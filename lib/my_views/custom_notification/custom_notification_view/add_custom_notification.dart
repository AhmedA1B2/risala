import 'package:flutter/material.dart';
import 'package:risala/Notifications/notification_service.dart';
import 'package:risala/main.dart';
import 'package:risala/main_view/main_view.dart';
import 'package:risala/models/translation.dart';
import 'package:risala/my_views/custom_notification/custom/custom_button_icon.dart';
import 'package:risala/my_views/custom_notification/custom/custom_button_text.dart';
import 'package:risala/my_views/custom_notification/custom/custom_text_field.dart';
import 'package:risala/my_views/custom_notification/custom/custom_time_field.dart';
import 'package:risala/translation/translation.dart';
import 'package:risala/vars/colors.dart';

class AddCustomNotification extends StatefulWidget {
  const AddCustomNotification({super.key});

  @override
  State<AddCustomNotification> createState() => _AddCustomNotificationState();
}

class _AddCustomNotificationState extends State<AddCustomNotification> {
  TextEditingController controllerOfTitle = TextEditingController();
  TextEditingController controllerOfBody = TextEditingController();

  List<Color> colorsOfweek = List.filled(8, whiteColor);
  final GlobalKey<CustomTimeFieldState> timeFieldKey =
      GlobalKey<CustomTimeFieldState>();

  Translation? translation;

  @override
  void initState() {
    super.initState();
    loadAllTranslations();
  }

  Future<void> loadAllTranslations() async {
    final list = await loadTranslation(sharedPref.getString("selectedValue"));
    if (list.isNotEmpty) {
      setState(() {
        translation = list.first;
      });
    }
  }

  void savedNotification() {
    final selectedTime = timeFieldKey.currentState?.selectedTime;
    if (selectedTime == null) return;

    List<int> selectedDays = [];
    List<int> dayNumbers = [5, 6, 7, 1, 2, 3, 4]; // ترتيب الأيام حسب الأزرار
    for (int i = 0; i < 7; i++) {
      if (colorsOfweek[i] == mainColor) {
        selectedDays.add(dayNumbers[i]);
      }
    }
    if (colorsOfweek[7] == mainColor) {
      selectedDays = [1, 2, 3, 4, 5, 6, 7];
    }

    if (selectedDays.isEmpty) return;

    NotificationService.instance.scheduledNotification(
      title: controllerOfTitle.text,
      body: controllerOfBody.text,
      hour: selectedTime.hour,
      minute: selectedTime.minute,
      daysOfWeek: selectedDays,
    );

    controllerOfTitle.clear();
    controllerOfBody.clear();
    timeFieldKey.currentState?.controller.clear();
    timeFieldKey.currentState?.selectedTime = null;

    setState(() {
      colorsOfweek = List.filled(8, whiteColor);
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // حل مشكلة الـ Null: إذا كانت البيانات لم تُحمل بعد، نعرض مؤشر تحميل
    if (translation == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildDayButton(
                  0,
                  translation!.friday.isNotEmpty
                      ? translation!.friday
                      : 'الجمعة'),
              _buildDayButton(
                  1,
                  translation!.saturday.isNotEmpty
                      ? translation!.saturday
                      : 'السبت'),
              _buildDayButton(
                  2,
                  translation!.sunday.isNotEmpty
                      ? translation!.sunday
                      : 'الأحد'),
              _buildDayButton(
                  3,
                  translation!.monday.isNotEmpty
                      ? translation!.monday
                      : 'الإثنين'),
              _buildDayButton(
                  4,
                  translation!.tuesday.isNotEmpty
                      ? translation!.tuesday
                      : 'الثلاثاء'),
              _buildDayButton(
                  5,
                  translation!.wednesday.isNotEmpty
                      ? translation!.wednesday
                      : 'الأربعاء'),
              _buildDayButton(
                  6,
                  translation!.thursday.isNotEmpty
                      ? translation!.thursday
                      : 'الخميس'),

              // زر "الكل" له منطق خاص لتغيير حالة جميع الأيام
              CustomButtonText(
                color: colorsOfweek[7],
                onPressed: () {
                  setState(() {
                    colorsOfweek[7] =
                        colorsOfweek[7] == whiteColor ? mainColor : whiteColor;
                    for (int i = 0; i < 7; i++) {
                      colorsOfweek[i] = colorsOfweek[7];
                    }
                  });
                },
                text: translation!.all.isNotEmpty ? translation!.all : 'الكل',
              ),
            ],
          ),
          const SizedBox(height: 32),
          CustomTimeField(
            key: timeFieldKey,
            hintText: translation!.chooseTime.isNotEmpty
                ? translation!.chooseTime
                : "اختر الوقت",
          ),
          const SizedBox(height: 16),
          CustomTextField(
            hintText: translation!.addNotificationTitle.isNotEmpty
                ? translation!.addNotificationTitle
                : 'اضف عنوانا للاشعار',
            controller: controllerOfTitle,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            hintText: translation!.addNotificationBody.isNotEmpty
                ? translation!.addNotificationBody
                : 'اضف نص الاشعار',
            controller: controllerOfBody,
          ),
          const SizedBox(height: 16),
          CustomButtonIcon(
            iconColor: scandColor,
            iconData: Icons.add_alert_outlined,
            size: 32,
            onPressed: savedNotification,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // دالة مساعدة لتقليل تكرار الكود في أزرار الأيام
  Widget _buildDayButton(int index, String label) {
    return CustomButtonText(
      color: colorsOfweek[index],
      onPressed: () {
        setState(() {
          colorsOfweek[index] =
              colorsOfweek[index] == whiteColor ? mainColor : whiteColor;
        });
      },
      text: label,
    );
  }
}
