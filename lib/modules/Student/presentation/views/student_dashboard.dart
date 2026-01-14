
import 'package:edutrack_application/modules/Attendence/presentation/views/scan_qr_attendence_screen.dart';
import 'package:edutrack_application/modules/Student/presentation/widgets/activity_card.dart';
import 'package:edutrack_application/modules/Student/presentation/widgets/carousel.dart';
import 'package:edutrack_application/modules/Student/presentation/widgets/student_assessment_entry.dart';
import 'package:flutter/material.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: Colors.white,
  appBar: AppBar(
    elevation: 0,

    /// ✅ SHOW BACK ARROW
    automaticallyImplyLeading: true,

    /// ✅ BACK ARROW COLOR WHITE
    iconTheme: const IconThemeData(color: Colors.white),

    backgroundColor: Colors.transparent,
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff3f5efb), Color(0xfffc466b)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ),

    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 16),
        child: CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white,
          child: ClipOval(
            child: Image.asset(
              "assets/logo.png",
              width: 36,
              height: 36,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    ],
  ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Carousel
            DashboardCarousel(),

            const SizedBox(height: 25),

            /// Activity Title
            Text(
              "Activity",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..shader = const LinearGradient(
                    colors: [Color(0xff3f5efb), Color(0xfffc466b)],
                  ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
              ),
            ),

            const SizedBox(height: 20),

            /// Activity Cards
            LayoutBuilder(
              builder: (context, constraints) {
                bool isMobile = constraints.maxWidth < 700;

                return GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: isMobile ? 1 : 3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: isMobile ? 3 : 1.1,
                  children: [
                    // ActivityCard(
                    //   title: "Profile",
                    //   icon: Icons.person,
                    //   onTap: () {
                    //     // Navigator.push(
                    //     //   context,
                    //     //   MaterialPageRoute(builder: (_) => const ProfilePage()),
                    //     // );
                    //   },
                    // ),

                    ActivityCard(
                      title: "Mark Attendance",
                      icon: Icons.fingerprint,
                      onTap: () {
                         Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ScanQRScreen()),
                        );
                      },
                    ),
                    ActivityCard(
                      title: "Assessment",
                      icon: Icons.assignment,
                      onTap: () {
                         Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => StudentRollEntryScreen()),
                        );
                      },
                    ),
                    // ActivityCard(
                    //   title: "Feedback",
                    //   icon: Icons.feedback,
                    //   onTap: () {},
                    // ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
