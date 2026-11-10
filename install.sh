#!/bin/sh
# Install Cudy VPN Auto Recovery on OpenWrt.

set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
CONFIG_SRC="$SCRIPT_DIR/config/defaults.conf"
CONFIG_DST="/etc/vpn-auto-recovery.conf"

fail() {
    echo "ERROR: $*" >&2
    exit 1
}

[ "$(id -u)" = "0" ] || fail "Run this installer as root."
[ -r "$CONFIG_SRC" ] || fail "Missing config/defaults.conf."
[ -x /etc/init.d/homeproxy ] || fail "HomeProxy init script not found at /etc/init.d/homeproxy."
command -v curl >/dev/null 2>&1 || fail "curl is required. Install it with: apk add curl"
command -v nft >/dev/null 2>&1 || fail "nftables command is required."

mkdir -p /usr/bin
install -m 0755 "$SCRIPT_DIR/scripts/vpn_healthcheck.sh" /usr/bin/vpn_healthcheck.sh
install -m 0755 "$SCRIPT_DIR/scripts/fix_vpn.sh" /usr/bin/fix_vpn.sh
install -m 0755 "$SCRIPT_DIR/scripts/add_game_ports.sh" /usr/bin/add_game_ports.sh
install -m 0755 "$SCRIPT_DIR/init.d/vpn-monitor" /etc/init.d/vpn-monitor

if [ ! -e "$CONFIG_DST" ]; then
    install -m 0644 "$CONFIG_SRC" "$CONFIG_DST"
    echo "Created $CONFIG_DST"
else
    echo "Keeping existing $CONFIG_DST (user configuration was not overwritten)."
fi

/etc/init.d/vpn-monitor enable
/etc/init.d/vpn-monitor restart

echo
echo "Cudy VPN Auto Recovery installed."
echo "Check status: /etc/init.d/vpn-monitor status"
echo "View logs:    logread -e vpn-healthcheck -e vpn-recovery"
