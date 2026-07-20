import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halaqat/features/progress_tracking/data/app_data.dart';
import 'daily_entry_screen.dart'; // Make sure this import matches your daily entry form path

class TeacherDashboardTab extends StatefulWidget {
  const TeacherDashboardTab({super.key});

  @override
  State<TeacherDashboardTab> createState() => _TeacherDashboardTabState();
}

class _TeacherDashboardTabState extends State<TeacherDashboardTab> {
  // 1. Session Configurations with their designated times
  final List<Map<String, dynamic>> _sessions = AppData.availableSessions;

  late String _selectedSession;
  String _searchQuery = "";

  // 2. Updated student records tracking attendance for *each* session individually
  final List<Map<String, dynamic>> _students = [
    {
      "studentId": "1",
      "name": "Hussein Muhammad",
      "para": 15,
      "sura": "Al-Kahf",
      "attendance": {
        "Session 1 (Sabaq)": "Present",
        "Session 2 (Sabqi)": "Pending",
        "Session 3 (Manzil)": "Pending",
      },
    },
    {
      "studentId": "2",
      "name": "Abdullah Ahmed",
      "status": "Present",
      "para": 30,
      "sura": "An-Naba",
      "attendance": {
        "Session 1 (Sabaq)": "Present",
        "Session 2 (Sabqi)": "Present",
        "Session 3 (Manzil)": "Present",
      },
    },
    {
      "studentId": "3",
      "name": "Zubair Khan",
      "status": "Absent",
      "para": 3,
      "sura": "Al-Baqarah",
      "attendance": {
        "Session 1 (Sabaq)": "Absent",
        "Session 2 (Sabqi)": "Absent",
        "Session 3 (Manzil)": "Pending",
      },
    },
    {
      "studentId": "4",
      "name": "Hamza Ali",
      "status": "Pending",
      "para": 1,
      "sura": "Al-Baqarah",
      "attendance": {
        "Session 1 (Sabaq)": "Pending",
        "Session 2 (Sabqi)": "Pending",
        "Session 3 (Manzil)": "Pending",
      },
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedSession = _getCurrentlyRunningSession();
  }

  // 3. Helper to determine which session is currently running based on time
  String _getCurrentlyRunningSession() {
    // 1. Guard against empty list to prevent RangeError on _sessions[0]
    if (_sessions.isEmpty) {
      return "No Sessions Available";
    }

    final now = DateTime.now();
    final currentHour = now.hour;

    for (var session in _sessions) {
      // 2. Safely cast to nullable TimeOfDay to avoid type errors if key is missing or null
      final startTime = session["startTime"] as TimeOfDay?;
      final endTime = session["endTime"] as TimeOfDay?;

      // 3. Ensure both start and end times exist before comparing
      if (startTime != null && endTime != null) {
        if (currentHour >= startTime.hour && currentHour < endTime.hour) {
          return session['name'] ?? _sessions[0]['name'];
        }
      }
    }

    // 4. Safe fallback if current time falls outside defined session blocks
    return _sessions[0]['name'] ?? "Session 1 (Sabaq)";
  }

  // Helper getter to filter students based on search query
  List<Map<String, dynamic>> get _filteredStudents {
    return _students.where((student) {
      return student['name'].toString().toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
    }).toList();
  }

  // 4. Session-specific calculations for the stats cards
  int get _totalStudents => _filteredStudents.length;

  int get _presentTodayInSelectedSession {
    return AppData.getTotalAttendanceCountForSession(
      '',
      'present',
      _getCurrentlyRunningSession(),
    );
  }

  int get _pendingInSelectedSession {
    return _filteredStudents.where((student) {
      final sessionAttendance = student['attendance'] as Map<String, dynamic>;
      return sessionAttendance[_selectedSession] == 'Pending';
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Sleek Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'teacher_dashboard'.tr(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0A5C36),
                      letterSpacing: -0.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (context.locale == const Locale('en')) {
                        context.setLocale(const Locale('ur'));
                      } else {
                        context.setLocale(const Locale('en'));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A5C36).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        context.locale == const Locale('en')
                            ? "اردو"
                            : "English",
                        style: const TextStyle(
                          color: Color(0xFF0A5C36),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Dynamic Session Selector (Highlights the session the teacher is looking at/marking)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SizedBox(
                height: 42,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _sessions.length,
                  itemBuilder: (context, index) {
                    final session = _sessions[index];
                    final sessionName = session['name'] as String;
                    final isSelected = sessionName == _selectedSession;
                    final isCurrentlyRunning =
                        sessionName == _getCurrentlyRunningSession();

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSession = sessionName;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF0A5C36)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isCurrentlyRunning
                                ? const Color(
                                    0xFF10B981,
                                  ) // Highlight the actual active session
                                : (isSelected
                                      ? const Color(0xFF0A5C36)
                                      : const Color(0xFFE2E8F0)),
                            width: isCurrentlyRunning ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isCurrentlyRunning) ...[
                              Icon(
                                Icons.circle,
                                size: 8,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF10B981),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              sessionName.tr(),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // 3. Search Bar
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 8.0,
            ),
            sliver: SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'search_student'.tr(),
                    hintStyle: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 15,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF94A3B8),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
          ),

          // 4. Session-Based Live Stats Card Section
          SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  _buildStatCard(
                    'total_students'.tr(),
                    _totalStudents.toString(),
                    const Color(0xFF0A5C36),
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    'present_today'.tr(),
                    _presentTodayInSelectedSession.toString(),
                    const Color(0xFF10B981),
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    'pending_logs'.tr(),
                    _pendingInSelectedSession.toString(),
                    const Color(0xFFF59E0B),
                  ),
                ],
              ),
            ),
          ),

          // 5. List of Students with Session-Specific Statuses
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final student = _filteredStudents[index];
                return _buildStudentCard(student);
              }, childCount: _filteredStudents.length),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    // Get the student's status *for the selected session*
    final Map<String, dynamic> attendanceRecord = student['attendance'];
    final String currentSessionStatus =
        attendanceRecord[_selectedSession] ?? 'Pending';

    Color statusColor;
    switch (currentSessionStatus) {
      case 'Present':
        statusColor = const Color(0xFF10B981);
        break;
      case 'Absent':
        statusColor = const Color(0xFFEF4444);
        break;
      default:
        statusColor = const Color(0xFFF59E0B);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 5, color: statusColor),
              Expanded(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text(
                    student['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      "Sabaq: Para ${student['para']} (${student['sura']})",
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          currentSessionStatus,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                    ],
                  ),
                  onTap: () {
                    // Send both the student name AND the auto-selected session (based on current time)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DailyEntryScreen(
                          studentId: student['studentId'],
                          studentName: student['name'],
                          // Pass the currently running session to auto-select it in DailyEntryScreen
                          initialSession: _selectedSession,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
