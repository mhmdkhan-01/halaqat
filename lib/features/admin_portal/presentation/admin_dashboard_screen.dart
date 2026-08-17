import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halaqat/features/admin_portal/presentation/admin_attendance_screen.dart';
import 'package:halaqat/features/admin_portal/presentation/backup_restore_screen.dart';
import 'package:halaqat/features/auth/presentation/login_screen.dart';
import 'package:halaqat/features/progress_tracking/data/app_data.dart';
import 'package:halaqat/features/progress_tracking/presentation/publish_results_screen.dart';

// Imports for your screens
import 'package:halaqat/features/student_management/presentation/manage_users_screen.dart';
import 'package:halaqat/features/progress_tracking/presentation/manage_sessions_screen.dart';
import 'package:halaqat/features/progress_tracking/presentation/exam_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentTab = 0;
  // The main sub-screens the Admin can switch between via Bottom Navigation
  final List<Widget> _screens = [
    const AdminHomeTab(),
    const ManageUsersTab(),
    const ManageAcademicTab(),
    const AdminSettingsTab(), // Added Logout Screen
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentTab, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (index) {
          setState(() {
            _currentTab = index;
          });
        },
        selectedItemColor: const Color(0xFF0A5C36),
        unselectedItemColor: const Color(0xFF94A3B8),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_rounded),
            label: 'overview'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people_alt_rounded),
            label: 'users'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.menu_book_rounded),
            label: 'academic'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_sharp),
            label: 'settings'.tr(),
          ),
        ],
      ),
    );
  }
}

// ==================== TAB 1: OVERVIEW ====================
class AdminHomeTab extends StatelessWidget {
  const AdminHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Sleek Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'admin_panel'.tr(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0A5C36),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'welcome_boss'.tr(),
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  //replacing CircleAvatar with language switcher
                  const CircleAvatar(
                    backgroundColor: Color(0xFF0A5C36),
                    radius: 22,
                    child: Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Overview Stats Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
              ),
              delegate: SliverChildListDelegate([
                _buildSummaryCard(
                  "Total Students",
                  "${AppData.getTotalStudentsCount()}",
                  const Color(0xFF0A5C36),
                  Icons.school,
                ),
                _buildSummaryCard(
                  "Total Teachers",
                  "${AppData.getTotalTeachersCount()}",
                  Colors.blue,
                  Icons.person_pin_rounded,
                ),
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminAttendanceScreen(),
                    ),
                  ),
                  child: _buildSummaryCard(
                    "Total Presents",
                    "${AppData.getTotalAttendanceCount(DateFormat('yyyy-MM-dd').format(DateTime.now()), 'present')}",
                    Colors.orange,
                    Icons.check_circle,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminAttendanceScreen(),
                    ),
                  ),
                  child: _buildSummaryCard(
                    "Total Absents",
                    "${AppData.getTotalAttendanceCount(DateFormat('yyyy-MM-dd').format(DateTime.now()), 'absent')}",
                    Colors.red,
                    Icons.cancel,
                  ),
                ),
              ]),
            ),
          ),

          // Quick Shortcuts Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                top: 28.0,
                bottom: 12.0,
              ),
              child: Text(
                'quick_actions'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
          ),

          // Quick Action Hub Icons
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            sliver: SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(5), // Replaced withOpacity
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  children: [
                    _buildShortcutButton(
                      context,
                      "Add Teacher",
                      Icons.person_add,
                      Colors.teal,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ManageUsersScreen(index: 1),
                          ),
                        );
                      },
                    ),
                    _buildShortcutButton(
                      context,
                      "Add Student",
                      Icons.group_add,
                      Colors.indigo,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ManageUsersScreen(index: 0),
                          ),
                        );
                      },
                    ),
                    _buildShortcutButton(
                      context,
                      "New Session",
                      Icons.add_alarm_rounded,
                      Colors.amber,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManageSessionsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildShortcutButton(
                      context,
                      "Exams",
                      Icons.note_add_rounded,
                      Colors.purple,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ExamManagementScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String count,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4), // Replaced withOpacity
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                count,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(30), // Replaced withOpacity
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== TAB 2: MANAGE USERS ====================
class ManageUsersTab extends StatelessWidget {
  const ManageUsersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("manage_users".tr()),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildManagementCard(
            title: "Manage Teachers",
            subtitle: "Add, update, or remove teachers from the roster",
            icon: Icons.badge_outlined,
            color: Colors.teal,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageUsersScreen(index: 1),
                ),
              );
            },
          ),
          _buildManagementCard(
            title: "Manage Students",
            subtitle: "Register students and assign them to teachers",
            icon: Icons.backpack_outlined,
            color: Colors.indigo,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageUsersScreen(index: 0),
                ),
              );
            },
          ),
          _buildManagementCard(
            title: "Manage Parents / Guardians",
            subtitle: "Link family profiles and assign children to parents",
            icon: Icons.family_restroom_rounded,
            color: Colors.pink,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageUsersScreen(index: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildManagementCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.withAlpha(38),
        ), // Replaced withOpacity
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(30), // Replaced withOpacity
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}

// ==================== TAB 3: MANAGE ACADEMIC ====================
class ManageAcademicTab extends StatelessWidget {
  const ManageAcademicTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("academic_setup".tr()),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildManagementCard(
            title: "Configure Sessions",
            subtitle:
                "Create, edit, or delete active time slots (Sabaq, Sabqi, Manzil)",
            icon: Icons.alarm_on_rounded,
            color: Colors.amber[700]!,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageSessionsScreen(),
                ),
              );
            },
          ),
          _buildManagementCard(
            title: "Exams & Syllabus",
            subtitle: "Schedule monthly, mid-term, or custom exams",
            icon: Icons.event_note_rounded,
            color: Colors.redAccent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExamManagementScreen(),
                ),
              );
            },
          ),
          _buildManagementCard(
            title: "Publish Results",
            subtitle: "Grade and add exam results directly to student files",
            icon: Icons.workspace_premium_rounded,
            color: Colors.purple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PublishResultsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildManagementCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.withAlpha(38),
        ), // Replaced withOpacity
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(30), // Replaced withOpacity
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}

// Ensure your project model paths match these imports
// import 'path/to/app_data.dart';
// import 'path/to/login_screen.dart';

// ================= Tab 3: Settings =================
class AdminSettingsTab extends StatefulWidget {
  const AdminSettingsTab({super.key});

  @override
  State<AdminSettingsTab> createState() => _AdminSettingsTabState();
}

class _AdminSettingsTabState extends State<AdminSettingsTab> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(title: Text('settings'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: const [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFF0A5C36),
                    child: Text(
                      "A",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Text(
                    "Admin",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.015),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Language ListTile
                  ListTile(
                    leading: const Icon(
                      Icons.language,
                      color: Color(0xFF0A5C36),
                    ),
                    title: const Text(
                      "Language / زبان",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    trailing: Text(
                      context.locale == const Locale('en') ? "English" : "اردو",
                      style: const TextStyle(
                        color: Color(0xFF0A5C36),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      if (context.locale == const Locale('en')) {
                        context.setLocale(const Locale('ur'));
                      } else {
                        context.setLocale(const Locale('en'));
                      }
                    },
                  ),

                  const Divider(height: 1, indent: 56),

                  // Import Data ListTile (Automatically restores the latest backup file)
                  ListTile(
                    leading: const Icon(
                      Icons.cloud_sync,
                      color: Color(0xFF0A5C36),
                    ),
                    title: const Text(
                      "Import/Export Data",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Color(0xFF94A3B8),
                    ),
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BackupRestoreScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56),

                  // Log Out ListTile
                  ListTile(
                    leading: const Icon(Icons.logout, color: Color(0xFF0A5C36)),
                    title: const Text(
                      "Log Out",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Color(0xFF94A3B8),
                    ),
                    onTap: () async {
                      await AppData.clearLoginInfo();
                      if (!context.mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
