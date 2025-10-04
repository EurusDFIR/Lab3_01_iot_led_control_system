package com.iot.ledcontrol.repository;

import com.iot.ledcontrol.model.SensorData;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface SensorDataRepository extends JpaRepository<SensorData, Long> {

    @Query("SELECT s FROM SensorData s WHERE s.deviceId = ?1 ORDER BY s.timestamp DESC LIMIT 1")
    Optional<SensorData> findLatestByDeviceId(String deviceId);

    @Query("SELECT s FROM SensorData s WHERE s.deviceId = ?1 ORDER BY s.timestamp DESC")
    List<SensorData> findAllByDeviceIdOrderByTimestampDesc(String deviceId);

    @Query("SELECT s FROM SensorData s WHERE s.deviceId = ?1 AND s.timestamp >= ?2 ORDER BY s.timestamp DESC")
    List<SensorData> findByDeviceIdAndTimestampAfterOrderByTimestampDesc(String deviceId, LocalDateTime timestamp);
}