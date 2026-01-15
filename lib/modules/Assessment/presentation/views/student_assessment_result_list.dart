import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentAssessmentResultList extends StatelessWidget {
  final String assessmentId;
  final String batchName;

  const StudentAssessmentResultList({
    super.key,
    required this.assessmentId,
    required this.batchName,
  });

  /// Fetch student name using roll_no
  Future<String> getStudentName(String rollNo) async {
    final snap = await FirebaseFirestore.instance
        .collection('student')
        .where('roll_no', isEqualTo: rollNo)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return "Unknown";
    return snap.docs.first['name'];
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

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('assessment_results')
            .where('assessment_id', isEqualTo: assessmentId)
            .snapshots(),
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No results found"));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🔹 TITLE
                Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xff3f5efb), Color(0xfffc466b)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: const Text(
              "Student List",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white, // overridden by shader
              ),
            ),
          ),
        ),


              /// 📊 TABLE
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  const Color(0xff3f5efb),
                ),
                headingTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                columns: const [
                    DataColumn(label: Text("Sr.No")),
                  DataColumn(label: Text("Roll No")),
                  DataColumn(label: Text("Student Name")),
                  DataColumn(label: Text("Correct")),
                  DataColumn(label: Text("Wrong")),
                  DataColumn(label: Text("Total")),
                  DataColumn(label: Text("Score")),
                ],
                  rows: List.generate(docs.length, (index) {
                          final doc = docs[index];
                    
                  final d = doc.data() as Map<String, dynamic>;
                  final rollNo = d['roll_no'];

                  return DataRow(
                    cells: [
                         DataCell(Text("${index + 1}")),
                      DataCell(Text(rollNo)),

                      /// STUDENT NAME CELL
                      DataCell(
                        FutureBuilder<String>(
                          future: getStudentName(rollNo),
                          builder: (_, snap) {
                            if (!snap.hasData) {
                              return const SizedBox(
                                width: 60,
                                height: 14,
                                child: LinearProgressIndicator(),
                              );
                            }
                            return Text(snap.data!);
                          },
                        ),
                      ),

                      DataCell(Text("${d['correct']}")),
                      DataCell(Text("${d['wrong']}")),
                      DataCell(Text("${d['total']}")),
                      DataCell(
                        Text(
                          "${d['correct']} / ${d['total']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
                  ),
                ),
              ),
         ] );
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
