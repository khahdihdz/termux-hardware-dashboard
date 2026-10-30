# Termux Hardware Dashboard

Bảng điều khiển thông tin phần cứng Android chạy trong Termux — **không cần root**, hỗ trợ tiếng Việt và English.

## Cài đặt nhanh

```bash
pkg update && pkg install -y curl
curl -fsSL https://raw.githubusercontent.com/khahdihdz/termux-hardware-dashboard/main/install.sh | bash
hwinfo
```

## Tính năng
- Tổng quan thiết bị, CPU, GPU, RAM, lưu trữ, pin, màn hình, hệ thống, cảm biến và mạng.
- Menu terminal tự thích ứng với chiều rộng màn hình.
- Giao diện Việt/Anh và chẩn đoán quyền truy cập.
- Cập nhật có sao lưu; gỡ ứng dụng không xóa cấu hình.
- Không root, database, telemetry hay dịch vụ chạy nền.

Android có thể giới hạn một số thông số phần cứng. Ứng dụng chỉ hiển thị dữ liệu hệ thống cho phép truy cập.

## Website
- Tiếng Việt: https://khahdihdz.github.io/termux-hardware-dashboard/vi/
- English: https://khahdihdz.github.io/termux-hardware-dashboard/en/

## Credits
Developer: Khanh Dinh · https://khahdihdz.github.io · Support: https://thankyou.tip4serv.com

## License
MIT — xem [LICENSE](LICENSE).
