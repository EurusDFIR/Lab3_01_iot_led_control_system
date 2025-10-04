import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/device.dart';
import '../models/device_command.dart';
import '../models/sensor_data.dart';
import '../models/notification_item.dart';
import '../services/api_service.dart';
import '../providers/device_provider.dart';

class DeviceDetailScreen extends StatefulWidget {
  final Device device;

  const DeviceDetailScreen({super.key, required this.device});

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  final ApiService _apiService = ApiService();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  List<DeviceCommand> _history = [];
  SensorData? _sensorData;
  bool _isLoading = false;
  bool _isLoadingSensor = false;
  Timer? _sensorTimer;

  // Notification system
  List<NotificationItem> _notifications = [];
  // ignore: prefer_final_fields
  Map<String, double> _thresholds = {
    'tempMin': 20.0,
    'tempMax': 30.0,
    'humidityMin': 30.0,
    'humidityMax': 70.0,
  };
  final Set<String> _shownNotifications =
      {}; // Track shown notifications to avoid duplicates

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadHistory();
    _loadSensorData();
    // Auto-refresh sensor data every 5 seconds
    _sensorTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _loadSensorData();
    });
  }

  @override
  void dispose() {
    _sensorTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final history =
          await _apiService.getCommandHistory(widget.device.deviceId);
      setState(() {
        _history = history.take(5).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải lịch sử: $e')),
        );
      }
    }
  }

  Future<void> _loadSensorData() async {
    setState(() => _isLoadingSensor = true);
    try {
      final sensorDataJson =
          await _apiService.getLatestSensorData(widget.device.deviceId);
      if (sensorDataJson != null) {
        final newSensorData = SensorData.fromJson(sensorDataJson);

        // Check thresholds and create notifications
        if (_sensorData != null) {
          _checkThresholds(newSensorData);
        }

        setState(() {
          _sensorData = newSensorData;
          _isLoadingSensor = false;
        });
      } else {
        setState(() => _isLoadingSensor = false);
      }
    } catch (e) {
      setState(() => _isLoadingSensor = false);
      // Don't show error snackbar for sensor data as it might not be available yet
    }
  }

  void _checkThresholds(SensorData sensorData) {
    // Check temperature thresholds
    if (sensorData.temperature < _thresholds['tempMin']!) {
      final notificationId =
          'temp_min_${sensorData.timestamp.millisecondsSinceEpoch}';
      if (!_shownNotifications.contains(notificationId)) {
        _createNotification(
          'Cảnh báo nhiệt độ thấp!',
          'Nhiệt độ hiện tại: ${sensorData.temperature.toStringAsFixed(1)}°C (dưới ngưỡng ${_thresholds['tempMin']}°C)',
          'temperature',
          sensorData.temperature,
          'min',
          notificationId,
        );
      }
    } else if (sensorData.temperature > _thresholds['tempMax']!) {
      final notificationId =
          'temp_max_${sensorData.timestamp.millisecondsSinceEpoch}';
      if (!_shownNotifications.contains(notificationId)) {
        _createNotification(
          'Cảnh báo nhiệt độ cao!',
          'Nhiệt độ hiện tại: ${sensorData.temperature.toStringAsFixed(1)}°C (vượt ngưỡng ${_thresholds['tempMax']}°C)',
          'temperature',
          sensorData.temperature,
          'max',
          notificationId,
        );
      }
    }

    // Check humidity thresholds
    if (sensorData.humidity < _thresholds['humidityMin']!) {
      final notificationId =
          'humidity_min_${sensorData.timestamp.millisecondsSinceEpoch}';
      if (!_shownNotifications.contains(notificationId)) {
        _createNotification(
          'Cảnh báo độ ẩm thấp!',
          'Độ ẩm hiện tại: ${sensorData.humidity.toStringAsFixed(1)}% (dưới ngưỡng ${_thresholds['humidityMin']!}%)',
          'humidity',
          sensorData.humidity,
          'min',
          notificationId,
        );
      }
    } else if (sensorData.humidity > _thresholds['humidityMax']!) {
      final notificationId =
          'humidity_max_${sensorData.timestamp.millisecondsSinceEpoch}';
      if (!_shownNotifications.contains(notificationId)) {
        _createNotification(
          'Cảnh báo độ ẩm cao!',
          'Độ ẩm hiện tại: ${sensorData.humidity.toStringAsFixed(1)}% (vượt ngưỡng ${_thresholds['humidityMax']!}%)',
          'humidity',
          sensorData.humidity,
          'max',
          notificationId,
        );
      }
    }
  }

  void _createNotification(String title, String body, String type, double value,
      String thresholdType, String notificationId) {
    final notification = NotificationItem(
      id: notificationId,
      type: type,
      message: '$title\n$body',
      timestamp: DateTime.now(),
      value: value,
      thresholdType: thresholdType,
    );

    setState(() {
      _notifications.insert(0, notification);
      // Keep only last 10 notifications
      if (_notifications.length > 10) {
        _notifications = _notifications.take(10).toList();
      }
    });

    _shownNotifications.add(notificationId);

    // Show local notification
    _showLocalNotification(title, body, notificationId.hashCode);
  }

  Future<void> _showLocalNotification(String title, String body, int id) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'sensor_alerts',
      'Sensor Alerts',
      channelDescription: 'Notifications for sensor threshold alerts',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> _controlDevice(String command) async {
    setState(() => _isLoading = true);

    final success = await context.read<DeviceProvider>().controlDevice(
          widget.device.deviceId,
          command,
        );

    if (success) {
      await _loadHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã gửi lệnh $command'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi khi gửi lệnh'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.deviceName),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadHistory();
          await _loadSensorData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(),
              const SizedBox(height: 20),
              _buildControlCard(),
              const SizedBox(height: 20),
              _buildSensorCard(),
              const SizedBox(height: 20),
              _buildNotificationCard(),
              const SizedBox(height: 20),
              _buildHistoryCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin thiết bị',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),
            _buildInfoRow('Device ID', widget.device.deviceId),
            _buildInfoRow('Loại thiết bị', widget.device.deviceType),
            _buildInfoRow('Mô tả', widget.device.description ?? '-'),
            _buildInfoRow('Trạng thái', widget.device.status ?? 'OFFLINE'),
            if (widget.device.lastSeen != null)
              _buildInfoRow(
                'Lần cuối online',
                _formatDate(widget.device.lastSeen!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              '💡 Điều khiển LED',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _controlDevice('ON'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.lightbulb, size: 40),
                        SizedBox(height: 8),
                        Text(
                          'BẬT LED',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _controlDevice('OFF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.lightbulb_outline, size: 40),
                        SizedBox(height: 8),
                        Text(
                          'TẮT LED',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_isLoading) ...[
              const SizedBox(height: 16),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSensorCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.thermostat,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Dữ liệu cảm biến',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _sensorData != null
                        ? Colors.greenAccent
                        : Colors.orangeAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isLoadingSensor)
              const CircularProgressIndicator(color: Colors.white)
            else if (_sensorData == null)
              const Column(
                children: [
                  Icon(
                    Icons.sensors_off,
                    color: Colors.white70,
                    size: 48,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Chưa có dữ liệu cảm biến',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSensorItem(
                    'Nhiệt độ',
                    '${_sensorData!.temperature.toStringAsFixed(1)}°C',
                    Icons.thermostat,
                    _getTemperatureColor(_sensorData!.temperature),
                    Icons.whatshot,
                  ),
                  Container(
                    height: 60,
                    width: 1,
                    color: Colors.white30,
                  ),
                  _buildSensorItem(
                    'Độ ẩm',
                    '${_sensorData!.humidity.toStringAsFixed(1)}%',
                    Icons.water_drop,
                    _getHumidityColor(_sensorData!.humidity),
                    Icons.opacity,
                  ),
                ],
              ),
            if (_sensorData != null) ...[
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Cập nhật: ${_formatDate(_sensorData!.timestamp)}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getTemperatureColor(double temperature) {
    if (temperature < 20) return Colors.blue;
    if (temperature < 25) return Colors.green;
    if (temperature < 30) return Colors.orange;
    return Colors.red;
  }

  Color _getHumidityColor(double humidity) {
    if (humidity < 30) return Colors.red;
    if (humidity < 50) return Colors.orange;
    if (humidity < 70) return Colors.green;
    return Colors.blue;
  }

  Widget _buildSensorItem(String label, String value, IconData icon,
      Color color, IconData secondaryIcon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            size: 32,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '⚠️ Cảnh báo cảm biến',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => _showThresholdDialog(),
                  icon: const Icon(Icons.settings),
                  tooltip: 'Thiết lập ngưỡng',
                ),
              ],
            ),
            const Divider(height: 20),
            // Threshold display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Nhiệt độ:',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      Text(
                          '${_thresholds['tempMin']}°C - ${_thresholds['tempMax']}°C'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Độ ẩm:',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      Text(
                          '${_thresholds['humidityMin']}% - ${_thresholds['humidityMax']}%'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Notifications list
            if (_notifications.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Chưa có cảnh báo nào',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ..._notifications
                  .map((notification) => _buildNotificationItem(notification)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    final isTemperature = notification.type == 'temperature';
    final isMin = notification.thresholdType == 'min';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isTemperature
            ? (isMin ? Colors.blue[50] : Colors.red[50])
            : (isMin ? Colors.orange[50] : Colors.purple[50]),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isTemperature
              ? (isMin ? Colors.blue[200]! : Colors.red[200]!)
              : (isMin ? Colors.orange[200]! : Colors.purple[200]!),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isTemperature ? Icons.thermostat : Icons.water_drop,
                color: isTemperature
                    ? (isMin ? Colors.blue : Colors.red)
                    : (isMin ? Colors.orange : Colors.purple),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  notification.message.split('\n')[0],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isTemperature
                        ? (isMin ? Colors.blue[800] : Colors.red[800])
                        : (isMin ? Colors.orange[800] : Colors.purple[800]),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            notification.message.split('\n')[1],
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(notification.timestamp),
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showThresholdDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thiết lập ngưỡng cảnh báo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Temperature thresholds
            const Text('Nhiệt độ (°C)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Min'),
                    controller: TextEditingController(
                        text: _thresholds['tempMin'].toString()),
                    onChanged: (value) {
                      final val = double.tryParse(value);
                      if (val != null) {
                        setState(() => _thresholds['tempMin'] = val);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Max'),
                    controller: TextEditingController(
                        text: _thresholds['tempMax'].toString()),
                    onChanged: (value) {
                      final val = double.tryParse(value);
                      if (val != null) {
                        setState(() => _thresholds['tempMax'] = val);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Humidity thresholds
            const Text('Độ ẩm (%)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Min'),
                    controller: TextEditingController(
                        text: _thresholds['humidityMin'].toString()),
                    onChanged: (value) {
                      final val = double.tryParse(value);
                      if (val != null) {
                        setState(() => _thresholds['humidityMin'] = val);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Max'),
                    controller: TextEditingController(
                        text: _thresholds['humidityMax'].toString()),
                    onChanged: (value) {
                      final val = double.tryParse(value);
                      if (val != null) {
                        setState(() => _thresholds['humidityMax'] = val);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lịch sử điều khiển',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),
            if (_history.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Chưa có lịch sử điều khiển',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ..._history.map((cmd) => _buildHistoryItem(cmd)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(DeviceCommand cmd) {
    final isOn = cmd.command == 'ON';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isOn ? Icons.lightbulb : Icons.lightbulb_outline,
            color: isOn ? Colors.green : Colors.orange,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cmd.command,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isOn ? Colors.green : Colors.orange,
                  ),
                ),
                Text(
                  'Nguồn: ${cmd.source} • ${cmd.status}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  _formatDate(cmd.createdAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
