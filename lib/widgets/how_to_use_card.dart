import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HowToUseCard extends StatefulWidget {
  const HowToUseCard({super.key});

  @override
  State<HowToUseCard> createState() => _HowToUseCardState();
}

class _HowToUseCardState extends State<HowToUseCard> {
  bool showAll = false;

  Widget buildStep({
    required int stepNumber,
    required String text,
    Widget? icon,
    bool highlight = false,
    bool advanceMargin = false,
  }) {
    return Container(
      margin: EdgeInsets.only(left: advanceMargin ? 40 : 0, bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: highlight ? Colors.redAccent : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(50),
            ),
            alignment: Alignment.center,
            child: Text(
              "$stepNumber",
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          if (icon != null) SizedBox(width: 50, height: 50, child: icon),
          if (icon != null) const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "How to Use",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            buildStep(
              stepNumber: 1,
              text: "Ambil foto cabai menggunakan kamera atau pilih dari galeri.",
              icon: Image.asset("assets/images/take-a-photo.png"),
            ),
            if (showAll)
              buildStep(
                stepNumber: 2,
                text: "Tunggu hasil prediksi dari model.",
                icon: Lottie.asset(
                  'assets/animations/Image Scanning.json',
                  fit: BoxFit.contain,
                ),
                highlight: true,
                advanceMargin: true,
              ),
            if (showAll)
              buildStep(
                stepNumber: 3,
                text: "Lihat saran pengobatan berdasarkan hasil diagnosa.",
                icon: Image.asset("assets/images/medical-result.png"),
              ),
            TextButton(
              onPressed: () {
                setState(() {
                  showAll = !showAll;
                });
              },
              child: Text(
                showAll ? "Sembunyikan Langkah" : "Lihat Semua Langkah",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
