import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// The application name, shown in the OS and app bar
  ///
  /// In en, this message translates to:
  /// **'HiperFoco'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get navTasks;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languagePortuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get languagePortuguese;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @noCategoriesYet.
  ///
  /// In en, this message translates to:
  /// **'No categories yet. Tap + to create one.'**
  String get noCategoriesYet;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategory;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get editCategory;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get categoryName;

  /// No description provided for @categoryColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get categoryColor;

  /// No description provided for @categoryIcon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get categoryIcon;

  /// No description provided for @categoryArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get categoryArchive;

  /// No description provided for @categoryUnarchive.
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get categoryUnarchive;

  /// No description provided for @showArchivedCategories.
  ///
  /// In en, this message translates to:
  /// **'Show archived categories'**
  String get showArchivedCategories;

  /// No description provided for @hideArchivedCategories.
  ///
  /// In en, this message translates to:
  /// **'Hide archived categories'**
  String get hideArchivedCategories;

  /// No description provided for @noArchivedCategories.
  ///
  /// In en, this message translates to:
  /// **'No archived categories.'**
  String get noArchivedCategories;

  /// No description provided for @noTasksYet.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet. Tap + to create one.'**
  String get noTasksYet;

  /// No description provided for @noPendingTasks.
  ///
  /// In en, this message translates to:
  /// **'No pending tasks.'**
  String get noPendingTasks;

  /// No description provided for @showCompletedTasks.
  ///
  /// In en, this message translates to:
  /// **'Show completed tasks'**
  String get showCompletedTasks;

  /// No description provided for @hideCompletedTasks.
  ///
  /// In en, this message translates to:
  /// **'Hide completed tasks'**
  String get hideCompletedTasks;

  /// No description provided for @addTask.
  ///
  /// In en, this message translates to:
  /// **'Add task'**
  String get addTask;

  /// No description provided for @editTask.
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get editTask;

  /// No description provided for @taskTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get taskTitle;

  /// No description provided for @taskDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get taskDescription;

  /// No description provided for @taskCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get taskCategory;

  /// No description provided for @taskDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get taskDueDate;

  /// No description provided for @noDueDate.
  ///
  /// In en, this message translates to:
  /// **'No due date'**
  String get noDueDate;

  /// No description provided for @deleteTask.
  ///
  /// In en, this message translates to:
  /// **'Delete task'**
  String get deleteTask;

  /// No description provided for @deleteTaskConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"?'**
  String deleteTaskConfirm(String title);

  /// No description provided for @timerStart.
  ///
  /// In en, this message translates to:
  /// **'Start timer'**
  String get timerStart;

  /// No description provided for @timerPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get timerPause;

  /// No description provided for @timerResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get timerResume;

  /// No description provided for @timerStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get timerStop;

  /// No description provided for @timerRunning.
  ///
  /// In en, this message translates to:
  /// **'Focusing'**
  String get timerRunning;

  /// No description provided for @timerPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get timerPaused;

  /// No description provided for @timerTodayCategory.
  ///
  /// In en, this message translates to:
  /// **'This category today'**
  String get timerTodayCategory;

  /// No description provided for @timerTodayTotal.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get timerTodayTotal;

  /// No description provided for @timerHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get timerHistory;

  /// No description provided for @timerHistoryToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get timerHistoryToday;

  /// No description provided for @timerHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No focus sessions on this day.'**
  String get timerHistoryEmpty;

  /// No description provided for @timerHistoryUnknownCategory.
  ///
  /// In en, this message translates to:
  /// **'Unknown category'**
  String get timerHistoryUnknownCategory;

  /// No description provided for @timerHistorySessionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 session} other{{count} sessions}}'**
  String timerHistorySessionCount(int count);

  /// No description provided for @settingsDataStorage.
  ///
  /// In en, this message translates to:
  /// **'Data & storage'**
  String get settingsDataStorage;

  /// No description provided for @settingsRetentionMonths.
  ///
  /// In en, this message translates to:
  /// **'Delete history older than'**
  String get settingsRetentionMonths;

  /// No description provided for @settingsRetentionMonthsValue.
  ///
  /// In en, this message translates to:
  /// **'{months, plural, one{1 month} other{{months} months}}'**
  String settingsRetentionMonthsValue(int months);

  /// No description provided for @settingsPurgeNow.
  ///
  /// In en, this message translates to:
  /// **'Purge now'**
  String get settingsPurgeNow;

  /// No description provided for @settingsPurgeConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Purge old data'**
  String get settingsPurgeConfirmTitle;

  /// No description provided for @settingsPurgeConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes focus history older than {months, plural, one{1 month} other{{months} months}}. This cannot be undone.'**
  String settingsPurgeConfirmMessage(int months);

  /// No description provided for @settingsPurgeDone.
  ///
  /// In en, this message translates to:
  /// **'Old data purged.'**
  String get settingsPurgeDone;

  /// No description provided for @taskRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get taskRepeat;

  /// No description provided for @recurrenceFrequencyDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get recurrenceFrequencyDaily;

  /// No description provided for @recurrenceFrequencyWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get recurrenceFrequencyWeekly;

  /// No description provided for @recurrenceFrequencyMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get recurrenceFrequencyMonthly;

  /// No description provided for @recurrenceEvery.
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get recurrenceEvery;

  /// No description provided for @recurrenceIntervalUnitDaily.
  ///
  /// In en, this message translates to:
  /// **'{interval, plural, one{day} other{days}}'**
  String recurrenceIntervalUnitDaily(int interval);

  /// No description provided for @recurrenceIntervalUnitWeekly.
  ///
  /// In en, this message translates to:
  /// **'{interval, plural, one{week} other{weeks}}'**
  String recurrenceIntervalUnitWeekly(int interval);

  /// No description provided for @recurrenceIntervalUnitMonthly.
  ///
  /// In en, this message translates to:
  /// **'{interval, plural, one{month} other{months}}'**
  String recurrenceIntervalUnitMonthly(int interval);

  /// No description provided for @recurrenceWeekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get recurrenceWeekdayMon;

  /// No description provided for @recurrenceWeekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get recurrenceWeekdayTue;

  /// No description provided for @recurrenceWeekdayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get recurrenceWeekdayWed;

  /// No description provided for @recurrenceWeekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get recurrenceWeekdayThu;

  /// No description provided for @recurrenceWeekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get recurrenceWeekdayFri;

  /// No description provided for @recurrenceWeekdaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get recurrenceWeekdaySat;

  /// No description provided for @recurrenceWeekdaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get recurrenceWeekdaySun;

  /// No description provided for @recurrenceEndDate.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get recurrenceEndDate;

  /// No description provided for @recurrenceNoEndDate.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get recurrenceNoEndDate;

  /// No description provided for @taskReminder.
  ///
  /// In en, this message translates to:
  /// **'Remind me'**
  String get taskReminder;

  /// No description provided for @reminderOffsetAtTime.
  ///
  /// In en, this message translates to:
  /// **'At the due time'**
  String get reminderOffsetAtTime;

  /// No description provided for @reminderOffset10.
  ///
  /// In en, this message translates to:
  /// **'10 minutes before'**
  String get reminderOffset10;

  /// No description provided for @reminderOffset30.
  ///
  /// In en, this message translates to:
  /// **'30 minutes before'**
  String get reminderOffset30;

  /// No description provided for @reminderOffset60.
  ///
  /// In en, this message translates to:
  /// **'1 hour before'**
  String get reminderOffset60;

  /// No description provided for @reminderOffset1440.
  ///
  /// In en, this message translates to:
  /// **'1 day before'**
  String get reminderOffset1440;

  /// No description provided for @notificationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are disabled. Reminders won\'t alert you until you enable them in system settings.'**
  String get notificationPermissionDenied;

  /// No description provided for @calendarNoTasksForDay.
  ///
  /// In en, this message translates to:
  /// **'No tasks on this day.'**
  String get calendarNoTasksForDay;

  /// No description provided for @calendarTrackedTime.
  ///
  /// In en, this message translates to:
  /// **'Tracked time'**
  String get calendarTrackedTime;

  /// No description provided for @calendarMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get calendarMarkDone;

  /// No description provided for @calendarMarkPending.
  ///
  /// In en, this message translates to:
  /// **'Mark pending'**
  String get calendarMarkPending;

  /// No description provided for @calendarSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get calendarSkip;

  /// No description provided for @calendarReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get calendarReset;

  /// No description provided for @calendarSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get calendarSkipped;

  /// No description provided for @remindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersTitle;

  /// No description provided for @addReminder.
  ///
  /// In en, this message translates to:
  /// **'Add reminder'**
  String get addReminder;

  /// No description provided for @editReminder.
  ///
  /// In en, this message translates to:
  /// **'Edit reminder'**
  String get editReminder;

  /// No description provided for @noRemindersYet.
  ///
  /// In en, this message translates to:
  /// **'No reminders yet. Tap + to create one.'**
  String get noRemindersYet;

  /// No description provided for @reminderMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get reminderMessage;

  /// No description provided for @reminderScheduledAt.
  ///
  /// In en, this message translates to:
  /// **'Date & time'**
  String get reminderScheduledAt;

  /// No description provided for @deleteReminder.
  ///
  /// In en, this message translates to:
  /// **'Delete reminder'**
  String get deleteReminder;

  /// No description provided for @deleteReminderConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this reminder?'**
  String get deleteReminderConfirm;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
