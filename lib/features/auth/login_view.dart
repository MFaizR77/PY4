import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/auth/login_controller.dart';
import 'package:logbook_app_001/features/logbook/log_view.dart';
import 'package:logbook_app_001/features/logbook/widgets/app_snackbar.dart';
import 'package:logbook_app_001/features/logbook/widgets/custom_text_field.dart';

import 'dart:async';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // Inisialisasi Otak dan Controller Input
  final LoginController _controller = LoginController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  bool _passwordVisible = true;

  int _loginAttempts = 0;
  bool _isButtonDisabled = false;
  Timer? _cooldownTimer;
  int _cooldownSeconds = 10;

  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void startTimer(){
    const onSec = const Duration(seconds: 1);
    _cooldownTimer = Timer.periodic(onSec, (timer) {
      if(_cooldownSeconds == 0){
        setState(() {
          timer.cancel();
        });
        timer.cancel();
      } else {
        setState(() {
          _cooldownSeconds--;
        });
      }
    });
  }

  void _startCooldown() {
    setState(() {
      _isButtonDisabled = true;
    });

    startTimer();

    _cooldownTimer = Timer(const Duration(seconds: 10), () {
      setState(() {
        _isButtonDisabled = false;
        _loginAttempts = 0;
      });
    });
  }

  @override
  void initState() {
    _passwordVisible = false;
  }

  void _handleLogin() {
    String user = _userController.text.trim();
    String pass = _passController.text.trim();

    bool isSuccess = _controller.login(user, pass);

    if (user.isEmpty || pass.isEmpty) {
      setState(() {
        _loginAttempts = 0;
        _isButtonDisabled = false;
      });

      showAppSnackbar(context, "Username dan Password tidak boleh kosong!", SnackbarType.error);
      return;
      
    } else {
      setState(() {
        _loginAttempts++;
      });

      if (_loginAttempts >= 3) {
        _startCooldown();
        showAppSnackbar(context, "Terlalu banyak percobaan! Coba lagi dalam 10 detik.", SnackbarType.error);
        return;
      } else if (!isSuccess) {
        int remainingAttempts = 3 - _loginAttempts;
        showAppSnackbar(context, "Login Gagal! Sisa percobaan: $remainingAttempts", SnackbarType.warning);
      }
    }

    if (isSuccess) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          // Di sini kita kirimkan variabel 'user' ke parameter 'username' di CounterView
          builder: (context) => LogView(username: user),
        ),
      );
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text("Login Gagal! Gunakan admin/123")),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login Gatekeeper")),
        body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Greeting Header
            Text(
              'Selamat datang!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Silakan login untuk melanjutkan',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 40),
            CustomTextField(
              controller: _userController,
              label: "Username",
              hint: "Contoh: admin, user, ilham",
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _passController,
              label: "Password",
              hint: "Contoh: 123",
              obscureText: !_passwordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Theme.of(context).primaryColorDark,
                ),
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isButtonDisabled ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: Colors.grey,
              ),
              child: Text(_isButtonDisabled ? "Terkunci (${_cooldownSeconds} detik)" : "Login"),
            ),
          ],
        ),
      ),
    );
  }
}
