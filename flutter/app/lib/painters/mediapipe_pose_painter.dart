import 'package:flutter/material.dart';

class MediaPipePosePainter extends CustomPainter {
  final List<Offset> landmarks;

  MediaPipePosePainter({
    required this.landmarks,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pointPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4
      ..style = PaintingStyle.fill;

    for (final point in landmarks) {
      canvas.drawCircle(point, 5, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant MediaPipePosePainter oldDelegate) {
    return oldDelegate.landmarks != landmarks;
  }
}