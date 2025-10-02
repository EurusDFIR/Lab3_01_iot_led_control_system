class Device {
  final int? id;
  final String deviceId;
  final String deviceName;
  final String deviceType;
  final String? description;
  final String mqttTopicControl;
  final String mqttTopicStatus;
  final String? status;
  final DateTime? lastSeen;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Device({
    this.id,
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    this.description,
    required this.mqttTopicControl,
    required this.mqttTopicStatus,
    this.status,
    this.lastSeen,
    this.createdAt,
    this.updatedAt,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'],
      deviceId: json['deviceId'],
      deviceName: json['deviceName'],
      deviceType: json['deviceType'],
      description: json['description'],
      mqttTopicControl: json['mqttTopicControl'],
      mqttTopicStatus: json['mqttTopicStatus'],
      status: json['status'],
      lastSeen: _parseDateTime(json['lastSeen']),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  static DateTime? _parseDateTime(dynamic dateData) {
    if (dateData == null) return null;

    if (dateData is String) {
      return DateTime.parse(dateData);
    } else if (dateData is List && dateData.length >= 7) {
      // Handle Spring Boot LocalDateTime format [year, month, day, hour, minute, second, nano]
      return DateTime(
        dateData[0], // year
        dateData[1], // month
        dateData[2], // day
        dateData[3], // hour
        dateData[4], // minute
        dateData[5], // second
        dateData[6] ~/ 1000000, // convert nano to micro
      );
    }

    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'deviceType': deviceType,
      'description': description,
      'mqttTopicControl': mqttTopicControl,
      'mqttTopicStatus': mqttTopicStatus,
    };
  }
}
