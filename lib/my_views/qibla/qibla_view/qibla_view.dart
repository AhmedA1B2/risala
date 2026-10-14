import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:risala/custom/custom_loading/custom_loading_screen/custom_loading_screen2.dart';
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

  // Keys used to preserve the last usable location between app launches.
  static const String _latitudeKey = 'qibla_last_latitude';
  static const String _longitudeKey = 'qibla_last_longitude';
  static const String _locationNameKey = 'qibla_last_location_name';

  double? _cachedQibla;
  double? _lastLatitude;
  double? _lastLongitude;

  bool _isLoading = true;
  bool _isSupported = true;
  bool _isGpsDisabledError = false;
  bool _isUsingSavedLocation = false;

  String _errorMessage = '';
  String _lastLocationName = '';
  Translation? translation;

  // Prevents an older reverse-geocoding request from overwriting a newer one.
  int _locationLookupGeneration = 0;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await loadAllTranslations();
    if (!mounted) return;
    if (translation == null) {
      setState(() {
        _isLoading = false;
        _isSupported = false;
        _errorMessage =
            'تعذر تحميل إعدادات البوصلة. أعد فتح الصفحة وحاول مجددًا.';
      });
      return;
    }
    await _checkHardwareAndPermissions();
  }

  /// Loads the saved location first, so the Qibla can appear without Internet.
  void _loadSavedLocation() {
    final latitude = sharedPref.getDouble(_latitudeKey);
    final longitude = sharedPref.getDouble(_longitudeKey);

    if (latitude == null ||
        longitude == null ||
        !_isValidCoordinates(latitude, longitude)) {
      return;
    }

    _lastLatitude = latitude;
    _lastLongitude = longitude;
    _cachedQibla = _calculateQiblaBearing(latitude, longitude);
    _lastLocationName =
        sharedPref.getString(_locationNameKey)?.trim().isNotEmpty == true
            ? sharedPref.getString(_locationNameKey)!.trim()
            : _savedLocationText;
    _isUsingSavedLocation = true;
  }

  /// Checks the compass sensor, then tries to refresh the location.
  /// A cached location remains usable if GPS, permissions, or Internet fail.
  Future<void> _checkHardwareAndPermissions() async {
    if (!mounted || translation == null) return;

    setState(() {
      _isGpsDisabledError = false;
      _errorMessage = '';
      if (_cachedQibla == null) {
        _isLoading = true;
      } else {
        // Do not hide the already-computed direction while refreshing GPS.
        _isLoading = false;
        _isSupported = true;
      }
    });

    // Read the cached coordinates before trying any system location service.
    _loadSavedLocation();
    if (_cachedQibla != null && mounted) {
      setState(() {
        _isLoading = false;
        _isSupported = true;
      });
    }

    // Test the same compass stream that the UI uses.
    try {
      final compassEvents = FlutterCompass.events;
      if (compassEvents == null) {
        _setFailure(translation!.compassNotSupportedDetailed);
        return;
      }

      await compassEvents
          .firstWhere((event) => event.heading != null)
          .timeout(const Duration(seconds: 3));
    } on TimeoutException {
      _setFailure(translation!.compassNotSupportedDetailed);
      return;
    } catch (e) {
      debugPrint('Compass sensor error: $e');
      _setFailure(translation!.compassNotSupportedDetailed);
      return;
    }

    bool serviceEnabled = false;
    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled()
          .timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('Could not check location service: $e');
    }

    // Location services are only needed to obtain a new location, not to use
    // the previously saved coordinates.
    if (!serviceEnabled) {
      if (_cachedQibla == null) {
        _setFailure(translation!.gpsDisabledForQibla, isGpsIssue: true);
      }
      return;
    }

    try {
      LocationPermission permission = await Geolocator.checkPermission();

      // Do not repeatedly show a permission dialog when a saved location is
      // already available. Ask only when the app has no usable coordinates.
      if (permission == LocationPermission.denied && _cachedQibla == null) {
        permission = await Geolocator.requestPermission();
      }

      final hasLocationPermission =
          permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always;

      if (!hasLocationPermission) {
        if (_cachedQibla == null) {
          if (permission == LocationPermission.deniedForever) {
            _setFailure(translation!.locationPermissionPermanentlyDenied);
          } else {
            _setFailure(translation!.locationPermissionDenied);
          }
        }
        return;
      }

      // If there is no app-cached location, try the OS last-known position
      // before asking GPS for a fresh fix. This can work without Internet.
      if (_cachedQibla == null) {
        try {
          final Position? lastKnown = await Geolocator.getLastKnownPosition()
              .timeout(const Duration(seconds: 2), onTimeout: () => null);
          if (lastKnown != null &&
              _isValidCoordinates(
                lastKnown.latitude,
                lastKnown.longitude,
              )) {
            await _saveLocation(
              lastKnown.latitude,
              lastKnown.longitude,
            );
          }
        } catch (e) {
          debugPrint('Could not get last known position: $e');
        }
      }

      // This request has a hard time limit, so loading cannot spin forever.
      try {
        final Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
            timeLimit: Duration(seconds: 8),
          ),
        ).timeout(const Duration(seconds: 9));

        if (_isValidCoordinates(position.latitude, position.longitude)) {
          await _saveLocation(position.latitude, position.longitude);
        }
      } catch (e) {
        // Keep showing the saved location if the fresh fix fails (including
        // when there is no Internet or the GPS signal is weak).
        debugPrint('Current location unavailable; keeping cached location: $e');
      }

      if (!mounted) return;
      if (_cachedQibla == null) {
        _setFailure(
          translation != null
              ? translation!.qiblaNoSavedLocationError
              : 'تعذر تحديد الموقع الحالي ولم يوجد موقع سابق م تحقق من صلاحية الموقع و الانترنت وحاول مجددًا.',
          isGpsIssue: false,
        );
      } else {
        setState(() {
          _isLoading = false;
          _isSupported = true;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Qibla setup error: $e\n$stackTrace');
      if (_cachedQibla != null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isSupported = true;
          });
        }
      } else {
        _setFailure(translation!.compassSetupError);
      }
    }
  }

  bool _isValidCoordinates(double latitude, double longitude) {
    return latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  /// Updates the angle immediately and persists coordinates for offline use.
  /// City lookup is optional: it never prevents the compass from working.
  Future<void> _saveLocation(double latitude, double longitude) async {
    if (!_isValidCoordinates(latitude, longitude)) return;

    final int lookupGeneration = ++_locationLookupGeneration;

    _lastLatitude = latitude;
    _lastLongitude = longitude;
    _cachedQibla = _calculateQiblaBearing(latitude, longitude);
    _isUsingSavedLocation = false;
    _lastLocationName = _coordinatesLocationText;

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isSupported = true;
      });
    }

    try {
      await sharedPref.setDouble(_latitudeKey, latitude);
      await sharedPref.setDouble(_longitudeKey, longitude);
      // Delete the previous city until we successfully resolve the city for
      // these new coordinates, to avoid displaying a stale city name.
      await sharedPref.remove(_locationNameKey);
    } catch (e) {
      debugPrint('Could not persist Qibla location: $e');
    }

    unawaited(
      _resolveCityName(latitude, longitude, lookupGeneration),
    );
  }

  Future<void> _resolveCityName(
    double latitude,
    double longitude,
    int lookupGeneration,
  ) async {
    try {
      final List<Placemark> places = await Geocoding()
          .placemarkFromCoordinates(latitude, longitude)
          .timeout(const Duration(seconds: 4));

      if (places.isEmpty || lookupGeneration != _locationLookupGeneration) {
        return;
      }

      final Placemark place = places.first;
      final String? city = _firstNonEmpty([
        place.locality,
        place.subAdministrativeArea,
        place.subLocality,
        place.administrativeArea,
      ]);
      final String? country = _clean(place.country);
      final String? name;

      if (city != null && country != null && city != country) {
        name = '$city، $country';
      } else {
        name = city ?? country ?? _clean(place.name);
      }

      if (name == null ||
          name.isEmpty ||
          lookupGeneration != _locationLookupGeneration) {
        return;
      }

      if (mounted) {
        setState(() {
          _lastLocationName = name!;
          _isUsingSavedLocation = false;
        });
      }
      await sharedPref.setString(_locationNameKey, name);
    } catch (e) {
      // Reverse geocoding may need a network connection on some phones.
      // The saved coordinates and Qibla direction continue to work regardless.
      debugPrint('Could not resolve city name (non-fatal): $e');
    }
  }

  String? _firstNonEmpty(List<String?> values) {
    for (final String? value in values) {
      final cleaned = _clean(value);
      if (cleaned != null) return cleaned;
    }
    return null;
  }

  String? _clean(String? value) {
    if (value == null) return null;
    final String cleaned = value.trim();
    return cleaned.isEmpty ? null : cleaned;
  }

  void _setFailure(String message, {bool isGpsIssue = false}) {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _isSupported = false;
      _errorMessage = message;
      _isGpsDisabledError = isGpsIssue;
    });
  }

  // Angle calculations do not need Internet or any online API.
  double _degToRad(double degrees) => degrees * pi / 180.0;
  double _radToDeg(double radians) => radians * 180.0 / pi;

  double _calculateQiblaBearing(double latitude, double longitude) {
    final double phi1 = _degToRad(latitude);
    final double phi2 = _degToRad(_kaabaLat);
    final double deltaLambda = _degToRad(_kaabaLon - longitude);
    final double y = sin(deltaLambda) * cos(phi2);
    final double x =
        cos(phi1) * sin(phi2) - sin(phi1) * cos(phi2) * cos(deltaLambda);
    final double theta = atan2(y, x);
    return (_radToDeg(theta) + 360) % 360;
  }

  double _computeRotationRadians(double qiblaBearing, double deviceHeading) {
    final double difference = (qiblaBearing - deviceHeading + 360) % 360;
    return _degToRad(difference);
  }

  Future<void> loadAllTranslations() async {
    try {
      final List<Translation> list =
          await loadTranslation(sharedPref.getString('selectedValue'));
      if (mounted && list.isNotEmpty) {
        setState(() => translation = list.first);
      }
    } catch (e) {
      debugPrint('Could not load translations: $e');
    }
  }

  String get _savedLocationText {
    return translation != null
        ? translation!.qiblaSavedLocation
        : 'آخر موقع محفوظ';
  }

  String get _coordinatesLocationText {
    return translation != null
        ? translation!.qiblaCoordinatesLocation
        : 'موقع محدد بإحداثيات GPS';
  }

  String get _locationCaption {
    return translation != null
        ? translation!.qiblaLocationUsed
        : 'الموقع المستخدم';
  }

  @override
  Widget build(BuildContext context) {
    if (translation == null) {
      if (_isLoading) {
        return const SafeArea(
          child: Center(child: CustomLoadingScreen2()),
        );
      }
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 12),
                Text(
                  _errorMessage.isEmpty
                      ? 'تعذر تحميل إعدادات البوصلة.'
                      : _errorMessage,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _initialize,
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_isLoading) {
      return const SafeArea(
        child: Center(child: CustomLoadingScreen2()),
      );
    }

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              if (!_isSupported) ...[
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
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: scandColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 10,
                  ),
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
                      horizontal: 30,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () async {
                    if (_isGpsDisabledError) {
                      await Geolocator.openLocationSettings();
                    } else {
                      await _checkHardwareAndPermissions();
                    }
                  },
                  child: Text(
                    _isGpsDisabledError
                        ? translation!.openLocationSettings
                        : translation!.retry,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ] else ...[
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
                          color: dilutionScandColor,
                          width: 4,
                        ),
                      ),
                      child: const Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: 15,
                            child: Text(
                              'N',
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 15,
                            child: Text(
                              'E',
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 15,
                            child: Text(
                              'S',
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 15,
                            child: Text(
                              'W',
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    StreamBuilder<CompassEvent>(
                      stream: FlutterCompass.events,
                      builder: (context, snapshot) {
                        final double? heading = snapshot.data?.heading;
                        if (snapshot.hasError ||
                            heading == null ||
                            _cachedQibla == null) {
                          return const Icon(
                            Icons.navigation,
                            size: 150,
                            color: Colors.grey,
                          );
                        }

                        final double rotation = _computeRotationRadians(
                          _cachedQibla!,
                          heading,
                        );
                        return Transform.rotate(
                          angle: rotation,
                          child: Icon(
                            Icons.navigation,
                            size: 160,
                            color: mainColor,
                          ),
                        );
                      },
                    ),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: scandColor,
                        border: Border.all(
                          color: dilutionScandColor,
                          width: 5,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                if (_cachedQibla != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: scandColor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: dilutionScandColor,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        '${translation!.qiblaDirection} ${_cachedQibla!.toStringAsFixed(1)}°',
                        style: const TextStyle(
                          color: whiteColor,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                if (_cachedQibla != null)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 12,
                      left: 20,
                      right: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isUsingSavedLocation
                              ? Icons.history
                              : Icons.location_on_outlined,
                          color: dilutionScandColor,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '$_locationCaption: $_lastLocationName',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: scandColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: _checkHardwareAndPermissions,
                  tooltip: translation!.retry,
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
                  ),
                ),
              ),
              const SizedBox(height: 150),
            ],
          ),
        ),
      ),
    );
  }
}
