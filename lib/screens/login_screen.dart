import 'package:flutter/material.dart';

import '../services/mfa_service.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final MFAService mfaService = MFAService();

  Future<void> login(BuildContext context) async {
    try {
      await mfaService.login(
        usernameController.text,
        passwordController.text,
      );
      Navigator.pushNamed(context, '/otp');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Usuario'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () => login(context),
              child: const Text('Iniciar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
