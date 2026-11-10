# Installing Cudy VPN Auto Recovery

## Requirements

- OpenWrt with BusyBox ash and procd.
- HomeProxy installed and configured.
- HomeProxy Mixed Proxy listening on `127.0.0.1:5330`.
- TUN interface named `singtun0`.
- `curl` and `nftables` installed.

The project was developed on a Cudy TR3000 v1 running OpenWrt 25.12.5. Interface names and ports may differ on other routers.

## Installation

1. Download the repository and extract it on the router, or copy the project directory to the device.
2. Change to the project root directory.
3. Run:

```sh
sh install.sh
```

The installer checks for HomeProxy, curl and nft, installs the scripts and registers the `vpn-monitor` procd service.

If `/etc/vpn-auto-recovery.conf` already exists, the installer will not overwrite it.

## Configuration

Edit:

```sh
vi /etc/vpn-auto-recovery.conf
```

Main settings:

| Parameter | Default | Description |
|---|---:|---|
| `CHECK_INTERVAL` | 30 | Health-check interval in seconds |
| `MAX_FAILS` | 5 | Consecutive failures before recovery |
| `COOLDOWN` | 900 | Recovery cooldown in seconds |
| `TUN_INTERFACE` | singtun0 | TUN interface name |
| `PROXY_URL` | http://127.0.0.1:5330 | HomeProxy Mixed Proxy |
| `RECOVERY_ATTEMPTS` | 15 | Checks after restarting HomeProxy |
| `RECOVERY_WAIT` | 4 | Delay between recovery checks |
| `ENABLE_GAME_PORT_RULES` | 1 | Enable game-port rules |

Make sure the Mixed Proxy address and TUN interface match your HomeProxy configuration.

## Check the service

```sh
/etc/init.d/vpn-monitor status
logread -e vpn-healthcheck -e vpn-recovery
```

Restart:

```sh
/etc/init.d/vpn-monitor restart
```

## Uninstallation

```sh
sh uninstall.sh
```

The uninstaller removes the service and installed executables, deletes the project's dedicated nftables table, but keeps `/etc/vpn-auto-recovery.conf`.

## Important notes

The recovery script restarts HomeProxy only. It does not run `ifup wan`, reload the firewall, or force HomeProxy to select a specific VPN node.

Game-port rules match only packets with `ct status dnat`. Corresponding port-forwarding rules must also exist in the firewall configuration.
