import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:lottie/lottie.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        onPageChanged: (index) {
          setState(() => isLastPage = (index == 2));
        },
        children: [
          buildSlide(
            bgColor: Colors.redAccent.shade100,
            title: "Selamat Datang di Chili Care 🌶️",
            subtitle: "Deteksi penyakit cabai secara cepat dan akurat.",
            image: "assets/images/logo1.png",
          ),
          buildSlide(
            bgColor: Colors.deepOrange.shade100,
            title: "Deteksi Cepat 📷",
            subtitle: "Gunakan kamera atau galeri untuk memindai cabai.",
            lottie: "assets/animations/Take a photo.json",
          ),
          buildSlide(
            bgColor: Colors.green.shade100,
            title: "Saran Pengobatan 💡",
            subtitle: "Dapatkan rekomendasi perawatan sesuai hasil deteksi.",
            lottie: "assets/animations/plant.json",
          ),
        ],
      ),
      bottomSheet: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              child: const Text("Lewati"),
              onPressed: () {
                Navigator.pushReplacementNamed(context, "/home");
              },
            ),
            Row(
              children: [
                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: ExpandingDotsEffect(
                    activeDotColor: Colors.redAccent, // dot aktif merah
                    dotColor: Colors.red.shade100,    // dot non-aktif juga merah muda                    dotHeight: 10,
                    dotWidth: 10,
                    spacing: 8,
                  ),
                ),
                const SizedBox(width: 16),
                isLastPage
                    ? ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, "/input-nama");
                        },
                        child: const Text("Mulai"),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Icon(Icons.arrow_forward),
                      ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget buildSlide({
    required Color bgColor,
    required String title,
    required String subtitle,
    String? image, // boleh null
    String? lottie, // tambahkan ini
  }) {
    return Container(
      color: bgColor,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔹 kalau ada Lottie, tampilkan animasi
              if (lottie != null)
                Lottie.asset(
                  lottie,
                  height: MediaQuery.of(context).size.height * 0.25,
                  repeat: true,
                )
              // 🔹 kalau tidak ada Lottie, tampilkan image biasa
              else if (image != null)
                Image.asset(
                  image,
                  height: MediaQuery.of(context).size.height * 0.25,
                ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
