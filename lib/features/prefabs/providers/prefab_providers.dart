import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_master/core/models/models.dart';
import 'package:quest_master/core/services/services.dart';

/// Prefab service provider.
final prefabServiceProvider = Provider<PrefabService>((ref) {
  return PrefabService();
});

/// All prefabs, optionally filtered by type.
final prefabListProvider = FutureProvider.family<List<Prefab>, PrefabType?>(
  (ref, type) async {
    final service = ref.watch(prefabServiceProvider);
    return service.loadPrefabs(type: type);
  },
);

/// All prefabs (unfiltered).
final allPrefabsProvider = FutureProvider<List<Prefab>>((ref) async {
  final service = ref.watch(prefabServiceProvider);
  return service.loadPrefabs();
});
