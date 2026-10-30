# Features / Tính năng

## Hardware modules

- Device overview: manufacturer, model, Android version, SDK, build, architecture, kernel and uptime.
- CPU/SoC: processor identity, online core count, load average, per-core frequency and CPU governor where exposed.
- GPU: renderer/vendor details from Android SurfaceFlinger when accessible.
- Memory: total, available, free and swap memory.
- Storage: filesystem capacity and usage for accessible locations.
- Battery: capacity, status, health, temperature, voltage and current where exposed; Termux:API fallback.
- Display: physical/override resolution and density.
- Sensors: readable IIO sensor values; optional Termux:API sensor listing.
- Network: interfaces, IP addresses, routes, DNS and interface state.
- Diagnostics: command availability, sysfs access and optional Termux:API checks.

## Interface and maintenance

- Responsive terminal menu for narrow phone terminals and wider displays.
- Vietnamese and English labels.
- User-space installer, updater with backup, and uninstaller.
- No root, database, telemetry or always-on background service.

## Platform limitations

Android vendors and kernels expose different hardware interfaces. Missing values are shown as unavailable rather than guessed. Termux:API is optional and does not bypass Android permissions. CPU load average is not the same as instantaneous CPU utilization.
