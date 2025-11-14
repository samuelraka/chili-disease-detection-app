import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../db/db_helper.dart';
import '../db/models/detection_record.dart';
import '../widgets/get_started_card.dart';
import '../widgets/how_to_use_card.dart';
import '../widgets/history_card.dart';
import '../widgets/custom_bottom_navbar.dart';
import '../widgets/update_dialog.dart';

class HomePage extends StatefulWidget {
  final Function(int) onTabChange;

  const HomePage({super.key, required this.onTabChange});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String currentVersion = "1.0.0";
  String latestVersion ="";
  List<DetectionRecord> recentHistory = [];
  String username = "User";

  @override
  void initState() {
    super.initState();
    fetchRecentHistory();
    loadUsername();
    _checkForModelUpdate();
  }

  // Ambil 3 record terbaru
  Future<void> fetchRecentHistory() async {
    final recent = await DBHelper.getRecentRecords(limit: 3);
    setState(() {
      recentHistory = recent;
    });
  }

  Future<void> loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'User';
    });
  }

  Future<void> _checkForModelUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    currentVersion = prefs.getString("model_version") ?? "1.0.0";

    final response = await http.get(Uri.parse(
      "https://api.github.com/repos/samuelraka/chili-disease-detection-model/releases/latest"
    ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      latestVersion = data["tag_name"];

      final assets = data["assets"] as List;
      final modelAsset = assets.firstWhere((a) => a["name"].contains(".tftlite"));
      final labelAsset = assets.firstWhere((a) => a["name"].contains(".txt"));

      final modelUrl = modelAsset["browser_download_url"];
      final labelUrl = labelAsset["browser_download_url"];

      if (latestVersion != currentVersion) {
        _showUpdateDialog(latestVersion, modelUrl, labelUrl);
      }
    } else {
      print("Gagal cek update: ${response.statusCode}");
    }
  }

  void _showUpdateDialog(String newVersion, String modelUrl, labelUrl) {
    showDialog(
      context: context,
      builder: (_) => UpdateDialog(
        currentVersion: currentVersion,
        latestVersion: newVersion,
        onUpdate: () {
          _downloadModelAndLabels(modelUrl, labelUrl, newVersion);
        },
      ),
    );
  }

  Future<void> _downloadModelAndLabels(String modelUrl, String labelUrl, String newVersion) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false, 
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      final dir = await getApplicationDocumentsDirectory();
      final modelPath = '${dir.path}/final_model.tflite';
      final labelPath = '${dir.path}/disease.txt';

      //Download Model
      final modelResponse = await http.get(Uri.parse(modelUrl));
      if (modelResponse.statusCode == 200) {
        await File(modelPath).writeAsBytes(modelResponse.bodyBytes);
      } else {
        throw Exception("Gagal unduh Model");
      }

      //Download Labels
      final labelResponse = await http.get(Uri.parse(labelUrl));
      if (labelResponse.statusCode == 200) {
        await File(labelPath).writeAsBytes(labelResponse.bodyBytes);
      } else {
        throw Exception("Gagal Unduh Label");
      }

      //Simpan versi & path  
      final prefs =await SharedPreferences.getInstance();
      await prefs.setString("model_version", newVersion);
      await prefs.setString("model_path", modelPath);
      await prefs.setString("label_path", labelPath);

      Navigator.pop(context);

      showDialog(
        context: context, 
        builder: (_) => AlertDialog(
          title: const Text("Update Berhasil"),
          content: Text("Model dan Label versi $newVersion telah diunduh"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      print("Error Ketika Sedang Mendownload Versi Terbaru: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              "assets/images/logo1.png",
              height: 36,
            ),
            const SizedBox(width: 10),
            Text(
              "Selamat Datang, $username",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GetStartedCard(
              onStart: () {
                widget.onTabChange(1);
              },
            ),
            const SizedBox(height: 16),
            const HowToUseCard(),
            const SizedBox(height: 16),
            HistoryCard(recentHistory: recentHistory),
          ],
        ),
      ),
    );
  }
}
