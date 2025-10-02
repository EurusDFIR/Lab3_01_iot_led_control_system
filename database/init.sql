-- Database: iot_led_control
-- Tạo database mới tránh ghi đè project khác

-- Kết nối vào container PostgreSQL và chạy:
-- CREATE DATABASE iot_led_control;

-- Sau đó kết nối vào database iot_led_control và chạy script này

-- Table: devices
CREATE TABLE IF NOT EXISTS devices (
    id SERIAL PRIMARY KEY,
    device_id VARCHAR(100) UNIQUE NOT NULL,
    device_name VARCHAR(255) NOT NULL,
    device_type VARCHAR(50) NOT NULL DEFAULT 'ESP32',
    description TEXT,
    mqtt_topic_control VARCHAR(255) NOT NULL,
    mqtt_topic_status VARCHAR(255) NOT NULL,
    status VARCHAR(20) DEFAULT 'OFFLINE',
    last_seen TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: device_commands
CREATE TABLE IF NOT EXISTS device_commands (
    id SERIAL PRIMARY KEY,
    device_id VARCHAR(100) NOT NULL,
    command VARCHAR(50) NOT NULL,
    source VARCHAR(50) NOT NULL, -- 'WEB' hoặc 'MOBILE'
    status VARCHAR(20) DEFAULT 'SENT', -- 'SENT', 'DELIVERED', 'EXECUTED', 'FAILED'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    executed_at TIMESTAMP,
    FOREIGN KEY (device_id) REFERENCES devices(device_id) ON DELETE CASCADE
);

-- Table: device_status_history
CREATE TABLE IF NOT EXISTS device_status_history (
    id SERIAL PRIMARY KEY,
    device_id VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL, -- 'ON', 'OFF', 'ONLINE', 'OFFLINE'
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (device_id) REFERENCES devices(device_id) ON DELETE CASCADE
);

-- Index for better query performance
CREATE INDEX idx_device_commands_device_id ON device_commands(device_id);
CREATE INDEX idx_device_commands_created_at ON device_commands(created_at);
CREATE INDEX idx_device_status_history_device_id ON device_status_history(device_id);
CREATE INDEX idx_device_status_history_timestamp ON device_status_history(timestamp);

-- Insert sample device (ESP32C3 với LED tích hợp)
INSERT INTO devices (device_id, device_name, device_type, description, mqtt_topic_control, mqtt_topic_status, status)
VALUES 
    ('ESP32C3_001', 'ESP32C3 Lab Room 1', 'ESP32C3', 'ESP32C3 với LED tích hợp - Phòng thí nghiệm 1', 'esp32/led/control', 'esp32/led/status', 'OFFLINE'),
    ('ESP32C3_002', 'ESP32C3 Lab Room 2', 'ESP32C3', 'ESP32C3 với LED tích hợp - Phòng thí nghiệm 2', 'esp32/led2/control', 'esp32/led2/status', 'OFFLINE');

-- View: Recent device commands with device info
CREATE OR REPLACE VIEW v_recent_commands AS
SELECT 
    dc.id,
    dc.device_id,
    d.device_name,
    dc.command,
    dc.source,
    dc.status,
    dc.created_at,
    dc.executed_at
FROM device_commands dc
JOIN devices d ON dc.device_id = d.device_id
ORDER BY dc.created_at DESC;

-- Function: Update device last_seen
CREATE OR REPLACE FUNCTION update_device_last_seen()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE devices 
    SET last_seen = CURRENT_TIMESTAMP,
        updated_at = CURRENT_TIMESTAMP
    WHERE device_id = NEW.device_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Auto update last_seen when device sends status
CREATE TRIGGER trigger_update_last_seen
AFTER INSERT ON device_status_history
FOR EACH ROW
EXECUTE FUNCTION update_device_last_seen();

-- Grant permissions (nếu cần)
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO your_user;
-- GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO your_user;
