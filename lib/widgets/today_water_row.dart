import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class TodayWaterRow extends StatelessWidget {
  const TodayWaterRow({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l = context.l10n;
    return _timelineItem(
      context: context,
      icon: Icons.water_drop_outlined,
      title: l.waterCups((state.currentWaterMl / 250).round()),
      subtitle: l.waterMlOfGoal(state.currentWaterMl, state.waterGoalMl),
      trailing: TextButton(
        onPressed: () => state.addWater(250),
        child: Text(l.waterAddCup),
      ),
    );
  }

  Widget _timelineItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
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
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
