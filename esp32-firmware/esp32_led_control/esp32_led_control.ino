/*
 * IoT LED Control System with DHT11 Sensor
 * ESP32C3 LED Pin: GPIO8 (built-in LED)
 * DHT11 Pin: GPIO2 (GP2)
 *
 * Features:
 * - Connect to WiFi
 * - Connect to MQTT Broker (EMQX)
 * - Subscribe to LED control topic
 * - Publish LED status
 * - Control built-in LED on ESP32C3
 * - Read DHT11 sensor (temperature, humidity)
 * - Publish sensor data
 */

// Uncomment the line below to use fake sensor data for testing
// #define USE_FAKE_SENSOR_DATA

#include <WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <DHT.h>

// ===== WIFI CONFIGURATION =====
const char *ssid = "YOUR_WIFI_SSID";         // 👈 Thay tên WiFi của bạn
const char *password = "YOUR_WIFI_PASSWORD"; // 👈 Thay mật khẩu WiFi

// ===== MQTT CONFIGURATION =====
// IMPORTANT: Replace this IP with the IP of your computer running EMQX
// How to find IP: Open CMD → type "ipconfig" → find IPv4 Address
// Example: 192.168.1.25, 192.168.0.105, 10.0.0.15, etc.
const char *mqtt_server = "192.168.1.XXX"; // 👈 THAY IP MÁY TÍNH CỦA BẠN!
const int mqtt_port = 1883;
const char *mqtt_user = "admin";       // EMQX username
const char *mqtt_password = "public";  // EMQX password
const char *client_id = "ESP32C3_001"; // Device ID (must match DB)

// MQTT Topics
const char *topic_control = "esp32/led/control";
const char *topic_status = "esp32/led/status";
const char *topic_sensor = "esp32/sensor/data";

// ===== LED CONFIGURATION =====
#define LED_PIN 8 // Built-in LED on ESP32C3 (GPIO8)
bool ledState = false;

// ===== DHT11 CONFIGURATION =====
#define DHT_PIN 2 // GPIO2 for DHT11 (GP2)
#define DHT_TYPE DHT11
DHT dht(DHT_PIN, DHT_TYPE);

// Timer cho sensor
unsigned long lastSensorTime = 0;
const unsigned long sensorInterval = 5000; // 5 giây

// WiFi và MQTT Client
WiFiClient espClient;
PubSubClient mqttClient(espClient);

// ===== HÀM KẾT NỐI WIFI =====
void setupWiFi()
{
    delay(10);
    Serial.println();
    Serial.print("Connecting to WiFi: ");
    Serial.println(ssid);

    WiFi.mode(WIFI_STA);
    WiFi.begin(ssid, password);

    while (WiFi.status() != WL_CONNECTED)
    {
        delay(500);
        Serial.print(".");
    }

    Serial.println();
    Serial.println("WiFi connected!");
    Serial.print("IP address: ");
    Serial.println(WiFi.localIP());
}

// ===== HÀM XỬ LÝ MQTT MESSAGE =====
void mqttCallback(char *topic, byte *payload, unsigned int length)
{
    Serial.print("Message received on topic: ");
    Serial.println(topic);

    // Convert payload to string
    String message = "";
    for (int i = 0; i < length; i++)
    {
        message += (char)payload[i];
    }
    Serial.print("Payload: ");
    Serial.println(message);

    // Parse JSON
    StaticJsonDocument<200> doc;
    DeserializationError error = deserializeJson(doc, message);

    if (error)
    {
        Serial.print("JSON parse error: ");
        Serial.println(error.c_str());
        return;
    }

    // Lấy command từ JSON
    const char *deviceId = doc["deviceId"];
    const char *command = doc["command"];

    // Kiểm tra device ID
    if (strcmp(deviceId, client_id) != 0)
    {
        Serial.println("Device ID không khớp, bỏ qua message");
        return;
    }

    // Xử lý lệnh
    if (strcmp(command, "ON") == 0)
    {
        digitalWrite(LED_PIN, LOW); // LED tích hợp ESP32C3 là active LOW
        ledState = true;
        Serial.println("LED turned ON");
        publishStatus("ON");
    }
    else if (strcmp(command, "OFF") == 0)
    {
        digitalWrite(LED_PIN, HIGH); // LED tích hợp ESP32C3 là active LOW
        ledState = false;
        Serial.println("LED turned OFF");
        publishStatus("OFF");
    }
    else
    {
        Serial.println("Unknown command");
    }
}

// ===== HÀM KẾT NỐI MQTT =====
void reconnectMQTT()
{
    while (!mqttClient.connected())
    {
        Serial.print("Connecting to MQTT Broker...");

        if (mqttClient.connect(client_id, mqtt_user, mqtt_password))
        {
            Serial.println("connected!");

            // Subscribe to control topic
            mqttClient.subscribe(topic_control);
            Serial.print("Subscribed to: ");
            Serial.println(topic_control);

            // Publish online status
            publishStatus("ONLINE");
        }
        else
        {
            Serial.print("failed, rc=");
            Serial.print(mqttClient.state());
            Serial.println(" - Retry in 5 seconds");
            delay(5000);
        }
    }
}

// ===== HÀM PUBLISH TRẠNG THÁI =====
void publishStatus(const char *status)
{
    StaticJsonDocument<200> doc;
    doc["deviceId"] = client_id;
    doc["command"] = status;
    doc["timestamp"] = millis();

    char buffer[256];
    serializeJson(doc, buffer);

    if (mqttClient.publish(topic_status, buffer))
    {
        Serial.print("Status published: ");
        Serial.println(buffer);
    }
    else
    {
        Serial.println("Failed to publish status");
    }
}

// ===== HÀM PUBLISH DỮ LIỆU SENSOR =====
void publishSensorData()
{
    float temperature, humidity;

#ifdef USE_FAKE_SENSOR_DATA
    // Sử dụng dữ liệu giả lập để test hệ thống
    temperature = 25.0 + random(-5, 5); // 20-30°C
    humidity = 60.0 + random(-10, 10);  // 50-70%
    Serial.println("Using FAKE sensor data for testing:");
#else
    // Đọc từ DHT11 thật
    temperature = dht.readTemperature();
    humidity = dht.readHumidity();

    if (isnan(temperature) || isnan(humidity))
    {
        Serial.println("Failed to read from DHT sensor!");
        return;
    }
#endif

    Serial.print("Temperature: ");
    Serial.println(temperature);
    Serial.print("Humidity: ");
    Serial.println(humidity);

    StaticJsonDocument<200> doc;
    doc["deviceId"] = client_id;
    doc["temperature"] = temperature;
    doc["humidity"] = humidity;
    doc["timestamp"] = millis();

    char buffer[256];
    serializeJson(doc, buffer);

    if (mqttClient.publish(topic_sensor, buffer))
    {
        Serial.print("Sensor data published: ");
        Serial.println(buffer);
    }
    else
    {
        Serial.println("Failed to publish sensor data");
    }
}

// ===== SETUP =====
void setup()
{
    // Khởi tạo Serial
    Serial.begin(115200);
    delay(1000);
    Serial.println();
    Serial.println("===================================");
    Serial.println("ESP32C3 LED Control System");
    Serial.println("===================================");

    // Khởi tạo LED Pin
    pinMode(LED_PIN, OUTPUT);
    digitalWrite(LED_PIN, HIGH); // LED tắt ban đầu (active LOW)
    ledState = false;

    // Khởi tạo DHT11
    dht.begin();

    // Kết nối WiFi
    setupWiFi();

    // Cấu hình MQTT
    mqttClient.setServer(mqtt_server, mqtt_port);
    mqttClient.setCallback(mqttCallback);

    Serial.println("Setup completed!");
}

// ===== LOOP =====
void loop()
{
    // Kiểm tra kết nối MQTT
    if (!mqttClient.connected())
    {
        reconnectMQTT();
    }
    mqttClient.loop();

    // Heartbeat - gửi status mỗi 30 giây
    static unsigned long lastHeartbeat = 0;
    if (millis() - lastHeartbeat > 30000)
    {
        lastHeartbeat = millis();
        publishStatus(ledState ? "ON" : "OFF");
        Serial.println("Heartbeat sent");
    }

    // Publish sensor data mỗi 5 giây
    if (millis() - lastSensorTime > sensorInterval)
    {
        lastSensorTime = millis();
        publishSensorData();
    }
}
