package com.iot.ledcontrol.repository;

import com.iot.ledcontrol.entity.DeviceCommand;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DeviceCommandRepository extends JpaRepository<DeviceCommand, Long> {
    List<DeviceCommand> findByDeviceIdOrderByCreatedAtDesc(String deviceId);

    List<DeviceCommand> findTop10ByOrderByCreatedAtDesc();
}
