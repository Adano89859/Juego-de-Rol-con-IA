import 'package:equatable/equatable.dart';

/// Represents a region in the game world.
///
/// Regions provide consistency to the world and help the AI maintain
/// coherent geography and culture.
class Region extends Equatable {
  final String id;
  final String name;
  final String description;
  
  /// Climate of the region (e.g., "temperate", "desert", "tundra")
  final String climate;
  
  /// Cultural traits (e.g., "trading hub", "militaristic", "scholarly")
  final String culture;
  
  /// IDs of regions that border this one
  final List<String> connectedRegions;
  
  /// Notable locations in this region
  final List<String> notableLocationIds;
  
  /// General danger level (1-10)
  final int dangerLevel;
  
  /// Dominant race/species if applicable
  final String? dominantRace;
  
  /// Notable features
  final List<String> features;
  
  final DateTime createdAt;
  final Map<String, dynamic> customData;

  const Region({
    required this.id,
    required this.name,
    required this.description,
    this.climate = 'temperate',
    this.culture = 'varied',
    this.connectedRegions = const [],
    this.notableLocationIds = const [],
    this.dangerLevel = 5,
    this.dominantRace,
    this.features = const [],
    required this.createdAt,
    this.customData = const {},
  });

  /// Compact representation for AI context
  String toContextString() {
    return '$name ($climate, $culture, peligro: $dangerLevel/10)';
  }

  Region copyWith({
    String? id,
    String? name,
    String? description,
    String? climate,
    String? culture,
    List<String>? connectedRegions,
    List<String>? notableLocationIds,
    int? dangerLevel,
    String? dominantRace,
    List<String>? features,
    DateTime? createdAt,
    Map<String, dynamic>? customData,
  }) {
    return Region(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      climate: climate ?? this.climate,
      culture: culture ?? this.culture,
      connectedRegions: connectedRegions ?? this.connectedRegions,
      notableLocationIds: notableLocationIds ?? this.notableLocationIds,
      dangerLevel: dangerLevel ?? this.dangerLevel,
      dominantRace: dominantRace ?? this.dominantRace,
      features: features ?? this.features,
      createdAt: createdAt ?? this.createdAt,
      customData: customData ?? this.customData,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'climate': climate,
        'culture': culture,
        'connectedRegions': connectedRegions,
        'notableLocationIds': notableLocationIds,
        'dangerLevel': dangerLevel,
        'dominantRace': dominantRace,
        'features': features,
        'createdAt': createdAt.toIso8601String(),
        'customData': customData,
      };

  factory Region.fromJson(Map<String, dynamic> json) => Region(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        climate: json['climate'] as String? ?? 'temperate',
        culture: json['culture'] as String? ?? 'varied',
        connectedRegions:
            (json['connectedRegions'] as List<dynamic>?)?.cast<String>() ?? [],
        notableLocationIds: (json['notableLocationIds'] as List<dynamic>?)
                ?.cast<String>() ??
            [],
        dangerLevel: json['dangerLevel'] as int? ?? 5,
        dominantRace: json['dominantRace'] as String?,
        features: (json['features'] as List<dynamic>?)?.cast<String>() ?? [],
        createdAt: DateTime.parse(json['createdAt'] as String),
        customData: (json['customData'] as Map<String, dynamic>?) ?? {},
      );

  @override
  List<Object?> get props => [id];
}
