# Project Structure Overview

```
3_01/
│
├── README.md                    # Tổng quan dự án
├── SETUP_GUIDE.md              # Hướng dẫn setup chi tiết
├── QUICKSTART.md               # Khởi động nhanh
├── .gitignore                  # Git ignore rules
│
├── docs/                       # Documentation
│   ├── ARCHITECTURE.md         # Kiến trúc hệ thống
│   ├── DEMO_SCRIPT.md          # Kịch bản demo
│   └── TESTING_GUIDE.md        # Hướng dẫn test
│
├── database/                   # Database scripts
│   ├── init.sql               # Schema và data mẫu
│   └── setup.bat              # Script setup database
│
├── backend/                    # Spring Boot Backend
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/iot/ledcontrol/
│   │   │   │   ├── LedControlApplication.java
│   │   │   │   ├── config/
│   │   │   │   │   ├── MqttConfig.java
│   │   │   │   │   ├── SecurityConfig.java
│   │   │   │   │   └── AppConfig.java
│   │   │   │   ├── controller/
│   │   │   │   │   └── DeviceController.java
│   │   │   │   ├── dto/
│   │   │   │   │   ├── DeviceDto.java
│   │   │   │   │   ├── MqttMessageDto.java
│   │   │   │   │   └── ControlCommandDto.java
│   │   │   │   ├── entity/
│   │   │   │   │   ├── Device.java
│   │   │   │   │   ├── DeviceCommand.java
│   │   │   │   │   └── DeviceStatusHistory.java
│   │   │   │   ├── repository/
│   │   │   │   │   ├── DeviceRepository.java
│   │   │   │   │   ├── DeviceCommandRepository.java
│   │   │   │   │   └── DeviceStatusHistoryRepository.java
│   │   │   │   └── service/
│   │   │   │       ├── MqttService.java
│   │   │   │       └── DeviceService.java
│   │   │   └── resources/
│   │   │       └── application.properties
│   │   └── test/
│   └── pom.xml
│
├── web-app/                    # ReactJS Web Application
│   ├── public/
│   │   └── index.html
│   ├── src/
│   │   ├── components/
│   │   │   ├── DeviceList.js
│   │   │   ├── DeviceList.css
│   │   │   ├── DeviceControl.js
│   │   │   ├── DeviceControl.css
│   │   │   ├── DeviceRegistration.js
│   │   │   └── DeviceRegistration.css
│   │   ├── services/
│   │   │   └── api.js
│   │   ├── App.js
│   │   ├── App.css
│   │   ├── index.js
│   │   └── index.css
│   ├── package.json
│   └── README.md
│
├── mobile-app/                 # Flutter Mobile Application
│   ├── lib/
│   │   ├── models/
│   │   │   ├── device.dart
│   │   │   └── device_command.dart
│   │   ├── providers/
│   │   │   └── device_provider.dart
│   │   ├── screens/
│   │   │   ├── home_screen.dart
│   │   │   ├── device_detail_screen.dart
│   │   │   └── register_device_screen.dart
│   │   ├── services/
│   │   │   └── api_service.dart
│   │   └── main.dart
│   ├── android/
│   │   └── app/src/main/
│   │       └── AndroidManifest.xml
│   ├── pubspec.yaml
│   └── README.md
│
├── esp32-firmware/             # Arduino ESP32C3 Firmware
│   ├── esp32_led_control.ino
│   └── README.md
│
├── run-backend.bat             # Script chạy backend
├── run-webapp.bat              # Script chạy web app
└── run-mobile.bat              # Script chạy mobile app
```

## File Descriptions

### Root Level

- **README.md**: Tổng quan về dự án, kiến trúc, công nghệ
- **SETUP_GUIDE.md**: Hướng dẫn setup từng bước chi tiết
- **QUICKSTART.md**: Hướng dẫn khởi động nhanh cho người mới
- **.gitignore**: Loại trừ file không cần commit

### Documentation (`docs/`)

- **ARCHITECTURE.md**: Kiến trúc hệ thống, data flow, design patterns
- **DEMO_SCRIPT.md**: Kịch bản demo chi tiết, Q&A
- **TESTING_GUIDE.md**: Hướng dẫn test, test cases

### Database (`database/`)

- **init.sql**: Database schema, tables, indexes, sample data
- **setup.bat**: Script tự động setup database

### Backend (`backend/`)

**Config Package:**

- `MqttConfig.java`: Cấu hình MQTT client, inbound/outbound adapters
- `SecurityConfig.java`: CORS, security configuration
- `AppConfig.java`: ObjectMapper, beans

**Controller Package:**

- `DeviceController.java`: REST API endpoints

**DTO Package:**

- `DeviceDto.java`: Device data transfer object
- `MqttMessageDto.java`: MQTT message format
- `ControlCommandDto.java`: Control command format

**Entity Package:**

- `Device.java`: Device entity (JPA)
- `DeviceCommand.java`: Command entity
- `DeviceStatusHistory.java`: Status history entity

**Repository Package:**

- `DeviceRepository.java`: Device CRUD operations
- `DeviceCommandRepository.java`: Command queries
- `DeviceStatusHistoryRepository.java`: History queries

**Service Package:**

- `MqttService.java`: MQTT publish/subscribe logic
- `DeviceService.java`: Business logic

### Web App (`web-app/`)

**Components:**

- `DeviceList.js/css`: Danh sách thiết bị
- `DeviceControl.js/css`: Điều khiển thiết bị
- `DeviceRegistration.js/css`: Đăng ký thiết bị mới

**Services:**

- `api.js`: API calls với axios

**Main:**

- `App.js/css`: Main component
- `index.js/css`: Entry point

### Mobile App (`mobile-app/`)

**Models:**

- `device.dart`: Device model class
- `device_command.dart`: Command model

**Providers:**

- `device_provider.dart`: State management với Provider

**Screens:**

- `home_screen.dart`: Màn hình chính
- `device_detail_screen.dart`: Chi tiết thiết bị
- `register_device_screen.dart`: Đăng ký thiết bị

**Services:**

- `api_service.dart`: HTTP API calls

### ESP32 Firmware (`esp32-firmware/`)

- **esp32_led_control.ino**: Arduino code cho ESP32C3
  - WiFi connection
  - MQTT client
  - LED control
  - JSON parsing

### Scripts

- **run-backend.bat**: Build và chạy Spring Boot backend
- **run-webapp.bat**: Install và chạy React web app
- **run-mobile.bat**: Run Flutter mobile app

## Technologies by Component

| Component | Technologies                                                       |
| --------- | ------------------------------------------------------------------ |
| Backend   | Java 17, Spring Boot 3.1, Spring Integration MQTT, JPA, PostgreSQL |
| Web       | React 18, Axios, CSS3                                              |
| Mobile    | Flutter 3.0+, Provider, HTTP                                       |
| Firmware  | Arduino C++, ESP32C3, WiFi, PubSubClient, ArduinoJson              |
| Database  | PostgreSQL 14+                                                     |
| Broker    | EMQX 5.x                                                           |
| Tools     | Maven, npm, Arduino IDE, MQTTX                                     |

## Key Features by File

### Backend API Endpoints (DeviceController.java)

```
GET    /api/devices                 - List all devices
GET    /api/devices/{id}            - Get device by ID
POST   /api/devices                 - Register new device
POST   /api/devices/{id}/control    - Control device
GET    /api/devices/{id}/history    - Command history
GET    /api/devices/health          - Health check
```

### MQTT Topics (MqttConfig.java)

```
esp32/led/control  - Publish control commands
esp32/led/status   - Subscribe to status updates
esp32/#           - Subscribe to all ESP32 topics
```

### Database Tables (init.sql)

```
devices               - Device information
device_commands       - Command history
device_status_history - Status tracking
```

## Line of Code Statistics (Approximate)

```
Backend (Java):        ~1,500 LOC
Web App (JS/JSX):      ~800 LOC
Mobile App (Dart):     ~1,000 LOC
ESP32 Firmware (C++):  ~250 LOC
Database (SQL):        ~150 LOC
Documentation (MD):    ~3,000 LOC
Total:                 ~6,700 LOC
```

## Dependencies Count

- **Backend**: 10+ dependencies (Spring Boot, PostgreSQL, MQTT, etc.)
- **Web**: 5+ dependencies (React, Axios, etc.)
- **Mobile**: 4+ dependencies (Provider, HTTP, JSON)
- **Firmware**: 3 libraries (WiFi, PubSubClient, ArduinoJson)

## File Size Summary

```
Backend:      ~500 KB (source code)
Web App:      ~200 KB (source code)
Mobile App:   ~150 KB (source code)
Firmware:     ~20 KB
Database:     ~20 KB
Docs:         ~100 KB
Total Source: ~1 MB
```

## Configuration Files

- `pom.xml` - Maven dependencies
- `package.json` - npm dependencies
- `pubspec.yaml` - Flutter dependencies
- `application.properties` - Spring Boot config
- `AndroidManifest.xml` - Android permissions

## Build Artifacts

- Backend: `target/led-control-backend-1.0.0.jar` (~50 MB)
- Web: `build/` folder (~2 MB)
- Mobile: `build/app/outputs/flutter-apk/app-release.apk` (~20 MB)
- Firmware: `.ino.bin` file (~1 MB)

---

This structure provides a complete, production-ready IoT LED control system with Web, Mobile, and Hardware components.
