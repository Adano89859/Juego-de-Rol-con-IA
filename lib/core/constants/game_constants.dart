/// Core constants for Quest Master game configuration.
/// Tuned for Ollama local model constraints.
class GameConstants {
  GameConstants._();

  // ── Context Window Management (CRITICAL for Ollama) ──
  static const int maxContextTokens = 1500;
  static const int systemInstructionBudget = 200;
  static const int storySummaryBudget = 150;
  static const int keyFactsBudget = 100;
  static const int recentEventsBudget = 400;
  static const int currentStateBudget = 150;
  static const int maxResponseTokens = 500;

  // ── Event History ──
  static const int recentEventsCount = 10;
  static const int summarizationThreshold = 25;
  static const int maxKeyFacts = 15;

  // ── Character Stats Defaults ──
  static const int defaultHealth = 100;
  static const int defaultMaxHealth = 100;
  static const int defaultAttack = 10;
  static const int defaultDefense = 5;
  static const int defaultSpeed = 10;
  static const int defaultLuck = 5;
  static const int defaultMana = 50;
  static const int defaultMaxMana = 50;

  // ── Token Estimation ──
  static const double charsPerToken = 4.0;

  static int estimateTokens(String text) {
    return (text.length / charsPerToken).ceil();
  }
}
