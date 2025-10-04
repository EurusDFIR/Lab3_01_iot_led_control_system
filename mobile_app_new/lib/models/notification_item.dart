class NotificationItem {
  final String id;
  final String type; // 'temperature' or 'humidity'
  final String message;
  final DateTime timestamp;
  final double value;
  final String thresholdType; // 'min' or 'max'

  NotificationItem({
    required this.id,
    required this.type,
    required this.message,
    required this.timestamp,
    required this.value,
    required this.thresholdType,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      message: json['message'] ?? '',
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      value: (json['value'] ?? 0.0).toDouble(),
      thresholdType: json['thresholdType'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'value': value,
      'thresholdType': thresholdType,
    };
  }
}
