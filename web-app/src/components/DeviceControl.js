import React, { useState, useEffect } from 'react';
import './DeviceControl.css';
import { deviceService } from '../services/api';

function DeviceControl({ device, onControl, onRefresh }) {
  const [history, setHistory] = useState([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    loadHistory();
  }, [device.deviceId]);

  const loadHistory = async () => {
    try {
      const data = await deviceService.getCommandHistory(device.deviceId);
      setHistory(data.slice(0, 5)); // Show last 5 commands
    } catch (err) {
      console.error('Error loading history:', err);
    }
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

  return (
    <div className="device-control">
      <div className="control-header">
        <h2>{device.deviceName}</h2>
        <span className={`status-badge ${device.status?.toLowerCase()}`}>
          {device.status || 'OFFLINE'}
        </span>
      </div>

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
    </div>
  );
}

export default DeviceControl;
