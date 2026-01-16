import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditBatchScreen extends StatefulWidget {
  const EditBatchScreen({super.key});

  @override
  State<EditBatchScreen> createState() => _EditBatchScreenState();
}

class _EditBatchScreenState extends State<EditBatchScreen> {
  String? editingBatchId;
 String? editingBatchNo;

  final collegeCtrl = TextEditingController();
  final streamCtrl = TextEditingController();
  final courseCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final startCtrl = TextEditingController();
  final endCtrl = TextEditingController();

  /// 🔹 Start Editing
  void startEdit(Map<String, dynamic> data) {
    setState(() {
      editingBatchId = data['batch_id'];
      collegeCtrl.text = data['college_name'];
      streamCtrl.text = data['stream'];
      courseCtrl.text = data['course_name'];
      locationCtrl.text = data['location'];
      editingBatchNo = data['batch_no'];
      startCtrl.text = data['start_date'];
      endCtrl.text = data['end_date'];
    });
  }

  /// 🔹 Update Batch
  Future<void> updateBatch(String id) async {
    await FirebaseFirestore.instance
        .collection('batches')
        .doc(id)
        .update({
      'college_name': collegeCtrl.text.trim(),
      'stream': streamCtrl.text.trim(),
      'course_name': courseCtrl.text.trim(),
      'location': locationCtrl.text.trim(),
      'batch_no': editingBatchNo.toString().trim(),
      'start_date': startCtrl.text.trim(),
      'end_date': endCtrl.text.trim(),
    });

    setState(() => editingBatchId = null);
  }

  /// 🔹 Delete Batch
  Future<void> deleteBatch(String id) async {
    await FirebaseFirestore.instance.collection('batches').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,

      /// 🔹 APP BAR
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('batches')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
 return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// 🌈 GRADIENT TITLE
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xff3f5efb), Color(0xfffc466b)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: const Text(
              "Batches Details",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white, // overridden by shader
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        /// 📊 TABLE
        Expanded(
          child:  Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor:
                      WidgetStateProperty.all(Colors.blue.shade50),
                  columnSpacing: 30,
                  columns: const [
                    DataColumn(label: Text("Sr.No")),
                    DataColumn(label: Text("College")),
                    DataColumn(label: Text("Stream")),
                    DataColumn(label: Text("Course")),
                    DataColumn(label: Text("Location")),
                     DataColumn(label: Text("Batch")),
                    DataColumn(label: Text("Start Date")),
                    DataColumn(label: Text("End Date")),
                    DataColumn(label: Text("Actions")),
                  ],
                  rows: List.generate(docs.length, (index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final id = data['batch_id'];
                    final isEditing = editingBatchId == id;

                    return DataRow(
                      cells: [
                        DataCell(Text("${index + 1}")),

                        DataCell(isEditing
                            ? TextField(controller: collegeCtrl)
                            : Text(data['college_name'])),

                        DataCell(isEditing
                            ? TextField(controller: streamCtrl)
                            : Text(data['stream'])),

                        DataCell(isEditing
                            ? TextField(controller: courseCtrl)
                            : Text(data['course_name'])),

                        DataCell(isEditing
                            ? TextField(controller: locationCtrl)
                            : Text(data['location'])),
                        
                        DataCell(isEditing
                            ? TextField(controller: locationCtrl)
                            : Text(data['batch_no'])),

                        DataCell(isEditing
                            ? TextField(controller: startCtrl)
                            : Text(data['start_date'])),

                        DataCell(isEditing
                            ? TextField(controller: endCtrl)
                            : Text(data['end_date'])),

                        /// ACTIONS
                        DataCell(
                          Row(
                            children: [
                              if (isEditing) ...[
                                IconButton(
                                  icon: const Icon(Icons.check,
                                      color: Colors.green),
                                  onPressed: () => updateBatch(id),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.grey),
                                  onPressed: () {
                                    setState(() {
                                      editingBatchId = null;
                                    });
                                  },
                                ),
                              ] else ...[
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () => startEdit(data),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text("Delete Batch"),
                                        content: const Text(
                                            "Are you sure you want to delete this batch?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              deleteBatch(id);
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              "Delete",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
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
          ]);
        },
      ),
    );
  }
}
