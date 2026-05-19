import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:matkul/services/firebase_service.dart';
import 'package:matkul/models/note_model.dart';
import 'package:matkul/screens/add_course_screen.dart';
import 'package:matkul/screens/add_note_screen.dart';
import 'package:matkul/screens/edit_note_screen.dart';
import 'package:matkul/screens/manage_courses_screen.dart';
import 'package:matkul/main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String _searchQuery = '';
  bool _isSearching = false;
  final _searchController = TextEditingController();
  bool _isSortDescending = true; 

  static const List<Color> _iconColors = [
    Color(0xFF7B52D3),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFF2196F3),
    Color(0xFFE91E63),
    Color(0xFF00BCD4),
    Color(0xFFFF5722),
  ];

  Color _getIconColor(int index) => _iconColors[index % _iconColors.length];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDeleteDialog(BuildContext context, Note note) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Catatan'),
        content: Text('Yakin ingin menghapus catatan "${note.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _firebaseService.removeNote(note.id!);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Catatan dihapus'), backgroundColor: Color(0xFF5C3EBC)),
              );
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
            ? null
            : IconButton(
                icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: Colors.white),
                onPressed: () {
                  themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
                },
              ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  hintText: 'Cari catatan...',
                  hintStyle: TextStyle(color: Colors.white60),
                  border: InputBorder.none,
                ),
                onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              )
            : const Text('Catatan Kuliah', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          if (!_isSearching)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (val) {
                if (val == 'matkul') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCourseScreen()));
                } else if (val == 'kelola') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageCoursesScreen()));
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'matkul', child: Text('Tambah Mata Kuliah')),
                const PopupMenuItem(value: 'kelola', child: Text('Kelola Mata Kuliah')),
              ],
            ),
        ],
      ),
      body: StreamBuilder<List<Note>>(
        stream: _firebaseService.getNotes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF5C3EBC)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(isDark);
          }

          final notes = snapshot.data!
              .where((n) =>
                  _searchQuery.isEmpty ||
                  n.title.toLowerCase().contains(_searchQuery) ||
                  n.courseName.toLowerCase().contains(_searchQuery) ||
                  n.content.toLowerCase().contains(_searchQuery))
              .toList();
          notes.sort((a, b) {
            if (_isSortDescending) {
              return b.timestamp.compareTo(a.timestamp);
            } else {
              return a.timestamp.compareTo(b.timestamp);
            }
          });

          if (notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text('Tidak ada catatan untuk "$_searchQuery"', style: const TextStyle(color: Colors.grey)),
                ],
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
                      'Daftar Catatan',
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    final date = DateTime.fromMillisecondsSinceEpoch(note.timestamp);
                    final formattedDate = DateFormat('d MMM yyyy • HH:mm').format(date);

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _getIconColor(index),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.menu_book, color: Colors.white, size: 22),
                        ),
                        title: Text(
                          note.courseName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? const Color(0xFF967FE8) : const Color(0xFF5C3EBC),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.title, 
                              style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.black87)
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 12, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(formattedDate, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.grey),
                          onSelected: (val) {
                            if (val == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => EditNoteScreen(note: note)),
                              );
                            } else if (val == 'delete') {
                              _showDeleteDialog(context, note);
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
                            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Colors.red))])),
                          ],
                        ),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                            builder: (_) => _buildNoteDetail(note, formattedDate, _getIconColor(index), isDark),
                          );
                        },
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
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddNoteScreen())),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEDE7FF),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.menu_book, size: 60, color: isDark ? const Color(0xFF967FE8) : const Color(0xFF5C3EBC)),
          ),
          const SizedBox(height: 20),
          Text(
            'Belum ada catatan', 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black54)
          ),
          const SizedBox(height: 8),
          const Text('Tekan + untuk menambah catatan baru', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildNoteDetail(Note note, String formattedDate, Color iconColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: iconColor, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.menu_book, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(note.courseName, style: TextStyle(color: iconColor, fontWeight: FontWeight.bold)),
                    Text(note.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Text(note.content, style: TextStyle(fontSize: 14, height: 1.5, color: isDark ? Colors.white70 : Colors.black87)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(formattedDate, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}