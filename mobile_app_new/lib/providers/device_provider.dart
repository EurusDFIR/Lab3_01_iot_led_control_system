import 'package:flutter/material.dart';
import '../models/device.dart';
import '../services/api_service.dart';

class DeviceProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Device> _devices = [];
  Device? _selectedDevice;
  bool _isLoading = false;
  String? _errorMessage;

  List<Device> get devices => _devices;
  Device? get selectedDevice => _selectedDevice;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load all devices
  Future<void> loadDevices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _devices = await _apiService.getAllDevices();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Select device
  void selectDevice(Device device) {
    _selectedDevice = device;
    notifyListeners();
  }

  // Register new device
  Future<bool> registerDevice(Device device) async {
    try {
      await _apiService.registerDevice(device);
      await loadDevices();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Control device
  Future<bool> controlDevice(String deviceId, String command) async {
    try {
      await _apiService.controlDevice(deviceId, command);
      await loadDevices();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
