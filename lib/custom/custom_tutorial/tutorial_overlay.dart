import 'package:flutter/material.dart';
import 'package:risala/main.dart';

class TutorialStep {
  final GlobalKey key;
  final String text;
  TutorialStep({required this.key, required this.text});
}

class TutorialOverlay {
  final BuildContext context;
  final List<TutorialStep> steps;
  final Color overlayColor;

  int _currentStep = 0;
  OverlayEntry? _entry;

  TutorialOverlay({
    required this.context,
    required this.steps,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 0.75),
  });

  void start() => _showStep();

  void _showStep() {
    _clearEntry();
    if (_currentStep >= steps.length) {
      _remove();
      return;
    }

    _entry = OverlayEntry(
      builder: (context) => _TutorialAnimatedView(
        step: steps[_currentStep],
        stepIndex: _currentStep,
        totalSteps: steps.length,
        overlayColor: overlayColor,
        onSkip: _remove,
      ),
    );

    Overlay.of(context).insert(_entry!);
  }

  void next() {
    _currentStep++;
    _showStep();
  }

  void _remove() {
    _clearEntry();
    _currentStep = 0;
    sharedPref.setBool("oldUser", true);
  }

  void _clearEntry() {
    _entry?.remove();
    _entry = null;
  }
}

// الكليبر المسؤول عن "ثقب" الخلفية بحواف دائرية
class _HoleClipper extends CustomClipper<Path> {
  final Rect rect;
  _HoleClipper(this.rect);

  @override
  Path getClip(Size size) {
    return Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(
          rect.inflate(4), const Radius.circular(12))) // حواف دائرية للثقب
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(_HoleClipper oldClipper) => oldClipper.rect != rect;
}

class _TutorialAnimatedView extends StatefulWidget {
  final TutorialStep step;
  final int stepIndex;
  final int totalSteps;
  final Color overlayColor;
  final VoidCallback onSkip;

  const _TutorialAnimatedView({
    required this.step,
    required this.stepIndex,
    required this.totalSteps,
    required this.overlayColor,
    required this.onSkip,
  });

  @override
  State<_TutorialAnimatedView> createState() => _TutorialAnimatedViewState();
}

class _TutorialAnimatedViewState extends State<_TutorialAnimatedView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1), // يبدأ من الأسفل قليلاً
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart, // أنيميشن احترافي وسلس جداً
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final renderBox =
        widget.step.key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return const SizedBox.shrink();

    final offset = renderBox.localToGlobal(Offset.zero);
    final rect = offset & renderBox.size;
    final screenSize = MediaQuery.of(context).size;
    bool showAbove = rect.center.dy > screenSize.height * 0.5;

    return Stack(
      children: [
        // 1. الخلفية المعتمة مع "ثقب" دائري الحواف يسمح بمرور اللمس
        FadeTransition(
          opacity: _opacityAnimation,
          child: ClipPath(
            clipper: _HoleClipper(rect),
            child: Container(color: widget.overlayColor),
          ),
        ),

        // 2. المحتوى (نص التعليمات)
        Positioned(
          top: showAbove ? null : rect.bottom + 25,
          bottom: showAbove ? (screenSize.height - rect.top) + 25 : null,
          left: 20,
          right: 20,
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: _buildTextBubble(),
            ),
          ),
        ),

        // 3. زر التخطي
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 20,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Material(
              color: Colors.transparent,
              child: TextButton(
                onPressed: widget.onSkip,
                child:
                    const Text("تخطي", style: TextStyle(color: Colors.white70)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextBubble() {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20), // حواف دائرية أنيقة
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.step.text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "خطوة ${widget.stepIndex + 1} من ${widget.totalSteps}",
                  style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
