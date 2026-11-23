
import '../database/app_database.dart';

class AttendanceService {
  final AppDatabase _db = AppDatabase.instance;

  Future<List<Map<String, Object?>>> getCourses() async {
    final db = await _db.database;
    return db.query('courses', orderBy: 'title ASC');
  }

  Future<List<Map<String, Object?>>> getAttendance() async {
    final db = await _db.database;

    return db.rawQuery('''
      SELECT
        attendance.id,
        attendance.course_id,
        attendance.date,
        attendance.status,
        courses.course_code,
        courses.title AS course_title
      FROM attendance
      INNER JOIN courses
        ON attendance.course_id = courses.id
      ORDER BY attendance.date DESC
    ''');
  }

  Future<int> addAttendance({
    required int courseId,
    required String date,
    required String status,
  }) async {
    return _db.insert('attendance', {
      'course_id': courseId,
      'date': date,
      'status': status,
    });
  }

  Future<int> updateAttendance({
    required int id,
    required int courseId,
    required String date,
    required String status,
  }) async {
    final db = await _db.database;

    return db.update(
      'attendance',
      {
        'course_id': courseId,
        'date': date,
        'status': status,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAttendance(int id) async {
    final db = await _db.database;

    return db.delete(
      'attendance',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
