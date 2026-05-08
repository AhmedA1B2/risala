import 'dart:async';
import 'package:flutter/material.dart';
import 'package:risala/vars/colors.dart';
import 'package:video_player/video_player.dart';
import 'package:vibration/vibration.dart';

class MyVideoPlayer extends StatefulWidget {
  const MyVideoPlayer({
    super.key,
    required this.video,
    required this.onFinished,
  });

  final String video;
  final VoidCallback onFinished;

  @override
  State<MyVideoPlayer> createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends State<MyVideoPlayer> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  bool showContinueButton = false;
  bool hasVibrated = false;
  bool isFinishedHandled = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset(widget.video);

    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
      _controller.play();
    });

    _controller.addListener(_videoListener);
  }

  void _videoListener() {
    if (!_controller.value.isInitialized) return;

    final position = _controller.value.position;
    final duration = _controller.value.duration;

    // 📳 الاهتزاز (مرة واحدة فقط)
    if (position.inMilliseconds >= 200 &&
        position.inMilliseconds < 400 &&
        !hasVibrated) {
      _triggerVibration();
    }

    // 🎬 انتهاء الفيديو
    if (position >= duration && !showContinueButton && !isFinishedHandled) {
      isFinishedHandled = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          showContinueButton = true;
        });
      });
    }
  }

  void _triggerVibration() async {
    hasVibrated = true;
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 200);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Stack(
        children: [
          FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),

          // 🔘 زر المتابعة
          if (showContinueButton)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: widget.onFinished,
                  child: const Text(
                    "متابعة",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
