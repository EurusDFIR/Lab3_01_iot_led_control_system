# 🚀 IoT LED Control System - Quick Start Guide

Hướng dẫn chạy dự án trong 5 phút cho người mới clone về.

## 📋 Yêu cầu hệ thống

- **Java 17+** (cho Backend)
- **Node.js 16+** (cho Web App)
- **Flutter 3.0+** (cho Mobile App)
- **Docker Desktop** (cho PostgreSQL + EMQX)
- **Arduino IDE** hoặc **PlatformIO** (cho ESP32)

## ⚡ Khởi động nhanh (5 phút)

### Bước 1: Clone dự án

```bash
git clone <repository-url>
cd 3_01
```

### Bước 2: Khởi động Database + MQTT Broker (Docker)

```bash
cd database
docker-compose up -d
```

**Kiểm tra:**

- PostgreSQL: `localhost:5432`
- EMQX Dashboard: `http://localhost:18083` (admin/public)

### Bước 3: Tìm IP máy tính của bạn

```bash
# Windows
ipconfig

# Tìm dòng IPv4 Address (ví dụ: 192.168.1.100)
```

### Bước 4: Cập nhật IP trong ESP32

**📝 CHỈ CẦN SỬA 1 FILE (cho local development):**

**ESP32:** `esp32-firmware/esp32_led_control/esp32_led_control.ino`

```cpp
// Dòng ~30
const char *mqtt_server = "192.168.1.XXX";  // 👈 Thay IP máy tính của bạn
```

**💡 Lưu ý quan trọng:**

- **Web App** đã dùng `localhost:8080` - không cần thay đổi
- **Mobile App** đã dùng `10.0.2.2:8080` (IP đặc biệt cho Android Emulator) - không cần thay đổi
- **Chỉ ESP32** cần IP thực vì kết nối WiFi và MQTT qua mạng

### Bước 5: Chạy Backend (Spring Boot)

```bash
cd backend
mvn clean install
mvn spring-boot:run
```

**Kiểm tra:** Backend chạy tại `http://localhost:8080`

### Bước 6: Chạy Web App (React)

```bash
cd web-app
npm install
npm start
```

**Kiểm tra:** Web App mở tại `http://localhost:3000`

### Bước 7: Chạy Mobile App (Flutter)

**QUAN TRỌNG - LẦN ĐẦU CHẠY:**

```bash
cd mobile_app_new

# Bước 1: Làm sạch
flutter clean

# Bước 2: Lấy dependencies
flutter pub get

# Bước 3: Chạy app
flutter run
```

**Nếu gặp lỗi Gradle:** File `android/app/build.gradle.kts` đã được cấu hình sẵn với core library desugaring. Chỉ cần chạy lại `flutter run`.

### Bước 8: Upload code lên ESP32

1. Mở `esp32-firmware/esp32_led_control/esp32_led_control.ino` trong Arduino IDE
2. Đảm bảo đã cài đặt thư viện:
   - `WiFi`
   - `PubSubClient`
   - `DHT sensor library`
3. Chọn board: **ESP32C3 Dev Module**
4. Chọn Port và Upload

## Arduino IDE Setup

### Required Libraries

Cài đặt các thư viện sau trong Arduino IDE:

1. **PubSubClient** by Nick O'Leary

   - Sketch → Include Library → Manage Libraries
   - Search "PubSubClient" → Install

2. **ArduinoJson** by Benoit Blanchon

   - Sketch → Include Library → Manage Libraries
   - Search "ArduinoJson" → Install version 6.21.3

3. **DHT sensor library** by Adafruit
   - Sketch → Include Library → Manage Libraries
   - Search "DHT" → Install "DHT sensor library by Adafruit"

### ESP32 Board Setup

1. **Add ESP32 board to Arduino IDE:**

   - File → Preferences
   - Additional Boards Manager URLs: `https://dl.espressif.com/dl/package_esp32_index.json`
   - Tools → Board → Boards Manager
   - Search "esp32" → Install "ESP32 by Espressif Systems"

2. **Select Board:**

   - Tools → Board → ESP32 Arduino → ESP32C3 Dev Module

3. **Select Port:**
   - Tools → Port → Select your ESP32 COM port

### Upload Code

1. Open `esp32-firmware/esp32_led_control/esp32_led_control.ino`
2. Update WiFi credentials and MQTT server IP
3. Click Upload button (→)
4. Check Serial Monitor for connection status

## 🔧 Xử lý lỗi thường gặp

### Flutter Mobile App

**Lỗi: "Unsupported Gradle project"**

- ✅ Đã fix: File `android/app/build.gradle.kts` đã có plugins block và core library desugaring
- Chạy: `flutter clean && flutter pub get && flutter run`

**Lỗi: "Core library desugaring required"**

- ✅ Đã fix: `isCoreLibraryDesugaringEnabled = true` đã được bật
- File đã có dependency: `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")`

### Docker

**Lỗi: Port already in use**

```bash
# Dừng container cũ
docker-compose down

# Xóa container cũ
docker ps -a
docker rm -f <container-id>

# Chạy lại
docker-compose up -d
```

### Backend

**Lỗi: Database connection failed**

- Đảm bảo Docker đã chạy: `docker ps`
- Kiểm tra PostgreSQL: `docker logs postgres-iot`

## 📱 Test hệ thống

1. **Mở Web App** → Xem danh sách thiết bị
2. **Bật/Tắt LED** → Kiểm tra ESP32
3. **Xem dữ liệu cảm biến** → Nhiệt độ, độ ẩm
4. **Mở Mobile App** → Kiểm tra tương tự

## 🎯 Cấu trúc dự án

```
3_01/
├── backend/              # Spring Boot API
├── web-app/             # React Web UI
├── mobile_app_new/      # Flutter Mobile App ✅ Đã fix Gradle
├── esp32-firmware/      # Arduino ESP32 Code
├── database/            # Docker Compose (PostgreSQL + EMQX)
└── docs/                # Tài liệu chi tiết
```

## 💡 Lưu ý quan trọng

1. **IP Configuration:** Đây là bước QUAN TRỌNG nhất - phải sửa IP ở 3 file
2. **Docker:** Phải chạy trước khi start Backend
3. **Flutter First Run:** Lần đầu chạy `flutter run` có thể tốn 5-10 phút để download Gradle dependencies
4. **ESP32:** Nhớ cài đặt đúng thư viện DHT11

## 📚 Tài liệu chi tiết

- [SETUP_GUIDE.md](SETUP_GUIDE.md) - Hướng dẫn setup đầy đủ
- [API Documentation](docs/API.md) - Chi tiết REST API
- [Architecture](docs/ARCHITECTURE.md) - Kiến trúc hệ thống

## 🆘 Cần giúp đỡ?

Nếu gặp vấn đề, kiểm tra:

1. Docker containers đang chạy: `docker ps`
2. Backend logs: Terminal chạy `mvn spring-boot:run`
3. Flutter logs: Terminal chạy `flutter run`
4. ESP32 Serial Monitor: Kiểm tra kết nối WiFi/MQTT

---

**Tạo bởi:** IoT Team | **Version:** 1.0 | **Last Updated:** October 2025
