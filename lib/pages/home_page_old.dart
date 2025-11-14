// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import '../utils/disease_detector.dart';
// import '../db/db_helper.dart';
// import '../db/models/detection_record.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   File? _image;
//   Map<String, dynamic>? _diseaseResult;
//   final picker = ImagePicker();

//   @override
//   void initState() {
//     super.initState();
//     _loadModel();
//   }

//   Future<void> _loadModel() async {
//     try {
//       await DiseaseDetector.loadModel();
//       debugPrint("Model berhasil dimuat.");
//     } catch (e) {
//       debugPrint("Gagal memuat model: $e");
//     }
//   }

//   Future<void> _pickImage() async {
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       final result = DiseaseDetector.detectDisease(pickedFile.path);
//       setState(() {
//         _image = File(pickedFile.path);
//         _diseaseResult = result;
//       });
//       await _storeDetectionResult();
//     }
//   }

//   Future<void> _takePicture() async {
//     final pickedFile = await picker.pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       final result =  DiseaseDetector.detectDisease(pickedFile.path);
//       setState(() {
//         _image = File(pickedFile.path);
//         _diseaseResult = result;
//       });
//       await _storeDetectionResult();
//     }
//   }

//   Future<void> _storeDetectionResult() async {
//     if (_image == null || _diseaseResult == null) return;

//     try {
//       final record = DetectionRecord(
//         imagePath: _image!.path,
//         disease: _diseaseResult!['disease'],
//         confidence: _diseaseResult!['confidence'],
//         date: DateTime.now().toIso8601String(),
//         symptoms: List<String>.from(_diseaseResult!['symptoms']),
//         prevention: List<String>.from(_diseaseResult!['prevention']),
//       );

//       await DBHelper.insertRecord(record);
//     } catch (e) {
//       print('Error storing detection result: $e');
//     }
//   }

//   Future<void> _simulateDetection() async {
//     final record = DetectionRecord(
//       imagePath: 'path/to/fake_image.jpg',
//       disease: 'Antraknosa',
//       confidence: 0.92,
//       date: DateTime.now().toIso8601String(),
//       symptoms: ['Bercak cokelat', 'Kulit mengering', 'Bentuk buah abnormal'],
//       prevention: ['Gunakan fungisida', 'Pangkas bagian terinfeksi', 'Rotasi tanaman'],
//     );

//     await DBHelper.insertRecord(record);

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Simulasi deteksi berhasil disimpan")),
//     );
//   }

//   void _showAppInfo() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Tentang Aplikasi'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: const [
//             Text('Aplikasi Deteksi Penyakit Cabai'),
//             SizedBox(height: 8),
//             Text('Versi: 1.0.0'),
//             SizedBox(height: 16),
//             Text('Gunakan aplikasi secara offline.'),
//             Text('Hanya koneksi internet untuk cek update model.'),
//             SizedBox(height: 16),
//             Text('© 2025'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Tutup'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Deteksi Penyakit Cabai"),
//         backgroundColor: Colors.green[700],
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.history),
//             onPressed: () => Navigator.pushNamed(context, '/history'),
//           ),
//           IconButton(
//             icon: const Icon(Icons.info_outline),
//             onPressed: _showAppInfo,
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: _takePicture,
//                     icon: const Icon(Icons.camera_alt),
//                     label: const Text("Ambil Foto"),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green[700],
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: _pickImage,
//                     icon: const Icon(Icons.photo_library),
//                     label: const Text("Pilih dari Galeri"),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green[700],
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton.icon(
//               onPressed: _simulateDetection,
//               icon: const Icon(Icons.bug_report),
//               label: const Text("Simulasi Data"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.orange[700],
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//               ),
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton.icon(
//               onPressed: () {
//                 Navigator.pushNamed(context, '/model-test');
//               },
//               icon: const Icon(Icons.model_training),
//               label: const Text("Tes Model TFLite"),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blueGrey,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//               ),
//             ),
//             const SizedBox(height: 20),
//             if (_image != null) _buildDetectionCard(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDetectionCard() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ClipRRect(
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
//             child: Image.file(_image!, height: 200, width: double.infinity, fit: BoxFit.cover),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: _diseaseResult != null
//                 ? Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("Penyakit: ${_diseaseResult!['disease']}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                       Text("Kemungkinan: ${(_diseaseResult!['confidence'] * 100).toStringAsFixed(1)}%", style: const TextStyle(fontSize: 14)),
//                       Text("Tanggal: ${DateTime.now().toString().split(' ')[0]}", style: const TextStyle(fontSize: 14)),
//                     ],
//                   )
//                 : const Center(child: CircularProgressIndicator()),
//           ),
//         ],
//       ),
//     );
//   }
// }
