import 'package:flutter/material.dart';

class PawIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? backgroundColor;

  const PawIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final defaultColor = color ?? Theme.of(context).iconTheme.color ?? Colors.blue;
    final defaultBackgroundColor = backgroundColor ?? Colors.blue.shade100;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: defaultBackgroundColor,
        shape: BoxShape.circle,
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: PawIconPainter(
          color: defaultColor,
        ),
      ),
    );
  }
}

class PawIconPainter extends CustomPainter {
  final Color color;

  PawIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Ana yastık (merkez)
    final mainPawRadius = radius * 0.4;
    canvas.drawCircle(center, mainPawRadius, paint);

    // Üst yastıklar
    final topPawRadius = radius * 0.25;
    final topPawOffset = radius * 0.6;
    
    canvas.drawCircle(
      Offset(center.dx - topPawOffset, center.dy - topPawOffset),
      topPawRadius,
      paint,
    );
    
    canvas.drawCircle(
      Offset(center.dx + topPawOffset, center.dy - topPawOffset),
      topPawRadius,
      paint,
    );

    // Alt yastıklar
    final bottomPawRadius = radius * 0.2;
    final bottomPawOffsetX = radius * 0.7;
    final bottomPawOffsetY = radius * 0.4;
    
    canvas.drawCircle(
      Offset(center.dx - bottomPawOffsetX, center.dy + bottomPawOffsetY),
      bottomPawRadius,
      paint,
    );
    
    canvas.drawCircle(
      Offset(center.dx + bottomPawOffsetX, center.dy + bottomPawOffsetY),
      bottomPawRadius,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
