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
    this.stitchColor = AppColors.surfaceWhite,
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
          center: Alignment(-0.4, -0.6),
          radius: 1.3,
          colors: [
            Color(0xFF234734), // Soft top-left light catch on leather
            Color(0xFF162D20), // Deep emerald leather body
            Color(0xFF0C1912), // Deep dark leather shadow edge
          ],
          stops: [0.0, 0.6, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFFC5A880).withValues(alpha: 0.18),
            blurRadius: 1.5,
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

/// CustomPainter drawing authentic leather pebble grain texture & 3D bevel edges.
class _LeatherGrainTexturePainter extends CustomPainter {
  _LeatherGrainTexturePainter({required this.borderRadius});

  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Draw subtle diagonal leather grain lines
    final grainLinePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.04)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (double i = -size.height; i < size.width + size.height; i += 12) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        grainLinePaint,
      );
    }

    // 2. Draw organic pebble grain dots
    final dotPaintLight = Paint()
      ..color = const Color(0xFF38684D).withValues(alpha: 0.09)
      ..style = PaintingStyle.fill;

    final dotPaintDark = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    // Deterministic pseudo-random seed grid
    for (double x = 8; x < size.width; x += 14) {
      for (double y = 8; y < size.height; y += 14) {
        final seed = (x * 31 + y * 17).toInt();
        final offsetX = (seed % 7) - 3.5;
        final offsetY = ((seed * 13) % 7) - 3.5;
        final radius = 1.0 + ((seed % 3) * 0.4);

        if (seed % 2 == 0) {
          canvas.drawCircle(Offset(x + offsetX, y + offsetY), radius, dotPaintDark);
        } else {
          canvas.drawCircle(Offset(x + offsetX, y + offsetY), radius, dotPaintLight);
        }
      }
    }

    // 3. Draw 3D embossed leather cut bevel frame
    final highlightBevel = Paint()
      ..color = const Color(0xFF427A5B).withValues(alpha: 0.25)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final shadowBevel = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
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
