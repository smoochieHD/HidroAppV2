import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/fasting_session.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/metabolic_incentive.dart';
import '../widgets/today_water_row.dart';
import '../widgets/water_card.dart';

/// Tema "Minimalista": fundo escuro permanente, número grande em destaque,
/// barra de progresso com marcas de hora e cards de resumo. Tema premium.
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
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      final appState = context.read<AppState>();
      appState.checkFastCompletion();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  // Paleta dark fixa — independente da paleta de cores do utilizador
  static const _bg = Color(0xFF111111);
  static const _card = Color(0xFF1A1A1A);
  static const _textPrimary = Color(0xFFEEEEEE);
  static const _textSecondary = Color(0xFF555555);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final colors = AppColorsScope.of(context); // para cores de acento (info)
    final session = state.activeSession;
    final lastSession = session ?? _lastSession(state);

    return Container(
      color: _bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_greeting(),
                    style: const TextStyle(
                        fontSize: 13, color: _textSecondary)),
                IconButton(
                  onPressed: () => state.goToSettings(),
                  icon: const Icon(Icons.settings_outlined,
                      size: 20, color: _textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Estado em texto pequeno
            Text(
              session != null
                  ? (session.goalReached ? 'Meta atingida' : 'Em jejum')
                  : 'Sem jejum activo',
              style:
                  const TextStyle(fontSize: 13, color: _textSecondary),
            ),
            const SizedBox(height: 2),

            // Número grande: tempo restante
            Text(
              session != null ? _formatRemaining(session) : '--h --m',
              style: const TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              session != null
                  ? '${_formatElapsed(session)} decorridos · meta ${session.goalDuration.inHours}h'
                  : '',
              style:
                  const TextStyle(fontSize: 12, color: _textSecondary),
            ),
            const SizedBox(height: 20),

            // Barra de progresso com marcas de hora
            if (session != null) ...[
              _progressBar(session, colors),
              const SizedBox(height: 16),

              // Cards de resumo: água + hora de fim
              _summaryCards(state, session, colors),
              const SizedBox(height: 16),
            ],

            // Botão principal
            SizedBox(
              width: double.infinity,
              child: session != null
                  ? ElevatedButton(
                      onPressed: () => state.endFasting(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.info,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Terminar jejum'),
                    )
                  : ElevatedButton(
                      onPressed: () => state.startFasting(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.info,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Iniciar jejum'),
                    ),
            ),

            // Incentivo metabólico
            if (session != null)
              _darkIncentive(session.elapsed.inMinutes, colors),

            const SizedBox(height: 16),

            // Toggle agendamento
            _autoScheduleToggle(state, colors),
            const SizedBox(height: 16),

            // Secção Hoje
            const Text('Hoje',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary)),
            const SizedBox(height: 10),

            if (lastSession != null && session == null) ...[
              ..._lastSessionRows(lastSession, colors),
              const SizedBox(height: 8),
              _waterSummaryRow(state, lastSession, colors),
            ],

            if (session != null) const TodayWaterRow(),

            const SizedBox(height: 8),
            const WaterCard(),
          ],
        ),
      ),
    );
  }

  /// Barra de progresso horizontal com marcas de hora
  Widget _progressBar(FastingSession session, AppColors colors) {
    final goalH = session.goalDuration.inHours;
    // Calcula marcas: divide em 4 intervalos arredondados
    final interval = ((goalH / 4).round()).clamp(1, 999);
    final marks = <int>[];
    for (int h = 0; h <= goalH; h += interval) {
      marks.add(h);
    }
    if (marks.last != goalH) marks.add(goalH);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Início · ${DateFormat.Hm().format(session.startTime)}',
                style: const TextStyle(
                    fontSize: 11, color: _textSecondary),
              ),
              Text(
                'Termina · ${DateFormat.Hm().format(session.plannedEndTime)}',
                style: const TextStyle(
                    fontSize: 11, color: _textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Barra
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: session.progress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: const Color(0xFF2A2A2A),
              valueColor:
                  AlwaysStoppedAnimation<Color>(colors.info),
            ),
          ),
          const SizedBox(height: 8),
          // Marcas de hora
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: marks
                .map((h) => Text('${h}h',
                    style: const TextStyle(
                        fontSize: 10, color: _textSecondary)))
                .toList(),
          ),
        ],
      ),
    );
  }

  /// Dois cards lado a lado: água e hora de fim
  Widget _summaryCards(
      AppState state, FastingSession session, AppColors colors) {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            icon: Icons.water_drop_outlined,
            value: '${state.currentWaterMl}ml',
            label: 'de ${state.waterGoalMl}ml de água',
            colors: colors,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            icon: Icons.flag_outlined,
            value: DateFormat.Hm().format(session.plannedEndTime),
            label: 'janela termina',
            colors: colors,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String value,
    required String label,
    required AppColors colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: colors.info),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: _textSecondary)),
        ],
      ),
    );
  }

  /// Incentivo metabólico em versão dark
  Widget _darkIncentive(int elapsedMinutes, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: MetabolicIncentive(
        elapsedMinutes: elapsedMinutes,
        colors: colors,
      ),
    );
  }

  Widget _autoScheduleToggle(AppState state, AppColors colors) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Agendar ciclo automaticamente',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary),
            ),
          ),
          Switch(
            value: state.autoScheduleNextCycle,
            onChanged: (v) => state.setAutoScheduleNextCycle(v),
            activeColor: colors.info,
          ),
        ],
      ),
    );
  }

  Widget _waterSummaryRow(
      AppState state, FastingSession session, AppColors colors) {
    return _darkRow(
      Icons.water_drop_outlined,
      '${(session.waterMl / 250).round()} copos de água (resumo)',
      '${session.waterMl}ml de ${state.waterGoalMl}ml neste ciclo',
      colors,
    );
  }

  List<Widget> _lastSessionRows(
      FastingSession session, AppColors colors) {
    return [
      _darkRow(
        Icons.check_circle,
        'Jejum iniciado',
        DateFormat("HH:mm 'de' dd/MM").format(session.startTime),
        colors,
      ),
      if (session.endTime != null) ...[
        const SizedBox(height: 8),
        _darkRow(
          Icons.flag_outlined,
          'Fim de jejum',
          DateFormat("HH:mm 'de' dd/MM").format(session.endTime!),
          colors,
        ),
      ],
    ];
  }

  Widget _darkRow(IconData icon, String title, String subtitle,
      AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: colors.info.withOpacity(0.15),
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
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: _textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  FastingSession? _lastSession(AppState state) {
    final history = state.history;
    if (history.isEmpty) return null;
    return history.reduce(
        (a, b) => a.startTime.isAfter(b.startTime) ? a : b);
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bom dia';
    if (h < 19) return 'Boa tarde';
    return 'Boa noite';
  }

  String _formatRemaining(FastingSession s) {
    final r = s.remainingRounded;
    return '${r.inHours}h ${r.inMinutes % 60}m';
  }

  String _formatElapsed(FastingSession s) {
    final e = s.elapsed;
    return '${e.inHours}h ${e.inMinutes % 60}m';
  }
}
