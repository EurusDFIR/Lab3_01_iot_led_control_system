class SensorData {
  final String deviceId;
  final double temperature;
  final double humidity;
  final DateTime timestamp;

  SensorData({
    required this.deviceId,
    required this.temperature,
    required this.humidity,
    required this.timestamp,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    DateTime timestamp;
    if (json['timestamp'] is List) {
      // Handle timestamp as List [year, month, day, hour, minute, second, millisecond]
      List<int> timestampList = List<int>.from(json['timestamp']);
      timestamp = DateTime(
        timestampList[0], // year
        timestampList[1], // month
        timestampList[2], // day
        timestampList[3], // hour
        timestampList[4], // minute
        timestampList[5], // second
        timestampList.length > 6
            ? timestampList[6] ~/ 1000
            : 0, // millisecond to microsecond
      );
    } else {
      // Handle timestamp as string (fallback)
      timestamp = DateTime.parse(json['timestamp']);
    }

    return SensorData(
      deviceId: json['deviceId'],
      temperature: json['temperature'].toDouble(),
      humidity: json['humidity'].toDouble(),
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'temperature': temperature,
      'humidity': humidity,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
