import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PokedexScreen extends StatefulWidget {
  @override
  _PokedexScreenState createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  Future<Map<String, dynamic>> fetchPokemonData() async {
    final response = await http
        .get(Uri.parse('https://pokeapi.co/api/v2/pokemon/1')); // Bulbasaur
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar datos de Pokémon');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchPokemonData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error al cargar datos'));
        } else {
          final pokemon = snapshot.data as Map<String, dynamic>;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(pokemon['sprites']['front_default']),
                Text(
                  'Nombre: ${pokemon['name'].toUpperCase()}',
                  style: TextStyle(fontSize: 24),
                ),
                Text('Altura: ${pokemon['height']}'),
                Text('Peso: ${pokemon['weight']}'),
              ],
            ),
          );
        }
      },
    );
  }
}
