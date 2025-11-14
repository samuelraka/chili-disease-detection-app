import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // DIUBAH: untuk tanggal
import '../db/models/detection_record.dart'; // DIUBAH: import model
import '../utils/disease_detector.dart'; // DIUBAH: import TFLite helper
import 'result_page.dart'; // DIUBAH: import ResultPage
import '../db/db_helper.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraReady = false;
  final ImagePicker _picker = ImagePicker();

  bool _showWarning = true;

  @override
  void initState() {
    super.initState();
    _init();

    // DIUBAH: load model saat aplikasi dijalankan
    DiseaseDetector.loadModel().then((_) {
      debugPrint('✅ Model otomatis dimuat saat pemanggilan pertama');
      // debugPrint('Input shape: ${DiseaseDetector.inputShape}');
      // debugPrint('Output shape: ${DiseaseDetector.outputShape}');
    });
  }

  Future <void> _init() async {
    await DiseaseDetector.loadModel();
    debugPrint("Load Model Berhasil");
    await initializeCamera();
  }

  Future<void> initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras!.isNotEmpty) {
      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {
        _isCameraReady = true;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final XFile file = await _controller!.takePicture();
      await _predictAndNavigate(File(file.path)); // DIUBAH: jalankan prediksi
    } catch (e) {
      debugPrint("Error taking picture: $e");
    }
  }

  Future<void> pickFromGallery() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      await _predictAndNavigate(File(file.path)); // DIUBAH: jalankan prediksi
    }
  }

  Future<void> _predictAndNavigate(File file) async {
    try {
      final result = await DiseaseDetector.processImage(file.path); // pakai await

      final now = DateTime.now();
      final formattedDate =
          DateFormat('EEEE, dd MMMM yyyy – HH:mm').format(now);

      String predictedDisease = result['disease'] ?? 'Unknown';

      // Cek apakah ini cabai atau bukan
      if (predictedDisease == 'Bukan Cabai') {
        setState(() {
          _showWarning = true; // Menampilkan peringatan
        });

        // Menampilkan pesan peringatan
        showDialog(
          context: context,
          barrierDismissible: false, // Menghindari penutupan dialog dengan tap di luar
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Peringatan'),
              content: const Text('Gambar ini bukan cabai! Mohon pastikan Anda mengambil gambar cabai yang jelas dan sesuai.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Ulangi Foto'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Menutup dialog
                  },
                ),
                TextButton(
                  child: const Text('Batal'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Menutup dialog
                    Navigator.pop(context); // Kembali ke halaman sebelumnya
                  },
                ),
              ],
            );
          },
        );
        return; // Menghentikan eksekusi jika bukan cabai
      }

      // Jika ini cabai, lanjutkan deteksi penyakit
      DetectionRecord record = DetectionRecord(
        imagePath: file.path,
        disease: predictedDisease,
        confidence: result['confidence'] ?? 0.0,
        date: formattedDate,
        symptoms: DiseaseDetector.getSymptoms(predictedDisease),
        prevention: DiseaseDetector.getPrevention(predictedDisease),
      );

      // Simpan ke database lokal
      await DBHelper.insertRecord(record);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(record: record),
        ),
      );
    } catch (e, st) {
        debugPrint('Error saat prediksi: $e');
        debugPrint('Stack trace: $st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal melakukan prediksi.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // transparan supaya kamera tetap fullscreen
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // kembali ke HomePage
          },
        ),
      ),
      extendBodyBehindAppBar: true, // biar AppBar overlay di atas camera preview
      body: _isCameraReady && _controller != null
          ? Stack(
              children: [
                // Camera preview fullscreen
                Positioned.fill(
                  child: CameraPreview(_controller!),
                ),

                //Box Warning
                if(_showWarning)
                  Positioned(
                    top: 40,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.yellow[700]?.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "⚠️ Ambil foto dengan gambar jelas dan pencahayaan cukup untuk hasil terbaik.",
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showWarning = false;
                              });
                            },
                            child: const Icon(Icons.close, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Tombol galeri kiri bawah
                Positioned(
                  bottom: 40,
                  left: 30,
                  child: GestureDetector(
                    onTap: pickFromGallery,
                    child: const Icon(Icons.photo, size: 40, color: Colors.white),
                  ),
                ),

                // Tombol shutter tengah bawah
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: takePicture,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
