import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halaqat/features/progress_tracking/data/app_data.dart';

class DailyEntryScreen extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String
  initialSession; // Added parameter to receive the auto-selected session

  const DailyEntryScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.initialSession,
  });

  @override
  State<DailyEntryScreen> createState() => _DailyEntryScreenState();
}

class _DailyEntryScreenState extends State<DailyEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  // Track selected sessions for entry (using a Set for flexible multi-session or single-session focus)
  late Set<String> _selectedSessions;

  // Available total sessions
  final List<String> _availableSessions = AppData.getAvailableSessionsNames();

  String _attendance = 'Present';

  final _paraController = TextEditingController();
  final _suraController = TextEditingController();
  final _linesController = TextEditingController();
  final _sabqiController = TextEditingController();
  final _manzilController = TextEditingController();
  final _remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with the session passed from the teacher dashboard
    _selectedSessions = {widget.initialSession};
  }

  @override
  void dispose() {
    _paraController.dispose();
    _suraController.dispose();
    _linesController.dispose();
    _sabqiController.dispose();
    _manzilController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.studentName, style: TextStyle(fontSize: 22)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              if (context.locale == const Locale('en')) {
                context.setLocale(const Locale('ur'));
              } else {
                context.setLocale(const Locale('en'));
              }
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NEW: Session Selection Header
                Text(
                  'logging_for_session'
                      .tr(), // Translation key for "Logging for Session"
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildSessionChipSelector(),
                const SizedBox(height: 20),

                // 1. Attendance Label
                Text(
                  'attendance'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildAttendanceSelector(),
                const SizedBox(height: 20),
                //add submit button for attendance.
                // Submit attendance Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F9D58),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _submitAttendance,
                    child: Text(
                      'submit_attendance'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (_attendance == 'Present') ...[
                  const Divider(),
                  const SizedBox(height: 10),

                  // 2. Sabaq Label
                  Text(
                    'sabaq'.tr(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _paraController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'para_no'.tr(),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _suraController,
                          decoration: InputDecoration(
                            labelText: 'sura'.tr(),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _linesController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'lines_pages'.tr(),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 3. Sabqi Label
                  Text(
                    'sabqi'.tr(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _sabqiController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'sabqi_hint'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4. Manzil Label
                  Text(
                    'manzil'.tr(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _manzilController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'manzil_hint'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // 5. Remarks Label
                Text(
                  'remarks'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _remarksController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'remarks_hint'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 30),

                // 6. Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F9D58),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _submitForm,
                    child: Text(
                      'submit_log'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Visual Multi-Select Session Filter (or quick focus switcher)
  Widget _buildSessionChipSelector() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: _availableSessions.map((session) {
        final isSelected = _selectedSessions.contains(session);
        return FilterChip(
          label: Text(
            session.tr(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
          selected: isSelected,
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                _selectedSessions.add(session);
              } else {
                // Ensure at least one session is always selected to submit against
                if (_selectedSessions.length > 1) {
                  _selectedSessions.remove(session);
                }
              }
            });
          },
          selectedColor: const Color(0xFF0A5C36),
          checkmarkColor: Colors.white,
          backgroundColor: Colors.grey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAttendanceSelector() {
    return SegmentedButton<String>(
      segments: [
        ButtonSegment<String>(
          value: 'Present',
          label: Text('present'.tr()),
          icon: const Icon(Icons.check_circle_outline),
        ),
        ButtonSegment<String>(
          value: 'Absent',
          label: Text('absent'.tr()),
          icon: const Icon(Icons.cancel_outlined),
        ),
        ButtonSegment<String>(
          value: 'Late',
          label: Text('late'.tr()),
          icon: const Icon(Icons.hourglass_empty_outlined),
        ),
      ],
      selected: {_attendance},
      onSelectionChanged: (Set<String> newSelection) {
        setState(() {
          _attendance = newSelection.first;
        });
      },
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: _attendance == 'Present'
            ? Colors.green[100]
            : _attendance == 'Absent'
            ? Colors.red[100]
            : Colors.orange[100],
        selectedForegroundColor: _attendance == 'Present'
            ? Colors.green[800]
            : _attendance == 'Absent'
            ? Colors.red[800]
            : Colors.orange[800],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Form submission logic
      // Note: You can access selected sessions via `_selectedSessions`
      // (e.g. submit attendance/grades for all checked sessions at once!)
      debugPrint("Submitting for sessions: $_selectedSessions");
      debugPrint("Attendance: $_attendance");

      Navigator.pop(context);
    }
  }

  void _submitAttendance() {
    for (var session in _selectedSessions) {
      AppData.addAttendanceLog(
        widget.studentId,
        widget.studentName,
        session,
        _attendance,
      );
    }
    Navigator.pop(context);
  }
}
