// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class StudentAttendanceListScreen extends StatelessWidget {
//   final String batchId;
//   final String batchName;

//   const StudentAttendanceListScreen({
//     super.key,
//     required this.batchId,
//     required this.batchName,
//   });

//   // Format timestamp
//   String formatTime(Timestamp? time) {
//     if (time == null) return "-";
//     return DateFormat('hh:mm a').format(time.toDate());
//   }

//   /// 🔹 Fetch student name using roll_no
//   Future<String> getStudentName(String rollNo) async {
//     if (rollNo.isEmpty) return rollNo;

//     try {
//       final query = await FirebaseFirestore.instance
//           .collection('student')
//           .where('roll_no', isEqualTo: rollNo)
//           .limit(1)
//           .get();

//       if (query.docs.isNotEmpty) {
//         final data = query.docs.first.data();
//         return data['name'] ?? rollNo;
//       }
//       return rollNo;
//     } catch (e) {
//       print("Error fetching student name for $rollNo: $e");
//       return rollNo;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final today = DateTime.now().toIso8601String().substring(0, 10);
//     final batchIdPrefix = batchId.split('_').first;

//     return Scaffold(
//       backgroundColor: Colors.white,

//       /// 🌈 App Bar
//       appBar: AppBar(
//         elevation: 0,
//         automaticallyImplyLeading: true,
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: const Text("", style: TextStyle(color: Colors.white)),
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

//       /// 🌟 Body
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance.collection('attendance').snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

//           // Filter attendance by batch prefix & today's date
//           final records = snapshot.data!.docs.where((doc) {
//             final data = doc.data() as Map<String, dynamic>;
//             final String? attendanceBatchId = data['batch_id'];
//             final String? date = data['date'];
//             return attendanceBatchId != null &&
//                 attendanceBatchId.startsWith(batchIdPrefix) &&
//                 date == today;
//           }).toList();

//           if (records.isEmpty) return const Center(child: Text("No attendance marked today"));

//           // 🔹 Fetch student names
//           return FutureBuilder<List<Map<String, dynamic>>>(
//             future: Future.wait(
//               records.map((record) async {
//                 final attendance = record.data() as Map<String, dynamic>;
//                 final rollNo = attendance['student_id'] ?? '';
//                 final studentName = await getStudentName(rollNo);

//                 return {
//                   'attendance': attendance,
//                   'rollNo': rollNo,
//                   'studentName': studentName,
//                 };
//               }),
//             ),
//             builder: (context, snapshot) {
//               if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
//               final list = snapshot.data!;

//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   /// 🔹 Title
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                     child: ShaderMask(
//                       shaderCallback: (bounds) => const LinearGradient(
//                         colors: [Color(0xff3f5efb), Color(0xfffc466b)],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ).createShader(bounds),
//                       child: Text(
//                         "Attendance - $batchName",
//                         style: const TextStyle(
//                           fontSize: 26,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),

//                   /// 📊 Table
//                   Expanded(
//                     child: Scrollbar(
//                       thumbVisibility: true,
//                       child: SingleChildScrollView(
//                         scrollDirection: Axis.vertical,
//                         child: SingleChildScrollView(
//                           scrollDirection: Axis.horizontal,
//                           child: DataTable(
//                             headingRowColor: MaterialStateProperty.all(Colors.blue.shade100),
//                             columns: const [
//                               DataColumn(label: Text("Sr No")),
//                               DataColumn(label: Text("Roll No")),
//                               DataColumn(label: Text("Student Name")),
//                               DataColumn(label: Text("In Time")),
//                               DataColumn(label: Text("Out Time")),
//                               DataColumn(label: Text("Verified")),
//                             ],
//                             rows: List.generate(list.length, (index) {
//                               final row = list[index];
//                               final attendance = row['attendance'] as Map<String, dynamic>;
//                               final rollNo = row['rollNo'] ?? '';
//                               final studentName = row['studentName'] ?? '';

//                               return DataRow(cells: [
//                                 DataCell(Text("${index + 1}")),
//                                 DataCell(Text(rollNo)),          // ✅ Roll No column
//                                 DataCell(Text(studentName)),     // ✅ Name column
//                                 DataCell(Text(formatTime(attendance['in_time']))),
//                                 DataCell(Text(formatTime(attendance['out_time']))),
//                                 DataCell(Text(attendance['verified_by'] ?? '')),
//                               ]);
//                             }),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:universal_html/html.dart' as html;

class StudentAttendanceListScreen extends StatelessWidget {
  final String batchId;
  final String batchName;

  const StudentAttendanceListScreen({
    super.key,
    required this.batchId,
    required this.batchName,
  });

  /// Format Firestore Timestamp to readable time
  String formatTime(Timestamp? time) {
    if (time == null) return "-";
    return DateFormat('hh:mm a').format(time.toDate());
  }

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
        final data = query.docs.first.data();
        return data['name'] ?? rollNo;
      }
      return rollNo;
    } catch (e) {
      print("Error fetching student name for $rollNo: $e");
      return rollNo;
    }
  }

  /// Export CSV for web/mobile/desktop
  Future<void> exportCsv(String csvData, String fileName) async {
    Uint8List bytes = Uint8List.fromList(utf8.encode(csvData));

    if (kIsWeb) {
      // Web download
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // Mobile/Desktop save
      final directory = await getApplicationDocumentsDirectory();
      final path = "${directory.path}/$fileName";
      final file = File(path);
      await file.writeAsBytes(bytes);
      print("CSV saved at: $path");
    }
  }

  /// Download CSV
  Future<void> downloadCSV(List<Map<String, dynamic>> attendanceList) async {
    // Sort by date then roll number
    attendanceList.sort((a, b) {
      final dateA = a['attendance']['date'] ?? '';
      final dateB = b['attendance']['date'] ?? '';
      final rollA = a['rollNo'] ?? '';
      final rollB = b['rollNo'] ?? '';
      final dateCompare = dateA.compareTo(dateB);
      if (dateCompare != 0) return dateCompare;
      return rollA.compareTo(rollB);
    });

    // CSV headers
    List<List<String>> csvData = [
      ["Date", "Roll No", "Student Name", "In Time", "Out Time", "Verified By"],
    ];

    // CSV rows
    for (var item in attendanceList) {
      final attendance = item['attendance'] as Map<String, dynamic>;
      csvData.add([
        attendance['date'] ?? '',
        item['rollNo'] ?? '',
        item['studentName'] ?? '',
        formatTime(attendance['in_time']),
        formatTime(attendance['out_time']),
        attendance['verified_by'] ?? '',
      ]);
    }

    String csv = const ListToCsvConverter().convert(csvData);

    await exportCsv(csv, "$batchName Attendance.csv");
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
        title: const Text("", style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Batch name + download icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xff3f5efb), Color(0xfffc466b)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      "Attendance - $batchName",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.download,
                    color: Colors.black,
                    size: 28,
                  ),
                  onPressed: () async {
                    try {
                      final snapshot = await FirebaseFirestore.instance
                          .collection('attendance')
                          .where('batch_id', isEqualTo: batchId)
                          .get();

                      if (snapshot.docs.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("No attendance records to download"),
                          ),
                        );
                        return;
                      }

                      // Fetch student names
                      final attendanceList = await Future.wait(
                        snapshot.docs.map((doc) async {
                          final data = doc.data() as Map<String, dynamic>;
                          final rollNo = data['student_id'] ?? '';
                          final studentName = await getStudentName(rollNo);
                          return {
                            'attendance': data,
                            'rollNo': rollNo,
                            'studentName': studentName,
                          };
                        }),
                      );

                      await downloadCSV(attendanceList);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Attendance downloaded successfully"),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("Error: $e")));
                    }
                  },
                ),
              ],
            ),
          ),

          // Attendance list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('attendance')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                final records = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['batch_id'] == batchId;
                }).toList();


                if (records.isEmpty)
                  return const Center(
                    child: Text("No attendance records found"),
                  );

                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: Future.wait(
                    records.map((record) async {
                      final data = record.data() as Map<String, dynamic>;
                      final rollNo = data['student_id'] ?? '';
                      final studentName = await getStudentName(rollNo);
                      return {
                        'attendance': data,
                        'rollNo': rollNo,
                        'studentName': studentName,
                        'docId': record.id, // ✅ ADD THIS
                      };
                    }),
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return const Center(child: CircularProgressIndicator());
                    final list = snapshot.data!;

                    // Group by date
                    final Map<String, List<Map<String, dynamic>>> grouped = {};
                    for (var item in list) {
                      final date = item['attendance']['date'] ?? 'Unknown';
                      grouped.putIfAbsent(date, () => []).add(item);
                    }

// ✅ SORT EACH DATE GROUP BY ROLL NO (ASCENDING)
grouped.forEach((date, items) {
  items.sort((a, b) {
    final rollA = a['rollNo']?.toString() ?? '';
    final rollB = b['rollNo']?.toString() ?? '';

    // Extract numbers from rollNo (e.g. BG0110 -> 110)
    final numA =
        int.tryParse(RegExp(r'\d+').firstMatch(rollA)?.group(0) ?? '0') ?? 0;
    final numB =
        int.tryParse(RegExp(r'\d+').firstMatch(rollB)?.group(0) ?? '0') ?? 0;

    // If numeric part differs → sort by number
    if (numA != numB) {
      return numA.compareTo(numB);
    }

    // Otherwise → fallback to string sort
    return rollA.compareTo(rollB);
  });
});



                    return ListView(
                      children: grouped.entries.map((entry) {
                        final date = entry.key;
                        final items = entry.value;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ExpansionTile(
                              initiallyExpanded: true,
                              title: Text(
                                "Date: $date",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    headingRowColor: MaterialStateProperty.all(
                                      Colors.blue.shade100,
                                    ),
                                    columns: const [
                                      DataColumn(label: Text("Sr No")),
                                      DataColumn(label: Text("Roll No")),
                                      DataColumn(label: Text("Student Name")),
                                      DataColumn(label: Text("In Time")),
                                      DataColumn(label: Text("Out Time")),
                                      DataColumn(label: Text("Verified")),
                                      DataColumn(label: Text("Delete")),
                                    ],
                                    rows: List.generate(items.length, (index) {
                                      final row = items[index];
                                      final attendance =
                                          row['attendance']
                                              as Map<String, dynamic>;

                                      return DataRow(
                                        cells: [
                                          DataCell(Text("${index + 1}")),
                                          DataCell(Text(row['rollNo'] ?? '')),
                                          DataCell(
                                            Text(row['studentName'] ?? ''),
                                          ),
                                          DataCell(
                                            Text(
                                              formatTime(attendance['in_time']),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              formatTime(
                                                attendance['out_time'],
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              attendance['verified_by'] ?? '',
                                            ),
                                          ),

                                          // 🗑 DELETE ICON (ONLY ADDITION)
                                          DataCell(
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed: () async {
                                                final confirm = await showDialog<bool>(
                                                  context: context,
                                                  builder: (ctx) => AlertDialog(
                                                    title: const Text(
                                                      "Delete Attendance",
                                                    ),
                                                    content: const Text(
                                                      "Are you sure you want to delete this attendance record?",
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              ctx,
                                                              false,
                                                            ),
                                                        child: const Text(
                                                          "Cancel",
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              ctx,
                                                              true,
                                                            ),
                                                        style:
                                                            ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                                  Colors.red,
                                                            ),
                                                        child: const Text(
                                                          "Delete",
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );

                                                if (confirm == true) {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('attendance')
                                                      .doc(
                                                        row['docId'],
                                                      ) // ✅ CORRECT
                                                      .delete();
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
