class Note {
  String? id;
  String courseId;
  String courseName;
  String title;
  String content;
  int timestamp;

  Note({
    this.id,
    required this.courseId,
    required this.courseName,
    required this.title,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'courseName': courseName,
      'title': title,
      'content': content,
      'timestamp': timestamp,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map, String documentId) {
    return Note(
      id: documentId,
      courseId: map['courseId'] ?? '',
      courseName: map['courseName'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      timestamp: map['timestamp'] ?? 0,
    );
  }
}