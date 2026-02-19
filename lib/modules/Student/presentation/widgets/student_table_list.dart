import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentListScreen extends StatefulWidget {
  final String batchName;
  final String courseName;

  const StudentListScreen({
    super.key,
    required this.batchName,
    required this.courseName,
  });

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  String? editingStudentId;

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final rollCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final classCtrl = TextEditingController();
  final collegeCtrl = TextEditingController();
final streamCtrl = TextEditingController();
final courseCtrl = TextEditingController();
final batchCtrl = TextEditingController();


  /// ▶ Start Edit
  void startEdit(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    setState(() {
     editingStudentId = doc.id;
    nameCtrl.text = data['name'] ?? '';
    emailCtrl.text = data['email'] ?? '';
    phoneCtrl.text = data['phone'] ?? '';
    rollCtrl.text = data['roll_no'] ?? '';
    passwordCtrl.text = data['password'] ?? '';
    classCtrl.text = data['class'] ?? '';

    collegeCtrl.text = data['college_name'] ?? '';
    streamCtrl.text = data['stream'] ?? '';
    courseCtrl.text = data['course_name'] ?? '';
    batchCtrl.text = data['batch_name'] ?? '';
    });
  }

  /// ▶ Update Student
  Future<void> updateStudent(String docId) async {
    await FirebaseFirestore.instance
        .collection('student')
        .doc(docId)
        .update({
        'name': nameCtrl.text.trim(),
    'email': emailCtrl.text.trim(),
    'phone': phoneCtrl.text.trim(),
    'roll_no': rollCtrl.text.trim(),
    'password': passwordCtrl.text.trim(),
    'class': classCtrl.text.trim(),

    'college_name': collegeCtrl.text.trim(),
    'stream': streamCtrl.text.trim(),
    'course_name': courseCtrl.text.trim(),
    'batch_name': batchCtrl.text.trim(),
    });

    setState(() => editingStudentId = null);
  }

  /// ▶ Delete Student
  Future<void> deleteStudent(String docId) async {
    await FirebaseFirestore.instance
        .collection('student')
        .doc(docId)
        .delete();
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
          "${widget.batchName}",
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
            .collection('student')
            .where('batch_name', isEqualTo: widget.batchName.trim())
            .where('course_name', isEqualTo: widget.courseName.trim())
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No students found"));
          }

         // final docs = snapshot.data!.docs;
final docs = snapshot.data!.docs.toList();

docs.sort((a, b) {
  final rollA = (a['roll_no'] ?? '').toString();
  final rollB = (b['roll_no'] ?? '').toString();

  // Extract numeric part safely (BG0110 → 110)
  final numA =
      int.tryParse(RegExp(r'\d+').firstMatch(rollA)?.group(0) ?? '0') ?? 0;
  final numB =
      int.tryParse(RegExp(r'\d+').firstMatch(rollB)?.group(0) ?? '0') ?? 0;

  // Primary sort → numeric
  if (numA != numB) {
    return numA.compareTo(numB);
  }

  // Secondary fallback → string
  return rollA.compareTo(rollB);
});

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
                        columnSpacing: 28,
                        headingRowColor:
                            WidgetStateProperty.all(Colors.blue.shade50),
                       columns: const [
  DataColumn(label: Text("Sr.No")),
  DataColumn(label: Text("Name")),
  DataColumn(label: Text("Email")),
  DataColumn(label: Text("Phone")),
  DataColumn(label: Text("Roll No")),
  DataColumn(label: Text("Class")),
  DataColumn(label: Text("College")),
  DataColumn(label: Text("Stream")),
  DataColumn(label: Text("Course")),
  DataColumn(label: Text("Batch")),
  DataColumn(label: Text("Password")),
  DataColumn(label: Text("Actions")),
],

                        rows: List.generate(docs.length, (index) {
                          final doc = docs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final isEditing = editingStudentId == doc.id;

                          return DataRow(
  cells: [
    DataCell(Text("${index + 1}")),

    DataCell(isEditing
        ? TextField(controller: nameCtrl)
        : Text(data['name'] ?? '')),

    DataCell(isEditing
        ? TextField(controller: emailCtrl)
        : Text(data['email'] ?? '')),

    DataCell(isEditing
        ? TextField(controller: phoneCtrl)
        : Text(data['phone'] ?? '')),

    DataCell(isEditing
        ? TextField(controller: rollCtrl)
        : Text(data['roll_no'] ?? '')),

    DataCell(isEditing
        ? TextField(controller: classCtrl)
        : Text(data['class'] ?? '')),

    DataCell(isEditing
        ? TextField(controller: passwordCtrl)
        : Text(data['password'] ?? '')),

    DataCell(isEditing
        ? TextField(controller: collegeCtrl)
        : Text(data['college_name'] ?? '')),

    DataCell(isEditing
        ? TextField(controller: streamCtrl)
        : Text(data['stream'] ?? '')),

    DataCell(isEditing
        ? TextField(controller: courseCtrl)
        : Text(data['course_name'] ?? '')),

    DataCell(isEditing
        ? TextField(controller: batchCtrl)
        : Text(data['batch_name'] ?? '')),

    DataCell(
      Row(
        children: [
          if (isEditing) ...[
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () => updateStudent(doc.id),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () =>
                  setState(() => editingStudentId = null),
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => startEdit(doc),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => deleteStudent(doc.id),
            ),
          ],
        ],
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
