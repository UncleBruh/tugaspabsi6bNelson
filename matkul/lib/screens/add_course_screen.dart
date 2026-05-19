import 'package:flutter/material.dart';
import 'package:matkul/services/firebase_service.dart';
import 'package:matkul/models/course_model.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});
  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _nameController = TextEditingController();
  final _lecturerController = TextEditingController();
  final _firebaseService = FirebaseService();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _lecturerController.dispose();
    super.dispose();
  }

  Future<void> _saveCourse() async {
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
      await _firebaseService.addCourse(Course(
        name: _nameController.text.trim(),
        lecturer: _lecturerController.text.trim(),
        timestamp: DateTime.now().millisecondsSinceEpoch, // Tambahkan baris ini
      ));
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mata kuliah berhasil ditambahkan'), backgroundColor: Color(0xFF5C3EBC)),
        );
      }
    } catch (e) {
      _showSnackBar('Gagal menyimpan mata kuliah');
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
        title: const Text('Tambah Mata Kuliah', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark 
                      ? [const Color(0xFF4A3299), const Color(0xFF6544AD)]
                      : [const Color(0xFF5C3EBC), const Color(0xFF7B52D3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.school, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mata Kuliah Baru', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Isi data mata kuliah yang akan ditambahkan', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
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
                  _isSaving ? 'Menyimpan...' : 'SIMPAN MATA KULIAH',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
                ),
                onPressed: _isSaving ? null : _saveCourse,
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