import 'package:flutter/material.dart';

import 'gps_detector_screen.dart';
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
    _tabController = TabController(length: 4, vsync: this);
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
            Tab(text: 'GPS', icon: Icon(Icons.gps_fixed)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          PerfilScreen(),
          TareasScreen(),
          PokedexScreen(),
          GPSStatusScreen(),
        ],
      ),
    );
  }
}
