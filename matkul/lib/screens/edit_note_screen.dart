import 'package:flutter/material.dart';
import 'package:matkul/services/firebase_service.dart';
import 'package:matkul/models/course_model.dart';
import 'package:matkul/models/note_model.dart';

class EditNoteScreen extends StatefulWidget {
  final Note note;
  const EditNoteScreen({super.key, required this.note});
  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final _firebaseService = FirebaseService();
  Course? _selectedCourse;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _updateNote() async {
    if (_titleController.text.trim().isEmpty) {
      _showSnackBar('Judul catatan tidak boleh kosong');
      return;
    }
    if (_contentController.text.trim().isEmpty) {
      _showSnackBar('Isi catatan tidak boleh kosong');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final updatedNote = Note(
        id: widget.note.id,
        courseId: _selectedCourse?.id ?? widget.note.courseId,
        courseName: _selectedCourse?.name ?? widget.note.courseName,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        timestamp: widget.note.timestamp,
      );
      await _firebaseService.updateNote(updatedNote);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catatan berhasil diperbarui'), backgroundColor: Color(0xFF5C3EBC)),
        );
      }
    } catch (e) {
      _showSnackBar('Gagal memperbarui catatan');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFF5C3EBC)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Theme.of(context).scaffoldBackgroundColor : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF5C3EBC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Catatan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Mata Kuliah', isDark),
            const SizedBox(height: 8),
            StreamBuilder<List<Course>>(
              stream: _firebaseService.getCourses(),
              builder: (context, snapshot) {
                final courses = snapshot.data ?? [];
                if (_selectedCourse == null && courses.isNotEmpty) {
                  try {
                    _selectedCourse = courses.firstWhere((c) => c.id == widget.note.courseId);
                  } catch (_) {}
                }
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDark ? Colors.grey[800]! : const Color(0xFFDDD6FE)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Course>(
                      isExpanded: true,
                      dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                      value: _selectedCourse,
                      items: courses
                          .map((c) => DropdownMenuItem(
                                value: c, 
                                child: Text(c.name, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedCourse = val),
                      icon: Icon(Icons.arrow_drop_down, color: isDark ? const Color(0xFF967FE8) : const Color(0xFF5C3EBC)),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildLabel('Judul Catatan', isDark),
            const SizedBox(height: 8),
            _buildTextField(_titleController, 'Judul catatan', isDark, maxLines: 1),
            const SizedBox(height: 20),
            _buildLabel('Isi Catatan', isDark),
            const SizedBox(height: 8),
            _buildTextField(_contentController, 'Isi catatan...', isDark, maxLines: 7),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C3EBC),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save, color: Colors.white),
                label: Text(
                  _isSaving ? 'Menyimpan...' : 'PERBARUI CATATAN',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
                ),
                onPressed: _isSaving ? null : _updateNote,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(color: isDark ? const Color(0xFF967FE8) : const Color(0xFF5C3EBC), fontWeight: FontWeight.w600, fontSize: 14),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, bool isDark, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDark ? Colors.grey[800]! : const Color(0xFFDDD6FE))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDark ? Colors.grey[800]! : const Color(0xFFDDD6FE))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isDark ? const Color(0xFF967FE8) : const Color(0xFF5C3EBC), width: 2)),
      ),
    );
  }
}