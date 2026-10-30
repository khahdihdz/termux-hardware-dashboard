# Community references / Nguồn tham khảo

This project is an independent Bash implementation. The repositories below were reviewed for feature ideas and platform limitations; no source code is copied from them.

## Termux projects

- [Aj-Seven/Android-Sysinfo](https://github.com/Aj-Seven/Android-Sysinfo) — Bash menu, Android device information, CPU/memory/battery monitoring, sensor listing and optional ADB integration. Reference for module organization and diagnostics. This project deliberately does not require ADB or elevated access.
- [AhmarZaidi/termux-status](https://github.com/AhmarZaidi/termux-status) — Python terminal dashboard with CPU, memory, storage, battery, network, process and settings views. Reference for monitoring coverage and navigation.
- [tmck-code/termux-hardware-stats](https://github.com/tmck-code/termux-hardware-stats) — non-root hardware statistics library, including CPU core count, frequency and per-core usage. Reference for CPU data sources.
- [subhobhai943/termux-sysmon](https://github.com/subhobhai943/termux-sysmon) — system monitor covering Android, CPU, RAM, battery, storage, network and uptime. Reference for broad device coverage.
- [AbdulJ7/Sysinfo](https://github.com/AbdulJ7/Sysinfo) — Bash-based Android/Termux system information utility and command-oriented modules.

## Android hardware reference

- [KG Soft CPU Info](https://github.com/kamgurgul/cpu-info) — Android application covering CPU, GPU, RAM, storage, display, OS, sensors and battery. Used as a feature-coverage reference, not as a Termux dependency.

## Design decisions

- Keep the core implementation in Bash and compatible with ordinary Termux user permissions.
- Use Android-exposed `/proc`, `/sys`, `getprop`, `dumpsys` and standard Termux commands where available.
- Treat Termux:API as optional. Never assume every device exposes the same sensor, GPU or battery fields.
- Do not claim instantaneous CPU utilization when only Linux load average is available.
- Do not introduce root, Shizuku, ADB, background daemons, telemetry or cloud upload as core requirements.

Last reviewed: 2026-10-30.
