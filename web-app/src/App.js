import React, { useState, useEffect } from 'react';
import './App.css';
import DeviceList from './components/DeviceList';
import DeviceControl from './components/DeviceControl';
import DeviceRegistration from './components/DeviceRegistration';
import { deviceService } from './services/api';

function App() {
  const [devices, setDevices] = useState([]);
  const [selectedDevice, setSelectedDevice] = useState(null);
  const [showRegistration, setShowRegistration] = useState(false);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Load devices on mount
  useEffect(() => {
    loadDevices();
    // Auto refresh every 5 seconds
    const interval = setInterval(loadDevices, 5000);
    return () => clearInterval(interval);
  }, []);

  const loadDevices = async () => {
    try {
      const data = await deviceService.getAllDevices();
      setDevices(data);
      setLoading(false);
      setError(null);
    } catch (err) {
      console.error('Error loading devices:', err);
      setError('Không thể kết nối đến server. Vui lòng kiểm tra backend.');
      setLoading(false);
    }
  };

  const handleDeviceSelect = (device) => {
    setSelectedDevice(device);
    setShowRegistration(false);
  };

  const handleRegisterDevice = async (deviceData) => {
    try {
      await deviceService.registerDevice(deviceData);
      await loadDevices();
      setShowRegistration(false);
      alert('Thiết bị đã được đăng ký thành công!');
    } catch (err) {
      console.error('Error registering device:', err);
      alert('Lỗi khi đăng ký thiết bị: ' + (err.response?.data?.message || err.message));
    }
  };

  const handleControlDevice = async (deviceId, command) => {
    try {
      await deviceService.controlDevice(deviceId, command, 'WEB');
      await loadDevices();
    } catch (err) {
      console.error('Error controlling device:', err);
      alert('Lỗi khi điều khiển thiết bị: ' + (err.response?.data?.message || err.message));
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>🔌 IoT LED Control System</h1>
        <p>Điều khiển LED trên ESP32C3 qua MQTT</p>
      </header>

      <main className="App-main">
        {error && (
          <div className="error-message">
            <p>❌ {error}</p>
          </div>
        )}

        <div className="container">
          <div className="sidebar">
            <div className="sidebar-header">
              <h2>Danh sách thiết bị</h2>
              <button 
                className="btn-register"
                onClick={() => setShowRegistration(true)}
              >
                + Đăng ký thiết bị
              </button>
            </div>
            
            {loading ? (
              <div className="loading">Đang tải...</div>
            ) : (
              <DeviceList
                devices={devices}
                selectedDevice={selectedDevice}
                onSelectDevice={handleDeviceSelect}
              />
            )}
          </div>

          <div className="content">
            {showRegistration ? (
              <DeviceRegistration
                onRegister={handleRegisterDevice}
                onCancel={() => setShowRegistration(false)}
              />
            ) : selectedDevice ? (
              <DeviceControl
                device={selectedDevice}
                onControl={handleControlDevice}
                onRefresh={loadDevices}
              />
            ) : (
              <div className="welcome">
                <h2>👋 Chào mừng!</h2>
                <p>Chọn một thiết bị từ danh sách bên trái để điều khiển</p>
                <p>hoặc đăng ký thiết bị mới</p>
              </div>
            )}
          </div>
        </div>
      </main>

      <footer className="App-footer">
        <p>IoT LED Control System © 2025 | ReactJS + Spring Boot + MQTT + ESP32C3</p>
      </footer>
    </div>
  );
}

export default App;
