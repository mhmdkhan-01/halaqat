import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halaqat/features/auth/presentation/login_screen.dart';
import 'package:halaqat/features/progress_tracking/data/app_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Import your reports screen here
import 'parent_reports_screen.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  // Mock data for children
  final List<Map<String, dynamic>> _children = [
    {"name": "Zubair Khan"},
    {"name": "Ayesha Khan"},
  ];

  int _selectedChildIndex = 0;

  // Mock progress data for the selected child
  final Map<String, dynamic> _todayReport = {
    "attendance": "Present",
    "sabaq": "Para 15, Surah Al-Kahf (Ayat 1-20)",
    "sabqi": "Para 14 (Full)",
    "manzil": "Para 5 (Quarter 1)",
    "sabaqgrade": "Excellent",
    "sabqigrade": "Good",
    "manzilgrade": "Needs Practice",
    "teacher_note": "Masha'Allah, excellent tajweed and focus today!",
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadChildrenAndReports();
  }

  Future<void> _loadChildrenAndReports() async {
    var sp = await SharedPreferences.getInstance();

    // Fetch children for the parent (replace with actual parent ID)
    final parentId = sp.getString("uid") ?? ""; // Replace with actual parent ID
    final children = await AppData.getChildrenForParent(parentId);

    if (children.isNotEmpty) {
      setState(() {
        _children.clear();
        _children.addAll(children);
      });

      // Fetch today's report for the first child
      final firstChildId = children[0]['studentId'] ?? "NA";
      final todayReport = await AppData.getTodayReport(firstChildId);
      if (todayReport['attendance'] == "Not Logged") {
        setState(() {
          _todayReport.clear();
        });
        return;
      }

      setState(() {
        _todayReport.clear();
        _todayReport.addAll(todayReport);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedChild = _children[_selectedChildIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Elegant Parent Portal Header
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
                    // Elegant Lang Switcher
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

            // 2. Child Selector (Horizontal Pill List)
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
                      itemCount: _children.length,
                      itemBuilder: (context, index) {
                        final child = _children[index];
                        final isSelected = index == _selectedChildIndex;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedChildIndex = index;
                            });
                          },
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
                                  child['name'],
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

            // 3. Today's Progress Card
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
                          // Top Status Row with Navigation Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedChild['name'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0A5C36),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ParentReportsScreen(
                                                childName:
                                                    selectedChild['name'],
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
                                            decoration:
                                                TextDecoration.underline,
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
                              if (_todayReport['attendance'] == null)
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
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _todayReport['attendance']
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
                          const Divider(height: 30, color: Color(0xFFF1F5F9)),
                          if (_todayReport['attendance'] != null) ...[
                            // Progress Indicators
                            //change here
                            _buildProgressRow(
                              'sabaq'.tr(),
                              _todayReport['sabaq'],
                              _todayReport['sabaqgrade'],
                              Icons.chrome_reader_mode_outlined,
                            ),
                            const SizedBox(height: 16),
                            _buildProgressRow(
                              'sabqi'.tr(),
                              _todayReport['sabqi'],
                              _todayReport['sabqigrade'],
                              Icons.history_edu_outlined,
                            ),
                            const SizedBox(height: 16),
                            _buildProgressRow(
                              'manzil'.tr(),
                              _todayReport['manzil'],
                              _todayReport['manzilgrade'],
                              Icons.star_border_rounded,
                            ),
                          ] else ...[
                            Center(
                              child: Text(
                                'Progress Data is not logged yet.',
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                          // Optional Teacher Note
                          if (_todayReport['teacher_note'] != null) ...[
                            const Divider(height: 30, color: Color(0xFFF1F5F9)),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6F8F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.rate_review_outlined,
                                    color: Color(0xFF0A5C36),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _todayReport['teacher_note'],
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

            // 4. Historical Timeline Header
            // SliverToBoxAdapter(
            //   child: Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 20.0),
            //     child: Text(
            //       'recent_history'.tr(),
            //       style: const TextStyle(
            //         fontSize: 18,
            //         fontWeight: FontWeight.bold,
            //         color: Color(0xFF1E293B),
            //       ),
            //     ),
            //   ),
            // ),

            // 5. Timeline List (SliverList)
            // SliverPadding(
            //   padding: const EdgeInsets.all(20.0),
            //   sliver: SliverList(
            //     delegate: SliverChildBuilderDelegate((context, index) {
            //       final log = _historyLogs[index];
            //       final isAbsent = log['attendance'] == 'Absent';

            //       return IntrinsicHeight(
            //         child: Row(
            //           crossAxisAlignment: CrossAxisAlignment.stretch,
            //           children: [
            //             // Timeline Left Line & Bullet
            //             Column(
            //               children: [
            //                 Container(
            //                   width: 12,
            //                   height: 12,
            //                   decoration: BoxDecoration(
            //                     color: isAbsent
            //                         ? const Color(0xFFEF4444)
            //                         : const Color(0xFF0A5C36),
            //                     shape: BoxShape.circle,
            //                   ),
            //                 ),
            //                 Expanded(
            //                   child: Container(
            //                     width: 2,
            //                     color: const Color(0xFFE2E8F0),
            //                   ),
            //                 ),
            //               ],
            //             ),
            //             const SizedBox(width: 16),

            //             // Card Contents
            //             Expanded(
            //               child: Container(
            //                 margin: const EdgeInsets.only(bottom: 20),
            //                 padding: const EdgeInsets.all(16),
            //                 decoration: BoxDecoration(
            //                   color: Colors.white,
            //                   borderRadius: BorderRadius.circular(16),
            //                   boxShadow: [
            //                     BoxShadow(
            //                       color: Colors.black.withOpacity(0.015),
            //                       blurRadius: 10,
            //                       offset: const Offset(0, 4),
            //                     ),
            //                   ],
            //                 ),
            //                 child: Column(
            //                   crossAxisAlignment: CrossAxisAlignment.start,
            //                   children: [
            //                     Row(
            //                       mainAxisAlignment:
            //                           MainAxisAlignment.spaceBetween,
            //                       children: [
            //                         Text(
            //                           log['date'],
            //                           style: const TextStyle(
            //                             fontWeight: FontWeight.bold,
            //                             fontSize: 14,
            //                             color: Color(0xFF1E293B),
            //                           ),
            //                         ),
            //                         Text(
            //                           log['attendance']
            //                               .toString()
            //                               .toLowerCase()
            //                               .tr(),
            //                           style: TextStyle(
            //                             color: isAbsent
            //                                 ? const Color(0xFFEF4444)
            //                                 : const Color(0xFF10B981),
            //                             fontWeight: FontWeight.bold,
            //                             fontSize: 12,
            //                           ),
            //                         ),
            //                       ],
            //                     ),
            //                     if (!isAbsent) ...[
            //                       const SizedBox(height: 10),
            //                       Text(
            //                         "${'sabaq'.tr()}: ${log['sabaq']}",
            //                         style: const TextStyle(
            //                           fontSize: 13,
            //                           color: Color(0xFF475569),
            //                         ),
            //                       ),
            //                       const SizedBox(height: 4),
            //                       Text(
            //                         "${'sabqi'.tr()}: ${log['sabqi']}",
            //                         style: const TextStyle(
            //                           fontSize: 13,
            //                           color: Color(0xFF64748B),
            //                         ),
            //                       ),
            //                     ],
            //                   ],
            //                 ),
            //               ),
            //             ),
            //           ],
            //         ),
            //       );
            //     }, childCount: _historyLogs.length),
            //   ),
            // ),
            //logout button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 30.0,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to the login screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
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
        ),
      ),
    );
  }

  // Row builder helper for Today's Card
  Widget _buildProgressRow(
    String label,
    String value,
    String grade,
    IconData icon,
  ) {
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
            color: label == "sabaq".tr()
                ? (grade == "Excellent")
                      ? Color(0xFF10B981).withOpacity(0.1)
                      : (grade == "Good")
                      ? Color.fromARGB(255, 16, 86, 185).withOpacity(0.1)
                      : Color(0xFFEF4444).withOpacity(0.1)
                : label == "sabqi".tr()
                ? (grade == "Excellent")
                      ? Color(0xFF10B981).withOpacity(0.1)
                      : (grade == "Good")
                      ? Color.fromARGB(255, 16, 86, 185).withOpacity(0.1)
                      : Color(0xFFEF4444).withOpacity(0.1)
                : (grade == "Excellent")
                ? Color(0xFF10B981).withOpacity(0.1)
                : (grade == "Good")
                ? Color.fromARGB(255, 16, 86, 185).withOpacity(0.1)
                : Color(0xFFEF4444).withOpacity(0.1),
            border: Border.all(
              color: (grade == "Excellent")
                  ? Color(0xFF10B981)
                  : (grade == "Good")
                  ? Color.fromARGB(255, 16, 86, 185)
                  : Color(0xFFEF4444),
              width: 1,
            ),
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
}
