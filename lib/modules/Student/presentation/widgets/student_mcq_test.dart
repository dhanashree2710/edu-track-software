import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:edutrack_application/utils/common/pop_up_screen.dart';

class StudentTestScreen extends StatefulWidget {
  final String rollNo;
  final String assessmentId;

  const StudentTestScreen({
    super.key,
    required this.rollNo,
    required this.assessmentId,
  });

  @override
  State<StudentTestScreen> createState() => _StudentTestScreenState();
}

class _StudentTestScreenState extends State<StudentTestScreen> {
  Map<int, String> answers = {};
  bool submitting = false;

String? batchName;

@override
void initState() {
  super.initState();
  fetchStudentData(); // load batch name when screen opens
}

Future<void> fetchStudentData() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('student')
      .where('roll_no', isEqualTo: widget.rollNo)
      .limit(1)
      .get();

  if (snapshot.docs.isNotEmpty) {
    setState(() {
      batchName = snapshot.docs.first.data()['batch_name']?.toString() ?? '';
    });
  }
}


  /// SUBMIT TEST
  Future<void> submitTest(List questions) async {
    int correct = 0;

    for (int i = 0; i < questions.length; i++) {
      if (answers[i] == questions[i]['correctAnswer']) {
        correct++;
      }
    }

   await FirebaseFirestore.instance.collection('assessment_results').add({
  'roll_no': widget.rollNo,
  'assessment_id': widget.assessmentId,
  'batch_name': batchName ?? '',   // FIXED
  'correct': correct,
  'wrong': questions.length - correct,
  'total': questions.length,
  'score': "$correct / ${questions.length}",
  'submitted_at': Timestamp.now(),
});



    showCustomAlert(
      context,
      isSuccess: true,
      title: "Test Submitted 🎉",
      description:
          "Correct: $correct\nWrong: ${questions.length - correct}\nScore: $correct / ${questions.length}",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // 🔷 GRADIENT APP BAR
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

      // 🔷 FETCH QUESTIONS FROM ASSESSMENT DOC
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('assessments')
            .doc(widget.assessmentId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final List questions = data['questions'] ?? [];

          if (questions.isEmpty) {
            return const Center(child: Text("No questions found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: questions.length + 1,
            itemBuilder: (context, index) {

              // 🔹 SUBMIT BUTTON
              if (index == questions.length) {
                return gradientButton(
                  text: "Submit Test",
                  loading: submitting,
              onTap: () {
  if (batchName == null || batchName!.isEmpty) {
    showCustomAlert(
      context,
      isSuccess: false,
      title: "Please wait",
      description: "Student data is still loading",
    );
    return;
  }

  submitTest(questions);
},

                );
              }

              final q = questions[index];

              return gradientCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Q${index + 1}. ${q['question']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _optionTile(index, "A", q['optionA']),
                    _optionTile(index, "B", q['optionB']),
                    _optionTile(index, "C", q['optionC']),
                    _optionTile(index, "D", q['optionD']),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// OPTION RADIO TILE
  Widget _optionTile(int qIndex, String key, String text) {
    return RadioListTile<String>(
      value: key,
      groupValue: answers[qIndex],
      title: Text(text),
      onChanged: (val) {
        setState(() => answers[qIndex] = val!);
      },
    );
  }
}

/// 🔷 GRADIENT CARD
Widget gradientCard({required Widget child}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xff3f5efb), Color(0xfffc466b)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    padding: const EdgeInsets.all(1.5),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    ),
  );
}

/// 🔷 GRADIENT BUTTON
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
