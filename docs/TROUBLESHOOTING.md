# Troubleshooting

## Service is not running

Check:

```sh
/etc/init.d/vpn-monitor status
logread -e vpn-healthcheck
```

Restart:

```sh
/etc/init.d/vpn-monitor restart
```

## TUN interface is missing

Check:

```sh
ip link show singtun0
```

Confirm that HomeProxy is configured to create the `singtun0` interface.

## Mixed Proxy is not reachable

Check the listener:

```sh
ss -lntp | grep 5330
```

Test through the proxy:

```sh
curl -I -x http://127.0.0.1:5330 --connect-timeout 5 --max-time 10 https://cp.cloudflare.com/generate_204
```

If your HomeProxy Mixed Proxy uses another port, update `PROXY_URL` in `/etc/vpn-auto-recovery.conf`.

## HomeProxy does not recover

Check:

```sh
/etc/init.d/homeproxy status
logread -e vpn-recovery -e homeproxy
```

Check that `/etc/init.d/homeproxy` exists and is executable.

## Check nftables game-port rules

```sh
nft list table inet vpn_game_ports
```

The helper only allows packets already marked as DNATed and does not create port-forwarding/NAT rules. Configure the actual port forwards separately in OpenWrt firewall.

To disable this helper, set:

```sh
ENABLE_GAME_PORT_RULES=0
```

Then run:

```sh
/etc/init.d/vpn-monitor restart
```

## Remove the project

From the project directory:

```sh
sh uninstall.sh
```

The configuration file is intentionally preserved:

```sh
/etc/vpn-auto-recovery.conf
```

Remove it manually only if you want to discard local settings:

```sh
rm -f /etc/vpn-auto-recovery.conf
```
