import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/device.dart';
import '../providers/device_provider.dart';

class RegisterDeviceScreen extends StatefulWidget {
  const RegisterDeviceScreen({super.key});

  @override
  State<RegisterDeviceScreen> createState() => _RegisterDeviceScreenState();
}

class _RegisterDeviceScreenState extends State<RegisterDeviceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _deviceIdController = TextEditingController();
  final _deviceNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _topicControlController =
      TextEditingController(text: 'esp32/led/control');
  final _topicStatusController =
      TextEditingController(text: 'esp32/led/status');

  String _deviceType = 'ESP32C3';
  bool _isLoading = false;

  @override
  void dispose() {
    _deviceIdController.dispose();
    _deviceNameController.dispose();
    _descriptionController.dispose();
    _topicControlController.dispose();
    _topicStatusController.dispose();
    super.dispose();
  }

  Future<void> _registerDevice() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final device = Device(
      deviceId: _deviceIdController.text.trim(),
      deviceName: _deviceNameController.text.trim(),
      deviceType: _deviceType,
      description: _descriptionController.text.trim(),
      mqttTopicControl: _topicControlController.text.trim(),
      mqttTopicStatus: _topicStatusController.text.trim(),
    );

    final success = await context.read<DeviceProvider>().registerDevice(device);

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng ký thiết bị thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<DeviceProvider>().errorMessage ??
              'Lỗi đăng ký thiết bị'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📝 Đăng ký thiết bị mới'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _deviceIdController,
                label: 'Device ID',
                hint: 'VD: ESP32C3_001',
                icon: Icons.fingerprint,
                required: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _deviceNameController,
                label: 'Tên thiết bị',
                hint: 'VD: ESP32C3 Lab Room 1',
                icon: Icons.devices,
                required: true,
              ),
              const SizedBox(height: 16),
              _buildDeviceTypeDropdown(),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: 'Mô tả',
                hint: 'Mô tả về thiết bị...',
                icon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _topicControlController,
                label: 'MQTT Topic Control',
                hint: 'esp32/led/control',
                icon: Icons.cloud_upload,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _topicStatusController,
                label: 'MQTT Topic Status',
                hint: 'esp32/led/status',
                icon: Icons.cloud_download,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _registerDevice,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: const Color(0xFF667eea),
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Đăng ký thiết bị',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label + (required ? ' *' : ''),
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: required
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập $label';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildDeviceTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _deviceType,
      decoration: InputDecoration(
        labelText: 'Loại thiết bị',
        prefixIcon: const Icon(Icons.category),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: ['ESP32C3', 'ESP32', 'ESP8266', 'Arduino']
          .map((type) => DropdownMenuItem(
                value: type,
                child: Text(type),
              ))
          .toList(),
      onChanged: (value) {
        setState(() => _deviceType = value!);
      },
    );
  }
}
