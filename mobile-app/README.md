# IoT LED Control - Flutter Mobile App

## Yêu cầu

- Flutter SDK 3.0+
- Android Studio với Android SDK
- Máy ảo Android (Medium Phone API)
- Backend API đang chạy

## Cài đặt

### 1. Cài đặt dependencies

```bash
cd mobile-app
flutter pub get
```

### 2. Cấu hình API URL

Mở file `lib/services/api_service.dart` và thay đổi IP:

```dart
static const String baseUrl = 'http://192.168.1.100:8080/api';
```

**Lưu ý:**

- Không dùng `localhost` vì emulator/device cần IP thực
- Tìm IP máy tính: `ipconfig` (Windows) hoặc `ifconfig` (Mac/Linux)
- Máy tính và emulator/device phải cùng mạng WiFi

### 3. Chạy ứng dụng

```bash
flutter run
```

Hoặc sử dụng Android Studio:

- Run → Run 'main.dart'
- Chọn emulator Medium Phone API

## Cấu trúc project

```
mobile-app/
├── lib/
│   ├── models/
│   │   ├── device.dart              # Model thiết bị
│   │   └── device_command.dart      # Model lệnh điều khiển
│   ├── providers/
│   │   └── device_provider.dart     # State management
│   ├── screens/
│   │   ├── home_screen.dart         # Màn hình chính
│   │   ├── device_detail_screen.dart # Chi tiết thiết bị
│   │   └── register_device_screen.dart # Đăng ký thiết bị
│   ├── services/
│   │   └── api_service.dart         # API calls
│   └── main.dart                    # Entry point
├── android/
│   └── app/src/main/AndroidManifest.xml
├── pubspec.yaml
└── README.md
```

## Chức năng

### 1. Danh sách thiết bị

- Hiển thị tất cả thiết bị
- Thông tin: Tên, Device ID, Status
- Icon và màu sắc theo trạng thái
- Pull to refresh
- Tap để xem chi tiết

### 2. Chi tiết thiết bị

- Thông tin đầy đủ về thiết bị
- Nút BẬT/TẮT LED lớn, trực quan
- Hiển thị 5 lệnh gần nhất
- Pull to refresh

### 3. Đăng ký thiết bị

- Form đầy đủ với validation
- Các trường: Device ID, Tên, Loại, Mô tả, MQTT Topics
- Dropdown chọn loại thiết bị
- Loading state khi đăng ký

## Testing

### 1. Test với Emulator

```bash
flutter run -d emulator-5554
```

### 2. Test với thiết bị thật

- Enable USB Debugging trên điện thoại
- Kết nối USB
- `flutter devices` để xem danh sách
- `flutter run -d <device_id>`

### 3. Build APK

```bash
flutter build apk --release
```

APK sẽ được tạo tại: `build/app/outputs/flutter-apk/app-release.apk`

## Troubleshooting

### Không kết nối được API

1. Kiểm tra IP trong `api_service.dart`
2. Ping IP từ máy tính: `ping 192.168.1.100`
3. Kiểm tra firewall
4. Đảm bảo backend đang chạy
5. Test API với Postman trước

### Lỗi "Cleartext HTTP traffic not permitted"

- Đã được fix trong `AndroidManifest.xml`
- Thêm `android:usesCleartextTraffic="true"`

### Emulator chậm

- Tăng RAM cho emulator trong AVD Manager
- Enable Hardware Acceleration
- Chọn loại máy ảo "Medium Phone" không quá nặng

### Hot reload không hoạt động

```bash
flutter clean
flutter pub get
flutter run
```

## Dependencies

- `http: ^1.1.0` - HTTP client
- `provider: ^6.1.1` - State management
- `json_annotation: ^4.8.1` - JSON serialization

## Permissions (AndroidManifest.xml)

- `INTERNET` - Gọi API
- `ACCESS_NETWORK_STATE` - Kiểm tra kết nối mạng

## Tips

1. Luôn kiểm tra Console log để debug
2. Dùng `flutter doctor` để check cấu hình
3. Test API với Postman trước khi test app
4. Sử dụng Android Studio Logcat để xem log chi tiết
