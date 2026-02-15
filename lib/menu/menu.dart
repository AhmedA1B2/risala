import 'package:flutter/material.dart';
import 'package:risala/custom/custom_menu_itme/custom_menu_itme1.dart';
import 'package:risala/main.dart';
import 'package:risala/menu/views/theme_view.dart';
import 'package:risala/models/translation.dart';
import 'package:risala/translation/translation.dart';
import 'package:risala/menu/views/language_text_settings_view.dart';

class Menu extends StatefulWidget {
  const Menu({
    super.key,
    required this.explanatoryTextForTitle,
    required this.saveText,
    required this.explanatoryTextForAya,
  });

  final String explanatoryTextForTitle;
  final String explanatoryTextForAya;
  final String saveText;

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  late String selectedValue = sharedPref.getString("selectedValue") ?? "ar";

  late Future<List<Translation>> _translationsFuture;

  @override
  void initState() {
    super.initState();
    _translationsFuture = loadTranslation(selectedValue);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Translation>>(
      future: _translationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('خطأ: ${snapshot.error}');
        } else {
          final translations = snapshot.data!;
          final trans = translations.first;

          return ListView(
            padding: const EdgeInsets.all(8),
            children: [
              CustomMenuItme(
                textItme: trans.languageAndText,
                iconItme: Icons.language,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LanguageTextSettingsView(),
                    ),
                  );
                },
              ),
              CustomMenuItme(
                textItme: trans.support,
                iconItme: Icons.support_agent,
                onPressed: () {},
              ),
              CustomMenuItme(
                textItme: trans.theme,
                iconItme: Icons.color_lens,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ThemeView()),
                  );
                },
              ),
            ],
          );
        }
      },
    );
  }
}
