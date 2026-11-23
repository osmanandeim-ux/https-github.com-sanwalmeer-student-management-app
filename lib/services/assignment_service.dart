
import '../database/app_database.dart';

class AssignmentService {
  final AppDatabase _db = AppDatabase.instance;

  Future<List<Map<String, Object?>>> getCourses() async {
    final db = await _db.database;
    return db.query('courses', orderBy: 'title ASC');
  }

  Future<List<Map<String, Object?>>> getAssignments() async {
    final db = await _db.database;

    return db.rawQuery('''
      SELECT
        assignments.id,
        assignments.course_id,
        assignments.title,
        assignments.description,
        assignments.due_date,
        assignments.status,
        courses.course_code,
        courses.title AS course_title
      FROM assignments
      INNER JOIN courses
        ON assignments.course_id = courses.id
      ORDER BY assignments.due_date ASC
    ''');
  }

  Future<int> addAssignment({
    required int courseId,
    required String title,
    required String description,
    required String dueDate,
    required String status,
  }) async {
    return _db.insert('assignments', {
      'course_id': courseId,
      'title': title,
      'description': description,
      'due_date': dueDate,
      'status': status,
    });
  }

  Future<int> updateAssignment({
    required int id,
    required int courseId,
    required String title,
    required String description,
    required String dueDate,
    required String status,
  }) async {
    final db = await _db.database;

    return db.update(
      'assignments',
      {
        'course_id': courseId,
        'title': title,
        'description': description,
        'due_date': dueDate,
        'status': status,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAssignment(int id) async {
    final db = await _db.database;

    return db.delete(
      'assignments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
