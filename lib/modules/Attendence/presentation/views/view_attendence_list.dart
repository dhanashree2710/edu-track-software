import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudentAttendanceListScreen extends StatelessWidget {
  final String batchId;
  final String batchName;

  const StudentAttendanceListScreen({
    super.key,
    required this.batchId,
    required this.batchName,
  });

  // Format timestamp
  String formatTime(Timestamp? time) {
    if (time == null) return "-";
    return DateFormat('hh:mm a').format(time.toDate());
  }

  /// 🔹 Fetch student name using roll_no
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

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final batchIdPrefix = batchId.split('_').first;

    return Scaffold(
      backgroundColor: Colors.white,

      /// 🌈 App Bar
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("", style: TextStyle(color: Colors.white)),
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

      /// 🌟 Body
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('attendance').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          // Filter attendance by batch prefix & today's date
          final records = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final String? attendanceBatchId = data['batch_id'];
            final String? date = data['date'];
            return attendanceBatchId != null &&
                attendanceBatchId.startsWith(batchIdPrefix) &&
                date == today;
          }).toList();

          if (records.isEmpty) return const Center(child: Text("No attendance marked today"));

          // 🔹 Fetch student names
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: Future.wait(
              records.map((record) async {
                final attendance = record.data() as Map<String, dynamic>;
                final rollNo = attendance['student_id'] ?? '';
                final studentName = await getStudentName(rollNo);

                return {
                  'attendance': attendance,
                  'rollNo': rollNo,
                  'studentName': studentName,
                };
              }),
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final list = snapshot.data!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔹 Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

                  /// 📊 Table
                  Expanded(
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(Colors.blue.shade100),
                            columns: const [
                              DataColumn(label: Text("Sr No")),
                              DataColumn(label: Text("Roll No")),
                              DataColumn(label: Text("Student Name")),
                              DataColumn(label: Text("In Time")),
                              DataColumn(label: Text("Out Time")),
                              DataColumn(label: Text("Verified")),
                            ],
                            rows: List.generate(list.length, (index) {
                              final row = list[index];
                              final attendance = row['attendance'] as Map<String, dynamic>;
                              final rollNo = row['rollNo'] ?? '';
                              final studentName = row['studentName'] ?? '';

                              return DataRow(cells: [
                                DataCell(Text("${index + 1}")),
                                DataCell(Text(rollNo)),          // ✅ Roll No column
                                DataCell(Text(studentName)),     // ✅ Name column
                                DataCell(Text(formatTime(attendance['in_time']))),
                                DataCell(Text(formatTime(attendance['out_time']))),
                                DataCell(Text(attendance['verified_by'] ?? '')),
                              ]);
                            }),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
