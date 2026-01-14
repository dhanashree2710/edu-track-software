import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutrack_application/modules/Assessment/presentation/views/college_list.dart';
import 'package:edutrack_application/modules/Assessment/presentation/views/student_assessment_result_list.dart';
import 'package:flutter/material.dart';

class AssessmentCollegesScreen extends StatelessWidget {
  const AssessmentCollegesScreen({super.key});

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
          final colleges = batches.map((e) => e['college_name'] ?? '').toSet().toList();

          if (colleges.isEmpty) return const Center(child: Text("No colleges found"));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: colleges.length,
            itemBuilder: (context, index) {
              final collegeName = colleges[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CollegeBatchListScreen(collegeName: collegeName),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xff3f5efb), Color(0xfffc466b)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    collegeName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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
