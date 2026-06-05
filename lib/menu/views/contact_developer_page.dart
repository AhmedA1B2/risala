import 'package:flutter/material.dart';
import 'package:risala/main.dart';
import 'package:risala/models/translation.dart';
import 'package:risala/translation/translation.dart';
import 'package:risala/vars/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactDeveloperPage extends StatefulWidget {
  const ContactDeveloperPage({super.key});

  @override
  State<ContactDeveloperPage> createState() => _ContactDeveloperPageState();
}

class _ContactDeveloperPageState extends State<ContactDeveloperPage> {
  Translation? translation;

  Future<void> openTelegram() async {
    final Uri telegram = Uri.parse(
      'https://t.me/risala_support',
    );

    await launchUrl(
      telegram,
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> loadAllTranslations() async {
    final list = await loadTranslation(sharedPref.getString("selectedValue"));
    if (mounted) {
      setState(() => translation = list.first);
    }
  }

  @override
  void initState() {
    loadAllTranslations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = scandColor;
    Color secondaryColor = dilutionamberColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        centerTitle: true,
        title: Text(
          translation != null
              ? translation!.contactDeveloper
              : 'التواصل مع المطور',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: dilutionScandColor)),
              child: Icon(
                Icons.support_agent_rounded,
                size: 60,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 25),
            Text(
              translation != null
                  ? translation!.developerSupportTitle
                  : 'هل واجهت مشكلة أو لديك اقتراح؟',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              translation != null
                  ? translation!.developerSupportDescription
                  : 'يمكنك التواصل مباشرة مع مطور التطبيق للإبلاغ عن الأخطاء أو إرسال الاقتراحات والملاحظات.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 15,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 35),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: dilutionScandColor)),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      translation != null
                          ? translation!.developerSupportHint
                          : 'يرجى وصف المشكلة بالتفصيل وإرفاق صورة للشاشة إن أمكن.',
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton.icon(
                onPressed: openTelegram,
                icon: const Icon(Icons.send_rounded),
                label: Text(
                  translation != null
                      ? translation!.contactViaTelegram
                      : 'التواصل عبر تيليجرام',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
