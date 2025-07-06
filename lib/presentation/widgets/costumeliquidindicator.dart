import 'package:flutter/material.dart';
import 'dart:math' as math;

class CustomLiquidIndicator extends StatefulWidget {
  final double value;
  final Color color;
  final Color backgroundColor;
  final bool enableAnimation;
  final Duration waveDuration;
  final Widget? center;
  final CustomClipper<Path>? customPath;

  const CustomLiquidIndicator({
    super.key,
    required this.value,
    this.color = Colors.blue,
    this.backgroundColor = Colors.white,
    this.enableAnimation = true,
    this.waveDuration = const Duration(seconds: 6),
    this.center,
    this.customPath, required String stationId, required double screenWidth, required tankType,
  });

  @override
  State<CustomLiquidIndicator> createState() => _CustomLiquidIndicatorState();
}

class _CustomLiquidIndicatorState extends State<CustomLiquidIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.waveDuration,
    );

    if (widget.enableAnimation) {
      _animationController.repeat();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CustomLiquidIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enableAnimation != oldWidget.enableAnimation) {
      if (widget.enableAnimation) {
        _animationController.repeat();
      } else {
        _animationController.stop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: widget.customPath,
      child: CustomPaint(
        painter: _LiquidCustomPainter(
          animation: _animationController,
          value: widget.value,
          color: widget.color,
          backgroundColor: widget.backgroundColor,
          enableAnimation: widget.enableAnimation,
        ),
        child: Center(child: widget.center),
      ),
    );
  }
}

class _LiquidCustomPainter extends CustomPainter {
  final Animation<double> animation;
  final double value;
  final Color color;
  final Color backgroundColor;
  final bool enableAnimation;

  _LiquidCustomPainter({
    required this.animation,
    required this.value,
    required this.color,
    required this.backgroundColor,
    required this.enableAnimation,
  }) : super(repaint: enableAnimation ? animation : null);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background
    final paint = Paint()..color = backgroundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw liquid
    final wavePaint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final fillHeight = size.height * (1 - value.clamp(0.0, 1.0));
    final wave1Height = size.height * 0.05;
    final wave2Height = size.height * 0.025;

    final path = Path();
    path.moveTo(0, fillHeight);

    // Create wave effect only if animation is enabled
    if (enableAnimation) {
      for (double i = 0; i <= size.width; i++) {
        final wave1 = math.sin((animation.value * 3 * math.pi) + (i / size.width * 4 * math.pi)) *
            wave1Height;
        final wave2 = math.sin((animation.value * 2 * math.pi) + (i / size.width * 7 * math.pi)) *
            wave2Height;
        path.lineTo(i, fillHeight + wave1 + wave2);
      }
    } else {
      path.lineTo(size.width, fillHeight);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(_LiquidCustomPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.animation.value != animation.value ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

// Custom gas bottle path
class GasBottlePath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    
    final double width = size.width;
    final double height = size.height;
    final double cornerRadius = width * 0.2;
    
    // Top rounded corners
    path.moveTo(cornerRadius, 0);
    path.lineTo(width - cornerRadius, 0);
    path.arcToPoint(
      Offset(width, cornerRadius),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );
    
    // Straight sides
    path.lineTo(width, height - cornerRadius);
    
    // Bottom rounded corners
    path.arcToPoint(
      Offset(width - cornerRadius, height),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );
    path.lineTo(cornerRadius, height);
    path.arcToPoint(
      Offset(0, height - cornerRadius),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );
    
    path.lineTo(0, cornerRadius);
    path.arcToPoint(
      Offset(cornerRadius, 0),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}