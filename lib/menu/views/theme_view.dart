import 'package:flutter/material.dart';
import 'package:risala/custom/custom_bg/custom_bg_of_home.dart';
import 'package:risala/custom/custom_bg/custom_minecraft_night_bg.dart';
import 'package:risala/custom/custom_bg/custom_night_sky_bg.dart';
import 'package:risala/custom/custom_bg/custom_ocean_rain_bg.dart';
import 'package:risala/main.dart';
import 'package:risala/main_view/main_view.dart';
import 'package:risala/menu/custom/bottom_bar_animation_for_theme.dart';
import 'package:risala/menu/custom/choose_icon.dart';
import 'package:risala/menu/custom/custom_circle.dart';
import 'package:risala/menu/custom/custom_item/custom_text_bar_for_theme.dart';
import 'package:risala/menu/custom/custom_item/custom_text_bar_for_theme2.dart';
import 'package:risala/menu/custom/custom_item/custom_text_bar_for_theme3.dart';
import 'package:risala/models/translation.dart';
import 'package:risala/translation/translation.dart';
import 'package:risala/vars/colors.dart';

class ThemeView extends StatefulWidget {
  const ThemeView({super.key});

  @override
  State<ThemeView> createState() => _ThemeViewState();
}

class _ThemeViewState extends State<ThemeView> {
  late int selectedThemeIndex;
  late int sizeOfTextBar;
  late bool isGlassEffect;

  bool _isSaving = false;
  Translation? translation;

  @override
  void initState() {
    super.initState();

    // Validate saved values so an invalid preference cannot select an
    // unintended background or leave the preview without a text-bar layout.
    final savedThemeIndex = sharedPref.getInt('myTheme') ?? 0;
    selectedThemeIndex =
        savedThemeIndex >= 0 && savedThemeIndex <= 3 ? savedThemeIndex : 0;

    final savedTextBarSize = sharedPref.getInt('sizeOfTextBar') ?? 1;
    sizeOfTextBar =
        savedTextBarSize == 1 || savedTextBarSize == 2 || savedTextBarSize == 3
            ? savedTextBarSize
            : 1;

    isGlassEffect = sharedPref.getBool('checkboxValue') ?? false;
    themeIndex = selectedThemeIndex;
    loadAllTranslations();
  }

  Future<void> loadAllTranslations() async {
    try {
      final list = await loadTranslation(sharedPref.getString('selectedValue'));

      if (!mounted || list.isEmpty) return;

      setState(() {
        translation = list.first;
      });
    } catch (error, stackTrace) {
      debugPrint('ThemeView: failed to load translations: $error');
      debugPrintStack(stackTrace: stackTrace);
      // The Arabic fallback labels remain available if translations fail.
    }
  }

  String _label(String? value, String fallback) {
    return value == null || value.isEmpty ? fallback : value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          _label(translation?.appearance, 'المظهر'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Only the background is switched. Keeping the scroll view outside
            // AnimatedSwitcher preserves its state and scroll position.
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      // Pause outgoing background animations during the short
                      // transition, avoiding two animated scenes running at
                      // full speed at the same time.
                      for (final previousChild in previousChildren)
                        TickerMode(
                          enabled: false,
                          child: previousChild,
                        ),
                      if (currentChild != null) currentChild,
                    ],
                  );
                },
                child: _buildBackgroundLayer(selectedThemeIndex),
              ),
            ),

            // This widget remains in the same Stack position when themes
            // change, so the user's current scroll position is retained.
            _buildPageContent(scandColor, mainColor),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundLayer(int index) {
    final emptyChild = const SizedBox.expand();

    late final Widget background;
    switch (index) {
      case 0:
        background = CustomBg(
          topBorderRadius: 0,
          topMargin: 0,
          child: emptyChild,
        );
        break;
      case 1:
        background = CustomNightSkyBg(child: emptyChild);
        break;
      case 2:
        background = CustomMinecraftNightBg(child: emptyChild);
        break;
      case 3:
      default:
        background = CustomOceanRainBg(child: emptyChild);
        break;
    }

    // KeyedSubtree gives AnimatedSwitcher a distinct identity without
    // requiring changes to the constructors of the custom background widgets.
    return KeyedSubtree(
      key: ValueKey<int>(index),
      child: background,
    );
  }

  Widget _buildPageContent(Color currentScandColor, Color currentMainColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Hero(
                tag: 'color_lens',
                child: Icon(Icons.color_lens),
              ),
              Text(
                _label(translation?.changeAppearance, 'تغيير المظهر'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: selectedThemeIndex == 0 ? blackColor : whiteColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ChooseIcon(
                color:
                    sizeOfTextBar == 2 ? currentScandColor : currentMainColor,
                icon: Icons.grid_view_rounded,
                onTap: () => _setTextBarSize(2),
              ),
              ChooseIcon(
                color:
                    sizeOfTextBar == 1 ? currentScandColor : currentMainColor,
                icon: Icons.rectangle,
                onTap: () => _setTextBarSize(1),
              ),
              ChooseIcon(
                color:
                    sizeOfTextBar == 3 ? currentScandColor : currentMainColor,
                icon: Icons.grid_on,
                onTap: () => _setTextBarSize(3),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Text(
            _label(translation?.previewAppearance, 'معاينة المظهر'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: selectedThemeIndex == 0 ? blackColor : whiteColor,
            ),
          ),
          const SizedBox(height: 15),
          if (sizeOfTextBar == 1)
            CustomTextBarForTheme(
              sizeOfFont: sizeOfTextBar,
              main: currentMainColor,
              surah: 'سورة',
              aya: 'آية',
              where: 'مكان',
              number: '1',
            ),
          if (sizeOfTextBar == 2)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CustomTextBarForTheme2(
                  sizeOfFont: sizeOfTextBar,
                  main: currentMainColor,
                  surah: 'سورة',
                  aya: 'آية',
                  where: 'مكان',
                  number: '1',
                ),
                CustomTextBarForTheme2(
                  sizeOfFont: sizeOfTextBar,
                  main: currentMainColor,
                  surah: 'سورة',
                  aya: 'آية',
                  where: 'مكان',
                  number: '1',
                ),
              ],
            ),
          if (sizeOfTextBar == 3)
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              children: [
                for (int i = 0; i < 3; i++)
                  CustomTextBarForTheme3(
                    sizeOfFont: sizeOfTextBar,
                    main: currentMainColor,
                    surah: 'سورة',
                    aya: 'آية',
                    where: 'مكان',
                    number: '1',
                  ),
              ],
            ),
          const SizedBox(height: 15),

          // Glass-effect preview.
          Card(
            color: whiteColor,
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    _label(translation?.glassEffect, 'تأثير الزجاج'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: blackColor,
                    ),
                  ),
                  Checkbox(
                    checkColor: currentMainColor,
                    activeColor: currentScandColor,
                    value: isGlassEffect,
                    onChanged: (value) {
                      setState(() {
                        isGlassEffect = value ?? false;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Bottom navigation preview.
          BottomBarAnimationForTheme(
            theme: isGlassEffect,
            icons: const [
              Icons.import_contacts_rounded,
              Icons.thunderstorm_rounded,
              Icons.gpp_good,
            ],
            onIconTap: (index) {},
            scand: currentScandColor,
            main: currentMainColor,
          ),
          const SizedBox(height: 30),
          Text(
            _label(translation?.chooseColor, 'اختر اللون'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: selectedThemeIndex == 0 ? blackColor : whiteColor,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSelectableCircle(0),
              _buildSelectableCircle(1),
              _buildSelectableCircle(2),
              _buildSelectableCircle(3),
            ],
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: currentScandColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
              ),
              onPressed: _isSaving ? null : _saveChanges,
              child: _isSaving
                  ? const SizedBox(
                      width: 23,
                      height: 23,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _label(translation?.save, 'تطبيق الثيم'),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _setTextBarSize(int size) {
    if (sizeOfTextBar == size) return;
    setState(() {
      sizeOfTextBar = size;
    });
  }

  Color _circleOuterColor(int index) {
    switch (index) {
      case 1:
        return const Color(0xFFffecb3); // Night sky.
      case 2:
        return const Color(0xFFFBFFC4); // Minecraft night.
      case 3:
        return const Color(0xFFFBFFC4); // Ocean rain.
      case 0:
      default:
        return const Color(0xFFFFFCBA);
    }
  }

  Color _circleInnerColor(int index) {
    switch (index) {
      case 1:
        return const Color(0xFF020611);
      case 2:
        return const Color(0xFF044019);
      case 3:
        return const Color(0xFF051942);
      case 0:
      default:
        return const Color(0xFF463700);
    }
  }

  Widget _buildSelectableCircle(int index) {
    final isSelected = selectedThemeIndex == index;

    return Container(
      decoration: isSelected
          ? BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: blackColor,
                width: 3,
              ),
            )
          : null,
      child: CustomCircle(
        onTap: () {
          if (selectedThemeIndex == index) return;

          setState(() {
            selectedThemeIndex = index;

            // تحديث الثيم العام فورًا.
            themeIndex = index;
          });
        },
        outColor: _circleOuterColor(index),
        inColor: _circleInnerColor(index),
        borderColor: blackColor,
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Save each value before rebuilding MainView, so it always reads the
      // complete and consistent set of preferences.
      final themeSaved = await sharedPref.setInt('myTheme', selectedThemeIndex);
      final glassSaved =
          await sharedPref.setBool('checkboxValue', isGlassEffect);
      final textBarSaved =
          await sharedPref.setInt('sizeOfTextBar', sizeOfTextBar);
      themeIndex = selectedThemeIndex;
      if (!themeSaved || !glassSaved || !textBarSaved) {
        throw StateError('One or more appearance preferences were not saved.');
      }

      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: scandColor,
            content: Text(
              _label(translation?.saved, 'تم حفظ وتطبيق التغييرات بنجاح'),
            ),
            duration: const Duration(seconds: 1),
          ),
        );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => const MainView(),
        ),
        (route) => false,
      );
    } catch (error, stackTrace) {
      debugPrint('ThemeView: failed to save appearance: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('تعذر حفظ التغييرات. يرجى المحاولة مرة أخرى.'),
            duration: Duration(seconds: 2),
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
