import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:risala/main.dart';
import 'package:risala/models/translation.dart';
import 'package:risala/my_views/sabhuh/custom/custom_sabhuh_item.dart';
import 'package:risala/my_views/sabhuh/custom/sabhuh_circle_column.dart';
import 'package:risala/my_views/sabhuh/service/click_sound_service.dart';
import 'package:risala/translation/translation.dart';
import 'package:risala/vars/colors.dart';

class SabhuhView extends StatefulWidget {
  const SabhuhView({super.key});

  @override
  State<SabhuhView> createState() => _SabhuhViewState();
}

class _SabhuhViewState extends State<SabhuhView> {
  int counter = sharedPref.getInt('sabhuhConter') ?? 0;
  bool isTap = false;
  bool showAdhkarView = false;
  bool isLoadingAdhkar = false;

  String? adhkarError;
  List<Map<String, dynamic>> adhkarList = [];
  Map<String, dynamic>? selectedDhikr;
  Translation? translation;

  // Used to ignore old results when the user changes category quickly.
  int _adhkarLoadRequest = 0;
  int _categorySelectionRequest = 0;

  int inOutColor = -1;

  final List<Color> inColor = List<Color>.filled(5, dilutionScandColor);
  final List<Color> outColor = List<Color>.filled(5, dilutionScandColor);

  String get _selectedLanguage => sharedPref.getString('selectedValue') ?? 'ar';

  @override
  void initState() {
    super.initState();
    _syncIndicatorColorsWithCounter();
    loadAdhkar();
    loadAllTranslations();
  }

  Future<void> loadAdhkar({String? category}) async {
    final int requestId = ++_adhkarLoadRequest;
    final String categoryToLoad =
        category ?? sharedPref.getString('myDhkar') ?? 'tsbyh';

    if (mounted) {
      setState(() {
        isLoadingAdhkar = true;
        adhkarError = null;
        selectedDhikr = null;
      });
    }

    try {
      final String response = await rootBundle.loadString(
        'assets/json/adhkar/$categoryToLoad.json',
      );
      final dynamic decoded = jsonDecode(response);

      if (decoded is! List) {
        throw const FormatException('Adhkar JSON must contain a list.');
      }

      final List<Map<String, dynamic>> data = [];
      for (final dynamic item in decoded) {
        if (item is! Map) {
          throw const FormatException('An adhkar item is not a JSON object.');
        }
        data.add(Map<String, dynamic>.from(item));
      }

      final String? savedDhikr = sharedPref.getString('selectedDhikrText');
      Map<String, dynamic>? nextSelectedDhikr;

      if (savedDhikr != null && savedDhikr.isNotEmpty) {
        for (final item in data) {
          if (item['arabic'] == savedDhikr) {
            nextSelectedDhikr = item;
            break;
          }
        }
      }

      nextSelectedDhikr ??= data.isNotEmpty ? data.first : null;

      if (!mounted || requestId != _adhkarLoadRequest) return;

      setState(() {
        adhkarList = data;
        selectedDhikr = nextSelectedDhikr;
        isLoadingAdhkar = false;
        adhkarError = null;
      });
    } catch (error, stackTrace) {
      debugPrint('Failed to load adhkar ($categoryToLoad): $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted || requestId != _adhkarLoadRequest) return;

      setState(() {
        adhkarList = [];
        selectedDhikr = null;
        isLoadingAdhkar = false;
        adhkarError = 'تعذر تحميل الأذكار. حاول مرة أخرى.';
      });
    }
  }

  Future<void> loadAllTranslations() async {
    try {
      final list = await loadTranslation(_selectedLanguage);

      if (!mounted || list.isEmpty) return;

      setState(() {
        translation = list.first;
      });
    } catch (error, stackTrace) {
      debugPrint('Failed to load Sabhuh translations: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  String _getMapText(
    Map<String, dynamic> item,
    String field, {
    required String fallbackField,
  }) {
    final dynamic value = item[field];
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }

    final dynamic fallback = item[fallbackField];
    return fallback is String ? fallback : '';
  }

  String _dhikrTitle(Map<String, dynamic> dhikr) {
    final String field =
        _selectedLanguage == 'ar' ? 'arabic' : _selectedLanguage;

    return _getMapText(dhikr, field, fallbackField: 'arabic');
  }

  String _dhikrExplanation(Map<String, dynamic> dhikr) {
    final String field = _selectedLanguage == 'ar'
        ? 'explanationar'
        : 'explanation$_selectedLanguage';

    return _getMapText(dhikr, field, fallbackField: 'explanationar');
  }

  String _textOrFallback(String? value, String fallback) {
    if (value == null || value.trim().isEmpty) return fallback;
    return value;
  }

  void _resetIndicatorColors() {
    inOutColor = -1;
    for (int i = 0; i < inColor.length; i++) {
      inColor[i] = dilutionScandColor;
      outColor[i] = dilutionScandColor;
    }
  }

  // Restore the five indicators to the same state they would have after the
  // saved number of taps, rather than showing all indicators as inactive.
  void _syncIndicatorColorsWithCounter() {
    _resetIndicatorColors();
    if (counter <= 0) return;

    inOutColor = (counter - 1) % inColor.length;

    for (int i = 0; i < inColor.length; i++) {
      final int firstVisit = i + 1;
      if (counter < firstVisit) continue;

      final int visitCount = 1 + ((counter - firstVisit) ~/ inColor.length);
      if (visitCount.isOdd) {
        inColor[i] = scandColor;
      }
    }
  }

  void _resetCounter() {
    setState(() {
      counter = 0;
      _resetIndicatorColors();
    });

    sharedPref.setInt('sabhuhConter', 0);
  }

  void _incrementCounter() {
    setState(() {
      counter++;

      inOutColor = (inOutColor + 1) % inColor.length;
      inColor[inOutColor] =
          inColor[inOutColor] == scandColor ? dilutionScandColor : scandColor;
    });

    sharedPref.setInt('sabhuhConter', counter);
    ClickSoundService().play();
  }

  Future<void> _openCategory(String category) async {
    final int selectionRequest = ++_categorySelectionRequest;

    // Invalidate a previous category load immediately.
    _adhkarLoadRequest++;

    setState(() {
      isTap = true;
      isLoadingAdhkar = true;
      adhkarError = null;
      selectedDhikr = null;
    });

    await sharedPref.setString('myDhkar', category);
    if (!mounted || selectionRequest != _categorySelectionRequest) return;

    await loadAdhkar(category: category);
  }

  Future<void> _selectDhikr(Map<String, dynamic> dhikr) async {
    final dynamic arabicValue = dhikr['arabic'];
    final String arabicText = arabicValue is String ? arabicValue : '';

    setState(() {
      selectedDhikr = dhikr;
      showAdhkarView = false;
      isTap = false;
      counter = 0;
      _resetIndicatorColors();
    });

    // Save both values so the selected dhikr and reset counter survive restart.
    await sharedPref.setString('selectedDhikrText', arabicText);
    await sharedPref.setInt('sabhuhConter', 0);
  }

  Widget _buildCategoryItem({
    required String? text,
    required String fallback,
    required String category,
  }) {
    return CustomSabhuhItem(
      text: _textOrFallback(text, fallback),
      onTap: () => _openCategory(category),
    );
  }

  Widget _buildAdhkarContent() {
    if (isLoadingAdhkar) {
      return Center(
        child: CircularProgressIndicator(color: scandColor),
      );
    }

    if (adhkarError != null && isTap) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                adhkarError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: blackColor, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => loadAdhkar(),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    if (isTap) {
      if (adhkarList.isEmpty) {
        return const Center(
          child: Text(
            'لا توجد أذكار في هذا القسم.',
            style: TextStyle(color: blackColor, fontSize: 16),
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        itemCount: adhkarList.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final dhikr = adhkarList[index];

          return ListTile(
            title: Text(
              _dhikrTitle(dhikr),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                color: blackColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => _selectDhikr(dhikr),
          );
        },
      );
    }

    return GridView.count(
      padding: const EdgeInsets.all(8),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      children: [
        _buildCategoryItem(
          text: translation?.morning,
          fallback: 'الصباح',
          category: 'sbah',
        ),
        _buildCategoryItem(
          text: translation?.evening,
          fallback: 'المساء',
          category: 'msaa',
        ),
        _buildCategoryItem(
          text: translation?.prayerTime,
          fallback: 'الصلاة',
          category: 'slah',
        ),
        _buildCategoryItem(
          text: translation?.sleep,
          fallback: 'النوم',
          category: 'noom',
        ),
        _buildCategoryItem(
          text: translation?.tasbihAndDhikr,
          fallback: 'تسبيح وذكر',
          category: 'tsbyh',
        ),
        _buildCategoryItem(
          text: translation?.wakingUp,
          fallback: 'الاستيقاظ',
          category: 'estyqad',
        ),
        _buildCategoryItem(
          text: translation?.adhan,
          fallback: 'الأذان',
          category: 'adan',
        ),
        _buildCategoryItem(
          text: translation?.mosque,
          fallback: 'المسجد',
          category: 'msjed',
        ),
        _buildCategoryItem(
          text: translation?.ablution,
          fallback: 'الوضوء',
          category: 'wdoa',
        ),
        _buildCategoryItem(
          text: translation?.homePlace,
          fallback: 'المنزل',
          category: 'mnzl',
        ),
        _buildCategoryItem(
          text: translation?.restroom,
          fallback: 'الخلاء',
          category: 'khla',
        ),
        _buildCategoryItem(
          text: translation?.food,
          fallback: 'الطعام',
          category: 'taam',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String adhkarTitle = _textOrFallback(
      translation?.adhkar,
      'الأذكار',
    );

    return SafeArea(
      child: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Main counter card.
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50),
                    child: Container(
                      decoration: BoxDecoration(
                        color: scandColor,
                        border: Border.all(
                          color: dilutionScandColor,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 24,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$counter',
                            style: const TextStyle(
                              color: whiteColor,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 20),
                          IconButton(
                            onPressed: _resetCounter,
                            icon: const Icon(
                              Icons.restart_alt_rounded,
                              size: 48,
                              color: whiteColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Selected dhikr card.
                  if (selectedDhikr != null)
                    Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 35,
                      ),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: mainColor,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: scandColor, width: 3),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            _dhikrTitle(selectedDhikr!),
                            style: TextStyle(
                              color: scandColor,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _dhikrExplanation(selectedDhikr!),
                            style: TextStyle(
                              color: dilutionScandColor,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 160),
                ],
              ),
            ),
          ),

          // Counter increment button.
          Positioned(
            left: 0,
            right: 0,
            bottom: 80,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  decoration: BoxDecoration(
                    color: scandColor,
                    border: Border.all(
                      color: dilutionScandColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 8,
                        color: Colors.black38,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _incrementCounter,
                    icon: const Icon(
                      Icons.add,
                      size: 56,
                      color: whiteColor,
                    ),
                  ),
                ),
              ),
            ),
          ),

          SabhuhCircleColumn(
            inColor: inColor,
            outColor: outColor,
          ),

          // Adhkar dialog backdrop and content.
          if (showAdhkarView) ...[
            const Positioned.fill(
              child: ModalBarrier(
                color: Colors.black54,
                dismissible: false,
              ),
            ),
            Positioned.fill(
              child: Center(
                child: FractionallySizedBox(
                  widthFactor: 0.9,
                  heightFactor: 0.9,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: whiteColor,
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                adhkarTitle,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: blackColor,
                                ),
                              ),
                            ),
                            const Divider(height: 1),
                            Expanded(child: _buildAdhkarContent()),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],

          // Adhkar open/close button. It remains above the dialog barrier.
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            top: showAdhkarView ? 10 : 40,
            right: showAdhkarView ? 25 : 16,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isTap = false;
                  showAdhkarView = !showAdhkarView;
                });
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: dilutionScandColor,
                      width: 2,
                    ),
                    color: scandColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    showAdhkarView ? '×' : adhkarTitle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: whiteColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
