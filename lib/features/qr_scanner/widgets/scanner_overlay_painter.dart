import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Custom Painter drawing the semi-transparent scanner mask with golden guide corners
class ScannerOverlayPainter extends CustomPainter {
  final Rect scanWindow;
  final double borderRadius;
  final double scanAnimationValue;

  ScannerOverlayPainter({
    required this.scanWindow,
    this.borderRadius = 16,
    this.scanAnimationValue = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = Colors.black.withOpacity(0.65);

    // Full screen rect
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Cutout path for scanner window
    final cutOutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(scanWindow, Radius.circular(borderRadius)),
      );

    // Draw darkened mask around cutout
    final maskPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(fullRect),
      cutOutPath,
    );
    canvas.drawPath(maskPath, backgroundPaint);

    // Draw Golden Corner Brackets
    final cornerPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    const cornerLength = 28.0;

    // Top-Left Corner
    canvas.drawLine(
      Offset(scanWindow.left, scanWindow.top + cornerLength),
      Offset(scanWindow.left, scanWindow.top + borderRadius),
      cornerPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(scanWindow.left, scanWindow.top, borderRadius * 2, borderRadius * 2),
      3.14159,
      1.57079,
      false,
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanWindow.left + borderRadius, scanWindow.top),
      Offset(scanWindow.left + cornerLength, scanWindow.top),
      cornerPaint,
    );

    // Top-Right Corner
    canvas.drawLine(
      Offset(scanWindow.right - cornerLength, scanWindow.top),
      Offset(scanWindow.right - borderRadius, scanWindow.top),
      cornerPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(scanWindow.right - borderRadius * 2, scanWindow.top, borderRadius * 2, borderRadius * 2),
      -1.57079,
      1.57079,
      false,
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanWindow.right, scanWindow.top + borderRadius),
      Offset(scanWindow.right, scanWindow.top + cornerLength),
      cornerPaint,
    );

    // Bottom-Left Corner
    canvas.drawLine(
      Offset(scanWindow.left, scanWindow.bottom - cornerLength),
      Offset(scanWindow.left, scanWindow.bottom - borderRadius),
      cornerPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(scanWindow.left, scanWindow.bottom - borderRadius * 2, borderRadius * 2, borderRadius * 2),
      1.57079,
      1.57079,
      false,
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanWindow.left + borderRadius, scanWindow.bottom),
      Offset(scanWindow.left + cornerLength, scanWindow.bottom),
      cornerPaint,
    );

    // Bottom-Right Corner
    canvas.drawLine(
      Offset(scanWindow.right - cornerLength, scanWindow.bottom),
      Offset(scanWindow.right - borderRadius, scanWindow.bottom),
      cornerPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(scanWindow.right - borderRadius * 2, scanWindow.bottom - borderRadius * 2, borderRadius * 2, borderRadius * 2),
      0,
      1.57079,
      false,
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanWindow.right, scanWindow.bottom - borderRadius),
      Offset(scanWindow.right, scanWindow.bottom - cornerLength),
      cornerPaint,
    );

    // Draw Moving Scanning Beam Laser
    final laserY = scanWindow.top + (scanWindow.height * scanAnimationValue);
    final laserPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.primary.withOpacity(0.0),
          AppColors.primary.withOpacity(0.85),
          AppColors.primary.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(scanWindow.left, laserY, scanWindow.width, 3))
      ..strokeWidth = 2.5;

    canvas.drawLine(
      Offset(scanWindow.left + 8, laserY),
      Offset(scanWindow.right - 8, laserY),
      laserPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) {
    return oldDelegate.scanAnimationValue != scanAnimationValue;
  }
}

