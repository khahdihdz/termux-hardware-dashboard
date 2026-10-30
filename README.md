# Termux Hardware Dashboard

Bảng điều khiển thông tin phần cứng Android chạy trong Termux — **không cần root**, hỗ trợ tiếng Việt và English. Thiết kế Bash ưu tiên tương thích với nhiều thiết bị Android và kích thước terminal nhỏ.

## Cài đặt nhanh

```bash
pkg update && pkg install -y curl
curl -fsSL https://raw.githubusercontent.com/khahdihdz/termux-hardware-dashboard/main/install.sh | bash
hwinfo
```

## Tính năng

- **Tổng quan:** thông tin thiết bị, phiên bản Android, kernel và các chỉ số tài nguyên chính.
- **CPU:** SoC, số lõi, tải hệ thống, tần số từng lõi và CPU governor nếu Android cho phép.
- **GPU:** thông tin renderer/vendor từ SurfaceFlinger khi được hệ thống cung cấp.
- **RAM:** tổng, khả dụng, trống và Swap.
- **Lưu trữ:** dung lượng đã dùng/còn trống ở các phân vùng truy cập được.
- **Pin:** mức pin, trạng thái sạc, sức khỏe, nhiệt độ, điện áp và dòng điện khi có dữ liệu.
- **Màn hình:** độ phân giải và mật độ hiển thị.
- **Hệ thống:** thiết bị, Android SDK, build, kiến trúc, kernel và uptime.
- **Cảm biến:** dữ liệu IIO; có thể liệt kê cảm biến Android qua Termux:API.
- **Mạng:** interface, địa chỉ IP, route, DNS và trạng thái interface.
- **Chẩn đoán:** kiểm tra lệnh, đường dẫn sysfs và tiện ích Termux:API.
- Menu responsive, giao diện Việt/Anh, cài đặt/cập nhật có sao lưu và gỡ cài đặt.

## Tùy chọn bổ sung

Một số dữ liệu Android không cho ứng dụng Termux thông thường đọc trực tiếp. Có thể cài ứng dụng **Termux:API** tương ứng với bản Termux đang dùng, sau đó cài gói:
```bash
pkg install termux-api
```
Termux:API được dùng làm phương án bổ sung cho dữ liệu pin và cảm biến. Không bắt buộc để chạy dashboard.

## Giới hạn và quyền riêng tư

- Không yêu cầu root, không cần database, telemetry hoặc dịch vụ nền.
- Không dùng Shizuku/ADB để vượt giới hạn bảo mật Android.
- Thông tin CPU/GPU/cảm biến có thể thiếu tùy kernel, chipset, phiên bản Android và quyền truy cập.
- Tải hệ thống (load average) không phải phần trăm CPU utilization thực tế.
- Dashboard không ghi log giám sát liên tục và không gửi dữ liệu thiết bị ra ngoài.

## Tham khảo

Xem [các dự án và nguồn cảm hứng](docs/INSPIRATION.md) và [danh sách tính năng](docs/FEATURES.md).

## Website

- Tiếng Việt: https://khahdihdz.github.io/termux-hardware-dashboard/vi/
- English: https://khahdihdz.github.io/termux-hardware-dashboard/en/

## Credits

Developer: Khanh Dinh · https://khahdihdz.github.io · Support: https://thankyou.tip4serv.com

## License

MIT — xem [LICENSE](LICENSE).
