import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:halaqat/features/admin_portal/presentation/admin_dashboard_screen.dart';
import 'package:halaqat/features/daily_logging/presentation/teacher_main_navigation.dart';
import 'package:halaqat/features/parent_portal/presentation/parent_dashboard.dart';
import 'package:halaqat/features/progress_tracking/data/app_data.dart';

// ==================== 1. SPLASH SCREEN ====================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    // Small artificial delay for splash animation
    await Future.delayed(const Duration(seconds: 2));

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Fetch user metadata/role from Firestore
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && mounted) {
          final role = doc.data()?['role'] as String? ?? '';
          _navigateBasedOnRole(role);
          return;
        }
      } catch (e) {
        debugPrint("Error fetching user role: $e");
      }
    }

    // Default: Fallback to LoginScreen if user is null or role fetch failed
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _navigateBasedOnRole(String role) {
    Widget destination;
    switch (role.toLowerCase()) {
      case 'admin':
        destination = const AdminDashboardScreen();
        break;
      case 'teacher':
        destination = const TeacherMainNavigation();
        break;
      case 'parent':
        destination = const ParentDashboard();
        break;
      default:
        destination = const LoginScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A5C36),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "app_name".tr(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "tagline".tr(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withAlpha(180),
                ),
              ),
              const SizedBox(height: 48),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== 2. LOGIN SCREEN ====================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedUser();
  }

  Future<void> _loadRememberedUser() async {
    String savedUser = await AppData.getRememberedUsername();
    if (savedUser.isNotEmpty) {
      setState(() {
        _emailController.text = savedUser;
        rememberMe = true;
      });
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      // 1. Authenticate with Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      final uid = userCredential.user?.uid;

      if (uid != null) {
        // 2. Fetch User Role from Firestore (`users` collection)
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

        if (userDoc.exists) {
          String role = userDoc.get('role') ?? 'teacher';

          // Handle Remember Me preference
          if (rememberMe) {
            await AppData.saveRememberedUsername(email);
          } else {
            await AppData.clearRememberedUsername();
          }

          if (!mounted) return;

          AppData.SaveLoginInfo(uid, role, true);
          // 3. Navigate according to role
          if (role == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminDashboardScreen(),
              ),
            );
          } else if (role == 'teacher') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const TeacherMainNavigation(),
              ),
            );
          } else if (role == 'parent') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ParentDashboard()),
            );
          }
        } else {
          _showErrorSnackBar("User document not found in database.");
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Login Failed";
      if (e.code == 'user-not-found') {
        errorMessage = "No user found for that email.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email format.";
      } else if (e.code == 'user-disabled') {
        errorMessage = "This user account has been disabled.";
      } else if (e.message != null) {
        errorMessage = e.message!;
      }

      if (mounted) _showErrorSnackBar(errorMessage);
    } catch (e) {
      if (mounted) _showErrorSnackBar("An error occurred: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ------------------ LANGUAGE TOGGLE ------------------
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: () {
                      final isEnglish = context.locale.languageCode == 'en';
                      context.setLocale(Locale(isEnglish ? 'ur' : 'en'));
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.language,
                            color: Color(0xFF0A5C36),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            context.locale.languageCode == 'en'
                                ? "ENG"
                                : "اردو",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A5C36),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // ------------------ WELCOME TEXT ------------------
                Text(
                  "welcome_back".tr(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "login_subtitle".tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 40),

                // Email Input
                Text(
                  "email_or_username".tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "admin@halaqat.com",
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: Color(0xFF94A3B8),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "field_required".tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Password Input
                Text(
                  "password".tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: "••••••••",
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      color: Color(0xFF94A3B8),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: const Color(0xFF94A3B8),
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "field_required".tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (value) {
                        setState(() {
                          rememberMe = value ?? false;
                        });
                      },
                    ),
                    Text(
                      "remember_me".tr(),
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A5C36),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            "login".tr(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickRoleBadge("Admin", "admin@test.com"),
                    _buildQuickRoleBadge("Teacher", "teacher@test.com"),
                    _buildQuickRoleBadge("Parent", "parent@test.com"),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickRoleBadge(String label, String email) {
    return GestureDetector(
      onTap: () {
        _emailController.text = email;
        _passwordController.text = "123456";
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0A5C36).withAlpha(20),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF0A5C36).withAlpha(40)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF0A5C36),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
