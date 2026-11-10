#!/bin/sh
# Cudy VPN Auto Recovery - controlled HomeProxy recovery

CONFIG="/etc/vpn-auto-recovery.conf"
[ -r "$CONFIG" ] && . "$CONFIG"

HOMEPROXY_INIT="${HOMEPROXY_INIT:-/etc/init.d/homeproxy}"
PROXY_URL="${PROXY_URL:-http://127.0.0.1:5330}"
PROBE_URL_1="${PROBE_URL_1:-https://api.ip.sb/geoip}"
PROBE_URL_2="${PROBE_URL_2:-https://cp.cloudflare.com/generate_204}"
CURL_CONNECT_TIMEOUT="${CURL_CONNECT_TIMEOUT:-5}"
CURL_MAX_TIME="${CURL_MAX_TIME:-10}"
PRE_RESTART_ATTEMPTS="${PRE_RESTART_ATTEMPTS:-3}"
PRE_RESTART_WAIT="${PRE_RESTART_WAIT:-3}"
RECOVERY_ATTEMPTS="${RECOVERY_ATTEMPTS:-15}"
RECOVERY_WAIT="${RECOVERY_WAIT:-4}"
ENABLE_GAME_PORT_RULES="${ENABLE_GAME_PORT_RULES:-1}"

TAG="vpn-recovery"

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

check_proxy_connectivity() {
    probe_url "$PROBE_URL_1" && return 0
    probe_url "$PROBE_URL_2" && return 0
    return 1
}

restore_game_ports() {
    [ "$ENABLE_GAME_PORT_RULES" = "1" ] || return 0
    if [ -x /usr/bin/add_game_ports.sh ]; then
        /usr/bin/add_game_ports.sh
    else
        log "Скрипт игровых правил не найден или не исполняемый."
        return 1
    fi
}

log "Начата проверка перед перезапуском HomeProxy."

i=1
while [ "$i" -le "$PRE_RESTART_ATTEMPTS" ]; do
    if check_proxy_connectivity; then
        log "Mixed Proxy доступен. Перезапуск HomeProxy не требуется."
        restore_game_ports
        exit 0
    fi
    log "Предварительная проверка не пройдена: $i/$PRE_RESTART_ATTEMPTS."
    i=$((i + 1))
    [ "$i" -le "$PRE_RESTART_ATTEMPTS" ] && sleep "$PRE_RESTART_WAIT"
done

if [ ! -x "$HOMEPROXY_INIT" ]; then
    log "Не найден исполняемый init-скрипт HomeProxy: $HOMEPROXY_INIT"
    exit 1
fi

log "Три предварительные проверки не пройдены. Перезапускаю только HomeProxy."
"$HOMEPROXY_INIT" restart || {
    log "Команда перезапуска HomeProxy завершилась с ошибкой."
    exit 1
}

i=1
while [ "$i" -le "$RECOVERY_ATTEMPTS" ]; do
    sleep "$RECOVERY_WAIT"
    if check_proxy_connectivity; then
        log "VPN восстановлен: Mixed Proxy снова обеспечивает доступ в интернет."
        restore_game_ports
        exit 0
    fi
    log "Ожидание восстановления: проверка $i/$RECOVERY_ATTEMPTS."
    i=$((i + 1))
done

log "VPN не восстановился за отведённое время."
exit 1
