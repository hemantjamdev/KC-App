import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Overlay widget showing a scaling & fading heart burst when double-tapped.
class DoubleTapHeartOverlay extends StatefulWidget {
  const DoubleTapHeartOverlay({
    super.key,
    required this.isAnimating,
    required this.onAnimationComplete,
  });

  final bool isAnimating;
  final VoidCallback onAnimationComplete;

  @override
  State<DoubleTapHeartOverlay> createState() => _DoubleTapHeartOverlayState();
}

class _DoubleTapHeartOverlayState extends State<DoubleTapHeartOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    // TweenSequence requires parent controller values strictly between [0.0, 1.0].
    // Chaining curves on individual sub-tweens prevents out-of-bounds assertion crashes.
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.2, end: 1.3).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.3, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.4).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.0),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0),
        weight: 30,
      ),
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete();
      }
    });
  }

  @override
  void didUpdateWidget(covariant DoubleTapHeartOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating && !oldWidget.isAnimating) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isAnimating) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacityVal = _opacityAnimation.value.clamp(0.0, 1.0);
        return Opacity(
          opacity: opacityVal,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_rounded,
                size: 72,
                color: AppColors.error,
              ),
            ),
          ),
        );
      },
    );
  }
}
