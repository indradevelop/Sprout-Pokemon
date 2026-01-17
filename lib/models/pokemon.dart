import 'package:isar/isar.dart';

part 'pokemon.g.dart';

@collection
class Pokemon {
  Id id = Isar.autoIncrement;

  late int pokemonId;
  late String name;
  late List<String> types;
  late String imageUrl;

  // Detail page data
  late String species;
  late double height; // in decimeters
  late double weight; // in hectograms
  late List<String> abilities;
  late double maleRatio; // percentage
  late String eggGroups;
  late int eggCycles;

  // Base stats
  late int hp;
  late int attack;
  late int defense;
  late int spAtk;
  late int spDef;
  late int speed;

  Pokemon({
    this.pokemonId = 0,
    this.name = '',
    this.types = const [],
    this.imageUrl = '',
    this.species = '',
    this.height = 0.0,
    this.weight = 0.0,
    this.abilities = const [],
    this.maleRatio = 0.0,
    this.eggGroups = '',
    this.eggCycles = 0,
    this.hp = 0,
    this.attack = 0,
    this.defense = 0,
    this.spAtk = 0,
    this.spDef = 0,
    this.speed = 0,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final types = (json['types'] as List)
        .map((type) => type['type']['name'] as String)
        .toList()
        .cast<String>();

    final abilities = (json['abilities'] as List)
        .map((ability) => ability['ability']['name'] as String)
        .toList()
        .cast<String>();

    final stats = json['stats'] as List;
    int hp = 0, attack = 0, defense = 0, spAtk = 0, spDef = 0, speed = 0;

    for (var stat in stats) {
      final statName = stat['stat']['name'] as String;
      final baseStat = stat['base_stat'] as int;

      switch (statName) {
        case 'hp':
          hp = baseStat;
          break;
        case 'attack':
          attack = baseStat;
          break;
        case 'defense':
          defense = baseStat;
          break;
        case 'special-attack':
          spAtk = baseStat;
          break;
        case 'special-defense':
          spDef = baseStat;
          break;
        case 'speed':
          speed = baseStat;
          break;
      }
    }

    return Pokemon(
      pokemonId: json['id'] as int,
      name: json['name'] as String,
      types: types,
      imageUrl: json['sprites']['other']['official-artwork']['front_default'] ??
          json['sprites']['front_default'] ??
          '',
      species: json['species']['name'] ?? '',
      height: (json['height'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      abilities: abilities,
      maleRatio:
          50.0, // Default, would need species endpoint for accurate ratio
      eggGroups: '',
      eggCycles: 0,
      hp: hp,
      attack: attack,
      defense: defense,
      spAtk: spAtk,
      spDef: spDef,
      speed: speed,
    );
  }
}
