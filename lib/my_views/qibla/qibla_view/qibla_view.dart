import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:risala/main.dart';
import 'package:risala/models/translation.dart';
import 'package:risala/my_views/qibla/custom_text/custom_text_fo_directions.dart';
import 'package:risala/translation/translation.dart';
import 'package:risala/vars/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QiblaView extends StatefulWidget {
  const QiblaView({super.key});

  @override
  State<QiblaView> createState() => _QiblaViewState();
}

class _QiblaViewState extends State<QiblaView>
    with SingleTickerProviderStateMixin {
  double? _heading; // device heading (degrees) 0 = North
  Position? _position; // live GPS position
  StreamSubscription<Position>? _posSub;
  StreamSubscription<CompassEvent>? _compassSub;
  SharedPreferences? _prefs;

  // Kaaba coordinates
  static const double _kaabaLat = 21.422487;
  static const double _kaabaLon = 39.826206;

  // cached values (read from SharedPreferences)
  double? _cachedLat;
  double? _cachedLon;
  double? _cachedQibla;

  // animation smoothing
  late double _displayedRotation; // radians applied to decorative arrow

  @override
  void dispose() {
    _posSub?.cancel();
    _compassSub?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _displayedRotation = 0.0;
    _initFast();
    loadAllTranslations();
  }

  Future<void> _initFast() async {
    _prefs = await SharedPreferences.getInstance();
    _readCached();

    _initCompass(); // شغل البوصلة

    await _checkPermissionAndStart();
  }

  Future<void> _checkPermissionAndStart() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translation != null
                ? translation!.locationAccessRequired.isNotEmpty
                    ? translation!.locationAccessRequired
                    : "يجب السماح بالوصول للموقع لاستخدام البوصلة"
                : "يجب السماح بالوصول للموقع لاستخدام البوصلة"),
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text(translation != null
                ? translation!.permissionDeniedSettings.isNotEmpty
                    ? translation!.permissionDeniedSettings
                    : "تم رفض الصلاحية نهائيًا. يرجى تفعيلها من الإعدادات"
                :"تم رفض الصلاحية نهائيًا. يرجى تفعيلها من الإعدادات"),
        ),
      );
      await Geolocator.openAppSettings();
      return;
    }

    // ✅ الآن فقط نستدعي الموقع
    final last = await Geolocator.getLastKnownPosition();
    if (last != null) {
      _position = last;
      _cachedQibla = _calculateQiblaBearing(last.latitude, last.longitude);
      setState(() {});
    }

    _initLocationLive();
  }

  void _initCompass() {
    if (FlutterCompass.events == null) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text(translation != null
                ? translation!.compassNotSupported.isNotEmpty
                    ? translation!.compassNotSupported
                    : "هذا الجهاز لا يدعم مستشعر البوصلة"
                :"هذا الجهاز لا يدعم مستشعر البوصلة"),
        ),
      );
      return;
    }

    _compassSub = FlutterCompass.events!.listen((event) {
      if (event.heading != null && mounted) {
        _heading = event.heading;
        setState(() {});
      }
    });
  }

  void _initLocationLive() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text(translation != null
                ? translation!.locationAccessRequired.isNotEmpty
                    ? translation!.locationAccessRequired
                    : "يجب السماح بالوصول للموقع لاستخدام البوصلة"
                :"يجب السماح بالوصول للموقع لاستخدام البوصلة"),
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content:
              Text(translation != null
                ? translation!.permissionDeniedAppSettings.isNotEmpty
                    ? translation!.permissionDeniedAppSettings
                    :"تم رفض الصلاحية نهائيًا. يرجى تفعيلها من إعدادات التطبيق"
                :"تم رفض الصلاحية نهائيًا. يرجى تفعيلها من إعدادات التطبيق"),
        ),
      );
      await Geolocator.openAppSettings();
      return;
    }

    _posSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 20,
      ),
    ).listen((pos) async {
      if (!mounted) return;

      _position = pos;
      _cachedQibla = _calculateQiblaBearing(pos.latitude, pos.longitude);

      await _saveCache(pos.latitude, pos.longitude, _cachedQibla!);

      setState(() {});
    });
  }

  void _readCached() {
    _cachedLat = _prefs?.getDouble('lastLat');
    _cachedLon = _prefs?.getDouble('lastLon');
    _cachedQibla = _prefs?.getDouble('lastQibla');
    if (_cachedLat != null && _cachedLon != null) {
      _position = Position(
        longitude: _cachedLon!,
        latitude: _cachedLat!,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }
  }

  Future<void> _saveCache(double lat, double lon, double qibla) async {
    await _prefs?.setDouble('lastLat', lat);
    await _prefs?.setDouble('lastLon', lon);
    await _prefs?.setDouble('lastQibla', qibla);
  }

  double _degToRad(double deg) => deg * pi / 180.0;
  double _radToDeg(double rad) => rad * 180.0 / pi;

  double _calculateQiblaBearing(double lat, double lon) {
    final double phi1 = _degToRad(lat);
    final double phi2 = _degToRad(_kaabaLat);
    final double deltaLambda = _degToRad(_kaabaLon - lon);

    final double y = sin(deltaLambda) * cos(phi2);
    final double x =
        cos(phi1) * sin(phi2) - sin(phi1) * cos(phi2) * cos(deltaLambda);

    final double theta = atan2(y, x);
    final double bearing = (_radToDeg(theta) + 360) % 360;
    return bearing;
  }

  double _computeRotationRadians(double qiblaBearing, double deviceHeading) {
    final double diff = (qiblaBearing - deviceHeading + 360) % 360;
    return _degToRad(diff);
  }

  Translation? translation;

  Future<void> loadAllTranslations() async {
    final list = await loadTranslation(sharedPref.getString("selectedValue"));
    if (!mounted) return;
    setState(() {
      translation = list.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pos = _position;
    final heading = _heading;

    double? qibla = _cachedQibla;
    if (_cachedQibla != null) {
      qibla = _cachedQibla;
    }

    double targetRotation = 0.0;
    if (qibla != null && heading != null) {
      targetRotation = _computeRotationRadians(qibla, heading);
    }

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              SizedBox(
                width: 300,
                height: 300,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: scandColor,
                        border: Border.all(color: dilutionScandColor, width: 2),
                        boxShadow: const [
                          BoxShadow(
                              blurRadius: 6,
                              color: Colors.black45,
                              offset: Offset(0, 4))
                        ],
                      ),
                    ),
                    const CustomTextFoDirections(
                      text: 'N',
                      top: 12,
                    ),
                    const CustomTextFoDirections(
                      right: 12,
                      text: 'E',
                    ),
                    const CustomTextFoDirections(
                      text: 'S',
                      bottom: 12,
                    ),
                    const CustomTextFoDirections(
                      text: 'W',
                      left: 12,
                    ),
                    ClipOval(
                      child: Container(
                        width: 110,
                        height: 110,
                        color: whiteColor,
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Image.asset('assets/images/kaaba.png',
                              fit: BoxFit.contain),
                        ),
                      ),
                    ),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                          begin: _displayedRotation, end: targetRotation),
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOut,
                      builder: (context, angle, child) {
                        _displayedRotation = angle;
                        return Transform.rotate(
                          angle: angle,
                          child: child,
                        );
                      },
                      child: SizedBox(
                        width: 240,
                        height: 240,
                        child: Center(
                          child: CustomPaint(
                            size: const Size(240, 240),
                            painter: _DecorativeArrowPainter(),
                          ),
                        ),
                      ),
                    ),
                    Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                            color: whiteColor, shape: BoxShape.circle)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Card(
                color: scandColor,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      if (pos != null) ...[
                        Text(
                            '${translation != null ? translation!.yourCurrentLocation.isNotEmpty ? translation!.yourCurrentLocation : "موقعي :" : "موقعي :"} ${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}',
                            style: const TextStyle(color: whiteColor)),
                      ] else if (_cachedLat != null) ...[
                        Text(
                            '${translation != null ? translation!.savedLocation.isNotEmpty ? translation!.savedLocation : "موقع مخزن:" : "موقع مخزن:"} ${_cachedLat!.toStringAsFixed(5)}, ${_cachedLon!.toStringAsFixed(5)}',
                            style: const TextStyle(color: Colors.white70)),
                      ] else ...[
                        Text(
                            translation != null
                                ? translation!.gettingLocation.isNotEmpty
                                    ? translation!.gettingLocation
                                    : "جاري الحصول على الموقع..."
                                : 'جاري الحصول على الموقع...',
                            style: TextStyle(color: Colors.white70)),
                      ],
                      const SizedBox(height: 6),
                      if (qibla != null) ...[
                        Text(
                            '${translation != null ? translation!.qiblaDirection.isNotEmpty ? translation!.qiblaDirection : "اتجاه القبلة :" : "اتجاه القبلة :"} ${qibla.toStringAsFixed(1)}°',
                            style: const TextStyle(color: whiteColor)),
                      ],
                      const SizedBox(height: 6),
                      if (heading != null && qibla != null) ...[
                        Builder(builder: (context) {
                          final diff = ((qibla! - heading + 360) % 360);
                          final display = diff > 180 ? diff - 360 : diff;
                          return Text(
                              '${translation != null ? translation!.gradeDifference.isNotEmpty ? translation!.gradeDifference : "فرق الدرجات :" : "فرق الدرجات :"} ${display.toStringAsFixed(1)}°',
                              style: const TextStyle(color: whiteColor));
                        })
                      ] else ...[
                        Text(
                            translation != null
                                ? translation!.deviceOrientationNotAvailable
                                        .isNotEmpty
                                    ? translation!.deviceOrientationNotAvailable
                                    : 'اتجاه الجهاز: غير متوفر'
                                : 'اتجاه الجهاز: غير متوفر',
                            style: TextStyle(color: Colors.white70)),
                      ],
                      const SizedBox(height: 10),
                      Wrap(
                        children: [
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                try {
                                  bool serviceEnabled = await Geolocator
                                      .isLocationServiceEnabled();
                                  if (!serviceEnabled) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                       SnackBar(
                                        content: Text(
                                            translation != null
                ? translation!.enableLocationService.isNotEmpty
                    ? translation!.enableLocationService
                    : "الرجاء تفعيل خدمة الموقع من إعدادات الجهاز"
                :"الرجاء تفعيل خدمة الموقع من إعدادات الجهاز"),
                                      ),
                                    );
                                    await Geolocator.openLocationSettings();
                                    return;
                                  }

                                  LocationPermission permission =
                                      await Geolocator.checkPermission();

                                  if (permission == LocationPermission.denied) {
                                    permission =
                                        await Geolocator.requestPermission();
                                    if (permission ==
                                        LocationPermission.denied) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                         SnackBar(
                                          content: Text(
                                             translation != null
                ? translation!.locationAccessRequired.isNotEmpty
                    ? translation!.locationAccessRequired
                    : "يجب السماح بالوصول للموقع لاستخدام البوصلة"
                : "يجب السماح بالوصول للموقع لاستخدام البوصلة"),
                                        ),
                                      );
                                      return;
                                    }
                                  }

                                  if (permission ==
                                      LocationPermission.deniedForever) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                       SnackBar(
                                        content: Text(
                                            translation != null
                ? translation!.permissionDeniedAppSettings.isNotEmpty
                    ? translation!.permissionDeniedAppSettings
                    : "تم رفض الصلاحية نهائيًا. يرجى تفعيلها من إعدادات التطبيق"
                :"تم رفض الصلاحية نهائيًا. يرجى تفعيلها من إعدادات التطبيق"),
                                      ),
                                    );
                                    await Geolocator.openAppSettings();
                                    return;
                                  }

                                  final pos =
                                      await Geolocator.getCurrentPosition(
                                          desiredAccuracy:
                                              LocationAccuracy.high);

                                  if (!mounted) return;

                                  setState(() => _position = pos);

                                  final q = _calculateQiblaBearing(
                                      pos.latitude, pos.longitude);
                                  await _saveCache(
                                      pos.latitude, pos.longitude, q);
                                } catch (e) {
                                  debugPrint("Location error: $e");
                                }
                              },
                              icon: Icon(
                                Icons.my_location,
                                color: dilutionScandColor,
                              ),
                              label: Text(
                                translation != null
                                    ? translation!.updateSite.isNotEmpty
                                        ? translation!.updateSite
                                        : 'تحديث الموقع'
                                    : 'تحديث الموقع',
                                style: TextStyle(color: dilutionScandColor),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await showDialog<void>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                          title: Text(translation != null
                                              ? translation!.compassCalibration
                                                      .isNotEmpty
                                                  ? translation!
                                                      .compassCalibration
                                                  : 'معايرة البوصلة'
                                              : 'معايرة البوصلة'),
                                          content: Text(translation != null
                                              ? translation!
                                                      .explanationOfCalibration
                                                      .isNotEmpty
                                                  ? translation!
                                                      .explanationOfCalibration
                                                  : 'قم بتحريك الهاتف في شكل رقم 8 واضبطه بعيدًا عن مصادر التشويش المغناطيسي.'
                                              : 'قم بتحريك الهاتف في شكل رقم 8 واضبطه بعيدًا عن مصادر التشويش المغناطيسي.'),
                                          actions: [
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text(translation != null
                                                    ? translation!.ok.isNotEmpty
                                                        ? translation!.ok
                                                        : 'حسنًا'
                                                    : 'حسنًا'))
                                          ],
                                        ));
                              },
                              icon: Icon(
                                Icons.explore,
                                color: dilutionScandColor,
                              ),
                              label: Text(
                                translation != null
                                    ? translation!.compassCalibration.isNotEmpty
                                        ? translation!.compassCalibration
                                        : 'معايرة البوصلة'
                                    : 'معايرة البوصلة',
                                style: TextStyle(color: dilutionScandColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Decorative arrow painter (Islamic-ish ornamental arrow)
class _DecorativeArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = mainColor;

    final borderPaint = Paint()
      ..color = dilutionScandColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 18;

    final spineTop = Offset(center.dx, center.dy - radius + 12);
    final spineBottom = Offset(center.dx, center.dy + 12);

    final spinePath = Path()
      ..moveTo(spineBottom.dx, spineBottom.dy)
      ..lineTo(spineTop.dx, spineTop.dy);
    canvas.drawPath(spinePath, paint);
    canvas.drawPath(spinePath, borderPaint);

    final ornamentPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = mainColor;

    final ornamentRect = Rect.fromCircle(
        center: Offset(center.dx - 8, spineTop.dy + 10), radius: 18);
    canvas.drawArc(ornamentRect, -pi / 3, pi * 2 / 3, false, ornamentPaint);
    canvas.drawArc(ornamentRect, -pi / 3, pi * 2 / 3, false, borderPaint);

    final tipPath = Path()
      ..moveTo(center.dx, spineTop.dy - 16)
      ..lineTo(center.dx - 8, spineTop.dy - 4)
      ..lineTo(center.dx, spineTop.dy + 8)
      ..lineTo(center.dx + 8, spineTop.dy - 4)
      ..close();

    final fill = Paint()..color = mainColor;
    canvas.drawPath(tipPath, fill);
    canvas.drawPath(tipPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
