# System Architecture - IoT LED Control System

## Overview

Hệ thống điều khiển LED trên ESP32C3 qua giao thức MQTT với giao diện Web và Mobile.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         CLIENT LAYER                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────┐                    ┌──────────────────┐  │
│  │   Web Browser    │                    │  Mobile Device   │  │
│  │   (ReactJS)      │                    │   (Flutter)      │  │
│  │  Port: 3000      │                    │   Android/iOS    │  │
│  └────────┬─────────┘                    └────────┬─────────┘  │
│           │                                        │             │
│           │         HTTP/REST API                  │             │
│           └────────────────┬───────────────────────┘             │
│                            │                                     │
└────────────────────────────┼─────────────────────────────────────┘
                             │
┌────────────────────────────┼─────────────────────────────────────┐
│                    APPLICATION LAYER                              │
├────────────────────────────┼─────────────────────────────────────┤
│                            ▼                                      │
│              ┌──────────────────────────┐                        │
│              │   Spring Boot Backend    │                        │
│              │   (Java + Spring Boot)   │                        │
│              │     Port: 8080           │                        │
│              │  ┌────────────────────┐  │                        │
│              │  │  REST Controllers  │  │                        │
│              │  └─────────┬──────────┘  │                        │
│              │  ┌─────────▼──────────┐  │                        │
│              │  │  Device Service    │  │                        │
│              │  └─────────┬──────────┘  │                        │
│              │  ┌─────────▼──────────┐  │                        │
│              │  │  MQTT Service      │  │                        │
│              │  │ (Spring Integration)│ │                        │
│              │  └─────────┬──────────┘  │                        │
│              │  ┌─────────▼──────────┐  │                        │
│              │  │   JPA Repository   │  │                        │
│              │  └─────────┬──────────┘  │                        │
│              └────────────┼──────────────┘                        │
│                           │                                       │
└───────────────────────────┼───────────────────────────────────────┘
                            │
           ┌────────────────┼────────────────┐
           │                │                │
           ▼                ▼                ▼
┌─────────────────┐  ┌──────────────┐  ┌──────────────┐
│   PostgreSQL    │  │ EMQX Broker  │  │   ESP32C3    │
│   Database      │  │    (MQTT)    │  │  (Hardware)  │
│                 │  │              │  │              │
│  Port: 5432     │  │  Port: 1883  │  │  GPIO8 LED   │
│                 │  │              │  │              │
│  ┌───────────┐ │  │ ┌──────────┐ │  │ ┌──────────┐ │
│  │  devices  │ │  │ │  Topics:  │ │  │ │ Arduino  │ │
│  ├───────────┤ │  │ │ control   │ │  │ │   Code   │ │
│  │  commands │ │  │ │  status   │ │  │ │          │ │
│  ├───────────┤ │  │ └──────────┘ │  │ │ WiFi     │ │
│  │  history  │ │  │              │  │ │ MQTT Lib │ │
│  └───────────┘ │  │              │  │ └──────────┘ │
└─────────────────┘  └──────────────┘  └──────────────┘
       DATA               MESSAGE           DEVICE
       LAYER              BROKER            LAYER
```

## Component Details

### 1. Client Layer

#### Web Application (ReactJS)

- **Technology:** React 18, Axios, CSS3
- **Port:** 3000
- **Features:**
  - Device list view
  - Device registration form
  - LED control interface
  - Command history display
  - Real-time updates (polling every 5s)
- **Communication:** REST API over HTTP

#### Mobile Application (Flutter)

- **Technology:** Flutter 3.0+, Provider, HTTP package
- **Platform:** Android/iOS
- **Features:**
  - Native mobile UI
  - Pull-to-refresh
  - Device management
  - LED control
  - Command history
- **Communication:** REST API over HTTP

### 2. Application Layer

#### Spring Boot Backend

- **Technology:** Java 17, Spring Boot 3.1, Spring Integration MQTT
- **Port:** 8080
- **Components:**

##### REST Controllers

- `DeviceController`: Handle HTTP requests
- Endpoints:
  - `GET /api/devices` - List devices
  - `POST /api/devices` - Register device
  - `POST /api/devices/{id}/control` - Control device
  - `GET /api/devices/{id}/history` - Get history

##### Services

- `DeviceService`: Business logic for device management
- `MqttService`: Handle MQTT publish/subscribe

##### MQTT Integration

- **Inbound Adapter:** Subscribe to status topics
- **Outbound Adapter:** Publish control commands
- **Message Converter:** JSON serialization
- **QoS:** 1 (At least once delivery)

##### JPA Repositories

- `DeviceRepository`: Device CRUD operations
- `DeviceCommandRepository`: Command history
- `DeviceStatusHistoryRepository`: Status tracking

### 3. Data Layer

#### PostgreSQL Database

- **Port:** 5432
- **Database:** iot_led_control
- **Tables:**

##### devices

```sql
- id (PK)
- device_id (UNIQUE)
- device_name
- device_type
- description
- mqtt_topic_control
- mqtt_topic_status
- status
- last_seen
- created_at
- updated_at
```

##### device_commands

```sql
- id (PK)
- device_id (FK)
- command (ON/OFF)
- source (WEB/MOBILE)
- status (SENT/DELIVERED/EXECUTED)
- created_at
- executed_at
```

##### device_status_history

```sql
- id (PK)
- device_id (FK)
- status
- timestamp
```

### 4. Message Broker

#### EMQX Broker

- **Port:** 1883 (MQTT), 18083 (Dashboard)
- **Protocol:** MQTT v3.1.1
- **Topics:**
  - `esp32/led/control` - Control commands
  - `esp32/led/status` - Status updates
- **QoS:** 1
- **Authentication:** Username/Password

### 5. Device Layer

#### ESP32C3 Microcontroller

- **Hardware:** ESP32C3 Dev Board
- **LED:** Built-in at GPIO8
- **Firmware:** Arduino C++
- **Libraries:**
  - WiFi.h - WiFi connectivity
  - PubSubClient.h - MQTT client
  - ArduinoJson.h - JSON parsing
- **Features:**
  - WiFi connection
  - MQTT subscribe/publish
  - LED control
  - Status reporting
  - Heartbeat (every 30s)

## Data Flow

### Control Flow (Web/Mobile → ESP32C3)

```
1. User clicks "BẬT LED" on Web/Mobile
   ↓
2. Frontend sends POST request to Backend
   POST /api/devices/ESP32C3_001/control
   Body: {"command": "ON", "source": "WEB"}
   ↓
3. Backend receives request
   ↓
4. DeviceService saves command to database
   INSERT INTO device_commands...
   ↓
5. MqttService publishes message to MQTT broker
   Topic: esp32/led/control
   Payload: {"deviceId":"ESP32C3_001","command":"ON"}
   ↓
6. EMQX Broker distributes message to subscribers
   ↓
7. ESP32C3 receives message (subscribed to topic)
   ↓
8. ESP32C3 parses JSON, checks deviceId
   ↓
9. ESP32C3 controls LED (digitalWrite HIGH)
   ↓
10. ESP32C3 publishes status to MQTT
    Topic: esp32/led/status
    Payload: {"deviceId":"ESP32C3_001","command":"ON"}
    ↓
11. Backend receives status message
    ↓
12. Backend updates database
    UPDATE devices SET status='ON', last_seen=NOW()
    INSERT INTO device_status_history...
    ↓
13. Frontend polls API and displays updated status
```

### Status Flow (ESP32C3 → Backend)

```
1. ESP32C3 publishes status
   Topic: esp32/led/status
   ↓
2. EMQX Broker receives message
   ↓
3. Backend MQTT Inbound Adapter receives
   ↓
4. MqttService.handleIncomingMessage()
   ↓
5. Parse JSON payload
   ↓
6. Update device status in database
   ↓
7. Save to status history table
```

## Communication Protocols

### HTTP/REST API

- **Protocol:** HTTP/1.1
- **Format:** JSON
- **Methods:** GET, POST, PUT, DELETE
- **Authentication:** None (can add JWT later)
- **CORS:** Enabled for localhost:3000

### MQTT

- **Version:** 3.1.1
- **QoS Levels:**
  - 0: At most once (not used)
  - 1: At least once (default)
  - 2: Exactly once (not used)
- **Retained Messages:** No
- **Clean Session:** Yes
- **Keep Alive:** 60 seconds

## Security Considerations

### Current Implementation

- Basic MQTT authentication (username/password)
- CORS enabled for specific origins
- Database credentials in config file

### Production Recommendations

- [ ] Add JWT authentication for REST API
- [ ] Use SSL/TLS for MQTT (MQTTS on port 8883)
- [ ] Use HTTPS for web application
- [ ] Store credentials in environment variables
- [ ] Implement rate limiting
- [ ] Add input validation and sanitization
- [ ] Enable MQTT ACL (Access Control Lists)
- [ ] Use database connection pooling

## Scalability

### Current Capacity

- Single backend instance
- Single MQTT broker
- Single database
- ~100 concurrent devices

### Scaling Options

#### Horizontal Scaling

- Load balancer for multiple backend instances
- EMQX cluster for high availability
- PostgreSQL replication (master-slave)

#### Vertical Scaling

- Increase backend server resources
- Optimize database queries
- Add caching layer (Redis)

#### Microservices Architecture

- Separate MQTT service
- Separate device management service
- Separate history service
- Message queue (RabbitMQ/Kafka)

## Technology Stack Summary

| Layer           | Technology  | Purpose          |
| --------------- | ----------- | ---------------- |
| Frontend Web    | ReactJS     | User interface   |
| Frontend Mobile | Flutter     | Mobile app       |
| Backend         | Spring Boot | REST API + MQTT  |
| Message Broker  | EMQX        | MQTT messaging   |
| Database        | PostgreSQL  | Data persistence |
| Firmware        | Arduino C++ | ESP32C3 control  |
| Protocol        | MQTT, HTTP  | Communication    |
| Format          | JSON        | Data exchange    |

## Design Patterns Used

1. **MVC (Model-View-Controller)**

   - Model: Entity classes
   - View: React/Flutter components
   - Controller: Spring Controllers

2. **Repository Pattern**

   - JPA Repositories for data access

3. **Service Layer Pattern**

   - Business logic separation

4. **Publish-Subscribe Pattern**

   - MQTT messaging

5. **DTO (Data Transfer Object)**
   - API request/response objects

## Future Enhancements

- [ ] WebSocket for real-time updates (replace polling)
- [ ] User authentication and authorization
- [ ] Device grouping and batch control
- [ ] Scheduling (turn on/off at specific times)
- [ ] Analytics and reporting
- [ ] Push notifications
- [ ] Voice control integration
- [ ] Energy consumption tracking
- [ ] Multi-tenancy support
- [ ] API rate limiting
- [ ] Logging and monitoring dashboard
- [ ] Docker containerization
- [ ] CI/CD pipeline

## References

- Spring Integration MQTT: https://docs.spring.io/spring-integration/docs/current/reference/html/mqtt.html
- EMQX Documentation: https://www.emqx.io/docs/en/latest/
- ESP32 Arduino Core: https://docs.espressif.com/projects/arduino-esp32/en/latest/
- MQTT Protocol: https://mqtt.org/
