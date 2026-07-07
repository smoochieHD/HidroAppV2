import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/fasting_session.dart';
import '../services/app_state.dart';
import '../services/backup_service.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'paywall_screen.dart';
import 'profiles_screen.dart';
import 'theme_picker_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final colors = AppColorsScope.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () =>
                    context.read<AppState>().goToTab(AppState.tabIndexHome),
                icon: Icon(Icons.arrow_back,
                    size: 22, color: colors.textPrimary),
                tooltip: 'Voltar ao início',
              ),
              const SizedBox(width: 12),
              Text('Definições',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary)),
            ],
          ),
          const SizedBox(height: 18),
          if (!state.isPremium)
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PaywallScreen()),
              ),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.tealBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hidro Premium',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: colors.teal)),
                        const SizedBox(height: 2),
                        Text('Desbloqueia todos os temas',
                            style: TextStyle(
                                fontSize: 11, color: colors.teal)),
                      ],
                    ),
                    Icon(Icons.chevron_right, color: colors.teal),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 18),
          _sectionLabel(context, 'Aparência'),
          _settingRow(
            context,
            label: 'Tema',
            value: state.selectedTheme.label,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ThemePickerScreen()),
            ),
          ),
          _settingRow(
            context,
            label: 'Idioma',
            value: state.languageCode == 'pt' ? 'Português' : 'English',
            onTap: () => _showLanguagePicker(context, state),
          ),
          const SizedBox(height: 14),
          _sectionLabel(context, 'Jejum'),
          _settingRow(
            context,
            label: 'Protocolo',
            value: protocolLabel(state.defaultProtocolMinutes),
            onTap: () => _showProtocolPicker(context, state),
          ),
          _settingRow(
            context,
            label: 'Tempo de comer',
            value: formatDurationMinutes(state.eatingWindowMinutes),
            onTap: () => _showEatingWindowPicker(context, state),
          ),
          _settingRow(
            context,
            label: 'Perfis',
            value: state.profiles.isEmpty ? 'Nenhum' : '${state.profiles.length}',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfilesScreen()),
            ),
          ),
          const SizedBox(height: 14),
          _sectionLabel(context, 'Água'),
          _settingRow(
            context,
            label: 'Meta por ciclo',
            value: '${(state.waterGoalMl / 1000).toStringAsFixed(1)} L',
            onTap: () => _showWaterGoalPicker(context, state),
          ),
          const SizedBox(height: 14),
          _sectionLabel(context, 'Notificações'),
          _toggleRow(
            context,
            label: 'Relatório semanal',
            subtitle: 'Domingo às 19h, com o resumo da semana',
            value: state.weeklyReportEnabled,
            onChanged: (v) => state.setWeeklyReportEnabled(v),
          ),
          _toggleRow(
            context,
            label: 'Lembretes de água',
            subtitle: 'Avisos ao longo do dia (8h-22h)',
            value: state.waterRemindersEnabled,
            onChanged: (v) => state.setWaterRemindersEnabled(v),
          ),
          const SizedBox(height: 14),
          _sectionLabel(context, 'Backup'),
          _settingRow(
            context,
            label: 'Exportar dados',
            value: '',
            onTap: () => _exportBackup(context),
          ),
          _settingRow(
            context,
            label: 'Importar dados',
            value: '',
            onTap: () => _importBackup(context),
          ),
        ],
      ),
    );
  }

  Future<void> _exportBackup(BuildContext context) async {
    final state = context.read<AppState>();
    try {
      await BackupService(state.storage).exportAndShare();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível exportar o backup.')),
        );
      }
    }
  }

  Future<void> _importBackup(BuildContext context) async {
    final state = context.read<AppState>();
    final error = await BackupService(state.storage).pickAndImport();
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    await state.refreshFromStorage();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backup importado com sucesso.')),
    );
  }

  Widget _toggleRow(
    BuildContext context, {
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colors = AppColorsScope.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontSize: 14, color: colors.textPrimary)),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 11, color: colors.textSecondary)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    final colors = AppColorsScope.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          letterSpacing: 0.5,
          color: colors.textSecondary,
        ),
      ),
    );
  }

  Widget _settingRow(
    BuildContext context, {
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final colors = AppColorsScope.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colors.borderTertiary)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 14, color: colors.textPrimary)),
            Row(
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 13, color: colors.textSecondary)),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right,
                    size: 16, color: colors.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, AppState state) {
    final colors = AppColorsScope.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Idioma / Language',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Text('🇵🇹', style: TextStyle(fontSize: 24)),
                  title: Text('Português',
                      style: TextStyle(color: colors.textPrimary)),
                  trailing: state.languageCode == 'pt'
                      ? Icon(Icons.check, color: colors.info)
                      : null,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    state.setLanguageCode('pt');
                  },
                ),
                ListTile(
                  leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
                  title: Text('English',
                      style: TextStyle(color: colors.textPrimary)),
                  trailing: state.languageCode == 'en'
                      ? Icon(Icons.check, color: colors.info)
                      : null,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    state.setLanguageCode('en');
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showProtocolPicker(BuildContext context, AppState state) {
    final colors = AppColorsScope.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        // (minutos, rótulo a mostrar). OMAD (23:1) e jejum em dias
        // alternados (36h, cobrindo um dia inteiro entre refeições) são
        // protocolos de duração — cabem na mesma estrutura dos presets
        // horários, só com nomes próprios em vez de "X:Y".
        final presets = [
          (16 * 60, '16:8'),
          (18 * 60, '18:6'),
          (20 * 60, '20:4'),
          (23 * 60, 'OMAD · 23:1'),
          (36 * 60, 'Dias alternados · 36h'),
        ];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Protocolo de jejum',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary)),
                const SizedBox(height: 14),
                ...presets.map((preset) => ListTile(
                      title: Text(preset.$2,
                          style: TextStyle(color: colors.textPrimary)),
                      trailing: state.defaultProtocolMinutes == preset.$1
                          ? Icon(Icons.check, color: colors.info)
                          : null,
                      onTap: () {
                        state.setDefaultProtocolMinutesWithAutoWindow(
                            preset.$1);
                        Navigator.of(ctx).pop();
                      },
                    )),
                ListTile(
                  title: Text('Personalizado',
                      style: TextStyle(color: colors.textPrimary)),
                  trailing: Icon(Icons.chevron_right,
                      color: colors.textSecondary),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showCustomDurationPicker(
                      context,
                      state,
                      title: 'Duração do jejum',
                      subtitle: 'Define quanto tempo dura o jejum',
                      initialMinutes: state.defaultProtocolMinutes,
                      onConfirm: state.setDefaultProtocolMinutesWithAutoWindow,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEatingWindowPicker(BuildContext context, AppState state) {
    _showCustomDurationPicker(
      context,
      state,
      title: 'Tempo de comer',
      subtitle:
          'Quanto tempo depois do fim do jejum até começar o próximo',
      initialMinutes: state.eatingWindowMinutes,
      onConfirm: state.setEatingWindowMinutes,
    );
  }

  void _showCustomDurationPicker(
    BuildContext context,
    AppState state, {
    required String title,
    required String subtitle,
    required int initialMinutes,
    required ValueChanged<int> onConfirm,
  }) {
    int selectedHours = initialMinutes ~/ 60;
    int selectedMinutes = initialMinutes % 60;
    final colors = AppColorsScope.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: StatefulBuilder(
              builder: (ctx, setLocalState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary)),
                    const SizedBox(height: 6),
                    Text(subtitle,
                        style:
                            TextStyle(fontSize: 12, color: colors.textSecondary)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 160,
                      child: Row(
                        children: [
                          Expanded(
                            child: _wheelColumn(
                              colors: colors,
                              label: 'horas',
                              itemCount: 24,
                              initialValue: selectedHours,
                              onChanged: (v) =>
                                  setLocalState(() => selectedHours = v),
                            ),
                          ),
                          Expanded(
                            child: _wheelColumn(
                              colors: colors,
                              label: 'min',
                              itemCount: 60,
                              initialValue: selectedMinutes,
                              onChanged: (v) =>
                                  setLocalState(() => selectedMinutes = v),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (selectedHours == 0 && selectedMinutes == 0)
                            ? null
                            : () {
                                onConfirm(selectedHours * 60 + selectedMinutes);
                                Navigator.of(ctx).pop();
                              },
                        child: const Text('Confirmar'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _wheelColumn({
    required AppColors colors,
    required String label,
    required int itemCount,
    required int initialValue,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(fontSize: 12, color: colors.textSecondary)),
        const SizedBox(height: 4),
        Expanded(
          child: CupertinoPicker(
            itemExtent: 36,
            scrollController:
                FixedExtentScrollController(initialItem: initialValue),
            onSelectedItemChanged: onChanged,
            children: List.generate(
              itemCount,
              (i) => Center(
                  child: Text('$i', style: TextStyle(color: colors.textPrimary))),
            ),
          ),
        ),
      ],
    );
  }

  void _showWaterGoalPicker(BuildContext context, AppState state) {
    final colors = AppColorsScope.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final options = [1500, 2000, 2500, 3000];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Meta de água por ciclo',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary)),
                const SizedBox(height: 14),
                ...options.map((ml) => ListTile(
                      title: Text('${(ml / 1000).toStringAsFixed(1)} L',
                          style: TextStyle(color: colors.textPrimary)),
                      trailing: state.waterGoalMl == ml
                          ? Icon(Icons.check, color: colors.info)
                          : null,
                      onTap: () {
                        state.setWaterGoal(ml);
                        Navigator.of(ctx).pop();
                      },
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}
