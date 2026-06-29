import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/fasting_session.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/water_card.dart';
import '../widgets/today_water_row.dart';

/// Tema "Relógio": anel de progresso circular clássico. Tema premium.
class HomeRelogioScreen extends StatefulWidget {
  const HomeRelogioScreen({super.key});

  @override
  State<HomeRelogioScreen> createState() => _HomeRelogioScreenState();
}

class _HomeRelogioScreenState extends State<HomeRelogioScreen> {
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
          const SizedBox(height: 12),
          Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: CustomPaint(
                painter: _RingPainter(
                  progress: session?.progress ?? 0.0,
                  trackColor: colors.borderTertiary,
                  progressColor: colors.info,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Jejum',
                          style: TextStyle(
                              fontSize: 12, color: colors.textSecondary)),
                      const SizedBox(height: 6),
                      Text(
                        session != null
                            ? _formatRemaining(session)
                            : '--:--',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        session != null ? 'restante' : 'sem jejum ativo',
                        style: TextStyle(
                            fontSize: 12, color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
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
          const SizedBox(height: 20),
          _autoScheduleToggle(context, state),
          const SizedBox(height: 12),
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
                    style: TextStyle(
                        fontSize: 11, color: colors.textSecondary)),
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
    final h = r.inHours.toString().padLeft(2, '0');
    final m = (r.inMinutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    final bgPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.progressColor != progressColor;
}
