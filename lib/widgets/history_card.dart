import 'dart:io';
import 'package:flutter/material.dart';
import '../db/models/detection_record.dart';

class HistoryCard extends StatelessWidget {
  final List<DetectionRecord> recentHistory;

  const HistoryCard({super.key, required this.recentHistory});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "History Diagnosa Terakhir",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            recentHistory.isNotEmpty
                ? Column(
                    children: recentHistory.map((record) {
                      return ListTile(
                        leading: Image.file(
                          File(record.imagePath),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(record.disease),
                        subtitle: Text(record.date),
                      );
                    }).toList(),
                  )
                : const Text("Belum ada history diagnosa."),
          ],
        ),
      ),
    );
  }
}
