import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutrack_application/utils/common/appbar_drawer.dart';
import 'package:edutrack_application/utils/common/pop_up_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminRegisterScreen extends StatefulWidget {
  final String currentUserId;
  final String currentUserRole;

  const AdminRegisterScreen({
    super.key,
    required this.currentUserId,
    required this.currentUserRole,
  });

  @override
  State<AdminRegisterScreen> createState() => _AdminRegisterScreenState();
}

class _AdminRegisterScreenState extends State<AdminRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  bool loading = false;
  bool obscurePassword = true;

  final LinearGradient redGradient = const LinearGradient(
    colors: [Color(0xff3f5efb), Color(0xfffc466b)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Dispose controllers
  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  /// 🔹 Gradient Border Wrapper
  Widget gradientBorderWrapper({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: redGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: child,
      ),
    );
  }

  /// 🔹 Input Decoration
  InputDecoration inputDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      suffixIcon: suffixIcon,
    );
  }

  /// 🔹 Register Admin
  Future<void> registerAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    if (!mounted) return;
    setState(() => loading = true);

    try {
      // 1️⃣ Create Firebase Auth user
      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailCtrl.text.trim(), password: passCtrl.text.trim());

      final uid = user.user!.uid;

      // 2️⃣ Save in admins collection
      await FirebaseFirestore.instance.collection('admin').doc(uid).set({
        'admin_id': uid,
        'name': nameCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
         'user_password': passCtrl.text.trim(),
        'created_at': Timestamp.now(),
      });

      // 3️⃣ Save in users collection
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'user_id': uid,
        'user_name': nameCtrl.text.trim(),
        'user_email': emailCtrl.text.trim(),
        'user_password': passCtrl.text.trim(),
        'role': 'admin',
        'created_at': Timestamp.now(),
      });

      if (!mounted) return;
      setState(() => loading = false);

      showCustomAlert(
        context,
        isSuccess: true,
        title: "Success",
        description: "Admin registered successfully",
      );

      nameCtrl.clear();
      emailCtrl.clear();
      passCtrl.clear();
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);

      showCustomAlert(
        context,
        isSuccess: false,
        title: "Error",
        description: e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: "",
      role: widget.currentUserRole,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /// Gradient Title
                  Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) => redGradient.createShader(bounds),
                      child: const Text(
                        "Register Admin",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // overridden by ShaderMask
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  /// Name Field
                  gradientBorderWrapper(
                    child: TextFormField(
                      controller: nameCtrl,
                      decoration: inputDecoration("Admin Name"),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(height: 14),

                  /// Email Field
                  gradientBorderWrapper(
                    child: TextFormField(
                      controller: emailCtrl,
                      decoration: inputDecoration("Email"),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(height: 14),

                  /// Password Field
                  gradientBorderWrapper(
                    child: TextFormField(
                      controller: passCtrl,
                      obscureText: obscurePassword,
                      decoration: inputDecoration(
                        "Password",
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFFC31432),
                          ),
                          onPressed: () {
                            if (!mounted) return;
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (v) => v != null && v.length < 6
                          ? "Minimum 6 characters"
                          : null,
                    ),
                  ),
                  const SizedBox(height: 25),

                  /// Submit Button
                  loading
                      ? const Center(child: CircularProgressIndicator())
                      : GestureDetector(
                          onTap: registerAdmin,
                          child: Container(
                            height: 55,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: redGradient,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              "Register Admin",
                              style: TextStyle(
                                color: Colors.white,
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
      ),
    );
  }
}
