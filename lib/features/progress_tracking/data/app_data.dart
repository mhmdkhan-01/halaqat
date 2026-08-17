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
  static const String _keyAttendanceLogs = "cached_attendance_logs";
  static const String _keyUid = "uid";
  static const String _keyRole = "cached_role";
  static const String _keyIsLoggedIn = "cached_IsLoggedIn";
  static const String _keyExams = "cashed_exams";
  static const String _keysubmittedProgressLogs = "cached_submitted_logs";
  static const String _keysubmitSessionForDate = "cached_submitSessionForDate";
  static const String _keyExamResults = "cached_exam_results";
  static const String _keyRememberedUsername = 'remembered_username';
  //for attendance tab to see if already submitted or not
  static Map<String, Set<String>> submittedSessions = {};
  //for daily entery screen to see if progress log is already submitted or not
  static Map<String, Set<String>> submittedProgressLogs = {};

  static final Map<String, Map<String, Map<String, String>>> _attendanceLogs = {
    // "2026-08-01": {
    //   "Session 1 (Sabaq)": {
    //     "std_8849204": "Present",
    //     "std_9920134": "Absent",
    //     "std_1111111": "Late",
    //   },
    //   "Session 2 (Sabqi)": {
    //     "std_8849204": "Present",
    //     "std_9920134": "Present",
    //     "std_1111111": "Absent",
    //   },
    // },
  };

  static final months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

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
    // {
    //   "id": "1",
    //   "name": "Session 1 (Sabaq)",
    //   "startTime": const TimeOfDay(hour: 6, minute: 0),
    //   "endTime": const TimeOfDay(hour: 9, minute: 0),
    // },
    // {
    //   "id": "2",
    //   "name": "Session 2 (Sabqi)",
    //   "startTime": const TimeOfDay(hour: 10, minute: 0),
    //   "endTime": const TimeOfDay(hour: 13, minute: 0),
    // },
    // {
    //   "id": "3",
    //   "name": "Session 3 (Manzil)",
    //   "startTime": const TimeOfDay(hour: 14, minute: 0),
    //   "endTime": const TimeOfDay(hour: 17, minute: 0),
    // },
  ];

  static List<Map<String, dynamic>> ProgressLogs = [
    // {
    //   "logId": "log_5529104",
    //   "studentId": "std_8849204",
    //   "studentName": "Ahmad Muhammad",
    //   "loggedByTeacherId": "teacher_uid_101",
    //   "date": "2026-07-16",
    //   "attendanceStatus": "present",
    //   "sabaq": {
    //     "surah": "Al-Baqarah",
    //     "para": 2,
    //     "startAyah": 142,
    //     "endAyah": 150,
    //     "lines": 17,
    //   },
    //   "sabqi": "para 1 page 2 to 5",
    //   "manzil": "para 2",
    //   "grade": ["Excellent", "Good", "Needs Practice"],
    // },
    // {
    //   "logId": "log_5529101",
    //   "studentId": "std_8849204",
    //   "studentName": "Ahmad Muhammad",
    //   "loggedByTeacherId": "teacher_uid_101",
    //   "date": "2026-07-14",
    //   "attendanceStatus": "absent",
    //   "sabaq": null,
    //   "sabqi": null,
    //   "manzil": null,
    //   "grade": ["N/A", "N/A", "N/A"],
    // },
  ];

  static List<Map<String, dynamic>> students = [
    // {
    //   "studentId": "std_8849204",
    //   "name": "Ahmad Muhammad",
    //   "teacherId": "teacher_uid_101",
    //   "parentId": "parent_uid_201",
    //   "assignedTeacherName": "Qari Sulaiman",
    //   "assignedParentName": "Muhammad Bilal",
    //   "createdAt": "2026-07-15T19:23:52Z",
    // },
    // {
    //   "studentId": "std_9920134",
    //   "name": "Hamza Yousaf",
    //   "teacherId": "teacher_uid_101",
    //   "parentId": "parent_uid_202",
    //   "assignedTeacherName": "Qari Sulaiman",
    //   "assignedParentName": "Yasir Khan",
    //   "createdAt": "2026-07-16T10:00:00Z",
    // },
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
    // {
    //   "uid": "teacher_uid_101",
    //   "name": "Qari Sulaiman",
    //   "role": "teacher",
    //   "phoneNumber": "03111111111",
    //   "password": "password",
    //   "createdAt": "2026-05-01T10:15:00Z",
    // },
    // {
    //   "uid": "teacher_uid_102",
    //   "name": "Qari Tariq",
    //   "role": "teacher",
    //   "phoneNumber": "03002222222",
    //   "password": "password",
    //   "createdAt": "2026-05-02T11:00:00Z",
    // },
    // {
    //   "uid": "parent_uid_201",
    //   "name": "Muhammad Bilal",
    //   "role": "parent",
    //   "phoneNumber": "03001234567",
    //   "password": "123456",
    //   "createdAt": "2026-05-03T09:30:00Z",
    // },
    // {
    //   "uid": "parent_uid_202",
    //   "name": "Yasir Khan",
    //   "role": "parent",
    //   "phoneNumber": "03007654321",
    //   "password": "123456",
    //   "createdAt": "2026-05-03T09:45:00Z",
    // },
  ];

  static List<Map<String, dynamic>> exams = [
    {
      "id": "e1",
      "title": "Monthly Hifz Evaluation",
      "date": DateTime(2026, 8, 20),
      "type": "Oral",
    },
    {
      "id": "e2",
      "title": "Quarterly Manzil Review",
      "date": DateTime(2026, 9, 15),
      "type": "Oral",
    },
  ];
  //{
  // 'exam name':[ Map<String, dynamic> , Map<String, dynamic>...]
  //}
  static Map<String, Map<String, Map<String, dynamic>>> examResultsByExamId = {
    "exam_01": {
      "std_8849204": {
        "studentId": "std_8849204",
        "studentName": "Ahmad Muhammad",
        "hifzScore": "94",
        "tajweedGrade": "A",
        "syllabus": "Para 1",
        "remarks": "Excellent progress",
        "status": "Published",
        "isGraded": true,
      },
    },
  };

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
    await prefs.remove(_keyAttendanceLogs);
  }

  //Load data from SharedPreferences on app start
  static Future<void> loadCachedData() async {
    final cachedStudents = await _getFromPrefs(_keyStudents);
    if (cachedStudents != null) {
      students = cachedStudents;
    }

    final cachedSessions = await _getFromPrefs(_keySessions);
    if (cachedSessions != null) {
      availableSessions = cachedSessions.map((s) {
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

    final cachedProgressLogs = await _getFromPrefs(_keyProgressLogs);
    if (cachedProgressLogs != null) {
      ProgressLogs = cachedProgressLogs;
    }
    final cachedExams = await _getFromPrefs(_keyExams);
    if (cachedExams != null) {
      exams = cachedExams;
    }
    final cachedUsers = await _getFromPrefs(_keyUsers);
    if (cachedUsers != null) {
      users = cachedUsers;
    }
    await loadSubmittedLogs();
    await loadAttendanceLogs();
    await loadSubmittedSessions();
  }

  static Future<void> submitProgressLogForDate(
    String date,
    String studentId,
  ) async {
    if (!submittedProgressLogs.containsKey(date)) {
      submittedProgressLogs[date] = {};
    }
    submittedProgressLogs[date]!.add(studentId);

    // Convert Set<String> to List<String> before encoding
    final encodableMap = submittedProgressLogs.map(
      (key, value) => MapEntry(key, value.toList()),
    );

    final sp = await SharedPreferences.getInstance();
    await sp.setString(_keysubmittedProgressLogs, jsonEncode(encodableMap));
  }

  static Future<void> loadSubmittedLogs() async {
    final sp = await SharedPreferences.getInstance();
    String raw = sp.getString(_keysubmittedProgressLogs) ?? "";
    if (raw.isNotEmpty) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(raw);
        submittedProgressLogs = decoded.map(
          (key, value) => MapEntry(
            key,
            value is List
                ? Set<String>.from(value.map((e) => e.toString()))
                : <String>{},
          ),
        );
      } catch (e) {
        debugPrint("Failed to load submitted progress logs: $e");
      }
    }
  }

  static Future<void> loadAttendanceLogs() async {
    final sp = await SharedPreferences.getInstance();
    final String? rawData = sp.getString(_keyAttendanceLogs);

    if (rawData != null && rawData.isNotEmpty) {
      try {
        final Map<String, dynamic> decodedData = jsonDecode(rawData);

        _attendanceLogs.clear();

        decodedData.forEach((date, sessions) {
          if (sessions is Map) {
            final Map<String, Map<String, String>> parsedSessions = {};

            sessions.forEach((sessionName, students) {
              if (students is Map) {
                parsedSessions[sessionName.toString()] = students.map(
                  (studentId, status) =>
                      MapEntry(studentId.toString(), status.toString()),
                );
              }
            });

            _attendanceLogs[date.toString()] = parsedSessions;
          }
        });
      } catch (e) {
        print("Failed to parse attendance logs: $e");
      }
    }
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
    debugPrint(
      "Fetching students for teacherId: $teacherId from AppData\nCurrent students: ${students}",
    );
    // ONLINE FLOW: (Future Firebase query will go here)
    final freshData = students
        .where((student) => student["teacherId"] == teacherId)
        .toList();

    // Cache updated list locally
    return freshData;
  }

  static Future<List<Map<String, dynamic>>> getParentChildren(
    String parentId,
  ) async {
    if (isOffline) {
      final cached = await _getFromPrefs(_keyStudents);
      if (cached != null) {
        return cached
            .where((student) => student["parentId"] == parentId)
            .toList();
      }
    }
    debugPrint(
      "Fetching children for parentId: $parentId from AppData\nCurrent students: ${students}",
    );
    // ONLINE FLOW: (Future Firebase query will go here)
    final freshData = students
        .where((student) => student["parentId"] == parentId)
        .toList();

    // Cache updated list locally
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
  static int getTotalTeachersCount() {
    return users.where((user) => user['role'] == 'teacher').length;
  }

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
              "grade": [],
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
            "grade": log["grade"],
          },
        )
        .toList();
  }

  static List<Map<String, dynamic>> getSessions() {
    return availableSessions;
  }

  // static List<Map<String, dynamic>> getExamResults() {
  //   return [
  //     {
  //       // --- Student Identity ---
  //       "studentId": "std_8849204", // From App Data
  //       "studentName": "Ahmad Muhammad", // From App Data
  //       // --- Exam Metadata ---
  //       "examId": "exam_01", // From App Data
  //       "sessionName": "Term 1 - 2026", // From App Data
  //       "status": "Published", // From App Data
  //       "syllabus": "Para 1",
  //       // --- Evaluation / Grading ---
  //       "hifzScore": "94/100", // From App Data
  //       "tajweedGrade": "A", // From App Data
  //       "remarks": "Excellent", // From Publish Result
  //       "isGraded": true, // From Publish Result
  //     },
  //   ];
  // }

  static Map<String, dynamic> getStudentAnalytics(String studentId) {
    int tnp = 0;
    final studentLogs = ProgressLogs.where(
      (log) => log['studentId'] == studentId,
    ).toList();
    studentLogs.forEach((log) {
      if (log['sabaq'] != null && log['sabaq']['lines'] != null) {
        tnp += (log['sabaq']['lines'] is String)
            ? int.parse(log['sabaq']['lines'])
            : log['sabaq']['lines'] as int;
      }
    });
    double totalNewPages = tnp / 16;
    double hifzProgressPercent = 0;
    double totalParas = 30;
    studentLogs.forEach((log) {
      if (log['sabaq'] != null && log['sabaq']['para'] != null) {
        hifzProgressPercent +=
            (int.parse(log['sabaq']['para'].toString())) / totalParas;
      }
    });
    int totalClasses = _attendanceLogs.length;
    int totalPresents = ProgressLogs.where(
      (log) =>
          log['studentId'] == studentId &&
          log['attendanceStatus'].toString().toLowerCase() == 'present',
    ).length;
    int totalAbsents = (totalPresents == 0)
        ? totalClasses
        : totalClasses - totalPresents;
    totalAbsents = totalAbsents < 0 ? 0 : totalAbsents;

    double attendanceRate = (totalClasses > 0)
        ? totalPresents / totalClasses
        : 0.0;
    return {
      "totalNewPages": totalNewPages.floor(),
      "hifzProgressPercent": hifzProgressPercent,
      "attendanceRate": attendanceRate,
      "totalClasses": totalClasses,
      "totalPresents": totalPresents,
      "totalAbsents": totalAbsents,
    };
  }

  static int getAttendanceForDay(String studentId, String date, String status) {
    final dayData = _attendanceLogs[date];
    if (dayData == null) return 0;

    int count = 0;
    dayData.forEach((sessionName, studentMap) {
      if (studentMap.containsKey(studentId)) {
        studentMap.forEach((id, status) {
          if (id == studentId && status.toLowerCase() == status.toLowerCase()) {
            count++;
          }
        });
      }
    });

    return count;
  }

  static List<String> getMonthlyCalendarAttendance(String studentId) {
    List<String> statuses = List.generate(30, (a) => "unlogged");
    _attendanceLogs.forEach((date, daydata) {
      String dstatus = "unlogged";
      bool check = true;
      daydata.forEach((session, studentMap) {
        if (studentMap.containsKey(studentId)) {
          studentMap.forEach((id, status) {
            if (id == studentId && status.toLowerCase() == "present") {
              dstatus = "present";
              check = false;
            } else {
              if (check) {
                if (id == studentId && status.toLowerCase() == "absent") {
                  dstatus = "absent";
                }
              }
            }
          });
        }
      });
      String ld = date.split('-').last;
      int? d = int.tryParse(ld);
      debugPrint("D id $d");
      debugPrint("Status is $dstatus");
      if (d != null) statuses[(d - 1)] = dstatus;
    });
    return statuses;
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
    String teacherNote,
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
      "teacherNote": teacherNote,
    });
    _saveToPrefs(_keyProgressLogs, ProgressLogs);
  }

  static Map<String, dynamic> validateLoginUser(String uname, String password) {
    Map<String, dynamic>? u = users
        .where((user) => user['phoneNumber'] == uname)
        .firstOrNull;
    if (u == null) {
      return {"status": "error", "message": "No User Found"};
    }
    if (password != u['password']) {
      return {"status": "error", "message": "Incorrect Password"};
    }

    return {"status": "success", "userId": u['uid'], "role": u['role']};
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
          latestPara = (latestLog['sabaq']['para'] is String)
              ? int.parse(latestLog['sabaq']['para'])
              : latestLog['sabaq']['para'];
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

      // 1. Ensure the date entry exists in the parent map
      _attendanceLogs[dateKey] ??= {};

      // 2. Safely merge student attendance for each session without losing other sessions
      for (var session in sessionNames) {
        _attendanceLogs[dateKey]![session] = Map<String, String>.from(
          studentAttendance,
        );
      }

      // 3. Persist to SharedPreferences (convert to JSON string if required by your helper)
      // If _saveToPrefs expects a String, use jsonEncode:
      await _saveToPrefs(_keyAttendanceLogs, _attendanceLogs);

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

  static Future<void> submitSessionForDate(
    String date,
    List<String> sessionNames,
  ) async {
    if (!submittedSessions.containsKey(date)) {
      submittedSessions[date] = {};
    }
    submittedSessions[date]!.addAll(sessionNames);

    // Convert Set<String> to List<String> for jsonEncode
    final encodableMap = submittedSessions.map(
      (key, value) => MapEntry(key, value.toList()),
    );

    await _saveToPrefs(_keysubmitSessionForDate, encodableMap);
  }

  static Future<void> loadSubmittedSessions() async {
    final sp = await SharedPreferences.getInstance();
    String raw = sp.getString(_keysubmitSessionForDate) ?? "";

    if (raw.isNotEmpty) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(raw);

        // Parse into a local map first
        final Map<String, Set<String>> parsedSessions = decoded.map(
          (key, value) => MapEntry(
            key,
            value is List
                ? Set<String>.from(value.map((e) => e.toString()))
                : <String>{},
          ),
        );

        // Assign to state only after successful parsing
        submittedSessions = parsedSessions;
      } catch (e) {
        debugPrint("Failed to load submitted sessions: $e");
      }
    } else {
      submittedSessions = {};
    }
  }

  static bool isSessionSubmitted(String date, String sessionName) {
    return submittedSessions[date]?.contains(sessionName) ?? false;
  }

  static Set<String> getSubmittedSessionsForDate(String date) {
    return submittedSessions[date] ?? {};
  }

  static bool isProgressLogSubmitted(String date, String studentId) {
    return submittedProgressLogs[date]?.contains(studentId) ?? false;
  }

  static Set<String> getSubmittedProgressLogsForDate(String date) {
    return submittedProgressLogs[date] ?? {};
  }

  static Future<List<Map<String, dynamic>>> getChildrenForParent(
    String parentId,
  ) async {
    return students
        .where((student) => student['parentId'] == parentId)
        .toList();
  }

  static Future<Map<String, dynamic>> getTodayReport(String studentId) async {
    //"attendance": "Present",
    // "sabaq": "Para 15, Surah Al-Kahf (Ayat 1-20)",
    // "sabqi": "Para 14 (Full)",
    // "manzil": "Para 5 (Quarter 1)",
    // "sabaqgrade": "Excellent",
    // "sabqigrade": "Good",
    // "manzilgrade": "Needs Practice",
    // "teacher_note": "Masha'Allah, excellent tajweed and focus today!",

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final progressLog = ProgressLogs.firstWhere(
      (log) => log['studentId'] == studentId && log['date'] == today,
      orElse: () => <String, dynamic>{},
    );
    return {
      "attendance": progressLog['attendanceStatus'] ?? "Not Logged",
      "sabaq": progressLog['sabaq'] != null
          ? "Para ${progressLog['sabaq']['para']}, Surah ${progressLog['sabaq']['surah']} (Lines: ${progressLog['sabaq']['lines']})"
          : "Not Logged",
      "sabqi": progressLog['sabqi'] ?? "Not Logged",
      "manzil": progressLog['manzil'] ?? "Not Logged",
      "sabaqgrade":
          progressLog['grade'] != null && progressLog['grade'].length > 0
          ? progressLog['grade'][0]
          : "Not Graded",
      "sabqigrade":
          progressLog['grade'] != null && progressLog['grade'].length > 1
          ? progressLog['grade'][1]
          : "Not Graded",
      "manzilgrade":
          progressLog['grade'] != null && progressLog['grade'].length > 2
          ? progressLog['grade'][2]
          : "Not Graded",

      "teacher_note": progressLog['teacherNote'] ?? "No Notes",
    };
  }

  static List<Map<String, dynamic>> getExams() {
    return exams;
  }

  static void addExam(Map<String, dynamic> exam) {
    exams.add(exam);
    // getStudents().forEach((student) {
    //   Map<String, dynamic> newentrie = {
    //     // --- Student Identity ---
    //     "studentId": student['studentId'], // From App Data
    //     "studentName": student['name'], // From App Data
    //     // --- Exam Metadata ---
    //     "examId": exam['id'], // From App Data
    //     "sessionName": exam['title'], // From App Data
    //     "status": "Pending", // From App Data
    //     "syllabus": "N/A",
    //     // --- Evaluation / Grading ---
    //     "hifzScore": "0", // From App Data
    //     "tajweedGrade": "X", // From App Data
    //     "remarks": "X", // From Publish Result
    //     "isGraded": false, // From Publish Result
    //   };
    //   resultsLogs[exam['id']] = [];
    //   resultsLogs[exam['id']]!.add(newentrie);
    //   debugPrint("Added: $newentrie");
    // });

    _saveToPrefs(_keyExams, exams);
  }

  static void updateExam(Map<String, dynamic> exam, int index) {
    exams[index] = exam;
    _saveToPrefs(_keyExams, exams);
  }

  static void deleteExam(int index) {
    exams.removeAt(index);
    _saveToPrefs(_keyExams, exams);
  }

  static List<Map<String, String>> getExamDetails() {
    List<Map<String, String>> names = [];
    DateTime d = DateTime(12, 1, 1);
    String dateString = '${months[d.month]} ${d.day}';
    exams.forEach((exam) {
      names.add({'id': exam['id'], 'name': '${exam['title']} - $dateString'});
    });
    return names;
  }

  /// Fetch results for all students in a specific exam
  static Map<String, Map<String, dynamic>> getResultsForExam(String examId) {
    return examResultsByExamId[examId] ?? {};
  }

  /// Fetch a single student's result for a specific exam
  static Map<String, dynamic>? getStudentResultForExam({
    required String examId,
    required String studentId,
  }) {
    return examResultsByExamId[examId]?[studentId];
  }

  /// Save or update a single student's result under a specific exam
  static void saveStudentResult({
    required String examId,
    required String studentId,
    required Map<String, dynamic> resultData,
  }) {
    if (!examResultsByExamId.containsKey(examId)) {
      examResultsByExamId[examId] = {};
    }
    examResultsByExamId[examId]![studentId] = resultData;
    _saveToPrefs(_keyExamResults, examResultsByExamId);
  }

  /// Save multiple student results at once (e.g. Publish All button)
  static void saveBulkResultsForExam({
    required String examId,
    required List<Map<String, dynamic>> studentResults,
  }) {
    if (!examResultsByExamId.containsKey(examId)) {
      examResultsByExamId[examId] = {};
    }

    for (var result in studentResults) {
      final String? studentId = result['studentId']?.toString();
      if (studentId != null && studentId.isNotEmpty) {
        examResultsByExamId[examId]![studentId] = result;
      }
    }
  }

  /// Fetch all historical exam results for a given student (Parent View)
  static List<Map<String, dynamic>> getAllResultsForStudent(String studentId) {
    List<Map<String, dynamic>> history = [];
    final exams = getExams();

    for (var exam in exams) {
      final String examId = exam['id'];
      final String examTitle = exam['title'];

      final examMap = examResultsByExamId[examId];
      if (examMap != null && examMap.containsKey(studentId)) {
        final result = examMap[studentId]!;
        if (result['isGraded'] == true) {
          history.add({...result, "examTitle": examTitle});
        }
      }
    }

    return history;
  }

  // ---------- import export functions ----------------//

  /// Safely encodes objects into JSON string, handling TimeOfDay & DateTime
  static Future<String> exportDataToJson() async {
    final sp = await SharedPreferences.getInstance();

    final Map<String, dynamic> backupPayload = {
      "version": 1,
      "exportedAt": DateTime.now().toIso8601String(),
      "data": {
        "students": AppData.students,
        "users": AppData.users,
        "sessions": AppData.availableSessions,
        "progressLogs": AppData.ProgressLogs,
        "exams": AppData.exams.map((e) {
          final copy = Map<String, dynamic>.from(e);
          if (copy['date'] is DateTime) {
            copy['date'] = (copy['date'] as DateTime).toIso8601String();
          }
          return copy;
        }).toList(),
        "examResultsByExamId": AppData.examResultsByExamId,
        "attendanceLogs": sp.getString(AppData._keyAttendanceLogs) != null
            ? jsonDecode(sp.getString(AppData._keyAttendanceLogs)!)
            : AppData._attendanceLogs,
        "submittedSessions": AppData.submittedSessions.map(
          (key, value) => MapEntry(key, value.toList()),
        ),
        "submittedProgressLogs": AppData.submittedProgressLogs.map(
          (key, value) => MapEntry(key, value.toList()),
        ),
      },
    };

    final encoder = JsonEncoder.withIndent('  ', (nonEncodable) {
      if (nonEncodable is TimeOfDay) {
        final hour = nonEncodable.hour.toString().padLeft(2, '0');
        final minute = nonEncodable.minute.toString().padLeft(2, '0');
        return '$hour:$minute';
      }
      if (nonEncodable is DateTime) {
        return nonEncodable.toIso8601String();
      }
      return nonEncodable.toString();
    });

    return encoder.convert(backupPayload);
  }

  /// Helper to parse "HH:mm" strings back to TimeOfDay
  static TimeOfDay _parseTimeOfDay(dynamic input) {
    if (input is TimeOfDay) return input;
    if (input is String && input.contains(':')) {
      final parts = input.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    return const TimeOfDay(hour: 0, minute: 0);
  }

  /// Helper to parse ISO strings back to DateTime
  static DateTime _parseDateTime(dynamic input) {
    if (input is DateTime) return input;
    if (input is String) {
      return DateTime.tryParse(input) ?? DateTime.now();
    }
    return DateTime.now();
  }

  /// Imports JSON string back into memory structures and SharedPreferences
  static Future<bool> importDataFromJson(String jsonStr) async {
    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      final Map<String, dynamic> data = decoded['data'] ?? decoded;

      final sp = await SharedPreferences.getInstance();

      // Clear existing memory structures
      AppData.students.clear();
      AppData.users.clear();
      AppData.availableSessions.clear();
      AppData.ProgressLogs.clear();
      AppData.exams.clear();
      AppData.examResultsByExamId.clear();
      AppData.submittedSessions.clear();
      AppData.submittedProgressLogs.clear();

      // 1. Populate Students
      if (data['students'] is List) {
        AppData.students.addAll(
          (data['students'] as List)
              .map((e) => Map<String, dynamic>.from(e))
              .toList(),
        );
        await sp.setString(AppData._keyStudents, jsonEncode(AppData.students));
      }

      // 2. Populate Users
      if (data['users'] is List) {
        AppData.users.addAll(
          (data['users'] as List)
              .map((e) => Map<String, dynamic>.from(e))
              .toList(),
        );
        await sp.setString(AppData._keyUsers, jsonEncode(AppData.users));
      }

      // 3. Populate Sessions
      if (data['sessions'] is List) {
        for (var item in data['sessions']) {
          final session = Map<String, dynamic>.from(item);
          if (session.containsKey('startTime')) {
            session['startTime'] = _parseTimeOfDay(session['startTime']);
          }
          if (session.containsKey('endTime')) {
            session['endTime'] = _parseTimeOfDay(session['endTime']);
          }
          AppData.availableSessions.add(session);
        }

        // Convert TimeOfDay back to String when persisting to SharedPreferences
        final serializableSessions = AppData.availableSessions.map((s) {
          final copy = Map<String, dynamic>.from(s);
          if (copy['startTime'] is TimeOfDay) {
            final tod = copy['startTime'] as TimeOfDay;
            copy['startTime'] =
                '${tod.hour.toString().padLeft(2, '0')}:${tod.minute.toString().padLeft(2, '0')}';
          }
          if (copy['endTime'] is TimeOfDay) {
            final tod = copy['endTime'] as TimeOfDay;
            copy['endTime'] =
                '${tod.hour.toString().padLeft(2, '0')}:${tod.minute.toString().padLeft(2, '0')}';
          }
          return copy;
        }).toList();

        await sp.setString(
          AppData._keySessions,
          jsonEncode(serializableSessions),
        );
      }

      // 4. Populate Progress Logs
      if (data['progressLogs'] is List) {
        AppData.ProgressLogs.addAll(
          (data['progressLogs'] as List)
              .map((e) => Map<String, dynamic>.from(e))
              .toList(),
        );
        await sp.setString(
          AppData._keyProgressLogs,
          jsonEncode(AppData.ProgressLogs),
        );
      }

      // 5. Populate Exams
      if (data['exams'] is List) {
        for (var e in data['exams']) {
          final examMap = Map<String, dynamic>.from(e);
          if (examMap.containsKey('date')) {
            examMap['date'] = _parseDateTime(examMap['date']);
          }
          AppData.exams.add(examMap);
        }

        final serializableExams = AppData.exams.map((e) {
          final copy = Map<String, dynamic>.from(e);
          if (copy['date'] is DateTime) {
            copy['date'] = (copy['date'] as DateTime).toIso8601String();
          }
          return copy;
        }).toList();

        await sp.setString(AppData._keyExams, jsonEncode(serializableExams));
      }

      // 6. Populate Exam Results
      if (data['examResultsByExamId'] is Map) {
        final rawResults = data['examResultsByExamId'] as Map<String, dynamic>;
        rawResults.forEach((examId, studentMap) {
          if (studentMap is Map) {
            AppData.examResultsByExamId[examId] = {};
            studentMap.forEach((stdId, log) {
              if (log is Map) {
                AppData.examResultsByExamId[examId]![stdId] =
                    Map<String, dynamic>.from(log);
              }
            });
          }
        });
        await sp.setString(
          AppData._keyExamResults,
          jsonEncode(data['examResultsByExamId']),
        );
      }

      // 7. Populate Attendance Logs
      if (data['attendanceLogs'] is Map) {
        final rawAttendance = data['attendanceLogs'] as Map<String, dynamic>;
        AppData._attendanceLogs.clear();

        rawAttendance.forEach((dateKey, sessionMap) {
          if (sessionMap is Map) {
            AppData._attendanceLogs[dateKey] = {};
            sessionMap.forEach((sessionKey, studentMap) {
              if (studentMap is Map) {
                AppData._attendanceLogs[dateKey]![sessionKey] =
                    Map<String, String>.from(studentMap);
              }
            });
          }
        });

        await sp.setString(
          AppData._keyAttendanceLogs,
          jsonEncode(data['attendanceLogs']),
        );
        await AppData.loadAttendanceLogs();
      }

      // 8. Populate Submitted Sessions
      if (data['submittedSessions'] is Map) {
        (data['submittedSessions'] as Map).forEach((key, val) {
          if (val is List) {
            AppData.submittedSessions[key.toString()] = Set<String>.from(
              val.map((e) => e.toString()),
            );
          }
        });
      }

      // 9. Populate Submitted Progress Logs
      if (data['submittedProgressLogs'] is Map) {
        (data['submittedProgressLogs'] as Map).forEach((key, val) {
          if (val is List) {
            AppData.submittedProgressLogs[key.toString()] = Set<String>.from(
              val.map((e) => e.toString()),
            );
          }
        });
      }

      return true;
    } catch (e, stackTrace) {
      print("Error restoring data: $e");
      print("Stack trace: $stackTrace");
      return false;
    }
  }

  /// Retrieves a map of sessions and student statuses for a specific date string (yyyy-MM-dd)
  static Map<String, Map<String, String>> getAttendanceLogsForDate(
    String date,
  ) {
    if (_attendanceLogs.containsKey(date)) {
      return _attendanceLogs[date] ?? {};
    }
    return {};
  }

  static Future<void> saveRememberedUsername(String username) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_keyRememberedUsername, username);
  }

  /// Retrieves the saved username (returns empty string if none saved)
  static Future<String> getRememberedUsername() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_keyRememberedUsername) ?? "";
  }

  /// Clears the saved username
  static Future<void> clearRememberedUsername() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_keyRememberedUsername);
  }
}
