import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/pokemon.dart';

class PokemonDetailPage extends StatefulWidget {
  final Pokemon pokemon;
  final Color color;

  const PokemonDetailPage({
    super.key,
    required this.pokemon,
    required this.color,
  });

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isFavorite = false;

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
    final pokemonName = widget.pokemon.name.replaceFirst(
      widget.pokemon.name[0],
      widget.pokemon.name[0].toUpperCase(),
    );
    final pokemonId = '#${widget.pokemon.pokemonId.toString().padLeft(3, '0')}';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            Brightness.light, // White icons on colored background
        statusBarBrightness: Brightness.dark, // iOS
        systemStatusBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: widget.color,
        body: SafeArea(
          child: Column(
            children: [
              // Header Section
              Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    color: widget.color,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Back button and favorite
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                            IconButton(
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: () {
                                setState(() {
                                  isFavorite = !isFavorite;
                                });
                              },
                            ),
                          ],
                        ),
                        // Pokemon Name and ID
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                pokemonName,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                pokemonId,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Type badges
                        Padding(
                          padding: const EdgeInsets.only(left: 16, bottom: 16),
                          child: Row(
                            children: widget.pokemon.types.map((type) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  child: Text(
                                    type.replaceFirst(
                                      type[0],
                                      type[0].toUpperCase(),
                                    ),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: -20,
                    child: Image.asset(
                      'assets/images/pokeball.png',
                      width: 180,
                      height: 180,
                      color: Colors.white24,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? 20
                          : 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: MediaQuery.of(context).orientation ==
                            Orientation.landscape
                        ? -8
                        : 0,
                    child: widget.pokemon.imageUrl.isNotEmpty
                        ? Center(
                            child: Image.network(
                              widget.pokemon.imageUrl,
                              height: MediaQuery.of(context).orientation ==
                                      Orientation.landscape
                                  ? MediaQuery.of(context).size.height * 0.4
                                  : MediaQuery.of(context).size.height * 0.25,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.white54,
                                  size: 100,
                                );
                              },
                            ),
                          )
                        : Container(),
                  )
                ],
              ),
              // Tab Bar and Content
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        labelColor: Colors.blue,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.blue,
                        indicatorWeight: 3,
                        labelStyle: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold),
                        unselectedLabelStyle: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold),
                        tabs: const [
                          Tab(text: 'About'),
                          Tab(text: 'Base Stats'),
                          Tab(text: 'Evolution'),
                          Tab(text: 'Moves'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // About Tab
                            _buildAboutTab(),
                            // Base Stats Tab
                            _buildBaseStatsTab(),
                            // Evolution Tab
                            _buildEvolutionTab(),
                            // Moves Tab
                            _buildMovesTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutTab() {
    // Convert height from decimeters to feet and cm
    final heightInCm = widget.pokemon.height * 10;
    final heightInFeet = heightInCm / 30.48;
    final feet = heightInFeet.toInt();
    final inches = ((heightInFeet - feet) * 12).toInt();
    final heightStr = '$feet\'$inches" (${heightInCm.toStringAsFixed(2)} cm)';

    // Convert weight from hectograms to lbs and kg
    final weightInKg = widget.pokemon.weight / 10;
    final weightInLbs = weightInKg * 2.20462;
    final weightStr =
        '${weightInLbs.toStringAsFixed(1)} lbs (${weightInKg.toStringAsFixed(1)} kg)';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Species
          _buildDetailRow('Species', widget.pokemon.species),
          const SizedBox(height: 12),
          // Height
          _buildDetailRow('Height', heightStr),
          const SizedBox(height: 12),
          // Weight
          _buildDetailRow('Weight', weightStr),
          const SizedBox(height: 12),
          // Abilities
          _buildDetailRow(
            'Abilities',
            widget.pokemon.abilities.isNotEmpty
                ? widget.pokemon.abilities
                    .map((a) => a.replaceFirst(a[0], a[0].toUpperCase()))
                    .join(', ')
                : 'Unknown',
          ),
          const SizedBox(height: 24),
          // Breeding Section
          const Text(
            'Breeding',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          // Gender
          _buildDetailRow(
            'Gender',
            '♂️ ${widget.pokemon.maleRatio.toStringAsFixed(1)}%    ♀️ ${(100 - widget.pokemon.maleRatio).toStringAsFixed(1)}%',
          ),
          const SizedBox(height: 12),
          // Egg Groups
          _buildDetailRow('Egg Groups', widget.pokemon.eggGroups),
          const SizedBox(height: 12),
          // Egg Cycle
          _buildDetailRow('Egg Cycle', '${widget.pokemon.eggCycles} cycles'),
        ],
      ),
    );
  }

  Widget _buildBaseStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildStatBar('HP', widget.pokemon.hp, 100),
          const SizedBox(height: 8),
          _buildStatBar('Attack', widget.pokemon.attack, 100),
          const SizedBox(height: 8),
          _buildStatBar('Defense', widget.pokemon.defense, 100),
          const SizedBox(height: 8),
          _buildStatBar('Sp. Atk', widget.pokemon.spAtk, 100),
          const SizedBox(height: 8),
          _buildStatBar('Sp. Def', widget.pokemon.spDef, 100),
          const SizedBox(height: 8),
          _buildStatBar('Speed', widget.pokemon.speed, 100),
          const SizedBox(height: 32),
          const Text(
            'Type Defenses',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Type effectiveness chart will be displayed here',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvolutionTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: const [
            Text(
              'Evolution Chain',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('Evolution data will be displayed here'),
          ],
        ),
      ),
    );
  }

  Widget _buildMovesTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: const [
            Text(
              'Moves',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('Moves list will be displayed here'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            softWrap: true,
            maxLines: null,
          ),
        ),
      ],
    );
  }

  Widget _buildStatBar(String statName, int value, int maxValue) {
    final percentage = value / maxValue;
    final barColor = percentage > 0.5
        ? Colors.green
        : percentage > 0.4
            ? Colors.orange
            : Colors.red;

    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            statName,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            value.toString(),
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 6,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ),
      ],
    );
  }
}
