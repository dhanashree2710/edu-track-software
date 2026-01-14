import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutrack_application/modules/Login/presentation/widgets/biometric_auth.dart';
import 'package:edutrack_application/modules/Student/presentation/views/student_dashboard.dart';
import 'package:edutrack_application/utils/common/pop_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({super.key});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  bool scanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Batch QR")),
      body: MobileScanner(
        onDetect: (barcodeCapture) async {
          if (scanned) return;

          final qrValue = barcodeCapture.barcodes.first.rawValue;
          if (qrValue == null || qrValue.isEmpty) return;

          scanned = true;
          debugPrint("✅ QR SCANNED: $qrValue");

          try {
            /// ✅ EXPECTED FORMAT
            /// batchId_yyyy-MM-dd
            if (!qrValue.contains('_')) {
              _show("❌ Invalid QR format");
              scanned = false;
              return;
            }

            final parts = qrValue.split('_');
            final batchId = parts[0];
            final qrDate = parts[1];

            final today =
                DateTime.now().toIso8601String().substring(0, 10);

            /// ❌ EXPIRED QR
            if (qrDate != today) {
              _show("❌ QR expired");
              scanned = false;
              return;
            }

            /// 🔍 FETCH BATCH DIRECTLY BY ID
            final batchRef = FirebaseFirestore.instance
                .collection('batches')
                .doc(batchId);

            final batchSnap = await batchRef.get();

            if (!batchSnap.exists) {
              _show("❌ Batch not found");
              scanned = false;
              return;
            }

            /// 🔍 VERIFY DAILY QR EXISTS
            final dailyQrSnap = await batchRef
                .collection('daily_qr')
                .doc(qrDate)
                .get();

            if (!dailyQrSnap.exists) {
              _show("❌ Attendance QR not active");
              scanned = false;
              return;
            }

            /// 🚀 NAVIGATE
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => BatchAttendanceScreen(
                  batchId: batchId,
                  batchData: batchSnap.data()!,
                ),
              ),
            );
          } catch (e) {
            scanned = false;
            _show("❌ Error: $e");
          }
        },
      ),
    );
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}


class BatchAttendanceScreen extends StatefulWidget {
  final String batchId;
  final Map<String, dynamic> batchData;

  const BatchAttendanceScreen({
    super.key,
    required this.batchId,
    required this.batchData,
  });

  @override
  State<BatchAttendanceScreen> createState() => _BatchAttendanceScreenState();
}

class _BatchAttendanceScreenState extends State<BatchAttendanceScreen> {
  final TextEditingController rollCtrl = TextEditingController();
  bool loading = false;

 final LinearGradient redGradient =
      const LinearGradient(colors: [Color(0xff3f5efb), Color(0xfffc466b)]);

 Future<void> markAttendance() async {
  if (rollCtrl.text.trim().isEmpty) return;

  setState(() => loading = true);

  /// 🔐 BIOMETRIC
  final ok = await BiometricService().authenticate();
  if (!ok) {
    setState(() => loading = false);
    return;
  }

  final today = DateTime.now().toIso8601String().substring(0, 10);
  final studentId = rollCtrl.text.trim();

  final query = await FirebaseFirestore.instance
      .collection('attendance')
      .where('student_id', isEqualTo: studentId)
      .where('batch_id', isEqualTo: widget.batchId)
      .where('date', isEqualTo: today)
      .limit(1)
      .get();

  /// 🟢 CHECK-IN
  if (query.docs.isEmpty) {
    await FirebaseFirestore.instance.collection('attendance').add({
      'student_id': studentId,
      'batch_id': widget.batchId,
      'date': today,
      'in_time': Timestamp.now(),
      'out_time': null,
      'verified_by': 'QR + Fingerprint',
    });

   showCustomAlert(
      context,
      isSuccess: true,
      title: "Success",
      description: "Successfully Check In!",
      nextScreen: StudentDashboard(), // You can navigate to another screen if needed
    );

    
  }

  /// 🟡 CHECK-OUT
  else {
    final doc = query.docs.first;

    if (doc['out_time'] != null) {
      showCustomAlert(
      context,
      isSuccess: false,
      title: "Failed",
      description: "Attendance already completed",
      nextScreen: StudentDashboard(), // You can navigate to another screen if needed
    );
     
    } else {
      await doc.reference.update({
        'out_time': Timestamp.now(),
      });

     showCustomAlert(
      context,
      isSuccess: true,
      title: "Success",
      description: "Successfully Check Out!",
      nextScreen: StudentDashboard(), // You can navigate to another screen if needed
    );

    }
  }

  setState(() => loading = false);
}


  @override
  Widget build(BuildContext context) {
    final b = widget.batchData;

    return  Scaffold(
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
             Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) => redGradient.createShader(bounds),
                      child: const Text(
                        "Mark Attendence",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // overridden by ShaderMask
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
            /// 📦 BATCH CARD
         Container(
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xff3f5efb), Color(0xfffc466b)],
    ),
    borderRadius: BorderRadius.circular(14),
  ),
  padding: const EdgeInsets.all(1.5), // outline thickness
  child: Card(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${b['course_name']} - ${b['batch_no']}",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text("College: ${b['college_name']}"),
          Text("Location: ${b['location']}"),
          Text("Trainer: ${b['trainer_name']}"),
        ],
      ),
    ),
  ),
),

            const SizedBox(height: 30),

            /// 🧑‍🎓 INPUT
          Container(
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xff3f5efb), Color(0xfffc466b)],
    ),
    borderRadius: BorderRadius.circular(12),
  ),
  padding: const EdgeInsets.all(1.5), // border thickness
  child: TextField(
    controller: rollCtrl,
    decoration: InputDecoration(
      hintText: "Student Roll No / ID",
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    ),
  ),
),


            const SizedBox(height: 20),

            /// ✅ BUTTON
           SizedBox(
  width: double.infinity,
  height: 50,
  child: DecoratedBox(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xff3f5efb), Color(0xfffc466b)],
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: ElevatedButton(
      onPressed: loading ? null : markAttendance,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: loading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
          : const Text(
              "Mark Attendance",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
    ),
  ),
),

          ],
        ),
      ),
    );
  }
}
