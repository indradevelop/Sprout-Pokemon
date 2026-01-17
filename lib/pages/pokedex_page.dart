import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../services/pokemon_service.dart';
import 'pokemon_detail_page.dart';

class PokeDexPage extends StatefulWidget {
  const PokeDexPage({super.key});

  @override
  State<PokeDexPage> createState() => _PokeDexPageState();
}

class _PokeDexPageState extends State<PokeDexPage> {
  List<Pokemon?> _pokemons = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  int _currentOffset = 0;
  final int _limit = 20;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadPokemons();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoadingMore &&
        !_isLoading) {
      _loadMorePokemons();
    }
  }

  void _checkAndLoadMore() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _onScroll();
      }
    });
  }

  Future<void> _loadPokemons({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _currentOffset = 0;
      if (forceRefresh) {
        _pokemons = [];
      }
    });

    await for (var event in PokemonService.fetchPokemonsProgressively(
      limit: _limit,
      offset: _currentOffset,
      forceRefresh: forceRefresh,
    )) {
      if (event.totalCount != null) {
        // Initialize with placeholders
        setState(() {
          _pokemons =
              List<Pokemon?>.filled(event.totalCount!, null, growable: true);
        });
      } else if (event.pokemon != null) {
        // Update with actual pokemon data
        setState(() {
          final index = _pokemons.indexWhere((p) => p == null);
          if (index != -1) {
            _pokemons[index] = event.pokemon;
          }
        });
      } else if (event.error != null) {
        setState(() {
          _error = event.error;
          _isLoading = false;
        });
        return;
      }
    }

    setState(() {
      _isLoading = false;
      _currentOffset += _limit;
    });

    // Check if we need to load more after initial load
    _checkAndLoadMore();
  }

  Future<void> _loadMorePokemons() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    final currentLength = _pokemons.length;

    await for (var event in PokemonService.fetchPokemonsProgressively(
      limit: _limit,
      offset: _currentOffset,
      forceRefresh: false,
    )) {
      if (event.totalCount != null) {
        // Add placeholders for the incoming batch (keeps itemCount stable)
        setState(() {
          _pokemons.addAll(
              List<Pokemon?>.filled(event.totalCount!, null, growable: true));
        });
      } else if (event.pokemon != null) {
        // Update with actual pokemon data
        setState(() {
          // Find first null starting from currentLength
          int index = -1;
          for (int i = currentLength; i < _pokemons.length; i++) {
            if (_pokemons[i] == null) {
              index = i;
              break;
            }
          }
          if (index != -1) {
            _pokemons[index] = event.pokemon;
          }
        });
      } else if (event.error != null) {
        setState(() {
          _isLoadingMore = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(event.error!)),
          );
        }
        return;
      }
    }

    setState(() {
      _isLoadingMore = false;
      _currentOffset += _limit;
    });

    // Check if we need to load more after UI updates
    _checkAndLoadMore();
  }

  Future<void> _refreshPokemons() async {
    await _loadPokemons(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          Positioned(
            top: -52,
            right: -84,
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/pokeball.png',
                width: 220,
                height: 220,
                color: Colors.grey,
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: false,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {},
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black),
                  onPressed: () {
                    // Handle menu action
                  },
                ),
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                const Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                  child: Text(
                    'Pokedex',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (_error != null && _pokemons.isEmpty) {
                        return Center(
                          child: Text('Error: $_error'),
                        );
                      }

                      if (_pokemons.isEmpty && _isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (_pokemons.isEmpty) {
                        return const Center(
                          child: Text('No pokemons found'),
                        );
                      }

                      final isLandscape = MediaQuery.of(context).orientation ==
                          Orientation.landscape;
                      return RefreshIndicator(
                        onRefresh: _refreshPokemons,
                        child: GridView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isLandscape ? 4 : 2,
                            childAspectRatio: 1.4,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                          ),
                          itemCount: _pokemons.length,
                          itemBuilder: (context, index) {
                            final pokemon = _pokemons[index];

                            // Show placeholder if pokemon is null
                            if (pokemon == null) {
                              return const PokemonCardPlaceholder();
                            }

                            final primaryType = pokemon.types.isNotEmpty
                                ? pokemon.types[0]
                                : 'normal';
                            final cardColor =
                                PokemonService.getTypeColor(primaryType);

                            return PokemonCard(
                              pokemon: pokemon,
                              color: cardColor,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final Color color;

  const PokemonCard({
    super.key,
    required this.pokemon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PokemonDetailPage(
              pokemon: pokemon,
              color: color,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: -4,
              right: -10,
              child: Opacity(
                opacity: 0.2,
                child: Image.asset(
                  'assets/images/pokeball.png',
                  width: 80,
                  height: 80,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    pokemon.name.replaceFirst(
                      pokemon.name[0],
                      pokemon.name[0].toUpperCase(),
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: pokemon.types.map((type) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          child: Text(
                            type.replaceFirst(
                              type[0],
                              type[0].toUpperCase(),
                            ),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 8,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Positioned(
                top: 12,
                right: 12,
                child: Text(
                  '#${pokemon.pokemonId.toString().padLeft(3, '0')}',
                  style: const TextStyle(
                    color: Colors.white24,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                )),
            Positioned(
              bottom: 0,
              right: -6,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: pokemon.imageUrl.isNotEmpty
                    ? Image.network(
                        pokemon.imageUrl,
                        fit: BoxFit.contain,
                        width: 84,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image_not_supported,
                            color: Colors.white54,
                          );
                        },
                      )
                    : const Icon(
                        Icons.image_not_supported,
                        color: Colors.white54,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PokemonCardPlaceholder extends StatelessWidget {
  const PokemonCardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: -4,
            right: -10,
            child: Opacity(
              opacity: 0.2,
              child: Image.asset(
                'assets/images/pokeball.png',
                width: 80,
                height: 80,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 60,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              width: 40,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const Positioned(
            bottom: 8,
            right: 8,
            child: SizedBox(
              width: 84,
              height: 84,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white38),
                  strokeWidth: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
