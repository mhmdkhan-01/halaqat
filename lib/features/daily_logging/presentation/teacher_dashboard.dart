import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halaqat/features/progress_tracking/data/app_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'daily_entry_screen.dart';

class TeacherDashboardTab extends StatefulWidget {
  const TeacherDashboardTab({super.key});

  @override
  State<TeacherDashboardTab> createState() => _TeacherDashboardTabState();
}

class _TeacherDashboardTabState extends State<TeacherDashboardTab> {
  // Combine all async initializations into a single Future holder
  late Future<Map<String, dynamic>> _dashboardDataFuture;

  String? _selectedSession;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _dashboardDataFuture = _loadDashboardData();
  }

  // Fetch both sessions and students asynchronously
  Future<Map<String, dynamic>> _loadDashboardData() async {
    final sessions = await AppData.getAvailableSessions();

    final sp = await SharedPreferences.getInstance();
    final String? uid = sp.getString('uid');

    List<Map<String, dynamic>> students = [];
    if (uid != null && uid.isNotEmpty) {
      students = await AppData.getTeacherStudents(uid);
    }

    // Determine initial active session based on current time
    final runningSession = _determineCurrentlyRunningSession(sessions);

    return {
      'sessions': sessions,
      'students': students,
      'runningSession': runningSession,
    };
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
    return SafeArea(
      child: FutureBuilder<Map<String, dynamic>>(
        future: _dashboardDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error loading dashboard: ${snapshot.error}"),
            );
          }

          final data = snapshot.data ?? {};
          final List<Map<String, dynamic>> sessions = data['sessions'] ?? [];
          final List<Map<String, dynamic>> students = data['students'] ?? [];
          final String runningSession =
              data['runningSession'] ?? "Session 1 (Sabaq)";

          // Default selected session to active running session on first load
          _selectedSession ??= runningSession;

          // Filter students based on search query
          final filteredStudents = students.where((student) {
            final name = student['name']?.toString().toLowerCase() ?? '';
            return name.contains(_searchQuery.toLowerCase());
          }).toList();

          // Calculate stats using loaded list
          final totalStudents = filteredStudents.length;

          // Future-ready placeholder for attendance stats
          final presentToday = AppData.getTotalAttendanceCountForSession(
            DateFormat('yyyy-MM-dd').format(DateTime.now()),
            'present',
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
                        'present_today'.tr(),
                        presentToday.toString(),
                        const Color(0xFF10B981),
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        'pending_logs'.tr(),
                        "0",
                        const Color(0xFFF59E0B),
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
                          return _buildStudentCard(student);
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
    final Map<String, dynamic> attendanceRecord =
        AppData.getAttendanceStatusForSession(
          _selectedSession ?? '',
          student["studentId"] ?? '',
          DateFormat('yyyy-MM-dd').format(DateTime.now()),
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
                    student['name'] ?? 'Unnamed',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  subtitle: const Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Text(
                      "Sabaq: Para 1 surah al baqara)",
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
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
                    Navigator.push(
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
