import React, { useState, useEffect, useCallback } from 'react';
import './DeviceControl.css';
import SensorHistory from './SensorHistory';
import { deviceService, sensorDataService } from '../services/api';

function DeviceControl({ device, onControl, onRefresh }) {
  const [history, setHistory] = useState([]);
  const [loading, setLoading] = useState(false);
  const [sensorData, setSensorData] = useState(null);
  const [activeTab, setActiveTab] = useState('control'); // 'control' or 'history'
  const [thresholds, setThresholds] = useState({
    temperature: { min: 20, max: 30 },
    humidity: { min: 40, max: 70 }
  });
  const [notifications, setNotifications] = useState([]);
  const [showThresholdConfig, setShowThresholdConfig] = useState(false);

  const loadHistory = useCallback(async () => {
    try {
      const data = await deviceService.getCommandHistory(device.deviceId);
      setHistory(data.slice(0, 5)); // Show last 5 commands
    } catch (err) {
      console.error('Error loading history:', err);
    }
  }, [device.deviceId]);

  const checkThresholds = useCallback((data) => {
    if (!data) return;

    const newNotifications = [];
    const now = new Date();

    // Check temperature thresholds
    if (data.temperature < thresholds.temperature.min) {
      newNotifications.push({
        id: Date.now() + 'temp_low',
        type: 'warning',
        title: 'Nhiệt độ thấp!',
        message: `Nhiệt độ ${data.temperature.toFixed(1)}°C thấp hơn ngưỡng ${thresholds.temperature.min}°C`,
        timestamp: now,
        sensor: 'temperature'
      });
    } else if (data.temperature > thresholds.temperature.max) {
      newNotifications.push({
        id: Date.now() + 'temp_high',
        type: 'danger',
        title: 'Nhiệt độ cao!',
        message: `Nhiệt độ ${data.temperature.toFixed(1)}°C cao hơn ngưỡng ${thresholds.temperature.max}°C`,
        timestamp: now,
        sensor: 'temperature'
      });
    }

    // Check humidity thresholds
    if (data.humidity < thresholds.humidity.min) {
      newNotifications.push({
        id: Date.now() + 'hum_low',
        type: 'warning',
        title: 'Độ ẩm thấp!',
        message: `Độ ẩm ${data.humidity.toFixed(1)}% thấp hơn ngưỡng ${thresholds.humidity.min}%`,
        timestamp: now,
        sensor: 'humidity'
      });
    } else if (data.humidity > thresholds.humidity.max) {
      newNotifications.push({
        id: Date.now() + 'hum_high',
        type: 'danger',
        title: 'Độ ẩm cao!',
        message: `Độ ẩm ${data.humidity.toFixed(1)}% cao hơn ngưỡng ${thresholds.humidity.max}%`,
        timestamp: now,
        sensor: 'humidity'
      });
    }

    // Add new notifications and keep only recent ones (last 10)
    if (newNotifications.length > 0) {
      setNotifications(prev => {
        const updated = [...newNotifications, ...prev].slice(0, 10);
        return updated;
      });

      // Browser notification (if permission granted)
      if (Notification.permission === 'granted') {
        newNotifications.forEach(notification => {
          new Notification(notification.title, {
            body: notification.message,
            icon: '/favicon.ico'
          });
        });
      }
    }
  }, [thresholds, setNotifications]);

  const loadSensorData = useCallback(async () => {
    try {
      const data = await sensorDataService.getLatestSensorData(device.deviceId);
      setSensorData(data);
      checkThresholds(data);
    } catch (err) {
      console.error('Error loading sensor data:', err);
      setSensorData(null);
    }
  }, [device.deviceId, checkThresholds]);

  const requestNotificationPermission = () => {
    if ('Notification' in window && Notification.permission === 'default') {
      Notification.requestPermission();
    }
  };

  useEffect(() => {
    loadHistory();
    loadSensorData();
    requestNotificationPermission();

    // Auto-refresh sensor data every 5 seconds (faster updates)
    const sensorInterval = setInterval(() => {
      loadSensorData();
    }, 5000);

    // Cleanup interval on unmount
    return () => clearInterval(sensorInterval);
  }, [device.deviceId, loadHistory, loadSensorData]);

  const updateThreshold = (sensor, type, value) => {
    setThresholds(prev => ({
      ...prev,
      [sensor]: {
        ...prev[sensor],
        [type]: parseFloat(value) || 0
      }
    }));
  };

  const clearNotifications = () => {
    setNotifications([]);
  };

  const removeNotification = (id) => {
    setNotifications(prev => prev.filter(n => n.id !== id));
  };

  const handleControl = async (command) => {
    setLoading(true);
    try {
      await onControl(device.deviceId, command);
      await loadHistory();
      await onRefresh();
    } finally {
      setLoading(false);
    }
  };

  const formatDate = (dateString) => {
    const date = new Date(dateString);
    return date.toLocaleString('vi-VN');
  };

  const getTemperatureStatus = (temp) => {
    if (temp < 20) return 'low';
    if (temp < 25) return 'normal';
    if (temp < 30) return 'warning';
    return 'high';
  };

  const getTemperatureStatusText = (temp) => {
    if (temp < 20) return 'Lạnh';
    if (temp < 25) return 'Thoải mái';
    if (temp < 30) return 'Ấm';
    return 'Nóng';
  };

  const getHumidityStatus = (humidity) => {
    if (humidity < 30) return 'low';
    if (humidity < 50) return 'normal';
    if (humidity < 70) return 'warning';
    return 'high';
  };

  const getHumidityStatusText = (humidity) => {
    if (humidity < 30) return 'Khô';
    if (humidity < 50) return 'Bình thường';
    if (humidity < 70) return 'Thoải mái';
    return 'Ẩm';
  };

  return (
    <div className="device-control">
      <div className="control-header">
        <h2>{device.deviceName}</h2>
        <span className={`status-badge ${device.status?.toLowerCase()}`}>
          {device.status || 'OFFLINE'}
        </span>
      </div>

      <div className="tab-navigation">
        <button
          className={`tab-button ${activeTab === 'control' ? 'active' : ''}`}
          onClick={() => setActiveTab('control')}
        >
          Điều khiển
        </button>
        <button
          className={`tab-button ${activeTab === 'history' ? 'active' : ''}`}
          onClick={() => setActiveTab('history')}
        >
          Lịch sử cảm biến
        </button>
      </div>

      {/* Notification Panel */}
      {notifications.length > 0 && (
        <div className="notification-panel">
          <div className="notification-header">
            <h3>⚠️ Cảnh báo</h3>
            <button className="clear-notifications-btn" onClick={clearNotifications}>
              Xóa tất cả
            </button>
          </div>
          <div className="notification-list">
            {notifications.map(notification => (
              <div key={notification.id} className={`notification-item ${notification.type}`}>
                <div className="notification-content">
                  <div className="notification-title">{notification.title}</div>
                  <div className="notification-message">{notification.message}</div>
                  <div className="notification-time">
                    {notification.timestamp.toLocaleTimeString('vi-VN')}
                  </div>
                </div>
                <button
                  className="notification-close"
                  onClick={() => removeNotification(notification.id)}
                >
                  ×
                </button>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Threshold Configuration */}
      <div className="threshold-config">
        <button
          className="threshold-config-btn"
          onClick={() => setShowThresholdConfig(!showThresholdConfig)}
        >
          ⚙️ Cấu hình ngưỡng {showThresholdConfig ? '▼' : '▶'}
        </button>
        {showThresholdConfig && (
          <div className="threshold-settings">
            <div className="threshold-group">
              <h4>Nhiệt độ (°C)</h4>
              <div className="threshold-inputs">
                <div className="threshold-input">
                  <label>Min:</label>
                  <input
                    type="number"
                    value={thresholds.temperature.min}
                    onChange={(e) => updateThreshold('temperature', 'min', e.target.value)}
                    step="0.1"
                  />
                </div>
                <div className="threshold-input">
                  <label>Max:</label>
                  <input
                    type="number"
                    value={thresholds.temperature.max}
                    onChange={(e) => updateThreshold('temperature', 'max', e.target.value)}
                    step="0.1"
                  />
                </div>
              </div>
            </div>
            <div className="threshold-group">
              <h4>Độ ẩm (%)</h4>
              <div className="threshold-inputs">
                <div className="threshold-input">
                  <label>Min:</label>
                  <input
                    type="number"
                    value={thresholds.humidity.min}
                    onChange={(e) => updateThreshold('humidity', 'min', e.target.value)}
                    step="0.1"
                  />
                </div>
                <div className="threshold-input">
                  <label>Max:</label>
                  <input
                    type="number"
                    value={thresholds.humidity.max}
                    onChange={(e) => updateThreshold('humidity', 'max', e.target.value)}
                    step="0.1"
                  />
                </div>
              </div>
            </div>
          </div>
        )}
      </div>

      {activeTab === 'control' ? (
        <>
          <div className="device-details">
            <div className="detail-item">
              <span className="label">Device ID:</span>
              <span className="value">{device.deviceId}</span>
            </div>
            <div className="detail-item">
              <span className="label">Loại thiết bị:</span>
              <span className="value">{device.deviceType}</span>
            </div>
            <div className="detail-item">
              <span className="label">Mô tả:</span>
              <span className="value">{device.description}</span>
            </div>
            {device.lastSeen && (
              <div className="detail-item">
                <span className="label">Lần cuối online:</span>
                <span className="value">{formatDate(device.lastSeen)}</span>
              </div>
            )}
          </div>

          {sensorData && (
            <div className="sensor-data-section">
              <h3>
                <span className="live-indicator"></span>
                Dữ liệu cảm biến
              </h3>
              <div className="sensor-cards">
                <div className="sensor-card temperature-card">
                  <div className="sensor-card-content">
                    <div className="sensor-header">
                      <h4 className="sensor-title">Nhiệt độ</h4>
                      <span className={`sensor-status status-${getTemperatureStatus(sensorData.temperature)}`}>
                        {getTemperatureStatusText(sensorData.temperature)}
                      </span>
                    </div>
                    <div className="sensor-value">
                      {sensorData.temperature.toFixed(1)}
                      <span className="sensor-unit">°C</span>
                    </div>
                    <div className="sensor-details">
                      <div className="last-updated">
                        Cập nhật: {formatDate(sensorData.timestamp)}
                      </div>
                      <div className="live-badge">
                        <span>LIVE</span>
                      </div>
                    </div>
                  </div>
                </div>
                <div className="sensor-card humidity-card">
                  <div className="sensor-card-content">
                    <div className="sensor-header">
                      <h4 className="sensor-title">Độ ẩm</h4>
                      <span className={`sensor-status status-${getHumidityStatus(sensorData.humidity)}`}>
                        {getHumidityStatusText(sensorData.humidity)}
                      </span>
                    </div>
                    <div className="sensor-value">
                      {sensorData.humidity.toFixed(1)}
                      <span className="sensor-unit">%</span>
                    </div>
                    <div className="sensor-details">
                      <div className="last-updated">
                        Cập nhật: {formatDate(sensorData.timestamp)}
                      </div>
                      <div className="live-badge">
                        <span>LIVE</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}

          <div className="control-panel">
            <h3>Điều khiển LED</h3>
            <div className="control-buttons">
              <button
                className="btn-on"
                onClick={() => handleControl('ON')}
                disabled={loading}
              >
                💡 BẬT LED
              </button>
              <button
                className="btn-off"
                onClick={() => handleControl('OFF')}
                disabled={loading}
              >
                🔴 TẮT LED
              </button>
            </div>
            {loading && <p className="loading-text">Đang gửi lệnh...</p>}
          </div>

          <div className="command-history">
            <h3>Lịch sử điều khiển</h3>
            {history.length === 0 ? (
              <p className="no-history">Chưa có lịch sử điều khiển</p>
            ) : (
              <table>
                <thead>
                  <tr>
                    <th>Lệnh</th>
                    <th>Nguồn</th>
                    <th>Trạng thái</th>
                    <th>Thời gian</th>
                  </tr>
                </thead>
                <tbody>
                  {history.map((cmd) => (
                    <tr key={cmd.id}>
                      <td>
                        <span className={`command-badge ${cmd.command.toLowerCase()}`}>
                          {cmd.command}
                        </span>
                      </td>
                      <td>{cmd.source}</td>
                      <td>{cmd.status}</td>
                      <td>{formatDate(cmd.createdAt)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        </>
      ) : (
        <SensorHistory deviceId={device.deviceId} />
      )}
    </div>
  );
}

export default DeviceControl;
