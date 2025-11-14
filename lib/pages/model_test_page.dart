import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class ModelTestPage extends StatefulWidget {
  const ModelTestPage({super.key});

  @override
  State<ModelTestPage> createState() => _ModelTestPageState();
}

class _ModelTestPageState extends State<ModelTestPage> {
  String _status = 'Menunggu pengujian model...';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    setState(() {
      _isLoading = true;
      _status = 'Meload model...';
    });

    try {
      final interpreter = await Interpreter.fromAsset('assets/model_converted.tflite');

      // Ambil info input dan output
      final inputTensor = interpreter.getInputTensor(0);
      final outputTensor = interpreter.getOutputTensor(0);

      final inputShape = inputTensor.shape;
      final outputShape = outputTensor.shape;

      final inputType = inputTensor.type;
      final outputType = outputTensor.type;

      setState(() {
        _status = '''
  ✅ Model berhasil diload!

  🔹 Input Shape: $inputShape
  🔹 Input Type: $inputType

  🔸 Output Shape: $outputShape
  🔸 Output Type: $outputType
  ''';
      });

      interpreter.close();
    } catch (e) {
      setState(() {
        _status = '❌ Gagal meload model:\n$e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tes Model TFLite"),
        backgroundColor: Colors.green[700],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _isLoading
              ? const CircularProgressIndicator()
              : Text(
                  _status,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
        ),
      ),
    );
  }
}
