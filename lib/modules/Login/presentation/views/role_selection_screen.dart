import 'package:edutrack_application/modules/Login/presentation/views/user_role_login.dart';
import 'package:edutrack_application/modules/Student/presentation/views/student_dashboard.dart';
import 'package:edutrack_application/utils/common/user_session.dart';
import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7ff),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 60, // 👈 space from top & bottom
              horizontal: 20,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isMobile = constraints.maxWidth < 700;

                return Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 30,
                  runSpacing: 30,
                  children: [
                    RoleCard(
                      title: "Admin",
                      imagePath: "assets/admin_role_screen.png",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserLoginScreen(role: "admin"),
                          ),
                        );
                      },
                      width: isMobile ? 240 : 260,
                      isMobile: isMobile,
                    ),
                    RoleCard(
                      title: "Trainer",
                      imagePath: "assets/trainer_role_screen.png",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserLoginScreen(role: "trainer"),
                          ),
                        );
                      },
                      width: isMobile ? 240 : 260,
                      isMobile: isMobile,
                    ),
                    RoleCard(
                      title: "Student",
                      imagePath: "assets/student_role_screen.png",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => StudentDashboard()),
                        );
                      },
                      width: isMobile ? 240 : 260,
                      isMobile: isMobile,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;
  final double width;
  final bool isMobile;

  const RoleCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.onTap,
    required this.width,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        width: width,
        height: isMobile ? 220 : 280, // 👈 reduced height for mobile
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xfffc466b), Color(0xff3f5efb)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                height: isMobile ? 90 : 120, // 👈 smaller image
                fit: BoxFit.contain,
              ),
              SizedBox(height: isMobile ? 12 : 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Text("Admin Dashboard")),
    );
  }
}

class TrainerPage extends StatelessWidget {
  const TrainerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Trainer Dashboard")));
  }
}

class StudentPage extends StatelessWidget {
  const StudentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Student Dashboard")));
  }
}
