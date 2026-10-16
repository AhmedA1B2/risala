import 'package:flutter/material.dart';
import 'package:risala/custom/custom_dialogue/custom_dialogue_2.dart';
import 'package:risala/main.dart';
import 'package:risala/models/translation.dart';
import 'package:risala/my_views/hadith/custom/custom_chapter_list.dart';
import 'package:risala/translation/translation.dart';

class HadithView extends StatefulWidget {
  const HadithView({super.key});

  @override
  State<HadithView> createState() => _HadithViewState();
}

class _HadithViewState extends State<HadithView> {
  Translation? translation;

  late String savedLanguage;
  late String oldSavedLanguage;
  late bool chooseTheLang;

  @override
  void initState() {
    super.initState();

    savedLanguage = sharedPref.getString('bukhariChapterLanguage') ?? 'none';

    oldSavedLanguage = sharedPref.getString('selectedValue') ?? 'none';

    chooseTheLang = savedLanguage == 'ar' ||
        savedLanguage == 'en' ||
        oldSavedLanguage == 'ar' ||
        oldSavedLanguage == 'en';

    loadAllTranslations();
  }

  Future<void> loadAllTranslations() async {
    final selectedValue = sharedPref.getString('selectedValue');

    if (selectedValue == null) return;

    try {
      final list = await loadTranslation(selectedValue);

      if (!mounted || list.isEmpty) return;

      setState(() {
        translation = list.first;
      });
    } catch (e) {
      debugPrint('Error loading translations: $e');
    }
  }

  Future<void> selectLanguage(String language) async {
    // حفظ اللغة المختارة أولاً.
    await sharedPref.setString(
      'bukhariChapterLanguage',
      language,
    );

    if (!mounted) return;

    // تحديث الواجهة فور اختيار اللغة.
    setState(() {
      savedLanguage = language;
      chooseTheLang = true;
    });
  }

  void contactDeveloper() {
    // أضف هنا إجراء فتح صفحة التواصل أو رابط الدعم.
  }

  @override
  Widget build(BuildContext context) {
    final message = translation?.hadithLangMessage ??
        'نعتذر منك، ولكن لغتك غير مدعومة حاليًا. '
            'يتوفر كتاب صحيح البخاري حاليًا باللغتين العربية والإنجليزية فقط. '
            'إذا كان بإمكانك المساعدة في توفير الكتاب بلغتك، '
            'أو تعرف شخصًا يمكنه ذلك، فيُرجى التواصل معنا.';

    return SafeArea(
      child: Stack(
        children: [
          // مفتاح مختلف لكل لغة لإعادة إنشاء القائمة عند التغيير.
          CustomChapterList(
            key: ValueKey(savedLanguage),
          ),

          if (!chooseTheLang)
            Positioned.fill(
              child: CustomDialogue2(
                text: message,
                choose1: 'العربية',
                onPressedchoose1: () => selectLanguage('ar'),
                choose2: 'English',
                onPressedchoose2: () => selectLanguage('en'),
                choose3: translation?.contactDeveloper ?? 'التواصل مع المطور',
                onPressedchoose3: contactDeveloper,
              ),
            ),
        ],
      ),
    );
  }
}
