#!/bin/sh
# Remove Cudy VPN Auto Recovery from OpenWrt.

set -eu

[ "$(id -u)" = "0" ] || {
    echo "ERROR: Run this uninstaller as root." >&2
    exit 1
}

if [ -x /etc/init.d/vpn-monitor ]; then
    /etc/init.d/vpn-monitor stop || true
    /etc/init.d/vpn-monitor disable || true
fi

rm -f /etc/init.d/vpn-monitor
rm -f /usr/bin/vpn_healthcheck.sh
rm -f /usr/bin/fix_vpn.sh
rm -f /usr/bin/add_game_ports.sh

# Remove only the dedicated table created by add_game_ports.sh.
if command -v nft >/dev/null 2>&1; then
    nft delete table inet vpn_game_ports 2>/dev/null || true
fi

# Keep the local config by default so a reinstall does not lose user settings.
# Remove it manually if a completely clean uninstall is desired.
echo "Cudy VPN Auto Recovery files removed."
echo "Configuration kept at /etc/vpn-auto-recovery.conf"
echo "To remove it too: rm -f /etc/vpn-auto-recovery.conf"
