import 'package:flutter/material.dart';

import '../services/mfa_service.dart';

class OTPScreen extends StatelessWidget {
  final TextEditingController otpController = TextEditingController();
  final MFAService mfaService = MFAService();

  Future<void> verifyOTP(BuildContext context) async {
    try {
      String token = await mfaService.verifyOTP(otpController.text);
      print('JWT Token: $token');
      Navigator.pushNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verificación OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: otpController,
              decoration: const InputDecoration(labelText: 'Ingrese OTP'),
            ),
            ElevatedButton(
              onPressed: () => verifyOTP(context),
              child: const Text('Verificar OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
