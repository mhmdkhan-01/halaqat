import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halaqat/features/auth/presentation/login_screen.dart';
import 'package:halaqat/features/daily_logging/presentation/attendance_tab.dart';
import 'package:halaqat/features/daily_logging/presentation/student_history_screen.dart';
import 'package:halaqat/features/progress_tracking/data/app_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      const AttendanceTab(), // Tab 3
      const TeacherSettingsTab(), // Tab 4
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
                      Icons.list_alt_outlined,
                      color: Color(0xFF64748B),
                    ),
                    selectedIcon: const Icon(
                      Icons.list_alt,
                      color: Color(0xFF0A5C36),
                    ),
                    label: 'attendance'.tr(),
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
class StudentDirectoryTab extends StatefulWidget {
  const StudentDirectoryTab({super.key});

  @override
  State<StudentDirectoryTab> createState() => _StudentDirectoryTabState();
}

class _StudentDirectoryTabState extends State<StudentDirectoryTab> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allStudents = [];
  List<Map<String, dynamic>> _filteredStudents = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchStudents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await AppData.getDirectoryStudents();
      setState(() {
        _allStudents = data;
        _filteredStudents = data;
        _isLoading = false;
      });
      // Re-apply search filter if user pulled-to-refresh while searching
      if (_searchController.text.isNotEmpty) {
        _onSearchChanged();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredStudents = List.from(_allStudents);
      } else {
        _filteredStudents = _allStudents.where((student) {
          final name = (student['name'] ?? '').toString().toLowerCase();
          final para = (student['para'] ?? '').toString().toLowerCase();
          return name.contains(query) || para.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        title: Text('directory'.tr()),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchStudents,
        color: const Color(0xFF0A5C36),
        child: Column(
          children: [
            // Search Input Field
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search student or para...",
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF94A3B8),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: Color(0xFF94A3B8),
                          ),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Content Area
            Expanded(child: _buildBodyContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0A5C36)),
      );
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Error loading directory: $_errorMessage",
                style: const TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }

    if (_filteredStudents.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          Center(
            child: Text(
              _searchController.text.isEmpty
                  ? "No students found in AppData."
                  : "No matching students found.",
              style: const TextStyle(color: Color(0xFF94A3B8)),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      itemCount: _filteredStudents.length,
      itemBuilder: (context, index) {
        final student = _filteredStudents[index];

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
              student['name'] ?? 'Unknown',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF1E293B),
              ),
            ),
            subtitle: Text(
              "Para ${student['para']}",
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF94A3B8),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentHistoryScreen(student: student),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ================= Tab 3: Settings =================
class TeacherSettingsTab extends StatefulWidget {
  const TeacherSettingsTab({super.key});

  @override
  State<TeacherSettingsTab> createState() => _TeacherSettingsTabState();
}

class _TeacherSettingsTabState extends State<TeacherSettingsTab> {
  bool isLoading = true;
  late String tuid;
  late String teacherName;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTeacherUid();
  }

  Future<void> getTeacherUid() async {
    var sp = await SharedPreferences.getInstance();
    tuid = sp.getString("uid") ?? "N/A";
    teacherName = await AppData.getUsersNameById(tuid);
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(title: Text('settings'.tr())),
      body: (isLoading)
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                          child: Text(
                            teacherName[0].toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              teacherName,
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
                            context.locale == const Locale('en')
                                ? "English"
                                : "اردو",
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
                          leading: const Icon(
                            Icons.logout,
                            color: Color(0xFF0A5C36),
                          ),
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
                            // Handle log out
                            await AppData.clearLoginInfo();
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
