import 'package:flutter/material.dart';
import 'package:halaqat/features/progress_tracking/data/app_data_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AdminAttendanceScreen extends StatefulWidget {
  const AdminAttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends State<AdminAttendanceScreen> {
  DateTime _selectedDate = DateTime.now();

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppDataProvider>();
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    final students = provider.students;
    final sessions = provider.getAvailableSessionsNames();
    final dailyLogs = provider.getAttendanceLogsForDate(formattedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Students Attendance'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // ------------------ DATE NAVIGATOR HEADER ------------------
          _buildDateHeader(),
          const Divider(height: 1),

          // ------------------ TABLE CONTENT ------------------
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : students.isEmpty
                ? const Center(child: Text("No students found."))
                : _buildAttendanceTable(students, sessions, dailyLogs),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader() {
    final isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());

    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () => _changeDate(-1),
            tooltip: "Previous Day",
          ),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  Text(
                    DateFormat('EEE, dd MMM yyyy').format(_selectedDate),
                    style: TextStyle(
                      fontSize: isToday ? 12 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isToday) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Today",
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.calendar_month, color: Colors.blue),
                onPressed: _pickDate,
                tooltip: "Select Date",
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 20),
                onPressed: () => _changeDate(1),
                tooltip: "Next Day",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTable(
    List<Map<String, dynamic>> students,
    List<String> sessions,
    Map<String, Map<String, String>> dailyLogs,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 24,
          headingRowHeight: 56,
          dataRowHeight: 64,
          border: TableBorder.all(
            color: Colors.grey.shade300,
            width: 1,
            style: BorderStyle.solid,
          ),
          headingRowColor: WidgetStatePropertyAll(
            Theme.of(context).primaryColor.withOpacity(0.05),
          ),
          columns: [
            const DataColumn(
              label: Text(
                'Student Name',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            ...sessions.map((sessionName) {
              return DataColumn(
                label: Text(
                  sessionName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              );
            }).toList(),
          ],
          rows: students.map((student) {
            final studentId = student['studentId'] ?? '';
            final studentName = student['name'] ?? 'Unknown';
            final parentName = student['assignedParentName'] ?? 'Unassigned';

            return DataRow(
              cells: [
                DataCell(
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "S/O: $parentName",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                ...sessions.map((sessionName) {
                  final status = _getAttendanceStatus(
                    dailyLogs,
                    sessionName,
                    studentId,
                  );
                  return DataCell(_buildStatusBadge(status));
                }).toList(),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getAttendanceStatus(
    Map<String, Map<String, String>> dailyLogs,
    String sessionName,
    String studentId,
  ) {
    if (dailyLogs.containsKey(sessionName)) {
      final sessionMap = dailyLogs[sessionName];
      if (sessionMap != null && sessionMap.containsKey(studentId)) {
        return sessionMap[studentId]!;
      }
    }
    return "Not Marked";
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    Color textColor = Colors.white;

    switch (status.toLowerCase()) {
      case 'present':
        badgeColor = Colors.green;
        break;
      case 'absent':
        badgeColor = Colors.red;
        break;
      case 'late':
        badgeColor = Colors.orange;
        break;
      default:
        badgeColor = Colors.grey.shade300;
        textColor = Colors.grey.shade800;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
