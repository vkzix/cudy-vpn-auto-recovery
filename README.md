Cudy VPN Auto Recovery

Automatic VPN monitoring and recovery for OpenWrt routers running HomeProxy.

Русская версия | English version

⸻

Русская версия

О проекте

Cudy VPN Auto Recovery — набор shell-скриптов для автоматического мониторинга и восстановления VPN-соединения на роутерах Cudy под управлением OpenWrt.

Проект предназначен для систем с HomeProxy и VPN на базе sing-box / hiddify-core, использующих TUN-интерфейс singtun0.

Основная задача — обнаруживать потерю VPN-соединения или доступа в интернет и автоматически пытаться восстановить работоспособность без ручного вмешательства.

Проект создавался и тестировался на Cudy TR3000 v1.

Возможности

* Автоматический мониторинг VPN-соединения.
* Проверка существования и состояния интерфейса singtun0.
* Проверка реальной доступности интернета через VPN.
* Использование нескольких HTTPS-проверок доступности.
* Защита от ложных срабатываний с помощью последовательных неудачных проверок.
* Автоматическое восстановление HomeProxy.
* Защитная пауза между попытками восстановления.
* Восстановление правил nftables для игровых портов.
* Запуск мониторинга через системный init.d-сервис.

Как работает

1. Служба vpn-monitor запускает vpn_healthcheck.sh.
2. Скрипт выполняет проверки каждые 30 секунд.
3. Проверяется наличие интерфейса singtun0.
4. Проверяется доступность внешних HTTPS-ресурсов через VPN.
5. При пяти последовательных неудачных проверках запускается процедура восстановления.
6. fix_vpn.sh перезапускает HomeProxy.
7. После перезапуска выполняется ожидание восстановления соединения (до 60 секунд).
8. Если восстановление не удалось, следующая попытка блокируется защитным интервалом в 900 секунд.

Параметры мониторинга

Параметр	Значение
Интервал проверки	30 секунд
Неудачных проверок до восстановления	5
Защитный интервал	900 секунд
Ожидание восстановления	До 60 секунд
TUN-интерфейс	singtun0
Служба VPN	HomeProxy

URLTest и выбор VPN-ноды

Выбор оптимальной VPN-ноды выполняется средствами HomeProxy через механизм URLTest.

Проект Auto Recovery не подменяет механизм выбора нод и не управляет подписками. Его задача — контролировать работоспособность VPN-инфраструктуры и восстанавливать HomeProxy при обнаружении проблем.

Результат URLTest зависит от доступности серверов, конфигурации HomeProxy и состояния VPN-узлов.

Структура проекта

cudy-vpn-auto-recovery/
├── README.md
├── LICENSE
├── install.sh
├── uninstall.sh
├── config/
│   └── defaults.conf
├── scripts/
│   ├── vpn_healthcheck.sh
│   ├── fix_vpn.sh
│   └── add_game_ports.sh
├── init.d/
│   └── vpn-monitor
└── docs/
    ├── INSTALL_RU.md
    ├── INSTALL_EN.md
    ├── HOW_IT_WORKS.md
    └── TROUBLESHOOTING.md

Назначение файлов

Файл	Назначение
install.sh	Установка проекта
uninstall.sh	Удаление проекта
defaults.conf	Настройки по умолчанию
vpn_healthcheck.sh	Мониторинг VPN
fix_vpn.sh	Восстановление HomeProxy
add_game_ports.sh	Восстановление игровых правил nftables
vpn-monitor	Служба автоматического мониторинга

Требования

* Совместимый роутер с OpenWrt.
* HomeProxy.
* Рабочая конфигурация VPN.
* TUN-интерфейс singtun0.
* Поддержка shell-скриптов и nftables.

Основная тестовая платформа:

* Router: Cudy TR3000 v1
* Firmware: OpenWrt 25.12.5
* VPN management: HomeProxy
* Core: hiddify-core / sing-box
* VPN protocol: VLESS Reality
* TUN interface: singtun0

Безопасность

В публичном репозитории не хранятся:

* VPN-подписки.
* VLESS UUID.
* Private keys.
* Адреса персональных VPN-серверов.
* Персональные конфигурации пользователей.

Каждый пользователь должен использовать собственную VPN-конфигурацию.

Установка

Инструкция по установке находится в INSTALL_RU.md.

Удаление

Для удаления предусмотрен uninstall.sh.

Подробности приведены в документации проекта.

Статус проекта

Проект находится в стадии разработки и тестирования на реальном оборудовании.

Цель — создать надёжный механизм автоматического восстановления VPN-соединения для домашних роутеров OpenWrt.

⸻

English Version

About

Cudy VPN Auto Recovery is a collection of shell scripts designed to automatically monitor and recover VPN connectivity on OpenWrt routers running HomeProxy.

The project targets systems using sing-box / hiddify-core-based VPN configurations with the singtun0 TUN interface.

Its primary purpose is to detect VPN connectivity failures and automatically attempt to restore network connectivity without manual intervention.

The project was developed and tested on the Cudy TR3000 v1 router.

Features

* Automatic VPN connectivity monitoring.
* TUN interface availability checks (singtun0).
* Real internet connectivity checks through the VPN.
* Multiple HTTPS connectivity probes.
* Consecutive failure detection to reduce false positives.
* Automatic HomeProxy recovery.
* Recovery cooldown to prevent restart loops.
* Restoration of nftables gaming port rules.
* Automatic monitoring through an init.d service.

How It Works

1. The vpn-monitor service starts vpn_healthcheck.sh.
2. The health-check script runs every 30 seconds.
3. The script checks whether singtun0 exists.
4. External HTTPS endpoints are tested through the VPN.
5. After five consecutive failed checks, recovery is triggered.
6. fix_vpn.sh restarts HomeProxy.
7. The script waits up to 60 seconds for connectivity to recover.
8. If recovery fails, another recovery attempt is prevented during the 900-second cooldown period.

Monitoring Parameters

Parameter	Value
Health-check interval	30 seconds
Consecutive failures	5
Recovery cooldown	900 seconds
Recovery wait timeout	Up to 60 seconds
TUN interface	singtun0
VPN service	HomeProxy

URLTest and VPN Node Selection

VPN node selection is handled by HomeProxy’s built-in URLTest mechanism.

Cudy VPN Auto Recovery does not replace the node-selection mechanism or manage VPN subscriptions.

Its purpose is to monitor VPN infrastructure and recover HomeProxy when connectivity failures are detected.

URLTest results depend on server availability, HomeProxy configuration and VPN node health.

Project Structure

cudy-vpn-auto-recovery/
├── README.md
├── LICENSE
├── install.sh
├── uninstall.sh
├── config/
│   └── defaults.conf
├── scripts/
│   ├── vpn_healthcheck.sh
│   ├── fix_vpn.sh
│   └── add_game_ports.sh
├── init.d/
│   └── vpn-monitor
└── docs/
    ├── INSTALL_RU.md
    ├── INSTALL_EN.md
    ├── HOW_IT_WORKS.md
    └── TROUBLESHOOTING.md

File Description

File	Description
install.sh	Project installation
uninstall.sh	Project removal
defaults.conf	Default configuration
vpn_healthcheck.sh	VPN health monitoring
fix_vpn.sh	HomeProxy recovery
add_game_ports.sh	nftables gaming port rule restoration
vpn-monitor	Automatic monitoring service

Requirements

* OpenWrt-compatible router.
* HomeProxy.
* Working VPN configuration.
* singtun0 TUN interface.
* Shell scripting and nftables support.

Primary test environment:

* Router: Cudy TR3000 v1
* Firmware: OpenWrt 25.12.5
* VPN management: HomeProxy
* Core: hiddify-core / sing-box
* VPN protocol: VLESS Reality
* TUN interface: singtun0

Security

The public repository does not contain:

* VPN subscription links.
* VLESS UUIDs.
* Private keys.
* Personal VPN server addresses.
* Private user configurations.

Users must provide their own VPN configurations.

Installation

See INSTALL_EN.md for installation instructions.

Uninstallation

The project provides an uninstall.sh script.

Refer to the project documentation for details.

Project Status

This project is under active development and testing on real hardware.

The goal is to provide a reliable automatic VPN recovery mechanism for OpenWrt home routers.

⸻

License

See LICENSE for license information.