import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppData {
  // Flag to simulate offline mode for testing/future connectivity check
  static bool isOffline = false;

  // Keys for SharedPreferences
  static const String _keyStudents = "cached_students";
  static const String _keySessions = "cached_sessions";
  static const String _keyProgressLogs = "cached_progress_logs";
  static const String _keyUsers = "cached_users";

  // Existing Mock Memory Data
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
        "lines": 17,
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
        "lines": 17,
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
        "lines": 17,
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
      "teacherId": "teacher_uid_101",
      "parentId": "parent_uid_202",
      "assignedTeacherName": "Qari Sulaiman",
      "assignedParentName": "Yasir Khan",
      "createdAt": "2026-07-16T10:00:00Z",
    },
  ];

  static List<Map<String, dynamic>> users = [
    {
      "uid": "admin_uid_001",
      "name": "Admin Muhammad",
      "role": "admin",
      "phoneNumber": "03000000001",
      "password": "password",
      "createdAt": "2026-05-01T10:00:00Z",
    },
    {
      "uid": "teacher_uid_101",
      "name": "Qari Sulaiman",
      "role": "teacher",
      "phoneNumber": "03111111111",
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
      "phoneNumber": "03001234567",
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

  // ==========================================
  // SHARED PREFERENCES HELPER METHODS
  // ==========================================

  static Future<void> _saveToPrefs(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(data));
  }

  static Future<List<Map<String, dynamic>>?> _getFromPrefs(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString != null && jsonString.isNotEmpty) {
      final List decoded = jsonDecode(jsonString);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return null;
  }

  // CALL THIS FUNCTION ON USER LOGOUT
  static Future<void> clearLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyStudents);
    await prefs.remove(_keySessions);
    await prefs.remove(_keyProgressLogs);
    await prefs.remove(_keyUsers);
  }

  // ==========================================
  // 1. TEACHER STUDENTS WITH OFFLINE SUPPORT
  // ==========================================
  static Future<List<Map<String, dynamic>>> getTeacherStudents(
    String teacherId,
  ) async {
    if (isOffline) {
      final cached = await _getFromPrefs(_keyStudents);
      if (cached != null) {
        return cached
            .where((student) => student["teacherId"] == teacherId)
            .toList();
      }
    }

    // ONLINE FLOW: (Future Firebase query will go here)
    final freshData = students
        .where((student) => student["teacherId"] == teacherId)
        .toList();

    // Cache updated list locally
    await _saveToPrefs(_keyStudents, students);
    return freshData;
  }

  // ==========================================
  // 2. SESSIONS WITH OFFLINE SUPPORT & TIMEOFDAY ENCODING
  // ==========================================
  static Future<List<Map<String, dynamic>>> getAvailableSessions() async {
    if (isOffline) {
      final cached = await _getFromPrefs(_keySessions);
      if (cached != null) {
        // Convert stored hour & minute back to TimeOfDay objects
        return cached.map((s) {
          return {
            "id": s["id"],
            "name": s["name"],
            "startTime": TimeOfDay(
              hour: s["startHour"] ?? 8,
              minute: s["startMinute"] ?? 0,
            ),
            "endTime": TimeOfDay(
              hour: s["endHour"] ?? 10,
              minute: s["endMinute"] ?? 0,
            ),
          };
        }).toList();
      }
    }

    // ONLINE FLOW: (Future Firebase query will go here)
    final freshSessions = List<Map<String, dynamic>>.from(availableSessions);

    // Encode TimeOfDay objects into primitive JSON fields for local saving
    final encodableSessions = availableSessions.map((s) {
      final start = s["startTime"] as TimeOfDay?;
      final end = s["endTime"] as TimeOfDay?;
      return {
        "id": s["id"],
        "name": s["name"],
        "startHour": start?.hour,
        "startMinute": start?.minute,
        "endHour": end?.hour,
        "endMinute": end?.minute,
      };
    }).toList();

    await _saveToPrefs(_keySessions, encodableSessions);
    return freshSessions;
  }

  // ==========================================
  // 3. PROGRESS LOGS WITH OFFLINE SUPPORT
  // ==========================================
  static Future<List<Map<String, dynamic>>> getProgressLogsAsync() async {
    if (isOffline) {
      final cached = await _getFromPrefs(_keyProgressLogs);
      if (cached != null) return cached;
    }

    // ONLINE FLOW: (Future Firebase query will go here)
    final freshLogs = getProgressLogs();
    await _saveToPrefs(_keyProgressLogs, freshLogs);
    return freshLogs;
  }

  // ==========================================
  // EXISTING SYNCHRONOUS HELPERS & MUTATIONS
  // ==========================================

  static List<Map<String, dynamic>> getUsers() => users;
  static List<Map<String, dynamic>> getStudents() => students;

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
    _saveToPrefs(_keyUsers, users);
  }

  static int getTotalStudentsCount() => getStudents().length;
  static int getTotalTeachersCount() => getUserNamesByRole('teacher').length;

  static Map<String, List<String>> getUserNamesByRole(String role) {
    final filteredUsers = getUsers()
        .where((user) => user['role'] == role)
        .toList();
    return {
      'uid': filteredUsers.map((user) => user['uid'] as String).toList(),
      'name': filteredUsers.map((user) => user['name'] as String).toList(),
    };
  }

  static void addStudent(String studentId, String name) {
    students.add({
      "studentId": DateTime.now().millisecondsSinceEpoch.toString(),
      "name": name,
      "teacherId": "Unassigned",
      "parentId": "Unassigned",
      "assignedTeacherName": "Unassigned",
      "assignedParentName": "Unassigned",
      "createdAt": DateTime.now().toIso8601String(),
    });
    _saveToPrefs(_keyStudents, students);
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
    _saveToPrefs(_keyStudents, students);
  }

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

  static String getParentPhoneNumber(String parentName) {
    final parent = getUsers().firstWhere(
      (user) => user['role'] == 'parent' && user['name'] == parentName,
      orElse: () => {"phoneNumber": ""},
    );
    return parent['phoneNumber'];
  }

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

  static int gettotalAttendanceCount(String date, String status) {
    return attendanceLogs
        .where(
          (log) =>
              log['date'] == date &&
              log['attendanceStatus'].toString().toLowerCase() ==
                  status.toLowerCase(),
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
              log['attendanceStatus'].toString().toLowerCase() ==
                  status.toLowerCase() &&
              log['session'] == session,
        )
        .length;
  }

  static Map<String, dynamic> getAttendanceStatusForSession(
    String session,
    String studentId,
    String date,
  ) {
    return attendanceLogs
            .where(
              (log) =>
                  log['studentId'] == studentId &&
                  log['session'] == session &&
                  log['date'] == date,
            )
            .map((log) => {"attendanceStatus": log["attendanceStatus"]})
            .firstOrNull ??
        {"attendanceStatus": "Pending"};
  }

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

  static List<String> getMonthlyCalendarAttendance(String studentId) {
    return List.generate(30, (index) {
      if (index == 13 || index == 27) return "absent";
      if (index >= 16) return "unlogged";
      return "present";
    });
  }

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
    getAvailableSessions(); // Re-caches updated list
  }

  static void updateSession(int index, Map<String, dynamic> session) {
    availableSessions[index] = session;
    getAvailableSessions(); // Re-caches updated list
  }

  static Future<void> addProgressLog(
    String studentId,
    String studentName,
    String surah,
    String para,
    String lines,
    String sabqi,
    String manzil,
    String remarks,
  ) async {
    ProgressLogs.add({
      "logId": DateTime.now().millisecondsSinceEpoch.toString(),
      "studentId": studentId,
      "studentName": studentName,
      "date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
      "attendanceStatus": "present",
      "sabaq": {"surah": surah, "para": para, "lines": lines},
      "sabqi": sabqi,
      "manzil": manzil,
      "grade": remarks,
    });
    _saveToPrefs(_keyProgressLogs, ProgressLogs);
  }

  static String validateLoginUser(String uname, String password) {
    Map<String, dynamic>? u = users
        .where((user) => user['phoneNumber'] == uname)
        .firstOrNull;
    if (u == null) {
      return "E:No User Found";
    }
    if (password != u['password']) {
      return "E:Incorrect Password";
    }
    return "T:${u['uid']}";
  }

  static void addSession(Map<String, dynamic> session) {
    availableSessions.add(session);
    getAvailableSessions();
  }

  static void updateSessionById(
    String id,
    Map<String, dynamic> updatedSession,
  ) {
    final index = availableSessions.indexWhere((s) => s['id'] == id);
    if (index != -1) {
      availableSessions[index] = updatedSession;
      getAvailableSessions();
    }
  }

  static void deleteSessionById(String id) {
    availableSessions.removeWhere((s) => s['id'] == id);
    getAvailableSessions();
  }

  static Future<List<Map<String, dynamic>>> getDirectoryStudents() async {
    // Simulating async fetch delay from AppData
    await Future.delayed(const Duration(milliseconds: 200));

    return AppData.students.map((student) {
      // 1. Resolve Parent details from AppData.users
      final parentUser = AppData.users.firstWhere(
        (user) => user['uid'] == student['parentId'],
        orElse: () => {},
      );

      // 2. Fetch latest ProgressLog for this student to get current Para
      final studentLogs = AppData.ProgressLogs.where(
        (log) => log['studentId'] == student['studentId'],
      ).toList();

      int latestPara = 1;
      if (studentLogs.isNotEmpty) {
        final latestLog = studentLogs.last;
        if (latestLog['sabaq'] != null && latestLog['sabaq']['para'] != null) {
          latestPara = latestLog['sabaq']['para'];
        }
      }

      // 3. Map into exact schema expected by DirectoryScreen & StudentHistoryScreen
      return {
        'studentId': student['studentId'],
        'name': student['name'] ?? 'Unknown Student',
        'para': latestPara,
        'parentPhone': parentUser['phoneNumber'] ?? 'N/A',
        'parent':
            parentUser['name'] ?? student['assignedParentName'] ?? 'Unassigned',
        'parentId': student['parentId'],
        'teacherId': student['teacherId'],
      };
    }).toList();
  }
}
