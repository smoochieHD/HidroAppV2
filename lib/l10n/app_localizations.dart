import 'package:flutter/material.dart';

/// Acesso rápido: AppLocalizations.of(context)
/// ou o extension: context.l10n
class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const delegate = _AppLocalizationsDelegate();

  static const supportedLocales = [
    Locale('pt'),
    Locale('en'),
  ];

  bool get _isPt => locale.languageCode == 'pt';

  // ── Saudações ────────────────────────────────────────────────────────
  String get greetingMorning => _isPt ? 'Bom dia' : 'Good morning';
  String get greetingAfternoon => _isPt ? 'Boa tarde' : 'Good afternoon';
  String get greetingEvening => _isPt ? 'Boa noite' : 'Good evening';

  String greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return greetingMorning;
    if (h < 19) return greetingAfternoon;
    return greetingEvening;
  }

  // ── Jejum ────────────────────────────────────────────────────────────
  String get startFasting => _isPt ? 'Iniciar jejum' : 'Start fast';
  String get endFasting => _isPt ? 'Terminar jejum' : 'End fast';
  String get endFastingNow => _isPt ? 'Terminar jejum agora' : 'End fast now';
  String get endFastingQuestion => _isPt ? 'Terminar jejum?' : 'End fast?';
  String get endFastingConfirm =>
      _isPt ? 'Isto regista o fim da sessão atual.' : 'This records the end of the current session.';
  String get fastingStarted => _isPt ? 'Jejum iniciado' : 'Fast started';
  String get fastingEnded => _isPt ? 'Fim de jejum' : 'Fast ended';
  String get fastingGoalReached => _isPt ? 'Meta atingida' : 'Goal reached';
  String get fastingInProgress => _isPt ? 'A meio do jejum' : 'Mid-fast';
  String get fastingNoActive => _isPt ? 'Sem jejum ativo' : 'No active fast';
  String fastingBegins(String time) =>
      _isPt ? 'Começa às $time' : 'Starts at $time';
  String fastingTimeLeft(int hours, int minutes) =>
      _isPt ? 'Faltam ${hours}h ${minutes}min' : '${hours}h ${minutes}min remaining';
  String fastingTimeOver(int hours, int minutes) =>
      _isPt ? 'Há mais ${hours}h ${minutes}min' : '${hours}h ${minutes}min over goal';
  String fastingWindowEnds(String time) =>
      _isPt ? 'Janela termina às $time' : 'Window ends at $time';
  String fastingStartTime(String time) =>
      _isPt ? 'Início · $time' : 'Start · $time';
  String fastingEndTime(String time) =>
      _isPt ? 'Termina · $time' : 'Ends · $time';
  String get fastingProtocol => _isPt ? 'Protocolo de jejum' : 'Fasting protocol';
  String fastingProtocolDefined(String duration) =>
      _isPt ? 'Protocolo definido: $duration' : 'Protocol set: $duration';
  String fastingGoal(String duration) =>
      _isPt ? 'Meta · $duration' : 'Goal · $duration';
  String get fastingWindow => _isPt ? 'Janela de alimentação' : 'Eating window';
  String get fastingEatingTime => _isPt ? 'Tempo de comer' : 'Eating time';
  String get fastingNextScheduled =>
      _isPt ? 'Próximo jejum agendado' : 'Next fast scheduled';
  String get fastingScheduleAuto =>
      _isPt ? 'Agendar ciclo automaticamente' : 'Auto-schedule next cycle';
  String get fastingScheduleDelay =>
      _isPt
          ? 'Quanto tempo depois do fim do jejum até começar o próximo'
          : 'How long after the fast ends before the next one starts';
  String fastingElapsed(int hours, int minutes) =>
      _isPt ? '${hours}h ${minutes}m de jejum' : '${hours}h ${minutes}m fasting';
  String fastingRemaining(int hours, int minutes) =>
      _isPt ? 'Faltam ${hours}h ${minutes}m' : '${hours}h ${minutes}m remaining';
  String get fastingNoRecordedToday =>
      _isPt ? 'Ainda sem jejum registado hoje.' : 'No fast recorded today yet.';
  String get fastingNoRecordedDay =>
      _isPt ? 'Sem jejum registado neste dia.' : 'No fast recorded on this day.';
  String get fastingStartNow => _isPt ? 'Iniciar agora' : 'Start now';
  String get fastingConcluded =>
      _isPt
          ? 'Termina mais alguns jejuns para veres a tendência.'
          : 'Complete a few more fasts to see your trend.';
  String get fastingNoCompleted =>
      _isPt
          ? 'Ainda não tens jejuns terminados. Conclui o teu primeiro jejum para veres dados aqui.'
          : 'No completed fasts yet. Finish your first fast to see data here.';
  String get fastingJejum => _isPt ? 'Jejum' : 'Fast';
  String fastingJejumOf(int hours, int minutes) =>
      _isPt ? 'Jejum: ${hours}h ${minutes}m' : 'Fast: ${hours}h ${minutes}m';

  // ── Água ─────────────────────────────────────────────────────────────
  String get water => _isPt ? 'Água' : 'Water';
  String waterCups(int cups) =>
      _isPt ? '$cups copos de água' : '$cups cups of water';
  String waterCupsSummary(int cups) =>
      _isPt ? '$cups copos de água (resumo)' : '$cups cups of water (summary)';
  String waterMlOfGoal(int ml, int goal) =>
      _isPt ? '${ml}ml de ${goal}ml' : '${ml}ml of ${goal}ml';
  String waterMlOfGoalCycle(int ml, int goal) =>
      _isPt ? '${ml}ml de ${goal}ml neste ciclo' : '${ml}ml of ${goal}ml this cycle';
  String waterLitersOfGoal(String liters, String goal) =>
      _isPt ? '${liters}L de ${goal}L' : '${liters}L of ${goal}L';
  String get waterGoalCycle => _isPt ? 'Meta de água por ciclo' : 'Water goal per cycle';
  String get waterGoalDaily => _isPt ? 'Meta diária de água' : 'Daily water goal';
  String get waterGoalPer => _isPt ? 'Meta por ciclo' : 'Goal per cycle';
  String get waterAdd250 => '+250ml';
  String get waterAdd500 => '+500ml';
  String get waterAddOther => _isPt ? '+ outro' : '+ other';
  String get waterAddCup => _isPt ? '+ copo' : '+ cup';
  String get waterAddAmount => _isPt ? 'Adicionar quantidade' : 'Add amount';
  String get waterReminders => _isPt ? 'Lembretes de água' : 'Water reminders';
  String get waterReminderDesc =>
      _isPt ? 'Avisos ao longo do dia (8h-22h)' : 'Alerts throughout the day (8am–10pm)';
  String waterCycleOf(String current, String goal) =>
      _isPt ? 'Água nesse ciclo: ${current}L de ${goal}L' : 'Water this cycle: ${current}L of ${goal}L';
  String waterCurrentOf(String current, String goal) =>
      _isPt ? 'Água: ${current}L de ${goal}L' : 'Water: ${current}L of ${goal}L';

  // ── Protocolo ────────────────────────────────────────────────────────
  String get protocol => _isPt ? 'Protocolo' : 'Protocol';
  String get protocolChoose => _isPt ? 'Escolhe o teu protocolo' : 'Choose your protocol';
  String get protocolCustom => _isPt ? 'Personalizado' : 'Custom';
  String get protocolOmad => 'OMAD · 23:1';
  String get protocolAltDays => _isPt ? 'Dias alternados · 36h' : 'Alternate days · 36h';
  String get protocolBeginner =>
      _isPt ? 'Mais popular, ideal para iniciantes' : 'Most popular, ideal for beginners';
  String get protocolExperienced =>
      _isPt ? 'Para quem já tem experiência' : 'For those with experience';
  String get protocolFastingDuration => _isPt ? 'Duração do jejum' : 'Fasting duration';
  String get protocolFastingDurationSub =>
      _isPt ? 'Define quanto tempo dura o jejum' : 'Set how long your fast lasts';

  // ── Definições ───────────────────────────────────────────────────────
  String get settings => _isPt ? 'Definições' : 'Settings';
  String get settingsCurrent => _isPt ? 'Definições atuais' : 'Current settings';
  String get settingsAppearance => _isPt ? 'Aparência' : 'Appearance';
  String get settingsLayout => 'Layout';
  String get settingsColor => _isPt ? 'Cor' : 'Colour';
  String get settingsTheme => _isPt ? 'Tema' : 'Theme';
  String get settingsChooseTheme => _isPt ? 'Escolher tema' : 'Choose theme';
  String get settingsNotifications => _isPt ? 'Notificações' : 'Notifications';
  String get settingsAdvanced => _isPt ? 'Avançado' : 'Advanced';
  String get settingsBackup => 'Backup';
  String get settingsExport => _isPt ? 'Exportar dados' : 'Export data';
  String get settingsImport => _isPt ? 'Importar dados' : 'Import data';
  String get settingsExportError =>
      _isPt ? 'Não foi possível exportar o backup.' : 'Could not export backup.';
  String get settingsLanguage => _isPt ? 'Idioma' : 'Language';

  // ── Tema / Premium ───────────────────────────────────────────────────
  String get themeUnlock => _isPt ? 'Desbloqueia todos os temas' : 'Unlock all themes';
  String get themeRelogioLinha =>
      _isPt ? 'Temas Relógio e Linha do tempo' : 'Clock and Timeline themes';
  String get themeFree => _isPt ? 'Grátis' : 'Free';
  String get premium => 'Hidro Premium';
  String get premiumMore => _isPt ? 'Mais temas. Mais controlo.' : 'More themes. More control.';
  String get premiumSupport =>
      _isPt ? 'Apoias o desenvolvimento da app' : 'You support the app\'s development';
  String get premiumCancel => _isPt ? 'Cancela quando quiseres' : 'Cancel anytime';
  String get premiumPalettes => _isPt ? 'Paletas de cor extra' : 'Extra colour palettes';

  // ── Perfis ───────────────────────────────────────────────────────────
  String get profiles => _isPt ? 'Perfis' : 'Profiles';
  String get profilesMy => _isPt ? 'Os teus perfis' : 'Your profiles';
  String get profilesFasting => _isPt ? 'Perfis de jejum' : 'Fasting profiles';
  String get profilesSave => _isPt ? 'Guardar como perfil' : 'Save as profile';
  String get profilesSaveAction => _isPt ? 'Guardar perfil' : 'Save profile';
  String get profilesNoSaved =>
      _isPt
          ? 'Ainda não guardaste nenhum perfil. Ajusta as definições e guarda para reutilizar.'
          : 'No saved profiles yet. Adjust the settings and save to reuse.';
  String get profilesRemove => _isPt ? 'Remover perfil?' : 'Remove profile?';
  String get profilesExampleName => _isPt ? 'Ex: Dias de trabalho' : 'E.g. Work days';

  // ── Estatísticas ─────────────────────────────────────────────────────
  String get stats => _isPt ? 'Estatísticas' : 'Statistics';
  String get statsAdvanced => _isPt ? 'Análises avançadas' : 'Advanced analytics';
  String get statsAdvancedTitle => _isPt ? 'Estatísticas avançadas' : 'Advanced statistics';
  String get statsWeekly => _isPt ? 'Semanal' : 'Weekly';
  String get statsMonthly => _isPt ? 'Mensal' : 'Monthly';
  String get statsYearly => _isPt ? 'Anual' : 'Yearly';
  String get statsAvgFasting => _isPt ? 'Média jejum' : 'Avg fast';
  String get statsGoalMet => _isPt ? 'Meta cumprida' : 'Goal met';
  String statsStreak(int days) => '$days ${_isPt ? 'dias' : 'days'}';
  String statsConsistency(int weeks) =>
      _isPt ? 'Consistência · últimas $weeks semanas' : 'Consistency · last $weeks weeks';
  String get statsNoPattern =>
      _isPt
          ? 'Ainda não encontrámos um padrão claro nos teus dados.'
          : 'We haven\'t found a clear pattern in your data yet.';
  String get statsNoDataPeriod =>
      _isPt ? 'Ainda sem dados suficientes neste período.' : 'Not enough data for this period yet.';
  String get statsDurationTrend => _isPt ? 'Tendência da duração' : 'Duration trend';
  String get statsTrends => _isPt ? 'Tendências e correlações' : 'Trends and correlations';
  String get statsRecentHistory => _isPt ? 'Histórico recente' : 'Recent history';
  String statsWaterMore(String liters, int diff) =>
      _isPt
          ? 'Dias com mais de ${liters}L de água têm ${diff}% mais probabilidade de completar o jejum.'
          : 'Days with more than ${liters}L of water are ${diff}% more likely to complete the fast.';
  String statsWaterLess(String liters, int diff) =>
      _isPt
          ? 'Dias com menos de ${liters}L de água têm ${diff}% menos probabilidade de completar o jejum.'
          : 'Days with less than ${liters}L of water are ${diff}% less likely to complete the fast.';
  String statsFastEarlyMore(String cutoff, int diff) =>
      _isPt
          ? 'Jejuns iniciados antes das ${cutoff}h têm ${diff}% mais probabilidade de sucesso.'
          : 'Fasts started before ${cutoff}h are ${diff}% more likely to succeed.';
  String statsFastLateMore(String cutoff, int diff) =>
      _isPt
          ? 'Jejuns iniciados depois das ${cutoff}h têm ${diff}% mais probabilidade de sucesso.'
          : 'Fasts started after ${cutoff}h are ${diff}% more likely to succeed.';
  String get statsBelowGoal => _isPt ? 'Abaixo da meta' : 'Below goal';
  String get statsContinueRecording =>
      _isPt
          ? 'Continua a registar jejuns para veres os teus padrões de sucesso.'
          : 'Keep logging fasts to see your success patterns.';

  // ── Histórico ────────────────────────────────────────────────────────
  String get history => _isPt ? 'Histórico' : 'History';

  // ── Acções gerais ────────────────────────────────────────────────────
  String get today => _isPt ? 'Hoje' : 'Today';
  String get confirm => _isPt ? 'Confirmar' : 'Confirm';
  String get cancel => _isPt ? 'Cancelar' : 'Cancel';
  String get save => _isPt ? 'Guardar' : 'Save';
  String get remove => _isPt ? 'Remover' : 'Remove';
  String get use => _isPt ? 'Usar' : 'Use';
  String get continueAction => _isPt ? 'Continuar' : 'Continue';
  String get begin => _isPt ? 'Começar' : 'Begin';
  String get back => _isPt ? 'Voltar ao início' : 'Back to start';
  String get starting => _isPt ? 'A começar...' : 'Starting...';
  String get canChangeLater =>
      _isPt ? 'Podes mudar isto mais tarde' : 'You can change this later';
  String get actionIrreversible =>
      _isPt ? 'Esta ação não pode ser desfeita.' : 'This action cannot be undone.';
  String onboardingProfiles(int count) =>
      _isPt ? '$count perfis pré-definidos' : '$count preset profiles';

  // ── Notificações ─────────────────────────────────────────────────────
  String get notifFastStarted => _isPt ? 'Jejum iniciado' : 'Fast started';
  String get notifFastStartedBody => _isPt ? 'O seu jejum começou' : 'Your fast has begun';
  String get notifFastStartedBodyFull =>
      _isPt ? 'O seu jejum está a contar. Boa sorte!' : 'Your fast is running. Good luck!';
  String get notifFastEnded => _isPt ? 'O seu jejum terminou' : 'Your fast has ended';
  String get notifWindowEnded =>
      _isPt ? 'A janela de alimentação terminou. Bom jejum!' : 'The eating window has ended. Happy fasting!';
  String get notifOpenApp =>
      _isPt ? 'Abra a app para ver o resumo.' : 'Open the app to see your summary.';
  String get notifFastEndChannel => _isPt ? 'Fim de jejum' : 'Fast ended';
  String get notifFastStartChannel => _isPt ? 'Início de jejum' : 'Fast started';
  String get notifFastEndDesc =>
      _isPt ? 'Avisa quando o jejum atual termina.' : 'Notifies when your current fast ends.';
  String get notifFastStartDesc =>
      _isPt ? 'Avisa quando um jejum agendado começa.' : 'Notifies when a scheduled fast begins.';
  String get notifWater => _isPt ? 'Hora de beber água' : 'Time to drink water';
  String get notifWaterChannel => _isPt ? 'Lembretes de água' : 'Water reminders';
  String get notifWaterDesc =>
      _isPt ? 'Lembra de beber água durante o dia.' : 'Reminds you to drink water during the day.';
  String get notifWaterStayHydrated =>
      _isPt ? 'Mantém a hidratação durante o dia.' : 'Stay hydrated throughout the day.';
  String get notifWeeklyReport => _isPt ? 'Relatório semanal' : 'Weekly report';
  String get notifWeeklyReportChannel => _isPt ? 'Relatório semanal' : 'Weekly report';
  String get notifWeeklyReportDesc =>
      _isPt ? 'Resumo semanal de progresso.' : 'Weekly progress summary.';
  String get notifWeeklyReportBody =>
      _isPt ? 'O teu resumo da semana' : 'Your weekly summary';
  String get notifWeeklyTime =>
      _isPt ? 'Domingo às 19h, com o resumo da semana' : 'Sunday at 7pm, with your weekly summary';
  String notifWeeklySummary(int count, int total, int streak) =>
      _isPt
          ? 'Cumpriste $count de $total dias. Sequência recorde: $streak dias.'
          : 'You completed $count of $total days. Record streak: $streak days.';

  // ── Próximo jejum ────────────────────────────────────────────────────
  String nextFastIn(int hours, int minutes) =>
      _isPt ? 'Daqui a ${hours}h ${minutes}min' : 'In ${hours}h ${minutes}min';

  // ── Paletas ──────────────────────────────────────────────────────────
  String get paletteBlue => _isPt ? 'Azul' : 'Blue';
  String get paletteGreen => _isPt ? 'Verde-jade' : 'Jade green';
  String get paletteTerracotta => _isPt ? 'Terracota' : 'Terracotta';
  String get paletteViolet => _isPt ? 'Violeta' : 'Violet';
  String get paletteCharcoal => _isPt ? 'Carvão' : 'Charcoal';

  // ── Nomes de temas ───────────────────────────────────────────────────
  String get themeDaily => _isPt ? 'Diário' : 'Daily';
  String get themeClock => _isPt ? 'Relógio' : 'Clock';
  String get themeTimeline => _isPt ? 'Linha do tempo' : 'Timeline';
  String get themeChama => _isPt ? 'Chama' : 'Flame';
  String get themeMinimalist => _isPt ? 'Minimalista' : 'Minimalist';

  // ── Incentivos metabólicos ───────────────────────────────────────────
  String get metabolicPhase1Title =>
      _isPt ? 'A 2 horas de queimar gordura' : '2 hours away from burning fat';
  String get metabolicPhase1Body =>
      _isPt
          ? 'Se continuar mais 2 horas, o seu corpo inicia a transição para usar a gordura como fonte de energia.'
          : 'If you continue for 2 more hours, your body will start transitioning to using fat as its energy source.';
  String get metabolicPhase2Title =>
      _isPt ? 'Glicogénio a esgotar-se' : 'Glycogen depleting';
  String get metabolicPhase2Body =>
      _isPt
          ? 'As reservas de glicogénio estão a diminuir e o corpo começa a transitar para a queima de gordura. Continue — está quase!'
          : 'Your glycogen stores are running low and your body is starting to transition to burning fat. Keep going — almost there!';
  String get metabolicPhase3Title =>
      _isPt ? 'Lipólise em pleno' : 'Lipolysis underway';
  String get metabolicPhase3Body =>
      _isPt
          ? 'O seu corpo está a quebrar activamente a gordura armazenada em ácidos gordos para usar como energia.'
          : 'Your body is actively breaking down stored fat into fatty acids to use as energy.';
  String get metabolicPhase4Title =>
      _isPt ? 'Cetose activa' : 'Active ketosis';
  String get metabolicPhase4Body =>
      _isPt
          ? 'O fígado está a produzir cetonas a partir da gordura armazenada — a sua principal fonte de energia agora é a gordura pura.'
          : 'Your liver is producing ketones from stored fat — your primary energy source is now pure fat.';

  // ── Misc home screens ────────────────────────────────────────────────
  String get concluido => _isPt ? 'concluído' : 'completed';
  String get semJejumActivo => _isPt ? 'sem jejum activo' : 'no active fast';
  String get iniciaJejum => _isPt ? 'Inicia um jejum para começar' : 'Start a fast to begin';
  String get metaAtingida => _isPt ? 'Meta atingida!' : 'Goal reached!';
  String get semJejum => _isPt ? 'sem jejum' : 'no fast';
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['pt', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
