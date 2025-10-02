# Hướng dẫn Cấu hình IP cho Hệ thống

## 🔍 Bước 1: Tìm IP máy tính của bạn

### Trên Windows:

1. Nhấn `Windows + R`
2. Gõ `cmd` và Enter
3. Gõ lệnh: `ipconfig`
4. Tìm dòng **"IPv4 Address"** trong phần Wireless LAN adapter hoặc Ethernet adapter
5. Ví dụ: `192.168.1.10` (đây là IP bạn cần)

**Lưu ý:**

- Nếu dùng WiFi → tìm trong "Wireless LAN adapter Wi-Fi"
- Nếu dùng cáp mạng → tìm trong "Ethernet adapter"
- **KHÔNG** dùng `127.0.0.1` hay `localhost`

### Ví dụ output ipconfig:

```
Wireless LAN adapter Wi-Fi:
   IPv4 Address. . . . . . . . . . . : 192.168.1.10
   Subnet Mask . . . . . . . . . . . : 255.255.255.0
   Default Gateway . . . . . . . . . : 192.168.1.1
```

👆 **192.168.1.10** là IP bạn cần!

---

## 📝 Bước 2: Cập nhật IP vào các file

### ✅ File 1: ESP32 Firmware (ĐÃ CẬP NHẬT)

**File:** `esp32-firmware/esp32_led_control.ino`

```cpp
// Bạn đã cập nhật:
const char *ssid = "LE HUNG";       // ✅ OK
const char *password = "123456789"; // ✅ OK

// CẦN CẬP NHẬT IP này thành IP máy tính bạn:
const char *mqtt_server = "192.168.1.10"; // ⚠️ Thay bằng IP của BẠN
```

**Cách sửa:**

- Line 23: Đổi `"192.168.1.10"` thành IP máy tính bạn tìm được ở Bước 1
- Ví dụ: `const char *mqtt_server = "192.168.1.123";`

---

### 📌 File 2: Backend Application Properties

**File:** `backend/src/main/resources/application.properties`

**CẦN SỬA:**

#### 2.1. PostgreSQL Database (nếu Docker không chạy trên localhost)

```properties
# Nếu PostgreSQL chạy trên localhost (Docker Desktop):
spring.datasource.url=jdbc:postgresql://localhost:5432/iot_led_control

# Nếu PostgreSQL chạy trên máy khác:
spring.datasource.url=jdbc:postgresql://IP_POSTGRES:5432/iot_led_control
```

#### 2.2. MQTT Broker

```properties
# HIỆN TẠI:
mqtt.broker.url=tcp://localhost:1883

# CẦN ĐỔI THÀNH (nếu muốn ESP32 kết nối):
mqtt.broker.url=tcp://0.0.0.0:1883
# HOẶC dùng IP máy bạn:
mqtt.broker.url=tcp://192.168.1.10:1883
```

**⚠️ QUAN TRỌNG:**

- Nếu Backend và EMQX cùng máy → dùng `localhost:1883` OK
- Backend sẽ connect được vì chạy cùng máy với EMQX
- ESP32 connect bằng IP thật của máy (đã set ở mqtt_server)

**KHÔNG CẦN ĐỔI** nếu setup như sau:

- Backend chạy trên máy A (IP: 192.168.1.10)
- EMQX Docker chạy trên máy A
- Backend config: `tcp://localhost:1883` ✅
- ESP32 config: `mqtt_server = "192.168.1.10"` ✅

---

### 📱 File 3: Mobile App API Service

**File:** `mobile-app/lib/services/api_service.dart`

**CẦN SỬA Line 9:**

```dart
// HIỆN TẠI:
static const String baseUrl = 'http://192.168.1.100:8080/api';

// ĐỔI THÀNH IP máy tính bạn:
static const String baseUrl = 'http://192.168.1.10:8080/api';
//                                    ^^^^^^^^^^^^
//                                    IP của BẠN
```

**Ví dụ cụ thể:**

- Nếu IP máy bạn là `192.168.1.25`
- Đổi thành: `'http://192.168.1.25:8080/api'`

---

## 🎯 Tổng kết Cấu hình

Giả sử IP máy bạn là **192.168.1.10**:

| File                   | Line | Đổi từ                            | Đổi thành                             |
| ---------------------- | ---- | --------------------------------- | ------------------------------------- |
| esp32_led_control.ino  | 23   | `"192.168.1.10"`                  | `"192.168.1.10"` (hoặc IP mới)        |
| api_service.dart       | 9    | `'http://192.168.1.100:8080/api'` | `'http://192.168.1.10:8080/api'`      |
| application.properties | 20   | `tcp://localhost:1883`            | **KHÔNG CẦN ĐỔI** (nếu EMQX cùng máy) |

---

## ✅ Checklist Cấu hình

Sau khi cập nhật xong, kiểm tra:

### ESP32C3:

- [ ] WiFi SSID đúng: `"LE HUNG"`
- [ ] WiFi Password đúng: `"123456789"`
- [ ] MQTT Server IP đúng: `"192.168.1.10"` (IP máy bạn)
- [ ] Device ID: `"ESP32C3_001"` (khớp với database)

### Backend:

- [ ] PostgreSQL running: `docker ps | findstr postgres`
- [ ] EMQX running: `docker ps | findstr emqx`
- [ ] Port 8080 free (không bị chiếm)
- [ ] MQTT config: `tcp://localhost:1883` (nếu EMQX cùng máy)

### Mobile App:

- [ ] API URL có IP máy bạn: `http://192.168.1.10:8080/api`
- [ ] Emulator và máy tính cùng mạng WiFi
- [ ] Internet permission trong AndroidManifest.xml (đã có)

### Network:

- [ ] Tất cả devices (máy tính, ESP32, phone) cùng mạng WiFi
- [ ] Firewall cho phép port 8080, 1883
- [ ] Có thể ping IP máy tính: `ping 192.168.1.10`

---

## 🧪 Kiểm tra kết nối

### Test 1: Backend có chạy không?

Mở browser:

```
http://localhost:8080/api/devices/health
```

Expect: `{"status":"UP","service":"IoT LED Control Backend"}`

### Test 2: Mobile có kết nối được Backend không?

Mở browser trên điện thoại/emulator:

```
http://192.168.1.10:8080/api/devices/health
```

Expect: Cùng response như trên

### Test 3: ESP32 có kết nối được MQTT không?

Mở Serial Monitor (115200 baud):

```
Expect logs:
- WiFi connected!
- IP address: 192.168.x.x
- Connecting to MQTT Broker...connected!
- Subscribed to: esp32/led/control
```

### Test 4: MQTTX Client

1. Connect to: `192.168.1.10:1883`
2. Username: `admin`, Password: `public`
3. Subscribe: `esp32/#`
4. Publish to `esp32/led/control`:
   ```json
   { "deviceId": "ESP32C3_001", "command": "ON" }
   ```
5. LED trên ESP32 sáng → ✅ SUCCESS!

---

## ❌ Troubleshooting

### Lỗi: ESP32 không connect WiFi

```
Connecting to WiFi: LE HUNG
.......................
```

**Giải pháp:**

- Kiểm tra SSID và password
- Đảm bảo WiFi là 2.4GHz (ESP32C3 không hỗ trợ 5GHz)
- ESP32 trong vùng phủ sóng WiFi

### Lỗi: ESP32 không connect MQTT

```
Connecting to MQTT Broker...failed, rc=-2
```

**Giải pháp:**

- Kiểm tra IP MQTT server đúng chưa
- Ping IP từ máy tính: `ping 192.168.1.10`
- Kiểm tra EMQX đang chạy: `docker ps | findstr emqx`
- Kiểm tra firewall: cho phép port 1883

### Lỗi: Mobile không connect Backend

```
Error loading devices: Failed host lookup: '192.168.1.100'
```

**Giải pháp:**

- Đổi IP trong `api_service.dart` thành IP đúng
- Máy tính và emulator/phone cùng WiFi
- Test URL trên browser điện thoại trước

### Lỗi: Backend không start

```
Error creating bean with name 'mqttClientFactory'
```

**Giải pháp:**

- Kiểm tra EMQX container: `docker ps`
- Start EMQX nếu chưa chạy: `docker start <emqx_container>`

---

## 📞 Cần trợ giúp?

1. Kiểm tra IP máy bạn: `ipconfig`
2. Kiểm tra các container: `docker ps`
3. Xem log Backend khi start
4. Xem Serial Monitor của ESP32
5. Test từng component riêng lẻ

---

**Tóm tắt nhanh:**

1. Tìm IP máy bạn: `ipconfig` → lấy IPv4 Address
2. Sửa ESP32 line 23: `mqtt_server = "IP_CUA_BAN"`
3. Sửa Mobile line 9: `baseUrl = 'http://IP_CUA_BAN:8080/api'`
4. Backend thường KHÔNG CẦN sửa (dùng localhost OK)
5. Test từng bước!

Good luck! 🚀
