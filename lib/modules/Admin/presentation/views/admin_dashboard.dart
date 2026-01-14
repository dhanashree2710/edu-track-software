import 'package:edutrack_application/modules/Assessment/presentation/widgets/manage_assessment.dart';
import 'package:edutrack_application/modules/Batch/presentation/views/create_batch.dart';
import 'package:edutrack_application/modules/Batch/presentation/widgets/manage_batch.dart';
import 'package:edutrack_application/modules/Student/presentation/widgets/manage_student.dart';
import 'package:edutrack_application/modules/Trainer/presentation/widgets/manage_trainer.dart';
import 'package:edutrack_application/utils/common/appbar_drawer.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  final String currentUserId;
  final String currentUserRole;
  const AdminDashboard({
    super.key,
    required this.currentUserId,
    required this.currentUserRole,
  });

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: "",
      role: currentUserRole,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            dashboardCard(
              title: "Batches",
              icon: Icons.groups,
              colors: [Colors.orange, Colors.deepOrange],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ManageBatchScreen()),
                );
              },
            ),

            dashboardCard(
              title: "Trainer",
              icon: Icons.school,
              colors: [Colors.blue, Colors.indigo],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ManageTrainerScreen()),
                );
              },
            ),
            dashboardCard(
              title: "Student",
              icon: Icons.person,
              colors: [Colors.green, Colors.teal],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ManageStudentScreen()),
                );
              },
            ),
            dashboardCard(
              title: "Assessment",
              icon: Icons.assignment,
              colors: [Colors.purple, Colors.deepPurple],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ManageAssessmentScreen()),
                );
              },
            ),
            // dashboardCard(
            //   title: "Feedback",
            //   icon: Icons.feedback,
            //   colors: [Colors.pink, Colors.redAccent],
            //   onTap: () {
            //     // Navigator.push(
            //     //   context,
            //     //   MaterialPageRoute(builder: (_) => ManageBatchScreen()),
            //     // );
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  // /// DRAWER ITEM
  // Widget _drawerItem(IconData icon, String title) {
  //   return ListTile(
  //     leading: Icon(icon),
  //     title: Text(title),
  //     onTap: () {},
  //   );
  // }

  Widget dashboardCard({
    required String title,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap, // 👈 ADD THIS
  }) {
    return InkWell(
      onTap: onTap, // 👈 USE IT
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.last.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
