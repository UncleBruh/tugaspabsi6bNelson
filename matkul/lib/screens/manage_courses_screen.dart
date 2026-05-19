import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import '../services/firebase_service.dart';
import '../models/course_model.dart';
import 'add_course_screen.dart';
import 'edit_course_screen.dart';

class ManageCoursesScreen extends StatefulWidget {
  const ManageCoursesScreen({super.key});

  @override
  State<ManageCoursesScreen> createState() => _ManageCoursesScreenState();
}

class _ManageCoursesScreenState extends State<ManageCoursesScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String _searchQuery = '';
  bool _isSearching = false;
  final _searchController = TextEditingController();

  bool _isSortDescending = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDeleteDialog(Course course) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Mata Kuliah'),
        content: Text('Yakin ingin menghapus mata kuliah "${course.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _firebaseService.removeCourse(course.id!);
              Navigator.pop(ctx);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => setState(() {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                }),
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  hintText: 'Cari mata kuliah...',
                  hintStyle: TextStyle(color: Colors.white60),
                  border: InputBorder.none,
                ),
                onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              )
            : const Text('Kelola Mata Kuliah', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () => setState(() => _isSearching = true),
            ),
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => setState(() {
                _isSearching = false;
                _searchQuery = '';
                _searchController.clear();
              }),
            ),
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.sort, color: Colors.white),
              tooltip: _isSortDescending ? 'Urutan: Terbaru' : 'Urutan: Terlama',
              onPressed: () {
                setState(() => _isSortDescending = !_isSortDescending);
              },
            ),
        ],
      ),
      body: StreamBuilder<List<Course>>(
        stream: _firebaseService.getCourses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF5C3EBC)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Belum ada mata kuliah',
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
              ),
            );
          }
          final courses = snapshot.data!.where((c) =>
              _searchQuery.isEmpty ||
              c.name.toLowerCase().contains(_searchQuery) ||
              c.lecturer.toLowerCase().contains(_searchQuery)).toList();
          courses.sort((a, b) {
            if (_isSortDescending) {
              return b.timestamp.compareTo(a.timestamp);
            } else {
              return a.timestamp.compareTo(b.timestamp);
            }
          });

          if (courses.isEmpty) {
            return Center(
              child: Text(
                'Tidak ada hasil untuk "$_searchQuery"',
                style: TextStyle(color: isDark ? Colors.white70 : Colors.grey),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daftar Mata Kuliah',
                      style: TextStyle(
                        color: isDark ? const Color(0xFF967FE8) : const Color(0xFF5C3EBC),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _isSortDescending ? 'Terbaru' : 'Terlama',
                      style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                    )
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    
                    final date = DateTime.fromMillisecondsSinceEpoch(course.timestamp);
                    final formattedDate = DateFormat('d MMM yyyy • HH:mm').format(date);
                
                    return Card(
                      color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF5C3EBC).withOpacity(0.1),
                          child: const Icon(Icons.school, color: Color(0xFF5C3EBC)),
                        ),
                        title: Text(
                          course.name,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(course.lecturer, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 12, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(formattedDate, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditCourseScreen(course: course))),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteDialog(course),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF5C3EBC),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCourseScreen())),
      ),
    );
  }
}