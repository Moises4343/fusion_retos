import 'package:flutter/material.dart';

class TareasScreen extends StatefulWidget {
  @override
  _TareasScreenState createState() => _TareasScreenState();
}

class _TareasScreenState extends State<TareasScreen> {
  String task = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Agregar tarea',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                task = value;
              });
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Acción al agregar la tarea
              print('Tarea agregada: $task');
            },
            child: Text('Agregar Tarea'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple, // Cambia el color del botón
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              textStyle: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
