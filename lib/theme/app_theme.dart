import 'package:flutter/material.dart';

/// Identificadores das paletas de cor selecionáveis pelo utilizador.
enum AppPaletteId { blue, green, terracotta, violet, charcoal }

extension AppPaletteIdX on AppPaletteId {
  String get id {
    switch (this) {
      case AppPaletteId.blue:
        return 'blue';
      case AppPaletteId.green:
        return 'green';
      case AppPaletteId.terracotta:
        return 'terracotta';
      case AppPaletteId.violet:
        return 'violet';
      case AppPaletteId.charcoal:
        return 'charcoal';
    }
  }

  String get label {
    switch (this) {
      case AppPaletteId.blue:
        return 'Azul';
      case AppPaletteId.green:
        return 'Verde-jade';
      case AppPaletteId.terracotta:
        return 'Terracota';
      case AppPaletteId.violet:
        return 'Violeta';
      case AppPaletteId.charcoal:
        return 'Carvão';
    }
  }

  /// Apenas a paleta azul (a original) é gratuita.
  bool get isPremium => this != AppPaletteId.blue;

  static AppPaletteId fromId(String id) {
    switch (id) {
      case 'green':
        return AppPaletteId.green;
      case 'terracotta':
        return AppPaletteId.terracotta;
      case 'violet':
        return AppPaletteId.violet;
      case 'charcoal':
        return AppPaletteId.charcoal;
      default:
        return AppPaletteId.blue;
    }
  }
}

/// Conjunto de cores de uma paleta. Substitui o antigo AppColors estático
/// — todos os ecrãs passam a ler as cores daqui (via Theme.of(context) ou
/// de uma instância obtida a partir de AppState.palette), em vez de
/// constantes fixas, para suportar troca de paleta em tempo real.
class AppColors {
  final bool isDark;
  final Color background;
  final Color backgroundSecondary;
  final Color textPrimary;
  final Color textSecondary;
  final Color borderTertiary;
  final Color info;
  final Color infoBackground;
  final Color teal;
  final Color tealBackground;
  final Color warning;
  final Color warningBackground;

  const AppColors({
    required this.isDark,
    required this.background,
    required this.backgroundSecondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.borderTertiary,
    required this.info,
    required this.infoBackground,
    required this.teal,
    required this.tealBackground,
    required this.warning,
    required this.warningBackground,
  });

  /// Paleta clara (azul, verde, terracota, violeta) partilham a mesma
  /// estrutura de fundo/texto, só a cor de destaque ("info") muda.
  factory AppColors.light({
    required Color accent,
    required Color accentBackground,
  }) {
    return AppColors(
      isDark: false,
      background: const Color(0xFFFFFFFF),
      backgroundSecondary: const Color(0xFFF5F6F8),
      textPrimary: const Color(0xFF1A1D1F),
      textSecondary: const Color(0xFF6F7780),
      borderTertiary: const Color(0xFFE5E7EA),
      info: accent,
      infoBackground: accentBackground,
      teal: const Color(0xFF2F8F84),
      tealBackground: const Color(0xFFE6F3F1),
      warning: const Color(0xFFB8860B),
      warningBackground: const Color(0xFFFBF1DC),
    );
  }

  /// Paleta "Carvão": modo escuro de verdade (fundo escuro, texto claro).
  factory AppColors.charcoal() {
    return const AppColors(
      isDark: true,
      background: Color(0xFF1A1B1E),
      backgroundSecondary: Color(0xFF26282C),
      textPrimary: Color(0xFFF2F2F2),
      textSecondary: Color(0xFFA8ABB1),
      borderTertiary: Color(0xFF36383D),
      info: Color(0xFF6FA8DC),
      infoBackground: Color(0xFF2D3A47),
      teal: Color(0xFF5AC8B0),
      tealBackground: Color(0xFF1F3A35),
      warning: Color(0xFFE0B85C),
      warningBackground: Color(0xFF3E3420),
    );
  }

  static AppColors forPalette(AppPaletteId id) {
    switch (id) {
      case AppPaletteId.blue:
        return AppColors.light(
          accent: const Color(0xFF378ADD),
          accentBackground: const Color(0xFFE6F1FB),
        );
      case AppPaletteId.green:
        return AppColors.light(
          accent: const Color(0xFF1D9E75),
          accentBackground: const Color(0xFFE1F5EE),
        );
      case AppPaletteId.terracotta:
        return AppColors.light(
          accent: const Color(0xFFD85A30),
          accentBackground: const Color(0xFFFAECE7),
        );
      case AppPaletteId.violet:
        return AppColors.light(
          accent: const Color(0xFF534AB7),
          accentBackground: const Color(0xFFEEEDFE),
        );
      case AppPaletteId.charcoal:
        return AppColors.charcoal();
    }
  }
}

/// InheritedWidget simples que disponibiliza a paleta atual a toda a
/// árvore de widgets, sem precisar de Provider extra — basta
/// AppColorsScope.of(context) em qualquer ecrã.
class AppColorsScope extends InheritedWidget {
  final AppColors colors;

  const AppColorsScope({
    super.key,
    required this.colors,
    required super.child,
  });

  static AppColors of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppColorsScope>();
    assert(scope != null, 'AppColorsScope não encontrado na árvore de widgets.');
    return scope!.colors;
  }

  @override
  bool updateShouldNotify(AppColorsScope oldWidget) =>
      oldWidget.colors != colors;
}

class AppTheme {
  static ThemeData light(AppColors colors) {
    return ThemeData(
      useMaterial3: true,
      brightness: colors.isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.info,
        brightness: colors.isDark ? Brightness.dark : Brightness.light,
        primary: colors.info,
        surface: colors.background,
      ),
      fontFamily: 'Roboto',
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: colors.textPrimary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: colors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      iconTheme: IconThemeData(color: colors.textPrimary),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
      ),
      listTileTheme: ListTileThemeData(
        textColor: colors.textPrimary,
        iconColor: colors.textSecondary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.infoBackground,
          foregroundColor: colors.info,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textPrimary,
          side: BorderSide(color: colors.borderTertiary),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.info,
        ),
      ),
    );
  }
}

/// Identificadores dos três temas visuais do ecrã principal.
enum HomeThemeId { diario, relogio, linhaDoTempo, chama, minimalista }

extension HomeThemeIdX on HomeThemeId {
  String get id {
    switch (this) {
      case HomeThemeId.diario:
        return 'diario';
      case HomeThemeId.relogio:
        return 'relogio';
      case HomeThemeId.linhaDoTempo:
        return 'linha_do_tempo';
      case HomeThemeId.chama:
        return 'chama';
      case HomeThemeId.minimalista:
        return 'minimalista';
    }
  }

  String get label {
    switch (this) {
      case HomeThemeId.diario:
        return 'Diário';
      case HomeThemeId.relogio:
        return 'Relógio';
      case HomeThemeId.linhaDoTempo:
        return 'Linha do tempo';
      case HomeThemeId.chama:
        return 'Chama';
      case HomeThemeId.minimalista:
        return 'Minimalista';
    }
  }

  bool get isPremium => this != HomeThemeId.diario;

  static HomeThemeId fromId(String id) {
    switch (id) {
      case 'relogio':
        return HomeThemeId.relogio;
      case 'linha_do_tempo':
        return HomeThemeId.linhaDoTempo;
      case 'chama':
        return HomeThemeId.chama;
      case 'minimalista':
        return HomeThemeId.minimalista;
      default:
        return HomeThemeId.diario;
    }
  }
}
