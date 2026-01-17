import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/pokemon.dart';

class DatabaseService {
  static Isar? _isar;

  static Future<Isar> get instance async {
    if (_isar != null) return _isar!;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [PokemonSchema],
      directory: dir.path,
    );

    return _isar!;
  }

  static Future<void> savePokemons(List<Pokemon> pokemons) async {
    final isar = await instance;
    await isar.writeTxn(() async {
      await isar.pokemons.putAll(pokemons);
    });
  }

  static Future<List<Pokemon>> getAllPokemons() async {
    final isar = await instance;
    return await isar.pokemons.where().findAll();
  }

  static Future<Pokemon?> getPokemonById(int pokemonId) async {
    final isar = await instance;
    return await isar.pokemons.filter().pokemonIdEqualTo(pokemonId).findFirst();
  }

  static Future<void> clearPokemons() async {
    final isar = await instance;
    await isar.writeTxn(() async {
      await isar.pokemons.clear();
    });
  }

  static Future<int> getPokemonCount() async {
    final isar = await instance;
    return await isar.pokemons.count();
  }
}
