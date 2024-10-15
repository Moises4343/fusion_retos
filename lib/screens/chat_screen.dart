import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

const apiKey = 'AIzaSyA0-2rXpHK9d9xuE5EOZ3nPgLuEdCKwf70';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _messages = [];
  late GenerativeModel _model;
  bool _isConnected = false;
  bool _isBotTyping = false;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
    );
    _loadMessages();
    _monitorConnectivity();
  }

  Future<void> _monitorConnectivity() async {
    _checkRealInternetConnection();

    Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        _checkRealInternetConnection();
      } else {
        _updateConnectionStatus(false);
      }
    });
  }

  Future<void> _checkRealInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _updateConnectionStatus(true);
      } else {
        _updateConnectionStatus(false);
      }
    } catch (_) {
      _updateConnectionStatus(false);
    }
  }

  void _updateConnectionStatus(bool status) {
    if (_isConnected != status) {
      setState(() {
        _isConnected = status;
      });
    }
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final storedMessages = prefs.getString('chat_history');

    if (storedMessages != null) {
      final decoded = jsonDecode(storedMessages) as List;
      setState(() {
        _messages = decoded.map((e) => Map<String, String>.from(e)).toList();
      });
    }
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chat_history', jsonEncode(_messages));
  }

  Future<void> _sendMessage(String message) async {
    _addMessage('user', message);
    _controller.clear();
    await _saveMessages();

    // Mostrar puntos suspensivos
    setState(() {
      _isBotTyping = true;
      _messages.add({'role': 'bot', 'content': '...'});
    });

    try {
      final response = await _model.generateContent([Content.text(message)]);
      final botResponse = response.text ?? 'Lo siento, no entendí eso.';

      // Reemplazar puntos suspensivos con la respuesta real
      setState(() {
        _isBotTyping = false;
        _messages.removeLast(); // Eliminar "..."
        _addMessage('bot', botResponse);
      });
    } catch (e) {
      setState(() {
        _isBotTyping = false;
        _messages.removeLast(); // Eliminar "..."
        _addMessage('bot', 'Hubo un error. Intenta nuevamente.');
      });
      print('Error: $e');
    }

    await _saveMessages();
  }

  void _addMessage(String role, String content) {
    setState(() {
      _messages.add({'role': role, 'content': content});
    });
  }

  Widget _buildMessage(Map<String, String> message) {
    final isUser = message['role'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[200] : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(message['content'] ?? ''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat con Gemini')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          if (_isBotTyping)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'El bot está escribiendo...',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: TextField(
                      controller: _controller,
                      enabled: _isConnected,
                      decoration: InputDecoration(
                        hintText: _isConnected
                            ? 'Escribe un mensaje...'
                            : 'Sin conexión',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: _isConnected ? Colors.blue : Colors.grey,
                  onPressed: _isConnected
                      ? () {
                          final message = _controller.text.trim();
                          if (message.isNotEmpty) {
                            _sendMessage(message);
                          }
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
