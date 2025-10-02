package com.iot.ledcontrol.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "device_commands")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DeviceCommand {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "device_id", nullable = false)
    private String deviceId;

    @Column(name = "command", nullable = false)
    private String command; // ON, OFF

    @Column(name = "source", nullable = false)
    private String source; // WEB, MOBILE

    @Column(name = "status")
    private String status; // SENT, DELIVERED, EXECUTED, FAILED

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "executed_at")
    private LocalDateTime executedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        status = "SENT";
    }
}
