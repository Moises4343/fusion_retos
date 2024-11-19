import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

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

  late SpeechToText _speech;
  bool _isListening = false;
  late FlutterTts _flutterTts;

  final ScrollController _scrollController = ScrollController();

  bool _isTextNotEmpty = false;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
    );
    _loadMessages();
    _monitorConnectivity();

    _speech = SpeechToText();
    _flutterTts = FlutterTts();
    _initializeTts();

    _controller.addListener(_onTextChanged);
  }

  void _initializeTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
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
      _updateConnectionStatus(
          result.isNotEmpty && result[0].rawAddress.isNotEmpty);
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

    setState(() {
      _isBotTyping = true;
      _isTextNotEmpty = false;
    });

    try {
      final context = _getLimitedContext(5);

      final response = await _model.generateContent([Content.text(context)]);
      final botResponse =
          response.text ?? "I'm sorry, I didn't understand that.";

      setState(() {
        _isBotTyping = false;
        _addMessage('bot', botResponse);
      });

      await _flutterTts.speak(botResponse);
    } catch (e) {
      setState(() {
        _isBotTyping = false;
        _addMessage('bot', 'There was an error. Please try again.');
      });
      print('Error: $e');
    }

    await _saveMessages();
  }

  String _getLimitedContext(int limit) {
    final start = _messages.length > limit ? _messages.length - limit : 0;
    final recentMessages = _messages.sublist(start);

    return recentMessages
        .map((msg) => "${msg['role']}: ${msg['content']}")
        .join('\n');
  }

  void _addMessage(String role, String content) {
    setState(() {
      _messages.add({'role': role, 'content': content});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessage(Map<String, String> message) {
    final isUser = message['role'] == 'user';
    return Row(
      mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isUser)
          const CircleAvatar(
            child: Icon(Icons.android),
          ),
        if (!isUser) const SizedBox(width: 8),
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isUser ? Colors.blue[200] : Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(message['content'] ?? ''),
          ),
        ),
        if (isUser) const SizedBox(width: 8),
        if (isUser)
          const CircleAvatar(
            child: Icon(Icons.person),
          ),
      ],
    );
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done') {
            setState(() {
              _isListening = false;
            });
          }
        },
        onError: (error) {
          print('Error: $error');
          setState(() {
            _isListening = false;
          });
        },
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: _onSpeechResult,
          localeId: 'en_US',
        );
      } else {
        print('El usuario ha denegado el uso del reconocimiento de voz.');
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _controller.text = result.recognizedWords;
    });
  }

  void _onSendPressed() {
    final message = _controller.text.trim();
    if (message.isNotEmpty) {
      _sendMessage(message);
    }
  }

  void _onTextChanged() {
    setState(() {
      _isTextNotEmpty = _controller.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Limpia el controller
    _speech.stop();
    _flutterTts.stop();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chatbot with Gemini')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          if (_isBotTyping)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    child: Icon(Icons.smart_toy),
                  ),
                  SizedBox(width: 8),
                  CircularProgressIndicator(),
                ],
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
                            ? 'Type a message...'
                            : 'No connection',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(_isListening ? Icons.mic : Icons.mic_off),
                  onPressed: _isConnected ? _startListening : null,
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: (_isConnected && _isTextNotEmpty)
                      ? Colors.blue
                      : Colors.grey,
                  onPressed:
                      (_isConnected && _isTextNotEmpty) ? _onSendPressed : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
