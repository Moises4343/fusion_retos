import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vudoo-English'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              elevation: 4.0,
              margin: const EdgeInsets.all(12.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo en la parte superior
                    Center(
                      child: Image.network(
                        'https://raw.githubusercontent.com/Moises4343/fusion_retos/refs/heads/main/lib/img/UP.jpeg',
                        width: 100,
                        height: 100,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Carrera:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text('Ingeniería en Software'),
                    const SizedBox(height: 12),
                    const Text(
                      'Materia:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text('Programación para móviles II'),
                    const SizedBox(height: 12),
                    const Text(
                      'Grupo:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text('9°B'),
                    const SizedBox(height: 12),
                    const Text(
                      'Nombre del alumno:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text('Moisés De Jesús Anzueto González'),
                    const SizedBox(height: 12),
                    const Text(
                      'Matricula:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text('193243'),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text(
                          'Enlace a GitHub: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.link),
                          onPressed: () => _openGitHubProfile(
                              'https://github.com/Moises4343/fusion_retos'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openGitHubProfile(String url) async {
    final Uri launchUri = Uri.parse(url);

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(
        launchUri,
        mode: LaunchMode.inAppWebView,
      );
    } else {
      throw 'No se puede abrir $url';
    }
  }
}
