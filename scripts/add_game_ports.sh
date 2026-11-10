#!/bin/sh
# Recreate a dedicated nftables chain for the project's game-port allowances.
# The chain accepts only packets already DNATed to a forwarded destination.
# Firewall drops in other base chains are not bypassed.

CONFIG="/etc/vpn-auto-recovery.conf"
[ -r "$CONFIG" ] && . "$CONFIG"

ENABLE_GAME_PORT_RULES="${ENABLE_GAME_PORT_RULES:-1}"
GAME_TCP_PORTS="${GAME_TCP_PORTS:-9339,5000-10000}"
GAME_UDP_PORTS="${GAME_UDP_PORTS:-9339,5000-10000}"

TAG="vpn-game-ports"
TABLE="vpn_game_ports"
CHAIN="forward"

log() {
    logger -t "$TAG" "$1"
}

[ "$ENABLE_GAME_PORT_RULES" = "1" ] || exit 0

command -v nft >/dev/null 2>&1 || {
    log "Команда nft не найдена."
    exit 1
}

# Validate the port-list syntax before inserting it into an nft command.
case "$GAME_TCP_PORTS$GAME_UDP_PORTS" in
    *[!0-9,-]*|'')
        log "Некорректный список игровых портов."
        exit 1
        ;;
esac

# Recreate only our own table; do not flush or modify the fw4 table.
nft delete table inet "$TABLE" 2>/dev/null
nft add table inet "$TABLE" || exit 1
nft "add chain inet $TABLE $CHAIN { type filter hook forward priority -5; policy accept; }" || exit 1

# Match only packets that have already been destination-NATed by an explicit
# port-forward. The normal OpenWrt firewall remains responsible for other traffic.
if [ -n "$GAME_TCP_PORTS" ]; then
    nft add rule inet "$TABLE" "$CHAIN" ct status dnat tcp dport "{ $GAME_TCP_PORTS }" accept || exit 1
fi
if [ -n "$GAME_UDP_PORTS" ]; then
    nft add rule inet "$TABLE" "$CHAIN" ct status dnat udp dport "{ $GAME_UDP_PORTS }" accept || exit 1
fi

log "Правила игровых портов восстановлены: TCP [$GAME_TCP_PORTS], UDP [$GAME_UDP_PORTS]."
exit 0
