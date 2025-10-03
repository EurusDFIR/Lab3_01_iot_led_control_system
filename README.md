# IoT LED Control System

Hệ thống điều khiển LED trên ESP32C3 qua MQTT với Web và Mobile App

## 🚀 Bắt đầu nhanh

**Người mới bắt đầu?** Làm theo thứ tự:

1. **Tìm IP máy tính:**

   ```bash
   find-ip.bat
   ```

   📖 Hoặc xem: [IP_CONFIG_SUMMARY.md](IP_CONFIG_SUMMARY.md)

2. **Setup hệ thống:**
   📖 Xem: [QUICKSTART.md](QUICKSTART.md) - Hướng dẫn từng bước

3. **Cấu hình chi tiết:**
   📖 Xem: [SETUP_GUIDE.md](SETUP_GUIDE.md) - Hướng dẫn đầy đủ

4. **Demo:**
   📖 Xem: [docs/DEMO_SCRIPT.md](docs/DEMO_SCRIPT.md) - Kịch bản demo

## ⚙️ Cấu hình IP (QUAN TRỌNG!)

Bạn ĐÃ cập nhật WiFi trong ESP32 ✅, còn cần:

### Bước 1: Tìm IP máy tính

```bash
# Chạy script:
find-ip.bat

# Hoặc thủ công:
ipconfig
# Tìm IPv4 Address
```

### Bước 2: Cập nhật 2 file

1. **ESP32:** `esp32-firmware/esp32_led_control.ino` - Line 26

   ```cpp
   const char *mqtt_server = "192.168.1.XX"; // 👈 Đổi IP
   ```

2. **Mobile:** `mobile-app/lib/services/api_service.dart` - Line 9
   ```dart
   static const String baseUrl = 'http://192.168.1.XX:8080/api'; // 👈 Đổi IP
   ```

📖 **Chi tiết:** [IP_CONFIGURATION_GUIDE.md](IP_CONFIGURATION_GUIDE.md)

## Kiến trúc hệ thống

```
ESP32C3 (LED) <--MQTT--> EMQX Broker <--MQTT--> Spring Boot API <--API--> Web (ReactJS) + Mobile (Flutter)
                                                        |
                                                   PostgreSQL
```

## Công nghệ sử dụng

- **Backend**: Java Spring Boot + Spring Integration MQTT (Paho)
- **Database**: PostgreSQL (DB: iot_led_control)
- **MQTT Broker**: EMQX
- **Web Frontend**: ReactJS
- **Mobile App**: Flutter
- **Hardware**: ESP32C3 với LED tích hợp
- **Tools**: MQTTX Client, Arduino IDE, VSCode, Android Studio

## Cấu trúc thư mục

```
3_01/
├── backend/           # Spring Boot API
├── web-app/          # ReactJS Web Application
├── mobile-app/       # Flutter Mobile Application
├── esp32-firmware/   # Arduino code cho ESP32C3
├── database/         # SQL scripts
└── docs/            # Tài liệu
```

## Setup Instructions

### 1. PostgreSQL Database

```bash
# Tạo database mới (tránh ghi đè project khác)
docker exec -it postgres_container_name psql -U postgres -c "CREATE DATABASE iot_led_control;"
```

### 2. EMQX Broker

```bash
# Kiểm tra EMQX đang chạy
docker ps | grep emqx

# EMQX Dashboard: http://localhost:18083
# Default: admin / public
```

### 3. Backend (Spring Boot)

```bash
cd backend
mvn clean install
mvn spring-boot:run
```

### 4. Web App (ReactJS)

```bash
cd web-app
npm install
npm start
```

### 5. Mobile App (Flutter)

```bash
cd mobile-app
flutter pub get
flutter run
```

### 6. ESP32C3 Firmware

- Mở Arduino IDE
- Mở file `esp32-firmware/esp32_led_control.ino`
- Cấu hình WiFi và MQTT broker
- Upload lên ESP32C3

## MQTT Topics

- **Control**: `esp32/led/control` - Publish lệnh bật/tắt LED
- **Status**: `esp32/led/status` - Subscribe trạng thái LED từ ESP32

## Payload Format

```json
{
  "deviceId": "ESP32C3_001",
  "command": "ON|OFF",
  "timestamp": "2025-10-03T10:30:00Z"
}
```

## 🔒 Bảo mật & GitHub

### Trước khi push lên GitHub:

1. **Xóa thông tin nhạy cảm:**

   - WiFi SSID/Password trong ESP32 code ✅ (đã làm)
   - Database passwords
   - API keys/tokens

2. **Sử dụng template config:**

   ```bash
   cp backend/src/main/resources/application-template.properties backend/src/main/resources/application-local.properties
   ```

3. **File đã được bảo vệ:**
   - `.gitignore` đã loại trừ file nhạy cảm
   - `application-local.properties` không được commit

### Push lên GitHub:

```bash
# Khởi tạo Git (nếu chưa có)
git init
git add .
git commit -m "Initial commit: IoT LED Control System"

# Tạo repo trên GitHub, sau đó:
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin master
```

## API Endpoints

- `GET /api/devices` - Lấy danh sách thiết bị
- `POST /api/devices` - Đăng ký thiết bị mới
- `POST /api/devices/{id}/control` - Điều khiển thiết bị
- `GET /api/devices/{id}/history` - Lịch sử điều khiển

## Testing with MQTTX

1. Connect to EMQX: `mqtt://localhost:1883`
2. Subscribe: `esp32/led/#`
3. Publish to: `esp32/led/control`
4. Payload: `{"deviceId":"ESP32C3_001","command":"ON"}`
