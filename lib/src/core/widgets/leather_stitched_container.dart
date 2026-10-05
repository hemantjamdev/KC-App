import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Ultra-luxury Leather Textured Container with Gold Dashed Stitching Border & Pebble Grain.
class LeatherStitchedContainer extends StatelessWidget {
  const LeatherStitchedContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.borderRadius = 22.0,
    this.stitchColor = AppColors.goldAccent,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color stitchColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: const RadialGradient(
          center: Alignment(-0.35, -0.45),
          radius: 1.35,
          colors: [
            Color(0xFF1E4834), // Soft top-left ambient light sheen on leather hide
            Color(0xFF133223), // Rich deep emerald leather body
            Color(0xFF0B1F16), // Dark leather edge shadow
          ],
          stops: [0.0, 0.55, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.32),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFFC5A880).withValues(alpha: 0.20),
            blurRadius: 2.0,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: CustomPaint(
          foregroundPainter: _DashedStitchingPainter(
            stitchColor: stitchColor,
            borderRadius: borderRadius,
          ),
          painter: _LeatherGrainTexturePainter(
            borderRadius: borderRadius,
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// CustomPainter drawing hyper-realistic natural leather hide texture & 3D bevel edges.
class _LeatherGrainTexturePainter extends CustomPainter {
  _LeatherGrainTexturePainter({required this.borderRadius});

  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Organic Curved Leather Micro-Creases & Wrinkles
    final creaseDarkPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.05)
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;

    final creaseLightPaint = Paint()
      ..color = const Color(0xFF3C7B5B).withValues(alpha: 0.08)
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;

    // Natural curved micro-crease paths across hide
    for (double y = 10; y < size.height; y += 18) {
      final Path path = Path();
      path.moveTo(0, y);
      for (double x = 0; x < size.width; x += 32) {
        final seed = ((x * 13) + (y * 29)).toInt();
        final controlY = y + ((seed % 7) - 3.5);
        final endX = math.min(x + 32, size.width);
        path.quadraticBezierTo(x + 16, controlY, endX, y + ((seed % 5) - 2.5));
      }
      canvas.drawPath(path, creaseDarkPaint);
      canvas.drawPath(path.shift(const Offset(0.5, 0.5)), creaseLightPaint);
    }

    // 2. Multi-Scale Natural Pebble Grain Pores & Cell Structure
    final poreDarkPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    final poreHighlightPaint = Paint()
      ..color = const Color(0xFF3C7B5B).withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;

    for (double x = 5; x < size.width; x += 9) {
      for (double y = 5; y < size.height; y += 9) {
        final seed = (x * 37 + y * 19).toInt();
        final offsetX = (seed % 7) - 3.5;
        final offsetY = ((seed * 17) % 7) - 3.5;
        final radius = 0.7 + ((seed % 3) * 0.45);

        final Offset center = Offset(
          (x + offsetX).clamp(0, size.width),
          (y + offsetY).clamp(0, size.height),
        );

        if (seed % 2 == 0) {
          canvas.drawCircle(center, radius, poreDarkPaint);
        } else {
          canvas.drawCircle(center + const Offset(0.4, 0.4), radius * 0.8, poreHighlightPaint);
        }
      }
    }

    // 3. 3D Embossed Leather Cut Bevel Frame
    final highlightBevel = Paint()
      ..color = const Color(0xFF3C7B5B).withValues(alpha: 0.35)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final shadowBevel = Paint()
      ..color = Colors.black.withValues(alpha: 0.55)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final innerRect = RRect.fromRectAndRadius(
      rect.deflate(1.0),
      Radius.circular(math.max(2.0, borderRadius - 1.0)),
    );

    canvas.drawRRect(innerRect, shadowBevel);
    canvas.drawRRect(innerRect.shift(const Offset(-0.8, -0.8)), highlightBevel);
  }

  @override
  bool shouldRepaint(covariant _LeatherGrainTexturePainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius;
  }
}

/// CustomPainter drawing authentic 3D tailor topstitch lines with --===-- sine-envelope thread dashes.
class _DashedStitchingPainter extends CustomPainter {
  _DashedStitchingPainter({
    required this.stitchColor,
    required this.borderRadius,
  });

  final Color stitchColor;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    const double inset = 6.0;
    const double minThickness = 1.0;
    const double maxThickness = 2.6;
    const double dashWidth = 8.0;
    const double dashGap = 4.5;

    // 1. Draw outer fabric seam edge (soft border)
    final outerEdgePaint = Paint()
      ..color = stitchColor.withValues(alpha: 0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final outerRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );
    canvas.drawRRect(outerRRect, outerEdgePaint);

    // 2. Draw Inset Tailor Topstitch Line with --===-- (thin-thick-thin) stroke profile
    final double insetRadius = (borderRadius - inset).clamp(4.0, borderRadius);
    final RRect insetRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        inset,
        inset,
        (size.width - inset * 2).clamp(0.0, size.width),
        (size.height - inset * 2).clamp(0.0, size.height),
      ),
      Radius.circular(insetRadius),
    );

    final Path insetPath = Path()..addRRect(insetRRect);

    // Thread shadow painter for 3D depth
    final threadShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    for (final PathMetric metric in insetPath.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double len = (distance + dashWidth < metric.length)
            ? dashWidth
            : metric.length - distance;

        if (len > 0) {
          const int steps = 6;
          for (int i = 0; i < steps; i++) {
            final double f1 = i / steps;
            final double f2 = (i + 1) / steps;
            final double d1 = distance + len * f1;
            final double d2 = distance + len * f2;
            final double fMid = (f1 + f2) / 2;

            final Path subSegment = metric.extractPath(d1, d2);
            final double w =
                minThickness +
                (maxThickness - minThickness) * math.sin(fMid * math.pi);

            // Draw dark thread shadow underneath
            canvas.drawPath(
              subSegment.shift(const Offset(0.6, 0.8)),
              threadShadowPaint..strokeWidth = w,
            );

            final paint = Paint()
              ..color = stitchColor
              ..style = PaintingStyle.stroke
              ..strokeWidth = w
              ..strokeCap = StrokeCap.round;

            canvas.drawPath(subSegment, paint);
          }
        }
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedStitchingPainter oldDelegate) {
    return oldDelegate.stitchColor != stitchColor ||
        oldDelegate.borderRadius != borderRadius;
  }
}
