import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class BatchDetailsScreen extends StatefulWidget {
  final QueryDocumentSnapshot batchData;

  const BatchDetailsScreen({super.key, required this.batchData});

  @override
  State<BatchDetailsScreen> createState() => _BatchDetailsScreenState();
}

class _BatchDetailsScreenState extends State<BatchDetailsScreen> {
  final GlobalKey _cardKey = GlobalKey();
  late DateTime selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  /// 🔹 QR Data
  String get qrData {
    final date = DateFormat('yyyy-MM-dd').format(selectedDate);
    return "${widget.batchData['batch_id']}_$date";
  }

  /// 🔹 Fetch Trainer Name Safely
  Future<String> fetchTrainerName(String trainerId) async {
    final doc = await FirebaseFirestore.instance
        .collection('trainer')
        .doc(trainerId)
        .get();

    if (doc.exists && doc.data() != null) {
      return doc['name'] ?? 'N/A';
    }
    return 'N/A';
  }

  /// 🔹 Trainer Info Widget (CRASH SAFE)
  Widget trainerInfo(QueryDocumentSnapshot data) {
    final map = data.data() as Map<String, dynamic>;

    if (!map.containsKey('trainer_id') || map['trainer_id'] == null) {
      return _info("Trainer", "Not Assigned");
    }

    return FutureBuilder<String>(
      future: fetchTrainerName(map['trainer_id']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _info("Trainer", "Loading...");
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _info("Trainer", "Not Found");
        }
        return _info("Trainer", snapshot.data!);
      },
    );
  }

  /// 🔹 Share QR Card
  Future<void> shareCard() async {
    setState(() => _isLoading = true);

    try {
      RenderRepaintBoundary boundary =
          _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage(pixelRatio: 4);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final file = File(
          "${dir.path}/batch_${DateFormat('yyyyMMdd').format(selectedDate)}.png");

      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            "Batch QR Code\nCollege: ${widget.batchData['college_name']}\nCourse: ${widget.batchData['course_name']}\nDate: ${DateFormat('dd MMM yyyy').format(selectedDate)}",
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 🔹 Pick Date
  Future<void> pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.batchData;

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
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: RepaintBoundary(
              key: _cardKey,
              child: _buildCard(data),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black38,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  /// 🔹 Card UI
  Widget _buildCard(QueryDocumentSnapshot data) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    data['college_name'] ?? '',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                InkWell(
                  onTap: shareCard,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xff3f5efb), Color(0xfffc466b)],
                      ),
                    ),
                    child: const Icon(Icons.download, color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _info("Course", data['course_name']),
            _info("Stream", data['stream']),
            _info("Location", data['location']),
            _info("Start Date", data['start_date']),
            _info("End Date", data['end_date']),

            /// ✅ SAFE TRAINER INFO
            trainerInfo(data),

            const SizedBox(height: 20),

            /// QR Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Attendance QR",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: pickDate,
                  icon: const Icon(Icons.calendar_today),
                  label:
                      Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// QR Code
            Center(
              child: QrImageView(
                data: qrData,
                size: 220,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Info Row
  Widget _info(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$title: ",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
