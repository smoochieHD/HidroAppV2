import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/fasting_session.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/metabolic_incentive.dart';
import '../widgets/water_card.dart';
import '../widgets/today_water_row.dart';

/// Tema "Chama": círculo de progresso grande com percentagem e pontos de fase
/// metabólica. Tema premium.
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
          const SizedBox(height: 16),

          // Círculo de progresso central
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: CustomPaint(
                painter: _ChamaRingPainter(
                  progress: progress,
                  trackColor: colors.borderTertiary,
                  progressColor: colors.info,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        session != null
                            ? '${(progress * 100).clamp(0, 100).round()}%'
                            : '0%',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      Text(
                        'concluído',
                        style: TextStyle(
                            fontSize: 12, color: colors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        session != null
                            ? _formatElapsed(session)
                            : 'sem jejum',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.info),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Pontos de fase metabólica
          if (session != null) ...[
            _phaseDots(session, colors),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Faltam ${_formatRemaining(session)}',
                style:
                    TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
            ),
          ] else ...[
            Center(
              child: Text(
                'Inicia um jejum para começar',
                style:
                    TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
            ),
          ],
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

  /// Quatro pontos representando as fases: 0-8h, 8-12h, 12-16h, 16h+
  Widget _phaseDots(FastingSession session, AppColors colors) {
    final minutes = session.elapsed.inMinutes;
    final phases = [
      minutes >= 0,      // 0–8h  (sempre verdadeiro se há sessão)
      minutes >= 8 * 60, // 8–12h
      minutes >= 12 * 60,// 12–16h
      minutes >= 16 * 60,// 16h+
    ];
    final labels = ['0h', '8h', '12h', '16h'];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(phases.length, (i) {
            final done = phases[i];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: 32,
                    height: 6,
                    decoration: BoxDecoration(
                      color: done
                          ? colors.info
                          : colors.borderTertiary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(labels[i],
                      style: TextStyle(
                          fontSize: 9,
                          color: done
                              ? colors.info
                              : colors.textSecondary)),
                ],
              ),
            );
          }),
        ),
      ],
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

  String _formatElapsed(FastingSession session) {
    final e = session.elapsed;
    return '${e.inHours}h ${e.inMinutes % 60}m de jejum';
  }

  String _formatRemaining(FastingSession session) {
    final r = session.remainingRounded;
    return '${r.inHours}h ${r.inMinutes % 60}m';
  }
}

class _ChamaRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  _ChamaRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14,
    );

    // Progresso
    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ChamaRingPainter old) =>
      old.progress != progress ||
      old.trackColor != trackColor ||
      old.progressColor != progressColor;
}
