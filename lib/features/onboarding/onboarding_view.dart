import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/auth/login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class OnboardingData {
  final String image;
  final String title;
  final String description;

  OnboardingData({
    required this.image,
    required this.title,
    required this.description,
  });
}

class _OnboardingViewState extends State<OnboardingView> {
  int step = 1;
  int currentIndex = 0;

  final List<OnboardingData> onboardingList = [
    OnboardingData(
      image: 'assets/image/Autentikasi2.jpg',
      title: 'Autentikasi Aman',
      description: 'Login dengan sistem keamanan terbaik. Autentikasi terbaik.',
    ),
    OnboardingData( 
      image: 'assets/image/Navigasi2.jpg',
      title: 'Navigasi Mudah',
      description:
          'Berpindah antar halaman dengan lancar. Pengalaman yang amazing',
    ),
    OnboardingData(
      image: 'assets/image/DataPersistance.png',
      title: 'Data Tersimpan',
      description:
          'Riwayat aktivitas Anda tersimpan otomatis. Tidak akan hilang meskipun aplikasi ditutup',
    ),
  ];

  void _nextStep() {
    if (currentIndex < onboardingList.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
    }
  }

  OnboardingData get currentData => onboardingList[currentIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Halaman Onboarding',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50),

              AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: Text(
                  currentData.title,
                  key: ValueKey(currentData.title),
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 20),

              AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: Image.asset(
                  currentData.image,
                  key: ValueKey(currentData.image),
                  width: 200,
                  height: 200,
                ),
              ),

              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: Text(
                  currentData.description,
                  key: ValueKey(currentData.description),
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 50),
              ElevatedButton(onPressed: _nextStep, child: const Text('Lanjut')),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  onboardingList.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: index == currentIndex ? 16 : 9,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: currentIndex == index
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
