package com.iot.ledcontrol.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DeviceDto {
    private Long id;
    private String deviceId;
    private String deviceName;
    private String deviceType;
    private String description;
    private String mqttTopicControl;
    private String mqttTopicStatus;
    private String status;
    private LocalDateTime lastSeen;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
