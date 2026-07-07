import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/app_state.dart';
import 'theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_PT');
  await initializeDateFormatting('en_US');
  final appState = await AppState.create();
  runApp(HidroApp(appState: appState));
}

class HidroApp extends StatefulWidget {
  final AppState appState;
  const HidroApp({super.key, required this.appState});

  @override
  State<HidroApp> createState() => _HidroAppState();
}

class _HidroAppState extends State<HidroApp> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onResume: () => widget.appState.checkScheduledNextFast(),
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.appState,
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          final colors = AppColors.forPalette(appState.palette);
          return MaterialApp(
            title: 'Hidro',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(colors),
            themeMode: colors.isDark ? ThemeMode.dark : ThemeMode.light,
            // ── Localizations ──────────────────────────────────────────
            locale: Locale(appState.languageCode),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: appState.storage.isOnboardingDone()
                ? const MainShell()
                : const OnboardingScreen(),
          );
        },
      ),
    );
  }
}
