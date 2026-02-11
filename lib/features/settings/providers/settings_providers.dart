import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Settings state.
class AppSettings {
  final String ollamaUrl;
  final String ollamaModel;
  final bool useMockAI;
  final bool darkMode;
  final int maxContextTokens;

  const AppSettings({
    this.ollamaUrl = 'http://localhost:11434',
    this.ollamaModel = 'llama3.2',
    this.useMockAI = true,
    this.darkMode = true,
    this.maxContextTokens = 1500,
  });

  AppSettings copyWith({
    String? ollamaUrl,
    String? ollamaModel,
    bool? useMockAI,
    bool? darkMode,
    int? maxContextTokens,
  }) {
    return AppSettings(
      ollamaUrl: ollamaUrl ?? this.ollamaUrl,
      ollamaModel: ollamaModel ?? this.ollamaModel,
      useMockAI: useMockAI ?? this.useMockAI,
      darkMode: darkMode ?? this.darkMode,
      maxContextTokens: maxContextTokens ?? this.maxContextTokens,
    );
  }
}

/// Settings provider with persistence.
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      ollamaUrl: prefs.getString('ollamaUrl') ?? 'http://localhost:11434',
      ollamaModel: prefs.getString('ollamaModel') ?? 'llama3.2',
      useMockAI: prefs.getBool('useMockAI') ?? true,
      darkMode: prefs.getBool('darkMode') ?? true,
      maxContextTokens: prefs.getInt('maxContextTokens') ?? 1500,
    );
  }

  Future<void> updateOllamaUrl(String url) async {
    state = state.copyWith(ollamaUrl: url);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ollamaUrl', url);
  }

  Future<void> updateOllamaModel(String model) async {
    state = state.copyWith(ollamaModel: model);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ollamaModel', model);
  }

  Future<void> toggleMockAI() async {
    state = state.copyWith(useMockAI: !state.useMockAI);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useMockAI', state.useMockAI);
  }

  Future<void> toggleDarkMode() async {
    state = state.copyWith(darkMode: !state.darkMode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', state.darkMode);
  }

  Future<void> updateMaxTokens(int tokens) async {
    state = state.copyWith(maxContextTokens: tokens);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('maxContextTokens', tokens);
  }
}
