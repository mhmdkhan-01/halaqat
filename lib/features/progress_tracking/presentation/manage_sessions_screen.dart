import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halaqat/features/progress_tracking/data/app_data_provider.dart';
import 'package:provider/provider.dart';

class ManageSessionsScreen extends StatefulWidget {
  const ManageSessionsScreen({super.key});

  @override
  State<ManageSessionsScreen> createState() => _ManageSessionsScreenState();
}

class _ManageSessionsScreenState extends State<ManageSessionsScreen> {
  @override
  void initState() {
    super.initState();
    // Load sessions once widget mounts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppDataProvider>().loadSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text("configure_sessions".tr()),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: Consumer<AppDataProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.hasError) {
            return Center(
              child: Text("Error loading sessions: ${provider.errorMessage}"),
            );
          }

          final sessions = provider.sessions;

          if (sessions.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            physics: const BouncingScrollPhysics(),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return _buildSessionCard(session, index);
            },
          );
        },
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
              elevation: 2,
            ),
            onPressed: () => _showSessionFormBottomSheet(),
            icon: const Icon(Icons.add_rounded),
            label: Text(
              "add_new_session".tr(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.alarm_off_rounded, size: 72, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "no_sessions_found".tr(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "add_first_session_hint".tr(),
            style: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session, int index) {
    final startTime = session['startTime'] as TimeOfDay?;
    final endTime = session['endTime'] as TimeOfDay?;

    final startTimeStr = startTime != null
        ? startTime.format(context)
        : "--:--";
    final endTimeStr = endTime != null ? endTime.format(context) : "--:--";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF0A5C36).withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.timer_outlined,
            color: Color(0xFF0A5C36),
            size: 20,
          ),
        ),
        title: Text(
          session['name'] ?? '',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1E293B),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          // Fixed row overflow using Expanded + TextOverflow
          child: Row(
            children: [
              const Icon(Icons.schedule, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "$startTimeStr - $endTimeStr",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Color(0xFF0A5C36)),
              onPressed: () =>
                  _showSessionFormBottomSheet(session: session, index: index),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.redAccent,
              ),
              onPressed: () => _confirmDelete(session['id'].toString()),
            ),
          ],
        ),
      ),
    );
  }

  void _showSessionFormBottomSheet({
    Map<String, dynamic>? session,
    int? index,
  }) {
    final isEditing = session != null;
    final nameController = TextEditingController(
      text: isEditing ? session['name'] : "",
    );
    TimeOfDay selectedStartTime = isEditing
        ? (session['startTime'] ?? const TimeOfDay(hour: 8, minute: 0))
        : const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay selectedEndTime = isEditing
        ? (session['endTime'] ?? const TimeOfDay(hour: 10, minute: 0))
        : const TimeOfDay(hour: 10, minute: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? "edit_session".tr() : "add_session".tr(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "session_name".tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: "e.g., Session 1 (Sabaq)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "start_time".tr(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: selectedStartTime,
                                );
                                if (time != null) {
                                  setSheetState(() => selectedStartTime = time);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(selectedStartTime.format(context)),
                                    const Icon(
                                      Icons.access_time_rounded,
                                      color: Color(0xFF0A5C36),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "end_time".tr(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: selectedEndTime,
                                );
                                if (time != null) {
                                  setSheetState(() => selectedEndTime = time);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(selectedEndTime.format(context)),
                                    const Icon(
                                      Icons.access_time_rounded,
                                      color: Color(0xFF0A5C36),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A5C36),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (nameController.text.isNotEmpty) {
                          final newSessionData = {
                            "id": isEditing
                                ? session['id']
                                : DateTime.now().millisecondsSinceEpoch
                                      .toString(),
                            "name": nameController.text,
                            "startTime": selectedStartTime,
                            "endTime": selectedEndTime,
                          };

                          final provider = context.read<AppDataProvider>();
                          if (isEditing) {
                            provider.updateSessionById(
                              session['id'].toString(),
                              newSessionData,
                            );
                          } else {
                            provider.addSession(newSessionData);
                          }

                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        isEditing ? "update_session".tr() : "save_session".tr(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(String sessionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("delete_session".tr()),
        content: Text("confirm_delete_session_message".tr()),
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
              context.read<AppDataProvider>().deleteSessionById(sessionId);
              Navigator.pop(context);
            },
            child: Text(
              "delete".tr(),
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
