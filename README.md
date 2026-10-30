# Termux Hardware Dashboard

Bảng điều khiển phần cứng và tiện ích Android chạy trong Termux — **không cần root**, hỗ trợ tiếng Việt và English. Viết bằng Bash, tương thích terminal nhỏ trên điện thoại.

## Cài đặt nhanh

```bash
pkg update && pkg install -y curl
curl -fsSL https://raw.githubusercontent.com/khahdihdz/termux-hardware-dashboard/main/install.sh | bash
hwinfo
```

Để bật các tích hợp Android tùy chọn:
```bash
pkg install termux-api
```
Cài ứng dụng **Termux:API** riêng trên Android và bảo đảm ứng dụng này cùng nguồn cài đặt với Termux.

## Tính năng

- **Tổng quan:** thiết bị, Android, kernel và chỉ số tài nguyên.
- **CPU/GPU:** SoC, số lõi, tải hệ thống, tần số lõi, governor và renderer khi hệ thống cho phép.
- **RAM/Lưu trữ:** RAM khả dụng, Swap và dung lượng phân vùng.
- **Pin:** mức pin, trạng thái, sức khỏe, nhiệt độ, điện áp, dòng điện; ưu tiên sysfs và dự phòng Termux:API.
- **Màn hình/Hệ thống:** độ phân giải, mật độ, build, kiến trúc và uptime.
- **Cảm biến:** dữ liệu IIO và liệt kê/đọc mẫu cảm biến Android qua Termux:API.
- **Mạng:** interface, IP, route, DNS và thông tin kết nối Wi-Fi qua Termux:API.
- **Trung tâm Termux:API:** định vị một lần, thông tin camera, đèn flash, rung, thông báo, TTS, độ sáng và âm lượng.
- **Tự động hóa theo yêu cầu:** kiểm tra pin yếu và thông báo ngay khi người dùng mở mục; không cài dịch vụ nền.
- **Chẩn đoán:** kiểm tra lệnh, quyền và khả năng truy cập; menu responsive, VI/EN.

## Quyền riêng tư và giới hạn

- Không root, không database, không telemetry và không dịch vụ nền.
- Định vị chỉ chạy khi người dùng chủ động chọn; camera chỉ đọc thông tin thiết bị trong bản này.
- Các thao tác đèn flash, rung, thông báo, TTS và độ sáng chỉ thực hiện sau khi người dùng chọn.
- Không đọc SMS/danh bạ, không ghi âm, không tự động chụp ảnh.
- Android/OEM có thể hạn chế cảm biến, GPU, tần số CPU, mạng hoặc một số quyền.
- Tải hệ thống (load average) không phải phần trăm CPU utilization thực tế.
- Thiếu dữ liệu được hiển thị là không khả dụng, không giả lập số liệu.

## Website

- Tiếng Việt: https://khahdihdz.github.io/termux-hardware-dashboard/vi/
- English: https://khahdihdz.github.io/termux-hardware-dashboard/en/

## Credits

Developer: Khanh Dinh · https://khahdihdz.github.io · Support: https://thankyou.tip4serv.com

## License

MIT — xem [LICENSE](LICENSE).
