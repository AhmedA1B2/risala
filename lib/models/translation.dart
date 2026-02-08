class Translation {
  // الحقول الأساسية (اختياري حسب حاجتك)
  final String key;
  final String text;

  // الحقول العامة
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

  // الحقول الجديدة (Tutorial & Confirmation)
  final String tutorialTasbih;
  final String tutorialNotifications;
  final String tutorialCompass;
  final String tutorialHome;
  final String tutorialMenu;
  final String confirmLanguageChange;

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
    // الحقول الجديدة في الـ Constructor
    required this.tutorialTasbih,
    required this.tutorialNotifications,
    required this.tutorialCompass,
    required this.tutorialHome,
    required this.tutorialMenu,
    required this.confirmLanguageChange,
  });

  factory Translation.fromMap(Map<String, dynamic> json, String langCode) {
    // الوصول للبيانات بناءً على هيكلة الـ JSON الخاص بك
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
      anErrorOccurredWhileSearchingForTheCity: data["anErrorOccurredWhileSearchingForTheCity"] ?? "",
      gettingLocation: data["gettingLocation"] ?? "",
      savedLocation: data["SavedLocation"] ?? "",
      updateSite: data["UpdateSite"] ?? "",
      gradeDifference: data["gradeDifference"] ?? "",
      qiblaDirection: data["qiblaDirection"] ?? "",
      deviceOrientationNotAvailable: data["deviceOrientationNotAvailable"] ?? "",
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
      // جلب الحقول الجديدة من الـ JSON
      tutorialTasbih: data["tutorialTasbih"] ?? "",
      tutorialNotifications: data["tutorialNotifications"] ?? "",
      tutorialCompass: data["tutorialCompass"] ?? "",
      tutorialHome: data["tutorialHome"] ?? "",
      tutorialMenu: data["tutorialMenu"] ?? "",
      confirmLanguageChange: data["confirmLanguageChange"] ?? "",
    );
  }
}