import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutrack_application/modules/Assessment/presentation/views/student_assessment_result_list.dart';
import 'package:flutter/material.dart';

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
                      builder: (_) => StudentAssessmentResultList(
                        assessmentId: docs[i].id,
                        batchName: batchName,
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
