package com.iot.ledcontrol.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.iot.ledcontrol.dto.MqttMessageDto;
import com.iot.ledcontrol.entity.Device;
import com.iot.ledcontrol.entity.DeviceCommand;
import com.iot.ledcontrol.entity.DeviceStatusHistory;
import com.iot.ledcontrol.repository.DeviceCommandRepository;
import com.iot.ledcontrol.repository.DeviceRepository;
import com.iot.ledcontrol.repository.DeviceStatusHistoryRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.integration.annotation.ServiceActivator;
import org.springframework.integration.mqtt.support.MqttHeaders;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.support.MessageBuilder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Optional;

@Service
@Slf4j
public class MqttService {

    @Autowired
    private MessageChannel mqttOutboundChannel;

    @Autowired
    private DeviceRepository deviceRepository;

    @Autowired
    private DeviceCommandRepository commandRepository;

    @Autowired
    private DeviceStatusHistoryRepository statusHistoryRepository;

    @Autowired
    private SensorDataService sensorDataService;

    @Autowired
    private ObjectMapper objectMapper;

    /**
     * Publish message to MQTT topic
     */
    public void publishMessage(String topic, String payload) {
        try {
            log.info("Publishing message to topic {}: {}", topic, payload);

            Message<String> message = MessageBuilder
                    .withPayload(payload)
                    .setHeader(MqttHeaders.TOPIC, topic)
                    .setHeader(MqttHeaders.QOS, 1)
                    .build();

            mqttOutboundChannel.send(message);
            log.info("Message published successfully");
        } catch (Exception e) {
            log.error("Error publishing message to MQTT: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to publish MQTT message", e);
        }
    }

    /**
     * Handle incoming messages from MQTT broker
     */
    @ServiceActivator(inputChannel = "mqttInputChannel")
    public void handleIncomingMessage(Message<?> message) {
        try {
            String topic = message.getHeaders().get(MqttHeaders.RECEIVED_TOPIC, String.class);
            String payload = message.getPayload().toString();

            log.info("Received message from topic {}: {}", topic, payload);

            // Parse JSON payload
            MqttMessageDto mqttMessage = objectMapper.readValue(payload, MqttMessageDto.class);

            // Process based on topic
            if (topic != null && topic.contains("/status")) {
                handleStatusMessage(mqttMessage);
            } else if (topic != null && topic.contains("/sensor/data")) {
                handleSensorMessage(mqttMessage);
            }

        } catch (Exception e) {
            log.error("Error handling incoming MQTT message: {}", e.getMessage(), e);
        }
    }

    /**
     * Handle status messages from devices
     */
    private void handleStatusMessage(MqttMessageDto mqttMessage) {
        try {
            String deviceId = mqttMessage.getDeviceId();
            String status = mqttMessage.getCommand();

            log.info("Processing status update for device {}: {}", deviceId, status);

            // Update device status in database
            Optional<Device> deviceOpt = deviceRepository.findByDeviceId(deviceId);
            if (deviceOpt.isPresent()) {
                Device device = deviceOpt.get();
                device.setStatus(status);
                device.setLastSeen(LocalDateTime.now());
                deviceRepository.save(device);

                // Save status history
                DeviceStatusHistory history = new DeviceStatusHistory();
                history.setDeviceId(deviceId);
                history.setStatus(status);
                statusHistoryRepository.save(history);

                log.info("Device status updated successfully");
            } else {
                log.warn("Device not found: {}", deviceId);
            }

        } catch (Exception e) {
            log.error("Error handling status message: {}", e.getMessage(), e);
        }
    }

    /**
     * Handle sensor data messages from devices
     */
    private void handleSensorMessage(MqttMessageDto mqttMessage) {
        try {
            String deviceId = mqttMessage.getDeviceId();
            Float temperature = mqttMessage.getTemperature();
            Float humidity = mqttMessage.getHumidity();

            log.info("Processing sensor data for device {}: temp={}, hum={}", deviceId, temperature, humidity);

            // Save sensor data to database
            sensorDataService.saveSensorData(deviceId, temperature, humidity);

            log.info("Sensor data saved successfully");

        } catch (Exception e) {
            log.error("Error handling sensor message: {}", e.getMessage(), e);
        }
    }

    /**
     * Send control command to device
     */
    public void sendControlCommand(String deviceId, String command, String source) {
        try {
            Optional<Device> deviceOpt = deviceRepository.findByDeviceId(deviceId);
            if (deviceOpt.isEmpty()) {
                throw new RuntimeException("Device not found: " + deviceId);
            }

            Device device = deviceOpt.get();

            // Create command record
            DeviceCommand deviceCommand = new DeviceCommand();
            deviceCommand.setDeviceId(deviceId);
            deviceCommand.setCommand(command);
            deviceCommand.setSource(source);
            commandRepository.save(deviceCommand);

            // Create MQTT message
            MqttMessageDto mqttMessage = new MqttMessageDto();
            mqttMessage.setDeviceId(deviceId);
            mqttMessage.setCommand(command);
            mqttMessage.setTimestamp(LocalDateTime.now().toString());

            String payload = objectMapper.writeValueAsString(mqttMessage);

            // Publish to MQTT
            publishMessage(device.getMqttTopicControl(), payload);

            log.info("Control command sent to device {}: {}", deviceId, command);

        } catch (Exception e) {
            log.error("Error sending control command: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to send control command", e);
        }
    }
}
