
import 'package:edutrack_application/modules/Assessment/presentation/views/add_assessment.dart';
import 'package:edutrack_application/modules/Assessment/presentation/views/view_assessment_batch.dart';
import 'package:edutrack_application/modules/Trainer/presentation/widgets/view_trainer_assigned_assessment.dart';
import 'package:flutter/material.dart';

class ManageTrainerAssessmentScreen extends StatelessWidget {
   final String currentUserId;
  const ManageTrainerAssessmentScreen({super.key, required this.currentUserId});

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

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _actionButton(
              title: "Create Assessment",
              icon: Icons.add_circle_outline,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AssessmentCreateScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _actionButton(
  title: "View Assessments",
  icon: Icons.list_alt_rounded,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrainerBatchListScreen(
          trainerId: currentUserId, // ✅ FIXED
        ),
      ),
    );
  },
),

            const SizedBox(height: 20),
          
          ],
        ),
      ),
    );
  }

  /// Reusable Action Button (same style as batch)
  Widget _actionButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 260,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xff3f5efb),
              Color(0xfffc466b),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
