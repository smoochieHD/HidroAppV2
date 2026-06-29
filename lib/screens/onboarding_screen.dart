import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _selectedHours = 16;
  int _waterGoalMl = 2000;
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final colors = AppColors.forPalette(state.palette);

    return AppColorsScope(
      colors: colors,
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(2, (i) {
                    final active = i <= _step;
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: i == 1 ? 0 : 4),
                        height: 3,
                        decoration: BoxDecoration(
                          color: active ? colors.info : colors.borderTertiary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: _step == 0
                      ? _protocolStep(context)
                      : _waterStep(context),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _next,
                    child: Text(_step == 0 ? 'Continuar' : 'Começar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _protocolStep(BuildContext context) {
    final colors = AppColorsScope.of(context);
    final options = [
      (16, '16:8', 'Mais popular, ideal para iniciantes'),
      (18, '18:6', 'Para quem já tem experiência'),
      (20, '20:4', 'Avançado'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Escolhe o teu protocolo',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary)),
        const SizedBox(height: 6),
        Text('Podes mudar isto mais tarde',
            style: TextStyle(fontSize: 13, color: colors.textSecondary)),
        const SizedBox(height: 20),
        ...options.map((opt) {
          final selected = _selectedHours == opt.$1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => setState(() => _selectedHours = opt.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? colors.info : colors.borderTertiary,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(opt.$2,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary)),
                        Text(opt.$3,
                            style: TextStyle(
                                fontSize: 12, color: colors.textSecondary)),
                      ],
                    ),
                    if (selected) Icon(Icons.check, color: colors.info),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _waterStep(BuildContext context) {
    final colors = AppColorsScope.of(context);
    final options = [1500, 2000, 2500, 3000];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Meta diária de água',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary)),
        const SizedBox(height: 6),
        Text('Podes mudar isto mais tarde',
            style: TextStyle(fontSize: 13, color: colors.textSecondary)),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((ml) {
            final selected = _waterGoalMl == ml;
            return InkWell(
              onTap: () => setState(() => _waterGoalMl = ml),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? colors.info : colors.borderTertiary,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Text('${(ml / 1000).toStringAsFixed(1)} L',
                    style: TextStyle(color: colors.textPrimary)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _next() async {
    if (_step == 0) {
      setState(() => _step = 1);
      return;
    }
    final state = context.read<AppState>();
    await state.setDefaultProtocolMinutes(_selectedHours * 60);
    await state.setWaterGoal(_waterGoalMl);
    await state.storage.setOnboardingDone();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    }
  }
}
