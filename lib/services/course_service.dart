
import '../database/app_database.dart';
import 'auth_service.dart';

class CourseService {
  final AppDatabase _db = AppDatabase.instance;
  final AuthService _auth = AuthService();

  Future<int?> get userId => _auth.getCurrentUserId();

  Future<List<Map<String, Object?>>> getCourses() async {
    final id = await userId;
    if (id == null) return [];

    return _db.getAll(
      'courses',
      where: 'user_id = ?',
      whereArgs: [id],
    );
  }

  Future<int> addCourse({
    required String courseCode,
    required String title,
  }) async {
    final id = await userId;
    if (id == null) throw Exception('Please login again.');

    return _db.insert('courses', {
      'user_id': id,
      'course_code': courseCode.trim(),
      'title': title.trim(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<int> updateCourse({
    required int courseId,
    required String courseCode,
    required String title,
  }) async {
    final id = await userId;
    if (id == null) throw Exception('Please login again.');

    final db = await _db.database;
    return db.update(
      'courses',
      {
        'course_code': courseCode.trim(),
        'title': title.trim(),
      },
      where: 'id = ? AND user_id = ?',
      whereArgs: [courseId, id],
    );
  }

  Future<int> deleteCourse(int courseId) async {
    final id = await userId;
    if (id == null) throw Exception('Please login again.');

    final db = await _db.database;
    return db.delete(
      'courses',
      where: 'id = ? AND user_id = ?',
      whereArgs: [courseId, id],
    );
  }
}
