import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  String? matricula;
  MobileScannerController controller = MobileScannerController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _mostrarResultado() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Resultado'),
        content: Text('Matrícula: $matricula'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.start();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escanear QR'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: MobileScanner(
              controller: controller,
              onDetect: (BarcodeCapture barcodeCapture) {
                final List<Barcode> barcodes = barcodeCapture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue == null) {
                    debugPrint('Código QR no válido');
                  } else {
                    final String code = barcode.rawValue!;
                    setState(() {
                      matricula = code;
                    });
                    _mostrarResultado();
                    controller.stop();
                    break;
                  }
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (matricula != null)
                  ? Text('Matrícula: $matricula')
                  : Text('Escanea un código QR'),
            ),
          ),
        ],
      ),
    );
  }
}
