import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AssessmentScreen extends StatefulWidget {
  final String batchId;

  const AssessmentScreen({super.key, required this.batchId});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// 🌈 APP BAR
      appBar:  AppBar(
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
         title: Text(
          "",
          style: const TextStyle(color: Colors.white),
        ),
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

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('assessments')
            .where('batchId', isEqualTo: widget.batchId)
            .limit(1)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Assessment Found"));
          }

          final doc = snapshot.data!.docs.first;
          final List questions = List.from(doc['questions']);

          return LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 700;

              return Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                    columnSpacing: isMobile ? 16 : 28,
                    headingRowColor: MaterialStateProperty.all(
                      Colors.blue.shade50,
                    ),
                    columns: const [
                      DataColumn(label: Text("No")),
                      DataColumn(label: Text("Question")),
                      DataColumn(label: Text("A")),
                      DataColumn(label: Text("B")),
                      DataColumn(label: Text("C")),
                      DataColumn(label: Text("D")),
                      DataColumn(label: Text("Correct")),
                      DataColumn(label: Text("Actions")),
                    ],
                    rows: List.generate(questions.length, (index) {
                      final q = questions[index];

                      return DataRow(
                        cells: [
                          DataCell(Text("${index + 1}")),
                          DataCell(
                            SizedBox(
                              width: isMobile ? 200 : 300,
                              child: Text(
                                q['question'],
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(Text(q['optionA'])),
                          DataCell(Text(q['optionB'])),
                          DataCell(Text(q['optionC'])),
                          DataCell(Text(q['optionD'])),
                          DataCell(
                            Text(
                              q['correctAnswer'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () =>
                                      _editQuestion(context, doc.id, questions, index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _deleteQuestion(doc.id, questions, index),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
                  ),
              );
            },
          );
        },
      ),
    );
  }

  /// 🗑 Delete MCQ
  Future<void> _deleteQuestion(
      String docId, List questions, int index) async {
    questions.removeAt(index);

    await FirebaseFirestore.instance
        .collection('assessments')
        .doc(docId)
        .update({'questions': questions});
  }

  /// ✏️ Edit MCQ Dialog
  void _editQuestion(
      BuildContext context, String docId, List questions, int index) {
    final q = questions[index];

    final questionCtrl = TextEditingController(text: q['question']);
    final aCtrl = TextEditingController(text: q['optionA']);
    final bCtrl = TextEditingController(text: q['optionB']);
    final cCtrl = TextEditingController(text: q['optionC']);
    final dCtrl = TextEditingController(text: q['optionD']);
    String correct = q['correctAnswer'];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Question"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: questionCtrl, decoration: const InputDecoration(labelText: "Question")),
              TextField(controller: aCtrl, decoration: const InputDecoration(labelText: "Option A")),
              TextField(controller: bCtrl, decoration: const InputDecoration(labelText: "Option B")),
              TextField(controller: cCtrl, decoration: const InputDecoration(labelText: "Option C")),
              TextField(controller: dCtrl, decoration: const InputDecoration(labelText: "Option D")),
              DropdownButtonFormField<String>(
                value: correct,
                items: ['A', 'B', 'C', 'D']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => correct = v!,
                decoration: const InputDecoration(labelText: "Correct Answer"),
              )
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              questions[index] = {
                'question': questionCtrl.text,
                'optionA': aCtrl.text,
                'optionB': bCtrl.text,
                'optionC': cCtrl.text,
                'optionD': dCtrl.text,
                'correctAnswer': correct,
              };

              await FirebaseFirestore.instance
                  .collection('assessments')
                  .doc(docId)
                  .update({'questions': questions});

              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }
}



class ViewCreatedAssessment extends StatelessWidget {
  const ViewCreatedAssessment({super.key});

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
        title: const Text("", style: TextStyle(color: Colors.white)),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('batches').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final batches = snapshot.data!.docs;
          final colleges = batches.map((e) => e['college_name'] ?? '').toSet().toList();

          if (colleges.isEmpty) return const Center(child: Text("No colleges found"));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: colleges.length,
            itemBuilder: (context, index) {
              final collegeName = colleges[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CollegeBatchListScreen(collegeName: collegeName),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xff3f5efb), Color(0xfffc466b)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    collegeName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// =====================
/// COLLEGE → BATCH LIST
/// =====================
class CollegeBatchListScreen extends StatefulWidget {
  final String collegeName;
  const CollegeBatchListScreen({super.key, required this.collegeName});

  @override
  State<CollegeBatchListScreen> createState() => _CollegeBatchListScreenState();
}

class _CollegeBatchListScreenState extends State<CollegeBatchListScreen> {
  bool loading = true;
  List<Map<String, dynamic>> batches = [];

  @override
  void initState() {
    super.initState();
    fetchBatches();
  }

  Future<void> fetchBatches() async {
    final snap = await FirebaseFirestore.instance
        .collection('batches')
        .where('college_name', isEqualTo: widget.collegeName)
        .get();

    batches = snap.docs.map((doc) {
      final d = doc.data();
      final batchKey = "${d['course_name']} - ${d['batch_no']}";

      return {
        'batchKey': batchKey,
        'batchName': d['batch_no'],
      };
    }).toList();

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// 🌈 APP BAR
      appBar:  AppBar(
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
         title: Text(
          "",
          style: const TextStyle(color: Colors.white),
        ),
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

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: batches.length,
              itemBuilder: (_, i) {
                final b = batches[i];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BatchAssessmentListScreen(
                          batchKey: b['batchKey'],
                          batchName: b['batchName'],
                        ),
                      ),
                    );
                  },
                  child: gradientTile(b['batchName']),
                );
              },
            ),
    );
  }
}

/// =====================
/// BATCH → ASSESSMENTS
/// =====================
class BatchAssessmentListScreen extends StatelessWidget {
  final String batchKey;
  final String batchName;

  const BatchAssessmentListScreen({
    super.key,
    required this.batchKey,
    required this.batchName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// 🌈 APP BAR
      appBar:  AppBar(
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
         title: Text(
          "",
          style: const TextStyle(color: Colors.white),
        ),
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

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('assessments')
            .where('batchId', isEqualTo: batchKey)
            .snapshots(),
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No assessments found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AssessmentScreen(
                        batchId: batchKey,
                      ),
                    ),
                  );
                },
                child: gradientTile("Assessment ${i + 1}"),
              );
            },
          );
        },
      ),
    );
  }
}



/// =====================
/// UI HELPERS
/// =====================
Widget gradientTile(String text) {
  return Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xff3f5efb), Color(0xfffc466b)],
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Widget gradientCard({required Widget child}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(1.5),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xff3f5efb), Color(0xfffc466b)],
      ),
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

AppBar gradientAppBar(String title) {
  return AppBar(
    iconTheme: const IconThemeData(color: Colors.white),
    backgroundColor: Colors.transparent,
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff3f5efb), Color(0xfffc466b)],
        ),
      ),
    ),
    title: Text(
      title,
      style: const TextStyle(color: Colors.white),
    ),
  );
}
