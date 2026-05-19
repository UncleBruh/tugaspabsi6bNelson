import 'package:firebase_database/firebase_database.dart'; 
import '../models/course_model.dart';
import '../models/note_model.dart';

class FirebaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref(); 


  Future<void> addCourse(Course course) async {
    await _dbRef.child('courses').push().set(course.toMap()); 
  }

  Future<void> updateCourse(Course course) async {
    await _dbRef.child('courses').child(course.id!).update(course.toMap());
  }

  Future<void> removeCourse(String courseId) async {
    await _dbRef.child('courses').child(courseId).remove();
  }

  Stream<List<Course>> getCourses() {
    return _dbRef.child('courses').onValue.map((event) { 
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      
      return data.entries.map((e) {
        final mapData = Map<String, dynamic>.from(e.value as Map);
        return Course.fromMap(mapData, e.key.toString());
      }).toList();
    });
  }

  Future<void> addNote(Note note) async {
    await _dbRef.child('notes').push().set(note.toMap());
  }

  Future<void> updateNote(Note note) async {
    await _dbRef.child('notes').child(note.id!).update(note.toMap());
  }

  Stream<List<Note>> getNotes() {
    return _dbRef.child('notes').onValue.map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      
      List<Note> notes = data.entries.map((e) {
        final mapData = Map<String, dynamic>.from(e.value as Map);
        return Note.fromMap(mapData, e.key.toString());
      }).toList();
      
      notes.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return notes;
    });
  }

  Future<void> removeNote(String key) async {
    await _dbRef.child('notes').child(key).remove();
  }
}