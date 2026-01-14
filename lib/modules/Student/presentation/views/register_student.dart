import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutrack_application/utils/common/pop_up_screen.dart';
import 'package:flutter/material.dart';

class StudentRegisterScreen extends StatefulWidget {
  const StudentRegisterScreen({super.key});

  @override
  State<StudentRegisterScreen> createState() => _StudentRegisterScreenState();
}

class _StudentRegisterScreenState extends State<StudentRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController rollNoCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController streamCtrl = TextEditingController();
  final TextEditingController classCtrl = TextEditingController();

  bool loading = false;

  /// 🔹 Firestore dropdown values
  List<QueryDocumentSnapshot> batches = [];
  String? selectedCollege;
  String? selectedBatch;
  String? selectedCourse;

  final LinearGradient redGradient = const LinearGradient(
    colors: [Color(0xff3f5efb), Color(0xfffc466b)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    fetchBatches();
  }

  /// 🔹 Fetch batches from Firestore
  Future<void> fetchBatches() async {
    final snapshot = await FirebaseFirestore.instance.collection('batches').get();
    setState(() {
      batches = snapshot.docs;
    });
  }

 /// 🔹 Register Student
Future<void> registerStudent() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => loading = true);

  try {
    String studentId = FirebaseFirestore.instance.collection('student').doc().id;

    await FirebaseFirestore.instance.collection('student').doc(studentId).set({
      'student_id': studentId,
      'roll_no': rollNoCtrl.text.trim(),
      'name': nameCtrl.text.trim(),
      'email': emailCtrl.text.trim(),
      'password': passwordCtrl.text.trim(),
      'phone': phoneCtrl.text.trim(),
      'stream': streamCtrl.text.trim(),
      'class': classCtrl.text.trim(),
      'college_name': selectedCollege,
      'batch_name': selectedBatch,
      'course_name': selectedCourse,
      'created_at': Timestamp.now(),
    });

    // ✅ Use custom popup instead of SnackBar
    showCustomAlert(
      context,
      isSuccess: true,
      title: "Success",
      description: "Student registered successfully!",
      nextScreen: null, // You can navigate to another screen if needed
    );

    // Clear fields
    rollNoCtrl.clear();
    nameCtrl.clear();
    emailCtrl.clear();
    passwordCtrl.clear();
    phoneCtrl.clear();
    streamCtrl.clear();
    classCtrl.clear();
    setState(() {
      selectedCollege = null;
      selectedBatch = null;
      selectedCourse = null;
    });
  } catch (e) {
    // ✅ Use custom popup for errors
    showCustomAlert(
      context,
      isSuccess: false,
      title: "Failed",
      description: "Failed to register student: $e",
      nextScreen: null,
    );
  } finally {
    setState(() => loading = false);
  }
}

  /// 🔹 Gradient Text Field
  Widget gradientTextField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: redGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(2), // border thickness
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          ),
        ),
      ),
    );
  }

  /// 🔹 Gradient Dropdown
  Widget gradientDropdown({
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: redGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: const InputDecoration(border: InputBorder.none),
          items: items,
          onChanged: onChanged,
          validator: validator,
          hint: Text(hint),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => redGradient.createShader(bounds),
                child: const Text(
                  "Register Student",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              /// 🔹 Dropdowns from batches table
              gradientDropdown(
                hint: "Select College",
                value: selectedCollege,
                items: batches
                    .map((b) => DropdownMenuItem<String>(
                          value: b['college_name'],
                          child: Text(b['college_name']),
                        ))
                    .toSet()
                    .toList(),
                onChanged: (val) => setState(() => selectedCollege = val),
                validator: (v) => v == null ? "Select College" : null,
              ),
              const SizedBox(height: 12),

             gradientDropdown(
                hint: "Select Batch",
                value: selectedBatch,
                items: batches
                    .map((b) => DropdownMenuItem<String>(
                          value: b['course_name'] + " - " + b['batch_no'],
                          child: Text(b['course_name'] + " - " + b['batch_no']),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => selectedBatch = val),
                validator: (v) => v == null ? "Select Batch" : null,
              ),
              const SizedBox(height: 12),
              gradientDropdown(
                hint: "Select Course",
                value: selectedCourse,
                items: batches
                    .map((b) => DropdownMenuItem<String>(
                          value: b['course_name'],
                          child: Text(b['course_name']),
                        ))
                    .toSet()
                    .toList(),
                onChanged: (val) => setState(() => selectedCourse = val),
                validator: (v) => v == null ? "Select Course" : null,
              ),
              const SizedBox(height: 12),

              /// 🔹 Text Fields
              gradientTextField(
                controller: rollNoCtrl,
                hint: "Roll No",
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              gradientTextField(
                controller: nameCtrl,
                hint: "Name",
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              gradientTextField(
                controller: emailCtrl,
                hint: "Email",
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    v!.isEmpty ? "Required" : (!v.contains('@') ? "Invalid email" : null),
              ),
              const SizedBox(height: 12),
              gradientTextField(
                controller: passwordCtrl,
                hint: "Password",
                obscure: true,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              gradientTextField(
                controller: phoneCtrl,
                hint: "Phone",
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              gradientTextField(
                controller: streamCtrl,
                hint: "Stream",
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              gradientTextField(
                controller: classCtrl,
                hint: "Class",
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 25),

              /// 🔹 Submit Button
              loading
                  ? const CircularProgressIndicator()
                  : InkWell(
                      onTap: registerStudent,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: redGradient,
                        ),
                        child: const Center(
                          child: Text(
                            "Register Student",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
