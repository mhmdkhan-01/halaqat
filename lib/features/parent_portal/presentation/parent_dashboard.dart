import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:halaqat/features/auth/presentation/login_screen.dart';
import 'package:halaqat/features/progress_tracking/data/app_data_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'parent_reports_screen.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppDataProvider>().loadChildrenAndReports();
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    final sp = await SharedPreferences.getInstance();
    await sp.clear(); // Clear cached Auth UID & user data
    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      body: SafeArea(
        child: Consumer<AppDataProvider>(
          builder: (context, provider, child) {
            if (provider.parentLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF0A5C36)),
              );
            }

            final children = provider.children;
            final selectedChild = provider.selectedChild;
            final todayReport = provider.todayReport;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. Parent Portal Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'parent_dashboard'.tr(),
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

                // 2. Empty State View if no children exist
                if (children.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.child_care_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "No students assigned to your account yet.",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => _handleLogout(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF4444),
                            ),
                            child: Text('logout'.tr()),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  // 3. Child Selector List
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            'my_children'.tr(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64748B),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: children.length,
                            itemBuilder: (context, index) {
                              final childItem = children[index];
                              final isSelected =
                                  index == provider.selectedChildIndex;
                              return GestureDetector(
                                onTap: () => provider.selectChild(index),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 4,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF0A5C36)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.02),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: isSelected
                                            ? Colors.white24
                                            : const Color(
                                                0xFF0A5C36,
                                              ).withOpacity(0.1),
                                        child: Icon(
                                          Icons.face,
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF0A5C36),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        childItem['name'] ?? '',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF1E293B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 4. Today's Progress Card
                  if (selectedChild != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'today_summary'.tr(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            selectedChild['name'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF0A5C36),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          GestureDetector(
                                            onTap: () {
                                              // Safely extract the student ID string from Map or String
                                              final rawId =
                                                  selectedChild['studentId'] ??
                                                  selectedChild['id'];
                                              final String cleanStudentId =
                                                  _safeExtractId(rawId);

                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ParentReportsScreen(
                                                        childName:
                                                            selectedChild['name']
                                                                ?.toString() ??
                                                            '',
                                                        studentId:
                                                            cleanStudentId,
                                                      ),
                                                ),
                                              );
                                            },
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  "View Report Card",
                                                  style: TextStyle(
                                                    color: Color(0xFF0A5C36),
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    decoration: TextDecoration
                                                        .underline,
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.keyboard_arrow_right,
                                                  size: 16,
                                                  color: Color(0xFF0A5C36),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (todayReport['attendance'] == null)
                                        Text(
                                          'Pending'.tr(),
                                          style: const TextStyle(
                                            color: Color(0xFF64748B),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        )
                                      else
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFF10B981,
                                            ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            todayReport['attendance']
                                                .toString()
                                                .toLowerCase()
                                                .tr(),
                                            style: const TextStyle(
                                              color: Color(0xFF10B981),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const Divider(
                                    height: 30,
                                    color: Color(0xFFF1F5F9),
                                  ),
                                  if (todayReport['attendance'] == null ||
                                      (!todayReport.containsKey('sabaq'))) ...[
                                    Center(child: Text("No data logged")),
                                  ] else if (todayReport['attendance'] !=
                                      null) ...[
                                    _buildProgressRow(
                                      'sabaq'.tr(),
                                      fixedSabaq(todayReport['sabaq'] ?? {}),
                                      todayReport['sabaqRemark']?.toString() ??
                                          '',
                                      Icons.chrome_reader_mode_outlined,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildProgressRow(
                                      'sabqi'.tr(),
                                      todayReport['sabqi']?.toString() ?? '',
                                      todayReport['sabqiRemark']?.toString() ??
                                          '',
                                      Icons.history_edu_outlined,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildProgressRow(
                                      'manzil'.tr(),
                                      todayReport['manzil']?.toString() ?? '',
                                      todayReport['manzilRemark']?.toString() ??
                                          '',
                                      Icons.star_border_rounded,
                                    ),
                                  ] else ...[
                                    const Center(
                                      child: Text(
                                        'Progress Data is not logged yet.',
                                        style: TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 13,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (todayReport['teacher_note'] != null) ...[
                                    const Divider(
                                      height: 30,
                                      color: Color(0xFFF1F5F9),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF6F8F6),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.rate_review_outlined,
                                            color: Color(0xFF0A5C36),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              todayReport['teacher_note'],
                                              style: const TextStyle(
                                                color: Color(0xFF475569),
                                                fontSize: 13,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // 5. Logout Button
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 30.0,
                      ),
                      child: ElevatedButton(
                        onPressed: () => _handleLogout(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Center(
                          child: Text(
                            'logout'.tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressRow(
    String label,
    String value,
    String grade,
    IconData icon,
  ) {
    Color getGradeColor(String grade) {
      if (grade == "Excellent") return const Color(0xFF10B981);
      if (grade == "Good") return const Color.fromARGB(255, 16, 86, 185);
      return const Color(0xFFEF4444);
    }

    final gradeColor = getGradeColor(grade);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF0A5C36).withOpacity(0.7), size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: gradeColor.withOpacity(0.1),
            border: Border.all(color: gradeColor, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            grade,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }

  String _safeExtractId(dynamic rawId) {
    if (rawId == null) return '';
    if (rawId is String) return rawId;
    if (rawId is Map) {
      return (rawId['id'] ?? rawId['studentId'] ?? rawId['_id'] ?? '')
          .toString();
    }
    return rawId.toString();
  }

  String fixedSabaq(Map<String, dynamic> sabaq) {
    if (sabaq.isEmpty) {
      return "";
    }
    return "surah: ${sabaq['surah']}, para: ${sabaq['para']}, lines: ${sabaq['lines']}";
  }
}
