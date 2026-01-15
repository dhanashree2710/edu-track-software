import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutrack_application/modules/Assessment/presentation/views/student_assessment_result_list.dart';
import 'package:flutter/material.dart';

/// ===============================
/// TRAINER → BATCH LIST SCREEN
/// ===============================
class TrainerBatchListScreen extends StatefulWidget {
  final String trainerId; // FirebaseAuth UID

  const TrainerBatchListScreen({
    super.key,
    required this.trainerId,
  });

  @override
  State<TrainerBatchListScreen> createState() =>
      _TrainerBatchListScreenState();
}

class _TrainerBatchListScreenState extends State<TrainerBatchListScreen> {
  bool loading = true;
  List<Map<String, dynamic>> batches = [];

  @override
  void initState() {
    super.initState();
    fetchBatches();
  }

  Future<void> fetchBatches() async {
    print("🔍 Fetching batches for trainerId: ${widget.trainerId}");

    final snap = await FirebaseFirestore.instance
        .collection('batches')
        .where('trainer_id', isEqualTo: widget.trainerId)
        .get();

    print("📦 Batches fetched = ${snap.docs.length}");

    batches = snap.docs.map((doc) {
      final d = doc.data();

      final course = d['course_name'] ?? '';
      final batchNo = d['batch_no'] ?? '';

      print(
          "✅ Batch docId=${doc.id}, trainer_id=${d['trainer_id']}, course=$course, batch=$batchNo");

      return {
        'batchId': doc.id,
        'batchKey': "$course - $batchNo",
        'batchName': batchNo,
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
                        builder: (_) => TrainerBatchAssessmentListScreen(
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

/// ===============================
/// BATCH → ASSESSMENTS
/// ===============================
class TrainerBatchAssessmentListScreen extends StatelessWidget {
  final String batchKey;
  final String batchName;

  const TrainerBatchAssessmentListScreen({
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
            print("❌ No assessments found for batchKey=$batchKey");
            return const Center(child: Text("No assessments found"));
          }

          print("✅ Assessments fetched = ${docs.length}");
          for (var d in docs) {
            print("📘 AssessmentID=${d.id}, batchId=${d['batchId']}");
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              return GestureDetector(
                onTap: () {
                  print("➡️ Open results for assessmentId=${docs[i].id}");
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

// /// ===============================
// /// ASSESSMENT → STUDENT RESULTS
// /// ===============================
// class TrainerStudentAssessmentResultList extends StatelessWidget {
//   final String assessmentId;
//   final String batchKey;
//   final String batchName;

//   const TrainerStudentAssessmentResultList({
//     super.key,
//     required this.assessmentId,
//     required this.batchKey,
//     required this.batchName,
//   });

//   Future<String> getStudentName(String rollNo) async {
//     print("👤 Fetch student for roll_no=$rollNo");

//     final snap = await FirebaseFirestore.instance
//         .collection('student')
//         .where('roll_no', isEqualTo: rollNo)
//         .limit(1)
//         .get();

//     if (snap.docs.isEmpty) {
//       print("❌ Student not found");
//       return "Unknown";
//     }

//     print("✅ Student found: ${snap.docs.first['name']}");
//     return snap.docs.first['name'];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: commonGradientAppBar(batchName),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('assessment_results')
//             .where('assessment_id', isEqualTo: assessmentId)
//             .where('batchId', isEqualTo: batchKey)
//             .snapshots(),
//         builder: (_, snap) {
//           print(
//               "🔍 Fetching results for assessmentId=$assessmentId batchKey=$batchKey");

//           if (snap.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (!snap.hasData || snap.data!.docs.isEmpty) {
//             print("❌ No assessment results found");
//             return const Center(child: Text("No results found"));
//           }

//           final docs = snap.data!.docs;
//           print("✅ Results fetched = ${docs.length}");

//           return SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: DataTable(
//               headingRowColor: WidgetStateProperty.all(
//                 const Color(0xff3f5efb),
//               ),
//               headingTextStyle: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//               columns: const [
//                 DataColumn(label: Text("Sr")),
//                 DataColumn(label: Text("Roll No")),
//                 DataColumn(label: Text("Student Name")),
//                 DataColumn(label: Text("Correct")),
//                 DataColumn(label: Text("Wrong")),
//                 DataColumn(label: Text("Total")),
//                 DataColumn(label: Text("Score")),
//               ],
//               rows: List.generate(docs.length, (i) {
//                 final d = docs[i].data() as Map<String, dynamic>;
//                 final rollNo = d['roll_no'] ?? '';

//                 return DataRow(
//                   cells: [
//                     DataCell(Text("${i + 1}")),
//                     DataCell(Text(rollNo)),
//                     DataCell(
//                       FutureBuilder<String>(
//                         future: getStudentName(rollNo),
//                         builder: (_, snap) {
//                           if (!snap.hasData) {
//                             return const SizedBox(
//                               width: 60,
//                               child: LinearProgressIndicator(),
//                             );
//                           }
//                           return Text(snap.data!);
//                         },
//                       ),
//                     ),
//                     DataCell(Text("${d['correct'] ?? 0}")),
//                     DataCell(Text("${d['wrong'] ?? 0}")),
//                     DataCell(Text("${d['total'] ?? 0}")),
//                     DataCell(
//                       Text(
//                         "${d['correct'] ?? 0} / ${d['total'] ?? 0}",
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               }),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// /// ===============================
// /// COMMON UI WIDGETS
// /// ===============================
// AppBar commonGradientAppBar(String title) {
//   return AppBar(
//     title: Text(title),
//     centerTitle: true,
//     elevation: 0,
//     iconTheme: const IconThemeData(color: Colors.white),
//     backgroundColor: Colors.transparent,
//     flexibleSpace: Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Color(0xff3f5efb), Color(0xfffc466b)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//     ),
//   );
// }

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
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
