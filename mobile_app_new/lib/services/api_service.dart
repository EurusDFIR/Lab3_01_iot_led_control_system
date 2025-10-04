import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/device.dart';
import '../models/device_command.dart';

class ApiService {
  // ⚠️ QUAN TRỌNG: Thay đổi IP này thành IP máy tính chạy backend
  // KHÔNG dùng localhost hoặc 127.0.0.1 vì emulator/device cần IP thực
  // Cách tìm IP: Mở CMD → gõ "ipconfig" → tìm IPv4 Address
  // VD: 'http://192.168.1.25:8080/api'
  // For Android Emulator, use: 10.0.2.2 (special IP to reach host machine)
  static const String baseUrl =
      'http://10.0.2.2:8080/api'; // 👈 DÙNG 10.0.2.2 cho Android Emulator!

  // Get all devices
  Future<List<Device>> getAllDevices() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/devices'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Device.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load devices: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading devices: $e');
    }
  }

  // Get device by ID
  Future<Device> getDeviceById(String deviceId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/devices/$deviceId'));

      if (response.statusCode == 200) {
        return Device.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load device: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading device: $e');
    }
  }

  // Register new device
  Future<Device> registerDevice(Device device) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/devices'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(device.toJson()),
      );

      if (response.statusCode == 200) {
        return Device.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to register device: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error registering device: $e');
    }
  }

  // Control device
  Future<void> controlDevice(String deviceId, String command) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/devices/$deviceId/control'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'command': command,
          'source': 'MOBILE',
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to control device: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error controlling device: $e');
    }
  }

  // Get command history
  Future<List<DeviceCommand>> getCommandHistory(String deviceId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/devices/$deviceId/history'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => DeviceCommand.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading history: $e');
    }
  }

  // Get latest sensor data
  Future<Map<String, dynamic>?> getLatestSensorData(String deviceId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/sensor-data/latest/$deviceId'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        return null; // No sensor data available
      } else {
        throw Exception('Failed to load sensor data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading sensor data: $e');
    }
  }
}
