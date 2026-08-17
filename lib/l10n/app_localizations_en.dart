// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HiperFoco';

  @override
  String get navHome => 'Home';

  @override
  String get navTasks => 'Tasks';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navStats => 'Stats';

  @override
  String get navSettings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languagePortuguese => 'Portuguese';

  @override
  String get languageEnglish => 'English';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get requiredField => 'This field is required';

  @override
  String get noCategoriesYet => 'No categories yet. Tap + to create one.';

  @override
  String get addCategory => 'Add category';

  @override
  String get editCategory => 'Edit category';

  @override
  String get categoryName => 'Name';

  @override
  String get categoryColor => 'Color';

  @override
  String get categoryIcon => 'Icon';

  @override
  String get categoryArchive => 'Archive';

  @override
  String get categoryUnarchive => 'Unarchive';

  @override
  String get showArchivedCategories => 'Show archived categories';

  @override
  String get hideArchivedCategories => 'Hide archived categories';

  @override
  String get noArchivedCategories => 'No archived categories.';

  @override
  String get noTasksYet => 'No tasks yet. Tap + to create one.';

  @override
  String get noPendingTasks => 'No pending tasks.';

  @override
  String get showCompletedTasks => 'Show completed tasks';

  @override
  String get hideCompletedTasks => 'Hide completed tasks';

  @override
  String get addTask => 'Add task';

  @override
  String get editTask => 'Edit task';

  @override
  String get taskTitle => 'Title';

  @override
  String get taskDescription => 'Description';

  @override
  String get taskCategory => 'Category';

  @override
  String get taskDueDate => 'Due date';

  @override
  String get noDueDate => 'No due date';

  @override
  String get deleteTask => 'Delete task';

  @override
  String deleteTaskConfirm(String title) {
    return 'Are you sure you want to delete \"$title\"?';
  }

  @override
  String get timerStart => 'Start timer';

  @override
  String get timerPause => 'Pause';

  @override
  String get timerResume => 'Resume';

  @override
  String get timerStop => 'Stop';

  @override
  String get timerRunning => 'Focusing';

  @override
  String get timerPaused => 'Paused';

  @override
  String get timerTodayCategory => 'This category today';

  @override
  String get timerTodayTotal => 'Today';

  @override
  String get timerHistory => 'History';

  @override
  String get timerHistoryToday => 'Today';

  @override
  String get timerHistoryEmpty => 'No focus sessions on this day.';

  @override
  String get timerHistoryUnknownCategory => 'Unknown category';

  @override
  String timerHistorySessionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions',
      one: '1 session',
    );
    return '$_temp0';
  }

  @override
  String get settingsDataStorage => 'Data & storage';

  @override
  String get settingsRetentionMonths => 'Delete history older than';

  @override
  String settingsRetentionMonthsValue(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months months',
      one: '1 month',
    );
    return '$_temp0';
  }

  @override
  String get settingsPurgeNow => 'Purge now';

  @override
  String get settingsPurgeConfirmTitle => 'Purge old data';

  @override
  String settingsPurgeConfirmMessage(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months months',
      one: '1 month',
    );
    return 'This permanently deletes focus history older than $_temp0. This cannot be undone.';
  }

  @override
  String get settingsPurgeDone => 'Old data purged.';

  @override
  String get taskRepeat => 'Repeat';

  @override
  String get recurrenceFrequencyDaily => 'Daily';

  @override
  String get recurrenceFrequencyWeekly => 'Weekly';

  @override
  String get recurrenceFrequencyMonthly => 'Monthly';

  @override
  String get recurrenceEvery => 'Every';

  @override
  String recurrenceIntervalUnitDaily(int interval) {
    String _temp0 = intl.Intl.pluralLogic(
      interval,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return '$_temp0';
  }

  @override
  String recurrenceIntervalUnitWeekly(int interval) {
    String _temp0 = intl.Intl.pluralLogic(
      interval,
      locale: localeName,
      other: 'weeks',
      one: 'week',
    );
    return '$_temp0';
  }

  @override
  String recurrenceIntervalUnitMonthly(int interval) {
    String _temp0 = intl.Intl.pluralLogic(
      interval,
      locale: localeName,
      other: 'months',
      one: 'month',
    );
    return '$_temp0';
  }

  @override
  String get recurrenceWeekdayMon => 'Mon';

  @override
  String get recurrenceWeekdayTue => 'Tue';

  @override
  String get recurrenceWeekdayWed => 'Wed';

  @override
  String get recurrenceWeekdayThu => 'Thu';

  @override
  String get recurrenceWeekdayFri => 'Fri';

  @override
  String get recurrenceWeekdaySat => 'Sat';

  @override
  String get recurrenceWeekdaySun => 'Sun';

  @override
  String get recurrenceEndDate => 'Ends';

  @override
  String get recurrenceNoEndDate => 'Never';

  @override
  String get taskReminder => 'Remind me';

  @override
  String get reminderOffsetAtTime => 'At the due time';

  @override
  String get reminderOffset10 => '10 minutes before';

  @override
  String get reminderOffset30 => '30 minutes before';

  @override
  String get reminderOffset60 => '1 hour before';

  @override
  String get reminderOffset1440 => '1 day before';

  @override
  String get notificationPermissionDenied =>
      'Notifications are disabled. Reminders won\'t alert you until you enable them in system settings.';

  @override
  String get calendarNoTasksForDay => 'No tasks on this day.';

  @override
  String get calendarTrackedTime => 'Tracked time';

  @override
  String get calendarMarkDone => 'Mark done';

  @override
  String get calendarMarkPending => 'Mark pending';

  @override
  String get calendarSkip => 'Skip';

  @override
  String get calendarReset => 'Reset';

  @override
  String get calendarSkipped => 'Skipped';

  @override
  String get remindersTitle => 'Reminders';

  @override
  String get addReminder => 'Add reminder';

  @override
  String get editReminder => 'Edit reminder';

  @override
  String get noRemindersYet => 'No reminders yet. Tap + to create one.';

  @override
  String get reminderMessage => 'Message';

  @override
  String get reminderScheduledAt => 'Date & time';

  @override
  String get deleteReminder => 'Delete reminder';

  @override
  String get deleteReminderConfirm =>
      'Are you sure you want to delete this reminder?';

  @override
  String get goalsTitle => 'Goals';

  @override
  String get addGoal => 'Add goal';

  @override
  String get editGoal => 'Edit goal';

  @override
  String get noGoalsYet => 'No goals yet. Tap + to create one.';

  @override
  String get goalTitle => 'Title';

  @override
  String get goalDescription => 'Description';

  @override
  String get deleteGoal => 'Delete goal';

  @override
  String deleteGoalConfirm(String title) {
    return 'Are you sure you want to delete \"$title\"? All its steps will be deleted too.';
  }

  @override
  String get noStepsYet => 'No steps yet. Add one below.';

  @override
  String get addStepHint => 'Add a step';

  @override
  String get promoteToTask => 'Promote to task';

  @override
  String get promoted => 'Promoted';

  @override
  String get promoteToTaskCategoryPrompt =>
      'Choose a category for the new task';
}
