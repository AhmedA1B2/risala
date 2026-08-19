import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ضرورية لالتقاط PlatformException
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:risala/custom/custom_loading/custom_loading_screen/custom_loading_screen2.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:risala/main.dart';
import 'package:risala/models/translation.dart';
import 'package:risala/translation/translation.dart';
import 'package:risala/vars/colors.dart';

class QiblaView extends StatefulWidget {
  const QiblaView({super.key});

  @override
  State<QiblaView> createState() => _QiblaViewState();
}

class _QiblaViewState extends State<QiblaView> {
  static const double _kaabaLat = 21.422487;
  static const double _kaabaLon = 39.826206;

  double? _cachedQibla;
  bool _isLoading = true;
  bool _isSupported = true;
  bool _isGpsDisabledError = false; // متغير جديد لحالة الـ GPS
  String _errorMessage = "";
  Translation? translation;

  @override
  void initState() {
    super.initState();
    loadAllTranslations();
    _checkHardwareAndPermissions();
  }

  /// الدالة الأساسية لفحص الموقع، الصلاحيات، والعتاد
  Future<void> _checkHardwareAndPermissions() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _isSupported = true;
      _isGpsDisabledError = false;
      _errorMessage = "";
    });

    try {
      // 1️⃣ أولاً: هل خدمة الموقع (GPS) مفعلة في إعدادات الهاتف؟
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setFailure(
          translation!.gpsDisabledForQibla,
          isGpsIssue: true,
        );
        return;
      }

      // 2️⃣ ثانياً: هل يمتلك التطبيق صلاحية الوصول للموقع؟
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _setFailure(translation!.locationPermissionDenied);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _setFailure(translation!.locationPermissionPermanentlyDenied);
        return;
      }

      // 3️⃣ ثالثاً: الفحص العميق للعتاد (المستشعر المغناطيسي)
      bool hasMagnetometer = false;
      try {
        // نحاول قراءة نبضة واحدة من المستشعر
        await magnetometerEventStream()
            .first
            .timeout(const Duration(milliseconds: 500));
        hasMagnetometer = true;
      } on PlatformException catch (e) {
        // مسك الخطأ NO_SENSOR في أجهزة مثل Samsung F12
        debugPrint("Hardware Error: ${e.message}");
        hasMagnetometer = false;
      } on TimeoutException {
        hasMagnetometer = false;
      } catch (e) {
        hasMagnetometer = false;
      }

      if (!hasMagnetometer) {
        _setFailure(translation!.compassNotSupportedDetailed);
        return;
      }

      // 4️⃣ أخيراً: جلب الموقع وحساب زاوية القبلة
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
      _cachedQibla =
          _calculateQiblaBearing(position.latitude, position.longitude);

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _setFailure(translation!.compassSetupError);
    }
  }

  void _setFailure(String message, {bool isGpsIssue = false}) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _isSupported = false;
        _errorMessage = message;
        _isGpsDisabledError = isGpsIssue;
      });
    }
  }

  // حسابات الزوايا
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
    return (_radToDeg(theta) + 360) % 360;
  }

  double _computeRotationRadians(double qiblaBearing, double deviceHeading) {
    final double diff = (qiblaBearing - deviceHeading + 360) % 360;
    return _degToRad(diff);
  }

  Future<void> loadAllTranslations() async {
    final list = await loadTranslation(sharedPref.getString("selectedValue"));
    if (mounted) {
      setState(() => translation = list.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: _isLoading
              ? const CustomLoadingScreen2()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    if (!_isSupported) ...[
                      // أيقونة تتغير حسب نوع الخطأ
                      Icon(
                        _isGpsDisabledError
                            ? Icons.location_off
                            : Icons.error_outline,
                        color: Colors.red,
                        size: 80,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isGpsDisabledError
                            ? translation!.locationDisabled
                            : translation!.compassNotSupported,
                        style: TextStyle(
                            color: scandColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 10),
                        child: Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: scandColor, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: scandColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12),
                        ),
                        onPressed: () async {
                          if (_isGpsDisabledError) {
                            // فتح إعدادات الموقع في الهاتف مباشرة
                            await Geolocator.openLocationSettings();
                          } else {
                            // إعادة محاولة الفحص
                            _checkHardwareAndPermissions();
                          }
                        },
                        child: Text(
                          _isGpsDisabledError
                              ? translation!.openLocationSettings
                              : translation!.retry,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                      )
                    ] else ...[
                      // واجهة البوصلة عند نجاح كل الفحوصات
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.width * 0.8,
                            decoration: BoxDecoration(
                              color: scandColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: dilutionScandColor, width: 4),
                            ),
                            child: const Stack(
                              alignment: AlignmentGeometry.center,
                              children: [
                                Positioned(
                                    top: 15,
                                    child: Text("N",
                                        style: TextStyle(
                                            color: whiteColor,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold))),
                                Positioned(
                                    right: 15,
                                    child: Text("E",
                                        style: TextStyle(
                                            color: whiteColor, fontSize: 24))),
                                Positioned(
                                    bottom: 15,
                                    child: Text("S",
                                        style: TextStyle(
                                            color: whiteColor, fontSize: 24))),
                                Positioned(
                                    left: 15,
                                    child: Text("W",
                                        style: TextStyle(
                                            color: whiteColor, fontSize: 24))),
                              ],
                            ),
                          ),
                          StreamBuilder<CompassEvent>(
                            stream: FlutterCompass.events,
                            builder: (context, snapshot) {
                              if (snapshot.hasError ||
                                  snapshot.data?.heading == null) {
                                return const Icon(Icons.navigation,
                                    size: 150, color: Colors.grey);
                              }
                              double heading = snapshot.data!.heading!;
                              double rotation = _computeRotationRadians(
                                  _cachedQibla!, heading);
                              return Transform.rotate(
                                angle: rotation,
                                child: Icon(Icons.navigation,
                                    size: 160, color: mainColor),
                              );
                            },
                          ),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                                color: scandColor,
                                border: Border.all(
                                    color: dilutionScandColor, width: 5),
                                shape: BoxShape.circle),
                          )
                        ],
                      ),
                      if (_cachedQibla != null && translation != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                color: scandColor,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                    color: dilutionScandColor, width: 2)),
                            child: Text(
                              "${translation!.qiblaDirection} ${_cachedQibla!.toStringAsFixed(1)}°",
                              style: const TextStyle(
                                  color: whiteColor, fontSize: 18),
                            ),
                          ),
                        ),
                    ],
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                          onPressed: () {
                            setState(() {
                              loadAllTranslations();
                              _checkHardwareAndPermissions();
                            });
                          },
                          icon: Stack(
                            children: [
                              Icon(
                                Icons.refresh_rounded,
                                color: dilutionScandColor,
                                size: 50,
                              ),
                              Icon(
                                Icons.refresh_rounded,
                                color: scandColor,
                                size: 48,
                              ),
                            ],
                          )),
                    ),
                    const SizedBox(
                      height: 150,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
