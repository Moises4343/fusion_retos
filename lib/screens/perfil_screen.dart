import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperación corte 1'),
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
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Carrera:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text('Ingeniería en Software'),
                    SizedBox(height: 12),
                    Text(
                      'Materia:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text('Programación para móviles II'),
                    SizedBox(height: 12),
                    Text(
                      'Grupo:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text('9°B'),
                    SizedBox(height: 12),
                    Text(
                      'Nombre del alumno:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text('Moisés De Jesús Anzueto González'),
                    SizedBox(height: 12),
                    Text(
                      'Matricula:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text('193243'),
                  ],
                ),
              ),
            ),

            // Tabla con los datos
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const <DataColumn>[
                  DataColumn(
                    label: Text(
                      'Logo',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Nombre',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Matrícula',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Llamar',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Mensaje',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'GitHub',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
                rows: <DataRow>[
                  _buildDataRow(
                    context,
                    imageUrl:
                        'https://raw.githubusercontent.com/Moises4343/fusion_retos/refs/heads/main/lib/img/UP.jpeg',
                    name: 'Moisés Anzueto',
                    matricula: '193243',
                    phoneNumber: '961-326-7127',
                    githubUrl: 'https://github.com/Moises4343/fusion_retos',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método que crea una fila en la tabla
  DataRow _buildDataRow(BuildContext context,
      {required String imageUrl,
      required String name,
      required String matricula,
      required String phoneNumber,
      required String githubUrl}) {
    return DataRow(
      cells: <DataCell>[
        DataCell(
          Image.network(imageUrl, width: 50, height: 50),
        ),
        DataCell(Text(name)),
        DataCell(Text(matricula)),
        DataCell(
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () => _makePhoneCall(phoneNumber),
          ),
        ),
        DataCell(
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () => _sendMessage(phoneNumber),
          ),
        ),
        DataCell(
          IconButton(
            icon: const Icon(Icons.link),
            onPressed: () => _openGitHubProfile(githubUrl),
          ),
        ),
      ],
    );
  }

  // Método para hacer una llamada
  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  // Método para enviar un mensaje
  void _sendMessage(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
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
