import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ViewfinderOverlay extends StatelessWidget {
  const ViewfinderOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Viewfinder size logic
        final double viewfinderWidth = constraints.maxWidth * 0.85;
        final double viewfinderHeight = constraints.maxHeight * 0.9;
        final Size viewfinderSize = Size(viewfinderWidth, viewfinderHeight);

        return Center(
          child: SizedBox(
            width: viewfinderSize.width,
            height: viewfinderSize.height,
            child: Stack(
              children: [
                // Semi-transparent inner area
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                
                // L-Brackets Painter
                CustomPaint(
                  size: viewfinderSize,
                  painter: ViewfinderPainter(
                    color: AppColors.primary,
                    strokeWidth: 2.5,
                    bracketLength: 32.0,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ViewfinderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double bracketLength;

  ViewfinderPainter({
    required this.color,
    required this.strokeWidth,
    required this.bracketLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double w = size.width;
    final double h = size.height;

    // Top Left
    canvas.drawLine(Offset(0, bracketLength), Offset.zero, paint);
    canvas.drawLine(Offset.zero, Offset(bracketLength, 0), paint);

    // Top Right
    canvas.drawLine(Offset(w - bracketLength, 0), Offset(w, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, bracketLength), paint);

    // Bottom Left
    canvas.drawLine(Offset(0, h - bracketLength), Offset(0, h), paint);
    canvas.drawLine(Offset(0, h), Offset(bracketLength, h), paint);

    // Bottom Right
    canvas.drawLine(Offset(w - bracketLength, h), Offset(w, h), paint);
    canvas.drawLine(Offset(w, h), Offset(w, h - bracketLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
