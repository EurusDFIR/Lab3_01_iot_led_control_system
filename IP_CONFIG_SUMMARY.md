# 📝 Tóm tắt Cấu hình IP - Checklist nhanh

## Bạn đã cấu hình WiFi trong ESP32 ✅

```cpp
const char *ssid = "";       // ✅
const char *password = ""; // ✅
```

## Còn 2 việc cần làm:

### 1️⃣ Tìm IP máy tính

**Cách 1: Chạy script**

```bash
find-ip.bat
```

**Cách 2: Thủ công**

```bash
# Mở CMD:
ipconfig

# Tìm dòng này:
IPv4 Address. . . . . . . . . . . : 192.168.1.10
                                    ^^^^^^^^^^^^
                                    Đây là IP bạn cần!
```

---

### 2️⃣ Cập nhật IP vào 2 file:

#### File 1: ESP32 Firmware

📁 `esp32-firmware/esp32_led_control.ino`

**Line 26:**

```cpp
// TRƯỚC (sai):
const char *mqtt_server = "192.168.1.10";

// SAU (đổi thành IP máy bạn):
const char *mqtt_server = "192.168.1.25"; // VD: nếu IP bạn là 192.168.1.25
```

#### File 2: Mobile App

📁 `mobile-app/lib/services/api_service.dart`

**Line 9:**

```dart
// TRƯỚC (sai):
static const String baseUrl = 'http://192.168.1.100:8080/api';

// SAU (đổi thành IP máy bạn):
static const String baseUrl = 'http://192.168.1.25:8080/api'; // VD
```

---

## ✅ Checklist hoàn thành:

- [ ] Đã tìm IP máy tính (bằng `ipconfig` hoặc `find-ip.bat`)
- [ ] Đã cập nhật IP trong `esp32_led_control.ino` line 26
- [ ] Đã cập nhật IP trong `api_service.dart` line 9
- [ ] WiFi SSID = "" ✅
- [ ] WiFi Password = "" ✅
- [ ] Backend application.properties KHÔNG CẦN đổi ✅

---

## 🎯 Ví dụ cụ thể:

Giả sử IP máy bạn là: **192.168.1.25**

### ESP32:

```cpp
const char *ssid = "";//ten wifi
const char *password = "";//pass
const char *mqtt_server = "192.168.1.25";  // 👈 Đổi thành IP này
```

### Mobile:

```dart
static const String baseUrl = 'http://192.168.1.25:8080/api'; // 👈 Đổi thành IP này
```

### Backend:

```properties
mqtt.broker.url=tcp://localhost:1883  # ✅ KHÔNG ĐỔI (giữ nguyên)
```

---

## 🚨 Lưu ý quan trọng:

1. **IP phải ĐÚNG** - không đúng thì không kết nối được
2. **Tất cả thiết bị cùng mạng WiFi** - máy tính, ESP32, điện thoại
3. **Không dùng `localhost` hay `127.0.0.1`** cho Mobile và ESP32
4. **Backend dùng `localhost`** là OK vì cùng máy với EMQX

---

## 🧪 Test nhanh:

### Test 1: Ping IP

```bash
ping 192.168.1.25
# Phải có reply → OK
```

### Test 2: Backend health

Mở browser:

```
http://localhost:8080/api/devices/health
```

Expect: `{"status":"UP",...}`

### Test 3: Mobile có connect được không?

Mở browser trên điện thoại:

```
http://192.168.1.25:8080/api/devices/health
```

Expect: Cùng response

### Test 4: ESP32 Serial Monitor

```
WiFi connected!
IP address: 192.168.x.x
Connecting to MQTT Broker...connected!
```

---

## ❓ Còn thắc mắc?

Đọc hướng dẫn chi tiết: [IP_CONFIGURATION_GUIDE.md](IP_CONFIGURATION_GUIDE.md)

---

**Tóm tắt ngắn gọn:**

1. Chạy `ipconfig` → lấy IPv4 Address
2. Sửa ESP32 line 26 → đổi IP
3. Sửa Mobile line 9 → đổi IP
4. Backend KHÔNG sửa
5. Test kết nối
6. Upload và chạy!

✅ **Xong!** Giờ bạn có thể tiếp tục với các bước khác trong QUICKSTART.md
