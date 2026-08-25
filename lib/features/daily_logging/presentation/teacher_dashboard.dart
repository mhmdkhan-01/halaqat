import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halaqat/features/progress_tracking/data/app_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'daily_entry_screen.dart';

class TeacherDashboardTab extends StatefulWidget {
  const TeacherDashboardTab({super.key});

  @override
  State<TeacherDashboardTab> createState() => _TeacherDashboardTabState();
}

class _TeacherDashboardTabState extends State<TeacherDashboardTab> {
  String? _selectedSession;
  String _searchQuery = "";
  String? _teacherUid;
  bool _isLoadingUid = true;

  @override
  void initState() {
    super.initState();
    _loadTeacherUid();
  }

  Future<void> _loadTeacherUid() async {
    final sp = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _teacherUid = sp.getString('uid');
        _isLoadingUid = false;
      });
    }
  }

  // Helper method to calculate currently active session from a loaded list
  String _determineCurrentlyRunningSession(
    List<Map<String, dynamic>> sessions,
  ) {
    if (sessions.isEmpty) return "No Sessions Available";

    final now = DateTime.now();
    final currentHour = now.hour;

    for (var session in sessions) {
      final startTime = session["startTime"] as TimeOfDay?;
      final endTime = session["endTime"] as TimeOfDay?;

      if (startTime != null && endTime != null) {
        if (currentHour >= startTime.hour && currentHour < endTime.hour) {
          return session['name'] ?? sessions[0]['name'];
        }
      }
    }

    return sessions[0]['name'] ?? "Session 1 (Sabaq)";
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUid) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: Consumer<AppDataProvider>(
        builder: (context, dataProvider, child) {
          final sessions = dataProvider.getAvailableSessions();
          final runningSession = _determineCurrentlyRunningSession(sessions);

          // Default selected session to active running session on first load
          _selectedSession ??= runningSession;

          final students = dataProvider.getTeacherStudents(_teacherUid ?? '');

          // Filter students based on search query
          final filteredStudents = students.where((student) {
            final name = student['name']?.toString().toLowerCase() ?? '';
            return name.contains(_searchQuery.toLowerCase());
          }).toList();

          final totalStudents = filteredStudents.length;
          final todayDateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

          final presentToday = dataProvider.getTotalAttendanceCountForSession(
            todayDateStr,
            'present',
            _selectedSession!,
          );

          final absentToday = dataProvider.getTotalAttendanceCountForSession(
            todayDateStr,
            'absent',
            _selectedSession!,
          );

          return CustomScrollView(
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
                            color: const Color(0xFF0A5C36).withAlpha(20),
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

              // 2. Dynamic Session Selector
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SizedBox(
                    height: 42,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: sessions.length,
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        final sessionName = session['name'] as String;
                        final isSelected = sessionName == _selectedSession;
                        final isCurrentlyRunning =
                            sessionName == runningSession;

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
                                    ? const Color(0xFF10B981)
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
                                  sessionName,
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
                          color: Colors.black.withAlpha(8),
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
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
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
                        totalStudents.toString(),
                        const Color(0xFF0A5C36),
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        'present'.tr(),
                        presentToday.toString(),
                        const Color(0xFF10B981),
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        'absent'.tr(),
                        absentToday.toString(),
                        const Color(0xFFEF4444),
                      ),
                    ],
                  ),
                ),
              ),

              // 5. List of Students
              filteredStudents.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(30.0),
                          child: Text(
                            "No students found",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final student = filteredStudents[index];
                          return _buildStudentCard(
                            context,
                            student,
                            dataProvider,
                            todayDateStr,
                          );
                        }, childCount: filteredStudents.length),
                      ),
                    ),
            ],
          );
        },
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
              color: Colors.black.withAlpha(5),
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

  Widget _buildStudentCard(
    BuildContext context,
    Map<String, dynamic> student,
    AppDataProvider dataProvider,
    String todayDateStr,
  ) {
    final attendanceRecord = dataProvider.getAttendanceStatusForSession(
      _selectedSession ?? '',
      student["studentId"] ?? '',
      todayDateStr,
    );

    final String currentSessionStatus =
        attendanceRecord["attendanceStatus"] ?? "Pending";

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
            color: Colors.black.withAlpha(5),
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
                    student['name'] ?? 'Unnamed',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      "S/O ${student['parent'] ?? '-'}",
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
                          color: statusColor.withAlpha(25),
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
                  onTap: () async {
                    if (_selectedSession == null || _selectedSession!.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a session first.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    if (currentSessionStatus == "Pending") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please mark attendance for the session first.',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    if (currentSessionStatus == "Absent") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Student is absent for this session.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DailyEntryScreen(
                          studentId: student['studentId'],
                          studentName: student['name'],
                          initialSession: _selectedSession ?? '',
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
