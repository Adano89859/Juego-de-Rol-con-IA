class ChatMessage {
  final String text;
  final bool isPlayer;
  final bool isSystem;

  ChatMessage({
    required this.text,
    required this.isPlayer,
    this.isSystem = false,
  });
}