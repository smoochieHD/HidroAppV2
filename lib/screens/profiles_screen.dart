import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../models/fasting_session.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class ProfilesScreen extends StatelessWidget {
  const ProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final state = context.watch<AppState>();
    final colors = AppColors.forPalette(state.palette);

    return AppColorsScope(
      colors: colors,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(title: const Text(l.profilesFasting)),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.settingsCurrent,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textPrimary)),
                          const SizedBox(height: 2),
                          Text(
                            '${formatDurationMinutes(state.defaultProtocolMinutes)} jejum · '
                            '${formatDurationMinutes(state.eatingWindowMinutes)} comer · '
                            '${(state.waterGoalMl / 1000).toStringAsFixed(1)}L água',
                            style: TextStyle(
                                fontSize: 11, color: colors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showSaveDialog(context, state),
                      child: const Text(l.profilesSave),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(l.profilesMy,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary)),
              const SizedBox(height: 10),
              if (state.profiles.isEmpty)
                Text(
                  'Ainda não guardaste nenhum perfil. Ajusta as definições '
                  'que quiseres e toca em "Guardar como perfil".',
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: state.profiles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final profile = state.profiles[index];
                      final isActive = state.activeProfileId == profile.id;
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colors.backgroundSecondary,
                          borderRadius: BorderRadius.circular(14),
                          border: isActive
                              ? Border.all(color: colors.info, width: 1.5)
                              : null,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(profile.name,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: colors.textPrimary)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${formatDurationMinutes(profile.protocolMinutes)} jejum · '
                                    '${formatDurationMinutes(profile.eatingWindowMinutes)} comer · '
                                    '${(profile.waterGoalMl / 1000).toStringAsFixed(1)}L',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: colors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            if (!isActive)
                              TextButton(
                                onPressed: () => state.applyProfile(profile.id),
                                child: const Text(l.use),
                              )
                            else
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(Icons.check_circle,
                                    color: colors.info, size: 20),
                              ),
                            IconButton(
                              onPressed: () =>
                                  _confirmDelete(context, state, profile.id),
                              icon: Icon(Icons.delete_outline,
                                  size: 18, color: colors.textSecondary),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSaveDialog(BuildContext context, AppState state) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(l.profilesSaveAction),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: l.profilesExampleName,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(l.cancel),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              state.saveCurrentAsProfile(name);
              Navigator.of(ctx).pop();
            },
            child: const Text(l.save),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppState state, String profileId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(l.profilesRemove),
        content: const Text(l.actionIrreversible),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(l.cancel),
          ),
          TextButton(
            onPressed: () {
              state.deleteProfile(profileId);
              Navigator.of(ctx).pop();
            },
            child: const Text(l.remove),
          ),
        ],
      ),
    );
  }
}
