# Hướng dẫn Setup và Chạy Hệ thống IoT LED Control

## Tổng quan

Hệ thống bao gồm 5 thành phần chính:

1. **PostgreSQL Database** (Docker)
2. **EMQX MQTT Broker** (Docker)
3. **Backend API** (Spring Boot)
4. **Web Application** (ReactJS)
5. **Mobile Application** (Flutter)
6. **ESP32C3 Firmware** (Arduino)

## Yêu cầu hệ thống

### Phần mềm cần cài đặt:

- [x] Docker Desktop
- [x] PostgreSQL Container
- [x] EMQX Container
- [x] Java JDK 17+
- [x] Maven 3.6+
- [x] Node.js 16+ và npm
- [x] Flutter SDK 3.0+
- [x] Android Studio (với SDK và Emulator)
- [x] Arduino IDE
- [x] VSCode (đã cài Flutter Extension)
- [x] MQTTX Client (để test)

### Hardware:

- [x] ESP32C3 Dev Board (có LED tích hợp tại GPIO8)
- [x] USB Cable

## Các bước Setup

### Bước 1: Chuẩn bị Docker Containers

#### 1.1. Kiểm tra containers đang chạy

```bash
docker ps
```

Đảm bảo có:

- PostgreSQL container
- EMQX container

#### 1.2. Setup PostgreSQL Database

```bash
cd database
setup.bat
```

Hoặc thủ công:

```bash
# Tạo database mới
docker exec -it <postgres_container_name> psql -U postgres -c "CREATE DATABASE iot_led_control;"

# Import schema
docker exec -i <postgres_container_name> psql -U postgres -d iot_led_control < init.sql
```

#### 1.3. Kiểm tra EMQX

- Mở trình duyệt: http://localhost:18083
- Login: `admin` / `public`
- Kiểm tra Dashboard hoạt động

### Bước 2: Cấu hình Backend

#### 2.1. Cập nhật application.properties

File: `backend/src/main/resources/application.properties`

```properties
# PostgreSQL - Cập nhật nếu cần
spring.datasource.url=jdbc:postgresql://localhost:5432/iot_led_control
spring.datasource.username=postgres
spring.datasource.password=postgres

# MQTT - Cập nhật IP nếu cần
mqtt.broker.url=tcp://localhost:1883
mqtt.username=admin
mqtt.password=public
```

#### 2.2. Build và Run Backend

```bash
cd backend
mvn clean install
mvn spring-boot:run
```

Hoặc dùng script:

```bash
run-backend.bat
```

Kiểm tra: http://localhost:8080/api/devices/health

### Bước 3: Setup Web Application

#### 3.1. Cài đặt dependencies

```bash
cd web-app
npm install
```

#### 3.2. Cấu hình API URL (nếu backend không chạy ở localhost)

File: `web-app/src/services/api.js`

```javascript
const API_BASE_URL = "http://localhost:8080/api";
```

#### 3.3. Run Web App

```bash
npm start
```

Hoặc dùng script:

```bash
run-webapp.bat
```

Mở trình duyệt: http://localhost:3000

### Bước 4: Setup Mobile Application

#### 4.1. Cấu hình API URL

File: `mobile-app/lib/services/api_service.dart`

```dart
// Thay bằng IP máy tính chạy backend
static const String baseUrl = 'http://192.168.1.100:8080/api';
```

**Cách tìm IP:**

```bash
ipconfig
# Tìm IPv4 Address của card mạng đang dùng
```

#### 4.2. Cài đặt dependencies

```bash
cd mobile-app
flutter pub get
```

#### 4.3. Khởi động Android Emulator

- Mở Android Studio
- Tools → AVD Manager
- Chọn "Medium Phone API" và nhấn Play
- Đợi emulator khởi động hoàn toàn

#### 4.4. Run Flutter App

```bash
flutter run
```

Hoặc dùng script:

```bash
run-mobile.bat
```

### Bước 5: Upload Firmware lên ESP32C3

#### 5.1. Mở Arduino IDE

#### 5.2. Cấu hình Board

- Tools → Board → ESP32 Arduino → **ESP32C3 Dev Module**
- Tools → Upload Speed → 115200

#### 5.3. Cài đặt thư viện

Tools → Manage Libraries, cài:

- **PubSubClient** by Nick O'Leary
- **ArduinoJson** by Benoit Blanchon

#### 5.4. Cấu hình WiFi và MQTT

File: `esp32-firmware/esp32_led_control.ino`

```cpp
// WiFi Configuration
const char* ssid = "TEN_WIFI_CUA_BAN";
const char* password = "MAT_KHAU_WIFI";

// MQTT Configuration
const char* mqtt_server = "192.168.1.100";  // IP máy chạy EMQX
const char* client_id = "ESP32C3_001";
```

#### 5.5. Upload code

1. Kết nối ESP32C3 qua USB
2. Chọn COM Port: Tools → Port → COM?
3. Nhấn Upload (→)
4. Giữ nút BOOT nếu cần

#### 5.6. Kiểm tra Serial Monitor

- Tools → Serial Monitor
- Baud Rate: 115200
- Xem log kết nối WiFi và MQTT

## Kiểm tra hệ thống hoạt động

### Test 1: Kiểm tra Backend API

```bash
curl http://localhost:8080/api/devices
```

Hoặc mở Postman:

- GET http://localhost:8080/api/devices
- Expect: JSON array danh sách thiết bị

### Test 2: Kiểm tra MQTT với MQTTX

1. Mở MQTTX Client
2. Create Connection:
   - Host: `localhost`
   - Port: `1883`
   - Username: `admin`
   - Password: `public`
3. Subscribe: `esp32/#`
4. Publish test:
   - Topic: `esp32/led/control`
   - Payload:
     ```json
     { "deviceId": "ESP32C3_001", "command": "ON" }
     ```
5. Xem LED trên ESP32C3 sáng

### Test 3: Kiểm tra Web App

1. Mở http://localhost:3000
2. Xem danh sách thiết bị
3. Chọn ESP32C3_001
4. Nhấn "BẬT LED" → LED sáng
5. Nhấn "TẮT LED" → LED tắt
6. Xem lịch sử điều khiển

### Test 4: Kiểm tra Mobile App

1. Mở app trên emulator/device
2. Xem danh sách thiết bị
3. Tap vào ESP32C3_001
4. Nhấn "BẬT LED" → LED sáng
5. Nhấn "TẮT LED" → LED tắt
6. Pull to refresh để cập nhật

### Test 5: Kiểm tra Database

```bash
docker exec -it <postgres_container> psql -U postgres -d iot_led_control

# Xem thiết bị
SELECT * FROM devices;

# Xem lịch sử lệnh
SELECT * FROM device_commands ORDER BY created_at DESC LIMIT 10;

# Xem lịch sử trạng thái
SELECT * FROM device_status_history ORDER BY timestamp DESC LIMIT 10;
```

## Quy trình hoạt động

1. **User gửi lệnh từ Web/Mobile**

   - User nhấn nút "BẬT LED"
   - Frontend gọi API: `POST /api/devices/{id}/control`

2. **Backend xử lý**

   - Nhận request
   - Lưu lệnh vào database (table `device_commands`)
   - Publish message lên MQTT topic `esp32/led/control`

3. **ESP32C3 nhận và xử lý**

   - Subscribe topic `esp32/led/control`
   - Nhận JSON message
   - Parse và kiểm tra `deviceId`
   - Điều khiển LED (GPIO8)
   - Publish trạng thái lên topic `esp32/led/status`

4. **Backend nhận status**
   - Subscribe topic `esp32/led/status`
   - Cập nhật trạng thái vào database
   - Frontend tự động refresh hiển thị trạng thái mới

## Troubleshooting

### Backend không start

- Kiểm tra PostgreSQL đang chạy
- Kiểm tra EMQX đang chạy
- Xem log để biết lỗi cụ thể
- Kiểm tra port 8080 không bị chiếm

### Web App không kết nối Backend

- Kiểm tra CORS đã cấu hình
- Kiểm tra URL API trong `api.js`
- Xem Console log trên browser
- Test API với Postman trước

### Mobile App không kết nối Backend

- Kiểm tra IP trong `api_service.dart`
- Đảm bảo máy tính và emulator cùng mạng
- Không dùng `localhost` hoặc `127.0.0.1`
- Kiểm tra firewall

### ESP32C3 không kết nối WiFi

- Kiểm tra SSID và password
- Kiểm tra ESP32C3 trong vùng phủ sóng
- Xem Serial Monitor log
- Try reset ESP32C3

### ESP32C3 không kết nối MQTT

- Kiểm tra IP MQTT broker
- Ping từ máy tính đến IP đó
- Kiểm tra firewall
- Verify EMQX đang chạy: `docker ps`
- Xem EMQX log: `docker logs <emqx_container>`

### LED không hoạt động

- ESP32C3 LED tích hợp ở GPIO8
- Kiểm tra Serial Monitor xem có nhận message không
- Test với MQTTX trước
- Kiểm tra Device ID khớp với database

## Scripts tiện ích

```bash
# Run all services (cần mở 3 terminal)
# Terminal 1:
run-backend.bat

# Terminal 2:
run-webapp.bat

# Terminal 3:
run-mobile.bat
```

## Ghi chú quan trọng

1. **Database:** Sử dụng DB mới `iot_led_control` tránh ảnh hưởng project khác
2. **MQTT Topics:** Đảm bảo consistent giữa Backend, ESP32, và Database
3. **Device ID:** Phải khớp giữa code ESP32, database, và lệnh điều khiển
4. **Network:** Tất cả components phải cùng mạng để giao tiếp
5. **Firewall:** Có thể cần tắt firewall hoặc mở port 8080, 1883, 3000

## Next Steps

1. Test từng component riêng lẻ
2. Test tích hợp từng cặp (Backend-MQTT, Backend-DB, etc.)
3. Test end-to-end toàn bộ hệ thống
4. Monitor log ở tất cả components
5. Thử nghiệm các tình huống lỗi (disconnect, timeout, etc.)

Chúc bạn thành công! 🎉
