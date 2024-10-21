import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensorScreen extends StatefulWidget {
  @override
  _SensorScreenState createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> {
  // Variables para almacenar los valores del acelerómetro
  double x = 0.0, y = 0.0, z = 0.0;

  // Variables para almacenar los valores del giroscopio
  double gyroX = 0.0, gyroY = 0.0, gyroZ = 0.0;

  // Variables para almacenar los valores del magnetómetro
  double magX = 0.0, magY = 0.0, magZ = 0.0;

  // Posición de la bola en la pantalla
  double posX = 0.0, posY = 0.0;

  // Tamaño de la bola
  final double ballSize = 50.0;

  // Dimensiones del área de juego
  double gameAreaWidth = 0.0;
  double gameAreaHeight = 0.0;

  // Controladores de StreamSubscription
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;

  // Bandera para inicializar la posición una sola vez
  bool isPositionInitialized = false;

  // GlobalKey para obtener el contexto del área de juego
  final GlobalKey _gameAreaKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // Suscribirse al acelerómetro
    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        x = event.x;
        y = event.y;
        z = event.z;

        if (isPositionInitialized) {
          // Ajustamos la sensibilidad multiplicando por un factor
          double sensitivity = 2.0;

          posX += (-x * sensitivity);
          posY += (y * sensitivity);

          // Limitar la posición para que la bola no se salga del área de juego
          posX = posX.clamp(0.0, gameAreaWidth - ballSize);
          posY = posY.clamp(0.0, gameAreaHeight - ballSize);

          // Detectar si la bola ha tocado los bordes (ha caído)
          if (posX <= 0.0 ||
              posX >= gameAreaWidth - ballSize ||
              posY <= 0.0 ||
              posY >= gameAreaHeight - ballSize) {
            _mostrarMensajePerdida();
          }
        }
      });
    });

    // Inicializar la posición de la bola después de construir el widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? renderBox =
          _gameAreaKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        setState(() {
          gameAreaWidth = renderBox.size.width;
          gameAreaHeight = renderBox.size.height;

          posX = gameAreaWidth / 2 - ballSize / 2;
          posY = gameAreaHeight / 2 - ballSize / 2;

          isPositionInitialized = true;
        });
      }
    });

    // Suscribirse al giroscopio
    _gyroscopeSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        gyroX = event.x;
        gyroY = event.y;
        gyroZ = event.z;
      });
    });

    // Suscribirse al magnetómetro
    _magnetometerSubscription =
        magnetometerEvents.listen((MagnetometerEvent event) {
      setState(() {
        magX = event.x;
        magY = event.y;
        magZ = event.z;
      });
    });
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _magnetometerSubscription?.cancel();
    super.dispose();
  }

  // Método para mostrar los datos de los sensores
  Widget _buildSensorData() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Acelerómetro
          Container(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Acelerómetro',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('X: ${x.toStringAsFixed(2)}'),
                Text('Y: ${y.toStringAsFixed(2)}'),
                Text('Z: ${z.toStringAsFixed(2)}'),
              ],
            ),
          ),
          const SizedBox(width: 16.0),
          // Giroscopio
          Container(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Giroscopio',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('X: ${gyroX.toStringAsFixed(2)}'),
                Text('Y: ${gyroY.toStringAsFixed(2)}'),
                Text('Z: ${gyroZ.toStringAsFixed(2)}'),
              ],
            ),
          ),
          const SizedBox(width: 16.0),
          // Magnetómetro
          Container(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Magnetómetro',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('X: ${magX.toStringAsFixed(2)}'),
                Text('Y: ${magY.toStringAsFixed(2)}'),
                Text('Z: ${magZ.toStringAsFixed(2)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Método para mostrar el minijuego
  Widget _buildGame() {
    return Center(
      child: Container(
        key: _gameAreaKey,
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2.0),
          color: Colors.white,
        ),
        child: Stack(
          children: [
            // Bola
            Positioned(
              left: posX,
              top: posY,
              child: Container(
                width: ballSize,
                height: ballSize,
                decoration: const BoxDecoration(
                  color: Colors.pink,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Puedes añadir más elementos como objetivos u obstáculos aquí
          ],
        ),
      ),
    );
  }

  // Método para mostrar el mensaje de pérdida
  void _mostrarMensajePerdida() {
    // Pausa la suscripción al acelerómetro
    _accelerometerSubscription?.pause();

    showDialog(
      context: context,
      barrierDismissible: false, // Evita cerrar el diálogo tocando fuera
      builder: (context) => AlertDialog(
        title: const Text('¡Has perdido!'),
        content: const Text('La bola ha tocado el borde.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Reiniciar el juego
              setState(() {
                posX = gameAreaWidth / 2 - ballSize / 2;
                posY = gameAreaHeight / 2 - ballSize / 2;
              });
              // Reanuda la suscripción al acelerómetro
              _accelerometerSubscription?.resume();
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor y Minijuego'),
      ),
      body: Column(
        children: [
          // Mostrar los datos de los sensores
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildSensorData(),
          ),
          // Mostrar el minijuego
          Expanded(
            child: _buildGame(),
          ),
        ],
      ),
    );
  }
}
