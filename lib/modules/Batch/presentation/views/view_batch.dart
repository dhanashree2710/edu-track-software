import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutrack_application/modules/Batch/presentation/views/batch_detail_screen.dart';
import 'package:flutter/material.dart';


class CollegesScreen extends StatelessWidget {
  const CollegesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: Colors.white,
  appBar: AppBar(
    elevation: 0,

    /// ✅ SHOW BACK ARROW
    automaticallyImplyLeading: true,

    /// ✅ BACK ARROW COLOR WHITE
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
        stream: FirebaseFirestore.instance.collection('batches').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Extract unique colleges from batches
          final batches = snapshot.data!.docs;
          final colleges = batches
              .map((e) => e['college_name'] ?? '')
              .toSet()
              .toList(); // unique

          if (colleges.isEmpty) {
            return const Center(child: Text("No colleges found"));
          }

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
                      builder: (_) => BatchesByCollegeScreen(collegeName: collegeName),
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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


class BatchesByCollegeScreen extends StatelessWidget {
  final String collegeName;
  const BatchesByCollegeScreen({super.key, required this.collegeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: Colors.white,
  appBar: AppBar(
    elevation: 0,

    /// ✅ SHOW BACK ARROW
    automaticallyImplyLeading: true,

    /// ✅ BACK ARROW COLOR WHITE
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
            .where('college_name', isEqualTo: collegeName)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final batches = snapshot.data!.docs;

          if (batches.isEmpty) return const Center(child: Text("No batches found"));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: batches.length,
            itemBuilder: (context, index) {
              final batch = batches[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff3f5efb), Color(0xfffc466b)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.all(1.5),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    title: Text(
                      "${batch['stream']} - ${batch['course_name']}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        batch['batch_no'] ?? '',
                        style: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 22, 22, 22)),
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BatchDetailsScreen(batchData: batch),
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
