class Translation {
  final String key;
  final String text;

  String theQuran;
  String ok;
  String languageAndText;
  String explanatoryTextForTitle;
  String explanatoryTextForAya;
  String save;
  String support;
  String theme;
  String numberOfVerses;
  String turnOff;
  String turnOn;
  String error;
  String playing;
  String saved;
  String verse;
  String surah;
  String searchHintText;
  String adhkar;
  String yourCurrentLocation;
  String locationServiceIsDisabled;
  String locationPermissionDenied;
  String enterCityName;
  String cityNotFound;
  String anErrorOccurredWhileSearchingForTheCity;
  String gettingLocation;
  String savedLocation;
  String updateSite;
  String gradeDifference;
  String qiblaDirection;
  String deviceOrientationNotAvailable;
  String compassCalibration;
  String explanationOfCalibration;
  String alfajr;
  String alshuruq;
  String alzahri;
  String aleasra;
  String almaghribi;
  String aleashai;
  String timeForTheNextPrayer;
  String prayerTimesIn;
  String calculationMethod;
  String almadhhab;

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
  });

  factory Translation.fromMap(Map<String, dynamic> json, String langCode) {
    final data = json[langCode][0];

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
    );
  }
}
