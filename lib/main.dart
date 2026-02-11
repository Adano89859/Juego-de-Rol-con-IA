import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_master/features/game/screens/game_screen.dart';
import 'package:quest_master/features/settings/providers/settings_providers.dart';
import 'package:quest_master/shared/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: QuestMasterApp()));
}

class QuestMasterApp extends ConsumerWidget {
  const QuestMasterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Quest Master',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
      home: const GameScreen(),
    );
  }
}
