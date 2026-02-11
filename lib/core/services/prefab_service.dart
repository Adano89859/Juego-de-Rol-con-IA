import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:quest_master/core/models/models.dart';
import 'package:uuid/uuid.dart';

/// Service for managing Prefab templates (save, load, import, export).
///
/// Prefabs are stored as individual JSON files in the app's documents directory.
/// Structure: `prefabs/{type}/{id}.json`
class PrefabService {
  static const _uuid = Uuid();
  Directory? _baseDir;

  Future<Directory> get _prefabDir async {
    if (_baseDir != null) return _baseDir!;
    final appDir = await getApplicationDocumentsDirectory();
    _baseDir = Directory('${appDir.path}/quest_master/prefabs');
    if (!await _baseDir!.exists()) {
      await _baseDir!.create(recursive: true);
    }
    return _baseDir!;
  }

  /// Save a character as a prefab template.
  Future<Prefab> saveCharacterPrefab({
    required String name,
    required Character character,
    String? description,
    List<String> tags = const [],
  }) async {
    final prefab = Prefab(
      id: _uuid.v4(),
      name: name,
      type: PrefabType.character,
      description: description,
      data: character
          .copyWith(
            isTemplate: true,
            templateName: name,
          )
          .toJson(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      tags: tags,
    );
    await _savePrefab(prefab);
    return prefab;
  }

  /// Save an item as a prefab template.
  Future<Prefab> saveItemPrefab({
    required String name,
    required GameItem item,
    String? description,
    List<String> tags = const [],
  }) async {
    final prefab = Prefab(
      id: _uuid.v4(),
      name: name,
      type: PrefabType.item,
      description: description,
      data: item
          .copyWith(
            isTemplate: true,
            templateName: name,
          )
          .toJson(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      tags: tags,
    );
    await _savePrefab(prefab);
    return prefab;
  }

  /// Save a location as a prefab template.
  Future<Prefab> saveLocationPrefab({
    required String name,
    required Location location,
    String? description,
    List<String> tags = const [],
  }) async {
    final prefab = Prefab(
      id: _uuid.v4(),
      name: name,
      type: PrefabType.location,
      description: description,
      data: location
          .copyWith(
            isTemplate: true,
            templateName: name,
          )
          .toJson(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      tags: tags,
    );
    await _savePrefab(prefab);
    return prefab;
  }

  /// Save a complete game situation as a prefab.
  Future<Prefab> saveSituationPrefab({
    required String name,
    required GameState gameState,
    String? description,
    List<String> tags = const [],
  }) async {
    final prefab = Prefab(
      id: _uuid.v4(),
      name: name,
      type: PrefabType.situation,
      description: description,
      data: {
        'era': gameState.era,
        'mainQuest': gameState.mainQuest,
        'locationName': gameState.currentLocation.name,
      },
      situationSnapshot: gameState.toJson(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      tags: tags,
    );
    await _savePrefab(prefab);
    return prefab;
  }

  /// Load all prefabs of a given type.
  Future<List<Prefab>> loadPrefabs({PrefabType? type}) async {
    final dir = await _prefabDir;
    final prefabs = <Prefab>[];

    if (!await dir.exists()) return prefabs;

    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.json')) {
        try {
          final content = await entity.readAsString();
          final json = jsonDecode(content) as Map<String, dynamic>;
          final prefab = Prefab.fromJson(json);
          if (type == null || prefab.type == type) {
            prefabs.add(prefab);
          }
        } catch (_) {
          // Skip corrupted files
        }
      }
    }

    prefabs.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return prefabs;
  }

  /// Load a single prefab by ID.
  Future<Prefab?> loadPrefab(String id) async {
    final dir = await _prefabDir;
    final file = File('${dir.path}/$id.json');
    if (!await file.exists()) return null;

    final content = await file.readAsString();
    return Prefab.fromJson(jsonDecode(content) as Map<String, dynamic>);
  }

  /// Delete a prefab by ID.
  Future<void> deletePrefab(String id) async {
    final dir = await _prefabDir;
    final file = File('${dir.path}/$id.json');
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Export a prefab to a shareable JSON string.
  Future<String> exportPrefab(String id) async {
    final prefab = await loadPrefab(id);
    if (prefab == null) throw Exception('Prefab not found: $id');
    return const JsonEncoder.withIndent('  ').convert(prefab.toJson());
  }

  /// Import a prefab from a JSON string.
  Future<Prefab> importPrefab(String jsonString) async {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    // Assign a new ID to avoid conflicts
    final prefab = Prefab.fromJson({
      ...json,
      'id': _uuid.v4(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
    await _savePrefab(prefab);
    return prefab;
  }

  /// Instantiate a character from a prefab (new ID, not a template anymore).
  Character instantiateCharacter(Prefab prefab) {
    assert(prefab.type == PrefabType.character);
    final character = Character.fromJson(prefab.data);
    return character.copyWith(
      id: _uuid.v4(),
      isTemplate: false,
      createdAt: DateTime.now(),
    );
  }

  /// Instantiate an item from a prefab.
  GameItem instantiateItem(Prefab prefab) {
    assert(prefab.type == PrefabType.item);
    final item = GameItem.fromJson(prefab.data);
    return item.copyWith(
      id: _uuid.v4(),
      isTemplate: false,
      createdAt: DateTime.now(),
    );
  }

  /// Instantiate a location from a prefab.
  Location instantiateLocation(Prefab prefab) {
    assert(prefab.type == PrefabType.location);
    final location = Location.fromJson(prefab.data);
    return location.copyWith(
      id: _uuid.v4(),
      isTemplate: false,
      createdAt: DateTime.now(),
    );
  }

  /// Restore a full game state from a situation prefab.
  GameState? restoreSituation(Prefab prefab) {
    if (prefab.type != PrefabType.situation) return null;
    if (prefab.situationSnapshot == null) return null;
    return GameState.fromJson(prefab.situationSnapshot!);
  }

  // ── Private ──

  Future<void> _savePrefab(Prefab prefab) async {
    final dir = await _prefabDir;
    final file = File('${dir.path}/${prefab.id}.json');
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(prefab.toJson()),
    );
  }
}
