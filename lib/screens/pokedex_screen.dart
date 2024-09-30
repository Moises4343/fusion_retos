import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PokedexScreen extends StatefulWidget {
  @override
  _PokedexScreenState createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  int currentPage = 0;
  List<dynamic> pokemons = [];
  String searchQuery = '';
  bool isLoading = false;

  final int limit = 10;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPokemons();
  }

  // Función para obtener Pokémon de la API
  Future<void> _fetchPokemons({String query = ''}) async {
    setState(() {
      isLoading = true;
    });

    final offset = currentPage * limit;
    final url = query.isEmpty
        ? 'https://pokeapi.co/api/v2/pokemon?offset=$offset&limit=$limit'
        : 'https://pokeapi.co/api/v2/pokemon?offset=0&limit=1000';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> results = data['results'];

      // Filtrar si hay un query de búsqueda
      if (query.isNotEmpty) {
        results = results.where((pokemon) {
          return pokemon['name'].startsWith(query.toLowerCase());
        }).toList();
      }

      // Obtener las imágenes de los Pokémon
      final pokemonDetails = await Future.wait(results.map((pokemon) async {
        final pokemonData = await http.get(Uri.parse(pokemon['url']));
        if (pokemonData.statusCode == 200) {
          final pokemonInfo = json.decode(pokemonData.body);
          return {
            'name': pokemon['name'],
            'image': pokemonInfo['sprites']['front_default'],
          };
        }
        return {
          'name': pokemon['name'],
          'image': null,
        };
      }).toList());

      setState(() {
        pokemons = pokemonDetails.take(limit).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Error al cargar Pokémon');
    }
  }

  // Función para cambiar de página
  void _changePage(int page) {
    setState(() {
      currentPage = page;
      _fetchPokemons(query: searchQuery);
    });
  }

  // Función para buscar Pokémon
  void _searchPokemon(String query) {
    setState(() {
      searchQuery = query;
      currentPage = 0;
      _fetchPokemons(query: query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokedex'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar Pokémon',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _searchPokemon(_searchController.text);
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                _searchPokemon(value);
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1 / 1.3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                      ),
                      itemCount: pokemons.length,
                      itemBuilder: (context, index) {
                        final pokemon = pokemons[index];
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 7,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              pokemon['image'] != null
                                  ? Image.network(
                                      pokemon['image'],
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 100,
                                      height: 100,
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: Text(
                                          'Sin imagen',
                                          style: TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        ),
                                      ),
                                    ),
                              const SizedBox(height: 10),
                              Text(
                                pokemon['name'].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            // Controles de paginación
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: currentPage == 0
                      ? null
                      : () => _changePage(currentPage - 1),
                  icon: const Icon(Icons.arrow_back),
                  iconSize: 32,
                  color: Colors.blue,
                ),
                Text('Página ${currentPage + 1}',
                    style: const TextStyle(fontSize: 18)),
                IconButton(
                  onPressed: pokemons.length < limit
                      ? null
                      : () => _changePage(currentPage + 1),
                  icon: const Icon(Icons.arrow_forward),
                  iconSize: 32,
                  color: Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
