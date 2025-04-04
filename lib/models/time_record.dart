class TimeRecord {
  final String id;
  final String companyId;
  final String companyName;
  final String projectId;
  final String projectName;
  final String type; // 'entrada' ou 'saída'
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final String? notes;

  TimeRecord({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.projectId,
    required this.projectName,
    required this.type,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'companyName': companyName,
      'projectId': projectId,
      'projectName': projectName,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'notes': notes,
    };
  }

  factory TimeRecord.fromJson(Map<String, dynamic> json) {
    return TimeRecord(
      id: json['id'],
      companyId: json['companyId'],
      companyName: json['companyName'],
      projectId: json['projectId'],
      projectName: json['projectName'],
      type: json['type'],
      timestamp: DateTime.parse(json['timestamp']),
      latitude: json['latitude'],
      longitude: json['longitude'],
      notes: json['notes'],
    );
  }
}
