import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halaqat/features/progress_tracking/data/app_data_provider.dart';
import 'package:provider/provider.dart';

class ManageUsersScreen extends StatefulWidget {
  final int index;
  const ManageUsersScreen({super.key, required this.index});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.index = widget.index;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppDataProvider>(
      builder: (context, provider, child) {
        final students = provider.studentsLegacyFormat;
        final teachersData = provider.teachersData;
        final parentsData = provider.parentsData;

        final teachersList = teachersData['name'] ?? [];
        final teachersIds = teachersData['uid'] ?? [];
        final parentsList = parentsData['name'] ?? [];
        final parentsIds = parentsData['uid'] ?? [];

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: Text("manage_users".tr()),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1E293B),
            bottom: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF0A5C36),
              unselectedLabelColor: const Color(0xFF64748B),
              indicatorColor: const Color(0xFF0A5C36),
              indicatorWeight: 3,
              tabs: [
                Tab(text: "students".tr()),
                Tab(text: "teachers".tr()),
                Tab(text: "parents".tr()),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildStudentsTab(
                students,
                teachersList,
                teachersIds,
                parentsList,
                parentsIds,
              ),
              _buildGenericUserTab(teachersList, teachersIds, "teacher"),
              _buildGenericUserTab(parentsList, parentsIds, "parent"),
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
                ),
                onPressed: () => _showAddUserBottomSheet(_tabController.index),
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: Text(
                  "add_new_user".tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Students Management List ---
  Widget _buildStudentsTab(
    List<Map<String, dynamic>> students,
    List<String> teachersList,
    List<String> teachersIds,
    List<String> parentsList,
    List<String> parentsIds,
  ) {
    return (students.isEmpty)
        ? const Center(
            child: Text(
              'No Students Available',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16.0),
            physics: const BouncingScrollPhysics(),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.withOpacity(0.15)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            student['name'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.swap_horizontal_circle_outlined,
                              color: Color(0xFF0A5C36),
                            ),
                            onPressed: () => _showAssignRelationsSheet(
                              student,
                              teachersList,
                              teachersIds,
                              parentsList,
                              parentsIds,
                            ),
                            tooltip: "Assign Relationships",
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildRelationIndicator(
                              icon: Icons.badge_outlined,
                              roleLabel: "teacher".tr(),
                              assignedName: student['teacher'] ?? "Unassigned",
                              color: Colors.teal,
                            ),
                          ),
                          Expanded(
                            child: _buildRelationIndicator(
                              icon: Icons.family_restroom_rounded,
                              roleLabel: "parent".tr(),
                              assignedName: student['parent'] ?? "Unassigned",
                              color: Colors.pink,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget _buildRelationIndicator({
    required IconData icon,
    required String roleLabel,
    required String assignedName,
    required Color color,
  }) {
    final isUnassigned = assignedName == "Unassigned";
    return Row(
      children: [
        Icon(icon, size: 18, color: isUnassigned ? Colors.grey : color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                roleLabel,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                assignedName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isUnassigned
                      ? Colors.red[300]
                      : const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Teachers & Parents Simple Lists ---
  Widget _buildGenericUserTab(
    List<String> userList,
    List<String> userIds,
    String role,
  ) {
    final provider = context.read<AppDataProvider>();
    return (userList.isEmpty)
        ? Center(
            child: Text(
              'No $role Available',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16.0),
            physics: const BouncingScrollPhysics(),
            itemCount: userList.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.withOpacity(0.15)),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: role == "teacher"
                        ? Colors.teal.withOpacity(0.12)
                        : Colors.pink.withOpacity(0.12),
                    child: Icon(
                      role == "teacher"
                          ? Icons.badge_outlined
                          : Icons.family_restroom_rounded,
                      color: role == "teacher" ? Colors.teal : Colors.pink,
                    ),
                  ),
                  title: Text(
                    userList[index],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      if (index < userIds.length) {
                        provider.deleteManagedUser(userIds[index], role);
                      }
                    },
                  ),
                ),
              );
            },
          );
  }

  // Sheet 1: Assign Student to Teacher/Parent
  void _showAssignRelationsSheet(
    Map<String, dynamic> student,
    List<String> teachersList,
    List<String> teachersIds,
    List<String> parentsList,
    List<String> parentsIds,
  ) {
    String? currentTeacher = student['teacher'] == "Unassigned"
        ? (teachersList.isEmpty ? "Unassigned" : teachersList.first)
        : student['teacher'];
    String? currentParent = student['parent'] == "Unassigned"
        ? (parentsList.isEmpty ? "Unassigned" : parentsList.first)
        : student['parent'];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "assign_relationships_for".tr(
                      args: [student['name'] ?? ''],
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Teacher Dropdown
                  Text(
                    "assign_teacher".tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue:
                        currentTeacher == "Unassigned" &&
                            teachersList.isNotEmpty
                        ? null
                        : currentTeacher,
                    hint: const Text("No teachers available"),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: teachersList
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: teachersList.isEmpty
                        ? null
                        : (val) => setSheetState(() => currentTeacher = val),
                  ),
                  const SizedBox(height: 20),

                  // Parent Dropdown
                  Text(
                    "assign_parent".tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue:
                        currentParent == "Unassigned" && parentsList.isNotEmpty
                        ? null
                        : currentParent,
                    hint: const Text("No parents available"),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: parentsList
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: parentsList.isEmpty
                        ? null
                        : (val) => setSheetState(() => currentParent = val),
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
                        int teacherIndex = teachersList.indexOf(
                          currentTeacher ?? '',
                        );
                        int parentIndex = parentsList.indexOf(
                          currentParent ?? '',
                        );

                        String teacherId = teacherIndex != -1
                            ? teachersIds[teacherIndex]
                            : "Unassigned";
                        String parentId = parentIndex != -1
                            ? parentsIds[parentIndex]
                            : "Unassigned";

                        context
                            .read<AppDataProvider>()
                            .assignStudentRelationships(
                              studentId: student['id'] ?? '',
                              teacherName: currentTeacher ?? "Unassigned",
                              parentName: currentParent ?? "Unassigned",
                              teacherId: teacherId,
                              parentId: parentId,
                            );

                        Navigator.pop(context);
                      },
                      child: Text(
                        "save_assignments".tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
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

  // Sheet 2: Create a New User
  void _showAddUserBottomSheet(int ind) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    final emailController = TextEditingController();
    List<String> roles = ["Student", "Teacher", "Parent"];
    String selectedRole = roles[ind];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "add_new_user".tr(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // --- Role Segment Selection ---
                      Text(
                        "user_role".tr(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<String>(
                          segments: [
                            ButtonSegment(
                              value: 'Student',
                              label: Text('student'.tr()),
                            ),
                            ButtonSegment(
                              value: 'Teacher',
                              label: Text('teacher'.tr()),
                            ),
                            ButtonSegment(
                              value: 'Parent',
                              label: Text('parent'.tr()),
                            ),
                          ],
                          selected: {selectedRole},
                          onSelectionChanged: (set) =>
                              setSheetState(() => selectedRole = set.first),
                          style: SegmentedButton.styleFrom(
                            selectedBackgroundColor: const Color(
                              0xFF0A5C36,
                            ).withAlpha(38),
                            selectedForegroundColor: const Color(0xFF0A5C36),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- Full Name Field ---
                      Text(
                        "full_name".tr(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: "Enter full name...",
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "field_required".tr();
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // --- Logins for Teachers & Parents ---
                      if (selectedRole != 'Student') ...[
                        const Text(
                          "Phone Number",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: "e.g., 03001234567",
                            prefixIcon: const Icon(Icons.phone_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "field_required".tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Email",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "e.g., abc@halaqat.com",
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "field_required".tr();
                            }

                            // Regular expression for standard email validation
                            final emailRegex = RegExp(
                              r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
                            );

                            if (!emailRegex.hasMatch(value.trim())) {
                              return "Enter a valid email address";
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Login Password",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: "••••••••",
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "field_required".tr();
                            }
                            if (value.length < 6) {
                              return "Password must be at least 6 characters";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      const SizedBox(height: 16),

                      // --- Submit Button ---
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
                            if (formKey.currentState!.validate()) {
                              final name = nameController.text.trim();

                              context.read<AppDataProvider>().createManagedUser(
                                name: name,
                                role: selectedRole,
                                phone: phoneController.text.trim(),
                                password: passwordController.text.trim(),
                                email: emailController.text.trim(),
                              );

                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "$selectedRole Registered Successfully!",
                                  ),
                                  backgroundColor: const Color(0xFF0A5C36),
                                ),
                              );
                            }
                          },
                          child: Text(
                            "create_user".tr(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
