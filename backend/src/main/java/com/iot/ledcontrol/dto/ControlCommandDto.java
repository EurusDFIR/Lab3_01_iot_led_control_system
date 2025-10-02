package com.iot.ledcontrol.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ControlCommandDto {
    private String command; // ON or OFF
    private String source; // WEB or MOBILE
}
