import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../db/models/detection_record.dart';
import '../utils/disease_detector.dart';

class ResultPage extends StatefulWidget {
  final DetectionRecord record;

  const ResultPage({super.key, required this.record});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final description = DiseaseDetector.getDescription(widget.record.disease);
    final formattedDate = DateFormat('EEEE, dd MMMM yyyy – HH:mm').format(DateTime.now());

    // Tentukan lebar maksimum card = lebar layar - padding
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - 32; // padding horizontal 16 + 16

    // Tentukan layout berdasarkan penyakit
    bool isHealthy = widget.record.disease == "Bukan Cabai"; // Tentukan jika normal (misalnya tidak ada penyakit)

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Hasil Diagnosa",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Tanggal diagnosa
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 12),

              // Gambar hasil prediksi
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(widget.record.imagePath),
                  width: cardWidth,
                  height: cardWidth * 0.75, // aspect ratio 4:3
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),

              // Card: Nama penyakit + confidence + expandable deskripsi
              SizedBox(
                width: cardWidth,
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          widget.record.disease,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        CircularPercentIndicator(
                          radius: 60,
                          lineWidth: 8,
                          percent: widget.record.confidence,
                          center: Text(
                              "${(widget.record.confidence * 100).toStringAsFixed(0)}%"),
                          progressColor: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        AnimatedCrossFade(
                          firstChild: isHealthy
                              ? Text(
                                  "Tidak ada penyakit pada cabai. Gambar yang Anda ambil menunjukkan cabai yang sehat.",
                                  style: const TextStyle(fontSize: 14, height: 1.4),
                                )
                              : Text(
                                  description,
                                  style: const TextStyle(fontSize: 14, height: 1.4),
                                ),
                          secondChild: Text(
                            description,
                            style: const TextStyle(fontSize: 14, height: 1.4),
                          ),
                          crossFadeState: _isExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 300),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                          child: Text(_isExpanded ? "Baca lebih sedikit" : "Baca selengkapnya"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Card: Gejala
              SizedBox(
                width: cardWidth,
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Gejala",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        if (!isHealthy) // Tampilkan gejala hanya jika ada penyakit
                          ...widget.record.symptoms.map((s) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text("🔍 $s", style: const TextStyle(fontSize: 14)),
                          )),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Card: Pencegahan
              SizedBox(
                width: cardWidth,
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Pencegahan",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        if (!isHealthy) // Tampilkan pencegahan hanya jika ada penyakit
                          ...widget.record.prevention.map((p) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text("✅ $p", style: const TextStyle(fontSize: 14)),
                          )),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 80), // space for FloatingActionButton
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, "/camera");
        },
        icon: const Icon(Icons.camera_alt),
        label: const Text("Ambil Foto Ulang"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

}
