import 'package:flutter/material.dart';
import 'package:halaqat/features/progress_tracking/data/app_data.dart';

class AttendanceTab extends StatefulWidget {
  const AttendanceTab({Key? key}) : super(key: key);

  @override
  State<AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<AttendanceTab> {
  late Future<Map<String, dynamic>> _screenDataFuture;

  // Real data parsed from AppData
  List<Map<String, dynamic>> _availableSessions = [];
  List<Map<String, dynamic>> _students = [];

  // Tracks selected session IDs or names
  final List<String> _selectedSessions = [];

  // Track WHICH session IDs/names are submitted/locked
  final Set<String> _submittedSessions = {};

  // Track local attendance status for students (studentId -> status)
  final Map<String, String> _studentAttendance = {};

  @override
  void initState() {
    super.initState();
    _screenDataFuture = fetchScreenData();
  }

  Future<Map<String, dynamic>> fetchScreenData() async {
    final rawSessions = AppData.getSessions();
    final rawStudents = AppData.getStudents();
    // Cast explicitly
    _availableSessions = List<Map<String, dynamic>>.from(rawSessions);
    _students = List<Map<String, dynamic>>.from(rawStudents);

    // Initialize default selection if empty
    if (_selectedSessions.isEmpty && _availableSessions.isNotEmpty) {
      _selectedSessions.add(_availableSessions.first['name'].toString());
    }

    // Initialize default status for students
    for (var student in _students) {
      final id = student['studentId'].toString();
      _studentAttendance.putIfAbsent(id, () => 'Present');
    }
    var submittedForToday = AppData.getSubmittedSessionsForDate(
      DateTime.now().toString().split(' ')[0],
    );
    _submittedSessions.addAll(submittedForToday);
    return {'sessions': _availableSessions, 'students': _students};
  }

  // Helper: Check if ALL currently selected sessions are submitted
  bool get _areAllSelectedSessionsSubmitted {
    if (_selectedSessions.isEmpty) return false;
    return _selectedSessions.every((s) => _submittedSessions.contains(s));
  }

  void _showSessionSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Session(s)'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _availableSessions.map((sessionMap) {
                      final sessionName = sessionMap['name'].toString();
                      final isSelected = _selectedSessions.contains(
                        sessionName,
                      );
                      final isLocked = AppData.isSessionSubmitted(
                        DateTime.now().toString().split(' ')[0],
                        sessionName,
                      );

                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                sessionName,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isLocked) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.lock,
                                size: 16,
                                color: Colors.amber,
                              ),
                            ],
                          ],
                        ),
                        value: isSelected,
                        onChanged: (checked) {
                          setDialogState(() {
                            if (checked == true) {
                              _selectedSessions.add(sessionName);
                            } else {
                              if (_selectedSessions.length > 1) {
                                _selectedSessions.remove(sessionName);
                              }
                            }
                          });
                          setState(() {}); // Update main UI
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _submitAttendance() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Attendance?'),
        content: Text(
          'Attendance for selected session(s):\n• ${_selectedSessions.join("\n• ")}\n\n'
          'Once submitted, these specific sessions cannot be modified later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              for (var session in _selectedSessions) {
                if (_submittedSessions.contains(session)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Session "$session" is already submitted and locked.',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  Navigator.pop(context); // Close the dialog
                  return;
                }
              }

              Navigator.pop(context);

              // 1. Call AppData to save log
              bool success = await AppData.saveAttendanceLog(
                date: DateTime.now(),
                sessionNames: _selectedSessions,
                studentAttendance: _studentAttendance,
              );

              if (success) {
                AppData.submitSessionForDate(
                  DateTime.now().toString().split(' ')[0],
                  _selectedSessions,
                );
                _submittedSessions.addAll(_selectedSessions);
                setState(() {});

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Attendance saved & locked successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Submit & Lock'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentSelectionLocked = _areAllSelectedSessionsSubmitted;

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _screenDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            return Column(
              children: [
                if (isCurrentSelectionLocked)
                  Container(
                    width: double.infinity,
                    color: Colors.amber.shade100,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.lock, color: Colors.amber, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Attendance is locked for the selected session(s).',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Top Session Selector
                Card(
                  margin: const EdgeInsets.all(12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.event_note, color: Colors.teal),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Active Session(s)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: _selectedSessions.map((s) {
                                  final isLocked = _submittedSessions.contains(
                                    s,
                                  );
                                  return Chip(
                                    avatar: isLocked
                                        ? const Icon(
                                            Icons.lock,
                                            size: 14,
                                            color: Colors.amber,
                                          )
                                        : null,
                                    label: Text(
                                      s,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    backgroundColor: isLocked
                                        ? Colors.amber.shade50
                                        : Colors.teal.shade50,
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.filter_list,
                            color: Colors.teal,
                          ),
                          onPressed: _showSessionSelectionDialog,
                          tooltip: 'Select Sessions',
                        ),
                      ],
                    ),
                  ),
                ),

                // Student List
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    itemCount: _students.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      final studentId = student['studentId'].toString();
                      final studentName = student['name'] ?? 'Unknown Student';
                      final teacherName =
                          student['assignedTeacherName'] ?? 'Unassigned';

                      final String currentStatus =
                          _studentAttendance[studentId] ?? 'Present';

                      return Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    studentName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    teacherName,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Status Toggles
                              Row(
                                children: [
                                  _buildStatusChip(
                                    label: 'Present',
                                    activeColor: Colors.green,
                                    isSelected: currentStatus == 'Present',
                                    onTap: isCurrentSelectionLocked
                                        ? null
                                        : () {
                                            setState(() {
                                              _studentAttendance[studentId] =
                                                  'Present';
                                            });
                                          },
                                  ),
                                  const SizedBox(width: 8),
                                  _buildStatusChip(
                                    label: 'Absent',
                                    activeColor: Colors.red,
                                    isSelected: currentStatus == 'Absent',
                                    onTap: isCurrentSelectionLocked
                                        ? null
                                        : () {
                                            setState(() {
                                              _studentAttendance[studentId] =
                                                  'Absent';
                                            });
                                          },
                                  ),
                                  const SizedBox(width: 8),
                                  _buildStatusChip(
                                    label: 'Late',
                                    activeColor: Colors.orange,
                                    isSelected: currentStatus == 'Late',
                                    onTap: isCurrentSelectionLocked
                                        ? null
                                        : () {
                                            setState(() {
                                              _studentAttendance[studentId] =
                                                  'Late';
                                            });
                                          },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Action Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        disabledBackgroundColor: Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: isCurrentSelectionLocked
                          ? null
                          : _submitAttendance,
                      icon: Icon(
                        isCurrentSelectionLocked
                            ? Icons.check_circle
                            : Icons.save,
                        color: Colors.white,
                      ),
                      label: Text(
                        isCurrentSelectionLocked
                            ? 'Session Attendance Submitted'
                            : 'Submit Attendance',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusChip({
    required String label,
    required Color activeColor,
    required bool isSelected,
    required VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? activeColor : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
