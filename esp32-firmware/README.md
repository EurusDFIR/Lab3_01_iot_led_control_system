# ESP32C3 LED Control Firmware

## Cấu hình Arduino IDE

### 1. Cài đặt ESP32 Board Manager

1. Mở Arduino IDE
2. File → Preferences
3. Thêm URL vào "Additional Board Manager URLs":
   ```
   https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
   ```
4. Tools → Board → Board Manager
5. Tìm "esp32" và cài đặt "esp32 by Espressif Systems"

### 2. Cài đặt thư viện cần thiết

Tools → Manage Libraries, tìm và cài đặt:

- **PubSubClient** (by Nick O'Leary) - Thư viện MQTT
- **ArduinoJson** (by Benoit Blanchon) - Thư viện JSON

### 3. Cấu hình Board

- Tools → Board → ESP32 Arduino → **ESP32C3 Dev Module**
- Tools → Upload Speed → 115200
- Tools → CPU Frequency → 160MHz
- Tools → Flash Size → 4MB
- Tools → Partition Scheme → Default 4MB

### 4. Cấu hình WiFi và MQTT

Mở file `esp32_led_control.ino` và chỉnh sửa:

```cpp
// WiFi Configuration
const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";

// MQTT Configuration
const char* mqtt_server = "192.168.1.100";  // IP máy chạy EMQX
const char* client_id = "ESP32C3_001";      // Device ID
```

### 5. Upload Code

1. Kết nối ESP32C3 với máy tính qua USB
2. Chọn đúng COM Port: Tools → Port → COM?
3. Click nút Upload (→)
4. Giữ nút BOOT trên ESP32C3 khi bắt đầu upload

### 6. Kiểm tra Serial Monitor

1. Tools → Serial Monitor
2. Baud Rate: 115200
3. Xem log kết nối WiFi và MQTT

## LED Pin Configuration

- **ESP32C3 có LED tích hợp tại GPIO8**
- Không cần kết nối LED ngoài
- LED sáng khi GPIO8 = HIGH
- LED tắt khi GPIO8 = LOW

## MQTT Topics

- **Control Topic**: `esp32/led/control` - Nhận lệnh điều khiển
- **Status Topic**: `esp32/led/status` - Gửi trạng thái LED

## JSON Message Format

**Control Message** (từ Backend → ESP32):

```json
{
  "deviceId": "ESP32C3_001",
  "command": "ON",
  "timestamp": "2025-10-03T10:30:00Z"
}
```

**Status Message** (từ ESP32 → Backend):

```json
{
  "deviceId": "ESP32C3_001",
  "command": "ON",
  "timestamp": 123456789
}
```

## Testing với MQTTX

1. Mở MQTTX Client
2. Connect to: `mqtt://localhost:1883`
3. Username: `admin`, Password: `public`
4. Subscribe to: `esp32/#` (xem tất cả messages)
5. Publish test message:
   - Topic: `esp32/led/control`
   - Payload:
     ```json
     { "deviceId": "ESP32C3_001", "command": "ON" }
     ```

## Troubleshooting

### Không kết nối được WiFi

- Kiểm tra SSID và password
- Đảm bảo ESP32C3 trong vùng phủ sóng WiFi
- Thử reset ESP32C3

### Không kết nối được MQTT

- Kiểm tra IP của EMQX broker
- Đảm bảo EMQX đang chạy: `docker ps`
- Kiểm tra firewall
- Verify username/password EMQX

### Upload code lỗi

- Giữ nút BOOT khi upload
- Chọn đúng COM Port
- Thử giảm Upload Speed xuống 57600

### LED không hoạt động

- ESP32C3 LED tích hợp ở GPIO8
- Kiểm tra Serial Monitor xem có nhận được message không
- Test với MQTTX trước khi test qua Web/Mobile
