import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentHistoryScreen extends StatefulWidget {
  final Map<String, dynamic> student;

  const StudentHistoryScreen({super.key, required this.student});

  @override
  State<StudentHistoryScreen> createState() => _StudentHistoryScreenState();
}

class _StudentHistoryScreenState extends State<StudentHistoryScreen> {
  // Mock Data mimicking our Firestore schemas
  final String _parentPhone =
      "03275521191"; // Populated from User document associated with parentId
  final double _hifzPercentage =
      0.45; // Simulated: 45% completion based on Paras memorized

  final List<Map<String, dynamic>> _historyLogs = [
    {
      "date": "2026-07-16",
      "attendance": "present",
      "sabaq": {
        "surah": "Al-Baqarah",
        "para": 2,
        "startAyah": 142,
        "endAyah": 150,
        "grade": "Excellent",
      },
      "sabqi": {"para": 1, "pages": "10-15", "grade": "Good"},
      "manzil": {"para": 30, "grade": "Excellent"},
    },
    {
      "date": "2026-07-15",
      "attendance": "present",
      "sabaq": {
        "surah": "Al-Baqarah",
        "para": 2,
        "startAyah": 130,
        "endAyah": 141,
        "grade": "Good",
      },
      "sabqi": {"para": 1, "pages": "5-10", "grade": "Excellent"},
      "manzil": {"para": 29, "grade": "Needs Practice"},
    },
    {
      "date": "2026-07-14",
      "attendance": "absent",
      "sabaq": null,
      "sabqi": null,
      "manzil": null,
    },
  ];

  void _launchWhatsApp() async {
    // Strip everything except numbers
    final cleanPhone = _parentPhone.replaceAll(RegExp(r'[^\d]'), '');
    final message =
        "Assalamu Alaikum, contacting regarding ${widget.student['name']}.";

    // Standard universal web link
    final whatsappWebUrl = Uri.parse(
      "https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}",
    );

    try {
      // Force Android to handle it via standard web rendering protocol, bypassing component checks
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
    // Safely extract recent Sabaq metrics from history
    final latestLog = _historyLogs.firstWhere(
      (log) => log['sabaq'] != null,
      orElse: () => {},
    );
    final currentSura = latestLog.isNotEmpty
        ? latestLog['sabaq']['surah']
        : "N/A";
    final currentPara = latestLog.isNotEmpty
        ? latestLog['sabaq']['para']
        : "N/A";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.student['name']),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Section 1: Parent Information & Messaging Hub
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

                  // Section 2: Progress Metrics & Hifz Gauge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      _buildQuickStatTile(
                        "Attendance",
                        "14 Present / 1 Absent",
                        Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

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

          // Section 3: History Timeline Logs
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
      width: MediaQuery.of(context).size.width * 0.27,
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
    final bool isAbsent = log['attendance'] == 'absent';

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
                  DateFormat('yyyy-MM-dd').format(DateTime.parse(log['date'])),
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
                    log['attendance'].toString().toUpperCase(),
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

          // Core Progress Grid Details
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
                  _buildProgressComponentRow(
                    "Sabaq (New)",
                    "${log['sabaq']['surah']} (Ayah ${log['sabaq']['startAyah']}-${log['sabaq']['endAyah']})",
                    log['sabaq']['grade'],
                    Colors.teal,
                  ),
                  const Divider(height: 20),
                  _buildProgressComponentRow(
                    "Sabqi (Recent)",
                    "Para ${log['sabqi']['para']} (Pgs: ${log['sabqi']['pages']})",
                    log['sabqi']['grade'],
                    Colors.indigo,
                  ),
                  const Divider(height: 20),
                  _buildProgressComponentRow(
                    "Manzil (Revision)",
                    "Para ${log['manzil']['para']}",
                    log['manzil']['grade'],
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
}
