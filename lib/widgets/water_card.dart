import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class WaterCard extends StatelessWidget {
  const WaterCard({super.key});
  static const int _segments = 8;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final colors = AppColorsScope.of(context);
    final l = context.l10n;
    final amountMl = state.currentWaterMl;
    final goalMl = state.waterGoalMl;
    final filledSegments =
        (state.currentWaterProgress * _segments).round().clamp(0, _segments);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l.water,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary)),
              Text(
                '${(amountMl / 1000).toStringAsFixed(2)} / ${(goalMl / 1000).toStringAsFixed(1)}L',
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(_segments, (i) {
              final filled = i < filledSegments;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i == _segments - 1 ? 0 : 5),
                  height: 6,
                  decoration: BoxDecoration(
                    color: filled ? colors.info : colors.borderTertiary,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => state.addWater(250),
                  child: Text(l.waterAdd250,
                      style: const TextStyle(fontSize: 13)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => state.addWater(500),
                  child: Text(l.waterAdd500,
                      style: const TextStyle(fontSize: 13)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showCustomAmountSheet(context, state),
                  child: Text(l.waterAddOther,
                      style: const TextStyle(fontSize: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCustomAmountSheet(BuildContext context, AppState state) {
    final l = context.l10n;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final options = [100, 150, 200, 300, 350, 750];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.waterAddAmount,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: options.map((ml) {
                    return OutlinedButton(
                      onPressed: () {
                        state.addWater(ml);
                        Navigator.of(ctx).pop();
                      },
                      child: Text('${ml}ml'),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
