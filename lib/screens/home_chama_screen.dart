import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/fasting_session.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/metabolic_incentive.dart';
import '../widgets/today_water_row.dart';
import '../widgets/water_card.dart';

/// Tema "Chama": hero colorido com círculo de progresso e percentagem.
/// Fases metabólicas representadas por 4 pontos. Tema premium.
class HomeChamaScreen extends StatefulWidget {
  const HomeChamaScreen({super.key});

  @override
  State<HomeChamaScreen> createState() => _HomeChamaScreenState();
}

class _HomeChamaScreenState extends State<HomeChamaScreen> {
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

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final colors = AppColorsScope.of(context);
    final session = state.activeSession;
    final lastSession = session ?? _lastSession(state);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero colorido ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            color: colors.info,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              children: [
                // Cabeçalho
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _greeting(),
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.info.computeLuminance() > 0.4
                            ? Colors.black54
                            : Colors.white70,
                      ),
                    ),
                    IconButton(
                      onPressed: () => state.goToSettings(),
                      icon: Icon(
                        Icons.settings_outlined,
                        size: 20,
                        color: colors.info.computeLuminance() > 0.4
                            ? Colors.black54
                            : Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Círculo
                SizedBox(
                  width: 190,
                  height: 190,
                  child: CustomPaint(
                    painter: _RingPainter(
                      progress: session?.progress ?? 0.0,
                      trackColor: Colors.white.withOpacity(0.2),
                      progressColor: Colors.white,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            session != null
                                ? '${((session.progress) * 100).clamp(0, 100).round()}%'
                                : '0%',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              color: colors.info.computeLuminance() > 0.4
                                  ? Colors.black87
                                  : Colors.white,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'concluído',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.info.computeLuminance() > 0.4
                                  ? Colors.black54
                                  : Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            session != null
                                ? _formatElapsed(session)
                                : 'sem jejum',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colors.info.computeLuminance() > 0.4
                                  ? Colors.black87
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Corpo ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pontos de fase + faltam X
                if (session != null) ...[
                  _phaseDots(session, colors),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      session.goalReached
                          ? 'Meta atingida!'
                          : 'Faltam ${_formatRemaining(session)}',
                      style: TextStyle(
                          fontSize: 12, color: colors.textSecondary),
                    ),
                  ),
                ] else
                  Center(
                    child: Text(
                      'Inicia um jejum para começar',
                      style: TextStyle(
                          fontSize: 12, color: colors.textSecondary),
                    ),
                  ),

                const SizedBox(height: 20),

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
                    elapsedMinutes: session.elapsed.inMinutes,
                    colors: colors,
                  ),

                const SizedBox(height: 20),

                // Toggle agendamento
                _autoScheduleToggle(context, state, colors),
                const SizedBox(height: 16),

                // Secção Hoje
                Text(
                  'Hoje',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),

                if (lastSession != null && session == null) ...[
                  ..._lastSessionRows(context, lastSession, colors),
                  const SizedBox(height: 8),
                  _waterSummaryRow(context, state, lastSession, colors),
                ],

                if (session != null) ...[
                  const TodayWaterRow(),
                ],

                const SizedBox(height: 8),
                const WaterCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _phaseDots(FastingSession session, AppColors colors) {
    final minutes = session.elapsed.inMinutes;
    final phases = [
      true,
      minutes >= 8 * 60,
      minutes >= 12 * 60,
      minutes >= 16 * 60,
    ];
    const labels = ['0h', '8h', '12h', '16h'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(phases.length, (i) {
        final done = phases[i];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 34,
                height: 6,
                decoration: BoxDecoration(
                  color: done ? colors.info : colors.borderTertiary,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                labels[i],
                style: TextStyle(
                  fontSize: 9,
                  color: done ? colors.info : colors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _autoScheduleToggle(
      BuildContext context, AppState state, AppColors colors) {
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
                color: colors.textPrimary,
              ),
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

  Widget _waterSummaryRow(BuildContext context, AppState state,
      FastingSession session, AppColors colors) {
    return _infoRow(
      context,
      Icons.water_drop_outlined,
      '${(session.waterMl / 250).round()} copos de água (resumo)',
      '${session.waterMl}ml de ${state.waterGoalMl}ml neste ciclo',
      colors,
    );
  }

  List<Widget> _lastSessionRows(
      BuildContext context, FastingSession session, AppColors colors) {
    return [
      _infoRow(
        context,
        Icons.check_circle,
        'Jejum iniciado',
        DateFormat("HH:mm 'de' dd/MM").format(session.startTime),
        colors,
      ),
      if (session.endTime != null) ...[
        const SizedBox(height: 8),
        _infoRow(
          context,
          Icons.flag_outlined,
          'Fim de jejum',
          DateFormat("HH:mm 'de' dd/MM").format(session.endTime!),
          colors,
        ),
      ],
    ];
  }

  Widget _infoRow(BuildContext context, IconData icon, String title,
      String subtitle, AppColors colors) {
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
                    style: TextStyle(
                        fontSize: 11, color: colors.textSecondary)),
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

  String _formatElapsed(FastingSession s) {
    final e = s.elapsed;
    return '${e.inHours}h ${e.inMinutes % 60}m de jejum';
  }

  String _formatRemaining(FastingSession s) {
    final r = s.remainingRounded;
    return '${r.inHours}h ${r.inMinutes % 60}m';
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  const _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, paint..color = trackColor);
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress.clamp(0.0, 1.0),
        false,
        paint..color = progressColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress;
}
