import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Passo 0 = língua, 1 = protocolo, 2 = água
  int _step = 0;
  int _selectedHours = 16;
  int _waterGoalMl = 2000;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final colors = AppColors.forPalette(state.palette);

    return AppColorsScope(
      colors: colors,
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: colors.background,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Barra de progresso — 3 segmentos
                    Row(
                      children: List.generate(3, (i) {
                        final active = i <= _step;
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                            height: 3,
                            decoration: BoxDecoration(
                              color: active
                                  ? colors.info
                                  : colors.borderTertiary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),

                    // Conteúdo do passo actual
                    Expanded(
                      child: _step == 0
                          ? _languageStep(context, state)
                          : _step == 1
                              ? _protocolStep(context, state)
                              : _waterStep(context),
                    ),

                    // Botão de avançar (escondido no passo 0 — a selecção
                    // da bandeira avança automaticamente)
                    if (_step > 0)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _next,
                          child: Text(
                            _step == 1
                                ? context.l10n.continueAction
                                : context.l10n.begin,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Passo 0: escolha de língua ──────────────────────────────────────
  Widget _languageStep(BuildContext context, AppState state) {
    final colors = AppColorsScope.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo / título sem texto de interface
        Icon(Icons.water_drop, size: 64, color: colors.info),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: _flagButton(
                flag: '🇵🇹',
                label: 'Português',
                selected: state.languageCode == 'pt',
                colors: colors,
                onTap: () async {
                  await state.setLanguageCode('pt');
                  setState(() => _step = 1);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _flagButton(
                flag: '🇬🇧',
                label: 'English',
                selected: state.languageCode == 'en',
                colors: colors,
                onTap: () async {
                  await state.setLanguageCode('en');
                  setState(() => _step = 1);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _flagButton({
    required String flag,
    required String label,
    required bool selected,
    required AppColors colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: selected ? colors.infoBackground : colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? colors.info : colors.borderTertiary,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: selected ? colors.info : colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Passo 1: protocolo ──────────────────────────────────────────────
  Widget _protocolStep(BuildContext context, AppState state) {
    final colors = AppColorsScope.of(context);
    final l = context.l10n;
    final options = [
      (16, '16:8', l.protocolBeginner),
      (18, '18:6', l.protocolExperienced),
      (20, '20:4', l.settingsAdvanced),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.protocolChoose,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary),
        ),
        const SizedBox(height: 6),
        Text(
          l.canChangeLater,
          style: TextStyle(fontSize: 13, color: colors.textSecondary),
        ),
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
                                fontSize: 12,
                                color: colors.textSecondary)),
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

  // ── Passo 2: meta de água ───────────────────────────────────────────
  Widget _waterStep(BuildContext context) {
    final colors = AppColorsScope.of(context);
    final l = context.l10n;
    final options = [1500, 2000, 2500, 3000];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.waterGoalDaily,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary),
        ),
        const SizedBox(height: 6),
        Text(
          l.canChangeLater,
          style:
              TextStyle(fontSize: 13, color: colors.textSecondary),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((ml) {
            final selected = _waterGoalMl == ml;
            return InkWell(
              onTap: () => setState(() => _waterGoalMl = ml),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color:
                        selected ? colors.info : colors.borderTertiary,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Text(
                  '${(ml / 1000).toStringAsFixed(1)} L',
                  style: TextStyle(color: colors.textPrimary),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _next() async {
    if (_step == 1) {
      setState(() => _step = 2);
      return;
    }
    // _step == 2: finalizar onboarding
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
