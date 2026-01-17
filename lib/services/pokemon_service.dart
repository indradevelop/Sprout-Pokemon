import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../models/pokemon.dart';
import 'database_service.dart';

class PokemonService {
  static const String baseUrl = 'https://pokeapi.co/api/v2';

  static Stream<PokemonLoadEvent> fetchPokemonsProgressively({
    int limit = 20,
    int offset = 0,
    bool forceRefresh = false,
  }) async* {
    try {
      // Fetch from API
      final response = await http.get(
        Uri.parse('$baseUrl/pokemon?limit=$limit&offset=$offset'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> results = data['results'];

        // Emit count of current batch
        yield PokemonLoadEvent(totalCount: results.length);

        List<Pokemon> pokemons = [];

        for (var result in results) {
          final pokemonUrl = result['url'] as String;
          final pokemonResponse = await http.get(Uri.parse(pokemonUrl));

          if (pokemonResponse.statusCode == 200) {
            final pokemonData = jsonDecode(pokemonResponse.body);
            final pokemon = Pokemon.fromJson(pokemonData);
            pokemons.add(pokemon);

            // Emit each loaded pokemon
            yield PokemonLoadEvent(pokemon: pokemon);
          }
        }

        // Save to database
        if (pokemons.isNotEmpty) {
          await DatabaseService.savePokemons(pokemons);
        }
      } else {
        throw Exception('Failed to load pokemons');
      }
    } catch (e) {
      // If API fails, try to return cached data
      final cachedPokemons = await DatabaseService.getAllPokemons();
      if (cachedPokemons.isNotEmpty) {
        // Return only the requested range from cache
        final endIndex = (offset + limit).clamp(0, cachedPokemons.length);
        final paginatedPokemons = cachedPokemons.sublist(offset, endIndex);

        yield PokemonLoadEvent(totalCount: paginatedPokemons.length);
        for (var pokemon in paginatedPokemons) {
          yield PokemonLoadEvent(pokemon: pokemon);
        }
      } else {
        yield PokemonLoadEvent(error: 'Error fetching pokemons: $e');
      }
    }
  }

  static Color getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'grass':
      case 'poison':
        return const Color(0xFF78C850);
      case 'fire':
        return const Color(0xFFF08030);
      case 'water':
        return const Color(0xFF6890F0);
      case 'electric':
        return const Color(0xFFF8D030);
      case 'ice':
        return const Color(0xFF98D8D8);
      case 'fighting':
        return const Color(0xFFA05038);
      case 'flying':
        return const Color(0xFFA890F0);
      case 'ground':
        return const Color(0xFFE0C068);
      case 'rock':
        return const Color(0xFFB8A038);
      case 'bug':
        return const Color(0xFFA8B820);
      case 'ghost':
        return const Color(0xFF705898);
      case 'steel':
        return const Color(0xFFB8B8D0);
      case 'psychic':
        return const Color(0xFFF85888);
      case 'dark':
        return const Color(0xFF705848);
      case 'dragon':
        return const Color(0xFF7038F8);
      case 'fairy':
        return const Color(0xFFEE99AC);
      default:
        return const Color(0xFF68A090);
    }
  }
}

class PokemonLoadEvent {
  final int? totalCount;
  final Pokemon? pokemon;
  final String? error;

  PokemonLoadEvent({this.totalCount, this.pokemon, this.error});
}
