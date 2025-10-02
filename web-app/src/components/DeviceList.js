import React from 'react';
import './DeviceList.css';

function DeviceList({ devices, selectedDevice, onSelectDevice }) {
  const getStatusColor = (status) => {
    if (status === 'ON') return '#4caf50';
    if (status === 'ONLINE') return '#2196f3';
    if (status === 'OFF') return '#ff9800';
    return '#9e9e9e';
  };

  const getStatusIcon = (status) => {
    if (status === 'ON') return '💡';
    if (status === 'ONLINE') return '🟢';
    if (status === 'OFF') return '🔴';
    return '⚫';
  };

  return (
    <div className="device-list">
      {devices.length === 0 ? (
        <div className="empty-list">
          <p>Chưa có thiết bị nào</p>
          <p>Nhấn "Đăng ký thiết bị" để thêm mới</p>
        </div>
      ) : (
        devices.map((device) => (
          <div
            key={device.deviceId}
            className={`device-item ${selectedDevice?.deviceId === device.deviceId ? 'active' : ''}`}
            onClick={() => onSelectDevice(device)}
          >
            <div className="device-icon">
              {getStatusIcon(device.status)}
            </div>
            <div className="device-info">
              <h3>{device.deviceName}</h3>
              <p className="device-id">{device.deviceId}</p>
              <span 
                className="device-status"
                style={{ backgroundColor: getStatusColor(device.status) }}
              >
                {device.status || 'OFFLINE'}
              </span>
            </div>
          </div>
        ))
      )}
    </div>
  );
}

export default DeviceList;
