import 'dart:io';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

Float32List imageToByteListFloat32(img.Image image, int inputSize) {
  final Float32List float32List = Float32List(inputSize * inputSize * 3);
  int index = 0;

  for (int y = 0; y < inputSize; y++) {
    for (int x = 0; x < inputSize; x++) {
      // pixel di sini adalah objek Pixel dengan properti r,g,b
      final pixel = image.getPixel(x, y);

      // Akses langsung properti r, g, b
      float32List[index++] = (pixel.r / 127.5) - 1.0;
      float32List[index++] = (pixel.g / 127.5) - 1.0;
      float32List[index++] = (pixel.b / 127.5) - 1.0;
    }
  }

  return float32List;
}

void main() {
  final bytes = File('Penyimpanan internal/DCIM/Camera/20250803_110555.jpg').readAsBytesSync();
  final image = img.decodeImage(bytes)!;
  final resized = img.copyResize(image, width: 224, height: 224);

  final inputTensor = imageToByteListFloat32(resized, 224);

  print(inputTensor.sublist(0, 15));  // Contoh lihat nilai pixel yang sudah diproses
}
