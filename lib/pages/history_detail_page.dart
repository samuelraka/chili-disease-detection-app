import 'dart:io';
import 'package:chili_disease_app/utils/disease_detector.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/models/detection_record.dart';
import 'package:expandable/expandable.dart';

class HistoryDetailPage extends StatelessWidget {
  final DetectionRecord record;

  const HistoryDetailPage({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    // Tanggal & jam diagnosa
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, dd MMMM yyyy – HH:mm').format(now);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Detail Diagnosa",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tanggal
            Text(
              formattedDate,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            // Foto hasil prediksi
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(record.imagePath),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            // Gunakan LayoutBuilder agar card menyesuaikan lebar gambar
            LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    // Card: Nama penyakit + confidence
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      child: Container(
                        width: constraints.maxWidth, // sama dengan lebar gambar
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                record.disease,
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: CircularProgressIndicator(
                                value: record.confidence,
                                strokeWidth: 8,
                                color: Colors.red,
                                backgroundColor: Colors.grey[300],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                "${(record.confidence * 100).toStringAsFixed(0)}%",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Bagian informasi penyakit (expandable)
                            ExpandablePanel(
                              header: const Text(
                                "Informasi Penyakit",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              collapsed: const Text(
                                "Tap untuk melihat informasi lengkap",
                                style: TextStyle(color: Colors.grey),
                              ),
                              expanded:  Text(
                                DiseaseDetector.getDescription(record.disease),
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card Gejala
                    Card(
                      shape:
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      child: Container(
                        width: constraints.maxWidth, // sama dengan lebar gambar
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Gejala",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...record.symptoms.map((s) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Text("🔍 $s",
                                      style: const TextStyle(fontSize: 14)),
                                )),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Card Pencegahan / Penanganan
                    Card(
                      shape:
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      child: Container(
                        width: constraints.maxWidth, // sama dengan lebar gambar
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Pencegahan / Penanganan",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...record.prevention.map((p) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Text("✅ $p",
                                      style: const TextStyle(fontSize: 14)),
                                )),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
