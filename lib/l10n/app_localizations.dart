import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fil.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('fil'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'CatfiSense'**
  String get appName;

  /// No description provided for @timeJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 min ago} other{{count} min ago}}'**
  String timeMinutesAgo(int count);

  /// No description provided for @timeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour ago} other{{count} hours ago}}'**
  String timeHoursAgo(int count);

  /// No description provided for @timeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String timeDaysAgo(int count);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String durationMinutes(int minutes);

  /// No description provided for @durationUnderMinute.
  ///
  /// In en, this message translates to:
  /// **'under 1m'**
  String get durationUnderMinute;

  /// No description provided for @freshnessUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated {time}'**
  String freshnessUpdated(String time);

  /// No description provided for @freshnessSensorOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'Sensor offline'**
  String get freshnessSensorOfflineTitle;

  /// No description provided for @freshnessSensorOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'The last reading was {time}. Check the sensor device\'s power and internet connection.'**
  String freshnessSensorOfflineBody(String time);

  /// No description provided for @freshnessNoInternetTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get freshnessNoInternetTitle;

  /// No description provided for @freshnessNoInternetBody.
  ///
  /// In en, this message translates to:
  /// **'Showing the last readings received. They will update when you\'re back online.'**
  String get freshnessNoInternetBody;

  /// No description provided for @statusGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get statusGood;

  /// No description provided for @statusWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get statusWarning;

  /// No description provided for @statusCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get statusCritical;

  /// No description provided for @issueLowPh.
  ///
  /// In en, this message translates to:
  /// **'Low pH'**
  String get issueLowPh;

  /// No description provided for @issueHighPh.
  ///
  /// In en, this message translates to:
  /// **'High pH'**
  String get issueHighPh;

  /// No description provided for @issueLowTemperature.
  ///
  /// In en, this message translates to:
  /// **'Low temperature'**
  String get issueLowTemperature;

  /// No description provided for @issueHighTemperature.
  ///
  /// In en, this message translates to:
  /// **'High temperature'**
  String get issueHighTemperature;

  /// No description provided for @issueLowOxygen.
  ///
  /// In en, this message translates to:
  /// **'Low dissolved oxygen'**
  String get issueLowOxygen;

  /// No description provided for @issueHighAmmonia.
  ///
  /// In en, this message translates to:
  /// **'High ammonia'**
  String get issueHighAmmonia;

  /// No description provided for @alertsNav.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alertsNav;

  /// No description provided for @alertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Alert History'**
  String get alertsTitle;

  /// No description provided for @alertsLink.
  ///
  /// In en, this message translates to:
  /// **'Alert history'**
  String get alertsLink;

  /// No description provided for @alertsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the readings. Check your connection and try again.'**
  String get alertsLoadError;

  /// No description provided for @alertsNoReadings.
  ///
  /// In en, this message translates to:
  /// **'No readings were recorded in this period.'**
  String get alertsNoReadings;

  /// No description provided for @alertsNoneTitle.
  ///
  /// In en, this message translates to:
  /// **'No alerts in this period'**
  String get alertsNoneTitle;

  /// No description provided for @alertsNoneBody.
  ///
  /// In en, this message translates to:
  /// **'The pond stayed within the healthy range.'**
  String get alertsNoneBody;

  /// No description provided for @alertsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 alert} other{{count} alerts}}'**
  String alertsCount(int count);

  /// No description provided for @alertsCriticalCount.
  ///
  /// In en, this message translates to:
  /// **'{count} critical'**
  String alertsCriticalCount(int count);

  /// No description provided for @alertsTotalTime.
  ///
  /// In en, this message translates to:
  /// **'{duration} in total'**
  String alertsTotalTime(String duration);

  /// No description provided for @alertOngoing.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get alertOngoing;

  /// No description provided for @alertStartedAt.
  ///
  /// In en, this message translates to:
  /// **'Started {time}'**
  String alertStartedAt(String time);

  /// No description provided for @alertLasted.
  ///
  /// In en, this message translates to:
  /// **'lasted {duration}'**
  String alertLasted(String duration);

  /// No description provided for @alertLowest.
  ///
  /// In en, this message translates to:
  /// **'lowest {value}'**
  String alertLowest(String value);

  /// No description provided for @alertHighest.
  ///
  /// In en, this message translates to:
  /// **'highest {value}'**
  String alertHighest(String value);

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @loadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load this. Check your connection and try again.'**
  String get loadError;

  /// No description provided for @dayToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dayToday;

  /// No description provided for @dayYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dayYesterday;

  /// No description provided for @logTypeFeeding.
  ///
  /// In en, this message translates to:
  /// **'Fed the fish'**
  String get logTypeFeeding;

  /// No description provided for @logTypeWaterChange.
  ///
  /// In en, this message translates to:
  /// **'Changed water'**
  String get logTypeWaterChange;

  /// No description provided for @logTypeAerator.
  ///
  /// In en, this message translates to:
  /// **'Turned on aerator'**
  String get logTypeAerator;

  /// No description provided for @logTypeTreatment.
  ///
  /// In en, this message translates to:
  /// **'Treated the water'**
  String get logTypeTreatment;

  /// No description provided for @logTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get logTypeOther;

  /// No description provided for @logbookNav.
  ///
  /// In en, this message translates to:
  /// **'Logbook'**
  String get logbookNav;

  /// No description provided for @logbookTitle.
  ///
  /// In en, this message translates to:
  /// **'Pond Logbook'**
  String get logbookTitle;

  /// No description provided for @logbookSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record what was done at the pond. Entries also show up on the History charts.'**
  String get logbookSubtitle;

  /// No description provided for @logbookAdd.
  ///
  /// In en, this message translates to:
  /// **'Log activity'**
  String get logbookAdd;

  /// No description provided for @logbookEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No entries yet'**
  String get logbookEmptyTitle;

  /// No description provided for @logbookEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap “Log activity” after feeding the fish, changing water, or treating the pond.'**
  String get logbookEmptyBody;

  /// No description provided for @logbookNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get logbookNoteLabel;

  /// No description provided for @logbookNoteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 2 kg of feed'**
  String get logbookNoteHint;

  /// No description provided for @logbookWhen.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get logbookWhen;

  /// No description provided for @logbookNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get logbookNow;

  /// No description provided for @logbookTodayAt.
  ///
  /// In en, this message translates to:
  /// **'Today, {time}'**
  String logbookTodayAt(String time);

  /// No description provided for @logbookSave.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get logbookSave;

  /// No description provided for @logbookSaved.
  ///
  /// In en, this message translates to:
  /// **'Entry saved'**
  String get logbookSaved;

  /// No description provided for @logbookSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save the entry. Check your connection and try again.'**
  String get logbookSaveError;

  /// No description provided for @logbookDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get logbookDelete;

  /// No description provided for @logbookDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this entry?'**
  String get logbookDeleteConfirmTitle;

  /// No description provided for @logbookDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This can\'t be undone.'**
  String get logbookDeleteConfirmBody;

  /// No description provided for @logbookDeleted.
  ///
  /// In en, this message translates to:
  /// **'Entry deleted'**
  String get logbookDeleted;

  /// No description provided for @logbookDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the entry. Check your connection and try again.'**
  String get logbookDeleteError;

  /// No description provided for @logbookByYou.
  ///
  /// In en, this message translates to:
  /// **'by you'**
  String get logbookByYou;

  /// No description provided for @logbookByOwner.
  ///
  /// In en, this message translates to:
  /// **'by the owner'**
  String get logbookByOwner;

  /// No description provided for @logbookByCaretaker.
  ///
  /// In en, this message translates to:
  /// **'by the caretaker'**
  String get logbookByCaretaker;

  /// No description provided for @logbookChartLegend.
  ///
  /// In en, this message translates to:
  /// **'Dashed lines mark logbook entries.'**
  String get logbookChartLegend;

  /// No description provided for @roleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get roleOwner;

  /// No description provided for @roleCaretaker.
  ///
  /// In en, this message translates to:
  /// **'Caretaker'**
  String get roleCaretaker;

  /// No description provided for @paramTemperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get paramTemperature;

  /// No description provided for @paramOxygen.
  ///
  /// In en, this message translates to:
  /// **'Dissolved oxygen'**
  String get paramOxygen;

  /// No description provided for @paramAmmonia.
  ///
  /// In en, this message translates to:
  /// **'Ammonia'**
  String get paramAmmonia;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'CatfiSense Pond Report'**
  String get reportTitle;

  /// No description provided for @reportPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period: {start} to {end}'**
  String reportPeriod(String start, String end);

  /// No description provided for @reportGenerated.
  ///
  /// In en, this message translates to:
  /// **'Generated {time}'**
  String reportGenerated(String time);

  /// No description provided for @reportSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get reportSummary;

  /// No description provided for @reportReadingsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 reading} other{{count} readings}}'**
  String reportReadingsCount(int count);

  /// No description provided for @reportGoodShare.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of readings were Good'**
  String reportGoodShare(int percent);

  /// No description provided for @reportParameter.
  ///
  /// In en, this message translates to:
  /// **'Parameter'**
  String get reportParameter;

  /// No description provided for @reportLowest.
  ///
  /// In en, this message translates to:
  /// **'Lowest'**
  String get reportLowest;

  /// No description provided for @reportAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get reportAverage;

  /// No description provided for @reportHighest.
  ///
  /// In en, this message translates to:
  /// **'Highest'**
  String get reportHighest;

  /// No description provided for @reportHealthyRange.
  ///
  /// In en, this message translates to:
  /// **'Healthy range'**
  String get reportHealthyRange;

  /// No description provided for @reportGoodReadings.
  ///
  /// In en, this message translates to:
  /// **'Good readings'**
  String get reportGoodReadings;

  /// No description provided for @reportAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get reportAlerts;

  /// No description provided for @reportStarted.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get reportStarted;

  /// No description provided for @reportDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get reportDuration;

  /// No description provided for @reportStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get reportStatus;

  /// No description provided for @reportDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get reportDetails;

  /// No description provided for @reportNoLogs.
  ///
  /// In en, this message translates to:
  /// **'No logbook entries in this period.'**
  String get reportNoLogs;

  /// No description provided for @reportTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get reportTime;

  /// No description provided for @reportActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get reportActivity;

  /// No description provided for @reportNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get reportNote;

  /// No description provided for @reportBy.
  ///
  /// In en, this message translates to:
  /// **'By'**
  String get reportBy;

  /// No description provided for @reportDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily averages'**
  String get reportDaily;

  /// No description provided for @reportDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get reportDate;

  /// No description provided for @reportReadings.
  ///
  /// In en, this message translates to:
  /// **'Readings'**
  String get reportReadings;

  /// No description provided for @reportWorst.
  ///
  /// In en, this message translates to:
  /// **'Worst'**
  String get reportWorst;

  /// No description provided for @reportPage.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {total}'**
  String reportPage(int page, int total);

  /// No description provided for @exportTooltip.
  ///
  /// In en, this message translates to:
  /// **'Export report'**
  String get exportTooltip;

  /// No description provided for @exportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export report'**
  String get exportTitle;

  /// No description provided for @exportPeriod.
  ///
  /// In en, this message translates to:
  /// **'For the period shown: {period}'**
  String exportPeriod(String period);

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'PDF report'**
  String get exportPdf;

  /// No description provided for @exportPdfHint.
  ///
  /// In en, this message translates to:
  /// **'Summary, alerts, logbook, and daily averages'**
  String get exportPdfHint;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Spreadsheet (CSV)'**
  String get exportCsv;

  /// No description provided for @exportCsvHint.
  ///
  /// In en, this message translates to:
  /// **'Every reading, for Excel or Google Sheets'**
  String get exportCsvHint;

  /// No description provided for @exportWorking.
  ///
  /// In en, this message translates to:
  /// **'Preparing the report…'**
  String get exportWorking;

  /// No description provided for @exportNoData.
  ///
  /// In en, this message translates to:
  /// **'There are no readings in this period to export.'**
  String get exportNoData;

  /// No description provided for @exportError.
  ///
  /// In en, this message translates to:
  /// **'Could not create the report. Please try again.'**
  String get exportError;

  /// No description provided for @welcomeLogin.
  ///
  /// In en, this message translates to:
  /// **'LOGIN'**
  String get welcomeLogin;

  /// No description provided for @welcomeSignup.
  ///
  /// In en, this message translates to:
  /// **'SIGN UP'**
  String get welcomeSignup;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginTitle;

  /// No description provided for @fieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone no'**
  String get fieldPhone;

  /// No description provided for @fieldPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get fieldPassword;

  /// No description provided for @fieldPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'enter your password'**
  String get fieldPasswordHint;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get loginPasswordRequired;

  /// No description provided for @loginRememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get loginRememberMe;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get loginForgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'LOGIN'**
  String get loginButton;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an Account? '**
  String get loginNoAccount;

  /// No description provided for @loginSignupLink.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get loginSignupLink;

  /// No description provided for @signupTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signupTitle;

  /// No description provided for @signupConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get signupConfirmPassword;

  /// No description provided for @signupConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get signupConfirmHint;

  /// No description provided for @signupPasswordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get signupPasswordsMismatch;

  /// No description provided for @signupButton.
  ///
  /// In en, this message translates to:
  /// **'CREATE ACCOUNT'**
  String get signupButton;

  /// No description provided for @signupHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an Account? '**
  String get signupHaveAccount;

  /// No description provided for @signupLoginLink.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get signupLoginLink;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'OTP'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send you an SMS with the OTP. Enter the code below.'**
  String get otpSubtitle;

  /// No description provided for @otpEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get otpEnterCode;

  /// No description provided for @otpConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get otpConfirm;

  /// No description provided for @otpResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP in '**
  String get otpResendIn;

  /// No description provided for @otpResend.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get otpResend;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get onboardingFinish;

  /// No description provided for @onboarding1Headline.
  ///
  /// In en, this message translates to:
  /// **'Your pond\'s health\nis in your hands.'**
  String get onboarding1Headline;

  /// No description provided for @onboarding1Body.
  ///
  /// In en, this message translates to:
  /// **'Monitor your catfish pond anytime, anywhere.'**
  String get onboarding1Body;

  /// No description provided for @onboarding2Headline.
  ///
  /// In en, this message translates to:
  /// **'Track what matters\nin real time.'**
  String get onboarding2Headline;

  /// No description provided for @onboarding2Body.
  ///
  /// In en, this message translates to:
  /// **'View pH, temperature, ammonia, and dissolved oxygen readings at a glance.'**
  String get onboarding2Body;

  /// No description provided for @onboarding3Headline.
  ///
  /// In en, this message translates to:
  /// **'Know your pond\'s\ncondition instantly.'**
  String get onboarding3Headline;

  /// No description provided for @onboarding3Body.
  ///
  /// In en, this message translates to:
  /// **'CatfiSense analyzes readings and shows whether your pond is Healthy, Warning, or Critical.'**
  String get onboarding3Body;

  /// No description provided for @onboarding4Headline.
  ///
  /// In en, this message translates to:
  /// **'Get alerts when\naction is needed.'**
  String get onboarding4Headline;

  /// No description provided for @onboarding4Body.
  ///
  /// In en, this message translates to:
  /// **'Receive mobile and SMS alerts with expert-guided recommendations.'**
  String get onboarding4Body;

  /// No description provided for @pondCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Link your pond'**
  String get pondCodeTitle;

  /// No description provided for @pondCodeBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the pond code from your CatfiSense device or from your admin to see your pond readings.'**
  String get pondCodeBody;

  /// No description provided for @pondCodeField.
  ///
  /// In en, this message translates to:
  /// **'Pond code'**
  String get pondCodeField;

  /// No description provided for @pondCodeButton.
  ///
  /// In en, this message translates to:
  /// **'LINK POND'**
  String get pondCodeButton;

  /// No description provided for @pondCodeWrongAccount.
  ///
  /// In en, this message translates to:
  /// **'Wrong account? '**
  String get pondCodeWrongAccount;

  /// No description provided for @pondCodeLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get pondCodeLogout;

  /// No description provided for @pondCodeJoinedOwner.
  ///
  /// In en, this message translates to:
  /// **'Pond linked. You joined as the owner.'**
  String get pondCodeJoinedOwner;

  /// No description provided for @pondCodeJoinedCaretaker.
  ///
  /// In en, this message translates to:
  /// **'Pond linked. You joined as the caretaker.'**
  String get pondCodeJoinedCaretaker;

  /// No description provided for @pondCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter the 8-character pond code'**
  String get pondCodeInvalid;

  /// No description provided for @pondJoinNotFound.
  ///
  /// In en, this message translates to:
  /// **'That pond code was not found. Check it and try again.'**
  String get pondJoinNotFound;

  /// No description provided for @pondJoinNetwork.
  ///
  /// In en, this message translates to:
  /// **'Could not link the pond. Check your connection and try again.'**
  String get pondJoinNetwork;

  /// No description provided for @pondJoinFull.
  ///
  /// In en, this message translates to:
  /// **'This pond already has an owner and a caretaker. Ask the pond owner for help.'**
  String get pondJoinFull;

  /// No description provided for @validatePhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid PH mobile number (09XXXXXXXXX)'**
  String get validatePhone;

  /// No description provided for @validatePasswordLength.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get validatePasswordLength;

  /// No description provided for @validatePasswordCapital.
  ///
  /// In en, this message translates to:
  /// **'Include at least one capital letter'**
  String get validatePasswordCapital;

  /// No description provided for @validatePasswordSymbol.
  ///
  /// In en, this message translates to:
  /// **'Include at least one symbol'**
  String get validatePasswordSymbol;

  /// No description provided for @authPhoneTaken.
  ///
  /// In en, this message translates to:
  /// **'This phone number is already registered.'**
  String get authPhoneTaken;

  /// No description provided for @authWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get authWeakPassword;

  /// No description provided for @authWrongCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect phone number or password.'**
  String get authWrongCredentials;

  /// No description provided for @authRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'Please re-enter your current password to continue.'**
  String get authRecentLogin;

  /// No description provided for @authNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'You need to be logged in to do this.'**
  String get authNotSignedIn;

  /// No description provided for @authSamePhone.
  ///
  /// In en, this message translates to:
  /// **'That is already your registered number.'**
  String get authSamePhone;

  /// No description provided for @authGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get authGeneric;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logoutTitle;

  /// No description provided for @logoutBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need to log in again to access your pond data.'**
  String get logoutBody;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logoutConfirm;

  /// No description provided for @commonChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get commonChecking;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get commonLoading;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsLoggedInAs.
  ///
  /// In en, this message translates to:
  /// **'Logged in as'**
  String get settingsLoggedInAs;

  /// No description provided for @settingsUnknownNumber.
  ///
  /// In en, this message translates to:
  /// **'Unknown number'**
  String get settingsUnknownNumber;

  /// No description provided for @settingsRole.
  ///
  /// In en, this message translates to:
  /// **'Pond role'**
  String get settingsRole;

  /// No description provided for @settingsRoleOwner.
  ///
  /// In en, this message translates to:
  /// **'Pond owner'**
  String get settingsRoleOwner;

  /// No description provided for @settingsRoleOwnerHint.
  ///
  /// In en, this message translates to:
  /// **'You can invite or remove the caretaker'**
  String get settingsRoleOwnerHint;

  /// No description provided for @settingsRoleCaretakerHint.
  ///
  /// In en, this message translates to:
  /// **'You can view this pond\'s readings'**
  String get settingsRoleCaretakerHint;

  /// No description provided for @settingsRoleNone.
  ///
  /// In en, this message translates to:
  /// **'Not linked to a pond'**
  String get settingsRoleNone;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsDarkModeHint.
  ///
  /// In en, this message translates to:
  /// **'Easier on the eyes at night'**
  String get settingsDarkModeHint;

  /// No description provided for @settingsTextSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get settingsTextSize;

  /// No description provided for @textSizeSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get textSizeSmall;

  /// No description provided for @textSizeDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get textSizeDefault;

  /// No description provided for @textSizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get textSizeLarge;

  /// No description provided for @textSizeExtraLarge.
  ///
  /// In en, this message translates to:
  /// **'Extra large'**
  String get textSizeExtraLarge;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'Phone default'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsPush.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get settingsPush;

  /// No description provided for @settingsPushHint.
  ///
  /// In en, this message translates to:
  /// **'In-app alerts when a reading turns risky'**
  String get settingsPushHint;

  /// No description provided for @settingsSms.
  ///
  /// In en, this message translates to:
  /// **'SMS Alerts'**
  String get settingsSms;

  /// No description provided for @settingsSmsHint.
  ///
  /// In en, this message translates to:
  /// **'Text messages straight from the pond device'**
  String get settingsSmsHint;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsAboutApp.
  ///
  /// In en, this message translates to:
  /// **'About CatfiSense'**
  String get settingsAboutApp;

  /// No description provided for @settingsAboutAppHint.
  ///
  /// In en, this message translates to:
  /// **'What the app does and how it works'**
  String get settingsAboutAppHint;

  /// No description provided for @membersTitle.
  ///
  /// In en, this message translates to:
  /// **'Pond members'**
  String get membersTitle;

  /// No description provided for @membersLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load pond members'**
  String get membersLoadError;

  /// No description provided for @membersNoCaretaker.
  ///
  /// In en, this message translates to:
  /// **'No caretaker yet'**
  String get membersNoCaretaker;

  /// No description provided for @membersInviteHint.
  ///
  /// In en, this message translates to:
  /// **'To invite one, send them the pond code below. They sign up in the app and enter it.'**
  String get membersInviteHint;

  /// No description provided for @membersNoPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number not available'**
  String get membersNoPhone;

  /// No description provided for @membersRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get membersRemove;

  /// No description provided for @membersNoCode.
  ///
  /// In en, this message translates to:
  /// **'No code set'**
  String get membersNoCode;

  /// No description provided for @membersCopyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy pond code'**
  String get membersCopyCode;

  /// No description provided for @membersCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Pond code copied'**
  String get membersCodeCopied;

  /// No description provided for @membersChangeCode.
  ///
  /// In en, this message translates to:
  /// **'Change pond code'**
  String get membersChangeCode;

  /// No description provided for @membersChangeCodeHint.
  ///
  /// In en, this message translates to:
  /// **'The old code stops working. Members stay in.'**
  String get membersChangeCodeHint;

  /// No description provided for @membersChangeCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Change pond code?'**
  String get membersChangeCodeTitle;

  /// No description provided for @membersChangeCodeBody.
  ///
  /// In en, this message translates to:
  /// **'{code} will stop working. Anyone already in the pond stays in.'**
  String membersChangeCodeBody(String code);

  /// No description provided for @membersChangeCodeBodyUnknown.
  ///
  /// In en, this message translates to:
  /// **'The current code will stop working. Anyone already in the pond stays in.'**
  String get membersChangeCodeBodyUnknown;

  /// No description provided for @membersChangeCodeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Change code'**
  String get membersChangeCodeConfirm;

  /// No description provided for @membersChangeCodeError.
  ///
  /// In en, this message translates to:
  /// **'Could not change the code. Check your connection and try again.'**
  String get membersChangeCodeError;

  /// No description provided for @membersNewCode.
  ///
  /// In en, this message translates to:
  /// **'New pond code: {code}'**
  String membersNewCode(String code);

  /// No description provided for @membersTheCaretaker.
  ///
  /// In en, this message translates to:
  /// **'The caretaker'**
  String get membersTheCaretaker;

  /// No description provided for @membersRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove caretaker?'**
  String get membersRemoveTitle;

  /// No description provided for @membersRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'{who} will lose access to this pond right away.\n\nThey could still rejoin with the current pond code, so change the code too if you don\'t want them back.'**
  String membersRemoveBody(String who);

  /// No description provided for @membersRemoveAndChange.
  ///
  /// In en, this message translates to:
  /// **'Remove & change code'**
  String get membersRemoveAndChange;

  /// No description provided for @membersRemoved.
  ///
  /// In en, this message translates to:
  /// **'Caretaker removed'**
  String get membersRemoved;

  /// No description provided for @membersRemoveError.
  ///
  /// In en, this message translates to:
  /// **'Could not remove the caretaker. Check your connection and try again.'**
  String get membersRemoveError;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'CLOSE'**
  String get commonClose;

  /// No description provided for @statusBannerGood.
  ///
  /// In en, this message translates to:
  /// **'Pond health is good.'**
  String get statusBannerGood;

  /// No description provided for @statusBannerWarning.
  ///
  /// In en, this message translates to:
  /// **'Pond health warning.'**
  String get statusBannerWarning;

  /// No description provided for @statusBannerCritical.
  ///
  /// In en, this message translates to:
  /// **'Pond health is critical.'**
  String get statusBannerCritical;

  /// No description provided for @phiHealthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get phiHealthy;

  /// No description provided for @phiOverall.
  ///
  /// In en, this message translates to:
  /// **'Overall PHI'**
  String get phiOverall;

  /// No description provided for @batteryLabel.
  ///
  /// In en, this message translates to:
  /// **'Device Battery'**
  String get batteryLabel;

  /// No description provided for @cardWhatItMeasures.
  ///
  /// In en, this message translates to:
  /// **'What it measures'**
  String get cardWhatItMeasures;

  /// No description provided for @cardWhyItMatters.
  ///
  /// In en, this message translates to:
  /// **'Why it matters'**
  String get cardWhyItMatters;

  /// No description provided for @cardOptimalRange.
  ///
  /// In en, this message translates to:
  /// **'Optimal range'**
  String get cardOptimalRange;

  /// No description provided for @cardPhLabel.
  ///
  /// In en, this message translates to:
  /// **'pH Level'**
  String get cardPhLabel;

  /// No description provided for @cardPhDescription.
  ///
  /// In en, this message translates to:
  /// **'pH shows how acidic or alkaline the pond water is.'**
  String get cardPhDescription;

  /// No description provided for @cardPhImpact.
  ///
  /// In en, this message translates to:
  /// **'Large or rapid pH changes can stress fish and affect gill function. pH also changes how toxic ammonia is to fish.'**
  String get cardPhImpact;

  /// No description provided for @cardTemperatureDescription.
  ///
  /// In en, this message translates to:
  /// **'Water temperature measures how warm or cool the pond is.'**
  String get cardTemperatureDescription;

  /// No description provided for @cardTemperatureImpact.
  ///
  /// In en, this message translates to:
  /// **'Temperature affects fish metabolism, appetite, growth, and oxygen demand. Warmer water also holds less dissolved oxygen.'**
  String get cardTemperatureImpact;

  /// No description provided for @cardOxygenDescription.
  ///
  /// In en, this message translates to:
  /// **'Dissolved oxygen (DO) is the oxygen available in the water for fish to breathe.'**
  String get cardOxygenDescription;

  /// No description provided for @cardOxygenImpact.
  ///
  /// In en, this message translates to:
  /// **'Low DO can cause stress, poor feeding, gasping at the surface, and fish deaths.'**
  String get cardOxygenImpact;

  /// No description provided for @cardAmmoniaDescription.
  ///
  /// In en, this message translates to:
  /// **'Ammonia comes mainly from fish waste and uneaten feed.'**
  String get cardAmmoniaDescription;

  /// No description provided for @cardAmmoniaImpact.
  ///
  /// In en, this message translates to:
  /// **'Ammonia can damage fish gills. Its toxic effect increases with higher pH and temperature.'**
  String get cardAmmoniaImpact;

  /// No description provided for @chartTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get chartTime;

  /// No description provided for @chartTemperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature (°C)'**
  String get chartTemperature;

  /// No description provided for @chartAmmoniaTitle.
  ///
  /// In en, this message translates to:
  /// **'Ammonia (NH₃)'**
  String get chartAmmoniaTitle;

  /// No description provided for @chartAmmoniaAxis.
  ///
  /// In en, this message translates to:
  /// **'Ammonia (mg/L)'**
  String get chartAmmoniaAxis;

  /// No description provided for @chartOxygenTitle.
  ///
  /// In en, this message translates to:
  /// **'Dissolved Oxygen (DO)'**
  String get chartOxygenTitle;

  /// No description provided for @chartOxygenAxis.
  ///
  /// In en, this message translates to:
  /// **'Dissolved Oxygen (mg/L)'**
  String get chartOxygenAxis;

  /// No description provided for @chartNoReadingsInRange.
  ///
  /// In en, this message translates to:
  /// **'No readings within the displayed range.'**
  String get chartNoReadingsInRange;

  /// No description provided for @chartNoReadingsInParameterRanges.
  ///
  /// In en, this message translates to:
  /// **'No readings within the displayed parameter ranges.'**
  String get chartNoReadingsInParameterRanges;

  /// No description provided for @rangeDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get rangeDaily;

  /// No description provided for @rangeWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get rangeWeekly;

  /// No description provided for @rangeMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get rangeMonthly;

  /// No description provided for @rangeCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get rangeCustom;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Water Parameter History'**
  String get historyTitle;

  /// No description provided for @historyNoReadings.
  ///
  /// In en, this message translates to:
  /// **'No readings recorded in this range yet.'**
  String get historyNoReadings;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get navInsights;

  /// No description provided for @refreshNoReadings.
  ///
  /// In en, this message translates to:
  /// **'No sensor readings are available yet.'**
  String get refreshNoReadings;

  /// No description provided for @refreshDone.
  ///
  /// In en, this message translates to:
  /// **'Latest sensor reading refreshed.'**
  String get refreshDone;

  /// No description provided for @refreshError.
  ///
  /// In en, this message translates to:
  /// **'Could not refresh sensor readings.'**
  String get refreshError;

  /// No description provided for @monitoringLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest: pH {ph} • {temperature}°C • DO {oxygen}'**
  String monitoringLatest(String ph, String temperature, String oxygen);

  /// No description provided for @monitoringWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the latest pond sensor reading.'**
  String get monitoringWaiting;

  /// No description provided for @monitoringActive.
  ///
  /// In en, this message translates to:
  /// **'Monitoring the latest pond sensor reading.'**
  String get monitoringActive;

  /// No description provided for @dashboardNoReadingsTitle.
  ///
  /// In en, this message translates to:
  /// **'No readings yet'**
  String get dashboardNoReadingsTitle;

  /// No description provided for @dashboardNoReadingsBody.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the pond sensor to send its first reading.\nTap refresh to check again.'**
  String get dashboardNoReadingsBody;

  /// No description provided for @dashboardViewRecommendations.
  ///
  /// In en, this message translates to:
  /// **'View recommendations'**
  String get dashboardViewRecommendations;

  /// No description provided for @dashboardSeeWhatToDo.
  ///
  /// In en, this message translates to:
  /// **'See what to do'**
  String get dashboardSeeWhatToDo;

  /// No description provided for @dashboardSensorReadings.
  ///
  /// In en, this message translates to:
  /// **'Sensor Readings'**
  String get dashboardSensorReadings;

  /// No description provided for @dashboardPhiTrend.
  ///
  /// In en, this message translates to:
  /// **'PHI Trend'**
  String get dashboardPhiTrend;

  /// No description provided for @dashboardPhiSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily pond health index'**
  String get dashboardPhiSubtitle;

  /// No description provided for @dashboardPhiEmpty.
  ///
  /// In en, this message translates to:
  /// **'No PHI readings recorded today yet.'**
  String get dashboardPhiEmpty;

  /// No description provided for @dashboardViewAllReadings.
  ///
  /// In en, this message translates to:
  /// **'View all readings'**
  String get dashboardViewAllReadings;

  /// No description provided for @aboutTagline.
  ///
  /// In en, this message translates to:
  /// **'Smart water-quality monitoring for catfish ponds.'**
  String get aboutTagline;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutVersion(String version);

  /// No description provided for @aboutWhatItDoes.
  ///
  /// In en, this message translates to:
  /// **'What it does'**
  String get aboutWhatItDoes;

  /// No description provided for @aboutWhatItDoesBody.
  ///
  /// In en, this message translates to:
  /// **'CatfiSense watches your pond water around the clock. A sensor device in the pond measures the water every few seconds, and this app shows the readings live, keeps their history, and tells you what to do when something drifts out of the safe range.'**
  String get aboutWhatItDoesBody;

  /// No description provided for @aboutWhatItMonitors.
  ///
  /// In en, this message translates to:
  /// **'What it monitors'**
  String get aboutWhatItMonitors;

  /// No description provided for @aboutPhBody.
  ///
  /// In en, this message translates to:
  /// **'How acidic or alkaline the water is. Big swings stress the fish.'**
  String get aboutPhBody;

  /// No description provided for @aboutTemperatureBody.
  ///
  /// In en, this message translates to:
  /// **'Affects how much catfish eat, how fast they grow, and how much oxygen they need.'**
  String get aboutTemperatureBody;

  /// No description provided for @aboutOxygenBody.
  ///
  /// In en, this message translates to:
  /// **'The oxygen available to the fish. Low oxygen is a common cause of sudden fish kills.'**
  String get aboutOxygenBody;

  /// No description provided for @aboutAmmoniaBody.
  ///
  /// In en, this message translates to:
  /// **'Builds up from fish waste and leftover feed. High levels harm the gills and slow growth.'**
  String get aboutAmmoniaBody;

  /// No description provided for @aboutPondStatus.
  ///
  /// In en, this message translates to:
  /// **'Pond status'**
  String get aboutPondStatus;

  /// No description provided for @aboutStatusGood.
  ///
  /// In en, this message translates to:
  /// **'All readings are within the healthy range.'**
  String get aboutStatusGood;

  /// No description provided for @aboutStatusWarning.
  ///
  /// In en, this message translates to:
  /// **'A reading is drifting out of range. Check the pond soon.'**
  String get aboutStatusWarning;

  /// No description provided for @aboutStatusCritical.
  ///
  /// In en, this message translates to:
  /// **'A reading is dangerous for the fish. Act now. You also get a push and SMS alert.'**
  String get aboutStatusCritical;

  /// No description provided for @aboutHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get aboutHowItWorks;

  /// No description provided for @aboutStepMeasure.
  ///
  /// In en, this message translates to:
  /// **'1. Measure'**
  String get aboutStepMeasure;

  /// No description provided for @aboutStepMeasureBody.
  ///
  /// In en, this message translates to:
  /// **'The solar-powered sensor device in the pond reads the water every few seconds.'**
  String get aboutStepMeasureBody;

  /// No description provided for @aboutStepSend.
  ///
  /// In en, this message translates to:
  /// **'2. Send'**
  String get aboutStepSend;

  /// No description provided for @aboutStepSendBody.
  ///
  /// In en, this message translates to:
  /// **'Each reading is sent over the internet to the CatfiSense cloud.'**
  String get aboutStepSendBody;

  /// No description provided for @aboutStepAlert.
  ///
  /// In en, this message translates to:
  /// **'3. Alert'**
  String get aboutStepAlert;

  /// No description provided for @aboutStepAlertBody.
  ///
  /// In en, this message translates to:
  /// **'The app shows live readings, history and recommendations, and warns you by push notification and SMS when the pond needs attention.'**
  String get aboutStepAlertBody;

  /// No description provided for @recWhatToDo.
  ///
  /// In en, this message translates to:
  /// **'What you should do'**
  String get recWhatToDo;

  /// No description provided for @recSortedByUrgency.
  ///
  /// In en, this message translates to:
  /// **'Sorted by urgency — handle critical items first.'**
  String get recSortedByUrgency;

  /// No description provided for @recNoActionTitle.
  ///
  /// In en, this message translates to:
  /// **'No action needed'**
  String get recNoActionTitle;

  /// No description provided for @recNoActionBody.
  ///
  /// In en, this message translates to:
  /// **'All sensor readings are within the healthy range.'**
  String get recNoActionBody;

  /// No description provided for @recWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 parameter needs attention} other{{count} parameters need attention}}'**
  String recWarningTitle(int count);

  /// No description provided for @recWarningBody.
  ///
  /// In en, this message translates to:
  /// **'Take the steps below soon to keep the pond healthy.'**
  String get recWarningBody;

  /// No description provided for @recCriticalTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 parameter critical} other{{count} parameters critical}}'**
  String recCriticalTitle(int count);

  /// No description provided for @recCriticalBody.
  ///
  /// In en, this message translates to:
  /// **'Act now — fish health may be at risk.'**
  String get recCriticalBody;

  /// No description provided for @recAllClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Pond conditions look great'**
  String get recAllClearTitle;

  /// No description provided for @recAllClearBody.
  ///
  /// In en, this message translates to:
  /// **'No corrective action needed right now. Keep up the good care!'**
  String get recAllClearBody;

  /// No description provided for @recTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'General Pond Care Tips'**
  String get recTipsTitle;

  /// No description provided for @recPhLowCritical1.
  ///
  /// In en, this message translates to:
  /// **'Apply agricultural lime immediately to raise pH and stop feeding until levels recover.'**
  String get recPhLowCritical1;

  /// No description provided for @recPhLowCritical2.
  ///
  /// In en, this message translates to:
  /// **'Increase water exchange to dilute acidity.'**
  String get recPhLowCritical2;

  /// No description provided for @recRetestPh.
  ///
  /// In en, this message translates to:
  /// **'Re-test pH after 2-3 hours, then again the next morning.'**
  String get recRetestPh;

  /// No description provided for @recPhLowWarning1.
  ///
  /// In en, this message translates to:
  /// **'Add agricultural lime in small doses and recheck after a few hours.'**
  String get recPhLowWarning1;

  /// No description provided for @recPhLowWarning2.
  ///
  /// In en, this message translates to:
  /// **'Avoid adding more feed than the fish can finish in 15-20 minutes.'**
  String get recPhLowWarning2;

  /// No description provided for @recPhHighCritical1.
  ///
  /// In en, this message translates to:
  /// **'Perform a partial water change immediately to bring pH back down.'**
  String get recPhHighCritical1;

  /// No description provided for @recPhHighCritical2.
  ///
  /// In en, this message translates to:
  /// **'Hold off on liming, fertilizing, or feeding until pH stabilizes.'**
  String get recPhHighCritical2;

  /// No description provided for @recPhHighWarning1.
  ///
  /// In en, this message translates to:
  /// **'Partially replace pond water with fresh water to ease pH back into range.'**
  String get recPhHighWarning1;

  /// No description provided for @recPhHighWarning2.
  ///
  /// In en, this message translates to:
  /// **'Avoid liming or fertilizing the pond until the next reading.'**
  String get recPhHighWarning2;

  /// No description provided for @recTempLowCritical1.
  ///
  /// In en, this message translates to:
  /// **'Shield the pond from cold wind and avoid handling fish until the water warms up.'**
  String get recTempLowCritical1;

  /// No description provided for @recTempLowCritical2.
  ///
  /// In en, this message translates to:
  /// **'Reduce or pause feeding — digestion slows sharply in cold water.'**
  String get recTempLowCritical2;

  /// No description provided for @recTempLowWarning1.
  ///
  /// In en, this message translates to:
  /// **'Reduce feeding frequency slightly while the water stays cool.'**
  String get recTempLowWarning1;

  /// No description provided for @recTempLowWarning2.
  ///
  /// In en, this message translates to:
  /// **'Watch for sluggish feeding behavior, an early sign of cold stress.'**
  String get recTempLowWarning2;

  /// No description provided for @recTempHighCritical1.
  ///
  /// In en, this message translates to:
  /// **'Increase aeration immediately and add cooler water if available.'**
  String get recTempHighCritical1;

  /// No description provided for @recTempHighCritical2.
  ///
  /// In en, this message translates to:
  /// **'Stop feeding until temperature drops back into range.'**
  String get recTempHighCritical2;

  /// No description provided for @recTempHighWarning1.
  ///
  /// In en, this message translates to:
  /// **'Increase aeration and consider shading part of the pond.'**
  String get recTempHighWarning1;

  /// No description provided for @recTempHighWarning2.
  ///
  /// In en, this message translates to:
  /// **'Feed during cooler hours — early morning or late afternoon.'**
  String get recTempHighWarning2;

  /// No description provided for @recDoCritical1.
  ///
  /// In en, this message translates to:
  /// **'Run aerators or paddle the surface immediately — fish are at risk of suffocation.'**
  String get recDoCritical1;

  /// No description provided for @recDoCritical2.
  ///
  /// In en, this message translates to:
  /// **'Stop feeding until oxygen levels recover.'**
  String get recDoCritical2;

  /// No description provided for @recDoCritical3.
  ///
  /// In en, this message translates to:
  /// **'Check for algae die-off or overcrowding as a likely cause.'**
  String get recDoCritical3;

  /// No description provided for @recDoWarning1.
  ///
  /// In en, this message translates to:
  /// **'Turn on aeration, especially in the early morning when DO is lowest.'**
  String get recDoWarning1;

  /// No description provided for @recDoWarning2.
  ///
  /// In en, this message translates to:
  /// **'Reduce feeding slightly to limit oxygen demand from waste breakdown.'**
  String get recDoWarning2;

  /// No description provided for @recAmmoniaCritical1.
  ///
  /// In en, this message translates to:
  /// **'Perform an immediate partial water change to dilute ammonia.'**
  String get recAmmoniaCritical1;

  /// No description provided for @recAmmoniaCritical2.
  ///
  /// In en, this message translates to:
  /// **'Stop feeding and remove any leftover feed or decaying matter.'**
  String get recAmmoniaCritical2;

  /// No description provided for @recAmmoniaCritical3.
  ///
  /// In en, this message translates to:
  /// **'Re-test after the water change and hold off on restocking until levels drop.'**
  String get recAmmoniaCritical3;

  /// No description provided for @recAmmoniaWarning1.
  ///
  /// In en, this message translates to:
  /// **'Reduce the feeding amount and remove uneaten feed promptly.'**
  String get recAmmoniaWarning1;

  /// No description provided for @recAmmoniaWarning2.
  ///
  /// In en, this message translates to:
  /// **'Check for overfeeding or waste buildup at the pond bottom.'**
  String get recAmmoniaWarning2;

  /// No description provided for @recTip1.
  ///
  /// In en, this message translates to:
  /// **'Test water quality at the same time each day so trends stay comparable.'**
  String get recTip1;

  /// No description provided for @recTip2.
  ///
  /// In en, this message translates to:
  /// **'Keep a feeding log — overfeeding is the most common cause of ammonia spikes.'**
  String get recTip2;

  /// No description provided for @recTip3.
  ///
  /// In en, this message translates to:
  /// **'Clean and recalibrate sensors regularly to keep readings trustworthy.'**
  String get recTip3;

  /// No description provided for @recTip4.
  ///
  /// In en, this message translates to:
  /// **'Aerate before sunrise, when dissolved oxygen naturally dips lowest.'**
  String get recTip4;

  /// No description provided for @consentTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay on top of your pond'**
  String get consentTitle;

  /// No description provided for @consentBody.
  ///
  /// In en, this message translates to:
  /// **'CatfiSense can alert you the moment a reading turns risky. Choose how you\'d like to hear about it — you can change this anytime in Settings.'**
  String get consentBody;

  /// No description provided for @consentPush.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get consentPush;

  /// No description provided for @consentSms.
  ///
  /// In en, this message translates to:
  /// **'SMS alerts'**
  String get consentSms;

  /// No description provided for @consentContinue.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get consentContinue;

  /// No description provided for @notifAlertsChannel.
  ///
  /// In en, this message translates to:
  /// **'Pond Alerts'**
  String get notifAlertsChannel;

  /// No description provided for @notifAlertsChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Warnings and critical alerts about pond water quality'**
  String get notifAlertsChannelDescription;

  /// No description provided for @notifMonitoringChannel.
  ///
  /// In en, this message translates to:
  /// **'Pond Monitoring'**
  String get notifMonitoringChannel;

  /// No description provided for @notifMonitoringChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Ongoing pond-monitoring status'**
  String get notifMonitoringChannelDescription;

  /// No description provided for @notifMonitoringTitle.
  ///
  /// In en, this message translates to:
  /// **'Pond monitoring active'**
  String get notifMonitoringTitle;

  /// No description provided for @notifCriticalTitle.
  ///
  /// In en, this message translates to:
  /// **'Pond health is critical'**
  String get notifCriticalTitle;

  /// No description provided for @notifWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Pond health warning'**
  String get notifWarningTitle;

  /// No description provided for @notifCriticalBody.
  ///
  /// In en, this message translates to:
  /// **'One or more readings are critical — check the app and act now.'**
  String get notifCriticalBody;

  /// No description provided for @notifWarningBody.
  ///
  /// In en, this message translates to:
  /// **'A reading has drifted out of the healthy range. Tap to see what to do.'**
  String get notifWarningBody;

  /// No description provided for @notifPushFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Pond alert'**
  String get notifPushFallbackTitle;

  /// No description provided for @notifPushFallbackBody.
  ///
  /// In en, this message translates to:
  /// **'A new pond alert has arrived.'**
  String get notifPushFallbackBody;

  /// No description provided for @fieldAdminUsername.
  ///
  /// In en, this message translates to:
  /// **'Admin username'**
  String get fieldAdminUsername;

  /// No description provided for @loginAsAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin? Log in with your username'**
  String get loginAsAdmin;

  /// No description provided for @loginAsFarmer.
  ///
  /// In en, this message translates to:
  /// **'Log in with a phone number instead'**
  String get loginAsFarmer;

  /// No description provided for @validateAdminUsername.
  ///
  /// In en, this message translates to:
  /// **'Admin usernames look like admin_yourname'**
  String get validateAdminUsername;

  /// No description provided for @smsTitle.
  ///
  /// In en, this message translates to:
  /// **'SMS alert numbers'**
  String get smsTitle;

  /// No description provided for @smsHint.
  ///
  /// In en, this message translates to:
  /// **'The gateway phone texts every pond alert to these numbers.'**
  String get smsHint;

  /// No description provided for @smsNone.
  ///
  /// In en, this message translates to:
  /// **'No numbers yet. Nobody will get SMS alerts.'**
  String get smsNone;

  /// No description provided for @smsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add number'**
  String get smsAdd;

  /// No description provided for @smsAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add an SMS alert number'**
  String get smsAddTitle;

  /// No description provided for @smsAdded.
  ///
  /// In en, this message translates to:
  /// **'Number added'**
  String get smsAdded;

  /// No description provided for @smsRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this number?'**
  String get smsRemoveTitle;

  /// No description provided for @smsRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'{number} will stop getting SMS alerts.'**
  String smsRemoveBody(String number);

  /// No description provided for @smsRemoveLastBody.
  ///
  /// In en, this message translates to:
  /// **'{number} is the only number left. Nobody will get SMS alerts until you add another.'**
  String smsRemoveLastBody(String number);

  /// No description provided for @smsRemoved.
  ///
  /// In en, this message translates to:
  /// **'Number removed'**
  String get smsRemoved;

  /// No description provided for @smsSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Check your connection and try again.'**
  String get smsSaveError;

  /// No description provided for @smsStatusSent.
  ///
  /// In en, this message translates to:
  /// **'sent'**
  String get smsStatusSent;

  /// No description provided for @smsStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'failed'**
  String get smsStatusFailed;

  /// No description provided for @smsStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'rejected'**
  String get smsStatusRejected;

  /// No description provided for @smsStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'expired'**
  String get smsStatusExpired;

  /// No description provided for @smsStatusPending.
  ///
  /// In en, this message translates to:
  /// **'waiting'**
  String get smsStatusPending;

  /// No description provided for @passwordChangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get passwordChangeTitle;

  /// No description provided for @passwordCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get passwordCurrent;

  /// No description provided for @passwordNew.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get passwordNew;

  /// No description provided for @passwordSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get passwordSave;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get passwordChanged;

  /// No description provided for @adminTitle.
  ///
  /// In en, this message translates to:
  /// **'CatfiSense Admin'**
  String get adminTitle;

  /// No description provided for @adminTabHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get adminTabHealth;

  /// No description provided for @adminTabPonds.
  ///
  /// In en, this message translates to:
  /// **'Ponds'**
  String get adminTabPonds;

  /// No description provided for @adminTabUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get adminTabUsers;

  /// No description provided for @adminTabThresholds.
  ///
  /// In en, this message translates to:
  /// **'Ranges'**
  String get adminTabThresholds;

  /// No description provided for @adminTabAudit.
  ///
  /// In en, this message translates to:
  /// **'Audit log'**
  String get adminTabAudit;

  /// No description provided for @adminNoPonds.
  ///
  /// In en, this message translates to:
  /// **'No ponds yet.'**
  String get adminNoPonds;

  /// No description provided for @adminSlotEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get adminSlotEmpty;

  /// No description provided for @adminRemoveOwnerTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove the owner?'**
  String get adminRemoveOwnerTitle;

  /// No description provided for @adminRemoveOwnerBody.
  ///
  /// In en, this message translates to:
  /// **'{who} will lose access to this pond right away, and the owner slot becomes free. The next person to enter the pond code becomes the owner, so consider changing the code too.'**
  String adminRemoveOwnerBody(String who);

  /// No description provided for @adminMemberRemoved.
  ///
  /// In en, this message translates to:
  /// **'Member removed'**
  String get adminMemberRemoved;

  /// No description provided for @adminAdmins.
  ///
  /// In en, this message translates to:
  /// **'Admins ({count})'**
  String adminAdmins(int count);

  /// No description provided for @adminFarmers.
  ///
  /// In en, this message translates to:
  /// **'Farmer accounts ({count})'**
  String adminFarmers(int count);

  /// No description provided for @adminYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get adminYou;

  /// No description provided for @adminJoined.
  ///
  /// In en, this message translates to:
  /// **'signed up {date}'**
  String adminJoined(String date);

  /// No description provided for @healthDevice.
  ///
  /// In en, this message translates to:
  /// **'Sensor device ({device})'**
  String healthDevice(String device);

  /// No description provided for @healthOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get healthOnline;

  /// No description provided for @healthOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get healthOffline;

  /// No description provided for @healthNoReadings24h.
  ///
  /// In en, this message translates to:
  /// **'No readings in the last 24 hours.'**
  String get healthNoReadings24h;

  /// No description provided for @healthLastReading.
  ///
  /// In en, this message translates to:
  /// **'Last reading {time}'**
  String healthLastReading(String time);

  /// No description provided for @healthUploadSpeed.
  ///
  /// In en, this message translates to:
  /// **'Upload speed'**
  String get healthUploadSpeed;

  /// No description provided for @healthUploadSpeedHint.
  ///
  /// In en, this message translates to:
  /// **'Time from the device sending a reading to Firebase storing it (last hour).'**
  String get healthUploadSpeedHint;

  /// No description provided for @healthLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get healthLatest;

  /// No description provided for @healthAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get healthAverage;

  /// No description provided for @healthSlowest.
  ///
  /// In en, this message translates to:
  /// **'Slowest'**
  String get healthSlowest;

  /// No description provided for @healthClockNote.
  ///
  /// In en, this message translates to:
  /// **'Based on the device\'s clock, so small values can be off by a fraction of a second.'**
  String get healthClockNote;

  /// No description provided for @healthLast10Min.
  ///
  /// In en, this message translates to:
  /// **'Readings, last 10 min'**
  String get healthLast10Min;

  /// No description provided for @healthOfExpected.
  ///
  /// In en, this message translates to:
  /// **'{count} of {expected}'**
  String healthOfExpected(int count, int expected);

  /// No description provided for @healthGaps.
  ///
  /// In en, this message translates to:
  /// **'Gaps in the last 24 hours'**
  String get healthGaps;

  /// No description provided for @healthNoGaps.
  ///
  /// In en, this message translates to:
  /// **'No gaps: readings arrived steadily.'**
  String get healthNoGaps;

  /// No description provided for @healthNow.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get healthNow;

  /// No description provided for @healthGateway.
  ///
  /// In en, this message translates to:
  /// **'SMS gateway phone'**
  String get healthGateway;

  /// No description provided for @healthGatewaySeen.
  ///
  /// In en, this message translates to:
  /// **'Last checked in {time}'**
  String healthGatewaySeen(String time);

  /// No description provided for @healthGatewayNever.
  ///
  /// In en, this message translates to:
  /// **'Has not checked in yet. Update the gateway app.'**
  String get healthGatewayNever;

  /// No description provided for @healthNoSms.
  ///
  /// In en, this message translates to:
  /// **'No SMS alerts queued yet.'**
  String get healthNoSms;

  /// No description provided for @healthLastSms.
  ///
  /// In en, this message translates to:
  /// **'Last SMS alert: {status}, {time}'**
  String healthLastSms(String status, String time);

  /// No description provided for @auditSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every change made by admins and pond owners'**
  String get auditSubtitle;

  /// No description provided for @auditEmpty.
  ///
  /// In en, this message translates to:
  /// **'No changes recorded yet.'**
  String get auditEmpty;

  /// No description provided for @auditBy.
  ///
  /// In en, this message translates to:
  /// **'by {name} · {time}'**
  String auditBy(String name, String time);

  /// No description provided for @auditThresholdsChanged.
  ///
  /// In en, this message translates to:
  /// **'Changed the pond ranges'**
  String get auditThresholdsChanged;

  /// No description provided for @auditThresholdsReset.
  ///
  /// In en, this message translates to:
  /// **'Reset the pond ranges to defaults'**
  String get auditThresholdsReset;

  /// No description provided for @auditCaretakerRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed a caretaker'**
  String get auditCaretakerRemoved;

  /// No description provided for @auditOwnerRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed a pond owner'**
  String get auditOwnerRemoved;

  /// No description provided for @auditCodeChanged.
  ///
  /// In en, this message translates to:
  /// **'Changed a pond code'**
  String get auditCodeChanged;

  /// No description provided for @auditRecipientAdded.
  ///
  /// In en, this message translates to:
  /// **'Added an SMS alert number'**
  String get auditRecipientAdded;

  /// No description provided for @auditRecipientRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed an SMS alert number'**
  String get auditRecipientRemoved;

  /// No description provided for @auditLogEntryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted someone\'s logbook entry'**
  String get auditLogEntryDeleted;

  /// No description provided for @auditOther.
  ///
  /// In en, this message translates to:
  /// **'Other change'**
  String get auditOther;

  /// No description provided for @thresholdsTitle.
  ///
  /// In en, this message translates to:
  /// **'Pond health ranges'**
  String get thresholdsTitle;

  /// No description provided for @thresholdsHelp.
  ///
  /// In en, this message translates to:
  /// **'Readings inside the Good range show as Good, inside the Warning range as Warning, and anything outside as Critical. Changes apply to every phone right away.'**
  String get thresholdsHelp;

  /// No description provided for @thresholdsGoodFrom.
  ///
  /// In en, this message translates to:
  /// **'Good from'**
  String get thresholdsGoodFrom;

  /// No description provided for @thresholdsGoodTo.
  ///
  /// In en, this message translates to:
  /// **'Good up to'**
  String get thresholdsGoodTo;

  /// No description provided for @thresholdsWarningFrom.
  ///
  /// In en, this message translates to:
  /// **'Warning from'**
  String get thresholdsWarningFrom;

  /// No description provided for @thresholdsWarningTo.
  ///
  /// In en, this message translates to:
  /// **'Warning up to'**
  String get thresholdsWarningTo;

  /// No description provided for @thresholdsNumberError.
  ///
  /// In en, this message translates to:
  /// **'Enter a number'**
  String get thresholdsNumberError;

  /// No description provided for @thresholdsOrderError.
  ///
  /// In en, this message translates to:
  /// **'The warning range must sit outside the good range, and each lower value must be below the upper one.'**
  String get thresholdsOrderError;

  /// No description provided for @thresholdsSave.
  ///
  /// In en, this message translates to:
  /// **'Save ranges'**
  String get thresholdsSave;

  /// No description provided for @thresholdsNoChanges.
  ///
  /// In en, this message translates to:
  /// **'Nothing changed.'**
  String get thresholdsNoChanges;

  /// No description provided for @thresholdsConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Save these ranges?'**
  String get thresholdsConfirmTitle;

  /// No description provided for @thresholdsConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Every phone will judge readings with the new ranges, and the change is recorded in the audit log.'**
  String get thresholdsConfirmBody;

  /// No description provided for @thresholdsSaved.
  ///
  /// In en, this message translates to:
  /// **'Ranges saved'**
  String get thresholdsSaved;

  /// No description provided for @thresholdsSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save the ranges. Check your connection and try again.'**
  String get thresholdsSaveError;

  /// No description provided for @thresholdsReset.
  ///
  /// In en, this message translates to:
  /// **'Reset to defaults'**
  String get thresholdsReset;

  /// No description provided for @thresholdsResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset to the default ranges?'**
  String get thresholdsResetTitle;

  /// No description provided for @thresholdsResetBody.
  ///
  /// In en, this message translates to:
  /// **'The general catfish guidance ranges will be used again on every phone.'**
  String get thresholdsResetBody;

  /// No description provided for @thresholdsDeviceNote.
  ///
  /// In en, this message translates to:
  /// **'The app, alerts, advice and reports use these ranges. The sensor device still decides when to send SMS alerts with the ranges in its own firmware.'**
  String get thresholdsDeviceNote;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @pondNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Pond name'**
  String get pondNameLabel;

  /// No description provided for @pondNameNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get pondNameNotSet;

  /// No description provided for @pondRename.
  ///
  /// In en, this message translates to:
  /// **'Rename pond'**
  String get pondRename;

  /// No description provided for @pondNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a pond name'**
  String get pondNameRequired;

  /// No description provided for @pondNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Use {max} characters or fewer'**
  String pondNameTooLong(int max);

  /// No description provided for @pondNameSaved.
  ///
  /// In en, this message translates to:
  /// **'Pond renamed'**
  String get pondNameSaved;

  /// No description provided for @pondNameError.
  ///
  /// In en, this message translates to:
  /// **'Could not rename the pond. Check your connection and try again.'**
  String get pondNameError;

  /// No description provided for @auditPondRenamed.
  ///
  /// In en, this message translates to:
  /// **'Renamed a pond'**
  String get auditPondRenamed;

  /// No description provided for @maintenanceNav.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get maintenanceNav;

  /// No description provided for @maintenanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get maintenanceTitle;

  /// No description provided for @maintenanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep the sensors accurate and the internet and SMS alerts running. You get a reminder before each one is due.'**
  String get maintenanceSubtitle;

  /// No description provided for @maintTaskDoElectrolyte.
  ///
  /// In en, this message translates to:
  /// **'DO sensor electrolyte'**
  String get maintTaskDoElectrolyte;

  /// No description provided for @maintTaskDoElectrolyteHint.
  ///
  /// In en, this message translates to:
  /// **'Refill the dissolved oxygen probe\'s electrolyte so DO readings stay accurate.'**
  String get maintTaskDoElectrolyteHint;

  /// No description provided for @maintTaskPhBuffer.
  ///
  /// In en, this message translates to:
  /// **'pH buffer & calibration'**
  String get maintTaskPhBuffer;

  /// No description provided for @maintTaskPhBufferHint.
  ///
  /// In en, this message translates to:
  /// **'Calibrate the pH probe with fresh buffer solutions.'**
  String get maintTaskPhBufferHint;

  /// No description provided for @maintTaskModemLoad.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi modem load'**
  String get maintTaskModemLoad;

  /// No description provided for @maintTaskModemLoadHint.
  ///
  /// In en, this message translates to:
  /// **'Reload the prepaid modem so the sensor can keep sending readings.'**
  String get maintTaskModemLoadHint;

  /// No description provided for @maintTaskGsmLoad.
  ///
  /// In en, this message translates to:
  /// **'SMS gateway load'**
  String get maintTaskGsmLoad;

  /// No description provided for @maintTaskGsmLoadHint.
  ///
  /// In en, this message translates to:
  /// **'Reload the gateway phone\'s SIM so SMS alerts keep going out.'**
  String get maintTaskGsmLoadHint;

  /// No description provided for @maintDoneDoElectrolyte.
  ///
  /// In en, this message translates to:
  /// **'Refilled DO electrolyte'**
  String get maintDoneDoElectrolyte;

  /// No description provided for @maintDonePhBuffer.
  ///
  /// In en, this message translates to:
  /// **'Calibrated pH with new buffer'**
  String get maintDonePhBuffer;

  /// No description provided for @maintDoneModemLoad.
  ///
  /// In en, this message translates to:
  /// **'Loaded the Wi-Fi modem'**
  String get maintDoneModemLoad;

  /// No description provided for @maintDoneGsmLoad.
  ///
  /// In en, this message translates to:
  /// **'Loaded the SMS gateway SIM'**
  String get maintDoneGsmLoad;

  /// No description provided for @maintStatusNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set up'**
  String get maintStatusNotSet;

  /// No description provided for @maintDueIn.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{Due today} =1{Due tomorrow} other{Due in {days} days}}'**
  String maintDueIn(int days);

  /// No description provided for @maintOverdueBy.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day overdue} other{{days} days overdue}}'**
  String maintOverdueBy(int days);

  /// No description provided for @maintLastDone.
  ///
  /// In en, this message translates to:
  /// **'Last done {date} · every {days} days'**
  String maintLastDone(String date, int days);

  /// No description provided for @maintNextDue.
  ///
  /// In en, this message translates to:
  /// **'Next: {date}'**
  String maintNextDue(String date);

  /// No description provided for @maintNotSetBody.
  ///
  /// In en, this message translates to:
  /// **'Tap Set up and pick when it was last done to start the reminders.'**
  String get maintNotSetBody;

  /// No description provided for @maintMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get maintMarkDone;

  /// No description provided for @maintSetUp.
  ///
  /// In en, this message translates to:
  /// **'Set up'**
  String get maintSetUp;

  /// No description provided for @maintEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit schedule'**
  String get maintEdit;

  /// No description provided for @maintDoneOn.
  ///
  /// In en, this message translates to:
  /// **'Done on'**
  String get maintDoneOn;

  /// No description provided for @maintLastDoneOn.
  ///
  /// In en, this message translates to:
  /// **'Last done on'**
  String get maintLastDoneOn;

  /// No description provided for @maintEvery.
  ///
  /// In en, this message translates to:
  /// **'Repeat every (days)'**
  String get maintEvery;

  /// No description provided for @maintEveryInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter 1 to {max} days'**
  String maintEveryInvalid(int max);

  /// No description provided for @maintNoteHintLoad.
  ///
  /// In en, this message translates to:
  /// **'e.g. promo loaded, valid 30 days'**
  String get maintNoteHintLoad;

  /// No description provided for @maintNoteHintProbe.
  ///
  /// In en, this message translates to:
  /// **'e.g. used new buffer pack'**
  String get maintNoteHintProbe;

  /// No description provided for @maintLogNote.
  ///
  /// In en, this message translates to:
  /// **'Also added to the logbook.'**
  String get maintLogNote;

  /// No description provided for @maintSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved. Reminders updated.'**
  String get maintSaved;

  /// No description provided for @maintSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Check your connection and try again.'**
  String get maintSaveError;

  /// No description provided for @maintNotLinked.
  ///
  /// In en, this message translates to:
  /// **'Link a pond first to track its maintenance.'**
  String get maintNotLinked;

  /// No description provided for @maintBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 maintenance task needs attention} other{{count} maintenance tasks need attention}}'**
  String maintBannerTitle(int count);

  /// No description provided for @maintBannerBody.
  ///
  /// In en, this message translates to:
  /// **'{tasks}. Tap to open Maintenance.'**
  String maintBannerBody(String tasks);

  /// No description provided for @notifMaintChannel.
  ///
  /// In en, this message translates to:
  /// **'Maintenance reminders'**
  String get notifMaintChannel;

  /// No description provided for @notifMaintChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Reminders to refill, calibrate and reload before they run out.'**
  String get notifMaintChannelDescription;

  /// No description provided for @notifMaintSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Maintenance due soon'**
  String get notifMaintSoonTitle;

  /// No description provided for @notifMaintSoonBody.
  ///
  /// In en, this message translates to:
  /// **'{task} is due on {date}.'**
  String notifMaintSoonBody(String task, String date);

  /// No description provided for @notifMaintDueTitle.
  ///
  /// In en, this message translates to:
  /// **'Maintenance due today'**
  String get notifMaintDueTitle;

  /// No description provided for @notifMaintDueBody.
  ///
  /// In en, this message translates to:
  /// **'{task} is due today. Mark it done in CatfiSense when finished.'**
  String notifMaintDueBody(String task);

  /// No description provided for @notifMaintOverdueTitle.
  ///
  /// In en, this message translates to:
  /// **'Maintenance overdue'**
  String get notifMaintOverdueTitle;

  /// No description provided for @notifMaintOverdueBody.
  ///
  /// In en, this message translates to:
  /// **'{task} was due on {date}.'**
  String notifMaintOverdueBody(String task, String date);

  /// No description provided for @logTypeMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get logTypeMaintenance;

  /// No description provided for @adminMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get adminMaintenance;

  /// No description provided for @memberNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get memberNameLabel;

  /// No description provided for @memberRename.
  ///
  /// In en, this message translates to:
  /// **'Set name'**
  String get memberRename;

  /// No description provided for @memberRenameHint.
  ///
  /// In en, this message translates to:
  /// **'Shown instead of the phone number. Leave blank to show the number again.'**
  String get memberRenameHint;

  /// No description provided for @memberNameSaved.
  ///
  /// In en, this message translates to:
  /// **'Name saved'**
  String get memberNameSaved;

  /// No description provided for @memberNameError.
  ///
  /// In en, this message translates to:
  /// **'Could not save the name. Check your connection and try again.'**
  String get memberNameError;

  /// No description provided for @auditMemberRenamed.
  ///
  /// In en, this message translates to:
  /// **'Renamed a member'**
  String get auditMemberRenamed;

  /// No description provided for @addPond.
  ///
  /// In en, this message translates to:
  /// **'Add pond'**
  String get addPond;

  /// No description provided for @addPondTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a pond'**
  String get addPondTitle;

  /// No description provided for @addPondBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the device ID the sensor saves its readings under in Firebase (readings/<device ID>). The new pond gets its own join code.'**
  String get addPondBody;

  /// No description provided for @addPondDeviceId.
  ///
  /// In en, this message translates to:
  /// **'Device ID'**
  String get addPondDeviceId;

  /// No description provided for @addPondInvalidId.
  ///
  /// In en, this message translates to:
  /// **'Use 3 to 40 letters, numbers, - or _.'**
  String get addPondInvalidId;

  /// No description provided for @addPondNoReadings.
  ///
  /// In en, this message translates to:
  /// **'No readings found for that device ID. Check it in Firebase under readings.'**
  String get addPondNoReadings;

  /// No description provided for @addPondExists.
  ///
  /// In en, this message translates to:
  /// **'That device is already a pond.'**
  String get addPondExists;

  /// No description provided for @addPondError.
  ///
  /// In en, this message translates to:
  /// **'Could not add the pond. Check your connection and try again.'**
  String get addPondError;

  /// No description provided for @addPondAdded.
  ///
  /// In en, this message translates to:
  /// **'Pond added. Join code: {code}'**
  String addPondAdded(String code);

  /// No description provided for @addPondCreate.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addPondCreate;

  /// No description provided for @auditPondAdded.
  ///
  /// In en, this message translates to:
  /// **'Added a pond'**
  String get auditPondAdded;

  /// No description provided for @adminPondPicker.
  ///
  /// In en, this message translates to:
  /// **'Pond'**
  String get adminPondPicker;

  /// No description provided for @healthGatewayPond1Only.
  ///
  /// In en, this message translates to:
  /// **'The SMS gateway currently serves pond1 only.'**
  String get healthGatewayPond1Only;

  /// No description provided for @maintConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Change this schedule?'**
  String get maintConfirmTitle;

  /// No description provided for @maintConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Reminders for {task} will follow the new schedule:'**
  String maintConfirmBody(String task);

  /// No description provided for @maintChangeLastDone.
  ///
  /// In en, this message translates to:
  /// **'Last done: {from} → {to}'**
  String maintChangeLastDone(String from, String to);

  /// No description provided for @maintChangeInterval.
  ///
  /// In en, this message translates to:
  /// **'Every: {from} → {to} days'**
  String maintChangeInterval(int from, int to);

  /// No description provided for @maintChangeNote.
  ///
  /// In en, this message translates to:
  /// **'Note: {from} → {to}'**
  String maintChangeNote(String from, String to);

  /// No description provided for @maintConfirmYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, change it'**
  String get maintConfirmYes;

  /// No description provided for @auditMaintenanceChanged.
  ///
  /// In en, this message translates to:
  /// **'Changed a maintenance schedule'**
  String get auditMaintenanceChanged;

  /// No description provided for @adminDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Switch to dark mode'**
  String get adminDarkMode;

  /// No description provided for @adminLightMode.
  ///
  /// In en, this message translates to:
  /// **'Switch to light mode'**
  String get adminLightMode;

  /// No description provided for @adminSensorDevice.
  ///
  /// In en, this message translates to:
  /// **'Sensor device'**
  String get adminSensorDevice;

  /// No description provided for @adminPondSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by pond name, ID, code, or phone'**
  String get adminPondSearchHint;

  /// No description provided for @adminNoPondMatch.
  ///
  /// In en, this message translates to:
  /// **'No ponds match your search.'**
  String get adminNoPondMatch;

  /// No description provided for @adminChoosePond.
  ///
  /// In en, this message translates to:
  /// **'Choose a pond'**
  String get adminChoosePond;

  /// No description provided for @adminPondCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 pond} other{{count} ponds}}'**
  String adminPondCount(int count);
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
      <String>['en', 'fil'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fil':
      return AppLocalizationsFil();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
