#!/bin/sh
# Cudy VPN Auto Recovery - continuous health monitor

CONFIG="/etc/vpn-auto-recovery.conf"
[ -r "$CONFIG" ] && . "$CONFIG"

CHECK_INTERVAL="${CHECK_INTERVAL:-30}"
MAX_FAILS="${MAX_FAILS:-5}"
COOLDOWN="${COOLDOWN:-900}"
TUN_INTERFACE="${TUN_INTERFACE:-singtun0}"
PROXY_URL="${PROXY_URL:-http://127.0.0.1:5330}"
PROBE_URL_1="${PROBE_URL_1:-https://api.ip.sb/geoip}"
PROBE_URL_2="${PROBE_URL_2:-https://cp.cloudflare.com/generate_204}"
CURL_CONNECT_TIMEOUT="${CURL_CONNECT_TIMEOUT:-5}"
CURL_MAX_TIME="${CURL_MAX_TIME:-10}"

TAG="vpn-healthcheck"
FAILS=0
LAST_RECOVERY=0

log() {
    logger -t "$TAG" "$1"
}

probe_url() {
    url="$1"
    curl -fsS -o /dev/null \
        --proxy "$PROXY_URL" \
        --connect-timeout "$CURL_CONNECT_TIMEOUT" \
        --max-time "$CURL_MAX_TIME" \
        "$url"
}

check_vpn() {
    # The TUN device must exist, but the primary connectivity test is
    # intentionally performed through HomeProxy's mixed proxy listener.
    ip link show dev "$TUN_INTERFACE" >/dev/null 2>&1 || return 1

    probe_url "$PROBE_URL_1" && return 0
    probe_url "$PROBE_URL_2" && return 0
    return 1
}

log "Контроль запущен. Основная проверка: Mixed Proxy 5330; TUN: $TUN_INTERFACE"

while :; do
    if check_vpn; then
        if [ "$FAILS" -gt 0 ]; then
            log "VPN снова доступен. Счётчик ошибок сброшен (было: $FAILS)."
        fi
        FAILS=0
    else
        FAILS=$((FAILS + 1))
        log "Проверка VPN не пройдена: $FAILS/$MAX_FAILS."

        if [ "$FAILS" -ge "$MAX_FAILS" ]; then
            NOW="$(date +%s)"
            ELAPSED=$((NOW - LAST_RECOVERY))

            if [ "$LAST_RECOVERY" -ne 0 ] && [ "$ELAPSED" -lt "$COOLDOWN" ]; then
                REMAINING=$((COOLDOWN - ELAPSED))
                log "Защитная пауза: до следующего восстановления осталось ${REMAINING} сек."
            else
                log "Порог ошибок достигнут. Запускаю автоматическое восстановление."
                LAST_RECOVERY="$NOW"

                if /usr/bin/fix_vpn.sh; then
                    log "Процедура восстановления завершена успешно."
                else
                    log "Восстановление не подтвердило доступность VPN."
                fi
            fi
            FAILS=0
        fi
    fi

    sleep "$CHECK_INTERVAL"
done
