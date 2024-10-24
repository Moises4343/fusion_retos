import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class GPSStatusScreen extends StatefulWidget {
  const GPSStatusScreen({super.key});

  @override
  _GPSStatusScreenState createState() => _GPSStatusScreenState();
}

class _GPSStatusScreenState extends State<GPSStatusScreen> {
  String _gpsStatus = "Comprobando el estado del GPS...";
  IconData _statusIcon = Icons.location_searching;
  Color _iconColor = Colors.blue;
  Position? _position;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkGPSStatus();
  }

  Future<void> _checkGPSStatus() async {
    setState(() {
      _isLoading = true;
      _gpsStatus = "Comprobando el estado del GPS...";
      _statusIcon = Icons.location_searching;
      _iconColor = Colors.blue;
    });

    bool serviceEnabled;
    LocationPermission permission;

    // Verifica si el servicio de GPS está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _gpsStatus = "El GPS está deshabilitado. Por favor, actívalo.";
        _statusIcon = Icons.warning;
        _iconColor = Colors.red;
        _isLoading = false;
      });
      return;
    }

    // Verifica los permisos de ubicación
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _gpsStatus = "Los permisos de ubicación están denegados.";
          _statusIcon = Icons.warning;
          _iconColor = Colors.red;
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _gpsStatus =
            "Los permisos de ubicación están permanentemente denegados.";
        _statusIcon = Icons.warning;
        _iconColor = Colors.red;
        _isLoading = false;
      });
      return;
    }

    // Obtener la ubicación actual
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Verificar si la ubicación es falsa
      bool isMocked = position.isMocked;

      print('isMocked: $isMocked');

      setState(() {
        _position = position;
        if (isMocked) {
          _gpsStatus = "Advertencia: ¡La ubicación está siendo falsificada!";
          _statusIcon = Icons.error;
          _iconColor = Colors.red;
        } else {
          _gpsStatus = "Ubicación obtenida correctamente.";
          _statusIcon = Icons.check_circle;
          _iconColor = Colors.green;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _gpsStatus = "Error al obtener la ubicación: $e";
        _statusIcon = Icons.warning;
        _iconColor = Colors.red;
        _isLoading = false;
      });
    }
  }

  // Método para abrir Google Maps con las coordenadas
  void _openGoogleMaps() {
    if (_position != null) {
      final String googleMapsUrl =
          "https://www.google.com/maps/search/?api=1&query=${_position!.latitude},${_position!.longitude}";
      launch(googleMapsUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero obten la ubicación')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detector de GPS'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(_statusIcon, color: _iconColor, size: 48),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _gpsStatus,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _iconColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    if (_position != null && !_isLoading)
                      Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.my_location,
                                color: Colors.blue),
                            title: Text("Latitud: ${_position!.latitude}"),
                          ),
                          ListTile(
                            leading: const Icon(Icons.location_on,
                                color: Colors.blue),
                            title: Text("Longitud: ${_position!.longitude}"),
                          ),
                        ],
                      )
                    else if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      const Text("Ubicación no disponible"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _checkGPSStatus,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar estado del GPS'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _openGoogleMaps,
              icon: const Icon(Icons.location_on),
              label: const Text('Abrir en Google Maps'),
            ),
          ],
        ),
      ),
    );
  }
}
