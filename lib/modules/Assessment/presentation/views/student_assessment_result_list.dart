// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class StudentAssessmentResultList extends StatelessWidget {
//   final String assessmentId;
//   final String batchName;

//   const StudentAssessmentResultList({
//     super.key,
//     required this.assessmentId,
//     required this.batchName,
//   });

//   /// Fetch student name using roll_no
//   Future<String> getStudentName(String rollNo) async {
//     final snap = await FirebaseFirestore.instance
//         .collection('student')
//         .where('roll_no', isEqualTo: rollNo)
//         .limit(1)
//         .get();

//     if (snap.docs.isEmpty) return "Unknown";
//     return snap.docs.first['name'];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,

//       /// 🌈 APP BAR
//       appBar:  AppBar(
//         elevation: 0,
//         automaticallyImplyLeading: true,
//         iconTheme: const IconThemeData(color: Colors.white),
//          title: Text(
//           "",
//           style: const TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Colors.transparent,
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xff3f5efb), Color(0xfffc466b)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 16),
//             child: CircleAvatar(
//               radius: 22,
//               backgroundColor: Colors.white,
//               child: ClipOval(
//                 child: Image.asset(
//                   "assets/logo.png",
//                   width: 36,
//                   height: 36,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),

//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('assessment_results')
//             .where('assessment_id', isEqualTo: assessmentId)
//             .snapshots(),
//         builder: (_, snap) {
//           if (!snap.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final docs = snap.data!.docs;

//           if (docs.isEmpty) {
//             return const Center(child: Text("No results found"));
//           }

//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [

//               /// 🔹 TITLE
//                 Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           child: ShaderMask(
//             shaderCallback: (bounds) => const LinearGradient(
//               colors: [Color(0xff3f5efb), Color(0xfffc466b)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ).createShader(bounds),
//             child: const Text(
//               "Student List",
//               style: TextStyle(
//                 fontSize: 26,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white, // overridden by shader
//               ),
//             ),
//           ),
//         ),


//               /// 📊 TABLE
//               Expanded(
//                 child: Scrollbar(
//                   thumbVisibility: true,
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.vertical,
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: DataTable(
//                 headingRowColor: WidgetStateProperty.all(
//                   const Color(0xff3f5efb),
//                 ),
//                 headingTextStyle: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 columns: const [
//                     DataColumn(label: Text("Sr.No")),
//                   DataColumn(label: Text("Roll No")),
//                   DataColumn(label: Text("Student Name")),
//                   DataColumn(label: Text("Correct")),
//                   DataColumn(label: Text("Wrong")),
//                   DataColumn(label: Text("Total")),
//                   DataColumn(label: Text("Score")),
//                 ],
//                   rows: List.generate(docs.length, (index) {
//                           final doc = docs[index];
                    
//                   final d = doc.data() as Map<String, dynamic>;
//                   final rollNo = d['roll_no'];

//                   return DataRow(
//                     cells: [
//                          DataCell(Text("${index + 1}")),
//                       DataCell(Text(rollNo)),

//                       /// STUDENT NAME CELL
//                       DataCell(
//                         FutureBuilder<String>(
//                           future: getStudentName(rollNo),
//                           builder: (_, snap) {
//                             if (!snap.hasData) {
//                               return const SizedBox(
//                                 width: 60,
//                                 height: 14,
//                                 child: LinearProgressIndicator(),
//                               );
//                             }
//                             return Text(snap.data!);
//                           },
//                         ),
//                       ),

//                       DataCell(Text("${d['correct']}")),
//                       DataCell(Text("${d['wrong']}")),
//                       DataCell(Text("${d['total']}")),
//                       DataCell(
//                         Text(
//                           "${d['correct']} / ${d['total']}",
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   );
//                 }).toList(),
//               ),
//             ),
//                   ),
//                 ),
//               ),
//          ] );
//         },
//       ),
//     );
//   }
// }


// /// =====================
// /// UI HELPERS
// /// =====================
// Widget gradientTile(String text) {
//   return Container(
//     margin: const EdgeInsets.only(bottom: 14),
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       gradient: const LinearGradient(
//         colors: [Color(0xff3f5efb), Color(0xfffc466b)],
//       ),
//       borderRadius: BorderRadius.circular(16),
//     ),
//     child: Text(
//       text,
//       style: const TextStyle(
//         color: Colors.white,
//         fontWeight: FontWeight.bold,
//       ),
//     ),
//   );
// }

// Widget gradientCard({required Widget child}) {
//   return Container(
//     margin: const EdgeInsets.only(bottom: 12),
//     padding: const EdgeInsets.all(1.5),
//     decoration: BoxDecoration(
//       gradient: const LinearGradient(
//         colors: [Color(0xff3f5efb), Color(0xfffc466b)],
//       ),
//       borderRadius: BorderRadius.circular(16),
//     ),
//     child: Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: child,
//     ),
//   );
// }

// AppBar gradientAppBar(String title) {
//   return AppBar(
//     iconTheme: const IconThemeData(color: Colors.white),
//     backgroundColor: Colors.transparent,
//     flexibleSpace: Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Color(0xff3f5efb), Color(0xfffc466b)],
//         ),
//       ),
//     ),
//     title: Text(
//       title,
//       style: const TextStyle(color: Colors.white),
//     ),
//   );
// }
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:universal_html/html.dart' as html;

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
    if (rollNo.isEmpty) return rollNo;
    try {
      final query = await FirebaseFirestore.instance
          .collection('student')
          .where('roll_no', isEqualTo: rollNo)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.data()['name'] ?? rollNo;
      }
      return rollNo;
    } catch (e) {
      return rollNo;
    }
  }

  /// Universal CSV export (same as Attendance screen)
  Future<void> exportCsv(String csvData, String fileName) async {
    Uint8List bytes = Uint8List.fromList(utf8.encode(csvData));

    if (kIsWeb) {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final path = "${directory.path}/$fileName";
      final file = File(path);
      await file.writeAsBytes(bytes);
    }
  }

  /// Download CSV
  Future<void> downloadCSV(
    BuildContext context,
    List<Map<String, dynamic>> students,
  ) async {
    List<List<String>> csvData = [
      [
        "Sr No",
        "Roll No",
        "Student Name",
        "Correct",
        "Wrong",
        "Total",
        "Score"
      ],
    ];

    int i = 1;
    for (var s in students) {
      final name = await getStudentName(s['roll_no']);
      csvData.add([
        i.toString(),
        s['roll_no'] ?? '',
        name,
        "${s['correct']}",
        "${s['wrong']}",
        "${s['total']}",
        "${s['correct']} / ${s['total']}",
      ]);
      i++;
    }

    final csv = const ListToCsvConverter().convert(csvData);

    await exportCsv(
      csv,
      "$batchName Assessment Results.csv",
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("CSV downloaded successfully")),
    );
  }

  /// Numeric-aware roll-no sort (BG01 < BG2 < BG10)
  int rollSort(dynamic a, dynamic b) {
    final rollA = a['roll_no']?.toString() ?? '';
    final rollB = b['roll_no']?.toString() ?? '';

    final numA =
        int.tryParse(RegExp(r'\d+').firstMatch(rollA)?.group(0) ?? '0') ?? 0;
    final numB =
        int.tryParse(RegExp(r'\d+').firstMatch(rollB)?.group(0) ?? '0') ?? 0;

    if (numA != numB) return numA.compareTo(numB);
    return rollA.compareTo(rollB);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// 🌈 APP BAR
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff3f5efb), Color(0xfffc466b)],
            ),
          ),
        ),
        title: const Text("", style: TextStyle(color: Colors.white)),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('assessment_results')
            .where('assessment_id', isEqualTo: assessmentId)
            .snapshots(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("No results found"));
          }

          /// 🔹 Deduplicate by roll_no
          final Map<String, Map<String, dynamic>> unique = {};
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            unique.putIfAbsent(data['roll_no'], () => data);
          }

          /// 🔹 Sort
          final studentList = unique.values.toList()..sort(rollSort);

          return Column(
            children: [
              /// 🔹 HEADER + DOWNLOAD
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: ShaderMask(
                        shaderCallback: (bounds) =>
                            const LinearGradient(
                          colors: [Color(0xff3f5efb), Color(0xfffc466b)],
                        ).createShader(bounds),
                        child: Text(
                          "Assessment - $batchName",
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.download, size: 28),
                      onPressed: () =>
                          downloadCSV(context, studentList),
                    ),
                  ],
                ),
              ),

              /// 📊 TABLE (FULL SCROLL SUPPORT)
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor:
                            MaterialStateProperty.all(
                          const Color(0xff3f5efb),
                        ),
                        headingTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        columns: const [
                          DataColumn(label: Text("Sr No")),
                          DataColumn(label: Text("Roll No")),
                          DataColumn(label: Text("Student Name")),
                          DataColumn(label: Text("Correct")),
                          DataColumn(label: Text("Wrong")),
                          DataColumn(label: Text("Total")),
                          DataColumn(label: Text("Score")),
                        ],
                        rows: List.generate(studentList.length, (index) {
                          final row = studentList[index];
                          final rollNo = row['roll_no'];

                          return DataRow(
                            cells: [
                              DataCell(Text("${index + 1}")),
                              DataCell(Text(rollNo)),
                              DataCell(
                                FutureBuilder<String>(
                                  future: getStudentName(rollNo),
                                  builder: (_, snap) {
                                    if (!snap.hasData) {
                                      return const SizedBox(
                                        width: 60,
                                        child:
                                            LinearProgressIndicator(),
                                      );
                                    }
                                    return Text(snap.data!);
                                  },
                                ),
                              ),
                              DataCell(Text("${row['correct']}")),
                              DataCell(Text("${row['wrong']}")),
                              DataCell(Text("${row['total']}")),
                              DataCell(
                                Text(
                                  "${row['correct']} / ${row['total']}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
