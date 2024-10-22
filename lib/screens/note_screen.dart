import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class NoteScreen extends StatefulWidget {
  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  bool _isListening = false;
  String _lastWords = 'Presiona el botón y empieza a hablar';
  double _confidence = 1.0;
  List<String> _notes = [];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage('es-ES');
    _loadNotes();
  }

  // Cargar las notas almacenadas
  void _loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notes = prefs.getStringList('notes') ?? [];
    });
  }

  // Guardar las notas
  void _saveNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('notes', _notes);
  }

  // Función para manejar la escucha del micrófono
  void _listen(TextEditingController controller) async {
    if (!_isListening) {
      try {
        bool available = await _speech.initialize(
          onStatus: (val) => print('onStatus: $val'),
          onError: (val) => print('onError: $val'),
        );
        if (available) {
          setState(() => _isListening = true);
          _speech.listen(
            onResult: (val) => setState(() {
              _lastWords = val.recognizedWords;
              controller.text = _lastWords;
              if (val.hasConfidenceRating && val.confidence > 0) {
                _confidence = val.confidence;
              }
            }),
          );
        } else {
          print('El reconocimiento de voz no está disponible');
        }
      } catch (e) {
        print('Error al inicializar SpeechToText: $e');
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  // Mostrar diálogo para agregar nota mediante dictado y mostrar texto en tiempo real
  void _showAddNoteDialog() {
    TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nueva Nota'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _controller,
                maxLines: null,
                decoration:
                    const InputDecoration(hintText: 'Escribe o dicta tu nota'),
              ),
              IconButton(
                icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                onPressed: () {
                  _listen(_controller);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _speech.stop();
                setState(() => _isListening = false);
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _speech.stop();
                setState(() => _isListening = false);
                if (_controller.text.trim().isNotEmpty) {
                  setState(() {
                    _notes.add(_controller.text.trim());
                    _saveNotes();
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  // Leer una nota en voz alta
  void _speak(String text) async {
    await _flutterTts.speak(text);
  }

  // Construir las tarjetas de notas
  Widget _buildNoteCard(int index) {
    return Card(
      elevation: 4,
      shadowColor: Colors.grey,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        title: Text(_notes[index]),
        leading: IconButton(
          icon: const Icon(Icons.volume_up),
          onPressed: () => _speak(_notes[index]),
        ),
        trailing: Wrap(
          spacing: 0,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showAddNoteDialog(),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  _notes.removeAt(index);
                  _saveNotes();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // Construir la lista de notas
  Widget _buildNotesList() {
    return ListView.builder(
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        return _buildNoteCard(index);
      },
    );
  }

  // Mostrar botón flotante para agregar nota
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _showAddNoteDialog,
      child: const Icon(Icons.edit),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Notas (Confianza: ${(_confidence * 100.0).toStringAsFixed(1)}%)'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _notes.isEmpty
                ? const Center(
                    child: Text(
                        'No hay notas. Presiona el botón para agregar una.'))
                : _buildNotesList(),
          ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            reverse: true,
            child: Container(
              width: width,
              height: height * 0.3,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Text(
                _lastWords,
                style: TextStyle(
                  fontSize: 24,
                  color: _isListening ? Colors.black87 : Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
}
