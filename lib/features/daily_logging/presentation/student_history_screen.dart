import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halaqat/features/progress_tracking/data/app_data.dart';
import 'package:url_launcher/url_launcher.dart';
// Import your AppData file here
// import 'path_to_app_data.dart';

class StudentHistoryScreen extends StatefulWidget {
  final Map<String, dynamic> student;

  const StudentHistoryScreen({super.key, required this.student});

  @override
  State<StudentHistoryScreen> createState() => _StudentHistoryScreenState();
}

class _StudentHistoryScreenState extends State<StudentHistoryScreen> {
  late String _parentPhone;
  late double _hifzPercentage;
  late List<Map<String, dynamic>> _historyLogs;

  @override
  void initState() {
    super.initState();
    _parentPhone = widget.student['parentPhone'] ?? "N/A";

    // Fetch logs specific to this student from AppData
    _historyLogs = AppData.getProgressLogs()
        .where((log) => log['studentId'] == widget.student['studentId'])
        .toList();

    // Calculate completion progress based on current Para
    int currentPara = widget.student['para'] is int
        ? widget.student['para']
        : int.tryParse(widget.student['para'].toString()) ?? 1;
    _hifzPercentage = (currentPara / 30).clamp(0.0, 1.0);
  }

  void _launchWhatsApp() async {
    final cleanPhone = _parentPhone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No valid parent phone number available."),
        ),
      );
      return;
    }

    final message =
        "Assalamu Alaikum, contacting regarding ${widget.student['name']}.";
    final whatsappWebUrl = Uri.parse(
      "https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}",
    );

    try {
      await launchUrl(whatsappWebUrl, mode: LaunchMode.platformDefault);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error launching URL: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract metrics dynamically
    final latestLog = _historyLogs.firstWhere(
      (log) => log['sabaq'] != null,
      orElse: () => {},
    );

    final currentSura = latestLog.isNotEmpty && latestLog['sabaq'] != null
        ? latestLog['sabaq']['surah'] ?? "N/A"
        : "N/A";

    final currentPara = widget.student['para'] ?? "1";

    // Dynamic attendance count
    final totalPresent = AppData.attendanceLogs
        .where(
          (a) =>
              a['studentId'] == widget.student['studentId'] &&
              a['attendanceStatus'] == 'present',
        )
        .length;
    final totalAbsent = AppData.attendanceLogs
        .where(
          (a) =>
              a['studentId'] == widget.student['studentId'] &&
              a['attendanceStatus'] == 'absent',
        )
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.student['name'] ?? "Student History"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Section 1: Parent Info & WhatsApp Action
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "parent_guardian".tr(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.student['parent'] ?? "Unassigned",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            _parentPhone,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: _launchWhatsApp,
                        icon: const Icon(
                          Icons.message,
                          color: Color(0xFF25D366),
                          size: 32,
                        ),
                        tooltip: "Chat via WhatsApp",
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // Section 2: Stats Grid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickStatTile(
                        "Current Sura",
                        currentSura,
                        Colors.teal,
                      ),
                      _buildQuickStatTile(
                        "Current Para",
                        "Para $currentPara",
                        Colors.indigo,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Section 2: Stats Grid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickStatTile(
                        "Attendance",
                        "$totalPresent Present ",
                        Colors.orange,
                      ),
                      _buildQuickStatTile(
                        "Attendance",
                        "$totalAbsent Absent ",
                        Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Section 3: Progress Bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "hifz_completion_progress".tr(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF475569),
                            ),
                          ),
                          Text(
                            "${(_hifzPercentage * 100).toStringAsFixed(0)}%",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A5C36),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _hifzPercentage,
                        backgroundColor: const Color(0xFF0A5C36).withAlpha(30),
                        color: const Color(0xFF0A5C36),
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Section 4: History Logs Header
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Text(
                "learning_history_logs".tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
          ),

          // Section 5: History Card List
          if (_historyLogs.isEmpty)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    "No history logs found for this student.",
                    style: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final log = _historyLogs[index];
                  return _buildDailyHistoryCard(log);
                }, childCount: _historyLogs.length),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickStatTile(String label, String value, Color color) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.35,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDailyHistoryCard(Map<String, dynamic> log) {
    final bool isAbsent = log['attendanceStatus'] == 'absent';
    final sabaq = log['sabaq'];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
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
                  log['date'] ?? '',
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
                        ? Colors.redAccent.withAlpha(30)
                        : const Color(0xFF0A5C36).withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    (log['attendanceStatus'] ?? 'PRESENT')
                        .toString()
                        .toUpperCase(),
                    style: TextStyle(
                      color: isAbsent
                          ? Colors.redAccent
                          : const Color(0xFF0A5C36),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Core Progress Details
          if (isAbsent)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Student was absent. No lessons were logged.",
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
                  if (sabaq != null)
                    _buildProgressComponentRow(
                      "Sabaq (New)",
                      "${sabaq['surah']} (Para ${sabaq['para']} - Lines ${sabaq['lines']})",
                      log['grade'][0] ?? 'N/A',
                      Colors.teal,
                    ),
                  if (sabaq != null) const Divider(height: 20),
                  _buildProgressComponentRow(
                    "Sabqi (Recent)",
                    log['sabqi'] ?? 'N/A',
                    log['grade'][1] ?? 'N/A',
                    Colors.indigo,
                  ),
                  const Divider(height: 20),
                  _buildProgressComponentRow(
                    "Manzil (Revision)",
                    log['manzil'] ?? 'N/A',
                    log['grade'][2] ?? 'N/A',
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
        Expanded(
          child: Column(
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
}
