import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:risala/Notifications/notification_service.dart';
import 'package:risala/vars/colors.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

final player = AudioPlayer();

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(color: scandColor),
            child: TextButton(
                onPressed: () async {
                  await NotificationService.instance.showAdhanNotification(
                      id: 100, title: "Title", body: "Body");
                  player.stop();
                },
                child: Text(
                  "Test--1",
                  style: TextStyle(color: mainColor),
                )),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(color: mainColor),
            child: TextButton(
                onPressed: () async {
                  await player.setAudioSource(
                    AudioSource.asset(
                      'assets/audio/adhan/Nasser_al_Qatami_Adhan.mp3',
                      tag: MediaItem(
                        id: 'adhan_nasser', // معرف فريد
                        album: "أذان",
                        title: "الأذان",
                        artist: "ناصر القطامي",
                        artUri: Uri.parse(
                            'https://example.com/adhan_icon.png'), // أيقونة اختيارية
                      ),
                    ),
                  );

                  await player.play();
                },
                child: Text(
                  "Test--2",
                  style: TextStyle(color: scandColor),
                )),
          ),
        ],
      ),
    );
  }
}
