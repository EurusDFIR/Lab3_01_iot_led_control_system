# IoT LED Control System

Hệ thống điều khiển LED ESP32 qua MQTT với Web App và## 📖 Tài liệu đầy đủ

| File                                                           | Mô tả                                 | Dành cho     |
| -------------------------------------------------------------- | ------------------------------------- | ------------ | --------------------------- |
| [QUICK_START.md](QUICK_START.md)                               | Hướng dẫn chạy nhanh 5 phút           | ⭐ Người mới |
| [VERSION_INSTALLATION_GUIDE.md](VERSION_INSTALLATION_GUIDE.md) | Hướng dẫn cài đặt phiên bản chính xác | ⭐ Người mới |
| [CONFIG_TEMPLATE.md](CONFIG_TEMPLATE.md)                       | Template cấu hình IP                  | ⭐ Người mới |
| [FIXED_ISSUES.md](FIXED_ISSUES.md)                             | Danh sách lỗi đã fix                  | ⭐ Người mới |
| [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)             | Checklist trước khi push              | 👨‍💻 Developer |
| [SYSTEM_SUMMARY.md](SYSTEM_SUMMARY.md)                         | Tóm tắt hệ thống                      | 📖 Tham khảo |
| [SETUP_GUIDE.md](SETUP_GUIDE.md)                               | Hướng dẫn setup đầy đủ                | 📖 Tham khảo | pp - **Ready to Deploy** ✅ |

## 🎯 Dành cho người mới clone về

**Đọc ngay:** [QUICK_START.md](QUICK_START.md) - Hướng dẫn chạy trong 5 phút

**Các lỗi đã được fix sẵn:** [FIXED_ISSUES.md](FIXED_ISSUES.md) - Không cần lo lắng về Gradle, Docker, hay Dependencies

## 📋 System Requirements (Phiên bản chính xác)

**Quan trọng:** Để đảm bảo tương thích 100%, vui lòng cài đặt chính xác các phiên bản sau:

- **Java**: 17.0.x
- **Node.js**: 16.14.0+
- **Flutter**: 3.35.5 (stable)
- **Docker Desktop**: 4.0+
- **Arduino IDE**: 2.0+

📖 **Chi tiết cài đặt:** [VERSION_INSTALLATION_GUIDE.md](VERSION_INSTALLATION_GUIDE.md)

## ⚡ Quick Commands

```bash
# 1. Start Docker (PostgreSQL + EMQX)
cd database && docker-compose up -d

# 2. Start Backend
cd backend && mvn spring-boot:run

# 3. Start Web App
cd web-app && npm install && npm start

# 4. Start Mobile App (lần đầu)
cd mobile_app_new && flutter clean && flutter pub get && flutter run
```

## 📝 Configuration (CHỈ CẦN SỬA 1 FILE cho Local Development)

### 1. Tìm IP máy tính

```bash
ipconfig  # Windows
# Tìm IPv4 Address, ví dụ: 192.168.1.100
```

### 2. Cập nhật IP trong ESP32 file:

**ESP32:** `esp32-firmware/esp32_led_control/esp32_led_control.ino`

```cpp
const char *mqtt_server = "192.168.1.XXX";  // 👈 Thay IP máy tính của bạn
```

**💡 Lưu ý:**

- **Web App** đã dùng `localhost:8080` - không cần thay đổi
- **Mobile App** đã dùng `10.0.2.2:8080` (Android Emulator) - không cần thay đổi
- **Chỉ ESP32** cần IP thực vì kết nối WiFi và MQTT

📖 **Chi tiết cấu hình:** [CONFIG_TEMPLATE.md](CONFIG_TEMPLATE.md)

## 🚀 Bắt đầu nhanh

**Người mới bắt đầu?** Làm theo thứ tự:

1. **Khởi động nhanh:**
   📖 Xem: [QUICK_START.md](QUICK_START.md) - Hướng dẫn 5 phút

2. **Cấu hình IP:**
   📖 Xem: [CONFIG_TEMPLATE.md](CONFIG_TEMPLATE.md) - Template sửa IP

3. **Các lỗi đã fix:**
   📖 Xem: [FIXED_ISSUES.md](FIXED_ISSUES.md) - Không lo lắng về bugs

4. **Deployment:**
   📖 Xem: [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) - Checklist push lên Git

5. **Setup chi tiết:**
   📖 Xem: [SETUP_GUIDE.md](SETUP_GUIDE.md) - Hướng dẫn đầy đủ

## � Tài liệu đầy đủ

| File                                               | Mô tả                       | Dành cho     |
| -------------------------------------------------- | --------------------------- | ------------ |
| [QUICK_START.md](QUICK_START.md)                   | Hướng dẫn chạy nhanh 5 phút | ⭐ Người mới |
| [CONFIG_TEMPLATE.md](CONFIG_TEMPLATE.md)           | Template cấu hình IP        | ⭐ Người mới |
| [FIXED_ISSUES.md](FIXED_ISSUES.md)                 | Danh sách lỗi đã fix        | ⭐ Người mới |
| [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) | Checklist trước khi push    | 👨‍💻 Developer |
| [SETUP_GUIDE.md](SETUP_GUIDE.md)                   | Hướng dẫn setup đầy đủ      | 📖 Tham khảo |

## ✨ Điểm nổi bật

✅ **Sẵn sàng deploy** - Tất cả lỗi Gradle đã được fix sẵn
✅ **Dễ dàng setup** - Chỉ cần sửa IP ở 3 files
✅ **Docker ready** - PostgreSQL + EMQX một lệnh khởi động
✅ **Cross-platform** - Web, Mobile, ESP32 đều hoạt động
✅ **Well documented** - Tài liệu đầy đủ và rõ ràng

## 🎯 Kiến trúc hệ thống

```
ESP32C3 (LED) <--MQTT--> EMQX Broker <--MQTT--> Spring Boot API <--API--> Web (ReactJS) + Mobile (Flutter)
                                                        |
                                                   PostgreSQL
```

## 💻 Công nghệ sử dụng

- **Backend**: Java Spring Boot + Spring Integration MQTT (Paho)
- **Database**: PostgreSQL + Docker
- **MQTT Broker**: EMQX (Docker)
- **Web Frontend**: ReactJS
- **Mobile App**: Flutter (với core library desugaring ✅)
- **Hardware**: ESP32C3 với LED tích hợp + DHT11
- **Tools**: Docker, Maven, npm, Arduino IDE

## 📁 Cấu trúc thư mục

```
3_01/
├── backend/              # Spring Boot API
├── web-app/             # ReactJS Web Application
├── mobile_app_new/      # Flutter Mobile App ✅ Gradle fixed
├── esp32-firmware/      # Arduino code cho ESP32C3
├── database/            # Docker Compose + SQL scripts
├── docs/                # Tài liệu chi tiết
├── QUICK_START.md       # 🚀 Bắt đầu đây
├── VERSION_INSTALLATION_GUIDE.md  # 🔧 Cài đặt phiên bản chính xác
├── CONFIG_TEMPLATE.md   # 📝 Cấu hình IP
├── FIXED_ISSUES.md      # ✅ Lỗi đã fix
└── DEPLOYMENT_CHECKLIST.md  # 📦 Checklist deploy
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
