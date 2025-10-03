/*
 * IoT LED Control System - ESP32C3 Firmware
 *
 * Chức năng:
 * - Kết nối WiFi
 * - Kết nối MQTT Broker (EMQX)
 * - Subscribe topic điều khiển LED
 * - Publish trạng thái LED
 * - Điều khiển LED tích hợp trên ESP32C3
 *
 * ESP32C3 LED Pin: GPIO8 (LED tích hợp)
 */

#include <WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>

// ===== CẤU HÌNH WIFI =====
const char *ssid = "LE HUNG";       // ✅ Tên WiFi của bạn
const char *password = "123456789"; // ✅ Mật khẩu WiFi

// ===== CẤU HÌNH MQTT =====
// ⚠️ QUAN TRỌNG: Thay IP này bằng IP máy tính chạy EMQX
// Cách tìm IP: Mở CMD → gõ "ipconfig" → tìm IPv4 Address
// VD: 192.168.1.25, 192.168.0.105, 10.0.0.15, etc.
const char *mqtt_server = "192.168.1.10"; // 👈 ĐỔI IP NÀY!
const int mqtt_port = 1883;
const char *mqtt_user = "admin";       // Username EMQX
const char *mqtt_password = "public";  // Password EMQX
const char *client_id = "ESP32C3_001"; // Device ID (phải khớp với DB)

// MQTT Topics
const char *topic_control = "esp32/led/control";
const char *topic_status = "esp32/led/status";

// ===== CẤU HÌNH LED =====
#define LED_PIN 8 // LED tích hợp trên ESP32C3 (GPIO8)
bool ledState = false;

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
}
