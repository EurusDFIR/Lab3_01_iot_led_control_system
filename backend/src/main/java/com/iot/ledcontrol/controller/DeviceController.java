package com.iot.ledcontrol.controller;

import com.iot.ledcontrol.dto.ControlCommandDto;
import com.iot.ledcontrol.dto.DeviceDto;
import com.iot.ledcontrol.entity.DeviceCommand;
import com.iot.ledcontrol.entity.DeviceStatusHistory;
import com.iot.ledcontrol.service.DeviceService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/devices")
@CrossOrigin(origins = "*")
@Slf4j
public class DeviceController {

    @Autowired
    private DeviceService deviceService;

    /**
     * Get all devices
     */
    @GetMapping
    public ResponseEntity<List<DeviceDto>> getAllDevices() {
        log.info("GET /api/devices - Get all devices");
        List<DeviceDto> devices = deviceService.getAllDevices();
        return ResponseEntity.ok(devices);
    }

    /**
     * Get device by ID
     */
    @GetMapping("/{deviceId}")
    public ResponseEntity<DeviceDto> getDeviceById(@PathVariable String deviceId) {
        log.info("GET /api/devices/{} - Get device by ID", deviceId);
        DeviceDto device = deviceService.getDeviceById(deviceId);
        return ResponseEntity.ok(device);
    }

    /**
     * Register new device
     */
    @PostMapping
    public ResponseEntity<DeviceDto> registerDevice(@RequestBody DeviceDto deviceDto) {
        log.info("POST /api/devices - Register new device: {}", deviceDto.getDeviceId());
        DeviceDto registeredDevice = deviceService.registerDevice(deviceDto);
        return ResponseEntity.ok(registeredDevice);
    }

    /**
     * Control device (ON/OFF)
     */
    @PostMapping("/{deviceId}/control")
    public ResponseEntity<Map<String, String>> controlDevice(
            @PathVariable String deviceId,
            @RequestBody ControlCommandDto controlCommand) {

        log.info("POST /api/devices/{}/control - Command: {}, Source: {}",
                deviceId, controlCommand.getCommand(), controlCommand.getSource());

        deviceService.controlDevice(deviceId, controlCommand.getCommand(), controlCommand.getSource());

        Map<String, String> response = new HashMap<>();
        response.put("message", "Command sent successfully");
        response.put("deviceId", deviceId);
        response.put("command", controlCommand.getCommand());

        return ResponseEntity.ok(response);
    }

    /**
     * Get device command history
     */
    @GetMapping("/{deviceId}/history")
    public ResponseEntity<List<DeviceCommand>> getCommandHistory(@PathVariable String deviceId) {
        log.info("GET /api/devices/{}/history - Get command history", deviceId);
        List<DeviceCommand> history = deviceService.getDeviceCommandHistory(deviceId);
        return ResponseEntity.ok(history);
    }

    /**
     * Get device status history
     */
    @GetMapping("/{deviceId}/status-history")
    public ResponseEntity<List<DeviceStatusHistory>> getStatusHistory(@PathVariable String deviceId) {
        log.info("GET /api/devices/{}/status-history - Get status history", deviceId);
        List<DeviceStatusHistory> history = deviceService.getDeviceStatusHistory(deviceId);
        return ResponseEntity.ok(history);
    }

    /**
     * Health check endpoint
     */
    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> healthCheck() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "UP");
        response.put("service", "IoT LED Control Backend");
        return ResponseEntity.ok(response);
    }
}
