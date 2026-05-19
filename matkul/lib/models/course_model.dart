class Course {
  String? id;
  String name;
  String lecturer;
  int timestamp;

  Course({
    this.id,
    required this.name,
    required this.lecturer,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'lecturer': lecturer,
      'timestamp': timestamp,
    };
  }

  factory Course.fromMap(Map<String, dynamic> map, String documentId) {
    return Course(
      id: documentId,
      name: map['name'] ?? '',
      lecturer: map['lecturer'] ?? '',
      timestamp: map['timestamp'] ?? 0,
    );
  }
}