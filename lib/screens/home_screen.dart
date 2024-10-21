import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'chat_screen.dart';
import 'gps_detector_screen.dart';
import 'perfil_screen.dart';
import 'pokedex_screen.dart';
import 'qr_generate_screen.dart';
import 'qr_screen.dart';
import 'sensor_screen.dart';
import 'tareas_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Mi Perfil', icon: Icon(Icons.person)),
                Tab(text: 'Tareas', icon: Icon(Icons.task)),
                Tab(text: 'Pokedex', icon: Icon(Icons.catching_pokemon)),
                Tab(text: 'GPS', icon: Icon(Icons.gps_fixed)),
                Tab(text: 'Chatbot', icon: FaIcon(FontAwesomeIcons.robot)),
                Tab(text: 'QR-Camera', icon: Icon(Icons.camera_alt)),
                Tab(text: 'QR-Generate', icon: Icon(Icons.qr_code)),
                Tab(text: 'Sensor', icon: Icon(Icons.sensors)),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const PerfilScreen(),
          const TareasScreen(),
          const PokedexScreen(),
          const GPSStatusScreen(),
          const ChatScreen(),
          QRScreen(),
          QRGenerateScreen(),
          SensorScreen(),
        ],
      ),
    );
  }
}
