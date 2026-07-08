import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/fasting_session.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/water_card.dart';
import '../widgets/today_water_row.dart';

/// Tema "Linha do tempo": barra de progresso horizontal. Tema premium.
class HomeLinhaDoTempoScreen extends StatefulWidget {
  const HomeLinhaDoTempoScreen({super.key});

  @override
  State<HomeLinhaDoTempoScreen> createState() =>
      _HomeLinhaDoTempoScreenState();
}

class _HomeLinhaDoTempoScreenState extends State<HomeLinhaDoTempoScreen> {
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
    final l = context.l10n;
    final state = context.watch<AppState>();
    final colors = AppColorsScope.of(context);
    final session = state.activeSession;
    final progress = session?.progress ?? 0.0;

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
          Text(
            session != null
                ? (session.goalReached ? l.fastingGoalReached : l.fastingInProgress)
                : l.fastingNoActive,
            style: TextStyle(fontSize: 13, color: colors.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            session != null ? _formatRemaining(session) : '--h --m',
            style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: colors.borderTertiary,
              color: colors.info,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                session != null
                    ? l.fastingStartTime(DateFormat.Hm().format(session.startTime))
                    : l.fastingNoActive,
                style: TextStyle(fontSize: 11, color: colors.textSecondary),
              ),
              if (session != null)
                Text(
                  'Meta · ${formatDurationMinutes(session.goalDuration.inMinutes)}',
                  style: TextStyle(fontSize: 11, color: colors.textSecondary),
                ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: session != null
                ? ElevatedButton(
                    onPressed: () => state.endFasting(),
                    child: const Text(l.endFasting),
                  )
                : ElevatedButton(
                    onPressed: () => state.startFasting(),
                    child: const Text(l.startFasting),
                  ),
          ),
          const SizedBox(height: 20),
          _autoScheduleToggle(context, state),
          const SizedBox(height: 12),
          Text(l.today,
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
              l.fastingScheduleAuto,
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
      _infoRow(context, Icons.check_circle, l.fastingStarted,
          DateFormat("HH:mm 'de' dd/MM").format(session.startTime)),
      if (session.endTime != null) ...[
        const SizedBox(height: 8),
        _infoRow(context, Icons.flag_outlined, l.fastingEnded,
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
    if (hour < 12) return l.greetingMorning;
    if (hour < 19) return l.greetingAfternoon;
    return l.greetingEvening;
  }

  String _formatRemaining(FastingSession session) {
    final r = session.remainingRounded;
    return '${r.inHours}h ${r.inMinutes % 60}m';
  }
}
