import React, { useState, useEffect, useCallback } from 'react';
import { sensorDataService } from '../services/api';
import './SensorHistory.css';

function SensorHistory({ deviceId }) {
  const [sensorHistory, setSensorHistory] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [timeRange, setTimeRange] = useState('all'); // 'all', '1h', '24h', '7d'

  const getTimeRangeTimestamp = useCallback(() => {
    const now = new Date();
    switch (timeRange) {
      case '1h':
        return new Date(now.getTime() - 60 * 60 * 1000).toISOString().slice(0, 19);
      case '24h':
        return new Date(now.getTime() - 24 * 60 * 60 * 1000).toISOString().slice(0, 19);
      case '7d':
        return new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000).toISOString().slice(0, 19);
      default:
        return null;
    }
  }, [timeRange]);

  const loadSensorHistory = useCallback(async () => {
    try {
      setLoading(true);
      let data;

      if (timeRange === 'all') {
        data = await sensorDataService.getSensorDataHistory(deviceId);
      } else {
        const since = getTimeRangeTimestamp();
        if (since) {
          data = await sensorDataService.getSensorDataHistorySince(deviceId, since);
        } else {
          data = await sensorDataService.getSensorDataHistory(deviceId);
        }
      }

      // Filter out any invalid data
      const validData = data.filter(item =>
        item &&
        item.timestamp &&
        item.temperature != null &&
        item.humidity != null
      );

      setSensorHistory(validData);
      setError(null);
    } catch (err) {
      console.error('Error loading sensor history:', err);
      setError('Không thể tải lịch sử dữ liệu cảm biến: ' + (err.message || 'Lỗi không xác định'));
      setSensorHistory([]);
    } finally {
      setLoading(false);
    }
  }, [deviceId, timeRange, getTimeRangeTimestamp]);

  useEffect(() => {
    loadSensorHistory();
  }, [loadSensorHistory]);

  const formatDate = (dateString) => {
    if (!dateString) return 'N/A';
    try {
      const date = new Date(dateString);
      if (isNaN(date.getTime())) return 'Invalid Date';
      return date.toLocaleString('vi-VN');
    } catch (error) {
      console.error('Error formatting date:', error);
      return 'Error';
    }
  };

  const getTemperatureData = () => {
    return sensorHistory
      .filter(data => data && data.timestamp && data.temperature != null)
      .map(data => ({
        time: new Date(data.timestamp).getTime(),
        temperature: data.temperature,
        formattedTime: formatDate(data.timestamp)
      })).reverse();
  };

  const getHumidityData = () => {
    return sensorHistory
      .filter(data => data && data.timestamp && data.humidity != null)
      .map(data => ({
        time: new Date(data.timestamp).getTime(),
        humidity: data.humidity,
        formattedTime: formatDate(data.timestamp)
      })).reverse();
  };

  const getStats = () => {
    if (sensorHistory.length === 0) return null;

    const validData = sensorHistory.filter(data =>
      data && data.temperature != null && data.humidity != null
    );

    if (validData.length === 0) return null;

    const temperatures = validData.map(d => d.temperature);
    const humidities = validData.map(d => d.humidity);

    return {
      temperature: {
        min: Math.min(...temperatures),
        max: Math.max(...temperatures),
        avg: temperatures.reduce((a, b) => a + b, 0) / temperatures.length
      },
      humidity: {
        min: Math.min(...humidities),
        max: Math.max(...humidities),
        avg: humidities.reduce((a, b) => a + b, 0) / humidities.length
      }
    };
  };

  const stats = getStats();

  if (loading) {
    return (
      <div className="sensor-history">
        <div className="loading">Đang tải lịch sử dữ liệu...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="sensor-history">
        <div className="error">{error}</div>
      </div>
    );
  }

  return (
    <div className="sensor-history">
      <div className="history-header">
        <h3>Lịch sử dữ liệu cảm biến</h3>
        <div className="time-range-selector">
          <select value={timeRange} onChange={(e) => setTimeRange(e.target.value)}>
            <option value="all">Tất cả</option>
            <option value="1h">1 giờ</option>
            <option value="24h">24 giờ</option>
            <option value="7d">7 ngày</option>
          </select>
        </div>
      </div>

      {stats && (
        <div className="stats-grid">
          <div className="stat-card">
            <h4>Nhiệt độ</h4>
            <div className="stat-values">
              <div className="stat-item">
                <span className="label">Thấp nhất:</span>
                <span className="value">{stats.temperature.min.toFixed(1)}°C</span>
              </div>
              <div className="stat-item">
                <span className="label">Cao nhất:</span>
                <span className="value">{stats.temperature.max.toFixed(1)}°C</span>
              </div>
              <div className="stat-item">
                <span className="label">Trung bình:</span>
                <span className="value">{stats.temperature.avg.toFixed(1)}°C</span>
              </div>
            </div>
          </div>

          <div className="stat-card">
            <h4>Độ ẩm</h4>
            <div className="stat-values">
              <div className="stat-item">
                <span className="label">Thấp nhất:</span>
                <span className="value">{stats.humidity.min.toFixed(1)}%</span>
              </div>
              <div className="stat-item">
                <span className="label">Cao nhất:</span>
                <span className="value">{stats.humidity.max.toFixed(1)}%</span>
              </div>
              <div className="stat-item">
                <span className="label">Trung bình:</span>
                <span className="value">{stats.humidity.avg.toFixed(1)}%</span>
              </div>
            </div>
          </div>
        </div>
      )}

      <div className="charts-container">
        <div className="chart-card">
          <h4>Biểu đồ nhiệt độ</h4>
          <div className="chart-placeholder">
            <div className="temperature-chart">
              {getTemperatureData().map((data, index) => (
                <div key={index} className="data-point" title={`${data.formattedTime}: ${data.temperature}°C`}>
                  <div className="time">{new Date(data.time).toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' })}</div>
                  <div className="bar" style={{
                    height: `${Math.max(10, (data.temperature / 50) * 100)}%`,
                    backgroundColor: data.temperature > 30 ? '#ff5722' : data.temperature > 25 ? '#ff9800' : '#4caf50'
                  }}>
                    <span className="value">{data.temperature.toFixed(1)}°C</span>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        <div className="chart-card">
          <h4>Biểu đồ độ ẩm</h4>
          <div className="chart-placeholder">
            <div className="humidity-chart">
              {getHumidityData().map((data, index) => (
                <div key={index} className="data-point" title={`${data.formattedTime}: ${data.humidity}%`}>
                  <div className="time">{new Date(data.time).toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' })}</div>
                  <div className="bar" style={{
                    height: `${Math.max(10, (data.humidity / 100) * 100)}%`,
                    backgroundColor: data.humidity > 70 ? '#2196f3' : data.humidity > 50 ? '#00bcd4' : '#009688'
                  }}>
                    <span className="value">{data.humidity.toFixed(1)}%</span>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>

      <div className="data-table">
        <h4>Dữ liệu chi tiết</h4>
        <div className="table-container">
          <table>
            <thead>
              <tr>
                <th>Thời gian</th>
                <th>Nhiệt độ (°C)</th>
                <th>Độ ẩm (%)</th>
              </tr>
            </thead>
            <tbody>
              {sensorHistory
                .filter(data => data && data.timestamp)
                .slice(0, 50)
                .map((data, index) => (
                <tr key={index}>
                  <td>{formatDate(data.timestamp)}</td>
                  <td className={`temperature ${data.temperature > 30 ? 'high' : data.temperature > 25 ? 'medium' : 'normal'}`}>
                    {data.temperature != null ? data.temperature.toFixed(1) : 'N/A'}°C
                  </td>
                  <td className={`humidity ${data.humidity > 70 ? 'high' : data.humidity > 50 ? 'medium' : 'normal'}`}>
                    {data.humidity != null ? data.humidity.toFixed(1) : 'N/A'}%
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        {sensorHistory.length > 50 && (
          <p className="note">* Chỉ hiển thị 50 bản ghi gần nhất</p>
        )}
      </div>
    </div>
  );
}

export default SensorHistory;