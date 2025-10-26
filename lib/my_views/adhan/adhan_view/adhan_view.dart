// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:risala/custom/custom_loading/custom_loading_screen/custom_loading_screen2.dart';
import 'package:risala/main.dart';
import 'package:risala/models/translation.dart';
import 'package:risala/translation/translation.dart';
import 'package:risala/vars/colors.dart';
import 'package:risala/vars/texts.dart';

class AdhanView extends StatefulWidget {
  const AdhanView({super.key});

  @override
  State<AdhanView> createState() => _AdhanViewState();
}

class _AdhanViewState extends State<AdhanView>
    with SingleTickerProviderStateMixin {
  PrayerTimes? prayerTimes;
  String nextPrayerName = "";
  Duration timeLeft = Duration.zero;
  Timer? timer;
  String cityName = "";
  bool isManual = false;
  bool isLoading = false;
  bool isSearchExpanded = false;

  final TextEditingController cityController = TextEditingController();

  CalculationMethod selectedMethod = CalculationMethod.egyptian;
  Madhab selectedMadhab = Madhab.shafi;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  double? savedLat;
  double? savedLng;

  ////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////

  Translation? translation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // نستخدم postFrameCallback لتشغيل الـ async init بأمان داخل initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    // نجعل الشاشة في وضع loading حتى تكتمل الإعدادات الأساسية
    if (!mounted) return;
    setState(() => isLoading = true);

    await loadAllTranslations(); // الآن تنتظر الترجمات
    await loadSavedSettingsAndPrayerTimes(); // ثم نحمّل الإعدادات وأوقات الصلاة

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  Future<void> loadAllTranslations() async {
    try {
      // loadTranslation يتوقع قيمة مفتاح اللغة من sharedPref أو null
      final selected = sharedPref.getString("selectedValue");
      final list = await loadTranslation(selected);
      if (!mounted) return;
      setState(() {
        translation = list.isNotEmpty ? list.first : null;
      });
    } catch (e) {
      // لا نحب الكراش — نعرض فقط في حال أردنا تتبع الأخطاء
      if (mounted) {
        setState(() {
          translation = null;
        });
      }
    }
  }

  Future<void> loadSavedSettingsAndPrayerTimes() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      // قراءة الإعدادات من SharedPreferences (نخزن enum.name وليس الاسم المعروض)
      String? savedCity = sharedPref.getString("savedCityName");
      savedLat = sharedPref.getDouble("savedCityLat");
      savedLng = sharedPref.getDouble("savedCityLng");
      String? savedMethod = sharedPref.getString("savedCalculationMethod");
      String? savedMadhab = sharedPref.getString("savedMadhab");

      // استرجاع طريقة الحساب والمذهب من enum.name
      if (savedMethod != null) {
        selectedMethod = CalculationMethod.values.firstWhere(
            (m) => m.name == savedMethod,
            orElse: () => CalculationMethod.egyptian);
      }

      if (savedMadhab != null) {
        selectedMadhab = Madhab.values.firstWhere((m) => m.name == savedMadhab,
            orElse: () => Madhab.shafi);
      }

      // تحميل أوقات الصلاة
      if (savedCity != null && savedLat != null && savedLng != null) {
        await loadPrayerTimes(
          coords: Coordinates(savedLat!, savedLng!),
          city: savedCity,
          save: false,
        );
      } else {
        // إذا لا توجد بيانات محفوظة، نستخدم الموقع الحالي مرة واحدة فقط
        final position = await getCurrentLocation();
        await loadPrayerTimes(
          coords: Coordinates(position.latitude, position.longitude),
          city: translation != null
              ? (translation!.yourCurrentLocation.isNotEmpty
                  ? translation!.yourCurrentLocation
                  : "موقعك الحالي")
              : "موقعك الحالي",
          save: true,
        );
      }
    } catch (e) {
      // لا نريد كراش — اظهر رسالة للمستخدم
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("خطأ أثناء تحميل الإعدادات: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(translation != null
          ? translation!.locationServiceIsDisabled.isNotEmpty
              ? translation!.locationServiceIsDisabled
              : "خدمة الموقع غير مفعّلة"
          : "خدمة الموقع غير مفعّلة");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception(translation != null
            ? translation!.locationPermissionDenied.isNotEmpty
                ? translation!.locationPermissionDenied
                : "تم رفض إذن الموقع"
            : "تم رفض إذن الموقع");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // مستخدم رفض الإذن نهائياً، نبلّغه بالإجراء المطلوب
      throw Exception(translation != null
          ? translation!.locationPermissionDenied.isNotEmpty
              ? translation!.locationPermissionDenied
              : "تم رفض إذن الموقع نهائياً. يرجى تفعيل الإذن من إعدادات الجهاز."
          : "تم رفض إذن الموقع نهائياً. يرجى تفعيل الإذن من إعدادات الجهاز.");
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> loadPrayerTimes(
      {required Coordinates coords,
      required String city,
      bool save = true}) async {
    try {
      if (!isManual && mounted) {
        setState(() => isLoading = true);
      }

      final params = selectedMethod.getParameters();
      params.madhab = selectedMadhab;

      final date = DateComponents.from(DateTime.now());
      final times = PrayerTimes(coords, date, params);

      if (save) {
        sharedPref.setString("savedCityName", city);
        sharedPref.setDouble("savedCityLat", coords.latitude);
        sharedPref.setDouble("savedCityLng", coords.longitude);
      }

      if (!mounted) return;
      setState(() {
        prayerTimes = times;
        cityName = city;
        savedLat = coords.latitude;
        savedLng = coords.longitude;
        isLoading = false;
      });

      _fadeController.forward(from: 0);
      startCountdown();
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("تعذر تحديد الموقع أو المدينة: $e")),
        );
      }
    }
  }

  Future<void> searchCityAndLoad() async {
    final input = cityController.text.trim();
    if (input.isEmpty) {
      // إذا لم يدخل المستخدم اسم مدينة فلن نفعل شيئًا
      setState(() {
        if (isSearchExpanded) isSearchExpanded = false;
      });
      return;
    }

    setState(() {
      isManual = true;
      isLoading = true;
    });

    try {
      final locations = await locationFromAddress(input);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final coords = Coordinates(loc.latitude, loc.longitude);

        await loadPrayerTimes(coords: coords, city: input, save: true);
      } else {
        throw Exception(translation != null
            ? translation!.cityNotFound.isNotEmpty
                ? translation!.cityNotFound
                : "لم يتم العثور على المدينة"
            : "لم يتم العثور على المدينة");
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(translation != null
                  ? (translation!
                          .anErrorOccurredWhileSearchingForTheCity.isNotEmpty
                      ? translation!.anErrorOccurredWhileSearchingForTheCity
                      : "حدث خطأ أثناء البحث عن المدينة")
                  : "حدث خطأ أثناء البحث عن المدينة: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void startCountdown() {
    // تأكد من إيقاف Timer الحالي قبل بدأ واحد جديد
    timer?.cancel();

    if (prayerTimes == null) return;

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (prayerTimes == null) return;
      final now = DateTime.now();
      DateTime? nextPrayerTime;
      String? nextName;

      if (now.isBefore(prayerTimes!.fajr)) {
        nextPrayerTime = prayerTimes!.fajr;
        nextName = translation != null
            ? (translation!.alfajr.isNotEmpty ? translation!.alfajr : "الفجر")
            : "الفجر";
      } else if (now.isBefore(prayerTimes!.sunrise)) {
        nextPrayerTime = prayerTimes!.sunrise;
        nextName = translation != null
            ? (translation!.alshuruq.isNotEmpty
                ? translation!.alshuruq
                : "الشروق")
            : "الشروق";
      } else if (now.isBefore(prayerTimes!.dhuhr)) {
        nextPrayerTime = prayerTimes!.dhuhr;
        nextName = translation != null
            ? (translation!.alzahri.isNotEmpty ? translation!.alzahri : "الظهر")
            : "الظهر";
      } else if (now.isBefore(prayerTimes!.asr)) {
        nextPrayerTime = prayerTimes!.asr;
        nextName = translation != null
            ? (translation!.aleasra.isNotEmpty ? translation!.aleasra : "العصر")
            : "العصر";
      } else if (now.isBefore(prayerTimes!.maghrib)) {
        nextPrayerTime = prayerTimes!.maghrib;
        nextName = translation != null
            ? (translation!.almaghribi.isNotEmpty
                ? translation!.almaghribi
                : "المغرب")
            : "المغرب";
      } else if (now.isBefore(prayerTimes!.isha)) {
        nextPrayerTime = prayerTimes!.isha;
        nextName = translation != null
            ? (translation!.aleashai.isNotEmpty
                ? translation!.aleashai
                : "العشاء")
            : "العشاء";
      } else {
        nextPrayerTime = prayerTimes!.fajr.add(const Duration(days: 1));
        nextName = translation != null
            ? (translation!.alfajr.isNotEmpty ? translation!.alfajr : "الفجر")
            : "الفجر";
      }

      final diff = nextPrayerTime.difference(now);
      ////////////////////////////
      /////////////////////////////////////////////////////
      ///////////////////////////
      if (diff.inSeconds <= 0) {
        playAdhan(); // ✅ تشغيل الأذان
        startCountdown(); // ✅ حساب الصلاة التالية بعد التي صليناها
      }
      ////////////////////////////
      /////////////////////////////////////////////////////
      ///////////////////////////
      if (!mounted) return;
      setState(() {
        nextPrayerName = nextName!;
        timeLeft = diff;
      });
    });
  }

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;
    // نعرض بالساعات حتى لو أكثر من 24
    return "${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}";
  }

  @override
  void dispose() {
    timer?.cancel();
    cityController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  String _methodName(CalculationMethod method) {
    // نعرض دائمًا الأسماء بالعربية كما طلبت (لا نربطها بالترجمة)
    switch (method) {
      case CalculationMethod.muslim_world_league:
        return "رابطة العالم الإسلامي";
      case CalculationMethod.egyptian:
        return "الهيئة المصرية العامة للمساحة";
      case CalculationMethod.karachi:
        return "جامعة كراتشي الإسلامية";
      case CalculationMethod.umm_al_qura:
        return "أم القرى (مكة المكرمة)";
      case CalculationMethod.north_america:
        return "جمعية أمريكا الشمالية الإسلامية (ISNA)";
      case CalculationMethod.dubai:
        return "دائرة الشؤون الإسلامية (دبي)";
      default:
        return method.name;
    }
  }

  String _madhabName(Madhab madhab) {
    switch (madhab) {
      case Madhab.shafi:
        return "الشافعي / المالكي";
      case Madhab.hanafi:
        return "الحنفي";
    }
  }

  ////////////////////////////
  /////////////////////////////////////////////////////
  ///////////////////////////
  final AudioPlayer audioPlayer = AudioPlayer();

  Future<void> playAdhan() async {
    await audioPlayer
        .play(AssetSource("audio/adhan/Nasser_al_Qatami_Adhan.mp3"));
  }
  ////////////////////////////
  /////////////////////////////////////////////////////
  ///////////////////////////

  void scheduleAlarms() {
    if (prayerTimes == null) return;

    final prayers = {
      'fajr': prayerTimes!.fajr,
      'dhuhr': prayerTimes!.dhuhr,
      'asr': prayerTimes!.asr,
      'maghrib': prayerTimes!.maghrib,
      'isha': prayerTimes!.isha,
    };

    prayers.forEach((name, time) async {
      final now = DateTime.now();
      // إذا الوقت في المستقبل فقط
      if (time.isAfter(now)) {
        await AndroidAlarmManager.oneShotAt(
          time,
          name.hashCode, // معرف فريد لكل صلاة
          playAdhanInBackground,
          exact: true,
          wakeup: true,
        );
      }
    });
  }

  ////////////////////////////
  /////////////////////////////////////////////////////
  ///////////////////////////

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const CustomLoadingScreen2()
        : FadeTransition(
            opacity: _fadeAnimation,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 90),
              children: [
                // دائرة البحث المتحركة
                Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    width: isSearchExpanded
                        ? MediaQuery.of(context).size.width
                        : 55,
                    height: 55,
                    decoration: BoxDecoration(
                      border: Border.all(color: blackColor, width: 1),
                      color: Colors.white.withOpacity(0.9),
                      borderRadius:
                          BorderRadius.circular(isSearchExpanded ? 16 : 30),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: isSearchExpanded ? 1 : 0,
                            child: isSearchExpanded
                                ? TextField(
                                    controller: cityController,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      hintText: translation != null
                                          ? (translation!
                                                  .enterCityName.isNotEmpty
                                              ? translation!.enterCityName
                                              : "أدخل اسم المدينة")
                                          : "أدخل اسم المدينة",
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12),
                                    ),
                                    onSubmitted: (_) => searchCityAndLoad(),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isSearchExpanded && cityController.text.isEmpty
                                ? Icons.close
                                : Icons.search,
                            color: Colors.black87,
                            size: 32,
                          ),
                          onPressed: () {
                            if (isSearchExpanded &&
                                cityController.text.isNotEmpty) {
                              searchCityAndLoad();
                            } else {
                              setState(() {
                                isSearchExpanded = !isSearchExpanded;
                                if (!isSearchExpanded) cityController.clear();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // إعدادات طريقة الحساب والمذهب
                Column(
                  children: [
                    Text(
                      translation != null
                          ? (translation!.calculationMethod.isNotEmpty
                              ? translation!.calculationMethod
                              : "طريقة الحساب:")
                          : "طريقة الحساب:",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<CalculationMethod>(
                      value: selectedMethod,
                      onChanged: (method) async {
                        if (method != null) {
                          // خزن enum.name لضمان ثبات القيمة
                          sharedPref.setString(
                              "savedCalculationMethod", method.name);
                          setState(() => selectedMethod = method);

                          // أعد تحميل أوقات الصلاة إن كانت الإحداثيات متاحة
                          if (savedLat != null && savedLng != null) {
                            await loadPrayerTimes(
                                coords: Coordinates(savedLat!, savedLng!),
                                city: cityName);
                          } else {
                            // حاول الحصول على الموقع الحالي كخيار افتراضي
                            try {
                              final pos = await getCurrentLocation();
                              await loadPrayerTimes(
                                  coords:
                                      Coordinates(pos.latitude, pos.longitude),
                                  city: translation != null
                                      ? (translation!
                                              .yourCurrentLocation.isNotEmpty
                                          ? translation!.yourCurrentLocation
                                          : "موقعك الحالي")
                                      : "موقعك الحالي");
                            } catch (_) {
                              // لا نحتاج لفعل أي شيء إضافي هنا — الرسائل ظهرت سابقاً
                            }
                          }
                        }
                      },
                      items: CalculationMethod.values.map((m) {
                        return DropdownMenuItem(
                          value: m,
                          child: Text(_methodName(m)),
                        );
                      }).toList(),
                    ),
                    const Divider(),
                    Text(
                      translation != null
                          ? (translation!.almadhhab.isNotEmpty
                              ? translation!.almadhhab
                              : "المذهب:")
                          : "المذهب:",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<Madhab>(
                      value: selectedMadhab,
                      onChanged: (m) async {
                        if (m != null) {
                          sharedPref.setString("savedMadhab", m.name);
                          setState(() => selectedMadhab = m);
                          if (savedLat != null && savedLng != null) {
                            await loadPrayerTimes(
                                coords: Coordinates(savedLat!, savedLng!),
                                city: cityName);
                          } else {
                            try {
                              final pos = await getCurrentLocation();
                              await loadPrayerTimes(
                                  coords:
                                      Coordinates(pos.latitude, pos.longitude),
                                  city: translation != null
                                      ? (translation!
                                              .yourCurrentLocation.isNotEmpty
                                          ? translation!.yourCurrentLocation
                                          : "موقعك الحالي")
                                      : "موقعك الحالي");
                            } catch (_) {}
                          }
                        }
                      },
                      items: Madhab.values.map((m) {
                        return DropdownMenuItem(
                          value: m,
                          child: Text(_madhabName(m)),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                if (prayerTimes != null) ...[
                  Text(
                    "${translation != null ? (translation!.timeForTheNextPrayer.isNotEmpty ? translation!.timeForTheNextPrayer : "باقي على صلاة ") : "باقي على صلاة "}$nextPrayerName",
                    style: TextStyle(
                      fontSize: mytitlefontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatDuration(timeLeft),
                    style: TextStyle(
                      fontSize: mytitlefontSize,
                      fontWeight: FontWeight.w500,
                      color: dilutionScandColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${translation != null ? (translation!.prayerTimesIn.isNotEmpty ? translation!.prayerTimesIn : "أوقات الصلاة في ") : "أوقات الصلاة في "} $cityName",
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color.fromARGB(76, 0, 0, 0),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Table(
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: [
                        tableRow(
                            translation != null
                                ? (translation!.alfajr.isNotEmpty
                                    ? translation!.alfajr
                                    : "الفجر")
                                : "الفجر",
                            prayerTimes!.fajr),
                        tableRow(
                            translation != null
                                ? (translation!.alshuruq.isNotEmpty
                                    ? translation!.alshuruq
                                    : "الشروق")
                                : "الشروق",
                            prayerTimes!.sunrise),
                        tableRow(
                            translation != null
                                ? (translation!.alzahri.isNotEmpty
                                    ? translation!.alzahri
                                    : "الظهر")
                                : "الظهر",
                            prayerTimes!.dhuhr),
                        tableRow(
                            translation != null
                                ? (translation!.aleasra.isNotEmpty
                                    ? translation!.aleasra
                                    : "العصر")
                                : "العصر",
                            prayerTimes!.asr),
                        tableRow(
                            translation != null
                                ? (translation!.almaghribi.isNotEmpty
                                    ? translation!.almaghribi
                                    : "المغرب")
                                : "المغرب",
                            prayerTimes!.maghrib),
                        tableRow(
                            translation != null
                                ? (translation!.aleashai.isNotEmpty
                                    ? translation!.aleashai
                                    : "العشاء")
                                : "العشاء",
                            prayerTimes!.isha),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
  }

  TableRow tableRow(String name, DateTime time) {
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color.fromARGB(68, 0, 0, 0)),
        ),
      ),
      children: [
        // نعرض الوقت أولًا ثم الاسم — هذا منطقي للواجهة العربية
        Text(DateFormat.Hm().format(time), textAlign: TextAlign.center),
        Text(name, textAlign: TextAlign.right),
      ],
    );
  }
}
