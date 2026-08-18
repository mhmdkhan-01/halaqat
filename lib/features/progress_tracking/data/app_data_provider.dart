import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
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
  StreamSubscription? _examsSub;

  bool isLoading = true;

  // Storage Keys for SharedPreferences (Offline Fallback)
  static const String _keyUsers = "cached_users";
  static const String _keyStudents = "cached_students";
  static const String _keySessions = "cached_sessions";
  static const String _keyProgressLogs = "cached_progress_logs";
  static const String _keyAttendanceLogs = "cached_attendance_logs";
  static const String _keyExams = "cached_exams";
  static const String _keyUid = "uid";
  static const String _keyRole = "cached_role";
  static const String _keyIsLoggedIn = "cached_IsLoggedIn";
  static const String _keyRememberedUsername = 'remembered_username';

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

  Future<void> addUser(
    String uid,
    String name,
    String role,
    String phoneNumber,
    String password,
  ) async {
    await _db.collection('users').doc(uid).set({
      "name": name,
      "role": role,
      "phoneNumber": phoneNumber,
      "password": password,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

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
      "assignedParentName": parent,
      "assignedTeacherName": teacher,
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
      updates['sessions.$session'] = studentAttendance;
    }

    await docRef.set(updates, SetOptions(merge: true));
  }

  Future<void> addProgressLog({
    required String studentId,
    required String studentName,
    required String surah,
    required String para,
    required String lines,
    required String sabqi,
    required String manzil,
    required List<String> remarks,
    required String teacherNote,
  }) async {
    final docRef = _db.collection('progress_logs').doc();
    await docRef.set({
      "logId": docRef.id,
      "studentId": studentId,
      "studentName": studentName,
      "date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
      "attendanceStatus": "present",
      "sabaq": {"surah": surah, "para": para, "lines": lines},
      "sabqi": sabqi,
      "manzil": manzil,
      "grade": remarks,
      "teacherNote": teacherNote,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  // ==========================================
  // READ HELPERS & CALCULATION METRICS
  // ==========================================

  int getTotalStudentsCount() => students.length;
  int getTotalTeachersCount() =>
      users.where((u) => u['role'] == 'teacher').length;

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

  Future<void> _loadFromLocalCache() async {
    final prefs = await SharedPreferences.getInstance();

    final cachedUsers = prefs.getString(_keyUsers);
    if (cachedUsers != null)
      users = List<Map<String, dynamic>>.from(jsonDecode(cachedUsers));

    final cachedStudents = prefs.getString(_keyStudents);
    if (cachedStudents != null)
      students = List<Map<String, dynamic>>.from(jsonDecode(cachedStudents));

    final cachedLogs = prefs.getString(_keyProgressLogs);
    if (cachedLogs != null)
      progressLogs = List<Map<String, dynamic>>.from(jsonDecode(cachedLogs));
  }

  @override
  void dispose() {
    _usersSub?.cancel();
    _studentsSub?.cancel();
    _sessionsSub?.cancel();
    _attendanceSub?.cancel();
    _progressSub?.cancel();
    _examsSub?.cancel();
    super.dispose();
  }
}
