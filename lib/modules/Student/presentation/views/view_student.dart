import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutrack_application/modules/Student/presentation/widgets/student_table_list.dart';
import 'package:flutter/material.dart';

class BatchCourseListScreen extends StatefulWidget {
  const BatchCourseListScreen({super.key});

  @override
  State<BatchCourseListScreen> createState() => _BatchCourseListScreenState();
}

class _BatchCourseListScreenState extends State<BatchCourseListScreen> {
  final LinearGradient redGradient = const LinearGradient(
    colors: [Color(0xff3f5efb), Color(0xfffc466b)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  List<Map<String, String>> batchCourseList = [];

  @override
  void initState() {
    super.initState();
    fetchBatchCourse();
  }

  Future<void> fetchBatchCourse() async {
    final snapshot = await FirebaseFirestore.instance.collection('student').get();
    final Set<String> unique = {};
    List<Map<String, String>> tempList = [];

    for (var doc in snapshot.docs) {
      String batch = doc['batch_name'] ?? '';
      String course = doc['course_name'] ?? '';
      String key = '$batch-$course';

      if (!unique.contains(key)) {
        unique.add(key);
        tempList.add({'batch': batch, 'course': course});
      }
    }

    setState(() {
      batchCourseList = tempList;
    });
  }

  Widget animatedCard(Map<String, String> bc) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StudentListScreen(
              batchName: bc['batch']!,
              courseName: bc['course']!,
            ),
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.45,
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          gradient: redGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              bc['batch']!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              bc['course']!,
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
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
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: batchCourseList.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Wrap(
                spacing: 12,
                runSpacing: 12,
                children: batchCourseList.map((bc) => animatedCard(bc)).toList(),
              ),
      ),
    );
  }
}
