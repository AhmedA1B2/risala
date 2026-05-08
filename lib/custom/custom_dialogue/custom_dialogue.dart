import 'package:flutter/material.dart';
import 'package:risala/custom/custom_blur_background/custom_blur_background.dart';

class CustomDialogue extends StatefulWidget {
  const CustomDialogue({
    super.key,
    required this.iconOk,
    this.onPressediconOk,
    required this.iconNo,
    this.onPressediconNo,
    required this.text,
  });

  final IconData iconOk;
  final void Function()? onPressediconOk;
  final IconData iconNo;
  final void Function()? onPressediconNo;
  final String text;

  @override
  State<CustomDialogue> createState() => _CustomDialogueState();
}

class _CustomDialogueState extends State<CustomDialogue> {
  double dialogueAnimatedScale = 0.2;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        dialogueAnimatedScale = 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomBlurBackground(
      onTap: widget.onPressediconNo,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 400),
        curve: Curves.bounceOut,
        scale: dialogueAnimatedScale,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            padding: const EdgeInsets.all(0),
                            onPressed: widget.onPressediconOk,
                            icon: Icon(
                              widget.iconOk,
                              color: Colors.green,
                              size: 48,
                            ),
                          ),
                          IconButton(
                            padding: const EdgeInsets.all(0),
                            onPressed: widget.onPressediconNo,
                            icon: Icon(
                              widget.iconNo,
                              color: Colors.red,
                              size: 48,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
