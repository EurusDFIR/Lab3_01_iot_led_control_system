package com.iot.ledcontrol.service;

import com.iot.ledcontrol.model.SensorData;
import com.iot.ledcontrol.repository.SensorDataRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class SensorDataService {

    @Autowired
    private SensorDataRepository sensorDataRepository;

    public SensorData saveSensorData(String deviceId, Float temperature, Float humidity) {
        SensorData sensorData = new SensorData(deviceId, temperature, humidity, LocalDateTime.now());
        return sensorDataRepository.save(sensorData);
    }

    public Optional<SensorData> getLatestSensorData(String deviceId) {
        return sensorDataRepository.findLatestByDeviceId(deviceId);
    }

    public List<SensorData> getSensorDataHistory(String deviceId) {
        return sensorDataRepository.findAllByDeviceIdOrderByTimestampDesc(deviceId);
    }

    public List<SensorData> getSensorDataHistorySince(String deviceId, LocalDateTime since) {
        return sensorDataRepository.findByDeviceIdAndTimestampAfterOrderByTimestampDesc(deviceId, since);
    }
}