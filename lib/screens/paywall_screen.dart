import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

/// Ecrã de subscrição. Nesta fase inicial, a compra real via Google Play
/// Billing ainda não está ligada — isso é o próximo passo depois de termos
/// a app a funcionar e testada localmente.
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _yearlySelected = true;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final state = context.read<AppState>();
    final colors = AppColors.forPalette(state.palette);

    return AppColorsScope(
      colors: colors,
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Text(l.premium,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary)),
                const SizedBox(height: 4),
                Text(l.premiumMore,
                    style:
                        TextStyle(fontSize: 13, color: colors.textSecondary)),
                const SizedBox(height: 20),
                _benefitRow(context, 'Temas Relógio e Linha do tempo'),
                _benefitRow(context, l.premiumPalettes),
                _benefitRow(context, l.statsAdvancedTitle),
                _benefitRow(context, l.premiumSupport),
                const SizedBox(height: 20),
                _planOption(
                  context,
                  title: l.statsYearly,
                  subtitle: '22,99€ / ano · poupa 37%',
                  selected: _yearlySelected,
                  onTap: () => setState(() => _yearlySelected = true),
                ),
                const SizedBox(height: 10),
                _planOption(
                  context,
                  title: l.statsMonthly,
                  subtitle: '2,99€ / mês',
                  selected: !_yearlySelected,
                  onTap: () => setState(() => _yearlySelected = false),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // TODO: ligar ao Google Play Billing nesta fase futura.
                      await state.setPremiumStatus(true);
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    child: const Text(l.continueAction),
                  ),
                ),
                const SizedBox(height: 8),
                Text(l.premiumCancel,
                    style:
                        TextStyle(fontSize: 11, color: colors.textSecondary)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _benefitRow(BuildContext context, String text) {
    final colors = AppColorsScope.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check, size: 16, color: colors.info),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text,
                  style: TextStyle(fontSize: 13, color: colors.textPrimary))),
        ],
      ),
    );
  }

  Widget _planOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final colors = AppColorsScope.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? colors.info : colors.borderTertiary,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary)),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12, color: colors.textSecondary)),
              ],
            ),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? colors.info : colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
