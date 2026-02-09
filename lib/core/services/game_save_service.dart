import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:quest_master/core/models/models.dart';

/// Service for saving and loading game state to/from disk.
class GameSaveService {
  Directory? _saveDir;

  Future<Directory> get _savePath async {
    if (_saveDir != null) return _saveDir!;
    final appDir = await getApplicationDocumentsDirectory();
    _saveDir = Directory('${appDir.path}/quest_master/saves');
    if (!await _saveDir!.exists()) {
      await _saveDir!.create(recursive: true);
    }
    return _saveDir!;
  }

  /// Save current game state.
  Future<void> saveGame(GameState state, {String slot = 'autosave'}) async {
    final dir = await _savePath;
    final file = File('${dir.path}/$slot.json');
    final json = const JsonEncoder.withIndent('  ').convert(state.toJson());
    await file.writeAsString(json);
  }

  /// Load a saved game state.
  Future<GameState?> loadGame({String slot = 'autosave'}) async {
    final dir = await _savePath;
    final file = File('${dir.path}/$slot.json');
    if (!await file.exists()) return null;

    final content = await file.readAsString();
    return GameState.fromJson(jsonDecode(content) as Map<String, dynamic>);
  }

  /// List all save slots.
  Future<List<String>> listSaves() async {
    final dir = await _savePath;
    if (!await dir.exists()) return [];

    final saves = <String>[];
    await for (final entity in dir.list()) {
      if (entity is File && entity.path.endsWith('.json')) {
        final name = entity.path.split('/').last.replaceAll('.json', '');
        saves.add(name);
      }
    }
    return saves;
  }

  /// Delete a save slot.
  Future<void> deleteSave(String slot) async {
    final dir = await _savePath;
    final file = File('${dir.path}/$slot.json');
    if (await file.exists()) {
      await file.delete();
    }
  }
}
