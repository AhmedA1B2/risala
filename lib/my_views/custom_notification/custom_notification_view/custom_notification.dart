import 'package:flutter/material.dart';
import 'package:risala/Notifications/notification_service.dart';
import 'package:risala/Notifications/saved_notification.dart';
import 'package:risala/my_views/custom_notification/custom/custom_button_icon.dart';
import 'package:risala/my_views/custom_notification/custom_notification_view/add_custom_notification.dart';
import 'package:risala/vars/colors.dart';

class CustomNotification extends StatefulWidget {
  const CustomNotification({super.key});

  @override
  State<CustomNotification> createState() => _CustomNotificationState();
}

class _CustomNotificationState extends State<CustomNotification> {
  List<SavedNotification> savedList = [];
  bool isLoading = true;
  bool showAddNotificationView = false;
  bool showDetails = false;
//
  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  void loadNotifications() async {
    savedList = await NotificationService.instance.getSavedNotifications();
    setState(() {
      isLoading = false;
    });
  }

//
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        showAddNotificationView == true
            ? const AddCustomNotification()
            : Stack(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 40),
                      itemCount: savedList.length,
                      itemBuilder: (context, index) {
                        final item = savedList[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              CustomButtonIcon(
                                iconData: Icons.delete_forever,
                                iconColor: Colors.red,
                                onPressed: () async {
                                  await NotificationService.instance
                                      .cancelNotifications(item.id);
                                  savedList.removeAt(index);
                                  setState(() {});
                                },
                              ),
                              Card(
                                color: whiteColor,
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.65,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  item.show ??= false;
                                                  item.show = !item.show!;
                                                });
                                              },
                                              icon: const Icon(
                                                  Icons.arrow_drop_down),
                                            ),
                                            Text(
                                              item.title,
                                              style:
                                                  const TextStyle(fontSize: 22),
                                            ),
                                          ],
                                        ),
                                        AnimatedSize(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                          alignment: Alignment.topCenter,
                                          child: (item.show ?? false)
                                              ? Wrap(
                                                  children: [
                                                    Text(item.body),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                        "الوقت: ${item.hour}:${item.minute}"),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                        "الأيام: ${item.days.join(", ")}"),
                                                  ],
                                                )
                                              : const SizedBox.shrink(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  CustomButtonIcon(
                    iconData: Icons.delete_sweep_sharp,
                    iconColor: Colors.red,
                    onPressed: () async {
                      await NotificationService.instance
                          .cancelAllNotifications();
                      setState(() {});
                    },
                  ),
                ],
              ),
        Positioned(
          bottom: showAddNotificationView == true
              ? MediaQuery.of(context).size.height * 0.12
              : MediaQuery.of(context).size.height * 0.05,
          right: showAddNotificationView == true ? null : 50,
          left: showAddNotificationView == true ? 50 : null,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: scandColor,
              border: Border.all(color: dilutionScandColor, width: 2),
              shape: BoxShape.circle,
            ),
            child: showAddNotificationView == true
                ? TextButton(
                    onPressed: () {
                      setState(() {
                        showAddNotificationView = false;
                      });
                    },
                    child: const Icon(
                      Icons.cancel,
                      size: 36,
                      color: whiteColor,
                    ))
                : TextButton(
                    onPressed: () {
                      setState(() {
                        showAddNotificationView = true;
                      });
                    },
                    child: const Icon(
                      Icons.add_alert,
                      size: 36,
                      color: whiteColor,
                    )),
          ),
        )
      ],
    );
  }
}
