import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutrack_application/modules/Admin/presentation/views/admin_dashboard.dart';
import 'package:edutrack_application/modules/Login/presentation/widgets/biometric_auth.dart';
import 'package:edutrack_application/modules/Student/presentation/views/student_dashboard.dart';
import 'package:edutrack_application/modules/Trainer/presentation/views/trainer_dashboard.dart';
import 'package:edutrack_application/utils/common/appbar_drawer.dart';
import 'package:edutrack_application/utils/common/pop_up_screen.dart';
import 'package:edutrack_application/utils/common/user_session.dart';
import 'package:flutter/material.dart';

class UserLoginScreen extends StatefulWidget {
  final String role;
  const UserLoginScreen({
    super.key, required this.role,
  
  });

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false; // 👁️ Add eye toggle state

 Widget getNextScreen(String role, DocumentSnapshot userDoc) {
  final userId = userDoc['user_id'];

  switch (role) {
    case 'admin':
      return AdminDashboard(
        currentUserId: userId,
        currentUserRole: role,
      );

    case 'trainer':
      return  TrainerDashboard(
        currentUserId: userId,
        currentUserRole: role,
      );

    default:
      return StudentDashboard();
  }
}

  // 🔥 FORGOT PASSWORD — update password in correct table
  Future<void> _showForgotPasswordDialog() async {
    final newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text("Reset Password"),
          content: TextField(
            controller: newPasswordController,
            decoration: const InputDecoration(labelText: "Enter New Password"),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Update"),
              onPressed: () async {
                final email = _emailController.text.trim();
                final newPassword = newPasswordController.text.trim();

                if (email.isEmpty || newPassword.isEmpty) {
                  showCustomAlert(
                    context,
                    isSuccess: false,
                    title: "Missing Fields",
                    description: "Enter email & new password.",
                  );
                  return;
                }

                Navigator.pop(context);
                await _updatePassword(email, newPassword);
              },
            ),
          ],
        );
      },
    );
  }

  // 🔥 Update password from all possible collections
  Future<void> _updatePassword(String email, String newPassword) async {
    final collections = ["users", "trainer", "admin"];
    bool updated = false;

    for (var col in collections) {
      final snap = await FirebaseFirestore.instance
          .collection(col)
          .where('user_email', isEqualTo: email)
          .get();

      if (snap.docs.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection(col)
            .doc(snap.docs.first.id)
            .update({'user_password': newPassword});

        updated = true;
        break;
      }
    }

    if (updated) {
      showCustomAlert(
        context,
        isSuccess: true,
        title: "Password Updated",
        description: "Password updated successfully for $email",
      );
    } else {
      showCustomAlert(
        context,
        isSuccess: false,
        title: "Error",
        description: "Email not found in system.",
      );
    }
  }

Future<void> _loginUser(BuildContext context) async {
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();

  print("🔹 LOGIN ATTEMPT → email=$email, password=$password");

  if (email.isEmpty || password.isEmpty) {
    showCustomAlert(
      context,
      isSuccess: false,
      title: "Missing Fields",
      description: "Please enter both email and password.",
    );
    return;
  }

  try {
    setState(() => _isLoading = true);

    const collection = "users"; // ✅ Always fetch from 'users' table
    print("🔹 Querying collection: $collection");

    final snapshot = await FirebaseFirestore.instance
        .collection(collection)
        .where('user_email', isEqualTo: email) // users table field
        .get();

    if (snapshot.docs.isEmpty) {
      print("No email match. Collection documents:");
      final allDocs = await FirebaseFirestore.instance.collection(collection).get();
      for (var d in allDocs.docs) {
        print(d.data());
      }

      showCustomAlert(
        context,
        isSuccess: false,
        title: "Login Failed",
        description: "Email not found in users table",
      );
      return;
    }

    final userDoc = snapshot.docs.first;
    final storedPassword = userDoc['user_password'].toString().trim();

    if (storedPassword != password) {
      showCustomAlert(
        context,
        isSuccess: false,
        title: "Login Failed",
        description: "Incorrect password",
      );
      return;
    }

    // ✅ Login successful — save session
    await UserSession().setUser(
      id: userDoc['user_id'],
      userRole: widget.role,
      userName: userDoc['user_name'],
      userEmail: userDoc['user_email'],
    );

    await UserSession().enableBiometric(true);

    showCustomAlert(
      context,
      isSuccess: true,
      title: "Login Successful",
      description: "Welcome ${userDoc['user_name']}",
      nextScreen: getNextScreen(widget.role, userDoc),
    );
  } catch (e) {
    print("❌ LOGIN ERROR → $e");
    showCustomAlert(
      context,
      isSuccess: false,
      title: "Login Error",
      description: e.toString(),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
    color: Colors.white, // 👈 Back arrow color
  ),
        title: const Text("", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('assets/logo.png'),
            ),
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff3f5efb), Color(0xfffc466b)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 800;
          return Center(
            child: Container(
              width: isDesktop ? 400 : double.infinity,
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFF34D0C6),
                        Color(0xFF22A4E0),
                        Color(0xFF1565C0),
                      ],
                    ).createShader(bounds),
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  _buildGradientTextField(
                    "Email",
                    Icons.email,
                    _emailController,
                  ),

                  const SizedBox(height: 20),

                  _buildPasswordField(), // 👁️ UPDATED PASSWORD FIELD

                  const SizedBox(height: 12),

                  // 🔹 Forgot Password (right aligned)
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: _showForgotPasswordDialog,
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Color(0xFF1565C0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  _isLoading
                      ? const CircularProgressIndicator()
                      : GestureDetector(
                          onTap: () => _loginUser(context),
                          child: Container(
                            height: 50,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xff3f5efb), Color(0xfffc466b)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 30),
                  IconButton(
                    icon: const Icon(Icons.fingerprint, size: 40),
                    onPressed: () async {
                      final session = UserSession();

                      // 🔴 LOAD SAVED DATA
                      await session.loadSession();

                      final loggedIn = await session.isLoggedIn();
                      final role = session.role;
                      final uid = session.userId;

                      debugPrint(
                        "🔐 BIO LOGIN → loggedIn=$loggedIn role=$role uid=$uid",
                      );

                      if (!loggedIn || role == null || uid == null) {
                        showCustomAlert(
                          context,
                          isSuccess: false,
                          title: "Login Required",
                          description:
                              "Please login once using email & password",
                        );
                        return;
                      }

                      final success = await BiometricAuth.authenticate();
                      if (!success) return;

                      Widget nextScreen;

                      switch (role.toLowerCase()) {
                        case 'admin':
                          nextScreen = AdminDashboard(
                            currentUserId: uid,
                            currentUserRole: role,
                          );
                          break;

                        case 'trainer':
                          nextScreen = TrainerDashboard(
                            currentUserId: uid,
                            currentUserRole: role,
                          );
                          break;

                        default:
                          nextScreen = const UserLoginScreen(role: '',
                           
                          );
                      }

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => nextScreen),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 🔹 Password field with eye icon
  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff3f5efb), Color(0xfffc466b)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(1.5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            hintText: "Password",
            prefixIcon: const Icon(Icons.lock, color: Color(0xFF1565C0)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 10,
            ),

            // 👁️ Eye Icon
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xFF1565C0),
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientTextField(
    String hint,
    IconData icon,
    TextEditingController controller,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff3f5efb), Color(0xfffc466b)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(1.5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF1565C0)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 10,
            ),
          ),
        ),
      ),
    );
  }
}
