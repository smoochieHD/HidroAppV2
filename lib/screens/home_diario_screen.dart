import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/fasting_session.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/water_card.dart';

/// Tema "Diário": feed cronológico do dia, em vez de um cronómetro.
/// Tema gratuito por defeito da v1.
class HomeDiarioScreen extends StatefulWidget {
  const HomeDiarioScreen({super.key});

  @override
  State<HomeDiarioScreen> createState() => _HomeDiarioScreenState();
}

class _HomeDiarioScreenState extends State<HomeDiarioScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Atualiza o ecrã a cada minuto para que o tempo decorrido/restante
    // do jejum se mantenha correto sem precisar de reiniciar a app.
    _ticker = Timer.periodic(const Duration(seconds: 5), (_) {
      final appState = context.read<AppState>();
      appState.checkFastCompletion();
      appState.refreshFromStorage();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final colors = AppColorsScope.of(context);
    final session = state.activeSession;
    final lastSession = session ?? _lastFromHistory(state);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _greeting(),
                style: TextStyle(
                  fontSize: 13,
                  color: colors.textSecondary,
                ),
              ),
              IconButton(
                onPressed: () => context.read<AppState>().goToSettings(),
                icon: Icon(Icons.settings_outlined,
                    size: 20, color: colors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (session != null)
            _activeFastingCard(context, session)
          else
            _startFastingCard(context, state),
          const SizedBox(height: 12),
          _autoScheduleToggle(context, state),
          const SizedBox(height: 20),
          Text(
            'Hoje',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary),
          ),
          const SizedBox(height: 10),
          if (lastSession != null)
            _timelineItem(
              context: context,
              icon: Icons.check_circle,
              title: 'Jejum iniciado',
              subtitle: DateFormat("HH:mm 'de' dd/MM")
                  .format(lastSession.startTime),
            ),
          if (lastSession != null && lastSession.endTime != null) ...[
            const SizedBox(height: 8),
            _timelineItem(
              context: context,
              icon: Icons.flag_outlined,
              title: 'Fim de jejum',
              subtitle: DateFormat("HH:mm 'de' dd/MM")
                  .format(lastSession.endTime!),
            ),
          ],
          const SizedBox(height: 8),
          if (session != null)
            _timelineItem(
              context: context,
              icon: Icons.water_drop_outlined,
              title: '${(state.currentWaterMl / 250).round()} copos de água',
              subtitle: '${state.currentWaterMl}ml de ${state.waterGoalMl}ml',
              trailing: TextButton(
                onPressed: () => state.addWater(250),
                child: const Text('+ copo'),
              ),
            )
          else if (lastSession != null)
            _timelineItem(
              context: context,
              icon: Icons.water_drop_outlined,
              title:
                  '${(lastSession.waterMl / 250).round()} copos de água (resumo)',
              subtitle:
                  '${lastSession.waterMl}ml de ${state.waterGoalMl}ml neste ciclo',
            ),
          const SizedBox(height: 8),
          if (session != null)
            _timelineItem(
              context: context,
              icon: Icons.schedule,
              title: 'Janela de alimentação',
              subtitle:
                  'Começa às ${DateFormat.Hm().format(session.plannedEndTime)}',
              dashed: true,
              muted: true,
            ),
          const SizedBox(height: 20),
          const WaterCard(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _autoScheduleToggle(BuildContext context, AppState state) {
    final colors = AppColorsScope.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Agendar ciclo automaticamente',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary),
            ),
          ),
          Switch(
            value: state.autoScheduleNextCycle,
            onChanged: (v) => state.setAutoScheduleNextCycle(v),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 19) return 'Boa tarde';
    return 'Boa noite';
  }

  /// Última sessão de jejum conhecida: a ativa, se houver, ou a mais
  /// recente do histórico — para "Jejum iniciado"/"Fim de jejum"
  /// continuarem visíveis mesmo depois do jejum terminar.
  FastingSession? _lastFromHistory(AppState state) {
    final history = state.history;
    if (history.isEmpty) return null;
    return history.reduce(
      (a, b) => a.startTime.isAfter(b.startTime) ? a : b,
    );
  }

  Widget _activeFastingCard(BuildContext context, FastingSession session) {
    final colors = AppColorsScope.of(context);
    final isOver = session.goalReached;
    final rounded = session.remainingRounded;
    final hours = rounded.inHours;
    final minutes = rounded.inMinutes % 60;
    final elapsedMinutes = session.elapsed.inMinutes;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.infoBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isOver ? 'Meta atingida' : 'A meio do jejum',
            style: TextStyle(fontSize: 12, color: colors.info),
          ),
          const SizedBox(height: 4),
          Text(
            isOver
                ? 'Há mais $hours h $minutes min'
                : 'Faltam $hours h $minutes min',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colors.info,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Janela termina às ${DateFormat.Hm().format(session.plannedEndTime)}',
            style: TextStyle(fontSize: 12, color: colors.info),
          ),
          ..._metabolicIncentive(elapsedMinutes, colors),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _confirmEndFasting(context),
              child: const Text('Terminar jejum agora'),
            ),
          ),
        ],
      ),
    );
  }

  /// Devolve um incentivo metabólico baseado nos minutos de jejum decorridos.
  /// Vazio se ainda não tiver atingido os 12h mínimos para ser relevante.
  List<Widget> _metabolicIncentive(int elapsedMinutes, AppColors colors) {
    String? icon;
    String? title;
    String? body;

    if (elapsedMinutes >= 24 * 60) {
      // ≥ 24 horas
      icon = '🔥';
      title = 'Cetose activa';
      body =
          'O fígado está a produzir cetonas a partir da gordura armazenada — a sua principal fonte de energia agora é a gordura pura.';
    } else if (elapsedMinutes >= 16 * 60) {
      // ≥ 16 horas
      icon = '⚡';
      title = 'Lipólise em pleno';
      body =
          'O seu corpo está a quebrar activamente a gordura armazenada em ácidos gordos para usar como energia.';
    } else if (elapsedMinutes >= 12 * 60) {
      // ≥ 12 horas
      icon = '✨';
      title = 'Glicogénio a esgotar-se';
      body =
          'As reservas de glicogénio estão a diminuir e o corpo começa a transitar para a queima de gordura. Continue — está quase!';
    } else if (elapsedMinutes >= 10 * 60) {
      // ≥ 10 horas (aviso antecipado)
      icon = '💡';
      title = 'A 2 horas de queimar gordura';
      body =
          'Se continuar mais 2 horas, o seu corpo inicia a transição para usar a gordura como fonte de energia.';
    }

    if (icon == null) return [];

    return [
      const SizedBox(height: 14),
      Divider(color: colors.info.withOpacity(0.25), thickness: 1),
      const SizedBox(height: 10),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colors.info,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body!,
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
    ];
  }

  Widget _startFastingCard(BuildContext context, AppState state) {
    final colors = AppColorsScope.of(context);
    final scheduled = state.scheduledNextFastTime;

    if (scheduled != null) {
      final remaining = scheduled.difference(DateTime.now());
      final h = remaining.inHours;
      final m = remaining.inMinutes % 60;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Próximo jejum agendado',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              remaining.isNegative
                  ? 'A começar...'
                  : 'Daqui a ${h}h ${m}min',
              style: TextStyle(fontSize: 12, color: colors.textSecondary),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => state.startFasting(),
                child: const Text('Iniciar agora'),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sem jejum ativo',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Protocolo definido: ${formatDurationMinutes(state.defaultProtocolMinutes)}',
            style: TextStyle(fontSize: 12, color: colors.textSecondary),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => state.startFasting(),
              child: const Text('Iniciar jejum'),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmEndFasting(BuildContext context) {
    final state = context.read<AppState>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Terminar jejum?'),
        content: const Text('Isto regista o fim da sessão atual.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              state.endFasting();
              Navigator.of(ctx).pop();
            },
            child: const Text('Terminar'),
          ),
        ],
      ),
    );
  }

  Widget _timelineItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    bool dashed = false,
    bool muted = false,
  }) {
    final colors = AppColorsScope.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: muted ? Colors.transparent : colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: dashed ? Border.all(color: colors.borderTertiary) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: muted
                  ? colors.backgroundSecondary
                  : colors.infoBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 14,
              color: muted ? colors.textSecondary : colors.info,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: muted
                        ? colors.textSecondary
                        : colors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: colors.textSecondary),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
