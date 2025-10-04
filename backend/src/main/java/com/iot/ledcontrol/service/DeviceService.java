package com.iot.ledcontrol.service;

import com.iot.ledcontrol.dto.DeviceDto;
import com.iot.ledcontrol.entity.Device;
import com.iot.ledcontrol.entity.DeviceCommand;
import com.iot.ledcontrol.entity.DeviceStatusHistory;
import com.iot.ledcontrol.repository.DeviceCommandRepository;
import com.iot.ledcontrol.repository.DeviceRepository;
import com.iot.ledcontrol.repository.DeviceStatusHistoryRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Slf4j
public class DeviceService {

    @Autowired
    private DeviceRepository deviceRepository;

    @Autowired
    private DeviceCommandRepository commandRepository;

    @Autowired
    private DeviceStatusHistoryRepository statusHistoryRepository;

    @Autowired
    private MqttService mqttService;

    /**
     * Get all devices
     */
    public List<DeviceDto> getAllDevices() {
        return deviceRepository.findAll().stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
    }

    /**
     * Get device by ID
     */
    public DeviceDto getDeviceById(String deviceId) {
        Device device = deviceRepository.findByDeviceId(deviceId)
                .orElseThrow(() -> new RuntimeException("Device not found: " + deviceId));
        return convertToDto(device);
    }

    /**
     * Register new device
     */
    @Transactional
    public DeviceDto registerDevice(DeviceDto deviceDto) {
        // Check if device already exists
        if (deviceRepository.existsByDeviceId(deviceDto.getDeviceId())) {
            throw new RuntimeException("Device already exists: " + deviceDto.getDeviceId());
        }

        Device device = new Device();
        device.setDeviceId(deviceDto.getDeviceId());
        device.setDeviceName(deviceDto.getDeviceName());
        device.setDeviceType(deviceDto.getDeviceType());
        device.setDescription(deviceDto.getDescription());
        device.setMqttTopicControl(deviceDto.getMqttTopicControl());
        device.setMqttTopicStatus(deviceDto.getMqttTopicStatus());
        device.setStatus("OFFLINE");

        Device savedDevice = deviceRepository.save(device);
        log.info("Device registered successfully: {}", savedDevice.getDeviceId());

        return convertToDto(savedDevice);
    }

    /**
     * Control device (ON/OFF)
     */
    @Transactional
    public void controlDevice(String deviceId, String command, String source) {
        // Validate command
        if (!command.equals("ON") && !command.equals("OFF")) {
            throw new RuntimeException("Invalid command: " + command);
        }

        // Check if device exists
        if (!deviceRepository.existsByDeviceId(deviceId)) {
            throw new RuntimeException("Device not found: " + deviceId);
        }

        // Send MQTT command
        mqttService.sendControlCommand(deviceId, command, source);

        log.info("Device control command sent - Device: {}, Command: {}, Source: {}",
                deviceId, command, source);
    }

    /**
     * Get device command history
     */
    public List<DeviceCommand> getDeviceCommandHistory(String deviceId) {
        return commandRepository.findByDeviceIdOrderByCreatedAtDesc(deviceId);
    }

    /**
     * Get device status history
     */
    public List<DeviceStatusHistory> getDeviceStatusHistory(String deviceId) {
        return statusHistoryRepository.findTop10ByDeviceIdOrderByTimestampDesc(deviceId);
    }

    /**
     * Convert Entity to DTO
     */
    private DeviceDto convertToDto(Device device) {
        DeviceDto dto = new DeviceDto();
        dto.setId(device.getId());
        dto.setDeviceId(device.getDeviceId());
        dto.setDeviceName(device.getDeviceName());
        dto.setDeviceType(device.getDeviceType());
        dto.setDescription(device.getDescription());
        dto.setMqttTopicControl(device.getMqttTopicControl());
        dto.setMqttTopicStatus(device.getMqttTopicStatus());
        dto.setStatus(device.getStatus());
        dto.setLastSeen(device.getLastSeen());
        dto.setCreatedAt(device.getCreatedAt());
        dto.setUpdatedAt(device.getUpdatedAt());
        return dto;
    }
}
