package com.iot.ledcontrol.controller;

import com.iot.ledcontrol.model.SensorData;
import com.iot.ledcontrol.service.SensorDataService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/sensor-data")
@CrossOrigin(origins = "*")
public class SensorDataController {

    @Autowired
    private SensorDataService sensorDataService;

    @GetMapping("/latest/{deviceId}")
    public ResponseEntity<SensorData> getLatestSensorData(@PathVariable String deviceId) {
        Optional<SensorData> sensorData = sensorDataService.getLatestSensorData(deviceId);
        if (sensorData.isPresent()) {
            return ResponseEntity.ok(sensorData.get());
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/history/{deviceId}")
    public ResponseEntity<List<SensorData>> getSensorDataHistory(@PathVariable String deviceId) {
        List<SensorData> sensorData = sensorDataService.getSensorDataHistory(deviceId);
        return ResponseEntity.ok(sensorData);
    }

    @GetMapping("/history/{deviceId}/since")
    public ResponseEntity<List<SensorData>> getSensorDataHistorySince(
            @PathVariable String deviceId,
            @RequestParam String since) {
        try {
            LocalDateTime timestamp = LocalDateTime.parse(since, DateTimeFormatter.ISO_LOCAL_DATE_TIME);
            List<SensorData> sensorData = sensorDataService.getSensorDataHistorySince(deviceId, timestamp);
            return ResponseEntity.ok(sensorData);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
}