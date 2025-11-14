import 'package:flutter/material.dart';

class UpdateDialog extends StatelessWidget {
  final String currentVersion;
  final String latestVersion;
  final VoidCallback onUpdate;

  const UpdateDialog({
    Key? key,
    required this.currentVersion,
    required this.latestVersion,
    required this.onUpdate,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Update Model Tersedia"),
      content: Text(
        "Model Saat ini: $currentVersion\n"
        "Model Terbaru: $latestVersion\n\n"
        "Apakah Anda Ingin Update Sekarang?",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), 
          child: const Text("Nanti"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onUpdate();
          }, 
          child: const Text("Update"),
        ),
      ],
    );
  }
}