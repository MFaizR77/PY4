import 'package:flutter/material.dart';
// Import Controller milik sendiri (masih satu folder)
import 'package:logbook_app_001/features/auth/login_controller.dart';
import 'package:logbook_app_001/features/logbook/counter_controller.dart';
// Import View dari fitur lain (Logbook) untuk navigasi
import 'package:logbook_app_001/features/logbook/counter_view.dart';

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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Username dan Password tidak boleh kosong!"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
      
    } else {
      setState(() {
        _loginAttempts++;
      });

      if (_loginAttempts >= 3) {
        _startCooldown();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Terlalu banyak percobaan! Coba lagi dalam 10 detik.",
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      } else if (!isSuccess) {
        int remainingAttempts = 3 - _loginAttempts;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login Gagal! Sisa percobaan: $remainingAttempts"),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }

    if (isSuccess) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          // Di sini kita kirimkan variabel 'user' ke parameter 'username' di CounterView
          builder: (context) => CounterView(username: user),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _userController,
              decoration: const InputDecoration(
                labelText: "Username",
                hintText: "Contoh: admin, user, ilham",
              ),
            ),
            TextField(
              controller: _passController,
              obscureText: !_passwordVisible,
              decoration: InputDecoration(
                labelText: "Password",
                hintText: "Contoh: 123",
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
