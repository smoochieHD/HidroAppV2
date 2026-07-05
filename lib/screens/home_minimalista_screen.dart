import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/fasting_session.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/metabolic_incentive.dart';
import '../widgets/water_card.dart';
import '../widgets/today_water_row.dart';

/// Tema "Minimalista": números grandes em destaque, barra de progresso com
/// marcas de hora e dois cards de resumo rápido. Tema premium.
class HomeMinimalistaScreen extends StatefulWidget {
  const HomeMinimalistaScreen({super.key});

  @override
  State<HomeMinimalistaScreen> createState() => _HomeMinimalistaScreenState();
}

class _HomeMinimalistaScreenState extends State<HomeMinimalistaScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
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
    final progress = session?.progress ?? 0.0;
    final elapsed = session?.elapsed.inMinutes ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _greeting(),
                style: TextStyle(fontSize: 13, color: colors.textSecondary),
              ),
              IconButton(
                onPressed: () => context.read<AppState>().goToSettings(),
                icon: Icon(Icons.settings_outlined,
                    size: 20, color: colors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Estado em texto pequeno
          Text(
            session != null
                ? (session.goalReached ? 'Meta atingida' : 'Em jejum')
                : 'Sem jejum ativo',
            style: TextStyle(fontSize: 13, color: colors.textSecondary),
          ),
          const SizedBox(height: 2),

          // Número grande: tempo restante
          Text(
            session != null ? _formatRemaining(session) : '--h --m',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            session != null ? 'restante · ${_formatElapsed(session)} decorridos' : '',
            style: TextStyle(fontSize: 12, color: colors.textSecondary),
          ),
          const SizedBox(height: 20),

          // Barra de progresso com marcas de hora
          if (session != null) _progressBar(session, progress, colors),
          const SizedBox(height: 20),

          // Cards de resumo rápido (apenas com sessão activa)
          if (session != null) ...[
            _summaryCards(context, state, session, colors),
            const SizedBox(height: 20),
          ],

          // Botão principal
          SizedBox(
            width: double.infinity,
            child: session != null
                ? ElevatedButton(
                    onPressed: () => state.endFasting(),
                    child: const Text('Terminar jejum'),
                  )
                : ElevatedButton(
                    onPressed: () => state.startFasting(),
                    child: const Text('Iniciar jejum'),
                  ),
          ),

          // Incentivo metabólico
          if (session != null)
            MetabolicIncentive(
              elapsedMinutes: elapsed,
              colors: colors,
            ),

          const SizedBox(height: 20),

          // Toggle agendamento automático
          _autoScheduleToggle(context, state),
          const SizedBox(height: 12),

          // Secção Hoje
          Text('Hoje',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary)),
          const SizedBox(height: 10),
          if (_lastSession(state) != null) ...[
            ..._lastSessionRows(context, _lastSession(state)!),
            const SizedBox(height: 8),
          ],
          if (session != null)
            const TodayWaterRow()
          else if (_lastSession(state) != null)
            _waterSummaryRow(context, state, _lastSession(state)!),
          const SizedBox(height: 8),
          const WaterCard(),
        ],
      ),
    );
  }

  /// Barra de progresso horizontal com marcas de hora visíveis
  Widget _progressBar(
      FastingSession session, double progress, AppColors colors) {
    final goalHours = session.goalDuration.inHours;
    // Marcas a mostrar: divide o total em 4 intervalos
    final interval = (goalHours / 4).round().clamp(1, 999);
    final marks = <int>[];
    for (int h = 0; h <= goalHours; h += interval) {
      marks.add(h);
    }
    if (marks.last != goalHours) marks.add(goalHours);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barra
        Container(
          height: 10,
          decoration: BoxDecoration(
            color: colors.borderTertiary,
            borderRadius: BorderRadius.circular(5),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: colors.info,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Marcas de hora
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: marks
              .map((h) => Text('${h}h',
                  style:
                      TextStyle(fontSize: 10, color: colors.textSecondary)))
              .toList(),
        ),
        const SizedBox(height: 4),
        // Legenda início / fim
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Início · ${DateFormat.Hm().format(session.startTime)}',
              style: TextStyle(fontSize: 11, color: colors.textSecondary),
            ),
            Text(
              'Termina · ${DateFormat.Hm().format(session.plannedEndTime)}',
              style: TextStyle(fontSize: 11, color: colors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  /// Dois cards de resumo rápido: água e hora de fim
  Widget _summaryCards(BuildContext context, AppState state,
      FastingSession session, AppColors colors) {
    final waterMl = state.currentWaterMl;
    final waterGoal = state.waterGoalMl;
    final endTime = DateFormat.Hm().format(session.plannedEndTime);

    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            colors: colors,
            icon: Icons.water_drop_outlined,
            value: '${waterMl}ml',
            label: 'de ${waterGoal}ml de água',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            colors: colors,
            icon: Icons.flag_outlined,
            value: endTime,
            label: 'janela termina',
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required AppColors colors,
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: colors.info),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary)),
          const SizedBox(height: 2),
          Text(label,
              style:
                  TextStyle(fontSize: 11, color: colors.textSecondary)),
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

  Widget _waterSummaryRow(
      BuildContext context, AppState state, FastingSession session) {
    return _infoRow(
      context,
      Icons.water_drop_outlined,
      '${(session.waterMl / 250).round()} copos de água (resumo)',
      '${session.waterMl}ml de ${state.waterGoalMl}ml neste ciclo',
    );
  }

  FastingSession? _lastSession(AppState state) {
    if (state.activeSession != null) return null;
    final history = state.history;
    if (history.isEmpty) return null;
    return history.reduce(
      (a, b) => a.startTime.isAfter(b.startTime) ? a : b,
    );
  }

  List<Widget> _lastSessionRows(BuildContext context, FastingSession session) {
    return [
      _infoRow(context, Icons.check_circle, 'Jejum iniciado',
          DateFormat("HH:mm 'de' dd/MM").format(session.startTime)),
      if (session.endTime != null) ...[
        const SizedBox(height: 8),
        _infoRow(context, Icons.flag_outlined, 'Fim de jejum',
            DateFormat("HH:mm 'de' dd/MM").format(session.endTime!)),
      ],
    ];
  }

  Widget _infoRow(
      BuildContext context, IconData icon, String title, String subtitle) {
    final colors = AppColorsScope.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: colors.infoBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: colors.info),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary)),
                Text(subtitle,
                    style:
                        TextStyle(fontSize: 11, color: colors.textSecondary)),
              ],
            ),
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

  String _formatRemaining(FastingSession session) {
    final r = session.remainingRounded;
    return '${r.inHours}h ${r.inMinutes % 60}m';
  }

  String _formatElapsed(FastingSession session) {
    final e = session.elapsed;
    return '${e.inHours}h ${e.inMinutes % 60}m';
  }
}
