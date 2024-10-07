import 'package:flutter/material.dart';

import 'gps_detector_screen.dart'; // Importa la nueva pantalla de GPS
import 'perfil_screen.dart';
import 'pokedex_screen.dart';
import 'tareas_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 4, vsync: this); // Cambia la longitud a 4
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HOME'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mi Perfil', icon: Icon(Icons.person)),
            Tab(text: 'Tareas', icon: Icon(Icons.task)),
            Tab(text: 'Pokedex', icon: Icon(Icons.catching_pokemon)),
            Tab(text: 'GPS', icon: Icon(Icons.gps_fixed)), // Nueva pestaña GPS
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          PerfilScreen(), // Pantalla Mi Perfil
          TareasScreen(), // Pantalla Tareas
          PokedexScreen(), // Pantalla Pokedex
          GPSStatusScreen(), // Pantalla GPS Detector
        ],
      ),
    );
  }
}
