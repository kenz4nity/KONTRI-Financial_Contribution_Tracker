import 'package:flutter/material.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;

import 'data/contribution_repository.dart';
import 'data/isar_service.dart';
import 'screens/dashboard_screen.dart';
import 'services/proof_storage.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tzdata.initializeTimeZones();

  // Resolve the proof directory before the first frame so widgets can build image paths synchronously.
  await ProofStorage.init();

  // Opens the existing database in place.
  final isar = await IsarService.open();

  runApp(KontriApp(repository: ContributionRepository(isar)));
}

class KontriApp extends StatefulWidget {
  const KontriApp({super.key, required this.repository});

  final ContributionRepository repository;

  @override
  State<KontriApp> createState() => _KontriAppState();
}

class _KontriAppState extends State<KontriApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kontri',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: buildKontriTheme(Brightness.light),
      darkTheme: buildKontriTheme(Brightness.dark),
      home: DashboardScreen(
        repository: widget.repository,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}
