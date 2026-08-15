import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halaqat/features/progress_tracking/data/app_data.dart';

class PublishResultsScreen extends StatefulWidget {
  const PublishResultsScreen({super.key});

  @override
  State<PublishResultsScreen> createState() => _PublishResultsScreenState();
}

class _PublishResultsScreenState extends State<PublishResultsScreen> {
  late List<Map<String, dynamic>> _exams;
  String? _selectedExamId;
  // ignore: unused_field
  String? _selectedExamTitle;
  List<Map<String, dynamic>> _students = [];

  @override
  void initState() {
    super.initState();
    _exams = AppData.getExams();
    if (_exams.isNotEmpty) {
      _selectedExamId = _exams[0]['id']?.toString();
      _selectedExamTitle = _exams[0]['title']?.toString();
      _loadStudentsForExam(_selectedExamId);
    }
  }

  void _loadStudentsForExam(String? examId) {
    if (examId == null) return;

    // Fetch existing results directly using AppData getter
    final examData = AppData.getResultsForExam(examId);

    setState(() {
      _students = AppData.students.map((student) {
        final String sId = student['studentId']?.toString() ?? '';
        final Map<String, dynamic>? existingLog = examData[sId];

        return {
          "studentId": sId,
          "studentName": student['name'] ?? '',
          "examId": examId,
          "status": existingLog?['status'] ?? "Pending",
          "syllabus": existingLog?['syllabus'] ?? "",
          "hifzScore": existingLog?['hifzScore'] ?? "",
          "tajweedGrade": existingLog?['tajweedGrade'] ?? "",
          "remarks": existingLog?['remarks'] ?? "",
          "isGraded": existingLog?['isGraded'] ?? false,
        };
      }).toList();
    });
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
                      value: _selectedExamId,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF0A5C36),
                      ),
                      items: _exams.map<DropdownMenuItem<String>>((exam) {
                        final String id = exam['id']?.toString() ?? '';
                        final String title = exam['title']?.toString() ?? '';

                        return DropdownMenuItem<String>(
                          value: id,
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Color(0xFF1E293B),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? val) {
                        if (val == null) return;
                        final selectedExam = _exams.firstWhere(
                          (e) => e['id'].toString() == val,
                          orElse: () => {},
                        );
                        setState(() {
                          _selectedExamId = val;
                          _selectedExamTitle = selectedExam['title']
                              ?.toString();
                        });
                        _loadStudentsForExam(val);
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
            onPressed: _publishAllResults,
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
    final bool hasGrade = student['isGraded'] == true;

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
                      hasGrade ? "Graded" : "Tap To Mark Grade",
                      style: TextStyle(
                        color: hasGrade
                            ? const Color(0xFF0A5C36)
                            : const Color(0xFF64748B),
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
                  int marks = int.tryParse(marksController.text.trim()) ?? 0;

                  // Determine grade based on marks range
                  String grade;
                  if (marks >= 85) {
                    grade = "ممتاز";
                  } else if (marks >= 75) {
                    grade = "جيد جدًا";
                  } else if (marks >= 65) {
                    grade = "جيد";
                  } else if (marks >= 50) {
                    grade = "مقبول";
                  } else if (marks >= 30) {
                    grade = "ضعيف";
                  } else {
                    grade = "ضعيف جدًا";
                  }
                  final updatedStudent = {
                    ...student,
                    "hifzScore": marksController.text,
                    "tajweedGrade": grade,
                    "syllabus": syllabusController.text,
                    "remarks": remarksController.text,
                    "status": "Published",
                    "isGraded": true,
                  };

                  setState(() {
                    _students[index] = updatedStudent;
                  });

                  // Immediately persist single edit to AppData memory
                  if (_selectedExamId != null) {
                    AppData.saveStudentResult(
                      examId: _selectedExamId!,
                      studentId: student['studentId'].toString(),
                      resultData: updatedStudent,
                    );
                  }

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
    final gradedStudents = _students
        .where((s) => s['isGraded'] == true)
        .toList();

    if (gradedStudents.isEmpty) {
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
            args: [
              gradedStudents.length.toString(),
              _students.length.toString(),
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
          TextButton(
            onPressed: () {
              if (_selectedExamId != null) {
                // Bulk save graded results directly via AppData helper function
                AppData.saveBulkResultsForExam(
                  examId: _selectedExamId!,
                  studentResults: gradedStudents,
                );
              }

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
