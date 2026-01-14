import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutrack_application/modules/Attendence/presentation/views/view_attendence_list.dart';
import 'package:flutter/material.dart';

class ViewAttendanceScreen extends StatelessWidget {
  const ViewAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LinearGradient gradient = const LinearGradient(
      colors: [Color(0xff3f5efb), Color(0xfffc466b)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      backgroundColor: Colors.white,

      /// 🌈 APP BAR
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: gradient),
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
        stream: FirebaseFirestore.instance.collection('batches').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final batches = snapshot.data!.docs;

          if (batches.isEmpty) return const Center(child: Text("No batches found"));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: batches.length,
            itemBuilder: (context, index) {
              final batchDoc = batches[index];
              final data = batchDoc.data() as Map<String, dynamic>;
              final batchId = batchDoc.id;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  gradient: gradient, // gradient border
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(1.5), // border width
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // inner card
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    title: Text(
                      data['course_name'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text("Batch: ${data['course_name']} - ${data['batch_no'] ?? ''}"),
                        Text("College: ${data['college_name'] ?? ''}"),
                      ],
                    ),
                    trailing: ShaderMask(
                      shaderCallback: (bounds) => gradient.createShader(bounds),
                      child: const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StudentAttendanceListScreen(
                            batchId: batchId,
                            batchName: "${data['course_name']} - ${data['batch_no'] ?? ''}",
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
