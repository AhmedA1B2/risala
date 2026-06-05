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

  // الإشعارات والكل
  final String all;
  final String addNotificationTitle;
  final String addNotificationBody;

  // حقول الوقت والتواريخ
  final String chooseTime;
  final String time;
  final String days;

  // البوصلة والمظهر
  final String appearance;
  final String changeAppearance;
  final String previewAppearance; // تم التعديل
  final String glassEffect; // تم التعديل
  final String chooseColor; // تم التعديل
  final String morning; // تم التعديل
  final String evening; // تم التعديل
  final String prayerTime; // تم التعديل
  final String sleep; // تم التعديل
  final String tasbihAndDhikr; // تم التعديل
  final String wakingUp; // تم التعديل
  final String adhan; // تم التعديل
  final String mosque; // تم التعديل
  final String ablution; // تم التعديل
  final String homePlace; // تم التعديل
  final String restroom; // تم التعديل
  final String food; // تم التعديل
  final String locationAccessRequired; // تم التعديل
  final String permissionDeniedSettings; // تم التعديل
  final String permissionDeniedAppSettings; // تم التعديل
  final String compassNotSupported; // تم التعديل
  final String enableLocationService; // تم التعديل

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

  final String contactDeveloper;
  final String developerSupportTitle;
  final String developerSupportDescription;
  final String developerSupportHint;
  final String contactViaTelegram;

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
    required this.contactDeveloper,
    required this.developerSupportTitle,
    required this.developerSupportDescription,
    required this.developerSupportHint,
    required this.contactViaTelegram,
  });

  factory Translation.fromMap(Map<String, dynamic> json, String langCode) {
    final data = (json is List) ? json[0][langCode][0] : json[langCode][0];

    return Translation(
      key: '',
      text: '',
      theQuran: data["theQuran"] ?? "",
      ok: data["ok"] ?? "",
      languageAndText: data["languageAndText"] ?? "",
      explanatoryTextForTitle: data["explanatoryTextForTitle"] ?? "",
      explanatoryTextForAya: data["explanatoryTextForAya"] ?? "",
      save: data["save"] ?? "",
      support: data["support"] ?? "",
      theme: data["theme"] ?? "",
      numberOfVerses: data["numberOfVerses"] ?? "",
      turnOff: data["turnOff"] ?? "",
      turnOn: data["turnOn"] ?? "",
      error: data["error"] ?? "",
      playing: data["playing"] ?? "",
      saved: data["saved"] ?? "",
      dontSaved: data["dontSaved"] ?? "",
      verse: data["verse"] ?? "",
      surah: data["surah"] ?? "",
      searchHintText: data["searchHintText"] ?? "",
      adhkar: data["adhkar"] ?? "",
      yourCurrentLocation: data["yourCurrentLocation"] ?? "",
      locationServiceIsDisabled: data["locationServiceIsDisabled"] ?? "",
      locationPermissionDenied: data["locationPermissionDenied"] ?? "",
      enterCityName: data["enterCityName"] ?? "",
      cityNotFound: data["cityNotFound"] ?? "",
      anErrorOccurredWhileSearchingForTheCity:
          data["anErrorOccurredWhileSearchingForTheCity"] ?? "",
      gettingLocation: data["gettingLocation"] ?? "",
      savedLocation: data["SavedLocation"] ?? "",
      updateSite: data["UpdateSite"] ?? "",
      gradeDifference: data["gradeDifference"] ?? "",
      qiblaDirection: data["qiblaDirection"] ?? "",
      deviceOrientationNotAvailable:
          data["deviceOrientationNotAvailable"] ?? "",
      compassCalibration: data["compassCalibration"] ?? "",
      explanationOfCalibration: data["explanationOfCalibration"] ?? "",
      alfajr: data["alfajr"] ?? "",
      alshuruq: data["alshuruq"] ?? "",
      alzahri: data["alzahri"] ?? "",
      aleasra: data["aleasra"] ?? "",
      almaghribi: data["almaghribi"] ?? "",
      aleashai: data["aleashai"] ?? "",
      timeForTheNextPrayer: data["timeForTheNextPrayer"] ?? "",
      prayerTimesIn: data["prayerTimesIn"] ?? "",
      calculationMethod: data["calculationMethod"] ?? "",
      almadhhab: data["almadhhab"] ?? "",
      tutorialTasbih: data["tutorialTasbih"] ?? "",
      tutorialNotifications: data["tutorialNotifications"] ?? "",
      tutorialCompass: data["tutorialCompass"] ?? "",
      tutorialHome: data["tutorialHome"] ?? "",
      tutorialMenu: data["tutorialMenu"] ?? "",
      confirmLanguageChange: data["confirmLanguageChange"] ?? "",
      saturday: data["saturday"] ?? "",
      sunday: data["sunday"] ?? "",
      monday: data["monday"] ?? "",
      tuesday: data["tuesday"] ?? "",
      wednesday: data["wednesday"] ?? "",
      thursday: data["thursday"] ?? "",
      friday: data["friday"] ?? "",
      all: data["all"] ?? "",
      addNotificationTitle: data["addNotificationTitle"] ?? "",
      addNotificationBody: data["addNotificationBody"] ?? "",
      chooseTime: data["chooseTime"] ?? "",
      time: data["time"] ?? "",
      days: data["days"] ?? "",
      //
      ablution: data["Ablution"] ?? "",
      adhan: data["Adhan"] ?? "",
      appearance: data["Appearance"] ?? "",
      changeAppearance: data["Change Appearance"] ?? "",
      chooseColor: data["Choose Color"] ?? "",
      compassNotSupported:
          data["This device does not support a compass sensor"] ?? "",
      enableLocationService:
          data["Please enable location service from device settings"] ?? "",
      evening: data["Evening"] ?? "",
      food: data["Food"] ?? "",
      glassEffect: data["Glass Effect"] ?? "",
      homePlace: data["Home"] ?? "",
      locationAccessRequired:
          data["Location access must be allowed to use the compass"] ?? "",
      morning: data["Morning"] ?? "",
      mosque: data["Mosque"] ?? "",
      permissionDeniedAppSettings: data[
              "Permission permanently denied. Please enable it from app settings"] ??
          "",
      permissionDeniedSettings: data[
              "Permission permanently denied. Please enable it from settings"] ??
          "",
      prayerTime: data["Prayer"] ?? "",
      previewAppearance: data["Preview Appearance"] ?? "",
      restroom: data["Restroom"] ?? "",
      sleep: data["Sleep"] ?? "",
      tasbihAndDhikr: data["Tasbih and Dhikr"] ?? "",
      wakingUp: data["Waking Up"] ?? "",

      dailyStreak: data["dailyStreak"] ?? "",
      dailyStreakDescription: data["dailyStreakDescription"] ?? "",
      daysLabel: data["daysLabel"] ?? "",
      dayLabel: data["dayLabel"] ?? "",
      okButton: data["okButton"] ?? "",
      hafsNarration: data["hafsNarration"] ?? "",
      qaloonNarration: data["qaloonNarration"] ?? "",
      gpsDisabledForQibla: data["gpsDisabledForQibla"] ?? "",
      locationPermissionPermanentlyDenied:
          data["locationPermissionPermanentlyDenied"] ?? "",
      compassNotSupportedDetailed: data["compassNotSupportedDetailed"] ?? "",
      compassSetupError: data["compassSetupError"] ?? "",
      locationDisabled: data["locationDisabled"] ?? "",
      openLocationSettings: data["openLocationSettings"] ?? "",
      retry: data["retry"] ?? "",
      contactDeveloper: data["contactDeveloper"] ?? "",
      developerSupportTitle: data["developerSupportTitle"] ?? "",
      developerSupportDescription: data["developerSupportDescription"] ?? "",
      developerSupportHint: data["developerSupportHint"] ?? "",
      contactViaTelegram: data["contactViaTelegram"] ?? "",
    );
  }
}
