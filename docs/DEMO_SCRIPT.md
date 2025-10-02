# Demo Script - IoT LED Control System

## Chuẩn bị trước Demo

### Checklist

- [ ] PostgreSQL container running
- [ ] EMQX container running
- [ ] Database initialized
- [ ] Backend running (http://localhost:8080)
- [ ] Web app running (http://localhost:3000)
- [ ] Mobile app running on emulator
- [ ] ESP32C3 connected and running
- [ ] MQTTX client ready
- [ ] Browser tabs prepared
- [ ] Serial Monitor open

### Setup môi trường

```bash
# Terminal 1 - Backend
cd backend
mvn spring-boot:run

# Terminal 2 - Web App
cd web-app
npm start

# Terminal 3 - Mobile App (optional)
cd mobile-app
flutter run

# Terminal 4 - Serial Monitor
# Arduino IDE → Tools → Serial Monitor
```

## Demo Flow (15-20 phút)

### Phần 1: Giới thiệu Hệ thống (2 phút)

**Script:**

```
"Xin chào, hôm nay em xin trình bày hệ thống điều khiển LED trên vi điều
khiển ESP32C3 qua giao thức MQTT.

Hệ thống bao gồm:
- Backend API: Spring Boot với tích hợp MQTT
- Frontend: Web app ReactJS và Mobile app Flutter
- MQTT Broker: EMQX
- Database: PostgreSQL
- Hardware: ESP32C3 với LED tích hợp

[Chỉ vào sơ đồ kiến trúc trên slide]

Hệ thống cho phép điều khiển LED từ Web hoặc Mobile, lưu lịch sử vào
database, và giao tiếp qua MQTT."
```

### Phần 2: Kiểm tra Components (3 phút)

#### 2.1. Backend API

```
"Đầu tiên, kiểm tra Backend API đã hoạt động:"

[Mở browser tab: http://localhost:8080/api/devices]

"API trả về danh sách thiết bị đã đăng ký trong database."
```

#### 2.2. EMQX Dashboard

```
"Tiếp theo, EMQX MQTT Broker:"

[Mở browser tab: http://localhost:18083]
Login: admin / public

"Dashboard hiển thị thông tin broker, các kết nối, và topics đang hoạt động."

[Click vào Connections → chỉ ESP32C3 connection]
```

#### 2.3. ESP32C3 Serial Monitor

```
"ESP32C3 đã kết nối thành công:"

[Chỉ Serial Monitor]

"Log cho thấy:
- Kết nối WiFi thành công
- Kết nối MQTT thành công
- Subscribe topic esp32/led/control
- Gửi status ONLINE"
```

### Phần 3: Demo Web Application (5 phút)

#### 3.1. Xem danh sách thiết bị

```
"Mở Web application:"

[Mở http://localhost:3000]

"Giao diện hiển thị danh sách thiết bị đã đăng ký.
Mỗi thiết bị có:
- Tên và ID
- Trạng thái hiện tại
- Icon trực quan"

[Chỉ vào từng thiết bị]
```

#### 3.2. Điều khiển LED từ Web

```
"Click vào thiết bị ESP32C3_001 để xem chi tiết:"

[Click vào device]

"Màn hình chi tiết hiển thị:
- Thông tin thiết bị
- Các nút điều khiển
- Lịch sử điều khiển"

[Scroll để show các phần]

"Bây giờ em sẽ BẬT LED:"

[Click nút "BẬT LED"]

[Chỉ LED trên ESP32C3 sáng lên]

"LED đã sáng! Quan sát các thay đổi:"
```

#### 3.3. Quan sát MQTTX

```
[Chuyển sang MQTTX]

"Trên MQTTX, chúng ta thấy:

1. Message trên topic esp32/led/control:
   {"deviceId":"ESP32C3_001","command":"ON"}

2. Message trả về từ ESP32 trên topic esp32/led/status:
   {"deviceId":"ESP32C3_001","command":"ON"}"

[Point to messages]
```

#### 3.4. Quan sát Serial Monitor

```
[Chuyển sang Serial Monitor]

"Serial Monitor hiển thị:
- Message received: esp32/led/control
- Payload parsed
- LED turned ON
- Status published"
```

#### 3.5. Kiểm tra Database

```
[Mở terminal với psql]

"Kiểm tra database:"

SELECT * FROM device_commands ORDER BY created_at DESC LIMIT 5;

"Lệnh ON vừa gửi đã được lưu với:
- Device ID
- Command: ON
- Source: WEB
- Timestamp"

SELECT * FROM device_status_history ORDER BY timestamp DESC LIMIT 5;

"Lịch sử trạng thái cũng đã cập nhật."
```

#### 3.6. Tắt LED

```
"Bây giờ tắt LED:"

[Click nút "TẮT LED"]

[LED trên ESP32C3 tắt]

"LED đã tắt, và lịch sử được cập nhật ngay lập tức."

[Scroll to history section]
```

### Phần 4: Demo Mobile Application (5 phút)

#### 4.1. Xem danh sách trên Mobile

```
"Chuyển sang Mobile app:"

[Show emulator]

"Giao diện mobile hiển thị tương tự:
- Danh sách thiết bị
- Trạng thái real-time
- UI tối ưu cho mobile"

[Swipe down to refresh]

"Pull-to-refresh để cập nhật danh sách."
```

#### 4.2. Điều khiển từ Mobile

```
[Tap vào device]

"Màn hình chi tiết trên mobile:
- Thông tin đầy đủ
- Các nút điều khiển lớn, dễ nhấn
- Lịch sử 5 lệnh gần nhất"

[Tap "BẬT LED"]

[LED sáng]

"LED đã sáng khi điều khiển từ Mobile!"

[Show lịch sử]

"Lịch sử hiển thị source là MOBILE."
```

#### 4.3. Cross-platform sync

```
"Điểm đặc biệt: dữ liệu đồng bộ giữa Web và Mobile:"

[Điều khiển từ Mobile]
[Chuyển sang Web, refresh]

"Lịch sử trên Web cũng cập nhật với lệnh từ Mobile."

[Và ngược lại]
```

### Phần 5: Demo Đăng ký Thiết bị (3 phút)

#### 5.1. Đăng ký từ Web

```
"Bây giờ đăng ký thiết bị mới:"

[Click "+ Đăng ký thiết bị"]

"Form đăng ký yêu cầu:
- Device ID (unique)
- Tên thiết bị
- Loại thiết bị
- Mô tả
- MQTT topics"

[Điền form:]
Device ID: ESP32C3_TEST
Device Name: ESP32C3 Test Demo
Device Type: ESP32C3
Description: Thiết bị demo
MQTT Topic Control: esp32/test/control
MQTT Topic Status: esp32/test/status

[Click "Đăng ký"]

"Thiết bị mới đã được đăng ký và xuất hiện trong danh sách!"
```

#### 5.2. Kiểm tra Database

```
[Terminal psql]

SELECT * FROM devices WHERE device_id = 'ESP32C3_TEST';

"Thiết bị mới đã được lưu vào database với đầy đủ thông tin."
```

### Phần 6: Test MQTTX Manual (2 phút)

```
"Cuối cùng, test bằng MQTTX Client:"

[MQTTX]

"Publish message thủ công:"

Topic: esp32/led/control
Payload:
{
  "deviceId": "ESP32C3_001",
  "command": "ON"
}

[Publish]

[LED sáng]

"LED phản ứng ngay với message từ MQTTX."

[Check Web/Mobile]

"Cả Web và Mobile đều cập nhật trạng thái."
```

### Phần 7: Tổng kết (2 phút)

```
"Tóm lại, hệ thống đã demo được các chức năng:

✅ Hiển thị danh sách thiết bị từ database
✅ Đăng ký thiết bị mới
✅ Điều khiển LED từ Web app
✅ Điều khiển LED từ Mobile app
✅ Lưu lịch sử vào database
✅ Giao tiếp MQTT real-time
✅ Đồng bộ dữ liệu cross-platform

Công nghệ sử dụng:
- Backend: Spring Boot + Spring Integration MQTT
- Database: PostgreSQL
- MQTT Broker: EMQX
- Web: ReactJS
- Mobile: Flutter
- Hardware: ESP32C3

Cảm ơn thầy/cô và các bạn đã theo dõi!"
```

## Backup Scenarios (Nếu có lỗi)

### Scenario 1: ESP32C3 disconnect

```
"Nếu ESP32C3 bị disconnect, hệ thống vẫn hoạt động:
- Lệnh được lưu vào database
- Web/Mobile hiển thị thiết bị OFFLINE
- Khi ESP32 kết nối lại, nó sẽ nhận lệnh từ queue (nếu có)"
```

### Scenario 2: Backend crash

```
"Nếu Backend crash:
- Frontend hiển thị error message
- MQTT broker vẫn hoạt động
- Database vẫn giữ nguyên dữ liệu
- Restart backend thì hệ thống tiếp tục hoạt động"
```

### Scenario 3: Network issues

```
"Demo offline capabilities:
- Mobile app cache dữ liệu
- Backend có retry mechanism
- MQTT QoS 1 đảm bảo message được gửi"
```

## Tips cho Demo tốt

1. **Chuẩn bị kỹ:**

   - Test toàn bộ flow trước
   - Chuẩn bị multiple devices
   - Có backup ESP32C3

2. **Presentation:**

   - Nói rõ ràng, tự tin
   - Giải thích từng bước
   - Show logs để minh chứng

3. **Handle questions:**

   - Trả lời trực tiếp
   - Nếu không biết, thành thật
   - Có document backup

4. **Time management:**

   - Practice timing
   - Có thể skip phần mobile nếu hết giờ
   - Prioritize core features

5. **Visual aids:**
   - Sử dụng slide cho architecture
   - Zoom in khi show code/logs
   - Highlight important parts

## Q&A Preparation

### Câu hỏi thường gặp:

**Q: Tại sao dùng MQTT thay vì HTTP?**
A: MQTT lightweight, pub/sub pattern, suitable cho IoT devices với bandwidth thấp.

**Q: QoS MQTT là gì?**
A: Quality of Service. QoS 1 đảm bảo message được gửi ít nhất 1 lần.

**Q: Xử lý nhiều thiết bị như thế nào?**
A: Mỗi device có unique ID và topics riêng. Backend scale horizontally.

**Q: Security?**
A: Hiện tại basic auth. Production cần MQTTS (SSL/TLS) và JWT cho API.

**Q: Tại sao không dùng WebSocket?**
A: MQTT chuyên cho IoT, EMQX có sẵn. WebSocket có thể dùng cho web real-time.

**Q: ESP32C3 có thể điều khiển gì khác?**
A: Có thể control: relay, motor, sensor, LCD, etc. Logic tương tự.

---

**Good luck with your demo! 🎉**
