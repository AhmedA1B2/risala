import 'package:flutter/material.dart';
import 'tutorial_overlay.dart';

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  final GlobalKey addKey = GlobalKey();
  final GlobalKey deleteKey = GlobalKey();

  // 1. تعريف المتغير هنا ليكون متاحاً في كل الصفحة
  late TutorialOverlay tutorial;

  @override
  void initState() {
    super.initState();

    // 2. تجهيز التعليمات
    tutorial = TutorialOverlay(
      context: context,
      steps: [
        TutorialStep(key: addKey, text: "اضغط للإضافة وسننتقل للخطوة التالية"),
        TutorialStep(key: deleteKey, text: "اضغط للحذف لإنهاء التعليمات"),
      ],
    );

    // تشغيل بعد بناء الواجهة
    WidgetsBinding.instance.addPostFrameCallback((_) => tutorial.start());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              key: addKey,
              onPressed: () {
                // 3. تفعيل الأكواد الخاصة بك أولاً
                print("تمت إضافة العنصر بنجاح!");

                // 4. الانتقال للخطوة التالية في التعليمات يدوياً
                tutorial.next();
              },
              child: const Text("إضافة"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              key: deleteKey,
              onPressed: () {
                // تفعيل كود الحذف
                print("تم حذف العنصر!");

                // إنهاء التعليمات
                tutorial.next();
              },
              child: const Text("حذف"),
            ),
          ],
        ),
      ),
    );
  }
}
