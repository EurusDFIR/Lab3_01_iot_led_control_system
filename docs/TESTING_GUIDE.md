# Testing Guide - IoT LED Control System

## Test Scenarios

### 1. Test Backend API

#### 1.1. Health Check

```bash
curl http://localhost:8080/api/devices/health
```

Expected:

```json
{
  "status": "UP",
  "service": "IoT LED Control Backend"
}
```

#### 1.2. Get All Devices

```bash
curl http://localhost:8080/api/devices
```

Expected: JSON array với 2 thiết bị mẫu

#### 1.3. Register New Device

```bash
curl -X POST http://localhost:8080/api/devices \
  -H "Content-Type: application/json" \
  -d '{
    "deviceId": "ESP32C3_003",
    "deviceName": "ESP32C3 Test Device",
    "deviceType": "ESP32C3",
    "description": "Test device",
    "mqttTopicControl": "esp32/led3/control",
    "mqttTopicStatus": "esp32/led3/status"
  }'
```

#### 1.4. Control Device

```bash
curl -X POST http://localhost:8080/api/devices/ESP32C3_001/control \
  -H "Content-Type: application/json" \
  -d '{
    "command": "ON",
    "source": "WEB"
  }'
```

### 2. Test MQTT with MQTTX

#### 2.1. Subscribe to All Topics

```
Connection:
  - Host: localhost
  - Port: 1883
  - Username: admin
  - Password: public

Subscribe: esp32/#
```

#### 2.2. Publish Control Command

```
Topic: esp32/led/control
QoS: 1
Payload:
{
  "deviceId": "ESP32C3_001",
  "command": "ON",
  "timestamp": "2025-10-03T10:30:00Z"
}
```

Expected: LED on ESP32C3 turns ON

#### 2.3. Observe Status Messages

```
Topic: esp32/led/status
Expected Payload:
{
  "deviceId": "ESP32C3_001",
  "command": "ON",
  "timestamp": 123456789
}
```

### 3. Test Database

```sql
-- Connect to database
docker exec -it postgres_container psql -U postgres -d iot_led_control

-- Check devices
SELECT * FROM devices;

-- Check recent commands
SELECT * FROM device_commands ORDER BY created_at DESC LIMIT 10;

-- Check status history
SELECT * FROM device_status_history ORDER BY timestamp DESC LIMIT 10;

-- Verify trigger working (last_seen should update)
SELECT device_id, device_name, last_seen, status FROM devices;
```

### 4. Test Web Application

#### Manual Testing Checklist:

- [ ] Web loads at http://localhost:3000
- [ ] Device list displays correctly
- [ ] Click device → detail screen opens
- [ ] Click "BẬT LED" → LED turns on
- [ ] Click "TẮT LED" → LED turns off
- [ ] History updates after control
- [ ] Click "Đăng ký thiết bị" → form opens
- [ ] Fill form → submit → device registered
- [ ] Auto refresh works (every 5 seconds)
- [ ] Error handling displays properly

### 5. Test Mobile Application

#### Manual Testing Checklist:

- [ ] App launches successfully
- [ ] Device list loads
- [ ] Pull to refresh works
- [ ] Tap device → detail screen opens
- [ ] Tap "BẬT LED" → LED turns on
- [ ] Tap "TẮT LED" → LED turns off
- [ ] History displays correctly
- [ ] Register device flow works
- [ ] Loading states show properly
- [ ] Error messages display

### 6. Test ESP32C3 Firmware

#### Serial Monitor Output Check:

```
Expected logs:
===================================
ESP32C3 LED Control System
===================================

Connecting to WiFi: YourWiFi
.....
WiFi connected!
IP address: 192.168.1.xxx

Connecting to MQTT Broker...connected!
Subscribed to: esp32/led/control
Status published: {"deviceId":"ESP32C3_001","command":"ONLINE",...}

Message received on topic: esp32/led/control
Payload: {"deviceId":"ESP32C3_001","command":"ON",...}
LED turned ON
Status published: {"deviceId":"ESP32C3_001","command":"ON",...}
```

### 7. Integration Tests

#### Test Case 1: End-to-End LED Control from Web

1. Open Web (http://localhost:3000)
2. Click ESP32C3_001
3. Click "BẬT LED"
4. **Verify:**
   - LED on ESP32C3 lights up
   - Web shows loading then success
   - History updates
   - MQTTX shows message on `esp32/led/control`
   - ESP32C3 Serial Monitor shows message received
   - MQTTX shows status on `esp32/led/status`
   - Database `device_commands` has new entry

#### Test Case 2: End-to-End LED Control from Mobile

1. Open Mobile App
2. Tap ESP32C3_001
3. Tap "BẬT LED"
4. **Verify:** (same as Test Case 1)

#### Test Case 3: Device Registration

1. Click "+ Đăng ký thiết bị"
2. Fill form with unique Device ID
3. Submit
4. **Verify:**
   - Success message shows
   - Device appears in list
   - Database has new entry
   - Device can be controlled

#### Test Case 4: Multiple Concurrent Controls

1. Open Web and Mobile simultaneously
2. Control from Web → Verify Mobile updates
3. Control from Mobile → Verify Web updates
4. Check history shows both sources

### 8. Performance Tests

#### 8.1. Load Test - Multiple Rapid Commands

```bash
# Send 10 commands rapidly
for i in {1..10}; do
  curl -X POST http://localhost:8080/api/devices/ESP32C3_001/control \
    -H "Content-Type: application/json" \
    -d '{"command":"ON","source":"TEST"}'
  sleep 0.5
done
```

**Verify:**

- All commands saved to database
- ESP32C3 processes all messages
- No crashes or errors

#### 8.2. Concurrent User Test

- Open 5 browser tabs
- Control LED from different tabs
- **Verify:** All commands processed correctly

### 9. Error Handling Tests

#### Test Case 1: Backend Down

1. Stop Backend
2. Try to control from Web/Mobile
3. **Verify:** Error message displays

#### Test Case 2: MQTT Broker Down

1. Stop EMQX container
2. Try to control LED
3. **Verify:** Backend logs error, command not sent

#### Test Case 3: ESP32C3 Disconnected

1. Unplug ESP32C3
2. Send control command
3. **Verify:** Command saved but not executed

#### Test Case 4: Invalid Device ID

```bash
curl -X POST http://localhost:8080/api/devices/INVALID_ID/control \
  -H "Content-Type: application/json" \
  -d '{"command":"ON","source":"TEST"}'
```

**Verify:** 404 or error response

### 10. Data Validation Tests

#### Test Case 1: Invalid Command

```bash
curl -X POST http://localhost:8080/api/devices/ESP32C3_001/control \
  -H "Content-Type: application/json" \
  -d '{"command":"INVALID","source":"TEST"}'
```

**Verify:** Error response

#### Test Case 2: Missing Required Fields

```bash
curl -X POST http://localhost:8080/api/devices \
  -H "Content-Type: application/json" \
  -d '{"deviceName":"Test"}'
```

**Verify:** Validation error

## Automated Test Scripts

### Backend Unit Tests

```bash
cd backend
mvn test
```

### Web App Tests

```bash
cd web-app
npm test
```

### Flutter Tests

```bash
cd mobile-app
flutter test
```

## Test Report Template

```
Test Date: ___________
Tester: ___________

Components Status:
[ ] PostgreSQL: Running
[ ] EMQX: Running
[ ] Backend: Running
[ ] Web App: Running
[ ] Mobile App: Running
[ ] ESP32C3: Connected

Test Results:
1. Backend API Tests: ___/___
2. MQTT Tests: ___/___
3. Database Tests: ___/___
4. Web App Tests: ___/___
5. Mobile App Tests: ___/___
6. ESP32C3 Tests: ___/___
7. Integration Tests: ___/___
8. Performance Tests: ___/___
9. Error Handling: ___/___
10. Data Validation: ___/___

Issues Found:
1. ___________
2. ___________
3. ___________

Notes:
___________
```

## Continuous Testing

### During Development:

1. Test each component after changes
2. Test integration points
3. Check logs regularly
4. Monitor MQTT messages with MQTTX
5. Verify database updates

### Before Demo:

1. Run full test suite
2. Clean database and start fresh
3. Test complete end-to-end flow
4. Prepare multiple scenarios
5. Have backup plans

## Debug Tools

- **Backend:** Spring Boot Actuator logs
- **Web:** Browser DevTools (F12)
- **Mobile:** Flutter DevTools, Android Logcat
- **MQTT:** MQTTX Client
- **Database:** pgAdmin or psql CLI
- **ESP32:** Serial Monitor

## Common Issues & Solutions

| Issue                    | Solution                          |
| ------------------------ | --------------------------------- |
| Backend won't start      | Check PostgreSQL and EMQX running |
| Web can't connect        | Check CORS, API URL               |
| Mobile can't connect     | Use IP not localhost              |
| ESP32 won't connect WiFi | Check credentials                 |
| LED doesn't respond      | Check MQTT topics match           |
| Database errors          | Check connection string           |

---

**Happy Testing! 🧪**
