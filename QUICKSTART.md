# Quick Start Guide - IoT LED Control System

## 🚀 Khởi động nhanh

### Bước 0: Tìm IP máy tính (QUAN TRỌNG!)

**Chạy script tự động:**

```bash
find-ip.bat
```

Script sẽ hiển thị IP của bạn và hướng dẫn cấu hình.

**HOẶC tìm thủ công:**

```bash
# Mở CMD và chạy:
ipconfig

# Tìm dòng "IPv4 Address"
# Ví dụ: 192.168.1.10
```

📝 **Ghi lại IP này, bạn sẽ cần nó ở bước sau!**

### Bước 1: Setup Database (1 lần duy nhất)

```bash
cd database
setup.bat
```

### Bước 2: Khởi động Backend

**Terminal 1:**

```bash
run-backend.bat
```

Đợi đến khi thấy: `IoT LED Control Backend Started Successfully!`

### Bước 3: Khởi động Web App

**Terminal 2:**

```bash
run-webapp.bat
```

Trình duyệt tự động mở: http://localhost:3000

### Bước 4: Khởi động Mobile App (Optional)

**Terminal 3:**

```bash
# Đảm bảo Android Emulator đã chạy
run-mobile.bat
```

### Bước 5: Upload code lên ESP32C3

**⚠️ QUAN TRỌNG: Đã cấu hình IP chưa?**

Nếu chưa, chạy: `find-ip.bat` hoặc xem [IP_CONFIGURATION_GUIDE.md](IP_CONFIGURATION_GUIDE.md)

**Các bước upload:**

1. Mở Arduino IDE
2. Mở file: `esp32-firmware/esp32_led_control.ino`
3. **Kiểm tra cấu hình:**
   - ✅ WiFi SSID: `"TEN_WIFI_CUA_BAN"` (thay bằng SSID thật)
   - ✅ WiFi Password: `"MAT_KHAU_WIFI"` (thay bằng mật khẩu thật)
   - ⚠️ MQTT Server IP: `"192.168.1.10"` 👈 **PHẢI ĐÚNG IP MÁY BẠN!**
4. Chọn Board: **ESP32C3 Dev Module**
5. Chọn Port: **COM?**
6. Click Upload (→)
7. Mở Serial Monitor (115200 baud) kiểm tra log

### Bước 6: Test hệ thống

1. **Mở Web** (http://localhost:3000)
2. Xem thiết bị ESP32C3_001 trong danh sách
3. Click vào thiết bị
4. Nhấn "BẬT LED" → LED trên ESP32C3 sáng ✅
5. Nhấn "TẮT LED" → LED tắt ✅
6. Xem lịch sử điều khiển

## 📋 Checklist

- [ ] PostgreSQL container đang chạy
- [ ] EMQX container đang chạy
- [ ] Database `iot_led_control` đã được tạo
- [ ] Backend running tại http://localhost:8080
- [ ] Web app running tại http://localhost:3000
- [ ] ESP32C3 kết nối WiFi thành công
- [ ] ESP32C3 kết nối MQTT thành công
- [ ] LED có thể điều khiển từ Web/Mobile

## 🔧 Cấu hình nhanh

### IP máy tính (tìm IP của bạn)

```bash
ipconfig
# Tìm IPv4 Address (VD: 192.168.1.100)
```

### Cập nhật IP ở các file:

1. **ESP32 Firmware:**

   - File: `esp32-firmware/esp32_led_control.ino`
   - Line: `const char* mqtt_server = "192.168.1.100";`

2. **Mobile App:**
   - File: `mobile-app/lib/services/api_service.dart`
   - Line: `static const String baseUrl = 'http://192.168.1.100:8080/api';`

## 🧪 Test với MQTTX

1. Mở MQTTX Client
2. New Connection:
   - Name: `Test ESP32`
   - Host: `localhost`
   - Port: `1883`
   - Username: `admin`
   - Password: `public`
3. Subscribe: `esp32/#`
4. Publish message:
   ```
   Topic: esp32/led/control
   Payload: {"deviceId":"ESP32C3_001","command":"ON"}
   ```
5. Xem LED sáng và status message trả về

## ❓ Lỗi thường gặp

### Backend không start

```bash
# Kiểm tra PostgreSQL
docker ps | findstr postgres

# Kiểm tra EMQX
docker ps | findstr emqx
```

### Web không kết nối Backend

- Kiểm tra Backend đang chạy: http://localhost:8080/api/devices/health
- Xem Console log trên browser (F12)

### Mobile không kết nối Backend

- Thay `localhost` bằng IP máy tính
- Kiểm tra firewall
- Ping IP: `ping 192.168.1.100`

### ESP32 không kết nối MQTT

- Kiểm tra WiFi SSID/Password
- Kiểm tra MQTT server IP
- Xem Serial Monitor log
- Test MQTT với MQTTX trước

## 📱 Sử dụng ứng dụng

### Web Application (http://localhost:3000)

1. **Xem danh sách thiết bị**

   - Sidebar bên trái hiển thị tất cả thiết bị
   - Icon và màu sắc theo trạng thái

2. **Đăng ký thiết bị mới**

   - Nhấn "+ Đăng ký thiết bị"
   - Điền thông tin
   - Submit

3. **Điều khiển LED**
   - Click vào thiết bị
   - Nhấn "BẬT LED" (màu xanh)
   - Nhấn "TẮT LED" (màu đỏ)
   - Xem lịch sử bên dưới

### Mobile Application

1. **Xem danh sách**

   - Swipe down để refresh
   - Tap vào thiết bị để xem chi tiết

2. **Điều khiển**
   - Tap vào thiết bị
   - Nhấn button BẬT/TẮT
   - Pull down để refresh

## 🎯 Demo Flow

1. Start Backend + EMQX + PostgreSQL
2. Start Web App
3. Connect ESP32C3
4. Mở Web → Xem ESP32C3_001
5. Click thiết bị → Nhấn BẬT LED
6. LED sáng ✅
7. Xem MQTTX: message trên topic `esp32/led/status`
8. Kiểm tra Database: lệnh đã lưu vào `device_commands`

## 📚 Documentation

- [README.md](README.md) - Tổng quan dự án
- [SETUP_GUIDE.md](SETUP_GUIDE.md) - Hướng dẫn chi tiết
- [backend/README.md](backend/README.md) - Backend API docs
- [web-app/README.md](web-app/README.md) - Web app docs
- [mobile-app/README.md](mobile-app/README.md) - Mobile app docs
- [esp32-firmware/README.md](esp32-firmware/README.md) - Firmware docs

## 🆘 Cần trợ giúp?

1. Kiểm tra log của từng component
2. Test từng phần riêng lẻ
3. Đọc phần Troubleshooting trong SETUP_GUIDE.md
4. Kiểm tra mạng và firewall

---

**Happy Coding! 🎉**
