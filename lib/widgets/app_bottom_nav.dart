import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorsScope.of(context);
    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.borderTertiary)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navIcon(context, Icons.home_rounded, 0),
          _navIcon(context, Icons.bar_chart_rounded, 1),
          _navIcon(context, Icons.calendar_month_rounded, 2),
          _navIcon(context, Icons.person_rounded, 3),
        ],
      ),
    );
  }

  Widget _navIcon(BuildContext context, IconData icon, int index) {
    final colors = AppColorsScope.of(context);
    final active = index == currentIndex;
    return IconButton(
      onPressed: () => onTap(index),
      icon: Icon(
        icon,
        color: active ? colors.info : colors.textSecondary,
      ),
    );
  }
}
