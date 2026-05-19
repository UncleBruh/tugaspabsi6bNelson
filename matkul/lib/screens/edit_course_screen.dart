import 'package:flutter/material.dart';
import 'package:matkul/services/firebase_service.dart';
import 'package:matkul/models/course_model.dart';

class EditCourseScreen extends StatefulWidget {
  final Course course;
  const EditCourseScreen({super.key, required this.course});

  @override
  State<EditCourseScreen> createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  late TextEditingController _nameController;
  late TextEditingController _lecturerController;
  final _firebaseService = FirebaseService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.course.name);
    _lecturerController = TextEditingController(text: widget.course.lecturer);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lecturerController.dispose();
    super.dispose();
  }

  Future<void> _updateCourse() async {
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('Nama mata kuliah tidak boleh kosong');
      return;
    }
    if (_lecturerController.text.trim().isEmpty) {
      _showSnackBar('Nama dosen tidak boleh kosong');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final updatedCourse = Course(
        id: widget.course.id,
        name: _nameController.text.trim(),
        lecturer: _lecturerController.text.trim(),
        timestamp: widget.course.timestamp, // Mempertahankan timestamp asli
      );
      await _firebaseService.updateCourse(updatedCourse);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mata kuliah berhasil diperbarui'), backgroundColor: Color(0xFF5C3EBC)),
        );
      }
    } catch (e) {
      _showSnackBar('Gagal memperbarui mata kuliah');
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
        title: const Text('Edit Mata Kuliah', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Nama Mata Kuliah', isDark),
            const SizedBox(height: 8),
            _buildTextField(_nameController, 'Contoh: Pemrograman Mobile', isDark),
            const SizedBox(height: 20),
            _buildLabel('Nama Dosen', isDark),
            const SizedBox(height: 8),
            _buildTextField(_lecturerController, 'Contoh: Dr. Andi Wijaya', isDark),
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
                  _isSaving ? 'Menyimpan...' : 'PERBARUI MATA KULIAH',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
                ),
                onPressed: _isSaving ? null : _updateCourse,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Text(text, style: TextStyle(color: isDark ? const Color(0xFF967FE8) : const Color(0xFF5C3EBC), fontWeight: FontWeight.w600, fontSize: 14));
  }

  Widget _buildTextField(TextEditingController controller, String hint, bool isDark) {
    return TextField(
      controller: controller,
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