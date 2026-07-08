import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

/// Exibe um incentivo metabólico contextual durante uma sessão de jejum activo.
/// Não mostra nada se [elapsedMinutes] for inferior a 10 horas.
class MetabolicIncentive extends StatelessWidget {
  final int elapsedMinutes;
  final AppColors colors;

  const MetabolicIncentive({
    super.key,
    required this.elapsedMinutes,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final phase = _resolvePhase(l);
    if (phase == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        Divider(color: colors.info.withOpacity(0.25), thickness: 1),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(phase.icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    phase.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.info,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    phase.body,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.info,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  _Phase? _resolvePhase(AppLocalizations l) {
    if (elapsedMinutes >= 24 * 60) {
      return _Phase(
        icon: '🔥',
        title: l.metabolicPhase4Title,
        body: l.metabolicPhase4Body,
      );
    } else if (elapsedMinutes >= 16 * 60) {
      return _Phase(
        icon: '⚡',
        title: l.metabolicPhase3Title,
        body: l.metabolicPhase3Body,
      );
    } else if (elapsedMinutes >= 12 * 60) {
      return _Phase(
        icon: '✨',
        title: l.metabolicPhase2Title,
        body: l.metabolicPhase2Body,
      );
    } else if (elapsedMinutes >= 10 * 60) {
      return _Phase(
        icon: '💡',
        title: l.metabolicPhase1Title,
        body: l.metabolicPhase1Body,
      );
    }
    return null;
  }
}

class _Phase {
  final String icon;
  final String title;
  final String body;
  const _Phase({required this.icon, required this.title, required this.body});
}
