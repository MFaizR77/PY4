import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/auth/login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  int step = 1; 

  void _nextStep() {
    setState(() {
      step++;
      if (step == 3) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginView()),
        );
      }
    });
  }

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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 50),
              Text(
                '$step',
                style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: _nextStep,
                child: const Text('Lanjut'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
