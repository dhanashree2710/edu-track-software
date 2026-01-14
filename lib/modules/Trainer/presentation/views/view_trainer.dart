import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewTrainerScreen extends StatefulWidget {
  const ViewTrainerScreen({super.key});

  @override
  State<ViewTrainerScreen> createState() => _ViewTrainerScreenState();
}

class _ViewTrainerScreenState extends State<ViewTrainerScreen> {
  String? editingTrainerId;

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController qualificationCtrl = TextEditingController();

  /// 🔹 Start Editing
  void startEdit(Map<String, dynamic> data) {
    setState(() {
      editingTrainerId = data['trainer_id'];
      nameCtrl.text = data['name'];
      emailCtrl.text = data['email'];
      phoneCtrl.text = data['phone'];
      qualificationCtrl.text = data['qualification'];
    });
  }

  /// 🔹 Update Trainer
  Future<void> updateTrainer(String id) async {
    await FirebaseFirestore.instance.collection('trainer').doc(id).update({
      'name': nameCtrl.text.trim(),
      'email': emailCtrl.text.trim(),
      'phone': phoneCtrl.text.trim(),
      'qualification': qualificationCtrl.text.trim(),
    });

    setState(() {
      editingTrainerId = null;
    });
  }

  /// 🔹 Delete Trainer
  Future<void> deleteTrainer(String id) async {
    await FirebaseFirestore.instance.collection('trainer').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      .collection('trainer')
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
              "Trainer Details",
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
          child: Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor:
                      MaterialStateProperty.all(Colors.blue.shade50),
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text("Sr.No")),
                    DataColumn(label: Text("Name")),
                    DataColumn(label: Text("Email")),
                    DataColumn(label: Text("Phone")),
                    DataColumn(label: Text("Qualification")),
                    DataColumn(label: Text("Actions")),
                  ],
                  rows: List.generate(docs.length, (index) {
                    final data =
                        docs[index].data() as Map<String, dynamic>;
                    final id = data['trainer_id'];
                    final isEditing = editingTrainerId == id;

                    return DataRow(
                      cells: [
                        DataCell(Text("${index + 1}")),

                        DataCell(
                          isEditing
                              ? TextField(controller: nameCtrl)
                              : Text(data['name']),
                        ),

                        DataCell(
                          isEditing
                              ? TextField(controller: emailCtrl)
                              : Text(data['email']),
                        ),

                        DataCell(
                          isEditing
                              ? TextField(controller: phoneCtrl)
                              : Text(data['phone']),
                        ),

                        DataCell(
                          isEditing
                              ? TextField(
                                  controller: qualificationCtrl)
                              : Text(data['qualification']),
                        ),

                        DataCell(
                          Row(
                            children: [
                              if (isEditing) ...[
                                IconButton(
                                  icon: const Icon(Icons.check,
                                      color: Colors.green),
                                  onPressed: () => updateTrainer(id),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.grey),
                                  onPressed: () {
                                    setState(() {
                                      editingTrainerId = null;
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
                                        title: const Text("Delete Trainer"),
                                        content: const Text(
                                            "Are you sure you want to delete this trainer?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              deleteTrainer(id);
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              "Delete",
                                              style: TextStyle(
                                                  color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ]
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
