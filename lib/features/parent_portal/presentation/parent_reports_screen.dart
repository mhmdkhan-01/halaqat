import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halaqat/features/progress_tracking/data/app_data.dart';

class ParentReportsScreen extends StatefulWidget {
  final String childName;
  final String studentId;
  const ParentReportsScreen({
    super.key,
    required this.childName,
    required this.studentId,
  });

  @override
  State<ParentReportsScreen> createState() => _ParentReportsScreenState();
}

class _ParentReportsScreenState extends State<ParentReportsScreen> {
  // Central Data Holds
  late List<Map<String, dynamic>> _historyLogs;
  late Map<String, dynamic> _analytics;
  late List<String> _calendarAttendance;
  late List<Map<String, dynamic>> _examResults;

  // Linked mapping key matching our collections

  // --- 1. Updated initState logic ---
  @override
  void initState() {
    super.initState();
    // Synchronize dependencies from AppData repository hooks
    _historyLogs = AppData.getHistoryLogsForStudent(widget.studentId);
    _analytics = AppData.getStudentAnalytics(widget.studentId);
    _calendarAttendance = AppData.getMonthlyCalendarAttendance(
      widget.studentId,
    );

    // Fetch student-specific results across all published exams
    _loadExamResultsForStudent();
  }

  void _loadExamResultsForStudent() {
    final List<Map<String, dynamic>> allExams = AppData.getExams();
    final List<Map<String, dynamic>> studentExamResults = [];

    for (var exam in allExams) {
      final String examId = exam['id']?.toString() ?? '';
      final String examTitle = exam['title'] ?? 'Exam';
      final String examDate = exam['date'].toString().split(' ')[0];

      // Get all results published for this exam
      final Map<String, Map<String, dynamic>> examData =
          AppData.getResultsForExam(examId);

      // Filter to check if a published result exists for this specific student
      if (examData.containsKey(widget.studentId)) {
        final studentResult = examData[widget.studentId]!;

        // Include published grades only
        if (studentResult['isGraded'] == true ||
            studentResult['status'] == 'Published') {
          studentExamResults.add({
            'examName': examTitle,
            'date': examDate,
            'hifzScore': studentResult['hifzScore'] ?? '0',
            'tajweedGrade': studentResult['tajweedGrade'] ?? 'N/A',
            'syllabus': studentResult['syllabus'] ?? '',
            'remarks': studentResult['remarks'] ?? '',
          });
        }
      }
    }

    setState(() {
      _examResults = studentExamResults;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        title: Text(
          'reports_and_analytics'.tr(args: [widget.childName]),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Monthly Performance Key Metrics ---
            _buildSectionHeader("Monthly Analytics Overview"),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAnalyticsCard(
                  "Pages Learnt",
                  "${_analytics['totalNewPages']} Pages",
                  Icons.menu_book_rounded,
                  Colors.teal,
                ),
                _buildAnalyticsCard(
                  "Total Progress",
                  "${(_analytics['hifzProgressPercent'] * 100).toStringAsFixed(0)}%",
                  Icons.analytics_outlined,
                  Colors.indigo,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- 2. Attendance Overview & Tabular Calendar View ---
            _buildSectionHeader("Attendance Summary"),
            const SizedBox(height: 12),
            _buildAttendanceSummaryCard(),
            const SizedBox(height: 12),
            _buildCalendarGridView(),

            const SizedBox(height: 24),

            // --- 3. Complete Daily Progress Logs ---
            _buildSectionHeader("Daily Progress Logs"),
            const SizedBox(height: 12),
            (_historyLogs.isEmpty)
                ? Center(
                    child: Text(
                      'No Data is logged yet.',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _historyLogs.length,
                    itemBuilder: (context, index) {
                      final log = _historyLogs[index];
                      return _buildDailyHistoryCard(log);
                    },
                  ),

            const SizedBox(height: 24),

            // --- 4. Exam Reports Section ---
            _buildSectionHeader("Exam Reports"),
            const SizedBox(height: 12),
            _examResults.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Text(
                        "no_exam_results_found".tr(),
                        style: const TextStyle(color: Color(0xFF64748B)),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _examResults.length,
                    itemBuilder: (context, index) {
                      final exam = _examResults[index];
                      final String score = exam['hifzScore'].toString();
                      final String formattedScore = score.contains('/')
                          ? score
                          : "$score/100";

                      return _buildExamCard(
                        examName: exam['examName'] ?? "Hifz Assessment",
                        date: exam['date'] ?? "N/A",
                        grade: exam['tajweedGrade'].toString().isEmpty
                            ? "N/A"
                            : exam['tajweedGrade'],
                        score: formattedScore,
                        subjectDetails: exam['remarks'].toString().isNotEmpty
                            ? "${'remarks'.tr()}: ${exam['remarks']}"
                            : (exam['syllabus'].toString().isNotEmpty
                                  ? "${'syllabus'.tr()}: ${exam['syllabus']}"
                                  : "no_remarks".tr()),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  // --- Helper Layout Elements ---

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
    ).tr();
  }

  Widget _buildAnalyticsCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.43,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSummaryCard() {
    double rate = _analytics['attendanceRate'] as double;
    debugPrint("Rate $rate");
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 74,
                height: 74,
                child: CircularProgressIndicator(
                  value: rate,
                  strokeWidth: 7,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF0A5C36),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${(rate * 100).floor()}%",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const Text(
                    "Rate",
                    style: TextStyle(fontSize: 9, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: [
                _buildAttendanceMetricRow(
                  "Total Classes",
                  "${_analytics['totalClasses']}",
                  const Color(0xFF1E293B),
                ),
                const Divider(height: 10),
                _buildAttendanceMetricRow(
                  "Presents",
                  "${_analytics['totalPresents']}",
                  const Color(0xFF10B981),
                ),
                const Divider(height: 10),
                _buildAttendanceMetricRow(
                  "Absents",
                  "${_analytics['totalAbsents']}",
                  const Color(0xFFEF4444),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGridView() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Monthly Attendance Log Calendar",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _calendarAttendance.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final status = _calendarAttendance[index];

              Color dayColor = const Color(0xFF10B981); // present
              if (status == "absent") dayColor = const Color(0xFFEF4444);
              if (status == "unlogged") dayColor = const Color(0xFFE2E8F0);

              return Container(
                decoration: BoxDecoration(
                  color: dayColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: dayColor.withOpacity(0.3)),
                ),
                alignment: Alignment.center,
                child: Text(
                  "${index + 1}",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: status == "unlogged" ? Colors.grey : dayColor,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDailyHistoryCard(Map<String, dynamic> log) {
    final bool isAbsent =
        log['attendance'].toString().toLowerCase() == 'absent';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  log['date'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF475569),
                    fontSize: 13,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isAbsent
                        ? Colors.red.withOpacity(0.1)
                        : const Color(0xFF0A5C36).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    log['attendance'].toString().toUpperCase(),
                    style: TextStyle(
                      color: isAbsent ? Colors.red : const Color(0xFF0A5C36),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isAbsent)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Absent on this day. No logs recorded.",
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildProgressComponentRow(
                    "Sabaq (New)",
                    "${log['sabaq']['surah']} - Lines: ${log['sabaq']['lines']}",
                    "${log['grade'][0]}",
                    Colors.teal,
                  ),
                  const Divider(height: 20),
                  _buildProgressComponentRow(
                    "Sabqi (Recent)",
                    "${log['sabqi']}",
                    "${log['grade'][1]}",
                    Colors.indigo,
                  ),
                  const Divider(height: 20),
                  _buildProgressComponentRow(
                    "Manzil (Revision)",
                    "${log['manzil']}",
                    "${log['grade'][2]}",
                    Colors.amber[800]!,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressComponentRow(
    String title,
    String details,
    String grade,
    Color color,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              details,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFCBD5E1)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            grade,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF475569),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceMetricRow(
    String title,
    String value,
    Color valueColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildExamCard({
    required String examName,
    required String date,
    required String grade,
    required String score,
    required String subjectDetails,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      examName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A5C36).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      grade,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF0A5C36),
                      ),
                    ),
                    Text(
                      score,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF0A5C36),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          Text(
            subjectDetails,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF475569),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
