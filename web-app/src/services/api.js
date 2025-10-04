import axios from 'axios';

const API_BASE_URL = 'http://localhost:8080/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

export const deviceService = {
  // Get all devices
  getAllDevices: async () => {
    const response = await api.get('/devices');
    return response.data;
  },

  // Get device by ID
  getDeviceById: async (deviceId) => {
    const response = await api.get(`/devices/${deviceId}`);
    return response.data;
  },

  // Register new device
  registerDevice: async (deviceData) => {
    const response = await api.post('/devices', deviceData);
    return response.data;
  },

  // Control device
  controlDevice: async (deviceId, command, source = 'WEB') => {
    const response = await api.post(`/devices/${deviceId}/control`, {
      command,
      source,
    });
    return response.data;
  },

  // Get command history
  getCommandHistory: async (deviceId) => {
    const response = await api.get(`/devices/${deviceId}/history`);
    return response.data;
  },

  // Get status history
  getStatusHistory: async (deviceId) => {
    const response = await api.get(`/devices/${deviceId}/status-history`);
    return response.data;
  },
};

export const sensorDataService = {
  // Get latest sensor data for device
  getLatestSensorData: async (deviceId) => {
    const response = await api.get(`/sensor-data/latest/${deviceId}`);
    return response.data;
  },

  // Get sensor data history for device
  getSensorDataHistory: async (deviceId) => {
    const response = await api.get(`/sensor-data/history/${deviceId}`);
    return response.data;
  },

  // Get sensor data history since timestamp
  getSensorDataHistorySince: async (deviceId, sinceTimestamp) => {
    const response = await api.get(`/sensor-data/history/${deviceId}/since`, {
      params: { since: sinceTimestamp }
    });
    return response.data;
  },
};

export default api;
