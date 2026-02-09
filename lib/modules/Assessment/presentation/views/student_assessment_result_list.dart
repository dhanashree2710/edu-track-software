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



Future<void> deleteResult(BuildContext context, String docId) async {
  try {
    await FirebaseFirestore.instance
        .collection('assessment_results')
        .doc(docId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Result deleted successfully")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Delete failed: $e")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
  final batchPrefix = batchName; // e.g., "BG01"



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
        //  stream: FirebaseFirestore.instance
        //     .collection('assessment_results')
        //     .where('assessment_id', isEqualTo: assessmentId)
        //     .where('batch_name', isEqualTo: batchName) // FILTER ADDED
        //     .snapshots(),
        // stream: FirebaseFirestore.instance
        //     .collection('assessment_results')
        //     .where('assessment_id', isEqualTo: assessmentId)
        //     .snapshots(),
//             stream: FirebaseFirestore.instance
//     .collection('assessment_results')
//     .where('assessment_id', isEqualTo: assessmentId)
//     .where('batch_name', isGreaterThanOrEqualTo: 'BFSI - $batchPrefix')
//     .where('batch_name', isLessThan: 'BFSI - $batchPrefix\uf8ff')
//     .snapshots(),
//         builder: (_, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final docs = snapshot.data!.docs;
//           if (docs.isEmpty) {
//             return const Center(child: Text("No results found"));
//           }
// print("assessmentId = $assessmentId");
// print("batchName = $batchName");

//        /// 🔹 Deduplicate by roll_no + keep docId
// final Map<String, Map<String, dynamic>> unique = {};

// for (var doc in docs) {
//   final data = doc.data() as Map<String, dynamic>;

//   final rollNo = data['roll_no']?.toString() ?? '';
//   data['docId'] = doc.id; // store document id safely

//   if (rollNo.isNotEmpty) {
//     unique.putIfAbsent(rollNo, () => data);
//   }
// }


//           /// 🔹 Sort
//           final studentList = unique.values.toList()..sort(rollSort);
stream: FirebaseFirestore.instance
    .collection('assessment_results')
    .where('assessment_id', isEqualTo: assessmentId)
    .snapshots(),
builder: (_, snapshot) {
  if (!snapshot.hasData) {
    return const Center(child: CircularProgressIndicator());
  }

  // Filter client-side by batch code (e.g., "BG01")
final docs = snapshot.data!.docs.where((doc) {
  final data = doc.data() as Map<String, dynamic>;
  final batch = data['batch_name']?.toString() ?? '';
  return batch.contains(batchName);
}).toList();


  if (docs.isEmpty) {
    return const Center(child: Text("No results found"));
  }

  /// 🔹 Deduplicate by roll_no + keep docId
  final Map<String, Map<String, dynamic>> unique = {};
  for (var doc in docs) {
    final data = doc.data() as Map<String, dynamic>;
    final rollNo = data['roll_no']?.toString() ?? '';
    data['docId'] = doc.id; // store document id safely
    if (rollNo.isNotEmpty) {
      unique.putIfAbsent(rollNo, () => data);
    }
  }

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
                            DataColumn(label: Text("Delete")), // NEW
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
                              DataCell(
  IconButton(
    icon: const Icon(Icons.delete, color: Colors.red),
   onPressed: () async {
  final confirm = await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Delete Result"),
      content: const Text("Are you sure you want to delete this result?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text("Delete"),
        ),
      ],
    ),
  );

  if (confirm == true) {
    deleteResult(context, row['docId']);
  }
}

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


// import 'dart:convert';
// import 'dart:typed_data';
// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:csv/csv.dart';
// import 'package:universal_html/html.dart' as html;


// class StudentAssessmentResultList extends StatelessWidget {
//   final String assessmentId;
//   final String batchName;

//   const StudentAssessmentResultList({
//     super.key,
//     required this.assessmentId,
//     required this.batchName,
//   });

//   Future<String> getStudentName(String rollNo) async {
//     if (rollNo.isEmpty) return rollNo;
//     try {
//       final query = await FirebaseFirestore.instance
//           .collection('student')
//           .where('roll_no', isEqualTo: rollNo)
//           .limit(1)
//           .get();

// print("Searching student with roll_no: $rollNo");

//       if (query.docs.isNotEmpty) {
//         return query.docs.first.data()['name'] ?? rollNo;
//       }
//       return rollNo;
//     } catch (e) {
//       return rollNo;
//     }
//   }

//   Future<void> exportCsv(String csvData, String fileName) async {
//     Uint8List bytes = Uint8List.fromList(utf8.encode(csvData));

//     if (kIsWeb) {
//       final blob = html.Blob([bytes]);
//       final url = html.Url.createObjectUrlFromBlob(blob);
//       final anchor = html.AnchorElement(href: url)
//         ..setAttribute("download", fileName)
//         ..click();
//       html.Url.revokeObjectUrl(url);
//     } else {
//       final directory = await getApplicationDocumentsDirectory();
//       final path = "${directory.path}/$fileName";
//       final file = File(path);
//       await file.writeAsBytes(bytes);
//     }
//   }

//   Future<void> downloadCSV(
//     BuildContext context,
//     List<Map<String, dynamic>> students,
//   ) async {
//     List<List<String>> csvData = [
//       [
//         "Sr No",
//         "Roll No",
//         "Student Name",
//         "Correct",
//         "Wrong",
//         "Total",
//         "Score"
//       ],
//     ];

//     int i = 1;
//     for (var s in students) {
//       final name = await getStudentName(s['roll_no']);
//       csvData.add([
//         i.toString(),
//         s['roll_no'] ?? '',
//         name,
//         "${s['correct']}",
//         "${s['wrong']}",
//         "${s['total']}",
//         "${s['correct']} / ${s['total']}",
//       ]);
//       i++;
//     }

//     final csv = const ListToCsvConverter().convert(csvData);

//     await exportCsv(csv, "$batchName Assessment Results.csv");

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("CSV downloaded successfully")),
//     );
//   }

//   int rollSort(dynamic a, dynamic b) {
//     final rollA = a['roll_no']?.toString() ?? '';
//     final rollB = b['roll_no']?.toString() ?? '';

//     final numA =
//         int.tryParse(RegExp(r'\d+').firstMatch(rollA)?.group(0) ?? '0') ?? 0;
//     final numB =
//         int.tryParse(RegExp(r'\d+').firstMatch(rollB)?.group(0) ?? '0') ?? 0;

//     if (numA != numB) return numA.compareTo(numB);
//     return rollA.compareTo(rollB);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,

//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         backgroundColor: Colors.transparent,
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xff3f5efb), Color(0xfffc466b)],
//             ),
//           ),
//         ),
//         title: const Text("", style: TextStyle(color: Colors.white)),
//       ),

//       body: StreamBuilder<QuerySnapshot>(
//         // stream: FirebaseFirestore.instance
//         //     .collection('assessment_results')
//         //     .where('assessment_id', isEqualTo: assessmentId)
//         //     .where('batch_name', isEqualTo: batchName) // FILTER ADDED
//         //     .snapshots(),
//         stream: FirebaseFirestore.instance
//     .collection('assessment_results')
//     .where('assessment_id', isEqualTo: assessmentId)
//     .snapshots(),

//         builder: (_, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final docs = snapshot.data!.docs;
//           if (docs.isEmpty) {
//             return const Center(child: Text("No results found"));
//           }

//           final Map<String, Map<String, dynamic>> unique = {};

//           for (var doc in docs) {
//             final data = doc.data() as Map<String, dynamic>;
//             data['docId'] = doc.id; // STORE DOC ID
//               print("Document ID: ${doc.id}");
//   print("Document Data: $data");
//             unique.putIfAbsent(data['roll_no'], () => data);
//           }

//           final studentList = unique.values.toList()..sort(rollSort);

//           return Column(
//             children: [
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: ShaderMask(
//                         shaderCallback: (bounds) =>
//                             const LinearGradient(
//                           colors: [Color(0xff3f5efb), Color(0xfffc466b)],
//                         ).createShader(bounds),
//                         child: Text(
//                           "Assessment - $batchName",
//                           style: const TextStyle(
//                             fontSize: 26,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.download, size: 28),
//                       onPressed: () =>
//                           downloadCSV(context, studentList),
//                     ),
//                   ],
//                 ),
//               ),

//               Expanded(
//                 child: Scrollbar(
//                   thumbVisibility: true,
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.vertical,
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: DataTable(
//                         headingRowColor:
//                             MaterialStateProperty.all(
//                           const Color(0xff3f5efb),
//                         ),
//                         headingTextStyle: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         columns: const [
//                           DataColumn(label: Text("Sr No")),
//                           DataColumn(label: Text("Roll No")),
//                           DataColumn(label: Text("Student Name")),
//                           DataColumn(label: Text("Correct")),
//                           DataColumn(label: Text("Wrong")),
//                           DataColumn(label: Text("Total")),
//                           DataColumn(label: Text("Score")),
//                         ],
//                         rows: List.generate(studentList.length, (index) {
//                           final row = studentList[index];
//                           final rollNo = row['roll_no'];

//                           return DataRow(
//                             onSelectChanged: (_) {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => EditResultScreen(
//   docId: row['docId'],
//   rollNo: row['roll_no'],
//   correct: row['correct'],
//   wrong: row['wrong'],
//   total: row['total'],
// )

//                                 ),
//                               );
//                             },
//                             cells: [
//                               DataCell(Text("${index + 1}")),
//                               DataCell(Text(rollNo)),
//                               DataCell(
//                                 FutureBuilder<String>(
//                                   future: getStudentName(rollNo),
//                                   builder: (_, snap) {
//                                     if (!snap.hasData) {
//                                       return const SizedBox(
//                                         width: 60,
//                                         child:
//                                             LinearProgressIndicator(),
//                                       );
//                                     }
//                                     return Text(snap.data!);
//                                   },
//                                 ),
//                               ),
//                               DataCell(Text("${row['correct']}")),
//                               DataCell(Text("${row['wrong']}")),
//                               DataCell(Text("${row['total']}")),
//                               DataCell(
//                                 Text(
//                                   "${row['correct']} / ${row['total']}",
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           );
//                         }),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }



// class EditResultScreen extends StatefulWidget {
//   final String docId;
//   final String rollNo;
//   final int correct;
//   final int wrong;
//   final int total;

//   const EditResultScreen({
//     super.key,
//     required this.docId,
//     required this.rollNo,
//     required this.correct,
//     required this.wrong,
//     required this.total,
//   });

//   @override
//   State<EditResultScreen> createState() => _EditResultScreenState();
// }

// class _EditResultScreenState extends State<EditResultScreen> {
//   late TextEditingController rollController;
//   late TextEditingController correctController;
//   late TextEditingController wrongController;

//   @override
//   void initState() {
//     super.initState();

//     rollController =
//         TextEditingController(text: widget.rollNo);
//     correctController =
//         TextEditingController(text: widget.correct.toString());
//     wrongController =
//         TextEditingController(text: widget.wrong.toString());
//   }

//   Future<void> updateResult() async {
//     final correct = int.tryParse(correctController.text) ?? 0;
//     final wrong = int.tryParse(wrongController.text) ?? 0;
//     final total = correct + wrong;

//     await FirebaseFirestore.instance
//         .collection('assessment_results')
//         .doc(widget.docId)
//         .update({
//       'roll_no': rollController.text,
//       'correct': correct,
//       'wrong': wrong,
//       'total': total,
//       'score': "$correct / $total",
//     });

//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Edit Result")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: rollController,
//               decoration: const InputDecoration(
//                 labelText: "Roll No",
//               ),
//             ),
//             TextField(
//               controller: correctController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 labelText: "Correct",
//               ),
//             ),
//             TextField(
//               controller: wrongController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 labelText: "Wrong",
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: updateResult,
//               child: const Text("Update"),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
