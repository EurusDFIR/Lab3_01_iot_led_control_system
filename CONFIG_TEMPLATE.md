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

### ⚠️ **Quan trọng: Local Development Setup**

**Cho local development (phát triển trên cùng 1 máy), bạn CHỈ CẦN thay đổi:**

### File 1: ESP32 Firmware (BẮT BUỘC)

**Đường dẫn:** `esp32-firmware/esp32_led_control/esp32_led_control.ino`

**Tìm dòng ~30:**

```cpp
const char *mqtt_server = "192.168.1.XXX";     // 👈 Thay IP máy tính
```

**Thay bằng:**

```cpp
const char *mqtt_server = "192.168.1.100";  // IP bạn tìm được ở Bước 1
```

---

### 📝 **Các file khác (KHÔNG CẦN thay đổi cho local development):**

**File 2: Web App** - Đã được config sẵn cho localhost:

```javascript
// web-app/src/services/api.js
const API_BASE_URL = "http://localhost:8080/api"; // ✅ Đúng rồi
```

**File 3: Mobile App** - Đã được config sẵn cho Android Emulator:

```dart
// mobile_app_new/lib/services/api_service.dart
static const String baseUrl = 'http://10.0.2.2:8080/api'; // ✅ Đúng rồi
```

---

### 🌐 **Khi nào cần thay đổi Web App & Mobile App:**

- Khi **deploy production** trên nhiều máy khác nhau
- Khi **test trên real device** (không phải emulator)
- Khi **backend chạy trên máy khác** (không phải localhost)

````

**Thay bằng:**

---

## ✅ Checklist (Local Development)

- [ ] Đã tìm IP máy tính
- [ ] Đã sửa WiFi SSID và Password trong ESP32
- [ ] ✅ **Đã sửa MQTT Server IP trong ESP32** (chỉ file này cần thay!)
- [ ] ✅ **Web App** - đã dùng `localhost:8080` (không cần thay)
- [ ] ✅ **Mobile App** - đã dùng `10.0.2.2:8080` (không cần thay)
- [ ] Đã save file ESP32

## 🎯 Lưu ý quan trọng

1. **Local Development:** Chỉ cần thay IP ở ESP32
2. **Production/Multi-device:** Thay tất cả 3 file
3. **Port 8080** là port của Backend API (không đổi)
4. **Port 1883** là port của MQTT (không đổi)
5. **Chỉ thay IP**, không thay port

## 🔄 Khi nào cần thay đổi IP?

- Đổi WiFi mới
- Đổi máy tính khác
- IP máy tính bị thay đổi (DHCP)
- **Deploy production** trên nhiều máy

## 📱 Test kết nối

Sau khi cấu hình xong, test theo thứ tự:

1. **Test Backend API:**

   ```bash
   curl http://localhost:8080/api/devices
````

Kết quả: Danh sách devices (hoặc array rỗng `[]`)

2. **Test Web App:**

   ```bash
   cd web-app && npm start
   ```

   - Mở browser: `http://localhost:3000`
   - Kiểm tra console không có lỗi kết nối

3. **Test Mobile App:**

   ```bash
   cd mobile_app_new && flutter run
   ```

   - Chạy app trên emulator/device
   - Kiểm tra danh sách devices hiển thị

4. **Test ESP32:**
   - Upload code với IP đã thay đổi
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
- Kiểm tra IP trong code ESP32 khớp với IP máy tính (`ipconfig`)

### Mobile App không load data

- **Android Emulator**: IP `10.0.2.2` là đúng (không cần thay)
- **Real Device**: Thay thành IP thực của máy tính
- Kiểm tra Backend đã chạy
- Kiểm tra device/emulator cùng mạng với máy tính

---

**Hoàn thành cấu hình!** 🎉

Tiếp theo: Chạy lệnh trong [QUICK_START.md](QUICK_START.md)
