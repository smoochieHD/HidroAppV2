import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Exibe um incentivo metabólico contextual durante uma sessão de jejum activo.
///
/// Não mostra nada se [elapsedMinutes] for inferior a 10 horas.
/// A partir daí, o texto evolui automaticamente pelas fases:
///   ≥ 10 h → aviso antecipado (faltam 2 h para iniciar a queima de gordura)
///   ≥ 12 h → glicogénio a esgotar-se, transição para queima de gordura
///   ≥ 16 h → lipólise em pleno
///   ≥ 24 h → cetose activa
///
/// Usa [colors] recebido externamente para seguir qualquer paleta/tema.
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
    final phase = _resolvePhase();
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

  _Phase? _resolvePhase() {
    if (elapsedMinutes >= 24 * 60) {
      return const _Phase(
        icon: '🔥',
        title: 'Cetose activa',
        body:
            'O fígado está a produzir cetonas a partir da gordura armazenada — '
            'a sua principal fonte de energia agora é a gordura pura.',
      );
    } else if (elapsedMinutes >= 16 * 60) {
      return const _Phase(
        icon: '⚡',
        title: 'Lipólise em pleno',
        body:
            'O seu corpo está a quebrar activamente a gordura armazenada '
            'em ácidos gordos para usar como energia.',
      );
    } else if (elapsedMinutes >= 12 * 60) {
      return const _Phase(
        icon: '✨',
        title: 'Glicogénio a esgotar-se',
        body:
            'As reservas de glicogénio estão a diminuir e o corpo começa '
            'a transitar para a queima de gordura. Continue — está quase!',
      );
    } else if (elapsedMinutes >= 10 * 60) {
      return const _Phase(
        icon: '💡',
        title: 'A 2 horas de queimar gordura',
        body:
            'Se continuar mais 2 horas, o seu corpo inicia a transição '
            'para usar a gordura como fonte de energia.',
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
