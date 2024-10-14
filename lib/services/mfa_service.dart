import 'dart:convert';

import 'package:http/http.dart' as http;

class MFAService {
  //final String baseUrl = 'https://tareas-api-cm2v.onrender.com';
  final String baseUrl = 'http://127.0.0.1:3000';

  // Registro de usuario
  Future<void> registerUser(
      String username, String password, String phoneNumber) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
        'phone_number': phoneNumber,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al registrar el usuario');
    }
  }

  // Inicio de sesión: Valida usuario y contraseña y envía OTP
  Future<void> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al iniciar sesión');
    }
  }

  // Verificación del OTP
  Future<String> verifyOTP(String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'otp': otp}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['token'];
    } else {
      throw Exception('OTP inválido o expirado');
    }
  }
}
