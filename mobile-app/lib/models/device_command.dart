class DeviceCommand {
  final int id;
  final String deviceId;
  final String command;
  final String source;
  final String status;
  final DateTime createdAt;
  final DateTime? executedAt;

  DeviceCommand({
    required this.id,
    required this.deviceId,
    required this.command,
    required this.source,
    required this.status,
    required this.createdAt,
    this.executedAt,
  });

  factory DeviceCommand.fromJson(Map<String, dynamic> json) {
    return DeviceCommand(
      id: json['id'],
      deviceId: json['deviceId'],
      command: json['command'],
      source: json['source'],
      status: json['status'],
      createdAt: _parseDateTime(json['createdAt']),
      executedAt: _parseDateTime(json['executedAt']),
    );
  }

  static DateTime _parseDateTime(dynamic dateData) {
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

    throw FormatException('Invalid date format: $dateData');
  }
}
