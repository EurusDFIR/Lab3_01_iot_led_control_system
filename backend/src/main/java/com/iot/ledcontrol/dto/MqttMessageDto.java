package com.iot.ledcontrol.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class MqttMessageDto {
    private String deviceId;
    private String command; // ON, OFF, ONLINE, OFFLINE
    private String timestamp;
}
