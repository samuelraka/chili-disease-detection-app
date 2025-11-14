import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiseaseDetector {
  static late Interpreter _interpreterChili;
  static late Interpreter _interpreterDisease;
  static bool _isLoaded = false;
  static late List<String> _labelsChili;
  static late List<String> _labelsDisease;

  // Load model dan labels.txt
  static Future<void> loadModel() async {
    if (_isLoaded) return;

    final prefs = await SharedPreferences.getInstance();
    final modelPath = prefs.getString("model_path");
    final labelPath = prefs.getString("label_path");

    // === Load Model Deteksi Cabai (tidak berubah) ===
    _interpreterChili = await Interpreter.fromAsset('assets/models/chili_model.tflite');
    final rawLabelsChili = await rootBundle.loadString('assets/labels/chili.txt');
    _labelsChili = rawLabelsChili.split('\n').where((e) => e.trim().isNotEmpty).toList();

    // === Load Model Penyakit Cabai (dinamis: bisa dari assets atau file update) ===
    if (modelPath != null && File(modelPath).existsSync()) {
      _interpreterDisease = await Interpreter.fromFile(File(modelPath));
      print("🆕 Loaded updated model from $modelPath");
    } else {
      _interpreterDisease = await Interpreter.fromAsset('assets/models/final_model.tflite');
      print("ℹ️ Loaded default model from assets");
    }

    // === Load Label ===
    if (labelPath != null && File(labelPath).existsSync()) {
      final rawLabelsDisease = await File(labelPath).readAsString();
      print("🆕 Loaded updated label from $labelPath");
      _labelsDisease = rawLabelsDisease.split('\n').where((e) => e.trim().isNotEmpty).toList();
    } else {
      final rawLabelsDisease = await rootBundle.loadString('assets/labels/disease.txt');
      print("ℹ️ Loaded default label from assets");
      _labelsDisease = rawLabelsDisease.split('\n').where((e) => e.trim().isNotEmpty).toList();
    }

    print("✅ Model & labels loaded: Cabai - ${_labelsChili.length} classes, Penyakit - ${_labelsDisease.length} classes");
    _isLoaded = true;
  }


  /// Prediksi penyakit dari gambar
  static Future<Map<String, dynamic>> processImage(String imagePath, {double chiliThreshold = 0.8, double diseaseThreshold = 0.8}) async {
    if (!_isLoaded) throw Exception('Model belum dimuat');

    // baca & resize gambar
    img.Image image = img.decodeImage(File(imagePath).readAsBytesSync())!;
    img.Image resized = img.copyResize(image, width: 224, height: 224);

    // buat input tensor [1,224,224,3] float32 dengan nilai 0–255
    var input = _imageToByteListFloat32NHWC(resized, 224).reshape([1, 224, 224, 3]);

    //Prediksi Gambar Cabai
    var chiliOutput = List.filled(_labelsChili.length, 0.0).reshape([1, _labelsChili.length]);
    _interpreterChili.run(input,chiliOutput);

    List<double> chiliProbs = chiliOutput[0].cast<double>();
    int chiliPredictedIndex = chiliProbs.indexOf(chiliProbs.reduce(math.max));
    double chiliConfidence = chiliProbs[chiliPredictedIndex];
    String chiliPrediction = _labelsChili[chiliPredictedIndex].trim();

    print("📷 Gambar: ${File(imagePath).uri.path.split('/').last}");
    print("✅ Prediksi Deteksi Cabai: $chiliPrediction (Confidence: $chiliConfidence)");

    //Jika gambar bukan cabai, hentikan proses
    if(chiliPrediction == "Bukan Cabai" || chiliConfidence < chiliThreshold) {
      print("Gambar Bukan Cabai, Proses Dihentikan");
      return {'disease' : 'Bukan Cabai', 'confidence' : chiliConfidence};
    }

    //Jika gambar adalah cabai, lanjut deteksi penyakit
    print("Gambar adalah cabai lanjut ke proses pengecekkan penyakit...");

    // 🔍 Debug pixel pertama
    final p0 = resized.getPixel(0, 0);
    print("Pixel(0,0) raw: R=${p0.r}, G=${p0.g}, B=${p0.b}");
    print("Pixel(0,0) as float32: "
        "${input[0][0][0][0]}, ${input[0][0][0][1]}, ${input[0][0][0][2]}");

    // Prediksi Penyakit
    var diseaseOutput = List.filled(_labelsDisease.length, 0.0).reshape([1, _labelsDisease.length]);
    _interpreterDisease.run(input, diseaseOutput);

    print("Raw output (Flutter): ${diseaseOutput[0]}");

    // ambil hasil
    List<double> probs = diseaseOutput[0].cast<double>();
    int diseasePredictedIndex = probs.indexOf(probs.reduce(math.max));
    double maxProb = probs[diseasePredictedIndex];

    String disease = _labelsDisease[diseasePredictedIndex].trim();

    print("Predicted disease(raw): '${['disease']}'");

    // Jika confidence penyakit rendah, beri tahu pengguna
    if (maxProb < diseaseThreshold) {
      print("⚠️ Confidence untuk deteksi penyakit terlalu rendah ($maxProb), pertimbangkan untuk memeriksa gambar secara manual.");
    }

    return {
      'disease': disease,
      'confidence': maxProb,
      'all_probs': probs,
    };
  }

  /// Convert image ke Float32 NHWC [0..255]
  static Float32List _imageToByteListFloat32NHWC(img.Image image, int inputSize) {
    final Float32List float32List = Float32List(inputSize * inputSize * 3);
    int index = 0;

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = image.getPixel(x, y); // Pixel type
        float32List[index++] = pixel.r.toDouble();
        float32List[index++] = pixel.g.toDouble();
        float32List[index++] = pixel.b.toDouble();
      }
    }
    return float32List;
  }

  /// Gejala penyakit
  static List<String> getSymptoms(String disease) {
    if (disease.contains('Antraknosa')) {
      return ['Bercak cokelat', 'Kulit mengering', 'Bentuk buah abnormal'];
    } else if (disease.contains('Busuk')) {
      return ['Buah lembek', 'Berbau busuk', 'Kulit berwarna gelap'];
    } else {
      return ['Buah sehat', 'Tidak ada gejala'];
    }
  }

  /// Pencegahan penyakit
  static List<String> getPrevention(String disease) {
    if (disease.contains('Antraknosa')) {
        return ['Gunakan fungisida', 'Pangkas bagian terinfeksi', 'Rotasi tanaman'];
    }else if(disease.contains('Busuk')) {
        return ['Buang buah busuk', 'Jaga kelembapan', 'Sanitasi kebun'];
    }else {
        return ['Perawatan normal', 'Jaga kebersihan kebun'];
    } 
  }

  static String getDescription(String disease) {
    switch (disease) {
      case 'Antraknosa':
        return "Antraknosa pada cabai adalah penyakit yang disebabkan oleh jamur Colletotrichum spp.. Penyakit ini umumnya menyerang bagian buah, daun, dan batang cabai, terutama pada kondisi lingkungan yang lembap dan basah. Jamur ini berkembang biak melalui spora yang dapat terbawa angin atau air hujan, sehingga penyebarannya bisa cepat pada kebun yang padat tanaman dan kurang sirkulasi udara.";
      case 'Busuk':
        return "Busuk terjadi karena infeksi bakteri/fungi. Buah menjadi lembek dan berbau tidak sedap.";
      default:
        return "Buah dalam kondisi sehat.";
    }
  }
}

