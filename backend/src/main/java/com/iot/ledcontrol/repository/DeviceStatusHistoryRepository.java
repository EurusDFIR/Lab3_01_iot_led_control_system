package com.iot.ledcontrol.repository;

import com.iot.ledcontrol.entity.DeviceStatusHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DeviceStatusHistoryRepository extends JpaRepository<DeviceStatusHistory, Long> {
    List<DeviceStatusHistory> findByDeviceIdOrderByTimestampDesc(String deviceId);

    List<DeviceStatusHistory> findTop10ByDeviceIdOrderByTimestampDesc(String deviceId);
}
