import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import 'paywall_screen.dart';

class ThemePickerScreen extends StatelessWidget {
  const ThemePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final state = context.watch<AppState>();
    final colors = AppColors.forPalette(state.palette);

    return AppColorsScope(
      colors: colors,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          title: const Text(l.settingsChooseTheme),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Layout',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.textSecondary)),
            const SizedBox(height: 10),
            ...HomeThemeId.values.map((theme) {
              final locked = theme.isPremium && !state.isPremium;
              final selected = state.selectedTheme == theme;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    if (locked) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const PaywallScreen()),
                      );
                    } else {
                      state.setSelectedTheme(theme);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(16),
                      border: selected
                          ? Border.all(color: colors.info, width: 1.5)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(theme.label,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: colors.textPrimary)),
                              if (theme == HomeThemeId.diario)
                                Text(l.themeFree,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: colors.textSecondary)),
                            ],
                          ),
                        ),
                        if (locked)
                          Icon(Icons.lock_outline,
                              size: 18, color: colors.warning)
                        else if (selected)
                          Icon(Icons.check_circle, color: colors.info)
                        else
                          Icon(Icons.chevron_right,
                              color: colors.textSecondary),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            Text(l.settingsColor,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.textSecondary)),
            const SizedBox(height: 10),
            ...AppPaletteId.values.map((paletteId) {
              final locked = paletteId.isPremium && !state.isPremium;
              final selected = state.palette == paletteId;
              final previewColors = AppColors.forPalette(paletteId);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    if (locked) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const PaywallScreen()),
                      );
                    } else {
                      state.setPalette(paletteId);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(16),
                      border: selected
                          ? Border.all(color: colors.info, width: 1.5)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: previewColors.info,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(paletteId.label,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: colors.textPrimary)),
                              if (paletteId == AppPaletteId.blue)
                                Text(l.themeFree,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: colors.textSecondary)),
                            ],
                          ),
                        ),
                        if (locked)
                          Icon(Icons.lock_outline,
                              size: 18, color: colors.warning)
                        else if (selected)
                          Icon(Icons.check_circle, color: colors.info)
                        else
                          Icon(Icons.chevron_right,
                              color: colors.textSecondary),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
