import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AppData {
  static List<Map<String, dynamic>> attendanceLogs = [
    {
      "studentId": "std_8849204",
      "studentName": "Ahmad Muhammad",
      "date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
      "session": "session1",
      "attendanceStatus": "present",
    },
  ];
  static List<Map<String, dynamic>> availableSessions = [
    {
      "id": "1",
      "name": "Session 1 (Sabaq)",
      "startTime": const TimeOfDay(hour: 6, minute: 0),
      "endTime": const TimeOfDay(hour: 9, minute: 0),
    },
    {
      "id": "2",
      "name": "Session 2 (Sabqi)",
      "startTime": const TimeOfDay(hour: 10, minute: 0),
      "endTime": const TimeOfDay(hour: 13, minute: 0),
    },
    {
      "id": "3",
      "name": "Session 3 (Manzil)",
      "startTime": const TimeOfDay(hour: 14, minute: 0),
      "endTime": const TimeOfDay(hour: 17, minute: 0),
    },
  ];
  static List<Map<String, dynamic>> ProgressLogs = [
    {
      "logId": "log_5529104",
      "studentId": "std_8849204",
      "studentName": "Ahmad Muhammad",
      "loggedByTeacherId": "teacher_uid_101",
      "date": "2026-07-16",
      "attendanceStatus": "present",
      "sabaq": {
        "surah": "Al-Baqarah",
        "para": 2,
        "startAyah": 142,
        "endAyah": 150,
        "grade": "Excellent",
      },
      "sabqi": {"para": 1, "pages": "10-15", "grade": "Good"},
      "manzil": {"para": 30, "grade": "Excellent"},
    },
    {
      "logId": "log_5529103",
      "studentId": "std_9920134",
      "studentName": "Hamza Yousaf",
      "loggedByTeacherId": "teacher_uid_101",
      "date": "2026-07-16",
      "attendanceStatus": "absent",
      "sabaq": {
        "surah": "Al-Baqarah",
        "para": 2,
        "startAyah": 142,
        "endAyah": 150,
        "grade": "Excellent",
      },
      "sabqi": {"para": 1, "pages": "10-15", "grade": "Good"},
      "manzil": {"para": 30, "grade": "Excellent"},
    },
    {
      "logId": "log_5529102",
      "studentId": "std_8849204",
      "studentName": "Ahmad Muhammad",
      "loggedByTeacherId": "teacher_uid_101",
      "date": "2026-07-15",
      "attendanceStatus": "present",
      "sabaq": {
        "surah": "Al-Baqarah",
        "para": 2,
        "startAyah": 130,
        "endAyah": 141,
        "grade": "Good",
      },
      "sabqi": {"para": 1, "pages": "5-10", "grade": "Excellent"},
      "manzil": {"para": 29, "grade": "Needs Practice"},
    },
    {
      "logId": "log_5529101",
      "studentId": "std_8849204",
      "studentName": "Ahmad Muhammad",
      "loggedByTeacherId": "teacher_uid_101",
      "date": "2026-07-14",
      "attendanceStatus": "absent",
      "sabaq": null,
      "sabqi": null,
      "manzil": null,
    },
  ];

  static List<Map<String, dynamic>> students = [
    {
      "studentId": "std_8849204",
      "name": "Ahmad Muhammad",
      "teacherId": "teacher_uid_101",
      "parentId": "parent_uid_201",
      "assignedTeacherName": "Qari Sulaiman",
      "assignedParentName": "Muhammad Bilal",
      "createdAt": "2026-07-15T19:23:52Z",
    },
    {
      "studentId": "std_9920134",
      "name": "Hamza Yousaf",
      "teacherId": "Unassigned",
      "parentId": "Unassigned",
      "assignedTeacherName": "Unassigned",
      "assignedParentName": "Unassigned",
      "createdAt": "2026-07-16T10:00:00Z",
    },
  ];
  static List<Map<String, dynamic>> users = [
    {
      "uid": "admin_uid_001",
      "name": "Admin Muhammad",
      "role": "admin",
      "phoneNumber": "03000000001",
      "password": "123456",
      "createdAt": "2026-05-01T10:00:00Z",
    },
    {
      "uid": "teacher_uid_101",
      "name": "Qari Sulaiman",
      "role": "teacher",
      "phoneNumber": "03001111111",
      "password": "123456",
      "createdAt": "2026-05-01T10:15:00Z",
    },
    {
      "uid": "teacher_uid_102",
      "name": "Qari Tariq",
      "role": "teacher",
      "phoneNumber": "03002222222",
      "password": "123456",
      "createdAt": "2026-05-02T11:00:00Z",
    },
    {
      "uid": "parent_uid_201",
      "name": "Muhammad Bilal",
      "role": "parent",
      "phoneNumber": "03001234567", // Linked phone number for WhatsApp
      "password": "123456",
      "createdAt": "2026-05-03T09:30:00Z",
    },
    {
      "uid": "parent_uid_202",
      "name": "Yasir Khan",
      "role": "parent",
      "phoneNumber": "03007654321",
      "password": "123456",
      "createdAt": "2026-05-03T09:45:00Z",
    },
  ];
  //Helper to add a user (teacher/parent)
  static void addUser(
    String uid,
    String name,
    String role,
    String phoneNumber,
    String password,
  ) {
    users.add({
      "uid": uid,
      "name": name,
      "role": role,
      "phoneNumber": phoneNumber,
      "password": password,
      "createdAt": DateTime.now().toIso8601String(),
    });
  }

  // ==========================================
  // 1. USERS COLLECTION (Firestore JSON Schema)
  // ==========================================
  // Maps directly to: FirebaseFirestore.instance.collection('users')
  static List<Map<String, dynamic>> getUsers() {
    return users;
  }

  //Helper For Total Students Count in Dashboard Screen
  static int getTotalStudentsCount() {
    return getStudents().length;
  }

  //Helpet for Total Teachers Count in Dashboard Screen
  static int getTotalTeachersCount() {
    return getUserNamesByRole('teacher').length;
  }

  // Filtered helper for ManageUsersScreen tabs (Column-based format)
  static Map<String, List<String>> getUserNamesByRole(String role) {
    // 1. Filter the list only once for better performance
    final filteredUsers = getUsers()
        .where((user) => user['role'] == role)
        .toList();

    // 2. Return the separated lists
    return {
      'uid': filteredUsers.map((user) => user['uid'] as String).toList(),
      'name': filteredUsers.map((user) => user['name'] as String).toList(),
    };
  }

  // ==========================================
  // 2. STUDENTS COLLECTION (Firestore JSON Schema)
  // ==========================================

  static void addStudent(String studentId, String name) {
    students.add({
      "studentId": DateTime.now().millisecondsSinceEpoch.toString(),
      "name": name,
      "teacherId": "Unassigned",
      "parentId": "Unassigned",
      "assignedTeacherName": "Unassigned",
      "assignedParentName": "Unassigned",
      "createdAt": DateTime.now(),
    });
  }

  static void assignRelations(
    String parent,
    String teacher,
    String parentId,
    String teacherId,
    int index,
  ) {
    students[index]['assignedParentName'] = parent;
    students[index]['assignedTeacherName'] = teacher;
    students[index]['teacherId'] = teacherId;
    students[index]['parentId'] = parentId;
  }

  // Maps directly to: FirebaseFirestore.instance.collection('students')
  static List<Map<String, dynamic>> getStudents() {
    return students;
  }

  // Legacy layout compatibility helper for your existing ManageUsersScreen mapping
  static List<Map<String, dynamic>> getStudentsLegacyFormat() {
    return getStudents().map((student) {
      return {
        "id": student["studentId"],
        "name": student["name"],
        "teacher": student["assignedTeacherName"],
        "parent": student["assignedParentName"],
      };
    }).toList();
  }

  // Helper to fetch associated parent contact details for WhatsApp Integration
  static String getParentPhoneNumber(String parentName) {
    final parent = getUsers().firstWhere(
      (user) => user['role'] == 'parent' && user['name'] == parentName,
      orElse: () => {"phoneNumber": ""},
    );
    return parent['phoneNumber'];
  }

  // ==========================================
  // 3. PROGRESS LOGS COLLECTION (Firestore JSON Schema)
  // ==========================================
  // Maps directly to: FirebaseFirestore.instance.collection('progress_logs')
  static List<Map<String, dynamic>> getProgressLogs() {
    return ProgressLogs.isEmpty
        ? [
            {
              "logId": "log_5529101",
              "studentId": "std_8849204",
              "studentName": "Ahmad Muhammad",
              "loggedByTeacherId": "teacher_uid_101",
              "date": "2026-07-14",
              "attendanceStatus": "absent",
              "sabaq": null,
              "sabqi": null,
              "manzil": null,
            },
          ]
        : ProgressLogs;
  }

  static void addProgressLog(Map<String, dynamic> log) {
    ProgressLogs.add(log);
  }

  //helper to get total presents of today from Progress Logs
  static int gettotalAttendanceCount(String date, String status) {
    return attendanceLogs
        .where(
          (log) => log['date'] == date && log['attendanceStatus'] == status,
        )
        .length;
  }

  static int getTotalAttendanceCountForSession(
    String date,
    String status,
    String session,
  ) {
    return attendanceLogs
        .where(
          (log) =>
              log['date'] == date &&
              log['attendanceStatus'] == status &&
              log['session'] == session,
        )
        .length;
  }

  // Formats data filtering specifically for the StudentHistoryScreen compatibility layout
  static List<Map<String, dynamic>> getHistoryLogsForStudent(String studentId) {
    return getProgressLogs()
        .where((log) => log['studentId'] == studentId)
        .map(
          (log) => {
            "date": log["date"],
            "attendance": log["attendanceStatus"],
            "sabaq": log["sabaq"],
            "sabqi": log["sabqi"],
            "manzil": log["manzil"],
          },
        )
        .toList();
  }

  // ==========================================
  // 4. SESSIONS COLLECTION & EXAMS COLLECTION
  // ==========================================
  // For manage_sessions_screen.dart & exam_management_screen.dart

  static List<Map<String, dynamic>> getSessions() {
    return [
      {"sessionId": "sess_01", "name": "Term 1 - 2026", "isActive": true},
      {"sessionId": "sess_02", "name": "Term 2 - 2026", "isActive": false},
    ];
  }

  static List<Map<String, dynamic>> getExamResults() {
    return [
      {
        "examId": "exam_01",
        "studentId": "std_8849204",
        "studentName": "Ahmad Muhammad",
        "sessionName": "Term 1 - 2026",
        "hifzScore": "94/100",
        "tajweedGrade": "A",
        "status": "Published",
      },
    ];
  }
  // ==========================================
  // ADD THIS INSIDE YOUR EXISTING APPDATA CLASS
  // ==========================================

  // Returns overall monthly summary analytics for a student
  static Map<String, dynamic> getStudentAnalytics(String studentId) {
    return {
      "totalNewPages": 14,
      "hifzProgressPercent": 0.45,
      "attendanceRate": "92%",
      "totalClasses": 120,
      "totalPresents": 110,
      "totalAbsents": 10,
    };
  }

  // Returns a raw matrix map representing the day-by-day attendance status for the month grid
  static List<String> getMonthlyCalendarAttendance(String studentId) {
    return List.generate(30, (index) {
      if (index == 13 || index == 27) return "absent";
      if (index >= 16) return "unlogged";
      return "present";
    });
  }

  //adding attendance log
  static void addAttendanceLog(
    String studentId,
    String studentName,
    String session,
    String status,
  ) {
    attendanceLogs.add({
      "studentId": studentId,
      "studentName": studentName,
      "date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
      "session": session,
      "attendanceStatus": status,
    });
  }

  static List<String> getAvailableSessionsNames() {
    return availableSessions
        .map((session) => session["name"] as String)
        .toList();
  }

  static void addNewSession(Map<String, dynamic> session) {
    availableSessions.add(session);
  }

  static void updateSession(int index, Map<String, dynamic> session) {
    availableSessions[index] = session;
  }

  static List<Map<String, dynamic>> getAvailableSessions() {
    return availableSessions;
  }
}
