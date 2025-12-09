import 'package:flutter/material.dart';
import 'package:risala/Notifications/notification_service.dart';
import 'package:risala/my_views/custom_notification/custom/custom_button_icon.dart';
import 'package:risala/my_views/custom_notification/custom/custom_button_text.dart';
import 'package:risala/my_views/custom_notification/custom/custom_text_field.dart';
import 'package:risala/my_views/custom_notification/custom/custom_time_field.dart';
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

  void savedNotification() {
    final selectedTime = timeFieldKey.currentState?.selectedTime;
    if (selectedTime == null) return; // لم يتم اختيار الوقت بعد

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

    if (selectedDays.isEmpty) return; // لم يتم اختيار أي يوم

    NotificationService.instance.scheduledNotification(
      title: controllerOfTitle.text,
      body: controllerOfBody.text,
      hour: selectedTime.hour,
      minute: selectedTime.minute,
      daysOfWeek: selectedDays,
    );

    // مسح الحقول بعد الحفظ (اختياري)
    controllerOfTitle.clear();
    controllerOfBody.clear();
    timeFieldKey.currentState?.controller.clear();
    timeFieldKey.currentState?.selectedTime = null;

    // إعادة تعيين ألوان الأيام
    setState(() {
      colorsOfweek = List.filled(8, whiteColor);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              CustomButtonText(
                color: colorsOfweek[0],
                onPressed: () {
                  setState(() {
                    colorsOfweek[0] =
                        colorsOfweek[0] == whiteColor ? mainColor : whiteColor;
                  });
                },
                text: 'الجمعة',
              ),
              CustomButtonText(
                color: colorsOfweek[1],
                onPressed: () {
                  setState(() {
                    colorsOfweek[1] =
                        colorsOfweek[1] == whiteColor ? mainColor : whiteColor;
                  });
                },
                text: 'السبت',
              ),
              CustomButtonText(
                color: colorsOfweek[2],
                onPressed: () {
                  setState(() {
                    colorsOfweek[2] =
                        colorsOfweek[2] == whiteColor ? mainColor : whiteColor;
                  });
                },
                text: 'الأحد',
              ),
              CustomButtonText(
                color: colorsOfweek[3],
                onPressed: () {
                  setState(() {
                    colorsOfweek[3] =
                        colorsOfweek[3] == whiteColor ? mainColor : whiteColor;
                  });
                },
                text: 'الإثنين',
              ),
              CustomButtonText(
                color: colorsOfweek[4],
                onPressed: () {
                  setState(() {
                    colorsOfweek[4] =
                        colorsOfweek[4] == whiteColor ? mainColor : whiteColor;
                  });
                },
                text: 'الثلاثاء',
              ),
              CustomButtonText(
                color: colorsOfweek[5],
                onPressed: () {
                  setState(() {
                    colorsOfweek[5] =
                        colorsOfweek[5] == whiteColor ? mainColor : whiteColor;
                  });
                },
                text: 'الأربعاء',
              ),
              CustomButtonText(
                color: colorsOfweek[6],
                onPressed: () {
                  setState(() {
                    colorsOfweek[6] =
                        colorsOfweek[6] == whiteColor ? mainColor : whiteColor;
                  });
                },
                text: 'الخميس',
              ),
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
                text: 'الكل',
              ),
            ],
          ),
          const SizedBox(height: 32),
          CustomTimeField(key: timeFieldKey),
          const SizedBox(height: 16),
          CustomTextField(
            hintText: 'اضف عنوانا للاشعار',
            controller: controllerOfTitle,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            hintText: 'اضف نص الاشعار',
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
}
