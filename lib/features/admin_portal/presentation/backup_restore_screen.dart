import 'dart:io';

import 'package:flutter/material.dart';
import 'package:halaqat/features/progress_tracking/data/app_data.dart';
import 'package:permission_handler/permission_handler.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  bool _isProcessing = false;

  Future<Directory> _getHalaqatBackupDir() async {
    // Request All Files Access on Android 11+
    if (Platform.isAndroid) {
      var status = await Permission.manageExternalStorage.status;
      if (!status.isGranted) {
        status = await Permission.manageExternalStorage.request();
      }
    }

    final Directory backupDir = Directory(
      '/storage/emulated/0/Download/halaqatbackups',
    );
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  /// EXPORT: Saves file automatically to Download/halaqatbackups/
  Future<void> _exportBackup() async {
    try {
      final String jsonContent = await AppData.exportDataToJson();
      final String timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final String fileName = 'halaqat_backup_$timestamp.json';

      final Directory dir = await _getHalaqatBackupDir();
      final File targetFile = File('${dir.path}/$fileName');

      await targetFile.writeAsString(jsonContent);

      if (!mounted) return;
      _showSnackBar("Backup saved to Download/halaqatbackups/", isError: false);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("Export failed: $e", isError: true);
    }
  }

  /// IMPORT: Reads the latest .json file from Download/halaqatbackups/
  Future<void> _importBackup() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final Directory dir = await _getHalaqatBackupDir();

      // List all files inside Download/halaqatbackups/
      final List<FileSystemEntity> entities = dir.listSync();
      final List<File> jsonFiles = entities
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .toList();

      if (jsonFiles.isEmpty) {
        if (!mounted) return;
        _showSnackBar(
          "No backup files found in Download/halaqatbackups/",
          isError: true,
        );
        return;
      }

      // Sort files by modified date to grab the latest one
      jsonFiles.sort(
        (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
      );
      final File latestBackup = jsonFiles.first;

      final bool? confirm = await _showConfirmRestoreDialog();
      if (confirm != true) return;

      final String jsonContent = await latestBackup.readAsString();
      final bool success = await AppData.importDataFromJson(jsonContent);

      if (!mounted) return;
      if (success) {
        _showSnackBar(
          "Restored from: ${latestBackup.path.split('/').last}",
          isError: false,
        );
      } else {
        _showSnackBar("Invalid backup file format.", isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("Failed to restore backup: $e", isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<bool?> _showConfirmRestoreDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Overwrite Current Data?"),
        content: const Text(
          "Restoring from a backup will overwrite your current in-memory "
          "and stored data. Are you sure you want to proceed?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Overwrite & Restore"),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF0A5C36),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Backup & Restore"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: _isProcessing
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0A5C36)),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Data Management",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Export a complete JSON snapshot of system records (Students, Progress, Exams, and Attendance) or restore state from a file.",
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 24),
                  _buildActionCard(
                    title: "Export System Backup",
                    subtitle: "Save all current app records to a JSON file.",
                    icon: Icons.cloud_upload_outlined,
                    color: const Color(0xFF0A5C36),
                    onTap: _exportBackup,
                  ),
                  const SizedBox(height: 16),
                  _buildActionCard(
                    title: "Restore System Data",
                    subtitle:
                        "Import data from a previously saved JSON backup file.",
                    icon: Icons.cloud_download_outlined,
                    color: const Color(0xFF0284C7),
                    onTap: _importBackup,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
        onTap: onTap,
      ),
    );
  }
}
