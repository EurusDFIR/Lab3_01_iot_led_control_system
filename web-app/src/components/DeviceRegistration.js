import React, { useState } from 'react';
import './DeviceRegistration.css';

function DeviceRegistration({ onRegister, onCancel }) {
  const [formData, setFormData] = useState({
    deviceId: '',
    deviceName: '',
    deviceType: 'ESP32C3',
    description: '',
    mqttTopicControl: 'esp32/led/control',
    mqttTopicStatus: 'esp32/led/status',
  });

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    
    // Validation
    if (!formData.deviceId || !formData.deviceName) {
      alert('Vui lòng điền đầy đủ thông tin bắt buộc!');
      return;
    }

    onRegister(formData);
  };

  return (
    <div className="device-registration">
      <h2>📝 Đăng ký thiết bị mới</h2>
      
      <form onSubmit={handleSubmit}>
        <div className="form-group">
          <label>Device ID <span className="required">*</span></label>
          <input
            type="text"
            name="deviceId"
            value={formData.deviceId}
            onChange={handleChange}
            placeholder="VD: ESP32C3_001"
            required
          />
          <small>ID duy nhất để xác định thiết bị</small>
        </div>

        <div className="form-group">
          <label>Tên thiết bị <span className="required">*</span></label>
          <input
            type="text"
            name="deviceName"
            value={formData.deviceName}
            onChange={handleChange}
            placeholder="VD: ESP32C3 Lab Room 1"
            required
          />
        </div>

        <div className="form-group">
          <label>Loại thiết bị</label>
          <select
            name="deviceType"
            value={formData.deviceType}
            onChange={handleChange}
          >
            <option value="ESP32C3">ESP32C3</option>
            <option value="ESP32">ESP32</option>
            <option value="ESP8266">ESP8266</option>
            <option value="Arduino">Arduino</option>
          </select>
        </div>

        <div className="form-group">
          <label>Mô tả</label>
          <textarea
            name="description"
            value={formData.description}
            onChange={handleChange}
            placeholder="Mô tả về thiết bị..."
            rows="3"
          />
        </div>

        <div className="form-group">
          <label>MQTT Topic Control</label>
          <input
            type="text"
            name="mqttTopicControl"
            value={formData.mqttTopicControl}
            onChange={handleChange}
            placeholder="esp32/led/control"
          />
          <small>Topic để gửi lệnh điều khiển</small>
        </div>

        <div className="form-group">
          <label>MQTT Topic Status</label>
          <input
            type="text"
            name="mqttTopicStatus"
            value={formData.mqttTopicStatus}
            onChange={handleChange}
            placeholder="esp32/led/status"
          />
          <small>Topic để nhận trạng thái từ thiết bị</small>
        </div>

        <div className="form-actions">
          <button type="button" className="btn-cancel" onClick={onCancel}>
            Hủy
          </button>
          <button type="submit" className="btn-submit">
            Đăng ký
          </button>
        </div>
      </form>
    </div>
  );
}

export default DeviceRegistration;
