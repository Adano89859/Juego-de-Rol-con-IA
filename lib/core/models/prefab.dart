import 'package:equatable/equatable.dart';

/// Types of saveable prefabs/templates.
enum PrefabType {
  situation,
  character,
  item,
  enemy,
  location,
  climate,
}

/// A reusable template that can be saved and loaded into any game session.
///
/// Prefabs store a snapshot of any game entity or situation, allowing
/// players to reuse them across different playthroughs.
class Prefab extends Equatable {
  final String id;
  final String name;
  final PrefabType type;
  final String? description;

  /// The serialized entity data (character JSON, item JSON, etc.)
  final Map<String, dynamic> data;

  /// For situations: the full game state snapshot
  final Map<String, dynamic>? situationSnapshot;

  /// Version for forward compatibility when schema changes
  final int schemaVersion;

  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;

  const Prefab({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    required this.data,
    this.situationSnapshot,
    this.schemaVersion = 1,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
  });

  Prefab copyWith({
    String? name,
    String? description,
    Map<String, dynamic>? data,
    Map<String, dynamic>? situationSnapshot,
    DateTime? updatedAt,
    List<String>? tags,
  }) {
    return Prefab(
      id: id,
      name: name ?? this.name,
      type: type,
      description: description ?? this.description,
      data: data ?? this.data,
      situationSnapshot: situationSnapshot ?? this.situationSnapshot,
      schemaVersion: schemaVersion,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'description': description,
        'data': data,
        'situationSnapshot': situationSnapshot,
        'schemaVersion': schemaVersion,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'tags': tags,
      };

  factory Prefab.fromJson(Map<String, dynamic> json) => Prefab(
        id: json['id'] as String,
        name: json['name'] as String,
        type: PrefabType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => PrefabType.situation,
        ),
        description: json['description'] as String?,
        data: json['data'] as Map<String, dynamic>,
        situationSnapshot:
            json['situationSnapshot'] as Map<String, dynamic>?,
        schemaVersion: json['schemaVersion'] as int? ?? 1,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      );

  @override
  List<Object?> get props => [id];
}
