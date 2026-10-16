import 'package:flutter/material.dart';
import 'package:risala/custom/custom_blur_background/custom_blur_background.dart';

class CustomDialogue2 extends StatefulWidget {
  const CustomDialogue2({
    super.key,
    required this.text,
    required this.choose1,
    this.onPressedchoose1,
    required this.choose2,
    this.onPressedchoose2,
    this.choose3,
    this.onPressedchoose3,
  });

  final String text;

  final String choose1;
  final VoidCallback? onPressedchoose1;

  final String choose2;
  final VoidCallback? onPressedchoose2;

  // الخيار الثالث اختياري
  final String? choose3;
  final VoidCallback? onPressedchoose3;

  @override
  State<CustomDialogue2> createState() => _CustomDialogue2State();
}

class _CustomDialogue2State extends State<CustomDialogue2> {
  double dialogueAnimatedScale = 0.75;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      setState(() {
        dialogueAnimatedScale = 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomBlurBackground(
      child: Center(
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.sizeOf(context).height * 0.2),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutBack,
            scale: dialogueAnimatedScale,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.88,
                maxHeight: MediaQuery.sizeOf(context).height * 0.75,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Material(
                  color: Colors.transparent,
                  elevation: 12,
                  shadowColor: Colors.black.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color:
                            colorScheme.outlineVariant.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // أيقونة زخرفية
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.info_rounded,
                              size: 30,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // نص الحوار
                          Text(
                            widget.text,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              height: 1.7,
                              color: colorScheme.onSurface,
                            ),
                          ),

                          const SizedBox(height: 26),

                          // الخيار الأول
                          _buildMainButton(
                            context: context,
                            text: widget.choose1,
                            onPressed: widget.onPressedchoose1,
                            icon: Icons.check_circle_outline_rounded,
                          ),

                          const SizedBox(height: 12),

                          // الخيار الثاني
                          _buildMainButton(
                            context: context,
                            text: widget.choose2,
                            onPressed: widget.onPressedchoose2,
                            icon: Icons.touch_app_rounded,
                            outlined: true,
                          ),

                          // الخيار الثالث: أصغر وتحت الخيارين
                          if (widget.choose3 != null) ...[
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: widget.onPressedchoose3,
                              style: TextButton.styleFrom(
                                foregroundColor: colorScheme.onSurfaceVariant,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                                minimumSize: const Size(0, 40),
                                tapTargetSize: MaterialTapTargetSize.padded,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                widget.choose3!,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainButton({
    required BuildContext context,
    required String text,
    required VoidCallback? onPressed,
    required IconData icon,
    bool outlined = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: outlined
          ? OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 21),
              label: Text(
                text,
                textAlign: TextAlign.center,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.primary,
                side: BorderSide(
                  color: colorScheme.primary.withValues(alpha: 0.45),
                  width: 1.3,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
                minimumSize: const Size(0, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : FilledButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 21),
              label: Text(
                text,
                textAlign: TextAlign.center,
              ),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
                minimumSize: const Size(0, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
    );
  }
}
