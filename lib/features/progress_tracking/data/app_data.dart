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
  static const String _keyUid = "uid";
  static const String _keyRole = "cached_role";
  static const String _keyIsLoggedIn = "cached_IsLoggedIn";
  //for attendance tab to see if already submitted or not
  static Map<String, Set<String>> submittedSessions = {};
  //for daily entery screen to see if progress log is already submitted or not
  static Map<String, Set<String>> submittedProgressLogs = {};

  static final Map<String, Map<String, Map<String, String>>> _attendanceLogs = {
    "2026-08-01": {
      "Session 1 (Sabaq)": {
        "std_8849204": "Present",
        "std_9920134": "Absent",
        "std_1111111": "Late",
      },
      "Session 2 (Sabqi)": {
        "std_8849204": "Present",
        "std_9920134": "Present",
        "std_1111111": "Absent",
      },
    },
  };
  // Existing Mock Memory Data
  // static List<Map<String, dynamic>> attendanceLogs = [
  //   {
  //     "studentId": "std_8849204",
  //     "studentName": "Ahmad Muhammad",
  //     "date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
  //     "session": "session1",
  //     "attendanceStatus": "present",
  //   },
  // ];

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
      },
      "sabqi": "para 1 page 2 to 5",
      "manzil": "para 2",
      "grade": ["Excellent", "Good", "Needs Practice"],
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
      "grade": ["N/A", "N/A", "N/A"],
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
      "password": "password",
      "createdAt": "2026-05-01T10:15:00Z",
    },
    {
      "uid": "teacher_uid_102",
      "name": "Qari Tariq",
      "role": "teacher",
      "phoneNumber": "03002222222",
      "password": "password",
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

  static Future<String> getUsersNameById(String uid) async {
    var u = users.where((user) => user["uid"] == uid).firstOrNull;
    if (u == null) {
      return "Unknown";
    }
    return u["name"];
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
    final logs = ProgressLogs.isEmpty
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
        : List<Map<String, dynamic>>.from(ProgressLogs);

    // Sort descending (newest first)
    logs.sort((a, b) => b['date'].toString().compareTo(a['date'].toString()));

    return logs;
  }

  static int getTotalAttendanceCount(String date, String status) {
    final dayData = _attendanceLogs[date];
    if (dayData == null) return 0;

    int count = 0;
    final targetStatus = status.toLowerCase();

    dayData.forEach((sessionName, studentMap) {
      studentMap.forEach((studentId, attendanceStatus) {
        if (attendanceStatus.toString().toLowerCase() == targetStatus) {
          count++;
        }
      });
    });

    return count;
  }

  static int getTotalAttendanceCountForSession(
    String date,
    String status,
    String session,
  ) {
    int count = 0;
    final dayData = _attendanceLogs[date];
    if (dayData == null) return 0;
    dayData.forEach((sessionName, studentMap) {
      if (sessionName == session) {
        studentMap.forEach((studentId, attendanceStatus) {
          if (attendanceStatus.toString().toLowerCase() ==
              status.toLowerCase()) {
            count++;
          }
        });
      }
    });
    return count;
  }

  static Map<String, dynamic> getAttendanceStatusForSession(
    String session,
    String studentId,
    String date,
  ) {
    Map<String, dynamic> response = {"attendanceStatus": "Pending"};
    final dayData = _attendanceLogs[date];
    if (dayData == null) return {"attendanceStatus": "Pending"};

    dayData.forEach((sessionName, studentMap) {
      if (sessionName.toLowerCase() == session.toLowerCase()) {
        final status = studentMap[studentId];
        if (status != null) {
          response = {"attendanceStatus": status};
        }
      }
    });

    return response;
  }

  static int getTotalAttendanceCountForStudent(
    String studentId,
    String status,
  ) {
    int count = 0;
    final targetStatus = status.toLowerCase();

    _attendanceLogs.forEach((date, sessions) {
      sessions.forEach((sessionName, studentMap) {
        final attendanceStatus = studentMap[studentId];
        if (attendanceStatus != null &&
            attendanceStatus.toLowerCase() == targetStatus) {
          count++;
        }
      });
    });

    return count;
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
    return availableSessions;
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
    List<String> remarks,
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

  static Future<bool> saveAttendanceLog({
    required DateTime date,
    required List<String> sessionNames,
    required Map<String, String> studentAttendance, // Map<studentId, status>
  }) async {
    try {
      // Format date as YYYY-MM-DD
      final String dateKey =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      // Ensure the date entry exists
      _attendanceLogs.putIfAbsent(dateKey, () => {});

      // For each active session submitted, record the attendance snapshot
      for (var session in sessionNames) {
        _attendanceLogs[dateKey]![session] = Map<String, String>.from(
          studentAttendance,
        );
      }

      // Debug log to verify structure in console
      print("Saved Logs for $dateKey: ${_attendanceLogs[dateKey]}");
      return true;
    } catch (e) {
      print("Failed to save attendance: $e");
      return false;
    }
  }

  /// Helper to get attendance stats for a specific day
  static Map<String, int> getDailySummary(DateTime date) {
    final String dateKey =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    int present = 0, absent = 0, lateCount = 0;

    if (_attendanceLogs.containsKey(dateKey)) {
      _attendanceLogs[dateKey]!.forEach((session, students) {
        students.forEach((studentId, status) {
          if (status == 'Present') present++;
          if (status == 'Absent') absent++;
          if (status == 'Late') lateCount++;
        });
      });
    }

    return {'present': present, 'absent': absent, 'late': lateCount};
  }

  static Future<void> SaveLoginInfo(
    String uid,
    String role,
    bool loggedIn,
  ) async {
    var sp = await SharedPreferences.getInstance();
    await sp.setString(_keyUid, uid);
    await sp.setString(_keyRole, role);
    await sp.setBool(_keyIsLoggedIn, loggedIn);
  }

  static Future<Map<String, dynamic>> getLoginInfo() async {
    var sp = await SharedPreferences.getInstance();
    String? uid = sp.getString(_keyUid);
    String? role = sp.getString(_keyRole);
    bool? isLoggedIn = sp.getBool(_keyIsLoggedIn);

    return {
      "uid": uid ?? "",
      "role": role ?? "",
      "isLoggedIn": isLoggedIn ?? false,
    };
  }

  static Future<void> clearLoginInfo() async {
    var sp = await SharedPreferences.getInstance();
    await sp.remove(_keyUid);
    await sp.remove(_keyRole);
    await sp.remove(_keyIsLoggedIn);
  }

  static void submitSessionForDate(String date, List<String> sessionNames) {
    if (!submittedSessions.containsKey(date)) {
      submittedSessions[date] = {};
    }
    submittedSessions[date]!.addAll(sessionNames);
  }

  static bool isSessionSubmitted(String date, String sessionName) {
    return submittedSessions[date]?.contains(sessionName) ?? false;
  }

  static Set<String> getSubmittedSessionsForDate(String date) {
    return submittedSessions[date] ?? {};
  }

  static void submitProgressLogForDate(String date, String studentId) {
    if (!submittedProgressLogs.containsKey(date)) {
      submittedProgressLogs[date] = {};
    }
    submittedProgressLogs[date]!.add(studentId);
  }

  static bool isProgressLogSubmitted(String date, String studentId) {
    return submittedProgressLogs[date]?.contains(studentId) ?? false;
  }

  static Set<String> getSubmittedProgressLogsForDate(String date) {
    return submittedProgressLogs[date] ?? {};
  }
}
