import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:edutrack_application/utils/common/pop_up_screen.dart';

class AssessmentCreateScreen extends StatefulWidget {
  const AssessmentCreateScreen({super.key});

  @override
  State<AssessmentCreateScreen> createState() => _AssessmentCreateScreenState();
}

class _AssessmentCreateScreenState extends State<AssessmentCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  String? selectedBatch;
  List<Map<String, dynamic>> batches = [];
  bool loading = false;

  final LinearGradient redGradient = const LinearGradient(
    colors: [Color(0xff3f5efb), Color(0xfffc466b)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dynamic list of questions
  List<QuestionModel> questions = [QuestionModel()];

  @override
  void initState() {
    super.initState();
    fetchBatches();
  }

  Future<void> fetchBatches() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('batches').get();
      setState(() {
        batches = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'course_name': data['course_name'] ?? 'Unknown Course',
            'batch_no': data['batch_no'] ?? 'Unknown Batch',
          };
        }).toList();
      });
    } catch (e) {
      showCustomAlert(
        context,
        isSuccess: false,
        title: "Error",
        description: e.toString(),
      );
    }
  }

  // Save all questions
  Future<void> saveAssessment() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedBatch == null) {
      showCustomAlert(
        context,
        isSuccess: false,
        title: "Error",
        description: "Please select a batch/course",
      );
      return;
    }

    setState(() => loading = true);

    try {
      // Prepare questions list
      final List<Map<String, dynamic>> questionList = questions.map((q) {
        return {
          'question': q.question.text.trim(),
          'optionA': q.optionA.text.trim(),
          'optionB': q.optionB.text.trim(),
          'optionC': q.optionC.text.trim(),
          'optionD': q.optionD.text.trim(),
          'correctAnswer': q.correctAnswer,
        };
      }).toList();

      await FirebaseFirestore.instance.collection('assessments').add({
        'batchId': selectedBatch,
        'questions': questionList,
        'createdAt': Timestamp.now(),
      });

      setState(() => loading = false);

      // Clear all
      selectedBatch = null;
      questions = [QuestionModel()];

      showCustomAlert(
        context,
        isSuccess: true,
        title: "Success 🎉",
        description: "Assessment added successfully",
      );
    } catch (e) {
      setState(() => loading = false);
      showCustomAlert(
        context,
        isSuccess: false,
        title: "Error ❌",
        description: e.toString(),
      );
    }
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: ShaderMask(
              shaderCallback: (bounds) => redGradient.createShader(
                Rect.fromLTWH(0, 0, bounds.width, bounds.height),
              ),
              child: const Text(
                "Create Assessment",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Batch Dropdown
          gradientDropdown(
            hint: "Select Batch / Course",
            value: selectedBatch,
            items: batches
                .map((b) => DropdownMenuItem<String>(
                      value: "${b['course_name']} - ${b['batch_no']}",
                      child: Text("${b['course_name']} - ${b['batch_no']}"),
                    ))
                .toList(),
            onChanged: (val) => setState(() => selectedBatch = val),
            validator: (v) => v == null || v.isEmpty ? "Select Batch" : null,
          ),
          const SizedBox(height: 16),

          Form(
            key: _formKey,
            child: Column(
              children: [
                // Dynamic list of questions
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    return _questionCard(index);
                  },
                ),
                const SizedBox(height: 16),

                // Add Question Button
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        questions.add(QuestionModel());
                      });
                    },
                    icon: const Icon(Icons.add_circle_outline, size: 36, color: Colors.purple),
                    tooltip: "Add Another Question",
                  ),
                ),

                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: loading ? null : saveAssessment,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: EdgeInsets.zero,
                      elevation: 0,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: redGradient,
                        borderRadius: const BorderRadius.all(Radius.circular(14)),
                      ),
                      child: Center(
                        child: loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Save Assessment",
                                style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  // Question card widget with remove button
  Widget _questionCard(int index) {
    final q = questions[index];
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Question ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _gradientTextField("Question", q.question, maxLines: 3),
              const SizedBox(height: 8),
              _gradientTextField("Option A", q.optionA),
              const SizedBox(height: 8),
              _gradientTextField("Option B", q.optionB),
              const SizedBox(height: 8),
              _gradientTextField("Option C", q.optionC),
              const SizedBox(height: 8),
              _gradientTextField("Option D", q.optionD),
              const SizedBox(height: 8),

              // Correct answer
              Row(
                children: ['A', 'B', 'C', 'D']
                    .map(
                      (e) => Expanded(
                        child: RadioListTile(
                          value: e,
                          groupValue: q.correctAnswer,
                          title: Text(e),
                          onChanged: (val) {
                            setState(() {
                              q.correctAnswer = val!;
                            });
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),

        // Remove Question Button
        if (questions.length > 1)
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              onPressed: () {
                setState(() {
                  questions.removeAt(index);
                });
              },
              icon: const Icon(Icons.cancel, color: Colors.red),
              tooltip: "Remove Question",
            ),
          ),
      ],
    );
  }

  // Gradient dropdown widget
  Widget gradientDropdown({
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(gradient: redGradient, borderRadius: BorderRadius.circular(12)),
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: const InputDecoration(border: InputBorder.none),
          items: items,
          onChanged: onChanged,
          validator: validator,
          hint: Text(hint),
        ),
      ),
    );
  }

  // Gradient text field widget
  Widget _gradientTextField(String hint, TextEditingController ctrl, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(gradient: redGradient, borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.all(2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          validator: (v) => v!.isEmpty ? "Please enter $hint" : null,
          decoration: InputDecoration(hintText: hint, border: InputBorder.none),
        ),
      ),
    );
  }
}

// Model to hold dynamic question data
class QuestionModel {
  TextEditingController question = TextEditingController();
  TextEditingController optionA = TextEditingController();
  TextEditingController optionB = TextEditingController();
  TextEditingController optionC = TextEditingController();
  TextEditingController optionD = TextEditingController();
  String correctAnswer = 'A';
}
