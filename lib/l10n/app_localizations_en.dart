// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'CatfiSense';

  @override
  String get timeJustNow => 'just now';

  @override
  String timeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count min ago',
      one: '1 min ago',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String durationMinutes(int minutes) {
    return '${minutes}m';
  }

  @override
  String get durationUnderMinute => 'under 1m';

  @override
  String freshnessUpdated(String time) {
    return 'Updated $time';
  }

  @override
  String get freshnessSensorOfflineTitle => 'Sensor offline';

  @override
  String freshnessSensorOfflineBody(String time) {
    return 'The last reading was $time. Check the sensor device\'s power and internet connection.';
  }

  @override
  String get freshnessNoInternetTitle => 'You\'re offline';

  @override
  String get freshnessNoInternetBody =>
      'Showing the last readings received. They will update when you\'re back online.';

  @override
  String get statusGood => 'Good';

  @override
  String get statusWarning => 'Warning';

  @override
  String get statusCritical => 'Critical';

  @override
  String get issueLowPh => 'Low pH';

  @override
  String get issueHighPh => 'High pH';

  @override
  String get issueLowTemperature => 'Low temperature';

  @override
  String get issueHighTemperature => 'High temperature';

  @override
  String get issueLowOxygen => 'Low dissolved oxygen';

  @override
  String get issueHighAmmonia => 'High ammonia';

  @override
  String get alertsNav => 'Alerts';

  @override
  String get alertsTitle => 'Alert History';

  @override
  String get alertsLink => 'Alert history';

  @override
  String get alertsLoadError =>
      'Could not load the readings. Check your connection and try again.';

  @override
  String get alertsNoReadings => 'No readings were recorded in this period.';

  @override
  String get alertsNoneTitle => 'No alerts in this period';

  @override
  String get alertsNoneBody => 'The pond stayed within the healthy range.';

  @override
  String alertsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alerts',
      one: '1 alert',
    );
    return '$_temp0';
  }

  @override
  String alertsCriticalCount(int count) {
    return '$count critical';
  }

  @override
  String alertsTotalTime(String duration) {
    return '$duration in total';
  }

  @override
  String get alertOngoing => 'Ongoing';

  @override
  String alertStartedAt(String time) {
    return 'Started $time';
  }

  @override
  String alertLasted(String duration) {
    return 'lasted $duration';
  }

  @override
  String alertLowest(String value) {
    return 'lowest $value';
  }

  @override
  String alertHighest(String value) {
    return 'highest $value';
  }

  @override
  String get commonCancel => 'Cancel';

  @override
  String get loadError =>
      'Could not load this. Check your connection and try again.';

  @override
  String get dayToday => 'Today';

  @override
  String get dayYesterday => 'Yesterday';

  @override
  String get logTypeFeeding => 'Fed the fish';

  @override
  String get logTypeWaterChange => 'Changed water';

  @override
  String get logTypeAerator => 'Turned on aerator';

  @override
  String get logTypeTreatment => 'Treated the water';

  @override
  String get logTypeOther => 'Other';

  @override
  String get logbookNav => 'Logbook';

  @override
  String get logbookTitle => 'Pond Logbook';

  @override
  String get logbookSubtitle =>
      'Record what was done at the pond. Entries also show up on the History charts.';

  @override
  String get logbookAdd => 'Log activity';

  @override
  String get logbookEmptyTitle => 'No entries yet';

  @override
  String get logbookEmptyBody =>
      'Tap “Log activity” after feeding the fish, changing water, or treating the pond.';

  @override
  String get logbookNoteLabel => 'Note (optional)';

  @override
  String get logbookNoteHint => 'e.g. 2 kg of feed';

  @override
  String get logbookWhen => 'When';

  @override
  String get logbookNow => 'Now';

  @override
  String logbookTodayAt(String time) {
    return 'Today, $time';
  }

  @override
  String get logbookSave => 'SAVE';

  @override
  String get logbookSaved => 'Entry saved';

  @override
  String get logbookSaveError =>
      'Could not save the entry. Check your connection and try again.';

  @override
  String get logbookDelete => 'Delete';

  @override
  String get logbookDeleteConfirmTitle => 'Delete this entry?';

  @override
  String get logbookDeleteConfirmBody => 'This can\'t be undone.';

  @override
  String get logbookDeleted => 'Entry deleted';

  @override
  String get logbookDeleteError =>
      'Could not delete the entry. Check your connection and try again.';

  @override
  String get logbookByYou => 'by you';

  @override
  String get logbookByOwner => 'by the owner';

  @override
  String get logbookByCaretaker => 'by the caretaker';

  @override
  String get logbookChartLegend => 'Dashed lines mark logbook entries.';

  @override
  String get roleOwner => 'Owner';

  @override
  String get roleCaretaker => 'Caretaker';

  @override
  String get paramTemperature => 'Temperature';

  @override
  String get paramOxygen => 'Dissolved oxygen';

  @override
  String get paramAmmonia => 'Ammonia';

  @override
  String get reportTitle => 'CatfiSense Pond Report';

  @override
  String reportPeriod(String start, String end) {
    return 'Period: $start to $end';
  }

  @override
  String reportGenerated(String time) {
    return 'Generated $time';
  }

  @override
  String get reportSummary => 'Summary';

  @override
  String reportReadingsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count readings',
      one: '1 reading',
    );
    return '$_temp0';
  }

  @override
  String reportGoodShare(int percent) {
    return '$percent% of readings were Good';
  }

  @override
  String get reportParameter => 'Parameter';

  @override
  String get reportLowest => 'Lowest';

  @override
  String get reportAverage => 'Average';

  @override
  String get reportHighest => 'Highest';

  @override
  String get reportHealthyRange => 'Healthy range';

  @override
  String get reportGoodReadings => 'Good readings';

  @override
  String get reportAlerts => 'Alerts';

  @override
  String get reportStarted => 'Started';

  @override
  String get reportDuration => 'Duration';

  @override
  String get reportStatus => 'Status';

  @override
  String get reportDetails => 'Details';

  @override
  String get reportNoLogs => 'No logbook entries in this period.';

  @override
  String get reportTime => 'Time';

  @override
  String get reportActivity => 'Activity';

  @override
  String get reportNote => 'Note';

  @override
  String get reportBy => 'By';

  @override
  String get reportDaily => 'Daily averages';

  @override
  String get reportDate => 'Date';

  @override
  String get reportReadings => 'Readings';

  @override
  String get reportWorst => 'Worst';

  @override
  String reportPage(int page, int total) {
    return 'Page $page of $total';
  }

  @override
  String get exportTooltip => 'Export report';

  @override
  String get exportTitle => 'Export report';

  @override
  String exportPeriod(String period) {
    return 'For the period shown: $period';
  }

  @override
  String get exportPdf => 'PDF report';

  @override
  String get exportPdfHint => 'Summary, alerts, logbook, and daily averages';

  @override
  String get exportCsv => 'Spreadsheet (CSV)';

  @override
  String get exportCsvHint => 'Every reading, for Excel or Google Sheets';

  @override
  String get exportWorking => 'Preparing the report…';

  @override
  String get exportNoData => 'There are no readings in this period to export.';

  @override
  String get exportError => 'Could not create the report. Please try again.';

  @override
  String get welcomeLogin => 'LOGIN';

  @override
  String get welcomeSignup => 'SIGN UP';

  @override
  String get loginTitle => 'Log in';

  @override
  String get fieldPhone => 'Phone no';

  @override
  String get fieldPassword => 'Password';

  @override
  String get fieldPasswordHint => 'enter your password';

  @override
  String get loginPasswordRequired => 'Enter your password';

  @override
  String get loginRememberMe => 'Remember Me';

  @override
  String get loginForgotPassword => 'Forgot Password?';

  @override
  String get loginButton => 'LOGIN';

  @override
  String get loginNoAccount => 'Don\'t have an Account? ';

  @override
  String get loginSignupLink => 'Sign up';

  @override
  String get signupTitle => 'Sign up';

  @override
  String get signupConfirmPassword => 'Confirm Password';

  @override
  String get signupConfirmHint => 'Confirm your password';

  @override
  String get signupPasswordsMismatch => 'Passwords do not match';

  @override
  String get signupButton => 'CREATE ACCOUNT';

  @override
  String get signupHaveAccount => 'Already have an Account? ';

  @override
  String get signupLoginLink => 'Login';

  @override
  String get otpTitle => 'OTP';

  @override
  String get otpSubtitle =>
      'We\'ll send you an SMS with the OTP. Enter the code below.';

  @override
  String get otpEnterCode => 'Enter the 6-digit code';

  @override
  String get otpConfirm => 'Confirm';

  @override
  String get otpResendIn => 'Resend OTP in ';

  @override
  String get otpResend => 'Resend OTP';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingFinish => 'Finish';

  @override
  String get onboarding1Headline => 'Your pond\'s health\nis in your hands.';

  @override
  String get onboarding1Body => 'Monitor your catfish pond anytime, anywhere.';

  @override
  String get onboarding2Headline => 'Track what matters\nin real time.';

  @override
  String get onboarding2Body =>
      'View pH, temperature, ammonia, and dissolved oxygen readings at a glance.';

  @override
  String get onboarding3Headline => 'Know your pond\'s\ncondition instantly.';

  @override
  String get onboarding3Body =>
      'CatfiSense analyzes readings and shows whether your pond is Healthy, Warning, or Critical.';

  @override
  String get onboarding4Headline => 'Get alerts when\naction is needed.';

  @override
  String get onboarding4Body =>
      'Receive mobile and SMS alerts with expert-guided recommendations.';

  @override
  String get pondCodeTitle => 'Link your pond';

  @override
  String get pondCodeBody =>
      'Enter the pond code from your CatfiSense device or from your admin to see your pond readings.';

  @override
  String get pondCodeField => 'Pond code';

  @override
  String get pondCodeButton => 'LINK POND';

  @override
  String get pondCodeWrongAccount => 'Wrong account? ';

  @override
  String get pondCodeLogout => 'Log out';

  @override
  String get pondCodeJoinedOwner => 'Pond linked. You joined as the owner.';

  @override
  String get pondCodeJoinedCaretaker =>
      'Pond linked. You joined as the caretaker.';

  @override
  String get pondCodeInvalid => 'Enter the 8-character pond code';

  @override
  String get pondJoinNotFound =>
      'That pond code was not found. Check it and try again.';

  @override
  String get pondJoinNetwork =>
      'Could not link the pond. Check your connection and try again.';

  @override
  String get pondJoinFull =>
      'This pond already has an owner and a caretaker. Ask the pond owner for help.';

  @override
  String get validatePhone => 'Enter a valid PH mobile number (09XXXXXXXXX)';

  @override
  String get validatePasswordLength => 'At least 8 characters';

  @override
  String get validatePasswordCapital => 'Include at least one capital letter';

  @override
  String get validatePasswordSymbol => 'Include at least one symbol';

  @override
  String get authPhoneTaken => 'This phone number is already registered.';

  @override
  String get authWeakPassword => 'Password must be at least 6 characters.';

  @override
  String get authWrongCredentials => 'Incorrect phone number or password.';

  @override
  String get authRecentLogin =>
      'Please re-enter your current password to continue.';

  @override
  String get authNotSignedIn => 'You need to be logged in to do this.';

  @override
  String get authSamePhone => 'That is already your registered number.';

  @override
  String get authGeneric => 'Something went wrong. Please try again.';

  @override
  String get logoutTitle => 'Log out?';

  @override
  String get logoutBody =>
      'You\'ll need to log in again to access your pond data.';

  @override
  String get logoutConfirm => 'Log out';

  @override
  String get commonChecking => 'Checking…';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsLoggedInAs => 'Logged in as';

  @override
  String get settingsUnknownNumber => 'Unknown number';

  @override
  String get settingsRole => 'Pond role';

  @override
  String get settingsRoleOwner => 'Pond owner';

  @override
  String get settingsRoleOwnerHint => 'You can invite or remove the caretaker';

  @override
  String get settingsRoleCaretakerHint => 'You can view this pond\'s readings';

  @override
  String get settingsRoleNone => 'Not linked to a pond';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsDarkModeHint => 'Easier on the eyes at night';

  @override
  String get settingsTextSize => 'Text size';

  @override
  String get textSizeSmall => 'Small';

  @override
  String get textSizeDefault => 'Default';

  @override
  String get textSizeLarge => 'Large';

  @override
  String get textSizeExtraLarge => 'Extra large';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'Phone default';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsPush => 'Push Notifications';

  @override
  String get settingsPushHint => 'In-app alerts when a reading turns risky';

  @override
  String get settingsSms => 'SMS Alerts';

  @override
  String get settingsSmsHint => 'Text messages straight from the pond device';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAboutApp => 'About CatfiSense';

  @override
  String get settingsAboutAppHint => 'What the app does and how it works';

  @override
  String get membersTitle => 'Pond members';

  @override
  String get membersLoadError => 'Could not load pond members';

  @override
  String get membersNoCaretaker => 'No caretaker yet';

  @override
  String get membersInviteHint =>
      'To invite one, send them the pond code below. They sign up in the app and enter it.';

  @override
  String get membersNoPhone => 'Phone number not available';

  @override
  String get membersRemove => 'Remove';

  @override
  String get membersNoCode => 'No code set';

  @override
  String get membersCopyCode => 'Copy pond code';

  @override
  String get membersCodeCopied => 'Pond code copied';

  @override
  String get membersChangeCode => 'Change pond code';

  @override
  String get membersChangeCodeHint =>
      'The old code stops working. Members stay in.';

  @override
  String get membersChangeCodeTitle => 'Change pond code?';

  @override
  String membersChangeCodeBody(String code) {
    return '$code will stop working. Anyone already in the pond stays in.';
  }

  @override
  String get membersChangeCodeBodyUnknown =>
      'The current code will stop working. Anyone already in the pond stays in.';

  @override
  String get membersChangeCodeConfirm => 'Change code';

  @override
  String get membersChangeCodeError =>
      'Could not change the code. Check your connection and try again.';

  @override
  String membersNewCode(String code) {
    return 'New pond code: $code';
  }

  @override
  String get membersTheCaretaker => 'The caretaker';

  @override
  String get membersRemoveTitle => 'Remove caretaker?';

  @override
  String membersRemoveBody(String who) {
    return '$who will lose access to this pond right away.\n\nThey could still rejoin with the current pond code, so change the code too if you don\'t want them back.';
  }

  @override
  String get membersRemoveAndChange => 'Remove & change code';

  @override
  String get membersRemoved => 'Caretaker removed';

  @override
  String get membersRemoveError =>
      'Could not remove the caretaker. Check your connection and try again.';

  @override
  String get commonBack => 'Back';

  @override
  String get commonClose => 'CLOSE';

  @override
  String get statusBannerGood => 'Pond health is good.';

  @override
  String get statusBannerWarning => 'Pond health warning.';

  @override
  String get statusBannerCritical => 'Pond health is critical.';

  @override
  String get phiHealthy => 'Healthy';

  @override
  String get phiOverall => 'Overall PHI';

  @override
  String get batteryLabel => 'Device Battery';

  @override
  String get cardWhatItMeasures => 'What it measures';

  @override
  String get cardWhyItMatters => 'Why it matters';

  @override
  String get cardOptimalRange => 'Optimal range';

  @override
  String get cardPhLabel => 'pH Level';

  @override
  String get cardPhDescription =>
      'pH shows how acidic or alkaline the pond water is.';

  @override
  String get cardPhImpact =>
      'Large or rapid pH changes can stress fish and affect gill function. pH also changes how toxic ammonia is to fish.';

  @override
  String get cardTemperatureDescription =>
      'Water temperature measures how warm or cool the pond is.';

  @override
  String get cardTemperatureImpact =>
      'Temperature affects fish metabolism, appetite, growth, and oxygen demand. Warmer water also holds less dissolved oxygen.';

  @override
  String get cardOxygenDescription =>
      'Dissolved oxygen (DO) is the oxygen available in the water for fish to breathe.';

  @override
  String get cardOxygenImpact =>
      'Low DO can cause stress, poor feeding, gasping at the surface, and fish deaths.';

  @override
  String get cardAmmoniaDescription =>
      'Ammonia comes mainly from fish waste and uneaten feed.';

  @override
  String get cardAmmoniaImpact =>
      'Ammonia can damage fish gills. Its toxic effect increases with higher pH and temperature.';

  @override
  String get chartTime => 'Time';

  @override
  String get chartTemperature => 'Temperature (°C)';

  @override
  String get chartAmmoniaTitle => 'Ammonia (NH₃)';

  @override
  String get chartAmmoniaAxis => 'Ammonia (mg/L)';

  @override
  String get chartOxygenTitle => 'Dissolved Oxygen (DO)';

  @override
  String get chartOxygenAxis => 'Dissolved Oxygen (mg/L)';

  @override
  String get chartNoReadingsInRange =>
      'No readings within the displayed range.';

  @override
  String get chartNoReadingsInParameterRanges =>
      'No readings within the displayed parameter ranges.';

  @override
  String get rangeDaily => 'Daily';

  @override
  String get rangeWeekly => 'Weekly';

  @override
  String get rangeMonthly => 'Monthly';

  @override
  String get rangeCustom => 'Custom';

  @override
  String get historyTitle => 'Water Parameter History';

  @override
  String get historyNoReadings => 'No readings recorded in this range yet.';

  @override
  String get navHome => 'Home';

  @override
  String get navHistory => 'History';

  @override
  String get navInsights => 'Insights';

  @override
  String get refreshNoReadings => 'No sensor readings are available yet.';

  @override
  String get refreshDone => 'Latest sensor reading refreshed.';

  @override
  String get refreshError => 'Could not refresh sensor readings.';

  @override
  String monitoringLatest(String ph, String temperature, String oxygen) {
    return 'Latest: pH $ph • $temperature°C • DO $oxygen';
  }

  @override
  String get monitoringWaiting => 'Waiting for the latest pond sensor reading.';

  @override
  String get monitoringActive => 'Monitoring the latest pond sensor reading.';

  @override
  String get dashboardNoReadingsTitle => 'No readings yet';

  @override
  String get dashboardNoReadingsBody =>
      'Waiting for the pond sensor to send its first reading.\nTap refresh to check again.';

  @override
  String get dashboardViewRecommendations => 'View recommendations';

  @override
  String get dashboardSeeWhatToDo => 'See what to do';

  @override
  String get dashboardSensorReadings => 'Sensor Readings';

  @override
  String get dashboardPhiTrend => 'PHI Trend';

  @override
  String get dashboardPhiSubtitle => 'Daily pond health index';

  @override
  String get dashboardPhiEmpty => 'No PHI readings recorded today yet.';

  @override
  String get dashboardViewAllReadings => 'View all readings';

  @override
  String get aboutTagline =>
      'Smart water-quality monitoring for catfish ponds.';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutWhatItDoes => 'What it does';

  @override
  String get aboutWhatItDoesBody =>
      'CatfiSense watches your pond water around the clock. A sensor device in the pond measures the water every few seconds, and this app shows the readings live, keeps their history, and tells you what to do when something drifts out of the safe range.';

  @override
  String get aboutWhatItMonitors => 'What it monitors';

  @override
  String get aboutPhBody =>
      'How acidic or alkaline the water is. Big swings stress the fish.';

  @override
  String get aboutTemperatureBody =>
      'Affects how much catfish eat, how fast they grow, and how much oxygen they need.';

  @override
  String get aboutOxygenBody =>
      'The oxygen available to the fish. Low oxygen is a common cause of sudden fish kills.';

  @override
  String get aboutAmmoniaBody =>
      'Builds up from fish waste and leftover feed. High levels harm the gills and slow growth.';

  @override
  String get aboutPondStatus => 'Pond status';

  @override
  String get aboutStatusGood => 'All readings are within the healthy range.';

  @override
  String get aboutStatusWarning =>
      'A reading is drifting out of range. Check the pond soon.';

  @override
  String get aboutStatusCritical =>
      'A reading is dangerous for the fish. Act now. You also get a push and SMS alert.';

  @override
  String get aboutHowItWorks => 'How it works';

  @override
  String get aboutStepMeasure => '1. Measure';

  @override
  String get aboutStepMeasureBody =>
      'The solar-powered sensor device in the pond reads the water every few seconds.';

  @override
  String get aboutStepSend => '2. Send';

  @override
  String get aboutStepSendBody =>
      'Each reading is sent over the internet to the CatfiSense cloud.';

  @override
  String get aboutStepAlert => '3. Alert';

  @override
  String get aboutStepAlertBody =>
      'The app shows live readings, history and recommendations, and warns you by push notification and SMS when the pond needs attention.';

  @override
  String get recWhatToDo => 'What you should do';

  @override
  String get recSortedByUrgency =>
      'Sorted by urgency — handle critical items first.';

  @override
  String get recNoActionTitle => 'No action needed';

  @override
  String get recNoActionBody =>
      'All sensor readings are within the healthy range.';

  @override
  String recWarningTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parameters need attention',
      one: '1 parameter needs attention',
    );
    return '$_temp0';
  }

  @override
  String get recWarningBody =>
      'Take the steps below soon to keep the pond healthy.';

  @override
  String recCriticalTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parameters critical',
      one: '1 parameter critical',
    );
    return '$_temp0';
  }

  @override
  String get recCriticalBody => 'Act now — fish health may be at risk.';

  @override
  String get recAllClearTitle => 'Pond conditions look great';

  @override
  String get recAllClearBody =>
      'No corrective action needed right now. Keep up the good care!';

  @override
  String get recTipsTitle => 'General Pond Care Tips';

  @override
  String get recPhLowCritical1 =>
      'Apply agricultural lime immediately to raise pH and stop feeding until levels recover.';

  @override
  String get recPhLowCritical2 => 'Increase water exchange to dilute acidity.';

  @override
  String get recRetestPh =>
      'Re-test pH after 2-3 hours, then again the next morning.';

  @override
  String get recPhLowWarning1 =>
      'Add agricultural lime in small doses and recheck after a few hours.';

  @override
  String get recPhLowWarning2 =>
      'Avoid adding more feed than the fish can finish in 15-20 minutes.';

  @override
  String get recPhHighCritical1 =>
      'Perform a partial water change immediately to bring pH back down.';

  @override
  String get recPhHighCritical2 =>
      'Hold off on liming, fertilizing, or feeding until pH stabilizes.';

  @override
  String get recPhHighWarning1 =>
      'Partially replace pond water with fresh water to ease pH back into range.';

  @override
  String get recPhHighWarning2 =>
      'Avoid liming or fertilizing the pond until the next reading.';

  @override
  String get recTempLowCritical1 =>
      'Shield the pond from cold wind and avoid handling fish until the water warms up.';

  @override
  String get recTempLowCritical2 =>
      'Reduce or pause feeding — digestion slows sharply in cold water.';

  @override
  String get recTempLowWarning1 =>
      'Reduce feeding frequency slightly while the water stays cool.';

  @override
  String get recTempLowWarning2 =>
      'Watch for sluggish feeding behavior, an early sign of cold stress.';

  @override
  String get recTempHighCritical1 =>
      'Increase aeration immediately and add cooler water if available.';

  @override
  String get recTempHighCritical2 =>
      'Stop feeding until temperature drops back into range.';

  @override
  String get recTempHighWarning1 =>
      'Increase aeration and consider shading part of the pond.';

  @override
  String get recTempHighWarning2 =>
      'Feed during cooler hours — early morning or late afternoon.';

  @override
  String get recDoCritical1 =>
      'Run aerators or paddle the surface immediately — fish are at risk of suffocation.';

  @override
  String get recDoCritical2 => 'Stop feeding until oxygen levels recover.';

  @override
  String get recDoCritical3 =>
      'Check for algae die-off or overcrowding as a likely cause.';

  @override
  String get recDoWarning1 =>
      'Turn on aeration, especially in the early morning when DO is lowest.';

  @override
  String get recDoWarning2 =>
      'Reduce feeding slightly to limit oxygen demand from waste breakdown.';

  @override
  String get recAmmoniaCritical1 =>
      'Perform an immediate partial water change to dilute ammonia.';

  @override
  String get recAmmoniaCritical2 =>
      'Stop feeding and remove any leftover feed or decaying matter.';

  @override
  String get recAmmoniaCritical3 =>
      'Re-test after the water change and hold off on restocking until levels drop.';

  @override
  String get recAmmoniaWarning1 =>
      'Reduce the feeding amount and remove uneaten feed promptly.';

  @override
  String get recAmmoniaWarning2 =>
      'Check for overfeeding or waste buildup at the pond bottom.';

  @override
  String get recTip1 =>
      'Test water quality at the same time each day so trends stay comparable.';

  @override
  String get recTip2 =>
      'Keep a feeding log — overfeeding is the most common cause of ammonia spikes.';

  @override
  String get recTip3 =>
      'Clean and recalibrate sensors regularly to keep readings trustworthy.';

  @override
  String get recTip4 =>
      'Aerate before sunrise, when dissolved oxygen naturally dips lowest.';

  @override
  String get consentTitle => 'Stay on top of your pond';

  @override
  String get consentBody =>
      'CatfiSense can alert you the moment a reading turns risky. Choose how you\'d like to hear about it — you can change this anytime in Settings.';

  @override
  String get consentPush => 'Push notifications';

  @override
  String get consentSms => 'SMS alerts';

  @override
  String get consentContinue => 'CONTINUE';

  @override
  String get notifAlertsChannel => 'Pond Alerts';

  @override
  String get notifAlertsChannelDescription =>
      'Warnings and critical alerts about pond water quality';

  @override
  String get notifMonitoringChannel => 'Pond Monitoring';

  @override
  String get notifMonitoringChannelDescription =>
      'Ongoing pond-monitoring status';

  @override
  String get notifMonitoringTitle => 'Pond monitoring active';

  @override
  String get notifCriticalTitle => 'Pond health is critical';

  @override
  String get notifWarningTitle => 'Pond health warning';

  @override
  String get notifCriticalBody =>
      'One or more readings are critical — check the app and act now.';

  @override
  String get notifWarningBody =>
      'A reading has drifted out of the healthy range. Tap to see what to do.';

  @override
  String get notifPushFallbackTitle => 'Pond alert';

  @override
  String get notifPushFallbackBody => 'A new pond alert has arrived.';

  @override
  String get fieldAdminUsername => 'Admin username';

  @override
  String get loginAsAdmin => 'Admin? Log in with your username';

  @override
  String get loginAsFarmer => 'Log in with a phone number instead';

  @override
  String get validateAdminUsername =>
      'Admin usernames look like admin_yourname';

  @override
  String get smsTitle => 'SMS alert numbers';

  @override
  String get smsHint =>
      'The gateway phone texts every pond alert to these numbers.';

  @override
  String get smsNone => 'No numbers yet. Nobody will get SMS alerts.';

  @override
  String get smsAdd => 'Add number';

  @override
  String get smsAddTitle => 'Add an SMS alert number';

  @override
  String get smsAdded => 'Number added';

  @override
  String get smsRemoveTitle => 'Remove this number?';

  @override
  String smsRemoveBody(String number) {
    return '$number will stop getting SMS alerts.';
  }

  @override
  String smsRemoveLastBody(String number) {
    return '$number is the only number left. Nobody will get SMS alerts until you add another.';
  }

  @override
  String get smsRemoved => 'Number removed';

  @override
  String get smsSaveError =>
      'Could not save. Check your connection and try again.';

  @override
  String get smsStatusSent => 'sent';

  @override
  String get smsStatusFailed => 'failed';

  @override
  String get smsStatusRejected => 'rejected';

  @override
  String get smsStatusExpired => 'expired';

  @override
  String get smsStatusPending => 'waiting';

  @override
  String get passwordChangeTitle => 'Change password';

  @override
  String get passwordCurrent => 'Current password';

  @override
  String get passwordNew => 'New password';

  @override
  String get passwordSave => 'Save';

  @override
  String get passwordChanged => 'Password changed';

  @override
  String get adminTitle => 'CatfiSense Admin';

  @override
  String get adminTabHealth => 'Health';

  @override
  String get adminTabPonds => 'Ponds';

  @override
  String get adminTabUsers => 'Users';

  @override
  String get adminTabThresholds => 'Ranges';

  @override
  String get adminTabAudit => 'Audit log';

  @override
  String get adminNoPonds => 'No ponds yet.';

  @override
  String get adminSlotEmpty => 'Empty';

  @override
  String get adminRemoveOwnerTitle => 'Remove the owner?';

  @override
  String adminRemoveOwnerBody(String who) {
    return '$who will lose access to this pond right away, and the owner slot becomes free. The next person to enter the pond code becomes the owner, so consider changing the code too.';
  }

  @override
  String get adminMemberRemoved => 'Member removed';

  @override
  String adminAdmins(int count) {
    return 'Admins ($count)';
  }

  @override
  String adminFarmers(int count) {
    return 'Farmer accounts ($count)';
  }

  @override
  String get adminYou => 'You';

  @override
  String adminJoined(String date) {
    return 'signed up $date';
  }

  @override
  String healthDevice(String device) {
    return 'Sensor device ($device)';
  }

  @override
  String get healthOnline => 'Online';

  @override
  String get healthOffline => 'Offline';

  @override
  String get healthNoReadings24h => 'No readings in the last 24 hours.';

  @override
  String healthLastReading(String time) {
    return 'Last reading $time';
  }

  @override
  String get healthUploadSpeed => 'Upload speed';

  @override
  String get healthUploadSpeedHint =>
      'Time from the device sending a reading to Firebase storing it (last hour).';

  @override
  String get healthLatest => 'Latest';

  @override
  String get healthAverage => 'Average';

  @override
  String get healthSlowest => 'Slowest';

  @override
  String get healthClockNote =>
      'Based on the device\'s clock, so small values can be off by a fraction of a second.';

  @override
  String get healthLast10Min => 'Readings, last 10 min';

  @override
  String healthOfExpected(int count, int expected) {
    return '$count of $expected';
  }

  @override
  String get healthGaps => 'Gaps in the last 24 hours';

  @override
  String get healthNoGaps => 'No gaps: readings arrived steadily.';

  @override
  String get healthNow => 'now';

  @override
  String get healthGateway => 'SMS gateway phone';

  @override
  String healthGatewaySeen(String time) {
    return 'Last checked in $time';
  }

  @override
  String get healthGatewayNever =>
      'Has not checked in yet. Update the gateway app.';

  @override
  String get healthNoSms => 'No SMS alerts queued yet.';

  @override
  String healthLastSms(String status, String time) {
    return 'Last SMS alert: $status, $time';
  }

  @override
  String get auditSubtitle => 'Every change made by admins and pond owners';

  @override
  String get auditEmpty => 'No changes recorded yet.';

  @override
  String auditBy(String name, String time) {
    return 'by $name · $time';
  }

  @override
  String get auditThresholdsChanged => 'Changed the pond ranges';

  @override
  String get auditThresholdsReset => 'Reset the pond ranges to defaults';

  @override
  String get auditCaretakerRemoved => 'Removed a caretaker';

  @override
  String get auditOwnerRemoved => 'Removed a pond owner';

  @override
  String get auditCodeChanged => 'Changed a pond code';

  @override
  String get auditRecipientAdded => 'Added an SMS alert number';

  @override
  String get auditRecipientRemoved => 'Removed an SMS alert number';

  @override
  String get auditLogEntryDeleted => 'Deleted someone\'s logbook entry';

  @override
  String get auditOther => 'Other change';

  @override
  String get thresholdsTitle => 'Pond health ranges';

  @override
  String get thresholdsHelp =>
      'Readings inside the Good range show as Good, inside the Warning range as Warning, and anything outside as Critical. Changes apply to every phone right away.';

  @override
  String get thresholdsGoodFrom => 'Good from';

  @override
  String get thresholdsGoodTo => 'Good up to';

  @override
  String get thresholdsWarningFrom => 'Warning from';

  @override
  String get thresholdsWarningTo => 'Warning up to';

  @override
  String get thresholdsNumberError => 'Enter a number';

  @override
  String get thresholdsOrderError =>
      'The warning range must sit outside the good range, and each lower value must be below the upper one.';

  @override
  String get thresholdsSave => 'Save ranges';

  @override
  String get thresholdsNoChanges => 'Nothing changed.';

  @override
  String get thresholdsConfirmTitle => 'Save these ranges?';

  @override
  String get thresholdsConfirmBody =>
      'Every phone will judge readings with the new ranges, and the change is recorded in the audit log.';

  @override
  String get thresholdsSaved => 'Ranges saved';

  @override
  String get thresholdsSaveError =>
      'Could not save the ranges. Check your connection and try again.';

  @override
  String get thresholdsReset => 'Reset to defaults';

  @override
  String get thresholdsResetTitle => 'Reset to the default ranges?';

  @override
  String get thresholdsResetBody =>
      'The general catfish guidance ranges will be used again on every phone.';

  @override
  String get thresholdsDeviceNote =>
      'The app, alerts, advice and reports use these ranges. The sensor device still decides when to send SMS alerts with the ranges in its own firmware.';

  @override
  String get commonSave => 'Save';

  @override
  String get pondNameLabel => 'Pond name';

  @override
  String get pondNameNotSet => 'Not set';

  @override
  String get pondRename => 'Rename pond';

  @override
  String get pondNameRequired => 'Enter a pond name';

  @override
  String pondNameTooLong(int max) {
    return 'Use $max characters or fewer';
  }

  @override
  String get pondNameSaved => 'Pond renamed';

  @override
  String get pondNameError =>
      'Could not rename the pond. Check your connection and try again.';

  @override
  String get auditPondRenamed => 'Renamed a pond';

  @override
  String get maintenanceNav => 'Maintenance';

  @override
  String get maintenanceTitle => 'Maintenance';

  @override
  String get maintenanceSubtitle =>
      'Keep the sensors accurate and the internet and SMS alerts running. You get a reminder before each one is due.';

  @override
  String get maintTaskDoElectrolyte => 'DO sensor electrolyte';

  @override
  String get maintTaskDoElectrolyteHint =>
      'Refill the dissolved oxygen probe\'s electrolyte so DO readings stay accurate.';

  @override
  String get maintTaskPhBuffer => 'pH buffer & calibration';

  @override
  String get maintTaskPhBufferHint =>
      'Calibrate the pH probe with fresh buffer solutions.';

  @override
  String get maintTaskModemLoad => 'Wi-Fi modem load';

  @override
  String get maintTaskModemLoadHint =>
      'Reload the prepaid modem so the sensor can keep sending readings.';

  @override
  String get maintTaskGsmLoad => 'SMS gateway load';

  @override
  String get maintTaskGsmLoadHint =>
      'Reload the gateway phone\'s SIM so SMS alerts keep going out.';

  @override
  String get maintDoneDoElectrolyte => 'Refilled DO electrolyte';

  @override
  String get maintDonePhBuffer => 'Calibrated pH with new buffer';

  @override
  String get maintDoneModemLoad => 'Loaded the Wi-Fi modem';

  @override
  String get maintDoneGsmLoad => 'Loaded the SMS gateway SIM';

  @override
  String get maintStatusNotSet => 'Not set up';

  @override
  String maintDueIn(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Due in $days days',
      one: 'Due tomorrow',
      zero: 'Due today',
    );
    return '$_temp0';
  }

  @override
  String maintOverdueBy(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days overdue',
      one: '1 day overdue',
    );
    return '$_temp0';
  }

  @override
  String maintLastDone(String date, int days) {
    return 'Last done $date · every $days days';
  }

  @override
  String maintNextDue(String date) {
    return 'Next: $date';
  }

  @override
  String get maintNotSetBody =>
      'Tap Set up and pick when it was last done to start the reminders.';

  @override
  String get maintMarkDone => 'Mark done';

  @override
  String get maintSetUp => 'Set up';

  @override
  String get maintEdit => 'Edit schedule';

  @override
  String get maintDoneOn => 'Done on';

  @override
  String get maintLastDoneOn => 'Last done on';

  @override
  String get maintEvery => 'Repeat every (days)';

  @override
  String maintEveryInvalid(int max) {
    return 'Enter 1 to $max days';
  }

  @override
  String get maintNoteHintLoad => 'e.g. promo loaded, valid 30 days';

  @override
  String get maintNoteHintProbe => 'e.g. used new buffer pack';

  @override
  String get maintLogNote => 'Also added to the logbook.';

  @override
  String get maintSaved => 'Saved. Reminders updated.';

  @override
  String get maintSaveError =>
      'Could not save. Check your connection and try again.';

  @override
  String get maintNotLinked => 'Link a pond first to track its maintenance.';

  @override
  String maintBannerTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count maintenance tasks need attention',
      one: '1 maintenance task needs attention',
    );
    return '$_temp0';
  }

  @override
  String maintBannerBody(String tasks) {
    return '$tasks. Tap to open Maintenance.';
  }

  @override
  String get notifMaintChannel => 'Maintenance reminders';

  @override
  String get notifMaintChannelDescription =>
      'Reminders to refill, calibrate and reload before they run out.';

  @override
  String get notifMaintSoonTitle => 'Maintenance due soon';

  @override
  String notifMaintSoonBody(String task, String date) {
    return '$task is due on $date.';
  }

  @override
  String get notifMaintDueTitle => 'Maintenance due today';

  @override
  String notifMaintDueBody(String task) {
    return '$task is due today. Mark it done in CatfiSense when finished.';
  }

  @override
  String get notifMaintOverdueTitle => 'Maintenance overdue';

  @override
  String notifMaintOverdueBody(String task, String date) {
    return '$task was due on $date.';
  }

  @override
  String get logTypeMaintenance => 'Maintenance';

  @override
  String get adminMaintenance => 'Maintenance';

  @override
  String get memberNameLabel => 'Name';

  @override
  String get memberRename => 'Set name';

  @override
  String get memberRenameHint =>
      'Shown instead of the phone number. Leave blank to show the number again.';

  @override
  String get memberNameSaved => 'Name saved';

  @override
  String get memberNameError =>
      'Could not save the name. Check your connection and try again.';

  @override
  String get auditMemberRenamed => 'Renamed a member';

  @override
  String get addPond => 'Add pond';

  @override
  String get addPondTitle => 'Add a pond';

  @override
  String get addPondBody =>
      'Enter the device ID the sensor saves its readings under in Firebase (readings/<device ID>). The new pond gets its own join code.';

  @override
  String get addPondDeviceId => 'Device ID';

  @override
  String get addPondInvalidId => 'Use 3 to 40 letters, numbers, - or _.';

  @override
  String get addPondNoReadings =>
      'No readings found for that device ID. Check it in Firebase under readings.';

  @override
  String get addPondExists => 'That device is already a pond.';

  @override
  String get addPondError =>
      'Could not add the pond. Check your connection and try again.';

  @override
  String addPondAdded(String code) {
    return 'Pond added. Join code: $code';
  }

  @override
  String get addPondCreate => 'Add';

  @override
  String get auditPondAdded => 'Added a pond';

  @override
  String get adminPondPicker => 'Pond';

  @override
  String get healthGatewayPond1Only =>
      'The SMS gateway currently serves pond1 only.';

  @override
  String get maintConfirmTitle => 'Change this schedule?';

  @override
  String maintConfirmBody(String task) {
    return 'Reminders for $task will follow the new schedule:';
  }

  @override
  String maintChangeLastDone(String from, String to) {
    return 'Last done: $from → $to';
  }

  @override
  String maintChangeInterval(int from, int to) {
    return 'Every: $from → $to days';
  }

  @override
  String maintChangeNote(String from, String to) {
    return 'Note: $from → $to';
  }

  @override
  String get maintConfirmYes => 'Yes, change it';

  @override
  String get auditMaintenanceChanged => 'Changed a maintenance schedule';

  @override
  String get adminDarkMode => 'Switch to dark mode';

  @override
  String get adminLightMode => 'Switch to light mode';

  @override
  String get adminSensorDevice => 'Sensor device';

  @override
  String get adminPondSearchHint => 'Search by pond name, ID, code, or phone';

  @override
  String get adminNoPondMatch => 'No ponds match your search.';

  @override
  String get adminChoosePond => 'Choose a pond';

  @override
  String adminPondCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ponds',
      one: '1 pond',
    );
    return '$_temp0';
  }
}
