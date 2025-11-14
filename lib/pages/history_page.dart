import 'dart:io';
import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../db/models/detection_record.dart';
import 'history_detail_page.dart'; // halaman detail

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<DetectionRecord> records = [];

  @override
  void initState() {
    super.initState();
    fetchRecords();
  }

  Future<void> fetchRecords() async {
    final allRecords = await DBHelper.getAllRecords();
    setState(() {
      records = allRecords;
    });
  }

  Future<void> deleteRecord(int index) async {
    final record = records[index];

    // Pastikan id tidak null
    if (record.id != null) {
      await DBHelper.deleteRecord(record.id!); // Menghapus dari database
      fetchRecords(); // Memperbarui daftar setelah dihapus
    } else {
      // Jika id null, tampilkan pesan error atau tidak lakukan apa-apa
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID riwayat tidak valid')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History Diagnosa"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: records.isEmpty
          ? const Center(child: Text("Belum ada history diagnosa."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return GestureDetector(
                  onTap: () {
                    // Buka detail
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HistoryDetailPage(record: record),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Thumbnail gambar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(record.imagePath),
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Nama penyakit + tanggal
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  record.disease,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  record.date,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),

                          // Circle progress untuk confidence
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: record.confidence,
                                  strokeWidth: 4,
                                  color: Colors.red,
                                  backgroundColor: Colors.grey[300],
                                ),
                                Text(
                                  "${(record.confidence * 100).toStringAsFixed(0)}%",
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),

                          // Tombol Hapus
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              // Dialog konfirmasi hapus
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Konfirmasi Hapus'),
                                    content: const Text(
                                        'Apakah Anda yakin ingin menghapus riwayat ini?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Batal'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('Hapus'),
                                        onPressed: () {
                                          if (record.id != null) {
                                            deleteRecord(records.indexOf(record)); // Pastikan record.id tidak null
                                            Navigator.of(context).pop();
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('ID riwayat tidak valid')),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
