import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halaqat/features/auth/presentation/login_screen.dart';
import 'package:halaqat/features/daily_logging/presentation/student_history_screen.dart';
import 'teacher_dashboard.dart'; // Imports Tab 1

class TeacherMainNavigation extends StatefulWidget {
  const TeacherMainNavigation({super.key});

  @override
  State<TeacherMainNavigation> createState() => _TeacherMainNavigationState();
}

class _TeacherMainNavigationState extends State<TeacherMainNavigation> {
  int _selectedIndex = 0;

  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      const TeacherDashboardTab(), // Tab 1
      const StudentDirectoryTab(), // Tab 2
      const TeacherSettingsTab(), // Tab 3
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _tabs),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                indicatorColor: const Color(0xFF0A5C36).withOpacity(0.1),
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A5C36),
                    );
                  }
                  return const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  );
                }),
              ),
              child: NavigationBar(
                height: 65,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                destinations: [
                  NavigationDestination(
                    icon: const Icon(
                      Icons.today_outlined,
                      color: Color(0xFF64748B),
                    ),
                    selectedIcon: const Icon(
                      Icons.today,
                      color: Color(0xFF0A5C36),
                    ),
                    label: 'today_sheet'.tr(),
                  ),
                  NavigationDestination(
                    icon: const Icon(
                      Icons.import_contacts_outlined,
                      color: Color(0xFF64748B),
                    ),
                    selectedIcon: const Icon(
                      Icons.import_contacts,
                      color: Color(0xFF0A5C36),
                    ),
                    label: 'directory'.tr(),
                  ),
                  NavigationDestination(
                    icon: const Icon(
                      Icons.tune_outlined,
                      color: Color(0xFF64748B),
                    ),
                    selectedIcon: const Icon(
                      Icons.tune,
                      color: Color(0xFF0A5C36),
                    ),
                    label: 'settings'.tr(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================= Tab 2: Student Directory =================
class StudentDirectoryTab extends StatelessWidget {
  const StudentDirectoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(title: Text('directory'.tr())),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        physics: const BouncingScrollPhysics(),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.015),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF0A5C36).withOpacity(0.1),
                child: const Icon(Icons.person, color: Color(0xFF0A5C36)),
              ),
              title: Text(
                index == 0 ? "Hussein Muhammad" : "Student Name $index",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text("Para ${index + 1}"),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF94A3B8),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentHistoryScreen(
                      student: {
                        'name': 'Hussein Muhammad',
                        'para': 1,
                        'parentPhone': '03420530847',
                        'parent': 'Ahmed Muhammad',
                      },
                    ), // Pass student data
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ================= Tab 3: Settings =================
class TeacherSettingsTab extends StatelessWidget {
  const TeacherSettingsTab({super.key});

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
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF0A5C36),
                    child: const Text(
                      "T",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Qari Ahmed",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Halaqa A",
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                        ),
                      ),
                    ],
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
                    onTap: () {
                      // Handle log out
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
