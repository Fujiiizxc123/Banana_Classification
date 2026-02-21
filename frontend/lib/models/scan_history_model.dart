class ScanHistoryModel {
  final int id;
  final String result;
  final double confidence;
  final String createdAt;

  ScanHistoryModel({
    required this.id,
    required this.result,
    required this.confidence,
    required this.createdAt,
  });

  factory ScanHistoryModel.fromJson(Map<String, dynamic> json) {
    return ScanHistoryModel(
      id: json['id'],
      result: json['result'],
      confidence: (json['confidence'] as num).toDouble(),
      createdAt: json['created_at'],
    );
  }
}
