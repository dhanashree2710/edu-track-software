import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';

class CreateBatchScreen extends StatefulWidget {
  const CreateBatchScreen({super.key});

  @override
  State<CreateBatchScreen> createState() => _CreateBatchScreenState();
}

class _CreateBatchScreenState extends State<CreateBatchScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController batchNoCtrl = TextEditingController();
  final TextEditingController collegeCtrl = TextEditingController();
  final TextEditingController streamCtrl = TextEditingController();
  final TextEditingController courseCtrl = TextEditingController();
  final TextEditingController locationCtrl = TextEditingController();
  final TextEditingController startDateCtrl = TextEditingController();
  final TextEditingController endDateCtrl = TextEditingController();

  bool loading = false;
  String? batchId;
  String? fixedQr;

  String? selectedTrainerId;
  String? selectedTrainerName;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> trainers = [];

  final LinearGradient redGradient =
      const LinearGradient(colors: [Color(0xff3f5efb), Color(0xfffc466b)]);

  @override
  void initState() {
    super.initState();
    fetchTrainers();
  }

  /// 🔹 Fetch trainers
  Future<void> fetchTrainers() async {
    final snap =
        await FirebaseFirestore.instance.collection('trainer').get();
    setState(() => trainers = snap.docs);
  }

  /// 🔹 Pick Date
  Future<void> pickDate(TextEditingController ctrl) async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      ctrl.text = DateFormat('yyyy-MM-dd').format(date);
    }
  }

  /// 🔹 CREATE BATCH + FIXED QR (ONCE)
  Future<void> createBatch() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedTrainerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a trainer")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final docRef =
          FirebaseFirestore.instance.collection('batches').doc();

      final qrValue = "${docRef.id}|${batchNoCtrl.text.trim()}";

      await docRef.set({
        'batch_id': docRef.id,
        'batch_no': batchNoCtrl.text.trim(),
        'college_name': collegeCtrl.text.trim(),
        'stream': streamCtrl.text.trim(),
        'course_name': courseCtrl.text.trim(),
        'location': locationCtrl.text.trim(),
        'trainer_id': selectedTrainerId,
        'trainer_name': selectedTrainerName,
        'start_date': startDateCtrl.text.trim(),
        'end_date': endDateCtrl.text.trim(),
        'fixed_qr': qrValue,
        'created_at': Timestamp.now(),
      });

      setState(() {
        loading = false;
        batchId = docRef.id;
        fixedQr = qrValue;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  /// 🔹 Gradient TextField
  Widget gradientField({
    required String hint,
    required TextEditingController controller,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: redGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
          hint: Text(hint),
          decoration: const InputDecoration(border: InputBorder.none),
          items: items,
          onChanged: onChanged,
          validator: validator,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
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


      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
               Center(
                 child: ShaderMask(
                  shaderCallback: (bounds) => redGradient.createShader(bounds),
                  child: const Text(
                    "Create Batch",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                               ),
               ),
              const SizedBox(height: 30),
              gradientField(
                hint: "Batch Number",
                controller: batchNoCtrl,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),

              gradientField(
                hint: "College / Institute Name",
                controller: collegeCtrl,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),

              gradientField(
                hint: "Stream",
                controller: streamCtrl,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),

              gradientField(
                hint: "Course Name",
                controller: courseCtrl,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),

              gradientField(
                hint: "Location",
                controller: locationCtrl,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),

              gradientDropdown(
                hint: "Select Trainer",
                value: selectedTrainerId,
                items: trainers.map((t) {
                  return DropdownMenuItem<String>(
                    value: t['trainer_id'],
                    child: Text(t['name']),
                  );
                }).toList(),
                onChanged: (v) {
                  final t = trainers.firstWhere((e) => e['trainer_id'] == v);
                  setState(() {
                    selectedTrainerId = v;
                    selectedTrainerName = t['name'];
                  });
                },
                validator: (v) => v == null ? "Select trainer" : null,
              ),
              const SizedBox(height: 12),

              gradientField(
                hint: "Start Date",
                controller: startDateCtrl,
                readOnly: true,
                onTap: () => pickDate(startDateCtrl),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),

              gradientField(
                hint: "End Date",
                controller: endDateCtrl,
                readOnly: true,
                onTap: () => pickDate(endDateCtrl),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 25),

              loading
                  ? const CircularProgressIndicator()
                  : InkWell(
                      onTap: createBatch,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: redGradient,
                        ),
                        child: const Center(
                          child: Text(
                            "Create Batch",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),

              const SizedBox(height: 30),

              if (fixedQr != null)
                Column(
                  children: [
                    const Text(
                      "Batch Attendance QR",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    QrImageView(
                      data: fixedQr!,
                      size: 220,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
