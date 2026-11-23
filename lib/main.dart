
import 'package:material_ui/material_ui.dart';
import 'services/auth_service.dart';
import 'services/course_service.dart';
import 'services/attendance_service.dart';
import 'services/assignment_service.dart';
void main() {
  runApp(const StudentManagementApp());
}

// --------------------------------------------------
// MAIN APP
// --------------------------------------------------

class StudentManagementApp extends StatelessWidget {
  const StudentManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Management',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3157D5),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        fontFamily: 'Roboto',
      ),
      home: const AuthGate(),
    );
  }
}

// --------------------------------------------------
// AUTH GATE - CHECK LOGIN SESSION
// --------------------------------------------------

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService auth = AuthService();

  bool loading = true;
  bool loggedIn = false;

  @override
  void initState() {
    super.initState();
    checkSession();
  }

  Future<void> checkSession() async {
    final userId = await auth.getCurrentUserId();

    if (!mounted) return;

    setState(() {
      loggedIn = userId != null;
      loading = false;
    });
  }

  void onAuthenticated() {
    setState(() {
      loggedIn = true;
    });
  }

  Future<void> logout() async {
    await auth.logout();

    if (!mounted) return;

    setState(() {
      loggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (loggedIn) {
      return MainScreen(onLogout: logout);
    }

    return LoginScreen(
      auth: auth,
      onAuthenticated: onAuthenticated,
    );
  }
}

// --------------------------------------------------
// LOGIN AND REGISTER SCREEN
// --------------------------------------------------

class LoginScreen extends StatefulWidget {
  final AuthService auth;
  final VoidCallback onAuthenticated;

  const LoginScreen({
    super.key,
    required this.auth,
    required this.onAuthenticated,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool registerMode = false;
  bool busy = false;
  bool hidePassword = true;
  String? errorMessage;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    setState(() {
      busy = true;
      errorMessage = null;
    });

    String? error;

    if (registerMode) {
      error = await widget.auth.register(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
      );
    } else {
      error = await widget.auth.login(
        email: emailController.text,
        password: passwordController.text,
      );
    }

    if (!mounted) return;

    setState(() {
      busy = false;
      errorMessage = error;
    });

    if (error == null) {
      widget.onAuthenticated();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 0,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.school,
                      size: 60,
                      color: Color(0xFF3157D5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      registerMode
                          ? 'Create Account'
                          : 'Welcome Back',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      registerMode
                          ? 'Register to manage your academic records'
                          : 'Login to your student account',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 28),

                    if (registerMode) ...[
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: passwordController,
                      obscureText: hidePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              hidePassword = !hidePassword;
                            });
                          },
                          icon: Icon(
                            hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),

                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],

                    const SizedBox(height: 22),

                    ElevatedButton(
                      onPressed: busy ? null : submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3157D5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                      child: busy
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              registerMode ? 'Create Account' : 'Login',
                            ),
                    ),

                    const SizedBox(height: 12),

                    TextButton(
                      onPressed: busy
                          ? null
                          : () {
                              setState(() {
                                registerMode = !registerMode;
                                errorMessage = null;
                              });
                            },
                      child: Text(
                        registerMode
                            ? 'Already have an account? Login'
                            : 'New student? Create an account',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------
// MAIN NAVIGATION
// --------------------------------------------------

class MainScreen extends StatefulWidget {
  final Future<void> Function() onLogout;

  const MainScreen({
    super.key,
    required this.onLogout,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  final GlobalKey<DashboardScreenState> dashboardKey =
      GlobalKey<DashboardScreenState>();

  List<Widget> get pages => [
        DashboardScreen(key: dashboardKey),
        const CoursesScreen(),
        const AttendanceScreen(),
        const AssignmentsScreen(),
        ProfileScreen(onLogout: widget.onLogout),
      ];

  final List<String> titles = [
    'Dashboard',
    'My Courses',
    'Attendance',
    'Assignments',
    'My Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);

          if (index == 0) {
            dashboardKey.currentState?.refreshDashboard();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Courses',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check),
            label: 'Attendance',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}


// --------------------------------------------------
// DASHBOARD
// --------------------------------------------------

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final CourseService _courseService = CourseService();
  final AttendanceService _attendanceService = AttendanceService();
  final AssignmentService _assignmentService = AssignmentService();

  int totalCourses = 0;
  int totalAssignments = 0;
  int pendingAssignments = 0;
  double attendancePercentage = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final courses = await _courseService.getCourses();
      final attendance = await _attendanceService.getAttendance();
      final assignments = await _assignmentService.getAssignments();

      // Only count records belonging to the logged-in user's courses.
      final courseIds = courses
          .map((course) => course['id'] as int)
          .toSet();

      final userAttendance = attendance.where(
        (record) => courseIds.contains(record['course_id']),
      ).toList();

      final userAssignments = assignments.where(
        (record) => courseIds.contains(record['course_id']),
      ).toList();

      final presentCount = userAttendance.where(
        (record) =>
            record['status'] == 'Present' ||
            record['status'] == 'Late',
      ).length;

      final attendanceRate = userAttendance.isEmpty
          ? 0.0
          : (presentCount / userAttendance.length) * 100;

      if (!mounted) return;

      setState(() {
        totalCourses = courses.length;
        totalAssignments = userAssignments.length;
        pendingAssignments = userAssignments.where(
          (assignment) => assignment['status'] == 'Pending',
        ).length;
        attendancePercentage = attendanceRate;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not load dashboard data.'),
        ),
      );
    }
  }

  Future<void> refreshDashboard() async {
  await _loadDashboard();
}

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Hello, Student 👋',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Welcome to your academic dashboard.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF3157D5),
                  Color(0xFF6685EE),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR ACADEMIC OVERVIEW',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Stay organised.\nAchieve more.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Quick Overview',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Courses',
                    value: '$totalCourses',
                    icon: Icons.menu_book,
                    color: const Color(0xFF3157D5),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Attendance',
                    value: '${attendancePercentage.toStringAsFixed(0)}%',
                    icon: Icons.fact_check,
                    color: const Color(0xFF169B72),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Assignments',
                    value: '$totalAssignments',
                    icon: Icons.assignment,
                    color: const Color(0xFFE58A28),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Pending',
                    value: '$pendingAssignments',
                    icon: Icons.pending_actions,
                    color: const Color(0xFF9B59B6),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          Text(
            'Pull down to refresh your dashboard.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// REUSABLE STAT CARD
// --------------------------------------------------

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 13),
          Text(
            value,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(title, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// SCHEDULE TILE
// --------------------------------------------------

class ScheduleTile extends StatelessWidget {
  final String time;
  final String subject;
  final String room;

  const ScheduleTile({
    super.key,
    required this.time,
    required this.subject,
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      child: ListTile(
        leading: const Icon(
          Icons.calendar_today,
          color: Color(0xFF3157D5),
        ),
        title: Text(
          subject,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('$time • $room'),
      ),
    );
  }
}

// --------------------------------------------------
// COURSES
// --------------------------------------------------

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final CourseService service = CourseService();

  List<Map<String, Object?>> courses = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadCourses();
  }

  Future<void> loadCourses() async {
    try {
      final result = await service.getCourses();

      if (!mounted) return;

      setState(() {
        courses = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      showMessage('Could not load courses.');
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

Future<Map<String, String>?> showCourseDialog({
  Map<String, Object?>? course,
}) {
  return showDialog<Map<String, String>>(
    context: context,
    builder: (dialogContext) => CourseFormDialog(
      initialCode: course?['course_code']?.toString() ?? '',
      initialTitle: course?['title']?.toString() ?? '',
      isEditing: course != null,
    ),
  );
}
  Future<void> addCourse() async {
    final data = await showCourseDialog();

    if (data == null) return;

    try {
      await service.addCourse(
        courseCode: data['code']!,
        title: data['title']!,
      );

      await loadCourses();
      showMessage('Course added successfully.');
    } catch (e) {
      showMessage('Could not add course.');
    }
  }

  Future<void> editCourse(Map<String, Object?> course) async {
    final data = await showCourseDialog(course: course);

    if (data == null) return;

    try {
      await service.updateCourse(
        courseId: course['id'] as int,
        courseCode: data['code']!,
        title: data['title']!,
      );

      await loadCourses();
      showMessage('Course updated successfully.');
    } catch (e) {
      showMessage('Could not update course.');
    }
  }

  Future<void> deleteCourse(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Course'),
        content: const Text(
          'Are you sure you want to delete this course?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await service.deleteCourse(id);
      await loadCourses();
      showMessage('Course deleted successfully.');
    } catch (e) {
      showMessage('Could not delete course.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addCourse,
        icon: const Icon(Icons.add),
        label: const Text('Add Course'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : courses.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.menu_book_outlined,
                        size: 60,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 12),
                      Text('No courses added yet.'),
                      Text('Tap Add Course to get started.'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];

                    return Card(
                      color: Colors.white,
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE8EDFF),
                          child: Icon(
                            Icons.menu_book,
                            color: Color(0xFF3157D5),
                          ),
                        ),
                        title: Text(
                          course['title'].toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          course['course_code'].toString(),
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              editCourse(course);
                            } else if (value == 'delete') {
                              deleteCourse(course['id'] as int);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}


// --------------------------------------------------
// ATTENDANCE
// --------------------------------------------------

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final AttendanceService service = AttendanceService();

  List<Map<String, Object?>> courses = [];
  List<Map<String, Object?>> records = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final courseList = await service.getCourses();
      final attendanceList = await service.getAttendance();

      if (!mounted) return;

      setState(() {
        courses = courseList;
        records = attendanceList;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      showMessage('Could not load attendance.');
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> showAttendanceDialog({
    Map<String, Object?>? record,
  }) async {
    if (courses.isEmpty) {
      showMessage('Please add a course first.');
      return;
    }

    int selectedCourse = record == null
        ? courses.first['id'] as int
        : record['course_id'] as int;

    String selectedStatus =
        record?['status']?.toString() ?? 'Present';

    DateTime selectedDate = record == null
        ? DateTime.now()
        : DateTime.tryParse(record['date'].toString()) ??
            DateTime.now();

    final result = await showDialog<Map<String, Object?>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(record == null
              ? 'Mark Attendance'
              : 'Edit Attendance'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: selectedCourse,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Select Course',
                  ),
                  items: courses.map((course) {
                    return DropdownMenuItem<int>(
                      value: course['id'] as int,
                      child: Text(course['course_code'].toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedCourse = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Attendance Status',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Present',
                      child: Text('Present'),
                    ),
                    DropdownMenuItem(
                      value: 'Absent',
                      child: Text('Absent'),
                    ),
                    DropdownMenuItem(
                      value: 'Late',
                      child: Text('Late'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedStatus = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Attendance Date'),
                  subtitle: Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  ),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: dialogContext,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );

                    if (picked != null) {
                      setDialogState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, {
                  'course_id': selectedCourse,
                  'status': selectedStatus,
                  'date':
                      '${selectedDate.year.toString().padLeft(4, '0')}-'
                      '${selectedDate.month.toString().padLeft(2, '0')}-'
                      '${selectedDate.day.toString().padLeft(2, '0')}',
                });
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result == null) return;

    try {
      if (record == null) {
        await service.addAttendance(
          courseId: result['course_id'] as int,
          date: result['date'] as String,
          status: result['status'] as String,
        );
      } else {
        await service.updateAttendance(
          id: record['id'] as int,
          courseId: result['course_id'] as int,
          date: result['date'] as String,
          status: result['status'] as String,
        );
      }

      await loadData();
      showMessage('Attendance saved successfully.');
    } catch (e) {
      showMessage('Could not save attendance.');
    }
  }

  Future<void> deleteRecord(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Attendance'),
        content: const Text('Delete this attendance record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await service.deleteAttendance(id);
      await loadData();
      showMessage('Attendance deleted.');
    } catch (e) {
      showMessage('Could not delete attendance.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAttendanceDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Mark Attendance'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : records.isEmpty
              ? const Center(
                  child: Text('No attendance records yet.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    final status = record['status'].toString();

                    return Card(
                      color: Colors.white,
                      child: ListTile(
                        leading: Icon(
                          Icons.fact_check,
                          color: status == 'Present'
                              ? Colors.green
                              : status == 'Absent'
                                  ? Colors.red
                                  : Colors.orange,
                        ),
                        title: Text(
                          record['course_title'].toString(),
                        ),
                        subtitle: Text(
                          '${record['course_code']} • '
                          '${record['date']} • $status',
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              showAttendanceDialog(record: record);
                            } else if (value == 'delete') {
                              deleteRecord(record['id'] as int);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// --------------------------------------------------
// ATTENDANCE TILE
// --------------------------------------------------

class AttendanceTile extends StatelessWidget {
  final String course;
  final String value;

  const AttendanceTile({
    super.key,
    required this.course,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      child: ListTile(
        title: Text(course),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF169B72),
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------
// ASSIGNMENTS
// --------------------------------------------------

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  final AssignmentService _service = AssignmentService();

  List<Map<String, Object?>> _assignments = [];
  List<Map<String, Object?>> _courses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final courses = await _service.getCourses();
      final assignments = await _service.getAssignments();

      if (!mounted) return;

      setState(() {
        _courses = courses;
        _assignments = assignments;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showMessage('Could not load assignments.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _showForm({
    Map<String, Object?>? assignment,
  }) async {
    if (_courses.isEmpty) {
      _showMessage('Please add a course first.');
      return;
    }

    final result = await showDialog<Map<String, Object?>>(
      context: context,
      builder: (_) => AssignmentFormDialog(
        courses: _courses,
        initialData: assignment,
      ),
    );

    if (result == null) return;

    try {
      if (assignment == null) {
        await _service.addAssignment(
          courseId: result['course_id'] as int,
          title: result['title'] as String,
          description: result['description'] as String,
          dueDate: result['due_date'] as String,
          status: result['status'] as String,
        );
        _showMessage('Assignment added successfully.');
      } else {
        await _service.updateAssignment(
          id: assignment['id'] as int,
          courseId: result['course_id'] as int,
          title: result['title'] as String,
          description: result['description'] as String,
          dueDate: result['due_date'] as String,
          status: result['status'] as String,
        );
        _showMessage('Assignment updated successfully.');
      }

      await _loadData();
    } catch (e) {
      _showMessage('Could not save assignment.');
    }
  }

  Future<void> _deleteAssignment(
    Map<String, Object?> assignment,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Assignment'),
        content: const Text(
          'Are you sure you want to delete this assignment?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _service.deleteAssignment(assignment['id'] as int);
      await _loadData();
      _showMessage('Assignment deleted successfully.');
    } catch (e) {
      _showMessage('Could not delete assignment.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _courses.isEmpty
              ? const Center(
                  child: Text('Add a course before creating assignments.'),
                )
              : _assignments.isEmpty
                  ? const Center(
                      child: Text('No assignments yet. Tap + to add one.'),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        const SectionHeader(title: 'My Assignments'),
                        const SizedBox(height: 12),
                        ..._assignments.map((assignment) {
                          final status =
                              assignment['status'] as String;
                          final dueDate =
                              assignment['due_date'] as String;

                          return Card(
                            color: Colors.white,
                            elevation: 0,
                            child: ListTile(
                              leading: const Icon(
                                Icons.assignment_outlined,
                                color: Color(0xFF3157D5),
                              ),
                              title: Text(
                                assignment['title'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                '${assignment['course_code']} • Due: $dueDate\n$status',
                              ),
                              isThreeLine: true,
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showForm(assignment: assignment);
                                  } else if (value == 'delete') {
                                    _deleteAssignment(assignment);
                                  }
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit'),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
    );
  }
}

class AssignmentFormDialog extends StatefulWidget {
  final List<Map<String, Object?>> courses;
  final Map<String, Object?>? initialData;

  const AssignmentFormDialog({
    super.key,
    required this.courses,
    this.initialData,
  });

  @override
  State<AssignmentFormDialog> createState() =>
      _AssignmentFormDialogState();
}

class _AssignmentFormDialogState extends State<AssignmentFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  int? _courseId;
  String _status = 'Pending';
  late DateTime _dueDate;

  bool get _isEditing => widget.initialData != null;

  @override
  void initState() {
    super.initState();

    final data = widget.initialData;

    _titleController = TextEditingController(
      text: data?['title'] as String? ?? '',
    );

    _descriptionController = TextEditingController(
      text: data?['description'] as String? ?? '',
    );

    _courseId = data?['course_id'] as int? ??
        widget.courses.first['id'] as int;

    _status = data?['status'] as String? ?? 'Pending';

    _dueDate = DateTime.tryParse(
          data?['due_date'] as String? ?? '',
        ) ??
        DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (selected != null) {
      setState(() => _dueDate = selected);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final date =
        '${_dueDate.year.toString().padLeft(4, '0')}-'
        '${_dueDate.month.toString().padLeft(2, '0')}-'
        '${_dueDate.day.toString().padLeft(2, '0')}';

    Navigator.pop(context, {
      'course_id': _courseId!,
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'due_date': date,
      'status': _status,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Assignment' : 'Add Assignment'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Assignment Title',
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Enter assignment title'
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _courseId,
                decoration: const InputDecoration(
                  labelText: 'Course',
                ),
                items: widget.courses.map((course) {
                  return DropdownMenuItem<int>(
                    value: course['id'] as int,
                    child: Text(
                      '${course['course_code']} - ${course['title']}',
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _courseId = value);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Pending',
                    child: Text('Pending'),
                  ),
                  DropdownMenuItem(
                    value: 'In Progress',
                    child: Text('In Progress'),
                  ),
                  DropdownMenuItem(
                    value: 'Completed',
                    child: Text('Completed'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _status = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Due Date'),
                subtitle: Text(
                  '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: _pickDate,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}


// --------------------------------------------------
// PROFILE AND LOGOUT
// --------------------------------------------------

class ProfileScreen extends StatelessWidget {
  final Future<void> Function() onLogout;

  const ProfileScreen({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 20),
        const CircleAvatar(
          radius: 48,
          backgroundColor: Color(0xFFE8EDFF),
          child: Icon(
            Icons.person,
            size: 55,
            color: Color(0xFF3157D5),
          ),
        ),
        const SizedBox(height: 15),
        const Center(
          child: Text(
            'Student Account',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 25),
        const ProfileTile(
          icon: Icons.school,
          title: 'Degree',
          value: 'Computer Science',
        ),
        const ProfileTile(
          icon: Icons.badge,
          title: 'Student ID',
          value: 'STU-2026-001',
        ),
        const ProfileTile(
          icon: Icons.calendar_month,
          title: 'Semester',
          value: 'Semester 5',
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () async {
            await onLogout();
          },
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(15),
          ),
        ),
      ],
    );
  }
}

// --------------------------------------------------
// PROFILE TILE
// --------------------------------------------------

class ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const ProfileTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      child: ListTile(
        leading: Icon(
          icon,
          color: const Color(0xFF3157D5),
        ),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}

// --------------------------------------------------
// SECTION HEADER
// --------------------------------------------------

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}


class CourseFormDialog extends StatefulWidget {
  final String initialCode;
  final String initialTitle;
  final bool isEditing;

  const CourseFormDialog({
    super.key,
    required this.initialCode,
    required this.initialTitle,
    required this.isEditing,
  });

  @override
  State<CourseFormDialog> createState() => _CourseFormDialogState();
}

class _CourseFormDialogState extends State<CourseFormDialog> {
  late final TextEditingController codeController;
  late final TextEditingController titleController;

  @override
  void initState() {
    super.initState();
    codeController = TextEditingController(text: widget.initialCode);
    titleController = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    codeController.dispose();
    titleController.dispose();
    super.dispose();
  }

  void saveCourse() {
    final code = codeController.text.trim();
    final title = titleController.text.trim();

    if (code.isEmpty || title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both course code and title.'),
        ),
      );
      return;
    }

    Navigator.pop(context, {
      'code': code,
      'title': title,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEditing ? 'Edit Course' : 'Add Course'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Course Code',
                hintText: 'e.g. CS32005',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Course Title',
                hintText: 'e.g. Mobile Application Development',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: saveCourse,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
