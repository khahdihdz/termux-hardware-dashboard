# Installation / Cài đặt

Run inside Termux:

```bash
pkg update && pkg install -y curl
curl -fsSL https://raw.githubusercontent.com/khahdihdz/termux-hardware-dashboard/main/install.sh | bash
hwinfo
```

No root required. Android may restrict access to thermal, sensor, GPU and battery interfaces; unavailable values are not fabricated.
