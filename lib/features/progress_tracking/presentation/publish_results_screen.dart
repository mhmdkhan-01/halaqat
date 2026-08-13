import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halaqat/features/progress_tracking/data/app_data.dart';

class PublishResultsScreen extends StatefulWidget {
  const PublishResultsScreen({super.key});

  @override
  State<PublishResultsScreen> createState() => _PublishResultsScreenState();
}

class _PublishResultsScreenState extends State<PublishResultsScreen> {
  // Mock Scheduled Exams
  final List<Map<String, dynamic>> _exams = AppData.getExams();
  String? _selectedExam;
  // Mock Student List with grading fields
  final List<Map<String, dynamic>> _students = [
    {
      // --- Student Identity ---
      "studentId": "std_8849204", // From App Data
      "studentName": "Ahmad Muhammad", // From App Data
      // --- Exam Metadata ---
      "examId": "exam_01", // From App Data
      "sessionName": "Term 1 - 2026", // From App Data
      "status": "Published", // From App Data
      "syllabus": "Para 1",
      // --- Evaluation / Grading ---
      "hifzScore": "94", // From App Data
      "tajweedGrade": "A", // From App Data
      "remarks": "Excellent", // From Publish Result
      "isGraded": true, // From Publish Result
    },
  ];

  @override
  void initState() {
    super.initState();
    if (_exams.isNotEmpty) {
      _selectedExam = _exams[0]['title'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text("publish_results".tr()),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: Column(
        children: [
          // Exam Selector Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "select_exam".tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedExam,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF0A5C36),
                      ),
                      items: _exams.map<DropdownMenuItem<String>>((exam) {
                        final String examName = exam['title']?.toString() ?? '';

                        return DropdownMenuItem<String>(
                          value: examName,
                          child: Text(
                            examName,
                            style: const TextStyle(
                              color: Color(0xFF1E293B),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? val) {
                        setState(() {
                          _selectedExam = val;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Student Grading List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              physics: const BouncingScrollPhysics(),
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final student = _students[index];
                return _buildStudentGradingCard(student, index);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A5C36),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            onPressed: () => _publishAllResults(),
            icon: const Icon(Icons.cloud_upload_rounded),
            label: Text(
              "publish_to_parents".tr(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentGradingCard(Map<String, dynamic> student, int index) {
    final bool hasGrade = student['isGraded'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: hasGrade
              ? const Color(0xFF0A5C36).withAlpha(50)
              : const Color(0xFFE2E8F0),
          width: hasGrade ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student['studentName'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Tap To Mark Grade",
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                if (hasGrade)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A5C36).withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${student['hifzScore']}/100",
                      style: const TextStyle(
                        color: Color(0xFF0A5C36),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: () => _openGradingDialog(student, index),
                    icon: const Icon(
                      Icons.add_moderator_rounded,
                      size: 18,
                      color: Color(0xFF0A5C36),
                    ),
                    label: Text(
                      "grade".tr(),
                      style: const TextStyle(color: Color(0xFF0A5C36)),
                    ),
                  ),
              ],
            ),
            if (hasGrade) ...[
              const Divider(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      student['remarks'].toString().isEmpty
                          ? "no_remarks".tr()
                          : student['remarks'],
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: Color(0xFF64748B),
                    ),
                    onPressed: () => _openGradingDialog(student, index),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openGradingDialog(Map<String, dynamic> student, int index) {
    final marksController = TextEditingController(text: student['hifzScore']);
    final remarksController = TextEditingController(text: student['remarks']);
    final syllabusController = TextEditingController(text: student['syllabus']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "${'grade'.tr()} ${student['studentName']}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "enter_marks".tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: marksController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "e.g., 85",
                    suffixText: "/ 100",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Syllabus".tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: syllabusController,
                  decoration: InputDecoration(
                    hintText: "e.g., Para 1 to 5",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "remarks".tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: remarksController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "e.g., Excellent tajweed progress.",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "cancel".tr(),
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A5C36),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (marksController.text.isNotEmpty) {
                  setState(() {
                    _students[index] = {
                      ...student,
                      "hifzScore": marksController.text,
                      "remarks": remarksController.text,
                      "isGraded": true,
                    };
                  });
                  Navigator.pop(context);
                }
              },
              child: Text("save_grade".tr()),
            ),
          ],
        );
      },
    );
  }

  void _publishAllResults() {
    // Basic validation check to verify grades are present
    final gradedCount = _students.where((s) => s['isGraded']).length;

    if (gradedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("grade_at_least_one_student".tr()),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("publish_results_confirm".tr()),
        content: Text(
          "publish_results_desc".tr(
            args: [gradedCount.toString(), _students.length.toString()],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "cancel".tr(),
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("results_published_success".tr()),
                  backgroundColor: const Color(0xFF0A5C36),
                ),
              );
            },
            child: Text(
              "publish".tr(),
              style: const TextStyle(
                color: Color(0xFF0A5C36),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
