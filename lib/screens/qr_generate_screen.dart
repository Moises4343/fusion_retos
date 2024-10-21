import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRGenerateScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generar QR'),
      ),
      body: Center(
        child: QrImageView(
          data: '193243',
          version: QrVersions.auto,
          size: 200.0,
        ),
      ),
    );
  }
}
