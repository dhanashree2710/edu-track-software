import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutrack_application/modules/Student/presentation/widgets/student_mcq_test.dart';
import 'package:edutrack_application/utils/common/pop_up_screen.dart';
import 'package:flutter/material.dart';

class StudentRollEntryScreen extends StatefulWidget {
  const StudentRollEntryScreen({super.key});

  @override
  State<StudentRollEntryScreen> createState() => _StudentRollEntryScreenState();
}

class _StudentRollEntryScreenState extends State<StudentRollEntryScreen> {
  final rollCtrl = TextEditingController();
  bool loading = false;

Future<void> startTest() async {
  setState(() => loading = true);

  final rollNo = rollCtrl.text.trim();

  if (rollNo.length < 4) {
    setState(() => loading = false);
    showCustomAlert(
      context,
      isSuccess: false,
      title: "Invalid Roll No",
      description: "Enter valid roll number",
    );
    return;
  }

  /// Extract batch from roll number
  final batchCode = rollNo.substring(0, 4); // BG01
  final batchId = "BFSI - $batchCode";
  

  /// Check student exists
  final studentSnap = await FirebaseFirestore.instance
      .collection('student')
      .where('roll_no', isEqualTo: rollNo)
      .limit(1)
      .get();

  if (studentSnap.docs.isEmpty) {
    setState(() => loading = false);
    showCustomAlert(
      context,
      isSuccess: false,
      title: "Invalid Roll No",
      description: "Student not found",
    );
    return;
  }

  /// Fetch assessment using batchId
  final assessmentSnap = await FirebaseFirestore.instance
      .collection('assessments')
      .where('batchId', isEqualTo: batchId)
      .limit(1)
      .get();

  if (assessmentSnap.docs.isEmpty) {
    setState(() => loading = false);
    showCustomAlert(
      context,
      isSuccess: false,
      title: "No Test",
      description: "No assessment available for this batch",
    );
    return;
  }

  final assessmentId = assessmentSnap.docs.first.id;

  /// Prevent multiple attempts
  final attemptCheck = await FirebaseFirestore.instance
      .collection('assessment_results')
      .where('roll_no', isEqualTo: rollNo)
      .where('assessment_id', isEqualTo: assessmentId)
      .get();

  if (attemptCheck.docs.isNotEmpty) {
    setState(() => loading = false);
    showCustomAlert(
      context,
      isSuccess: false,
      title: "Already Attempted",
      description: "You can attempt this test only once",
    );
    return;
  }

  setState(() => loading = false);

 Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => StudentTestScreen(
      rollNo: rollNo,
      assessmentId: assessmentId,
      batchName: batchId,
    ),
  ),
);

}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: true,
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            gradientTextField("Enter Roll Number", rollCtrl),
            const SizedBox(height: 30),
            gradientButton(
              text: "Start Test",
              loading: loading,
              onTap: startTest,
            ),
          ],
        ),
      ),
    );
  }
}

 Widget gradientTextField(String hint, TextEditingController controller) {
  return Container(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xff3f5efb), Color(0xfffc466b)],
      ),
      borderRadius: BorderRadius.circular(14),
    ),
    padding: const EdgeInsets.all(2),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    ),
  );
}
Widget gradientButton({
  required String text,
  required VoidCallback onTap,
  bool loading = false,
}) {
  return SizedBox(
    width: double.infinity,
    height: 52,
    child: ElevatedButton(
      onPressed: loading ? null : onTap,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Ink(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff3f5efb), Color(0xfffc466b)],
          ),
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
        child: Center(
          child: loading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    ),
  );
}
