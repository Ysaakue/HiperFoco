// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'HiperFoco';

  @override
  String get navHome => 'Início';

  @override
  String get navTasks => 'Tarefas';

  @override
  String get navCalendar => 'Calendário';

  @override
  String get navStats => 'Estatísticas';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsAppearance => 'Aparência';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Escuro';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageEnglish => 'Inglês';

  @override
  String get comingSoon => 'Em breve';

  @override
  String get save => 'Salvar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String get requiredField => 'Este campo é obrigatório';

  @override
  String get noCategoriesYet =>
      'Nenhuma categoria ainda. Toque em + para criar.';

  @override
  String get addCategory => 'Adicionar categoria';

  @override
  String get editCategory => 'Editar categoria';

  @override
  String get categoryName => 'Nome';

  @override
  String get categoryColor => 'Cor';

  @override
  String get categoryIcon => 'Ícone';

  @override
  String get categoryArchive => 'Arquivar';

  @override
  String get categoryUnarchive => 'Desarquivar';

  @override
  String get showArchivedCategories => 'Mostrar categorias arquivadas';

  @override
  String get hideArchivedCategories => 'Ocultar categorias arquivadas';

  @override
  String get noArchivedCategories => 'Nenhuma categoria arquivada.';

  @override
  String get noTasksYet => 'Nenhuma tarefa ainda. Toque em + para criar.';

  @override
  String get noPendingTasks => 'Nenhuma tarefa pendente.';

  @override
  String get showCompletedTasks => 'Mostrar tarefas concluídas';

  @override
  String get hideCompletedTasks => 'Ocultar tarefas concluídas';

  @override
  String get addTask => 'Adicionar tarefa';

  @override
  String get editTask => 'Editar tarefa';

  @override
  String get taskTitle => 'Título';

  @override
  String get taskDescription => 'Descrição';

  @override
  String get taskCategory => 'Categoria';

  @override
  String get taskDueDate => 'Data limite';

  @override
  String get noDueDate => 'Sem data limite';

  @override
  String get deleteTask => 'Excluir tarefa';

  @override
  String deleteTaskConfirm(String title) {
    return 'Tem certeza que deseja excluir \"$title\"?';
  }

  @override
  String get timerStart => 'Iniciar cronômetro';

  @override
  String get timerPause => 'Pausar';

  @override
  String get timerResume => 'Retomar';

  @override
  String get timerStop => 'Encerrar';

  @override
  String get timerRunning => 'Focando';

  @override
  String get timerPaused => 'Pausado';

  @override
  String get timerTodayCategory => 'Esta categoria hoje';

  @override
  String get timerTodayTotal => 'Hoje';

  @override
  String get timerHistory => 'Histórico';

  @override
  String get timerHistoryToday => 'Hoje';

  @override
  String get timerHistoryEmpty => 'Nenhuma sessão de foco neste dia.';

  @override
  String get timerHistoryUnknownCategory => 'Categoria desconhecida';

  @override
  String timerHistorySessionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessões',
      one: '1 sessão',
    );
    return '$_temp0';
  }

  @override
  String get settingsDataStorage => 'Dados e armazenamento';

  @override
  String get settingsRetentionMonths => 'Excluir histórico com mais de';

  @override
  String settingsRetentionMonthsValue(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months meses',
      one: '1 mês',
    );
    return '$_temp0';
  }

  @override
  String get settingsPurgeNow => 'Excluir agora';

  @override
  String get settingsPurgeConfirmTitle => 'Excluir dados antigos';

  @override
  String settingsPurgeConfirmMessage(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months meses',
      one: '1 mês',
    );
    return 'Isso exclui permanentemente o histórico de foco com mais de $_temp0. Essa ação não pode ser desfeita.';
  }

  @override
  String get settingsPurgeDone => 'Dados antigos excluídos.';

  @override
  String get taskRepeat => 'Repetir';

  @override
  String get recurrenceFrequencyDaily => 'Diariamente';

  @override
  String get recurrenceFrequencyWeekly => 'Semanalmente';

  @override
  String get recurrenceFrequencyMonthly => 'Mensalmente';

  @override
  String get recurrenceEvery => 'A cada';

  @override
  String recurrenceIntervalUnitDaily(int interval) {
    String _temp0 = intl.Intl.pluralLogic(
      interval,
      locale: localeName,
      other: 'dias',
      one: 'dia',
    );
    return '$_temp0';
  }

  @override
  String recurrenceIntervalUnitWeekly(int interval) {
    String _temp0 = intl.Intl.pluralLogic(
      interval,
      locale: localeName,
      other: 'semanas',
      one: 'semana',
    );
    return '$_temp0';
  }

  @override
  String recurrenceIntervalUnitMonthly(int interval) {
    String _temp0 = intl.Intl.pluralLogic(
      interval,
      locale: localeName,
      other: 'meses',
      one: 'mês',
    );
    return '$_temp0';
  }

  @override
  String get recurrenceWeekdayMon => 'Seg';

  @override
  String get recurrenceWeekdayTue => 'Ter';

  @override
  String get recurrenceWeekdayWed => 'Qua';

  @override
  String get recurrenceWeekdayThu => 'Qui';

  @override
  String get recurrenceWeekdayFri => 'Sex';

  @override
  String get recurrenceWeekdaySat => 'Sáb';

  @override
  String get recurrenceWeekdaySun => 'Dom';

  @override
  String get recurrenceEndDate => 'Termina';

  @override
  String get recurrenceNoEndDate => 'Nunca';

  @override
  String get taskReminder => 'Lembrar';

  @override
  String get reminderOffsetAtTime => 'No horário';

  @override
  String get reminderOffset10 => '10 minutos antes';

  @override
  String get reminderOffset30 => '30 minutos antes';

  @override
  String get reminderOffset60 => '1 hora antes';

  @override
  String get reminderOffset1440 => '1 dia antes';

  @override
  String get notificationPermissionDenied =>
      'As notificações estão desativadas. Os lembretes não vão te avisar até você ativá-las nas configurações do sistema.';

  @override
  String get calendarNoTasksForDay => 'Nenhuma tarefa neste dia.';

  @override
  String get calendarTrackedTime => 'Tempo cronometrado';

  @override
  String get calendarMarkDone => 'Marcar como concluída';

  @override
  String get calendarMarkPending => 'Marcar como pendente';

  @override
  String get calendarSkip => 'Pular';

  @override
  String get calendarReset => 'Redefinir';

  @override
  String get calendarSkipped => 'Pulada';

  @override
  String get remindersTitle => 'Lembretes';

  @override
  String get addReminder => 'Adicionar lembrete';

  @override
  String get editReminder => 'Editar lembrete';

  @override
  String get noRemindersYet => 'Nenhum lembrete ainda. Toque em + para criar.';

  @override
  String get reminderMessage => 'Mensagem';

  @override
  String get reminderScheduledAt => 'Data e hora';

  @override
  String get deleteReminder => 'Excluir lembrete';

  @override
  String get deleteReminderConfirm =>
      'Tem certeza que deseja excluir este lembrete?';

  @override
  String get goalsTitle => 'Metas';

  @override
  String get addGoal => 'Adicionar meta';

  @override
  String get editGoal => 'Editar meta';

  @override
  String get noGoalsYet => 'Nenhuma meta ainda. Toque em + para criar.';

  @override
  String get goalTitle => 'Título';

  @override
  String get goalDescription => 'Descrição';

  @override
  String get deleteGoal => 'Excluir meta';

  @override
  String deleteGoalConfirm(String title) {
    return 'Tem certeza que deseja excluir \"$title\"? Todas as etapas dela também serão excluídas.';
  }

  @override
  String get noStepsYet => 'Nenhuma etapa ainda. Adicione uma abaixo.';

  @override
  String get addStepHint => 'Adicionar uma etapa';

  @override
  String get promoteToTask => 'Promover a tarefa';

  @override
  String get promoted => 'Promovida';

  @override
  String get promoteToTaskCategoryPrompt =>
      'Escolha uma categoria para a nova tarefa';
}
