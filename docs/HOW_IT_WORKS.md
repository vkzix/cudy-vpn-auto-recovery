# How It Works

## Components

- `vpn-monitor`: procd init service.
- `vpn_healthcheck.sh`: continuous health-check loop.
- `fix_vpn.sh`: guarded HomeProxy recovery routine.
- `add_game_ports.sh`: recreates the project's dedicated nftables table.
- `/etc/vpn-auto-recovery.conf`: local configuration.

## Monitoring flow

1. procd starts `/usr/bin/vpn_healthcheck.sh`.
2. The monitor checks whether `singtun0` exists.
3. It tests external HTTPS connectivity through HomeProxy Mixed Proxy at `127.0.0.1:5330`.
4. The first probe is `https://api.ip.sb/geoip`; if it fails, the Cloudflare 204 endpoint is tried.
5. A successful probe resets the consecutive-failure counter.
6. After `MAX_FAILS` failed monitoring cycles, the monitor calls `fix_vpn.sh`.
7. A cooldown prevents repeated recovery attempts.

## Recovery flow

1. `fix_vpn.sh` performs up to three preliminary proxy checks.
2. If the proxy is already working, HomeProxy is not restarted.
3. If all preliminary checks fail, only `/etc/init.d/homeproxy restart` is executed.
4. The script waits and checks connectivity up to 15 times, with a four-second delay.
5. On success, the game-port helper is called.
6. If all checks fail, the recovery script exits with an error and the monitor logs the result.

## URLTest

VPN node selection belongs to HomeProxy's URLTest configuration. This project does not implement a separate node selector, modify subscription data, or guarantee that URLTest will always choose the fastest node.

## Safety boundaries

- No WAN interface restart.
- No global firewall reload.
- No forced node selection.
- The game-port helper modifies only its own `inet vpn_game_ports` nftables table.
- Game-port rules match DNATed traffic only.

## Timing defaults

- Monitor interval: 30 seconds.
- Failure threshold: 5 consecutive failed cycles.
- Recovery cooldown: 900 seconds.
- Post-restart checks: 15 × 4 seconds (up to approximately 60 seconds).
