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
}
