# 🚀 Pre-Deployment Checklist - Kiểm tra trước khi push

## ✅ Đã hoàn thành

### 1. Cấu hình Flutter Android

- [x] `mobile_app_new/android/app/build.gradle.kts` có plugins block
- [x] Core library desugaring enabled cho flutter_local_notifications
- [x] compileSdk và targetSdk phù hợp

### 2. Docker Setup

- [x] `database/docker-compose.yml` với PostgreSQL + EMQX
- [x] `database/init.sql` để tạo bảng và dữ liệu
- [x] `database/setup.bat` để khởi tạo database

### 3. Configuration Templates

- [x] ESP32 firmware có placeholder IP (192.168.1.XXX)
- [x] CONFIG_TEMPLATE.md hướng dẫn thay IP
- [x] Mobile app dùng 10.0.2.2 cho Android emulator

### 4. Dependencies

- [x] Backend: Spring Boot 3.1.5, PostgreSQL, MQTT
- [x] Web App: React 18, Axios, React Router
- [x] Mobile App: Flutter 3.0+, HTTP, Provider, Local Notifications
- [x] ESP32: WiFi, PubSubClient, ArduinoJson, DHT

### 5. Documentation

- [x] README.md - Tổng quan dự án
- [x] QUICK_START.md - Hướng dẫn 5 phút
- [x] SYSTEM_SUMMARY.md - Tóm tắt hệ thống
- [x] CONFIG_TEMPLATE.md - Hướng dẫn cấu hình
- [x] DEPLOYMENT_CHECKLIST.md - Checklist deploy
- [x] FIXED_ISSUES.md - Lỗi đã fix
- [x] GIT_COMMIT_GUIDE.md - Hướng dẫn commit

### 6. Scripts & Automation

- [x] `run-backend.bat` - Chạy backend
- [x] `run-webapp.bat` - Chạy web app
- [x] `run-mobile.bat` - Chạy mobile app
- [x] `.gitignore` - Loại trừ build files

## 🔍 Cần kiểm tra thêm

### Environment Compatibility

- [ ] Java 17+ available
- [ ] Node.js 16+ available
- [ ] Flutter 3.0+ available
- [ ] Docker Desktop installed
- [ ] Arduino IDE hoặc PlatformIO

### Network Configuration

- [ ] WiFi credentials cho ESP32
- [ ] IP máy tính cho ESP32 MQTT server
- [ ] CORS origins cho web app (localhost:3000)
- [ ] Mobile app API URL (10.0.2.2 cho emulator)

### Hardware Requirements

- [ ] ESP32 board (ESP32C3 recommended)
- [ ] DHT11 sensor connected to GPIO2
- [ ] LED connected to GPIO8 (hoặc built-in LED)

## 🧪 Test Checklist

### Docker Test

```bash
cd database
docker-compose up -d
docker ps  # Check containers running
curl http://localhost:18083  # EMQX dashboard
```

### Backend Test

```bash
cd backend
mvn clean install
mvn spring-boot:run
curl http://localhost:8080/api/devices  # API test
```

### Web App Test

```bash
cd web-app
npm install
npm start
# Check http://localhost:3000
```

### Mobile App Test

```bash
cd mobile_app_new
flutter clean
flutter pub get
flutter run  # Android emulator
```

### ESP32 Test

- Upload code to ESP32
- Check serial monitor for WiFi/MQTT connection
- Test LED control from web/mobile app

## 📋 Final Steps

1. **Update CONFIG_TEMPLATE.md** với IP thực tế
2. **Test end-to-end** trên máy khác
3. **Update README.md** nếu cần
4. **Git commit** với message rõ ràng
5. **Push to repository**

---

**Status:** ✅ READY FOR DEPLOYMENT</content>
<parameter name="filePath">r:\_Documents_TDMU\KIEN_THUC_TDMU\4_year_HK1\IOT\TH\lab05\3_01\PRE_DEPLOYMENT_CHECKLIST.md
