# Student Management App — Project Plan

## 1. Problem
Students need one simple mobile application to manage their
courses, attendance, assignments and academic profile.

## 2. Target User
A university student managing their own academic information.

## 3. Main Features
- Student registration and login
- Dashboard with academic summary
- Course management (add, view, edit, delete)
- Attendance recording and history
- Assignment management and due dates
- Student profile management
- Weather information through a public API

## 4. Technology
- Flutter and Dart
- SQLite for local database storage
- Public weather API for dashboard information
- VS Code for development
- Git for version control

## 5. Database Design

### Users
id, name, email, password_hash, created_at

### Courses
id, user_id, course_code, title, created_at

### Attendance
id, course_id, date, status

### Assignments
id, course_id, title, description, due_date, status

Relationships:
- One user can have multiple courses.
- One course can have multiple attendance records.
- One course can have multiple assignments.

## 6. User Flow
Launch App
  -> Login / Register
  -> Dashboard
  -> Courses
  -> Attendance
  -> Assignments
  -> Profile

## 7. Security and Accessibility
- Validate user inputs.
- Hash passwords instead of storing plaintext.
- Keep student records locally on the device.
- Use readable text, suitable colour contrast and accessible labels.
- Request only permissions actually needed.

## 8. Testing Plan
- Test registration and login.
- Test course creation and editing.
- Test attendance recording.
- Test assignment creation and completion.
- Verify records remain after restarting the app.
- Test invalid inputs and API failure handling.

## 9. Future Improvements
- Cloud synchronisation
- Push notifications for assignment deadlines
- University timetable integration
