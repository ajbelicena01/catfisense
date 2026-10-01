// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Filipino Pilipino (`fil`).
class AppLocalizationsFil extends AppLocalizations {
  AppLocalizationsFil([String locale = 'fil']) : super(locale);

  @override
  String get appName => 'CatfiSense';

  @override
  String get timeJustNow => 'ngayon lang';

  @override
  String timeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minuto na ang nakalipas',
      one: '1 minuto na ang nakalipas',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count oras na ang nakalipas',
      one: '1 oras na ang nakalipas',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count araw na ang nakalipas',
      one: '1 araw na ang nakalipas',
    );
    return '$_temp0';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours oras $minutes min';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get durationUnderMinute => 'wala pang 1 min';

  @override
  String freshnessUpdated(String time) {
    return 'Na-update $time';
  }

  @override
  String get freshnessSensorOfflineTitle => 'Offline ang sensor';

  @override
  String freshnessSensorOfflineBody(String time) {
    return 'Ang huling reading ay $time. Tingnan ang power at internet ng sensor device.';
  }

  @override
  String get freshnessNoInternetTitle => 'Wala kang internet';

  @override
  String get freshnessNoInternetBody =>
      'Ipinapakita ang mga huling reading na natanggap. Mag-a-update ang mga ito kapag may internet ka na ulit.';

  @override
  String get statusGood => 'Maayos';

  @override
  String get statusWarning => 'Babala';

  @override
  String get statusCritical => 'Kritikal';

  @override
  String get issueLowPh => 'Mababang pH';

  @override
  String get issueHighPh => 'Mataas na pH';

  @override
  String get issueLowTemperature => 'Mababang temperatura';

  @override
  String get issueHighTemperature => 'Mataas na temperatura';

  @override
  String get issueLowOxygen => 'Mababang dissolved oxygen';

  @override
  String get issueHighAmmonia => 'Mataas na ammonia';

  @override
  String get alertsNav => 'Mga Alerto';

  @override
  String get alertsTitle => 'Kasaysayan ng Alerto';

  @override
  String get alertsLink => 'Kasaysayan ng alerto';

  @override
  String get alertsLoadError =>
      'Hindi ma-load ang mga reading. Tingnan ang iyong internet at subukang muli.';

  @override
  String get alertsNoReadings => 'Walang naitalang reading sa panahong ito.';

  @override
  String get alertsNoneTitle => 'Walang alerto sa panahong ito';

  @override
  String get alertsNoneBody => 'Nanatili sa maayos na antas ang pond.';

  @override
  String alertsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alerto',
      one: '1 alerto',
    );
    return '$_temp0';
  }

  @override
  String alertsCriticalCount(int count) {
    return '$count kritikal';
  }

  @override
  String alertsTotalTime(String duration) {
    return '$duration sa kabuuan';
  }

  @override
  String get alertOngoing => 'Nagpapatuloy';

  @override
  String alertStartedAt(String time) {
    return 'Nagsimula $time';
  }

  @override
  String alertLasted(String duration) {
    return 'tumagal nang $duration';
  }

  @override
  String alertLowest(String value) {
    return 'pinakamababa $value';
  }

  @override
  String alertHighest(String value) {
    return 'pinakamataas $value';
  }

  @override
  String get commonCancel => 'Kanselahin';

  @override
  String get loadError =>
      'Hindi ma-load. Tingnan ang iyong internet at subukang muli.';

  @override
  String get dayToday => 'Ngayong araw';

  @override
  String get dayYesterday => 'Kahapon';

  @override
  String get logTypeFeeding => 'Nagpakain ng isda';

  @override
  String get logTypeWaterChange => 'Nagpalit ng tubig';

  @override
  String get logTypeAerator => 'Binuksan ang aerator';

  @override
  String get logTypeTreatment => 'Ginamot ang tubig';

  @override
  String get logTypeOther => 'Iba pa';

  @override
  String get logbookNav => 'Logbook';

  @override
  String get logbookTitle => 'Logbook ng Pond';

  @override
  String get logbookSubtitle =>
      'Itala ang mga ginawa sa pond. Makikita rin ang mga tala sa mga chart ng History.';

  @override
  String get logbookAdd => 'Magtala';

  @override
  String get logbookEmptyTitle => 'Wala pang tala';

  @override
  String get logbookEmptyBody =>
      'Pindutin ang “Magtala” pagkatapos magpakain, magpalit ng tubig, o gamutin ang pond.';

  @override
  String get logbookNoteLabel => 'Tala (opsyonal)';

  @override
  String get logbookNoteHint => 'hal. 2 kg na pakain';

  @override
  String get logbookWhen => 'Kailan';

  @override
  String get logbookNow => 'Ngayon';

  @override
  String logbookTodayAt(String time) {
    return 'Ngayong araw, $time';
  }

  @override
  String get logbookSave => 'I-SAVE';

  @override
  String get logbookSaved => 'Nai-save ang tala';

  @override
  String get logbookSaveError =>
      'Hindi mai-save ang tala. Tingnan ang iyong internet at subukang muli.';

  @override
  String get logbookDelete => 'Burahin';

  @override
  String get logbookDeleteConfirmTitle => 'Burahin ang talang ito?';

  @override
  String get logbookDeleteConfirmBody => 'Hindi na ito maibabalik.';

  @override
  String get logbookDeleted => 'Nabura ang tala';

  @override
  String get logbookDeleteError =>
      'Hindi mabura ang tala. Tingnan ang iyong internet at subukang muli.';

  @override
  String get logbookByYou => 'ikaw';

  @override
  String get logbookByOwner => 'ng may-ari';

  @override
  String get logbookByCaretaker => 'ng tagapag-alaga';

  @override
  String get logbookChartLegend =>
      'Ang mga putol-putol na linya ay mga tala sa logbook.';

  @override
  String get roleOwner => 'May-ari';

  @override
  String get roleCaretaker => 'Tagapag-alaga';

  @override
  String get paramTemperature => 'Temperatura';

  @override
  String get paramOxygen => 'Dissolved oxygen';

  @override
  String get paramAmmonia => 'Ammonia';

  @override
  String get reportTitle => 'Ulat ng Pond - CatfiSense';

  @override
  String reportPeriod(String start, String end) {
    return 'Panahon: $start hanggang $end';
  }

  @override
  String reportGenerated(String time) {
    return 'Ginawa noong $time';
  }

  @override
  String get reportSummary => 'Buod';

  @override
  String reportReadingsCount(int count) {
    return '$count reading';
  }

  @override
  String reportGoodShare(int percent) {
    return '$percent% ng mga reading ay Maayos';
  }

  @override
  String get reportParameter => 'Parameter';

  @override
  String get reportLowest => 'Pinakamababa';

  @override
  String get reportAverage => 'Karaniwan';

  @override
  String get reportHighest => 'Pinakamataas';

  @override
  String get reportHealthyRange => 'Maayos na antas';

  @override
  String get reportGoodReadings => 'Maayos na reading';

  @override
  String get reportAlerts => 'Mga Alerto';

  @override
  String get reportStarted => 'Nagsimula';

  @override
  String get reportDuration => 'Tagal';

  @override
  String get reportStatus => 'Status';

  @override
  String get reportDetails => 'Detalye';

  @override
  String get reportNoLogs => 'Walang tala sa logbook sa panahong ito.';

  @override
  String get reportTime => 'Oras';

  @override
  String get reportActivity => 'Gawain';

  @override
  String get reportNote => 'Tala';

  @override
  String get reportBy => 'Nagtala';

  @override
  String get reportDaily => 'Karaniwan bawat araw';

  @override
  String get reportDate => 'Petsa';

  @override
  String get reportReadings => 'Reading';

  @override
  String get reportWorst => 'Pinakamalala';

  @override
  String reportPage(int page, int total) {
    return 'Pahina $page ng $total';
  }

  @override
  String get exportTooltip => 'I-export ang ulat';

  @override
  String get exportTitle => 'I-export ang ulat';

  @override
  String exportPeriod(String period) {
    return 'Para sa ipinapakitang panahon: $period';
  }

  @override
  String get exportPdf => 'PDF na ulat';

  @override
  String get exportPdfHint =>
      'Buod, mga alerto, logbook, at karaniwan bawat araw';

  @override
  String get exportCsv => 'Spreadsheet (CSV)';

  @override
  String get exportCsvHint => 'Lahat ng reading, para sa Excel o Google Sheets';

  @override
  String get exportWorking => 'Inihahanda ang ulat…';

  @override
  String get exportNoData => 'Walang reading na mai-e-export sa panahong ito.';

  @override
  String get exportError => 'Hindi magawa ang ulat. Pakisubukang muli.';

  @override
  String get welcomeLogin => 'MAG-LOGIN';

  @override
  String get welcomeSignup => 'MAG-SIGN UP';

  @override
  String get loginTitle => 'Mag-log in';

  @override
  String get fieldPhone => 'Numero ng telepono';

  @override
  String get fieldPassword => 'Password';

  @override
  String get fieldPasswordHint => 'ilagay ang iyong password';

  @override
  String get loginPasswordRequired => 'Ilagay ang iyong password';

  @override
  String get loginRememberMe => 'Tandaan ako';

  @override
  String get loginForgotPassword => 'Nakalimutan ang password?';

  @override
  String get loginButton => 'MAG-LOGIN';

  @override
  String get loginNoAccount => 'Wala pang account? ';

  @override
  String get loginSignupLink => 'Mag-sign up';

  @override
  String get signupTitle => 'Mag-sign up';

  @override
  String get signupConfirmPassword => 'Kumpirmahin ang password';

  @override
  String get signupConfirmHint => 'Ulitin ang iyong password';

  @override
  String get signupPasswordsMismatch => 'Hindi magkatugma ang mga password';

  @override
  String get signupButton => 'GUMAWA NG ACCOUNT';

  @override
  String get signupHaveAccount => 'May account ka na? ';

  @override
  String get signupLoginLink => 'Mag-login';

  @override
  String get otpTitle => 'OTP';

  @override
  String get otpSubtitle =>
      'Magpapadala kami ng SMS na may OTP. Ilagay ang code sa ibaba.';

  @override
  String get otpEnterCode => 'Ilagay ang 6-digit na code';

  @override
  String get otpConfirm => 'Kumpirmahin';

  @override
  String get otpResendIn => 'Magpadala muli ng OTP sa loob ng ';

  @override
  String get otpResend => 'Magpadala muli ng OTP';

  @override
  String get onboardingSkip => 'Laktawan';

  @override
  String get onboardingNext => 'Susunod';

  @override
  String get onboardingFinish => 'Tapos na';

  @override
  String get onboarding1Headline =>
      'Nasa iyong mga kamay\nang kalusugan ng pond.';

  @override
  String get onboarding1Body =>
      'Bantayan ang iyong palaisdaan ng hito kahit kailan, kahit saan.';

  @override
  String get onboarding2Headline => 'Subaybayan ang mahalaga\nsa real time.';

  @override
  String get onboarding2Body =>
      'Makita agad ang pH, temperatura, ammonia, at dissolved oxygen ng tubig.';

  @override
  String get onboarding3Headline => 'Alamin agad ang\nkalagayan ng pond.';

  @override
  String get onboarding3Body =>
      'Sinusuri ng CatfiSense ang mga reading at ipinapakita kung Maayos, may Babala, o Kritikal ang pond.';

  @override
  String get onboarding4Headline => 'Maalerto kapag\nkailangang kumilos.';

  @override
  String get onboarding4Body =>
      'Makatanggap ng mobile at SMS na alerto kasama ang payo ng eksperto.';

  @override
  String get pondCodeTitle => 'I-link ang iyong pond';

  @override
  String get pondCodeBody =>
      'Ilagay ang pond code mula sa iyong CatfiSense device o sa iyong admin para makita ang mga reading ng pond.';

  @override
  String get pondCodeField => 'Pond code';

  @override
  String get pondCodeButton => 'I-LINK ANG POND';

  @override
  String get pondCodeWrongAccount => 'Maling account? ';

  @override
  String get pondCodeLogout => 'Mag-log out';

  @override
  String get pondCodeJoinedOwner =>
      'Na-link ang pond. Sumali ka bilang may-ari.';

  @override
  String get pondCodeJoinedCaretaker =>
      'Na-link ang pond. Sumali ka bilang tagapag-alaga.';

  @override
  String get pondCodeInvalid => 'Ilagay ang 8-character na pond code';

  @override
  String get pondJoinNotFound =>
      'Hindi nakita ang pond code na iyan. Suriin ito at subukang muli.';

  @override
  String get pondJoinNetwork =>
      'Hindi ma-link ang pond. Tingnan ang iyong internet at subukang muli.';

  @override
  String get pondJoinFull =>
      'May may-ari at tagapag-alaga na ang pond na ito. Humingi ng tulong sa may-ari ng pond.';

  @override
  String get validatePhone =>
      'Maglagay ng tamang PH mobile number (09XXXXXXXXX)';

  @override
  String get validatePasswordLength => 'Hindi bababa sa 8 character';

  @override
  String get validatePasswordCapital =>
      'Maglagay ng kahit isang malaking titik';

  @override
  String get validatePasswordSymbol => 'Maglagay ng kahit isang simbolo';

  @override
  String get authPhoneTaken => 'Nakarehistro na ang numerong ito.';

  @override
  String get authWeakPassword =>
      'Dapat hindi bababa sa 6 na character ang password.';

  @override
  String get authWrongCredentials => 'Mali ang numero ng telepono o password.';

  @override
  String get authRecentLogin =>
      'Pakilagay muli ang iyong kasalukuyang password para magpatuloy.';

  @override
  String get authNotSignedIn => 'Kailangan mong naka-log in para magawa ito.';

  @override
  String get authSamePhone => 'Iyan na ang nakarehistro mong numero.';

  @override
  String get authGeneric => 'May nagkaproblema. Pakisubukang muli.';

  @override
  String get logoutTitle => 'Mag-log out?';

  @override
  String get logoutBody =>
      'Kailangan mong mag-log in muli para makita ang datos ng iyong pond.';

  @override
  String get logoutConfirm => 'Mag-log out';

  @override
  String get commonChecking => 'Sinusuri…';

  @override
  String get commonLoading => 'Naglo-load…';

  @override
  String get settingsTitle => 'Mga Setting';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsLoggedInAs => 'Naka-log in bilang';

  @override
  String get settingsUnknownNumber => 'Hindi alam na numero';

  @override
  String get settingsRole => 'Tungkulin sa pond';

  @override
  String get settingsRoleOwner => 'May-ari ng pond';

  @override
  String get settingsRoleOwnerHint =>
      'Maaari kang mag-imbita o mag-alis ng tagapag-alaga';

  @override
  String get settingsRoleCaretakerHint =>
      'Makikita mo ang mga reading ng pond na ito';

  @override
  String get settingsRoleNone => 'Hindi naka-link sa pond';

  @override
  String get settingsAppearance => 'Itsura';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsDarkModeHint => 'Mas magaan sa mata sa gabi';

  @override
  String get settingsTextSize => 'Laki ng teksto';

  @override
  String get textSizeSmall => 'Maliit';

  @override
  String get textSizeDefault => 'Karaniwan';

  @override
  String get textSizeLarge => 'Malaki';

  @override
  String get textSizeExtraLarge => 'Napakalaki';

  @override
  String get settingsLanguage => 'Wika';

  @override
  String get settingsLanguageSystem => 'Wika ng telepono';

  @override
  String get settingsNotifications => 'Mga Notification';

  @override
  String get settingsPush => 'Push Notification';

  @override
  String get settingsPushHint =>
      'Alerto sa app kapag delikado ang isang reading';

  @override
  String get settingsSms => 'SMS na Alerto';

  @override
  String get settingsSmsHint => 'Text message mula mismo sa device sa pond';

  @override
  String get settingsAbout => 'Tungkol';

  @override
  String get settingsAboutApp => 'Tungkol sa CatfiSense';

  @override
  String get settingsAboutAppHint =>
      'Ano ang ginagawa ng app at paano ito gumagana';

  @override
  String get membersTitle => 'Mga miyembro ng pond';

  @override
  String get membersLoadError => 'Hindi ma-load ang mga miyembro ng pond';

  @override
  String get membersNoCaretaker => 'Wala pang tagapag-alaga';

  @override
  String get membersInviteHint =>
      'Para mag-imbita, ipadala sa kanila ang pond code sa ibaba. Mag-sign up sila sa app at ilagay ito.';

  @override
  String get membersNoPhone => 'Walang numero ng telepono';

  @override
  String get membersRemove => 'Alisin';

  @override
  String get membersNoCode => 'Walang nakatakdang code';

  @override
  String get membersCopyCode => 'Kopyahin ang pond code';

  @override
  String get membersCodeCopied => 'Nakopya ang pond code';

  @override
  String get membersChangeCode => 'Palitan ang pond code';

  @override
  String get membersChangeCodeHint =>
      'Hindi na gagana ang lumang code. Mananatili ang mga miyembro.';

  @override
  String get membersChangeCodeTitle => 'Palitan ang pond code?';

  @override
  String membersChangeCodeBody(String code) {
    return 'Hindi na gagana ang $code. Mananatili ang lahat ng nasa pond na.';
  }

  @override
  String get membersChangeCodeBodyUnknown =>
      'Hindi na gagana ang kasalukuyang code. Mananatili ang lahat ng nasa pond na.';

  @override
  String get membersChangeCodeConfirm => 'Palitan ang code';

  @override
  String get membersChangeCodeError =>
      'Hindi mapalitan ang code. Tingnan ang iyong internet at subukang muli.';

  @override
  String membersNewCode(String code) {
    return 'Bagong pond code: $code';
  }

  @override
  String get membersTheCaretaker => 'Ang tagapag-alaga';

  @override
  String get membersRemoveTitle => 'Alisin ang tagapag-alaga?';

  @override
  String membersRemoveBody(String who) {
    return 'Mawawalan agad ng access si $who sa pond na ito.\n\nMaaari pa rin silang bumalik gamit ang kasalukuyang pond code, kaya palitan din ang code kung ayaw mo na silang bumalik.';
  }

  @override
  String get membersRemoveAndChange => 'Alisin at palitan ang code';

  @override
  String get membersRemoved => 'Naalis ang tagapag-alaga';

  @override
  String get membersRemoveError =>
      'Hindi maalis ang tagapag-alaga. Tingnan ang iyong internet at subukang muli.';

  @override
  String get commonBack => 'Bumalik';

  @override
  String get commonClose => 'ISARA';

  @override
  String get statusBannerGood => 'Maayos ang kalusugan ng pond.';

  @override
  String get statusBannerWarning => 'May babala sa kalusugan ng pond.';

  @override
  String get statusBannerCritical => 'Kritikal ang kalusugan ng pond.';

  @override
  String get phiHealthy => 'Maayos';

  @override
  String get phiOverall => 'Kabuuang PHI';

  @override
  String get batteryLabel => 'Baterya ng Device';

  @override
  String get cardWhatItMeasures => 'Ano ang sinusukat nito';

  @override
  String get cardWhyItMatters => 'Bakit ito mahalaga';

  @override
  String get cardOptimalRange => 'Tamang antas';

  @override
  String get cardPhLabel => 'Antas ng pH';

  @override
  String get cardPhDescription =>
      'Ipinapakita ng pH kung gaano ka-asido o ka-alkaline ang tubig ng pond.';

  @override
  String get cardPhImpact =>
      'Ang malaki o biglaang pagbabago ng pH ay nagpapa-stress sa isda at nakaaapekto sa hasang. Binabago rin ng pH kung gaano kalason ang ammonia sa isda.';

  @override
  String get cardTemperatureDescription =>
      'Sinusukat ng temperatura kung gaano kainit o kalamig ang tubig ng pond.';

  @override
  String get cardTemperatureImpact =>
      'Naaapektuhan ng temperatura ang metabolismo, gana sa pagkain, paglaki, at pangangailangan ng isda sa oxygen. Mas kaunti rin ang oxygen na kayang hawakan ng mainit na tubig.';

  @override
  String get cardOxygenDescription =>
      'Ang dissolved oxygen (DO) ay ang oxygen sa tubig na nilalanghap ng isda.';

  @override
  String get cardOxygenImpact =>
      'Ang mababang DO ay nagdudulot ng stress, mahinang pagkain, paghingal sa ibabaw ng tubig, at pagkamatay ng isda.';

  @override
  String get cardAmmoniaDescription =>
      'Nagmumula ang ammonia sa dumi ng isda at sa hindi nakaing pakain.';

  @override
  String get cardAmmoniaImpact =>
      'Nakasisira ng hasang ng isda ang ammonia. Lumalakas ang lason nito kapag mataas ang pH at temperatura.';

  @override
  String get chartTime => 'Oras';

  @override
  String get chartTemperature => 'Temperatura (°C)';

  @override
  String get chartAmmoniaTitle => 'Ammonia (NH₃)';

  @override
  String get chartAmmoniaAxis => 'Ammonia (mg/L)';

  @override
  String get chartOxygenTitle => 'Dissolved Oxygen (DO)';

  @override
  String get chartOxygenAxis => 'Dissolved Oxygen (mg/L)';

  @override
  String get chartNoReadingsInRange => 'Walang reading sa ipinapakitang antas.';

  @override
  String get chartNoReadingsInParameterRanges =>
      'Walang reading sa ipinapakitang mga antas.';

  @override
  String get rangeDaily => 'Araw';

  @override
  String get rangeWeekly => 'Linggo';

  @override
  String get rangeMonthly => 'Buwan';

  @override
  String get rangeCustom => 'Pumili';

  @override
  String get historyTitle => 'Kasaysayan ng Tubig';

  @override
  String get historyNoReadings =>
      'Wala pang naitalang reading sa panahong ito.';

  @override
  String get navHome => 'Home';

  @override
  String get navHistory => 'Kasaysayan';

  @override
  String get navInsights => 'Payo';

  @override
  String get refreshNoReadings => 'Wala pang reading mula sa sensor.';

  @override
  String get refreshDone => 'Na-refresh ang pinakabagong reading.';

  @override
  String get refreshError => 'Hindi ma-refresh ang mga reading.';

  @override
  String monitoringLatest(String ph, String temperature, String oxygen) {
    return 'Pinakabago: pH $ph • $temperature°C • DO $oxygen';
  }

  @override
  String get monitoringWaiting =>
      'Hinihintay ang pinakabagong reading ng sensor.';

  @override
  String get monitoringActive =>
      'Binabantayan ang pinakabagong reading ng sensor.';

  @override
  String get dashboardNoReadingsTitle => 'Wala pang reading';

  @override
  String get dashboardNoReadingsBody =>
      'Hinihintay ang unang reading mula sa sensor ng pond.\nPindutin ang refresh para tingnan ulit.';

  @override
  String get dashboardViewRecommendations => 'Tingnan ang mga payo';

  @override
  String get dashboardSeeWhatToDo => 'Alamin ang gagawin';

  @override
  String get dashboardSensorReadings => 'Mga Reading ng Sensor';

  @override
  String get dashboardPhiTrend => 'Takbo ng PHI';

  @override
  String get dashboardPhiSubtitle => 'Pang-araw-araw na pond health index';

  @override
  String get dashboardPhiEmpty => 'Wala pang naitalang PHI ngayong araw.';

  @override
  String get dashboardViewAllReadings => 'Tingnan ang lahat ng reading';

  @override
  String get aboutTagline =>
      'Matalinong pagbabantay ng kalidad ng tubig para sa palaisdaan ng hito.';

  @override
  String aboutVersion(String version) {
    return 'Bersyon $version';
  }

  @override
  String get aboutWhatItDoes => 'Ano ang ginagawa nito';

  @override
  String get aboutWhatItDoesBody =>
      'Binabantayan ng CatfiSense ang tubig ng iyong pond buong araw at gabi. Sinusukat ng sensor device sa pond ang tubig bawat ilang segundo, at ipinapakita ng app na ito ang mga reading nang live, itinatala ang kasaysayan, at sinasabi kung ano ang gagawin kapag lumabas sa ligtas na antas ang tubig.';

  @override
  String get aboutWhatItMonitors => 'Ano ang binabantayan nito';

  @override
  String get aboutPhBody =>
      'Kung gaano ka-asido o ka-alkaline ang tubig. Nagpapa-stress sa isda ang malalaking pagbabago.';

  @override
  String get aboutTemperatureBody =>
      'Nakaaapekto sa dami ng kinakain ng hito, bilis ng paglaki, at dami ng oxygen na kailangan nila.';

  @override
  String get aboutOxygenBody =>
      'Ang oxygen na magagamit ng isda. Karaniwang sanhi ng biglaang pagkamatay ng isda ang mababang oxygen.';

  @override
  String get aboutAmmoniaBody =>
      'Naiipon mula sa dumi ng isda at tirang pakain. Nakasisira ng hasang at nagpapabagal ng paglaki kapag mataas.';

  @override
  String get aboutPondStatus => 'Kalagayan ng pond';

  @override
  String get aboutStatusGood => 'Nasa maayos na antas ang lahat ng reading.';

  @override
  String get aboutStatusWarning =>
      'May reading na lumalabas sa tamang antas. Tingnan agad ang pond.';

  @override
  String get aboutStatusCritical =>
      'May reading na mapanganib sa isda. Kumilos ngayon. Makatatanggap ka rin ng push at SMS na alerto.';

  @override
  String get aboutHowItWorks => 'Paano ito gumagana';

  @override
  String get aboutStepMeasure => '1. Sukatin';

  @override
  String get aboutStepMeasureBody =>
      'Sinusukat ng solar-powered na sensor device sa pond ang tubig bawat ilang segundo.';

  @override
  String get aboutStepSend => '2. Ipadala';

  @override
  String get aboutStepSendBody =>
      'Ipinapadala ang bawat reading sa CatfiSense cloud gamit ang internet.';

  @override
  String get aboutStepAlert => '3. Mag-alerto';

  @override
  String get aboutStepAlertBody =>
      'Ipinapakita ng app ang live na reading, kasaysayan, at mga payo, at binabalaan ka sa push notification at SMS kapag kailangan ng pond ng atensyon.';

  @override
  String get recWhatToDo => 'Ano ang dapat gawin';

  @override
  String get recSortedByUrgency =>
      'Nakaayos ayon sa pagkaapurahan — unahin ang mga kritikal.';

  @override
  String get recNoActionTitle => 'Walang kailangang gawin';

  @override
  String get recNoActionBody =>
      'Nasa maayos na antas ang lahat ng reading ng sensor.';

  @override
  String recWarningTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parameter ang kailangang asikasuhin',
      one: '1 parameter ang kailangang asikasuhin',
    );
    return '$_temp0';
  }

  @override
  String get recWarningBody =>
      'Gawin agad ang mga hakbang sa ibaba para manatiling maayos ang pond.';

  @override
  String recCriticalTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parameter ang kritikal',
      one: '1 parameter ang kritikal',
    );
    return '$_temp0';
  }

  @override
  String get recCriticalBody =>
      'Kumilos ngayon — maaaring nanganganib ang kalusugan ng isda.';

  @override
  String get recAllClearTitle => 'Maganda ang kalagayan ng pond';

  @override
  String get recAllClearBody =>
      'Walang kailangang ayusin sa ngayon. Ipagpatuloy ang mabuting pag-aalaga!';

  @override
  String get recTipsTitle => 'Mga Payo sa Pag-aalaga ng Pond';

  @override
  String get recPhLowCritical1 =>
      'Maglagay agad ng agricultural lime para tumaas ang pH, at itigil ang pagpapakain hangga\'t hindi bumabalik sa tamang antas.';

  @override
  String get recPhLowCritical2 =>
      'Dagdagan ang pagpapalit ng tubig para mabawasan ang asido.';

  @override
  String get recRetestPh =>
      'Sukatin muli ang pH pagkalipas ng 2-3 oras, at muli kinaumagahan.';

  @override
  String get recPhLowWarning1 =>
      'Maglagay ng agricultural lime nang paunti-unti at sukatin muli pagkalipas ng ilang oras.';

  @override
  String get recPhLowWarning2 =>
      'Huwag magpakain nang higit sa kayang ubusin ng isda sa loob ng 15-20 minuto.';

  @override
  String get recPhHighCritical1 =>
      'Magpalit agad ng bahagi ng tubig para bumaba ang pH.';

  @override
  String get recPhHighCritical2 =>
      'Itigil muna ang paglalagay ng lime, pataba, o pakain hangga\'t hindi matatag ang pH.';

  @override
  String get recPhHighWarning1 =>
      'Palitan ang bahagi ng tubig ng pond ng malinis na tubig para unti-unting bumalik ang pH sa tamang antas.';

  @override
  String get recPhHighWarning2 =>
      'Huwag munang maglagay ng lime o pataba sa pond hanggang sa susunod na reading.';

  @override
  String get recTempLowCritical1 =>
      'Harangan ang pond mula sa malamig na hangin at huwag hawakan ang isda hangga\'t hindi umiinit ang tubig.';

  @override
  String get recTempLowCritical2 =>
      'Bawasan o itigil muna ang pagpapakain — bumabagal ang pagtunaw ng pagkain sa malamig na tubig.';

  @override
  String get recTempLowWarning1 =>
      'Bawasan nang kaunti ang dalas ng pagpapakain habang malamig ang tubig.';

  @override
  String get recTempLowWarning2 =>
      'Bantayan kung matamlay kumain ang isda, isang maagang senyales ng cold stress.';

  @override
  String get recTempHighCritical1 =>
      'Dagdagan agad ang aeration at magdagdag ng mas malamig na tubig kung mayroon.';

  @override
  String get recTempHighCritical2 =>
      'Itigil ang pagpapakain hangga\'t hindi bumababa ang temperatura sa tamang antas.';

  @override
  String get recTempHighWarning1 =>
      'Dagdagan ang aeration at lagyan ng lilim ang bahagi ng pond.';

  @override
  String get recTempHighWarning2 =>
      'Magpakain sa mas malamig na oras — maagang umaga o hapon.';

  @override
  String get recDoCritical1 =>
      'Paandarin agad ang aerator o haluin ang ibabaw ng tubig — maaaring malunod sa kakulangan ng hangin ang isda.';

  @override
  String get recDoCritical2 =>
      'Itigil ang pagpapakain hangga\'t hindi bumabalik ang oxygen.';

  @override
  String get recDoCritical3 =>
      'Tingnan kung may namatay na lumot o sobrang dami ng isda bilang posibleng sanhi.';

  @override
  String get recDoWarning1 =>
      'Buksan ang aeration, lalo na sa madaling-araw kung kailan pinakamababa ang DO.';

  @override
  String get recDoWarning2 =>
      'Bawasan nang kaunti ang pakain para mabawasan ang oxygen na nauubos sa pagkabulok ng dumi.';

  @override
  String get recAmmoniaCritical1 =>
      'Magpalit agad ng bahagi ng tubig para mabawasan ang ammonia.';

  @override
  String get recAmmoniaCritical2 =>
      'Itigil ang pagpapakain at alisin ang tirang pakain o nabubulok na bagay.';

  @override
  String get recAmmoniaCritical3 =>
      'Sukatin muli pagkatapos magpalit ng tubig at huwag munang magdagdag ng isda hangga\'t hindi bumababa ang antas.';

  @override
  String get recAmmoniaWarning1 =>
      'Bawasan ang dami ng pakain at alisin agad ang hindi nakaing pakain.';

  @override
  String get recAmmoniaWarning2 =>
      'Tingnan kung sobra ang pakain o may naipong dumi sa ilalim ng pond.';

  @override
  String get recTip1 =>
      'Sukatin ang kalidad ng tubig sa parehong oras araw-araw para maihambing ang takbo nito.';

  @override
  String get recTip2 =>
      'Itala ang pagpapakain sa Logbook — ang sobrang pakain ang pinakakaraniwang sanhi ng pagtaas ng ammonia.';

  @override
  String get recTip3 =>
      'Linisin at i-calibrate muli ang mga sensor nang regular para mapagkatiwalaan ang mga reading.';

  @override
  String get recTip4 =>
      'Mag-aerate bago sumikat ang araw, kung kailan pinakamababa ang dissolved oxygen.';

  @override
  String get consentTitle => 'Laging bantayan ang iyong pond';

  @override
  String get consentBody =>
      'Aalertuhin ka ng CatfiSense kapag naging delikado ang isang reading. Piliin kung paano mo gustong malaman — mapapalitan mo ito anumang oras sa Mga Setting.';

  @override
  String get consentPush => 'Push notification';

  @override
  String get consentSms => 'SMS na alerto';

  @override
  String get consentContinue => 'MAGPATULOY';

  @override
  String get notifAlertsChannel => 'Mga Alerto ng Pond';

  @override
  String get notifAlertsChannelDescription =>
      'Mga babala at kritikal na alerto tungkol sa kalidad ng tubig ng pond';

  @override
  String get notifMonitoringChannel => 'Pagbabantay ng Pond';

  @override
  String get notifMonitoringChannelDescription =>
      'Kasalukuyang status ng pagbabantay ng pond';

  @override
  String get notifMonitoringTitle => 'Binabantayan ang pond';

  @override
  String get notifCriticalTitle => 'Kritikal ang kalusugan ng pond';

  @override
  String get notifWarningTitle => 'Babala sa kalusugan ng pond';

  @override
  String get notifCriticalBody =>
      'May kritikal na reading — buksan ang app at kumilos ngayon.';

  @override
  String get notifWarningBody =>
      'May reading na lumabas sa maayos na antas. Pindutin para malaman ang gagawin.';

  @override
  String get notifPushFallbackTitle => 'Alerto ng pond';

  @override
  String get notifPushFallbackBody => 'May bagong alerto ng pond.';

  @override
  String get fieldAdminUsername => 'Admin username';

  @override
  String get loginAsAdmin => 'Admin? Mag-log in gamit ang username';

  @override
  String get loginAsFarmer => 'Mag-log in gamit ang numero ng telepono';

  @override
  String get validateAdminUsername =>
      'Ganito ang admin username: admin_pangalan';

  @override
  String get smsTitle => 'Mga numero para sa SMS na alerto';

  @override
  String get smsHint =>
      'Ipinapadala ng gateway phone ang bawat alerto ng pond sa mga numerong ito.';

  @override
  String get smsNone =>
      'Wala pang numero. Walang makatatanggap ng SMS na alerto.';

  @override
  String get smsAdd => 'Magdagdag ng numero';

  @override
  String get smsAddTitle => 'Magdagdag ng numero para sa SMS na alerto';

  @override
  String get smsAdded => 'Naidagdag ang numero';

  @override
  String get smsRemoveTitle => 'Alisin ang numerong ito?';

  @override
  String smsRemoveBody(String number) {
    return 'Hindi na makatatanggap ng SMS na alerto ang $number.';
  }

  @override
  String smsRemoveLastBody(String number) {
    return 'Ang $number na lang ang natitirang numero. Walang makatatanggap ng SMS na alerto hangga\'t hindi ka nagdadagdag ng iba.';
  }

  @override
  String get smsRemoved => 'Naalis ang numero';

  @override
  String get smsSaveError =>
      'Hindi mai-save. Tingnan ang iyong internet at subukang muli.';

  @override
  String get smsStatusSent => 'naipadala';

  @override
  String get smsStatusFailed => 'hindi naipadala';

  @override
  String get smsStatusRejected => 'tinanggihan';

  @override
  String get smsStatusExpired => 'nag-expire';

  @override
  String get smsStatusPending => 'naghihintay';

  @override
  String get passwordChangeTitle => 'Palitan ang password';

  @override
  String get passwordCurrent => 'Kasalukuyang password';

  @override
  String get passwordNew => 'Bagong password';

  @override
  String get passwordSave => 'I-save';

  @override
  String get passwordChanged => 'Napalitan ang password';

  @override
  String get adminTitle => 'CatfiSense Admin';

  @override
  String get adminTabHealth => 'Kalagayan';

  @override
  String get adminTabPonds => 'Mga Pond';

  @override
  String get adminTabUsers => 'Mga User';

  @override
  String get adminTabThresholds => 'Antas';

  @override
  String get adminTabAudit => 'Talaan';

  @override
  String get adminNoPonds => 'Wala pang pond.';

  @override
  String get adminSlotEmpty => 'Bakante';

  @override
  String get adminRemoveOwnerTitle => 'Alisin ang may-ari?';

  @override
  String adminRemoveOwnerBody(String who) {
    return 'Mawawalan agad ng access si $who sa pond na ito at mababakante ang puwesto ng may-ari. Ang susunod na maglalagay ng pond code ang magiging may-ari, kaya pag-isipang palitan din ang code.';
  }

  @override
  String get adminMemberRemoved => 'Naalis ang miyembro';

  @override
  String adminAdmins(int count) {
    return 'Mga admin ($count)';
  }

  @override
  String adminFarmers(int count) {
    return 'Mga account ng magsasaka ($count)';
  }

  @override
  String get adminYou => 'Ikaw';

  @override
  String adminJoined(String date) {
    return 'nag-sign up $date';
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
  String get healthNoReadings24h => 'Walang reading sa nakaraang 24 oras.';

  @override
  String healthLastReading(String time) {
    return 'Huling reading $time';
  }

  @override
  String get healthUploadSpeed => 'Bilis ng pag-upload';

  @override
  String get healthUploadSpeedHint =>
      'Oras mula sa pagpapadala ng device ng reading hanggang maitala ito sa Firebase (nakaraang oras).';

  @override
  String get healthLatest => 'Pinakabago';

  @override
  String get healthAverage => 'Karaniwan';

  @override
  String get healthSlowest => 'Pinakamabagal';

  @override
  String get healthClockNote =>
      'Batay sa orasan ng device, kaya maaaring may kaunting diperensya ang maliliit na halaga.';

  @override
  String get healthLast10Min => 'Reading, nakaraang 10 min';

  @override
  String healthOfExpected(int count, int expected) {
    return '$count sa $expected';
  }

  @override
  String get healthGaps => 'Mga puwang sa nakaraang 24 oras';

  @override
  String get healthNoGaps =>
      'Walang puwang: tuloy-tuloy ang dating ng mga reading.';

  @override
  String get healthNow => 'ngayon';

  @override
  String get healthGateway => 'SMS gateway phone';

  @override
  String healthGatewaySeen(String time) {
    return 'Huling nag-check in $time';
  }

  @override
  String get healthGatewayNever =>
      'Hindi pa nag-check in. I-update ang gateway app.';

  @override
  String get healthNoSms => 'Wala pang SMS na alerto.';

  @override
  String healthLastSms(String status, String time) {
    return 'Huling SMS na alerto: $status, $time';
  }

  @override
  String get auditSubtitle =>
      'Bawat pagbabagong ginawa ng mga admin at may-ari ng pond';

  @override
  String get auditEmpty => 'Wala pang naitalang pagbabago.';

  @override
  String auditBy(String name, String time) {
    return 'ni $name · $time';
  }

  @override
  String get auditThresholdsChanged => 'Binago ang mga antas ng pond';

  @override
  String get auditThresholdsReset =>
      'Ibinalik sa default ang mga antas ng pond';

  @override
  String get auditCaretakerRemoved => 'Nag-alis ng tagapag-alaga';

  @override
  String get auditOwnerRemoved => 'Nag-alis ng may-ari ng pond';

  @override
  String get auditCodeChanged => 'Pinalitan ang pond code';

  @override
  String get auditRecipientAdded => 'Nagdagdag ng numero para sa SMS na alerto';

  @override
  String get auditRecipientRemoved =>
      'Nag-alis ng numero para sa SMS na alerto';

  @override
  String get auditLogEntryDeleted => 'Nagbura ng tala ng iba sa logbook';

  @override
  String get auditOther => 'Ibang pagbabago';

  @override
  String get thresholdsTitle => 'Mga antas ng kalusugan ng pond';

  @override
  String get thresholdsHelp =>
      'Ang reading sa loob ng Maayos na antas ay Maayos, sa loob ng antas ng Babala ay Babala, at ang lahat ng nasa labas ay Kritikal. Agad itong magagamit sa lahat ng telepono.';

  @override
  String get thresholdsGoodFrom => 'Maayos mula';

  @override
  String get thresholdsGoodTo => 'Maayos hanggang';

  @override
  String get thresholdsWarningFrom => 'Babala mula';

  @override
  String get thresholdsWarningTo => 'Babala hanggang';

  @override
  String get thresholdsNumberError => 'Maglagay ng numero';

  @override
  String get thresholdsOrderError =>
      'Dapat nasa labas ng maayos na antas ang antas ng babala, at mas mababa ang ibabang halaga kaysa sa itaas.';

  @override
  String get thresholdsSave => 'I-save ang mga antas';

  @override
  String get thresholdsNoChanges => 'Walang binago.';

  @override
  String get thresholdsConfirmTitle => 'I-save ang mga antas na ito?';

  @override
  String get thresholdsConfirmBody =>
      'Gagamitin ng lahat ng telepono ang bagong mga antas, at maitatala ang pagbabago sa talaan.';

  @override
  String get thresholdsSaved => 'Nai-save ang mga antas';

  @override
  String get thresholdsSaveError =>
      'Hindi mai-save ang mga antas. Tingnan ang iyong internet at subukang muli.';

  @override
  String get thresholdsReset => 'Ibalik sa default';

  @override
  String get thresholdsResetTitle => 'Ibalik sa default na mga antas?';

  @override
  String get thresholdsResetBody =>
      'Muling gagamitin sa lahat ng telepono ang pangkalahatang antas para sa hito.';

  @override
  String get thresholdsDeviceNote =>
      'Ginagamit ng app, mga alerto, payo, at ulat ang mga antas na ito. Ang sensor device ay gumagamit pa rin ng sariling antas sa firmware nito para sa SMS na alerto.';

  @override
  String get commonSave => 'I-save';

  @override
  String get pondNameLabel => 'Pangalan ng pond';

  @override
  String get pondNameNotSet => 'Wala pa';

  @override
  String get pondRename => 'Palitan ang pangalan ng pond';

  @override
  String get pondNameRequired => 'Ilagay ang pangalan ng pond';

  @override
  String pondNameTooLong(int max) {
    return 'Hanggang $max na character lang';
  }

  @override
  String get pondNameSaved => 'Napalitan na ang pangalan ng pond';

  @override
  String get pondNameError =>
      'Hindi mapalitan ang pangalan ng pond. Tingnan ang iyong internet at subukang muli.';

  @override
  String get auditPondRenamed => 'Pinalitan ang pangalan ng pond';

  @override
  String get maintenanceNav => 'Maintenance';

  @override
  String get maintenanceTitle => 'Maintenance';

  @override
  String get maintenanceSubtitle =>
      'Panatilihing tama ang mga sensor at tuloy-tuloy ang internet at SMS na alerto. Makakatanggap ka ng paalala bago dumating ang bawat isa.';

  @override
  String get maintTaskDoElectrolyte => 'Electrolyte ng DO sensor';

  @override
  String get maintTaskDoElectrolyteHint =>
      'Palitan ang electrolyte ng dissolved oxygen probe para manatiling tama ang basa ng DO.';

  @override
  String get maintTaskPhBuffer => 'pH buffer at calibration';

  @override
  String get maintTaskPhBufferHint =>
      'I-calibrate ang pH probe gamit ang bagong buffer solution.';

  @override
  String get maintTaskModemLoad => 'Load ng Wi-Fi modem';

  @override
  String get maintTaskModemLoadHint =>
      'Lagyan ng load ang prepaid modem para tuloy ang pagpapadala ng sensor ng mga basa.';

  @override
  String get maintTaskGsmLoad => 'Load ng SMS gateway';

  @override
  String get maintTaskGsmLoadHint =>
      'Lagyan ng load ang SIM ng gateway phone para tuloy ang pagpapadala ng SMS na alerto.';

  @override
  String get maintDoneDoElectrolyte => 'Pinalitan ang electrolyte ng DO';

  @override
  String get maintDonePhBuffer => 'Na-calibrate ang pH gamit ang bagong buffer';

  @override
  String get maintDoneModemLoad => 'Nilagyan ng load ang Wi-Fi modem';

  @override
  String get maintDoneGsmLoad => 'Nilagyan ng load ang SIM ng SMS gateway';

  @override
  String get maintStatusNotSet => 'Hindi pa naka-set up';

  @override
  String maintDueIn(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Sa loob ng $days araw',
      one: 'Bukas na',
      zero: 'Ngayong araw na',
    );
    return '$_temp0';
  }

  @override
  String maintOverdueBy(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Lampas na nang $days araw',
      one: 'Lampas na nang 1 araw',
    );
    return '$_temp0';
  }

  @override
  String maintLastDone(String date, int days) {
    return 'Huling ginawa $date · bawat $days araw';
  }

  @override
  String maintNextDue(String date) {
    return 'Susunod: $date';
  }

  @override
  String get maintNotSetBody =>
      'Pindutin ang I-set up at piliin kung kailan ito huling ginawa para magsimula ang mga paalala.';

  @override
  String get maintMarkDone => 'Tapos na';

  @override
  String get maintSetUp => 'I-set up';

  @override
  String get maintEdit => 'Baguhin ang iskedyul';

  @override
  String get maintDoneOn => 'Ginawa noong';

  @override
  String get maintLastDoneOn => 'Huling ginawa noong';

  @override
  String get maintEvery => 'Ulitin bawat (araw)';

  @override
  String maintEveryInvalid(int max) {
    return 'Maglagay ng 1 hanggang $max araw';
  }

  @override
  String get maintNoteHintLoad => 'hal. promo na in-load, 30 araw';

  @override
  String get maintNoteHintProbe => 'hal. gumamit ng bagong buffer pack';

  @override
  String get maintLogNote => 'Idinagdag din sa logbook.';

  @override
  String get maintSaved => 'Na-save. Na-update ang mga paalala.';

  @override
  String get maintSaveError =>
      'Hindi ma-save. Tingnan ang iyong internet at subukang muli.';

  @override
  String get maintNotLinked =>
      'Mag-link muna ng pond para masubaybayan ang maintenance nito.';

  @override
  String maintBannerTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count maintenance ang kailangang gawin',
      one: '1 maintenance ang kailangang gawin',
    );
    return '$_temp0';
  }

  @override
  String maintBannerBody(String tasks) {
    return '$tasks. Pindutin para buksan ang Maintenance.';
  }

  @override
  String get notifMaintChannel => 'Mga paalala sa maintenance';

  @override
  String get notifMaintChannelDescription =>
      'Mga paalala sa pagpapalit, pag-calibrate at pag-load bago maubos.';

  @override
  String get notifMaintSoonTitle => 'Malapit na ang maintenance';

  @override
  String notifMaintSoonBody(String task, String date) {
    return 'Kailangang gawin ang $task sa $date.';
  }

  @override
  String get notifMaintDueTitle => 'Maintenance ngayong araw';

  @override
  String notifMaintDueBody(String task) {
    return 'Kailangang gawin ngayon ang $task. Markahang tapos sa CatfiSense kapag natapos.';
  }

  @override
  String get notifMaintOverdueTitle => 'Lampas na ang maintenance';

  @override
  String notifMaintOverdueBody(String task, String date) {
    return 'Dapat nagawa na ang $task noong $date.';
  }

  @override
  String get logTypeMaintenance => 'Maintenance';

  @override
  String get adminMaintenance => 'Maintenance';

  @override
  String get memberNameLabel => 'Pangalan';

  @override
  String get memberRename => 'Lagyan ng pangalan';

  @override
  String get memberRenameHint =>
      'Ipapakita ito sa halip na ang numero. Iwanang blangko para ang numero ulit ang ipakita.';

  @override
  String get memberNameSaved => 'Na-save ang pangalan';

  @override
  String get memberNameError =>
      'Hindi ma-save ang pangalan. Tingnan ang iyong internet at subukang muli.';

  @override
  String get auditMemberRenamed => 'Pinalitan ang pangalan ng miyembro';

  @override
  String get addPond => 'Magdagdag ng pond';

  @override
  String get addPondTitle => 'Magdagdag ng pond';

  @override
  String get addPondBody =>
      'Ilagay ang device ID kung saan sine-save ng sensor ang mga basa nito sa Firebase (readings/<device ID>). Magkakaroon ng sariling join code ang bagong pond.';

  @override
  String get addPondDeviceId => 'Device ID';

  @override
  String get addPondInvalidId =>
      'Gumamit ng 3 hanggang 40 letra, numero, - o _.';

  @override
  String get addPondNoReadings =>
      'Walang nakitang basa para sa device ID na iyan. Tingnan ito sa Firebase sa ilalim ng readings.';

  @override
  String get addPondExists => 'Pond na ang device na iyan.';

  @override
  String get addPondError =>
      'Hindi maidagdag ang pond. Tingnan ang iyong internet at subukang muli.';

  @override
  String addPondAdded(String code) {
    return 'Naidagdag ang pond. Join code: $code';
  }

  @override
  String get addPondCreate => 'Idagdag';

  @override
  String get auditPondAdded => 'Nagdagdag ng pond';

  @override
  String get adminPondPicker => 'Pond';

  @override
  String get healthGatewayPond1Only =>
      'Sa ngayon, pond1 lang ang sinusuportahan ng SMS gateway.';

  @override
  String get maintConfirmTitle => 'Baguhin ang iskedyul na ito?';

  @override
  String maintConfirmBody(String task) {
    return 'Susundin ng mga paalala para sa $task ang bagong iskedyul:';
  }

  @override
  String maintChangeLastDone(String from, String to) {
    return 'Huling ginawa: $from → $to';
  }

  @override
  String maintChangeInterval(int from, int to) {
    return 'Bawat: $from → $to araw';
  }

  @override
  String maintChangeNote(String from, String to) {
    return 'Tala: $from → $to';
  }

  @override
  String get maintConfirmYes => 'Oo, baguhin';

  @override
  String get auditMaintenanceChanged => 'Binago ang iskedyul ng maintenance';

  @override
  String get adminDarkMode => 'Lumipat sa dark mode';

  @override
  String get adminLightMode => 'Lumipat sa light mode';

  @override
  String get adminSensorDevice => 'Sensor device';

  @override
  String get adminPondSearchHint =>
      'Maghanap ayon sa pangalan, ID, code, o numero';

  @override
  String get adminNoPondMatch => 'Walang pond na tugma sa hinanap mo.';

  @override
  String get adminChoosePond => 'Pumili ng pond';

  @override
  String adminPondCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pond',
      one: '1 pond',
    );
    return '$_temp0';
  }
}
