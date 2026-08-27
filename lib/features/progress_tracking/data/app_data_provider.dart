import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDataProvider extends ChangeNotifier {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Real-time Stream Subscriptions
  StreamSubscription? _usersSub;
  StreamSubscription? _studentsSub;
  StreamSubscription? _sessionsSub;
  StreamSubscription? _attendanceSub;
  StreamSubscription? _progressSub;
  StreamSubscription? _submissionsSub;
  StreamSubscription? _examsSub;

  bool isLoading = true;

  // Storage Keys for SharedPreferences (Offline Fallback)
  static const String _keyUsers = "cached_users";
  static const String _keyStudents = "cached_students";
  static const String _keySessions = "cached_sessions";
  static const String _keyProgressLogs = "cached_progress_logs";
  static const String _keyAttendanceLogs = "cached_attendance_logs";
  static const String _keySubmissions = "cached_submissions";
  static const String _keyExams = "cached_exams";
  static const String _keyUid = "uid";
  static const String _keyRole = "cached_role";
  static const String _keyIsLoggedIn = "cached_IsLoggedIn";
  // static const String _keyRememberedUsername = 'remembered_username';
  static String currentUserId = "";
  // In-Memory Global State
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> availableSessions = [];
  List<Map<String, dynamic>> progressLogs = [];
  List<Map<String, dynamic>> exams = [];

  Map<String, Map<String, Map<String, String>>> attendanceLogs = {};
  Map<String, Map<String, Map<String, dynamic>>> examResultsByExamId = {};
  Map<String, Set<String>> submittedSessions = {};
  Map<String, Set<String>> submittedProgressLogs = {};
  bool parentLoading = false;

  // Add the getter that ParentDashboard is trying to access

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

  // ==========================================
  // INITIALIZATION & REAL-TIME LISTENERS
  // ==========================================

  /// Call once at App Startup or Main Screen
  Future<void> initializeDataListeners() async {
    isLoading = true;
    notifyListeners();

    // 1. Load SharedPreferences cache first for instant UI response
    await _loadFromLocalCache();

    // 2. Attach real-time Firestore listeners
    _listenToUsers();
    _listenToStudents();
    _listenToSessions();
    _listenToAttendance();
    _listenToProgressLogs();
    _listenToDailySubmissions();
    _listenToExams();

    isLoading = false;

    notifyListeners();
  }

  void _listenToUsers() {
    _usersSub?.cancel();
    _usersSub = _db.collection('users').snapshots().listen((snapshot) {
      users = snapshot.docs.map((doc) => doc.data()..['uid'] = doc.id).toList();
      _saveToPrefs(_keyUsers, users);
      notifyListeners();
    });
  }

  void _listenToStudents() {
    _studentsSub?.cancel();
    _studentsSub = _db.collection('students').snapshots().listen((snapshot) {
      students = snapshot.docs
          .map((doc) => doc.data()..['studentId'] = doc.id)
          .toList();
      _saveToPrefs(_keyStudents, students);
      // If we already have a cached parent UID, update reports automatically
      if (currentUserId.isNotEmpty) {
        final parentChildren = getChildrenForParent(currentUserId);
        if (parentChildren.isNotEmpty) {
          final rawId =
              parentChildren[_selectedChildIndex]['studentId'] ??
              parentChildren[_selectedChildIndex]['id'];
          fetchTodayReportForChild(_extractStringId(rawId));
        }
      }

      parentLoading = false;
      notifyListeners();
    });
  }

  void _listenToSessions() {
    _sessionsSub?.cancel();
    _sessionsSub = _db.collection('sessions').snapshots().listen((snapshot) {
      availableSessions = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          "id": doc.id,
          "name": data["name"] ?? "",
          "startTime": TimeOfDay(
            hour: data["startHour"] ?? 8,
            minute: data["startMinute"] ?? 0,
          ),
          "endTime": TimeOfDay(
            hour: data["endHour"] ?? 10,
            minute: data["endMinute"] ?? 0,
          ),
        };
      }).toList();

      _cacheSessionsLocally();
      notifyListeners();
    });
  }

  void _listenToAttendance() {
    _attendanceSub?.cancel();
    _attendanceSub = _db.collection('attendance_logs').snapshots().listen((
      snapshot,
    ) {
      attendanceLogs.clear();
      for (var doc in snapshot.docs) {
        final dateKey = doc.id;
        final sessionsData =
            doc.data()['sessions'] as Map<String, dynamic>? ?? {};

        final Map<String, Map<String, String>> parsedSessions = {};
        sessionsData.forEach((sessionName, studentMap) {
          if (studentMap is Map) {
            parsedSessions[sessionName] = Map<String, String>.from(studentMap);
          }
        });
        attendanceLogs[dateKey] = parsedSessions;
      }
      debugPrint("Current Attendance Logs::: ${attendanceLogs}");
      _saveToPrefs(_keyAttendanceLogs, attendanceLogs);
      notifyListeners();
    });
  }

  void _listenToProgressLogs() {
    _progressSub?.cancel();
    _progressSub = _db.collection('progress_logs').snapshots().listen((
      snapshot,
    ) {
      progressLogs = snapshot.docs
          .map((doc) => doc.data()..['logId'] = doc.id)
          .toList();
      progressLogs.sort(
        (a, b) => b['date'].toString().compareTo(a['date'].toString()),
      );
      _saveToPrefs(_keyProgressLogs, progressLogs);
      notifyListeners();
    });
  }

  void _listenToDailySubmissions() {
    _submissionsSub?.cancel();
    _submissionsSub = _db.collection('daily_submissions').snapshots().listen((
      snapshot,
    ) {
      submittedProgressLogs.clear();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final String date = data['date'] ?? '';
        final String studentId = data['studentId'] ?? '';
        final bool isSubmitted = data['isSubmitted'] ?? false;

        if (date.isNotEmpty && studentId.isNotEmpty && isSubmitted) {
          submittedProgressLogs.putIfAbsent(date, () => {}).add(studentId);
        }
      }
      _cacheSubmissionsLocally();
      notifyListeners();
    });
  }

  void _listenToExams() {
    _examsSub?.cancel();
    _examsSub = _db.collection('exams').snapshots().listen((snapshot) {
      exams = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          "id": doc.id,
          "title": data["title"] ?? "",
          "date": (data["date"] as Timestamp?)?.toDate() ?? DateTime.now(),
          "type": data["type"] ?? "Oral",
        };
      }).toList();
      notifyListeners();
    });
  }

  // ==========================================
  // FIRESTORE WRITE OPERATIONS
  // ==========================================

  Future<void> addStudent(String name) async {
    final docRef = _db.collection('students').doc();
    await docRef.set({
      "studentId": docRef.id,
      "name": name,
      "teacherId": "Unassigned",
      "parentId": "Unassigned",
      "assignedTeacherName": "Unassigned",
      "assignedParentName": "Unassigned",
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> assignRelations(
    String parent,
    String teacher,
    String parentId,
    String teacherId,
    String studentId,
  ) async {
    await _db.collection('students').doc(studentId).update({
      "parent": parent,
      "teacher": teacher,
      "teacherId": teacherId,
      "parentId": parentId,
    });
  }

  Future<void> saveAttendanceLog({
    required DateTime date,
    required List<String> sessionNames,
    required Map<String, String> studentAttendance,
  }) async {
    final String dateKey = DateFormat('yyyy-MM-dd').format(date);
    final docRef = _db.collection('attendance_logs').doc(dateKey);

    Map<String, dynamic> updates = {};
    for (var session in sessionNames) {
      // Escapes dots properly so Firestore builds a nested map
      updates['sessions.$session'] = studentAttendance;
    }

    // Ensure document exists first before updating nested fields
    final docSnap = await docRef.get();
    if (!docSnap.exists) {
      // If doc doesn't exist, create it with nested map structure
      Map<String, dynamic> initialData = {'sessions': {}};
      for (var session in sessionNames) {
        initialData['sessions'][session] = studentAttendance;
      }
      await docRef.set(initialData);
    } else {
      // Update existing document using dot-path notation
      await docRef.update(updates);
    }
  }

  /// Adds a new student progress log to Firestore
  Future<void> addProgressLog({
    required String studentId,
    required String studentName,
    required String surah,
    required String para,
    required String lines,
    required String sabqi,
    required String manzil,
    required List<String> remarksList,
    required String generalRemarks,
  }) async {
    final docRef = _db.collection('progress_logs').doc();
    final String dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    await docRef.set({
      "logId": docRef.id,
      "studentId": studentId,
      "studentName": studentName,
      "date": dateStr,
      "sabaq": {"surah": surah, "para": para, "lines": lines},
      "sabqi": sabqi,
      "manzil": manzil,
      "sabaqRemark": remarksList.isNotEmpty ? remarksList[0] : '',
      "sabqiRemark": remarksList.length > 1 ? remarksList[1] : '',
      "manzilRemark": remarksList.length > 2 ? remarksList[2] : '',
      "generalRemarks": generalRemarks,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  /// Persists student daily log submission status in Firestore
  Future<void> submitProgressLogForDate(String date, String studentId) async {
    submittedProgressLogs.putIfAbsent(date, () => {}).add(studentId);
    notifyListeners();

    await _db.collection('daily_submissions').doc('${date}_$studentId').set({
      'date': date,
      'studentId': studentId,
      'isSubmitted': true,
      'submittedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ==========================================
  // READ HELPERS & CALCULATION METRICS
  // ==========================================

  /// Returns available sessions stored in state
  List<Map<String, dynamic>> getAvailableSessions() {
    return availableSessions;
  }

  /// Returns all students assigned to a specific teacher UID
  List<Map<String, dynamic>> getTeacherStudents(String teacherUid) {
    if (teacherUid.isEmpty) return [];

    return students.where((student) {
      final assignedId =
          student['teacherId'] ??
          student['assignedTeacherId'] ??
          student['teacherUid'];
      return assignedId == teacherUid;
    }).toList();
  }

  /// Retrieves student attendance status for a given session and date
  Map<String, String> getAttendanceStatusForSession(
    String sessionName,
    String studentId,
    String dateStr,
  ) {
    final dateLogs = attendanceLogs[dateStr];

    if (dateLogs != null) {
      final sessionLogs = dateLogs[sessionName];
      if (sessionLogs != null) {
        final status = sessionLogs[studentId];
        if (status != null && status.isNotEmpty) {
          return {"attendanceStatus": status};
        }
      }
    }

    return {"attendanceStatus": "Pending"};
  }

  /// Counts total present or absent students for a specific session on a given date
  int getTotalAttendanceCountForSession(
    String dateStr,
    String statusType, // 'present' or 'absent'
    String sessionName,
  ) {
    final dateLogs = attendanceLogs[dateStr];
    if (dateLogs == null) return 0;

    final sessionLogs = dateLogs[sessionName];
    if (sessionLogs == null) return 0;

    final targetStatus = statusType.toLowerCase();
    int count = 0;

    sessionLogs.forEach((studentId, status) {
      if (status.toLowerCase() == targetStatus) {
        count++;
      }
    });

    return count;
  }

  bool isProgressLogSubmitted(String date, String studentId) {
    return submittedProgressLogs[date]?.contains(studentId) ?? false;
  }

  int getTotalStudentsCount() => students.length;

  int getTotalTeachersCount() =>
      users.where((u) => u['role'] == 'teacher').length;

  int getTotalSessionsCount() => availableSessions.length;

  List<String> getAvailableSessionsNames() {
    return availableSessions.map((s) => s["name"].toString()).toList();
  }

  Map<String, Map<String, String>> getAttendanceLogsForDate(String date) {
    return attendanceLogs[date] ?? {};
  }

  int getUniquePresentStudentsCount(String date) {
    final dateLogs = attendanceLogs[date];
    if (dateLogs == null || dateLogs.isEmpty) return 0;
    final Map<String, List<String>> studentStatuses = _groupStudentStatuses(
      dateLogs,
    );

    int count = 0;
    studentStatuses.forEach((_, statuses) {
      if (statuses.every((s) => s.toLowerCase() == 'present')) count++;
    });
    return count;
  }

  int getPartialPresentStudentsCount(String date) {
    final dateLogs = attendanceLogs[date];
    if (dateLogs == null || dateLogs.isEmpty) return 0;
    final Map<String, List<String>> studentStatuses = _groupStudentStatuses(
      dateLogs,
    );

    int count = 0;
    studentStatuses.forEach((_, statuses) {
      final hasPresent = statuses.any((s) => s.toLowerCase() == 'present');
      final hasNonPresent = statuses.any((s) => s.toLowerCase() != 'present');
      if (hasPresent && hasNonPresent) count++;
    });
    return count;
  }

  int getUniqueAbsentStudentsCount(String date) {
    final dateLogs = attendanceLogs[date];
    if (dateLogs == null || dateLogs.isEmpty) return 0;
    final Map<String, List<String>> studentStatuses = _groupStudentStatuses(
      dateLogs,
    );

    int count = 0;
    studentStatuses.forEach((_, statuses) {
      if (statuses.every((s) => s.toLowerCase() == 'absent')) count++;
    });
    return count;
  }

  int getTotalSessionsCountForDate(String date) {
    final dateLogs = attendanceLogs[date];
    if (dateLogs == null) return 0;
    return dateLogs.keys.length;
  }

  Map<String, List<String>> _groupStudentStatuses(
    Map<String, Map<String, String>> dateLogs,
  ) {
    final Map<String, List<String>> studentStatuses = {};
    for (var session in dateLogs.values) {
      session.forEach((studentId, status) {
        studentStatuses.putIfAbsent(studentId, () => []).add(status);
      });
    }
    return studentStatuses;
  }

  void markSessionsSubmitted(String dateKey, List<String> sessionNames) {
    submittedSessions.putIfAbsent(dateKey, () => {}).addAll(sessionNames);
    notifyListeners();
  }

  // ==========================================
  // SHARED PREFERENCES LOCAL CACHE HELPERS
  // ==========================================

  Future<void> _saveToPrefs(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(data));
  }

  Future<void> _cacheSessionsLocally() async {
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
  }

  Future<void> _cacheSubmissionsLocally() async {
    final Map<String, List<String>> encodableSubmissions = {};
    submittedProgressLogs.forEach((date, studentsSet) {
      encodableSubmissions[date] = studentsSet.toList();
    });
    await _saveToPrefs(_keySubmissions, encodableSubmissions);
  }

  Future<void> _loadFromLocalCache() async {
    final prefs = await SharedPreferences.getInstance();

    final cachedUsers = prefs.getString(_keyUsers);
    if (cachedUsers != null) {
      users = List<Map<String, dynamic>>.from(jsonDecode(cachedUsers));
    }

    final cachedStudents = prefs.getString(_keyStudents);
    if (cachedStudents != null) {
      students = List<Map<String, dynamic>>.from(jsonDecode(cachedStudents));
    }

    final cachedLogs = prefs.getString(_keyProgressLogs);
    if (cachedLogs != null) {
      progressLogs = List<Map<String, dynamic>>.from(jsonDecode(cachedLogs));
    }

    final cachedSubmissions = prefs.getString(_keySubmissions);
    if (cachedSubmissions != null) {
      final Map<String, dynamic> decoded = jsonDecode(cachedSubmissions);
      submittedProgressLogs.clear();
      decoded.forEach((date, studentList) {
        if (studentList is List) {
          submittedProgressLogs[date] = Set<String>.from(studentList);
        }
      });
    }

    final cachedExams = prefs.getString(_keyExams);
    if (cachedExams != null) {
      exams = List<Map<String, dynamic>>.from(jsonDecode(cachedExams));
    }
  }

  /// Clears stored user session data upon logout
  Future<void> clearLoginInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUid);
    await prefs.remove(_keyRole);
    await prefs.setBool(_keyIsLoggedIn, false);
    notifyListeners();
  }

  /// Returns all progress logs filtered by a specific student ID
  List<Map<String, dynamic>> getProgressLogsForStudent(String studentId) {
    return progressLogs.where((log) => log['studentId'] == studentId).toList();
  }

  /// Calculates total attendance count for a student by status ('Present' or 'Absent')
  int getTotalAttendanceCountForStudent(String studentId, String status) {
    int count = 0;
    final targetStatus = status.trim().toLowerCase();

    attendanceLogs.forEach((dateKey, sessionsMap) {
      sessionsMap.forEach((sessionName, studentAttendanceMap) {
        if (studentAttendanceMap.containsKey(studentId)) {
          final studentStatus = studentAttendanceMap[studentId]
              ?.trim()
              .toLowerCase();
          if (studentStatus == targetStatus) {
            count++;
          }
        }
      });
    });

    return count;
  }

  /// Error message field required by UI for state reporting
  String? errorMessage;

  /// Alias getter to provide direct access to students list for directory views
  List<Map<String, dynamic>> get directoryStudents => students;

  /// Fetches directory students by re-notifying listeners or triggering listener sync
  Future<void> fetchDirectoryStudents() async {
    try {
      errorMessage = null;
      notifyListeners();
      // Data is synced in real-time via _listenToStudents()
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Resolves a user's full name given their UID from local state or Firestore fallback
  Future<String> getUsersNameById(String uid) async {
    if (uid.isEmpty || uid == "N/A") return "Unknown User";

    // 1. Search in-memory state first
    final userMap = users.firstWhere((u) => u['uid'] == uid, orElse: () => {});

    if (userMap.isNotEmpty && userMap['name'] != null) {
      return userMap['name'].toString();
    }

    // 2. Fetch directly from Firestore fallback if not present in memory
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!['name']?.toString() ?? "Unknown User";
      }
    } catch (e) {
      debugPrint("Error fetching user name by ID: $e");
    }

    return "Unknown User";
  }

  // ==========================================
  // PARENT / CHILD SCREEN HELPERS
  // ==========================================
  int _selectedChildIndex = 0;
  Map<String, dynamic> _todayReport = {};

  // State Getters
  int get selectedChildIndex => _selectedChildIndex;
  Map<String, dynamic> get todayReport => _todayReport;

  /// Helper to safely extract String ID from dynamic values or Maps
  String _extractStringId(dynamic value) {
    if (value is Map) {
      return value['id']?.toString() ?? value['uid']?.toString() ?? '';
    }
    return value?.toString() ?? '';
  }

  /// Returns students assigned to the logged-in parent
  List<Map<String, dynamic>> get children {
    if (currentUserId.isNotEmpty) {
      return getChildrenForParent(currentUserId);
    }
    return students;
  }

  /// Returns currently selected child map
  Map<String, dynamic>? get selectedChild {
    final list = children;
    if (list.isNotEmpty && _selectedChildIndex < list.length) {
      return list[_selectedChildIndex];
    }
    return null;
  }

  /// Retrieves students assigned to a specific parent ID
  List<Map<String, dynamic>> getChildrenForParent(String parentUid) {
    if (parentUid.isEmpty) return [];

    return students.where((student) {
      dynamic pId = student['parentId'] ?? student['assignedParentId'];
      String extractedId = _extractStringId(pId);
      return extractedId == parentUid;
    }).toList();
  }

  /// Fetches today's report map for a specific student ID
  Map<String, dynamic> getTodayReport(String studentId) {
    final String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final todayLog = progressLogs.firstWhere(
      (log) =>
          _extractStringId(log['studentId']) == studentId &&
          log['date'] == todayStr,
      orElse: () => {},
    );

    String attendanceStatus = "Not Logged";
    final todayAttendance = attendanceLogs[todayStr];

    if (todayAttendance != null) {
      for (var session in todayAttendance.values) {
        if (session.containsKey(studentId)) {
          attendanceStatus = session[studentId]?.toString() ?? "Not Logged";
          break;
        }
      }
    }

    if (todayLog.isEmpty && attendanceStatus == "Not Logged") {
      return {'attendance': "Not Logged"};
    }

    return {...todayLog, 'attendance': attendanceStatus};
  }

  /// Loads children list for logged-in parent and fetches initial report
  Future<void> loadChildrenAndReports() async {
    parentLoading = true;
    notifyListeners();

    try {
      final sp = await SharedPreferences.getInstance();
      currentUserId = sp.getString(_keyUid) ?? "";

      final parentChildren = getChildrenForParent(currentUserId);

      if (parentChildren.isNotEmpty) {
        _selectedChildIndex = 0;
        final rawId = parentChildren[0]['studentId'] ?? parentChildren[0]['id'];
        final firstChildId = _extractStringId(rawId);

        fetchTodayReportForChild(firstChildId);
      } else {
        _todayReport.clear();
      }
    } catch (e) {
      debugPrint("Error loading children and reports: $e");
    } finally {
      parentLoading = false;
      notifyListeners();
    }
  }

  /// Changes selected child index and updates report
  void selectChild(int index) {
    final list = children;
    if (index < 0 || index >= list.length) return;

    _selectedChildIndex = index;

    final rawId = list[index]['studentId'] ?? list[index]['id'];
    final childId = _extractStringId(rawId);

    fetchTodayReportForChild(childId);
    notifyListeners();
  }

  /// Updates current daily report state for child
  void fetchTodayReportForChild(String studentId) {
    try {
      final report = getTodayReport(studentId);
      if (report['attendance'] == "Not Logged" && report.length == 1) {
        _todayReport = {};
      } else {
        _todayReport = Map<String, dynamic>.from(report);
      }
    } catch (e) {
      _todayReport = {};
    }
    notifyListeners();
  }
  // ==========================================
  // REPORTS & ANALYTICS FIRESTORE HELPERS
  // ==========================================

  /// Returns exam results mapping for a given [examId]
  Map<String, Map<String, dynamic>> getResultsForExam(String examId) {
    return examResultsByExamId[examId] ?? {};
  }

  /// Returns history logs filtered for a specific [studentId] sorted by date
  List<Map<String, dynamic>> getHistoryLogsForStudent(String studentId) {
    final studentLogs = progressLogs
        .where((log) => log['studentId'] == studentId)
        .toList();

    return studentLogs.map((log) {
      final String logDate = log['date'] ?? '';

      // Determine attendance status for log date
      String attendanceStatus = "Not Logged";
      final dateAttendance = attendanceLogs[logDate];
      if (dateAttendance != null) {
        for (var session in dateAttendance.values) {
          if (session.containsKey(studentId)) {
            attendanceStatus = session[studentId] ?? "Not Logged";
            break;
          }
        }
      }

      // Collect remarks into structured grade array
      final List<String> grades = [
        log['sabaqRemark']?.toString() ?? '',
        log['sabqiRemark']?.toString() ?? '',
        log['manzilRemark']?.toString() ?? '',
      ];

      return {...log, 'attendance': attendanceStatus, 'grade': grades};
    }).toList();
  }

  /// Returns analytics overview metrics for a specific [studentId]
  Map<String, dynamic> getStudentAnalytics(String studentId) {
    int totalPresents = 0;
    int totalAbsents = 0;
    int totalClasses = 0;
    int totalNewPages = 0;

    // Calculate attendance metrics across logged sessions
    attendanceLogs.forEach((_, sessionsMap) {
      for (var studentMap in sessionsMap.values) {
        if (studentMap.containsKey(studentId)) {
          totalClasses++;
          final status = studentMap[studentId]?.trim().toLowerCase();
          if (status == 'present') {
            totalPresents++;
          } else if (status == 'absent') {
            totalAbsents++;
          }
        }
      }
    });

    // Calculate total pages/lines learned from student progress logs
    final studentLogs = progressLogs.where(
      (log) => log['studentId'] == studentId,
    );
    for (var log in studentLogs) {
      final sabaq = log['sabaq'];
      if (sabaq is Map && sabaq.containsKey('lines')) {
        final linesNum = int.tryParse(sabaq['lines'].toString()) ?? 0;
        totalNewPages += (linesNum / 15)
            .round(); // Converts 15 lines per standard page
      }
    }

    final double attendanceRate = totalClasses > 0
        ? (totalPresents / totalClasses)
        : 0.0;
    final double hifzProgressPercent = (totalNewPages / 604).clamp(
      0.0,
      1.0,
    ); // 604 total Quran pages

    return {
      'totalClasses': totalClasses,
      'totalPresents': totalPresents,
      'totalAbsents': totalAbsents,
      'attendanceRate': attendanceRate,
      'totalNewPages': totalNewPages,
      'hifzProgressPercent': hifzProgressPercent,
    };
  }

  /// Returns monthly calendar attendance statuses for a specific [studentId]
  List<String> getMonthlyCalendarAttendance(String studentId) {
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final List<String> calendarStatuses = [];

    for (int day = 1; day <= daysInMonth; day++) {
      final String dateKey = DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime(now.year, now.month, day));
      final dateLogs = attendanceLogs[dateKey];

      String dayStatus = "unlogged";
      if (dateLogs != null) {
        for (var session in dateLogs.values) {
          if (session.containsKey(studentId)) {
            final status = session[studentId]?.trim().toLowerCase();
            if (status == 'present') {
              dayStatus = "present";
              break;
            } else if (status == 'absent') {
              dayStatus = "absent";
            }
          }
        }
      }
      calendarStatuses.add(dayStatus);
    }

    return calendarStatuses;
  }
  // ==========================================
  // EXAM FIRESTORE CRUD OPERATIONS
  // ==========================================

  /// Adds a new exam schedule to Firestore
  Future<void> addExamToFirestore(Map<String, dynamic> exam) async {
    final docRef = _db.collection('exams').doc();
    await docRef.set({
      "title": exam["title"] ?? "",
      "date": exam["date"] is DateTime
          ? Timestamp.fromDate(exam["date"])
          : Timestamp.fromDate(DateTime.now()),
      "type": exam["type"] ?? "Oral",
      "createdAt": FieldValue.serverTimestamp(),
    });
    _saveToPrefs(_keyExams, exams);
  }

  /// Updates an existing exam in Firestore by document ID
  Future<void> updateExamInFirestore(Map<String, dynamic> exam) async {
    final String examId = exam["id"] ?? "";
    if (examId.isEmpty) return;

    await _db.collection('exams').doc(examId).update({
      "title": exam["title"] ?? "",
      "date": exam["date"] is DateTime
          ? Timestamp.fromDate(exam["date"])
          : Timestamp.fromDate(DateTime.now()),
      "type": exam["type"] ?? "Oral",
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  /// Deletes an exam document from Firestore by document ID
  Future<void> deleteExamFromFirestore(String examId) async {
    if (examId.isEmpty) return;
    await _db.collection('exams').doc(examId).delete();
  }

  // ==========================================
  // MISSING SESSION HANDLERS & PROPERTIES
  // ==========================================

  /// Getter to check if an error message exists
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  /// Alias property for accessing available sessions from UI
  List<Map<String, dynamic>> get sessions => availableSessions;

  /// Triggered manually to reload or fetch session state
  Future<void> loadSessions() async {
    try {
      errorMessage = null;
      isLoading = true;
      notifyListeners();

      // Active listeners handle updates automatically,
      // but reading local cache ensures instant availability
      final prefs = await SharedPreferences.getInstance();
      final cachedSessions = prefs.getString(_keySessions);
      if (cachedSessions != null) {
        final List<dynamic> decoded = jsonDecode(cachedSessions);
        availableSessions = decoded.map((s) {
          return {
            "id": s["id"],
            "name": s["name"] ?? "",
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
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Adds a new session to Firestore
  Future<void> addSession(Map<String, dynamic> sessionData) async {
    try {
      final startTime = sessionData['startTime'] as TimeOfDay?;
      final endTime = sessionData['endTime'] as TimeOfDay?;

      final docRef = _db
          .collection('sessions')
          .doc(
            sessionData['id'] ??
                DateTime.now().millisecondsSinceEpoch.toString(),
          );

      await docRef.set({
        "name": sessionData['name'] ?? "",
        "startHour": startTime?.hour ?? 8,
        "startMinute": startTime?.minute ?? 0,
        "endHour": endTime?.hour ?? 10,
        "endMinute": endTime?.minute ?? 0,
        "createdAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Updates an existing session in Firestore by document ID
  Future<void> updateSessionById(
    String id,
    Map<String, dynamic> sessionData,
  ) async {
    try {
      if (id.isEmpty) return;
      final startTime = sessionData['startTime'] as TimeOfDay?;
      final endTime = sessionData['endTime'] as TimeOfDay?;

      await _db.collection('sessions').doc(id).update({
        "name": sessionData['name'] ?? "",
        "startHour": startTime?.hour ?? 8,
        "startMinute": startTime?.minute ?? 0,
        "endHour": endTime?.hour ?? 10,
        "endMinute": endTime?.minute ?? 0,
        "updatedAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Deletes a session document from Firestore by document ID
  Future<void> deleteSessionById(String id) async {
    try {
      if (id.isEmpty) return;
      await _db.collection('sessions').doc(id).delete();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  // ==========================================
  // EXAM RESULTS & GETTER HELPERS
  // ==========================================

  /// Alias getter for exams required by PublishResultsScreen
  List<Map<String, dynamic>> get availableExams => exams;

  /// Alias getter for all students list
  List<Map<String, dynamic>> get allStudents => students;

  /// Saves or updates a single student's exam result in Firestore
  Future<void> saveStudentResult({
    required String examId,
    required String studentId,
    required Map<String, dynamic> resultData,
  }) async {
    try {
      if (examId.isEmpty || studentId.isEmpty) return;

      // Update local state map instantly for immediate UI updates
      examResultsByExamId.putIfAbsent(examId, () => {});
      examResultsByExamId[examId]![studentId] = resultData;
      notifyListeners();

      // Persist to Firestore: collection 'exam_results' -> doc(examId) -> subcollection 'student_results' -> doc(studentId)
      await _db
          .collection('exam_results')
          .doc(examId)
          .collection('student_results')
          .doc(studentId)
          .set({
            ...resultData,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Persists a list of graded student results to Firestore in a batch write
  Future<void> saveBulkResultsForExam({
    required String examId,
    required List<Map<String, dynamic>> studentResults,
  }) async {
    try {
      if (examId.isEmpty || studentResults.isEmpty) return;

      isLoading = true;
      notifyListeners();

      final WriteBatch batch = _db.batch();

      for (var result in studentResults) {
        final String studentId = result['studentId']?.toString() ?? '';
        if (studentId.isEmpty) continue;

        // Update local state
        examResultsByExamId.putIfAbsent(examId, () => {});
        examResultsByExamId[examId]![studentId] = result;

        // Queue Firestore write doc
        final docRef = _db
            .collection('exam_results')
            .doc(examId)
            .collection('student_results')
            .doc(studentId);

        batch.set(docRef, {
          ...result,
          'publishedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // Commit all results in a single transaction network call
      await batch.commit();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ==========================================
  // MANAGE USERS HELPERS & FIRESTORE METHODS
  // ==========================================

  /// Get teacher name list and ID list
  Map<String, List<String>> get teachersData {
    final teachers = users.where((u) => u['role'] == 'teacher').toList();
    return {
      'name': teachers.map((u) => u['name']?.toString() ?? '').toList(),
      'uid': teachers.map((u) => u['id']?.toString() ?? '').toList(),
    };
  }

  /// Get parent name list and ID list
  Map<String, List<String>> get parentsData {
    final parents = users.where((u) => u['role'] == 'parent').toList();
    return {
      'name': parents.map((u) => u['name']?.toString() ?? '').toList(),
      'uid': parents.map((u) => u['id']?.toString() ?? '').toList(),
    };
  }

  /// Helper list for students matching legacy format
  List<Map<String, dynamic>> get studentsLegacyFormat => students;

  /// Assign teacher and parent relationships to a student
  Future<void> assignStudentRelationships({
    required String studentId,
    required String teacherName,
    required String parentName,
    required String teacherId,
    required String parentId,
  }) async {
    try {
      final index = students.indexWhere((s) => s['id'] == studentId);
      if (index != -1) {
        students[index]['teacher'] = teacherName;
        students[index]['parent'] = parentName;
        students[index]['teacherId'] = teacherId;
        students[index]['parentId'] = parentId;
        notifyListeners();
      }

      await _db.collection('students').doc(studentId).update({
        'teacher': teacherName,
        'parent': parentName,
        'teacherId': teacherId,
        'parentId': parentId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Add a new user (Student, Teacher, or Parent)
  Future<void> createManagedUser({
    required String name,
    required String role,
    String? email,
    String? phone,
    String? password,
  }) async {
    FirebaseApp? tempApp;
    try {
      final String formattedRole = role.toLowerCase().trim();

      if (formattedRole == 'student') {
        // --- STUDENT LOGIC (No Auth required) ---
        final docRef = _db.collection('students').doc();
        final String generatedId = docRef.id;

        final newStudent = {
          'id': generatedId,
          'name': name.trim(),
          'teacher': 'Unassigned',
          'parent': 'Unassigned',
          'teacherId': 'Unassigned',
          'parentId': 'Unassigned',
        };

        await docRef.set({
          ...newStudent,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Update local state list if not handled by real-time streams
        students.add(newStudent);
      } else {
        // --- TEACHER / PARENT LOGIC (Requires Auth + Users doc) ---
        if (email == null || email.trim().isEmpty) {
          throw Exception("Email is required for $formattedRole account.");
        }
        if (password == null || password.trim().isEmpty) {
          throw Exception("Password is required for $formattedRole account.");
        }

        // 1. Initialize secondary app so current Admin is not logged out
        tempApp = await Firebase.initializeApp(
          name: 'TempUserAuth_${DateTime.now().millisecondsSinceEpoch}',
          options: Firebase.app().options,
        );

        // 2. Register user credentials in Firebase Auth
        UserCredential userCredential =
            await FirebaseAuth.instanceFor(
              app: tempApp,
            ).createUserWithEmailAndPassword(
              email: email.trim(),
              password: password.trim(),
            );

        final String? uid = userCredential.user?.uid;

        if (uid != null) {
          final newUser = {
            'id': uid,
            'uid': uid,
            'name': name.trim(),
            'email': email.trim(),
            'role': formattedRole,
            'phone': phone?.trim() ?? '',
          };

          // 3. Save details under users/{UID} in Firestore
          await _db.collection('users').doc(uid).set({
            ...newUser,
            'createdAt': FieldValue.serverTimestamp(),
          });

          // Update local state list if not handled by real-time streams
          users.add(newUser);
        }
      }

      notifyListeners();
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message ?? e.code;
      notifyListeners();
      rethrow;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      // Clean up secondary Firebase app instance
      await tempApp?.delete();
    }
  }

  /// Remove a user (Teacher or Parent)
  Future<void> deleteManagedUser(String userId, String role) async {
    try {
      users.removeWhere((u) => u['id'] == userId);
      notifyListeners();

      await _db.collection('users').doc(userId).delete();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  String getParentPhone(String parentId) {
    if (parentId.isEmpty || parentId == 'Unassigned') {
      return "N/A";
    }

    // Look up parent in memory by matching parentId to user's uid or id
    final parent = users.firstWhere(
      (u) => (u['uid'] == parentId || u['id'] == parentId),
      orElse: () => {},
    );

    if (parent.isEmpty) {
      debugPrint("Parent not found for parentId: $parentId");
      return "N/A";
    }

    // Extract phone number from stored fields
    final phone = parent['phone'] ?? parent['phoneNumber'];

    if (phone != null && phone.toString().trim().isNotEmpty) {
      return phone.toString();
    }

    return "N/A";
  }

  @override
  void dispose() {
    _usersSub?.cancel();
    _studentsSub?.cancel();
    _sessionsSub?.cancel();
    _attendanceSub?.cancel();
    _progressSub?.cancel();
    _submissionsSub?.cancel();
    _examsSub?.cancel();
    super.dispose();
  }
}
