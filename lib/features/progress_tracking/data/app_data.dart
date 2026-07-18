class AppData {
  // ==========================================
  // 1. USERS COLLECTION (Firestore JSON Schema)
  // ==========================================
  // Maps directly to: FirebaseFirestore.instance.collection('users')
  static List<Map<String, dynamic>> getUsers() {
    return [
      {
        "uid": "admin_uid_001",
        "name": "Admin Muhammad",
        "role": "admin",
        "phoneNumber": "03000000001",
        "createdAt": "2026-05-01T10:00:00Z",
      },
      {
        "uid": "teacher_uid_101",
        "name": "Qari Sulaiman",
        "role": "teacher",
        "phoneNumber": "03001111111",
        "createdAt": "2026-05-01T10:15:00Z",
      },
      {
        "uid": "teacher_uid_102",
        "name": "Qari Tariq",
        "role": "teacher",
        "phoneNumber": "03002222222",
        "createdAt": "2026-05-02T11:00:00Z",
      },
      {
        "uid": "parent_uid_201",
        "name": "Muhammad Bilal",
        "role": "parent",
        "phoneNumber": "03001234567", // Linked phone number for WhatsApp
        "createdAt": "2026-05-03T09:30:00Z",
      },
      {
        "uid": "parent_uid_202",
        "name": "Yasir Khan",
        "role": "parent",
        "phoneNumber": "03007654321",
        "createdAt": "2026-05-03T09:45:00Z",
      },
    ];
  }

  // Filtered helper for ManageUsersScreen tabs
  static List<String> getUserNamesByRole(String role) {
    return getUsers()
        .where((user) => user['role'] == role)
        .map((user) => user['name'] as String)
        .toList();
  }

  // ==========================================
  // 2. STUDENTS COLLECTION (Firestore JSON Schema)
  // ==========================================
  // Maps directly to: FirebaseFirestore.instance.collection('students')
  static List<Map<String, dynamic>> getStudents() {
    return [
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
    return [
      {
        "logId": "log_5529103",
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
}
