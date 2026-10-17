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

  // البريد الإلكتروني الخاص بالمطور.
  static const String developerEmail = 'ahmed.ishtiwi.47@gmail.com';

  // اسم مستخدم واتساب دون علامة @.
  // رابط wa.me باسم المستخدم مدعوم من واتساب عند تفعيل ميزة أسماء المستخدمين.
  static const String whatsappUsername = 'support_of_risala';

  Future<void> loadAllTranslations() async {
    try {
      final list = await loadTranslation(
        sharedPref.getString('selectedValue'),
      );

      if (!mounted || list.isEmpty) return;

      setState(() {
        translation = list.first;
      });
    } catch (_) {
      // تستمر الصفحة بالنصوص الاحتياطية إذا تعذّر تحميل ملف الترجمة.
    }
  }

  @override
  void initState() {
    super.initState();
    loadAllTranslations();
  }

  // محاولة فتح تطبيق خارجي أو رابط ويب.
  Future<bool> tryLaunchUri(Uri uri) async {
    try {
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      return false;
    }
  }

  // فتح الرابط وإظهار رسالة مترجمة عند الفشل.
  Future<void> openContactUri(Uri uri) async {
    final opened = await tryLaunchUri(uri);

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            translation?.contactLaunchError ??
                'تعذّر فتح الرابط أو التطبيق. حاول مجددًا.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // فتح صفحة دعم رسالة على تيليجرام.
  Future<void> openTelegram() async {
    await openContactUri(
      Uri.parse('https://t.me/risala_support'),
    );
  }

  // فتح محادثة واتساب باستخدام اسم المستخدم بدل رقم الهاتف.
  Future<void> openWhatsApp() async {
    final username = whatsappUsername.trim().replaceFirst(RegExp(r'^@'), '');

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            translation?.contactWhatsAppUsernameMissing ??
                'اسم مستخدم واتساب غير محدد.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // تنسيق الرابط حسب صيغة واتساب لأسماء المستخدمين: https://wa.me/Username
    final whatsappUri = Uri.https('wa.me', '/$username');
    await openContactUri(whatsappUri);
  }

  // فتح تطبيق البريد مع المستلم وموضوع الرسالة محددين مسبقًا.
  Future<void> openEmail() async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: developerEmail,
      queryParameters: {
        'subject':
            translation?.contactEmailSubject ?? 'تواصل بخصوص تطبيق رسالة',
      },
    );

    await openContactUri(emailUri);
  }

  // زر موحد للمحافظة على تناسق أزرار التواصل.
  Widget contactButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color foregroundColor,
    Color? borderColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 23),
        label: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          side: BorderSide(
            color: borderColor ?? backgroundColor,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: scandColor,
        centerTitle: true,
        title: Text(
          translation?.contactDeveloper ?? 'التواصل مع المطور',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // أيقونة الدعم.
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: scandColor,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: dilutionScandColor),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.support_agent_rounded,
                        size: 66,
                        color: blackColor,
                      ),
                      Hero(
                        tag: 'support_agent_rounded',
                        child: Icon(
                          Icons.support_agent_rounded,
                          size: 60,
                          color: mainColor,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.support_agent_rounded,
                          size: 60,
                          color: Color.fromARGB(26, 0, 0, 0),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // عنوان صفحة التواصل.
                Text(
                  translation?.developerSupportTitle ??
                      'هل واجهت مشكلة أو لديك اقتراح؟',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                // وصف وسائل الدعم.
                Text(
                  translation?.developerSupportDescription ??
                      'يمكنك التواصل مباشرة مع مطور التطبيق للإبلاغ '
                          'عن الأخطاء أو إرسال الاقتراحات والملاحظات.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 30),

                // تنبيه للمستخدم.
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: scandColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: scandColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          translation?.developerSupportHint ??
                              'يرجى وصف المشكلة بالتفصيل وإرفاق '
                                  'صورة للشاشة إن أمكن.',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // زر التواصل عبر واتساب.
                contactButton(
                  label:
                      translation?.contactViaWhatsApp ?? 'التواصل عبر واتساب',
                  icon: Icons.phone,
                  onPressed: openWhatsApp,
                  backgroundColor: scandColor,
                  foregroundColor: Colors.white,
                ),

                const SizedBox(height: 12),

                // زر التواصل عبر البريد الإلكتروني.
                contactButton(
                  label: translation?.contactViaEmail ??
                      'التواصل عبر البريد الإلكتروني',
                  icon: Icons.email_rounded,
                  onPressed: openEmail,
                  backgroundColor: Colors.white,
                  foregroundColor: scandColor,
                  borderColor: scandColor,
                ),

                const SizedBox(height: 12),

                // زر التواصل عبر تيليجرام.
                contactButton(
                  label:
                      translation?.contactViaTelegram ?? 'التواصل عبر تيليجرام',
                  icon: Icons.send_rounded,
                  onPressed: openTelegram,
                  backgroundColor: scandColor,
                  foregroundColor: Colors.white,
                ),

                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
