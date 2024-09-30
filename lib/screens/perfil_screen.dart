import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PerfilScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Datos'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const <DataColumn>[
            DataColumn(
              label: Text(
                'Imagen',
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
                  'https://raw.githubusercontent.com/Moises4343/fusion_retos/refs/heads/main/lib/img/moises.jpg',
              name: 'Moisés Anzueto',
              matricula: '193243',
              phoneNumber: '961-326-7127',
              githubUrl: 'https://github.com/Moises4343/fusion_retos',
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

  // Método para abrir el perfil de GitHub
  void _openGitHubProfile(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No se puede abrir $url';
    }
  }
}
