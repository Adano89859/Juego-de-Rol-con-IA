import 'package:firebase_database/firebase_database.dart';
import 'package:quest_master/core/models/models.dart';

class MultiplayerService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  // Create a new room
  Future<void> createRoom({
    required String roomCode,
    required Character hostCharacter,
  }) async {
    final roomRef = _database.ref('rooms/$roomCode');
    
    await roomRef.set({
      'host': {
        'name': hostCharacter.name,
        'characterClass': hostCharacter.characterClass,
        'backstory': hostCharacter.backstory,
        'appearance': hostCharacter.appearance,
        'personality': hostCharacter.personality,
        'currentAction': '',
        'submitted': false,
        'connected': true,
        'joinedAt': DateTime.now().toIso8601String(),
      },
      'guest': null,
      'gameData': null,
      'currentNarrative': null,
      'turnNumber': 0,
      'bothReady': false,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // Join an existing room
  Future<bool> joinRoom({
    required String roomCode,
    required Character guestCharacter,
  }) async {
    final roomRef = _database.ref('rooms/$roomCode');
    
    try {
      final snapshot = await roomRef.get();
      if (!snapshot.exists) {
        return false;
      }

      final data = snapshot.value as Map<dynamic, dynamic>;
      if (data['guest'] != null) {
        return false; // Room is full
      }

      await roomRef.child('guest').set({
        'name': guestCharacter.name,
        'characterClass': guestCharacter.characterClass,
        'backstory': guestCharacter.backstory,
        'appearance': guestCharacter.appearance,
        'personality': guestCharacter.personality,
        'currentAction': '',
        'submitted': false,
        'connected': true,
        'joinedAt': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error joining room: $e');
      return false;
    }
  }

  // Listen to room changes
  Stream<DatabaseEvent> listenToRoom(String roomCode) {
    return _database.ref('rooms/$roomCode').onValue;
  }

  // Save game data (only host)
  Future<void> saveGameData({
    required String roomCode,
    required String mainQuest,
    required String initialNarrative,
  }) async {
    await _database.ref('rooms/$roomCode/gameData').set({
      'mainQuest': mainQuest,
      'initialNarrative': initialNarrative,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // Get game data
  Future<Map<String, dynamic>?> getGameData(String roomCode) async {
    final snapshot = await _database.ref('rooms/$roomCode/gameData').get();
    if (!snapshot.exists) return null;
    return Map<String, dynamic>.from(snapshot.value as Map);
  }

  // Update player action (with typing indicator)
  Future<void> updatePlayerAction({
    required String roomCode,
    required bool isHost,
    required String action,
    required bool submitted,
  }) async {
    final playerPath = isHost ? 'host' : 'guest';
    final roomRef = _database.ref('rooms/$roomCode/$playerPath');
    
    await roomRef.update({
      'currentAction': action,
      'submitted': submitted,
    });
  }

  // Save AI narrative (only host)
  Future<void> saveNarrative({
    required String roomCode,
    required String hostAction,
    required String guestAction,
    required String narrative,
    required int turnNumber,
  }) async {
    await _database.ref('rooms/$roomCode/currentNarrative').set({
      'hostAction': hostAction,
      'guestAction': guestAction,
      'narrative': narrative,
      'turnNumber': turnNumber,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Listen to narrative updates
  Stream<DatabaseEvent> listenToNarrative(String roomCode) {
    return _database.ref('rooms/$roomCode/currentNarrative').onValue;
  }

  // Reset turn (after AI processes both actions)
  Future<void> resetTurn(String roomCode) async {
    final roomRef = _database.ref('rooms/$roomCode');
    
    await roomRef.update({
      'host/submitted': false,
      'host/currentAction': '',
      'guest/submitted': false,
      'guest/currentAction': '',
      'bothReady': false,
    });
  }

  // Delete room
  Future<void> deleteRoom(String roomCode) async {
    await _database.ref('rooms/$roomCode').remove();
  }

  // Set connected status
  Future<void> setConnected({
    required String roomCode,
    required bool isHost,
    required bool connected,
  }) async {
    final playerPath = isHost ? 'host' : 'guest';
    await _database.ref('rooms/$roomCode/$playerPath/connected').set(connected);
  }
}