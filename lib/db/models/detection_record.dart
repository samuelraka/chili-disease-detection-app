class DetectionRecord {
  final int? id;
  final String imagePath;
  final String disease;
  final double confidence;
  final String date;
  final List<String> symptoms;
  final List<String> prevention;

  DetectionRecord({
    this.id,
    required this.imagePath,
    required this.disease,
    required this.confidence,
    required this.date,
    required this.symptoms,
    required this.prevention,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'disease': disease,
      'confidence': confidence,
      'date': date,
      'symptoms': symptoms.join(','),
      'prevention': prevention.join(','),
    };
  }

  factory DetectionRecord.fromMap(Map<String, dynamic> map) {
    return DetectionRecord(
      id: map['id'],
      imagePath: map['imagePath'],
      disease: map['disease'],
      confidence: map['confidence'],
      date: map['date'],
      symptoms: (map['symptoms'] as String).split(','),
      prevention: (map['prevention'] as String).split(','),
    );
  }
}
