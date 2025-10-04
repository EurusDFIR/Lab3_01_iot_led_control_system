# Configuration Template

File này giúp bạn dễ dàng thay đổi IP trong tất cả các file cần thiết.

## 🔍 Bước 1: Tìm IP máy tính

### Windows

```bash
ipconfig
```

Tìm dòng **IPv4 Address**, ví dụ: `192.168.1.100`

### Linux/MacOS

```bash
ifconfig
```

Hoặc

```bash
ip addr show
```

## 📝 Bước 2: Copy IP và thay thế

**IP máy tính của bạn:** `___________________` (Ghi lại đây)

## 🔧 Bước 3: Cập nhật các file

### File 1: ESP32 Firmware

**Đường dẫn:** `esp32-firmware/esp32_led_control/esp32_led_control.ino`

**Tìm dòng ~26-28:**

```cpp
const char *ssid = "YOUR_WIFI_SSID";           // 👈 Thay tên WiFi
const char *password = "YOUR_WIFI_PASSWORD";   // 👈 Thay mật khẩu WiFi
const char *mqtt_server = "192.168.1.XXX";     // 👈 Thay IP máy tính
```

**Thay bằng:**

```cpp
const char *ssid = "Tên_WiFi_Của_Bạn";
const char *password = "Mật_Khẩu_WiFi";
const char *mqtt_server = "192.168.1.XXX";  // IP bạn tìm được ở Bước 1
```

---

### File 2: Web App API Configuration

**Đường dẫn:** `web-app/src/services/api.js`

**Tìm dòng ~1:**

```javascript
const API_BASE_URL = "http://192.168.1.XXX:8080/api";
```

**Thay bằng:**

```javascript
const API_BASE_URL = "http://192.168.1.100:8080/api"; // IP của bạn
```

---

### File 3: Mobile App API Configuration

**Đường dẫn:** `mobile_app_new/lib/services/api_service.dart`

**Tìm dòng ~4:**

```dart
static const String baseUrl = 'http://192.168.1.XXX:8080/api';
```

**Thay bằng:**

```dart
static const String baseUrl = 'http://192.168.1.100:8080/api';  // IP của bạn
```

---

## ✅ Checklist

- [ ] Đã tìm IP máy tính
- [ ] Đã sửa WiFi SSID và Password trong ESP32
- [ ] Đã sửa MQTT Server IP trong ESP32
- [ ] Đã sửa API Base URL trong Web App
- [ ] Đã sửa API Base URL trong Mobile App
- [ ] Đã save tất cả các file

## 🎯 Lưu ý quan trọng

1. **IP phải giống nhau ở cả 3 file** (Web, Mobile, ESP32)
2. **Port 8080** là port của Backend API (không đổi)
3. **Port 1883** là port của MQTT (không đổi)
4. **Chỉ thay IP**, không thay port

## 🔄 Khi nào cần thay đổi IP?

- Đổi WiFi mới
- Đổi máy tính khác
- IP máy tính bị thay đổi (DHCP)

## 📱 Test kết nối

Sau khi cấu hình xong, test theo thứ tự:

1. **Test Backend API:**

   ```bash
   curl http://192.168.1.XXX:8080/api/devices
   ```

   Kết quả: Danh sách devices (hoặc array rỗng `[]`)

2. **Test Web App:**

   - Mở browser: `http://localhost:3000`
   - Kiểm tra console không có lỗi kết nối

3. **Test Mobile App:**

   - Chạy app trên emulator/device
   - Kiểm tra danh sách devices hiển thị

4. **Test ESP32:**
   - Mở Serial Monitor
   - Kiểm tra log: "Connected to MQTT"

---

## 🆘 Troubleshooting

### Không kết nối được API

- Kiểm tra Backend đã chạy: `http://localhost:8080`
- Kiểm tra IP đúng: `ipconfig`
- Kiểm tra Firewall không block port 8080

### ESP32 không kết nối MQTT

- Kiểm tra WiFi SSID/Password đúng
- Kiểm tra EMQX đã chạy: `docker ps`
- Kiểm tra IP trong code ESP32

### Mobile App không load data

- Kiểm tra IP trong `api_service.dart`
- Kiểm tra Backend đã chạy
- Kiểm tra device/emulator cùng mạng với máy tính

---

**Hoàn thành cấu hình!** 🎉

Tiếp theo: Chạy lệnh trong [QUICK_START.md](QUICK_START.md)
