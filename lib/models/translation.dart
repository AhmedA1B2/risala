class Translation {
  final String key;
  final String text;

  // الحقول الأساسية
  final String theQuran;
  final String ok;
  final String languageAndText;
  final String explanatoryTextForTitle;
  final String explanatoryTextForAya;
  final String save;
  final String support;
  final String theme;
  final String numberOfVerses;
  final String turnOff;
  final String turnOn;
  final String error;
  final String playing;
  final String saved;
  final String dontSaved;
  final String verse;
  final String surah;
  final String searchHintText;
  final String adhkar;
  final String yourCurrentLocation;
  final String locationServiceIsDisabled;
  final String locationPermissionDenied;
  final String enterCityName;
  final String cityNotFound;
  final String anErrorOccurredWhileSearchingForTheCity;
  final String gettingLocation;
  final String savedLocation;
  final String updateSite;
  final String gradeDifference;
  final String qiblaDirection;
  final String deviceOrientationNotAvailable;
  final String compassCalibration;
  final String explanationOfCalibration;
  final String alfajr;
  final String alshuruq;
  final String alzahri;
  final String aleasra;
  final String almaghribi;
  final String aleashai;
  final String timeForTheNextPrayer;
  final String prayerTimesIn;
  final String calculationMethod;
  final String almadhhab;

  // التعليمات (Tutorial)
  final String tutorialTasbih;
  final String tutorialNotifications;
  final String tutorialCompass;
  final String tutorialHadith;
  final String tutorialHome;
  final String tutorialMenu;

  // تأكيد اللغة
  final String confirmLanguageChange;

  // أيام الأسبوع
  final String saturday;
  final String sunday;
  final String monday;
  final String tuesday;
  final String wednesday;
  final String thursday;
  final String friday;

  // الإشعارات والوقت
  final String all;
  final String addNotificationTitle;
  final String addNotificationBody;
  final String chooseTime;
  final String time;
  final String days;

  // المظهر
  final String appearance;
  final String changeAppearance;
  final String previewAppearance;
  final String glassEffect;
  final String chooseColor;
  final String morning;
  final String evening;
  final String prayerTime;
  final String sleep;
  final String tasbihAndDhikr;
  final String wakingUp;
  final String adhan;
  final String mosque;
  final String ablution;
  final String homePlace;
  final String restroom;
  final String food;
  final String locationAccessRequired;
  final String permissionDeniedSettings;
  final String permissionDeniedAppSettings;
  final String compassNotSupported;
  final String enableLocationService;

  // نافذة التعريف بالثيمات الجديدة
  final String themeDialogTitle;
  final String themeDialogSubtitle;
  final String themeDialogDescription;
  final String themeGoldName;
  final String themeNightSkyName;
  final String themeMinecraftNightName;
  final String themeOceanRainName;
  final String later;
  final String applyTheme;

  // الستريك والقرآن
  final String dailyStreak;
  final String dailyStreakDescription;
  final String daysLabel;
  final String dayLabel;
  final String okButton;
  final String hafsNarration;
  final String qaloonNarration;
  final String gpsDisabledForQibla;
  final String locationPermissionPermanentlyDenied;
  final String compassNotSupportedDetailed;
  final String compassSetupError;
  final String locationDisabled;
  final String openLocationSettings;
  final String retry;

  // نصوص البوصلة الجديدة
  final String qiblaSavedLocation;
  final String qiblaCoordinatesLocation;
  final String qiblaLocationUsed;
  final String qiblaNoSavedLocationError;

  // الدعم والتواصل
  final String contactDeveloper;
  final String developerSupportTitle;
  final String developerSupportDescription;
  final String developerSupportHint;
  final String contactViaTelegram;
  final String contactViaWhatsApp;
  final String contactViaEmail;
  final String contactLaunchError;
  final String contactWhatsAppUsernameMissing;
  final String contactEmailSubject;
  final String copy;
  final String hadithLangMessage;

  Translation({
    required this.key,
    required this.text,
    required this.theQuran,
    required this.ok,
    required this.languageAndText,
    required this.explanatoryTextForTitle,
    required this.explanatoryTextForAya,
    required this.save,
    required this.support,
    required this.theme,
    required this.numberOfVerses,
    required this.turnOff,
    required this.turnOn,
    required this.error,
    required this.playing,
    required this.saved,
    required this.dontSaved,
    required this.verse,
    required this.surah,
    required this.searchHintText,
    required this.adhkar,
    required this.yourCurrentLocation,
    required this.locationServiceIsDisabled,
    required this.locationPermissionDenied,
    required this.enterCityName,
    required this.cityNotFound,
    required this.anErrorOccurredWhileSearchingForTheCity,
    required this.gettingLocation,
    required this.savedLocation,
    required this.updateSite,
    required this.gradeDifference,
    required this.qiblaDirection,
    required this.deviceOrientationNotAvailable,
    required this.compassCalibration,
    required this.explanationOfCalibration,
    required this.alfajr,
    required this.alshuruq,
    required this.alzahri,
    required this.aleasra,
    required this.almaghribi,
    required this.aleashai,
    required this.timeForTheNextPrayer,
    required this.prayerTimesIn,
    required this.calculationMethod,
    required this.almadhhab,
    required this.tutorialTasbih,
    required this.tutorialNotifications,
    required this.tutorialCompass,
    required this.tutorialHadith,
    required this.tutorialHome,
    required this.tutorialMenu,
    required this.confirmLanguageChange,
    required this.saturday,
    required this.sunday,
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.all,
    required this.addNotificationTitle,
    required this.addNotificationBody,
    required this.chooseTime,
    required this.time,
    required this.days,
    required this.appearance,
    required this.changeAppearance,
    required this.previewAppearance,
    required this.glassEffect,
    required this.chooseColor,
    required this.morning,
    required this.evening,
    required this.prayerTime,
    required this.sleep,
    required this.tasbihAndDhikr,
    required this.wakingUp,
    required this.adhan,
    required this.mosque,
    required this.ablution,
    required this.homePlace,
    required this.restroom,
    required this.food,
    required this.locationAccessRequired,
    required this.permissionDeniedSettings,
    required this.permissionDeniedAppSettings,
    required this.compassNotSupported,
    required this.enableLocationService,
    this.themeDialogTitle = 'ثيمات جديدة!',
    this.themeDialogSubtitle = 'اختر المظهر الذي يناسبك',
    this.themeDialogDescription = 'أضفنا ثيمات جديدة لتخصيص مظهر تطبيق رسالة. اختر الثيم الذي يعجبك، ويمكنك تغييره في أي وقت لاحقًا.',
    this.themeGoldName = 'الذهبي',
    this.themeNightSkyName = 'سماء الليل',
    this.themeMinecraftNightName = 'ليل ماينكرافت',
    this.themeOceanRainName = 'مطر المحيط',
    this.later = 'لاحقًا',
    this.applyTheme = 'تطبيق الثيم',
    required this.dailyStreak,
    required this.dailyStreakDescription,
    required this.daysLabel,
    required this.dayLabel,
    required this.okButton,
    required this.hafsNarration,
    required this.qaloonNarration,
    required this.gpsDisabledForQibla,
    required this.locationPermissionPermanentlyDenied,
    required this.compassNotSupportedDetailed,
    required this.compassSetupError,
    required this.locationDisabled,
    required this.openLocationSettings,
    required this.retry,
    this.qiblaSavedLocation = 'Last saved location',
    this.qiblaCoordinatesLocation = 'Location from GPS coordinates',
    this.qiblaLocationUsed = 'Location used',
    this.qiblaNoSavedLocationError = 'Could not determine your current location and no previous location is saved. Check location permission and try again.',
    required this.contactDeveloper,
    required this.developerSupportTitle,
    required this.developerSupportDescription,
    required this.developerSupportHint,
    required this.contactViaTelegram,
    this.contactViaWhatsApp = 'Contact via WhatsApp',
    this.contactViaEmail = 'Contact via Email',
    this.contactLaunchError = 'Could not open the link or app. Please try again.',
    this.contactWhatsAppUsernameMissing = 'WhatsApp username is not configured.',
    this.contactEmailSubject = 'Contact about the Risala app',
    required this.copy,
    required this.hadithLangMessage,
  });

  factory Translation.fromMap(Map<String, dynamic> json, String langCode) {
    final dynamic languageData = json[langCode];
    final Map<String, dynamic> data;

    if (languageData is List && languageData.isNotEmpty && languageData.first is Map) {
      data = Map<String, dynamic>.from(languageData.first as Map);
    } else if (languageData is Map) {
      data = Map<String, dynamic>.from(languageData);
    } else {
      data = <String, dynamic>{};
    }

    String value(String key, [String fallback = '']) {
      final result = data[key];
      return result is String ? result : fallback;
    }

    return Translation(
      key: '',
      text: '',
      theQuran: value('theQuran'),
      ok: value('ok'),
      languageAndText: value('languageAndText'),
      explanatoryTextForTitle: value('explanatoryTextForTitle'),
      explanatoryTextForAya: value('explanatoryTextForAya'),
      save: value('save'),
      support: value('support'),
      theme: value('theme'),
      numberOfVerses: value('numberOfVerses'),
      turnOff: value('turnOff'),
      turnOn: value('turnOn'),
      error: value('error'),
      playing: value('playing'),
      saved: value('saved'),
      dontSaved: value('dontSaved'),
      verse: value('verse'),
      surah: value('surah'),
      searchHintText: value('searchHintText'),
      adhkar: value('adhkar'),
      yourCurrentLocation: value('yourCurrentLocation'),
      locationServiceIsDisabled: value('locationServiceIsDisabled'),
      locationPermissionDenied: value('locationPermissionDenied'),
      enterCityName: value('enterCityName'),
      cityNotFound: value('cityNotFound'),
      anErrorOccurredWhileSearchingForTheCity: value('anErrorOccurredWhileSearchingForTheCity'),
      gettingLocation: value('gettingLocation'),
      savedLocation: value('SavedLocation'),
      updateSite: value('UpdateSite'),
      gradeDifference: value('gradeDifference'),
      qiblaDirection: value('qiblaDirection'),
      deviceOrientationNotAvailable: value('deviceOrientationNotAvailable'),
      compassCalibration: value('compassCalibration'),
      explanationOfCalibration: value('explanationOfCalibration'),
      alfajr: value('alfajr'),
      alshuruq: value('alshuruq'),
      alzahri: value('alzahri'),
      aleasra: value('aleasra'),
      almaghribi: value('almaghribi'),
      aleashai: value('aleashai'),
      timeForTheNextPrayer: value('timeForTheNextPrayer'),
      prayerTimesIn: value('prayerTimesIn'),
      calculationMethod: value('calculationMethod'),
      almadhhab: value('almadhhab'),
      tutorialTasbih: value('tutorialTasbih'),
      tutorialNotifications: value('tutorialNotifications'),
      tutorialCompass: value('tutorialCompass'),
      tutorialHadith: value('tutorialHadith'),
      tutorialHome: value('tutorialHome'),
      tutorialMenu: value('tutorialMenu'),
      confirmLanguageChange: value('confirmLanguageChange'),
      saturday: value('saturday'),
      sunday: value('sunday'),
      monday: value('monday'),
      tuesday: value('tuesday'),
      wednesday: value('wednesday'),
      thursday: value('thursday'),
      friday: value('friday'),
      all: value('all'),
      addNotificationTitle: value('addNotificationTitle'),
      addNotificationBody: value('addNotificationBody'),
      chooseTime: value('chooseTime'),
      time: value('time'),
      days: value('days'),
      appearance: value('Appearance'),
      changeAppearance: value('Change Appearance'),
      previewAppearance: value('Preview Appearance'),
      glassEffect: value('Glass Effect'),
      chooseColor: value('Choose Color'),
      morning: value('Morning'),
      evening: value('Evening'),
      prayerTime: value('Prayer'),
      sleep: value('Sleep'),
      tasbihAndDhikr: value('Tasbih and Dhikr'),
      wakingUp: value('Waking Up'),
      adhan: value('Adhan'),
      mosque: value('Mosque'),
      ablution: value('Ablution'),
      homePlace: value('Home'),
      restroom: value('Restroom'),
      food: value('Food'),
      locationAccessRequired: value('Location access must be allowed to use the compass'),
      permissionDeniedSettings: value('Permission permanently denied. Please enable it from settings'),
      permissionDeniedAppSettings: value('Permission permanently denied. Please enable it from app settings'),
      compassNotSupported: value('This device does not support a compass sensor'),
      enableLocationService: value('Please enable location service from device settings'),
      themeDialogTitle: value('themeDialogTitle', 'ثيمات جديدة!'),
      themeDialogSubtitle: value('themeDialogSubtitle', 'اختر المظهر الذي يناسبك'),
      themeDialogDescription: value('themeDialogDescription', 'أضفنا ثيمات جديدة لتخصيص مظهر تطبيق رسالة. اختر الثيم الذي يعجبك، ويمكنك تغييره في أي وقت لاحقًا.'),
      themeGoldName: value('themeGoldName', 'الذهبي'),
      themeNightSkyName: value('themeNightSkyName', 'سماء الليل'),
      themeMinecraftNightName: value('themeMinecraftNightName', 'ليل ماينكرافت'),
      themeOceanRainName: value('themeOceanRainName', 'مطر المحيط'),
      later: value('later', 'لاحقًا'),
      applyTheme: value('applyTheme', 'تطبيق الثيم'),
      dailyStreak: value('dailyStreak'),
      dailyStreakDescription: value('dailyStreakDescription'),
      daysLabel: value('daysLabel'),
      dayLabel: value('dayLabel'),
      okButton: value('okButton'),
      hafsNarration: value('hafsNarration'),
      qaloonNarration: value('qaloonNarration'),
      gpsDisabledForQibla: value('gpsDisabledForQibla'),
      locationPermissionPermanentlyDenied: value('locationPermissionPermanentlyDenied'),
      compassNotSupportedDetailed: value('compassNotSupportedDetailed'),
      compassSetupError: value('compassSetupError'),
      locationDisabled: value('locationDisabled'),
      openLocationSettings: value('openLocationSettings'),
      retry: value('retry'),
      qiblaSavedLocation: value('qiblaSavedLocation', value('SavedLocation', 'Last saved location')),
      qiblaCoordinatesLocation: value('qiblaCoordinatesLocation', 'Location from GPS coordinates'),
      qiblaLocationUsed: value('qiblaLocationUsed', 'Location used'),
      qiblaNoSavedLocationError: value('qiblaNoSavedLocationError', value('compassSetupError', 'Could not determine your current location.')),
      contactDeveloper: value('contactDeveloper'),
      developerSupportTitle: value('developerSupportTitle'),
      developerSupportDescription: value('developerSupportDescription'),
      developerSupportHint: value('developerSupportHint'),
      contactViaTelegram: value('contactViaTelegram'),
      contactViaWhatsApp: value('contactViaWhatsApp', 'Contact via WhatsApp'),
      contactViaEmail: value('contactViaEmail', 'Contact via Email'),
      contactLaunchError: value('contactLaunchError', 'Could not open the link or app. Please try again.'),
      contactWhatsAppUsernameMissing: value('contactWhatsAppUsernameMissing', 'WhatsApp username is not configured.'),
      contactEmailSubject: value('contactEmailSubject', 'Contact about the Risala app'),
      copy: value('copy'),
      hadithLangMessage: value('hadithLangMessage'),
    );
  }
}
