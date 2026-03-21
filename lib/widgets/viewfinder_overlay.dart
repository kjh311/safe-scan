import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ViewfinderOverlay extends StatelessWidget {
  const ViewfinderOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Define viewfinder dimensions (vertical rectangle)
        final double viewfinderWidth = constraints.maxWidth * 0.7;
        final double viewfinderHeight = viewfinderWidth * 1.5; // Vertical ratio
        final Size viewfinderSize = Size(viewfinderWidth, viewfinderHeight);

        return Stack(
          children: [
            // Scrim / Background overlay with a hole
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.6),
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: viewfinderSize.width,
                      height: viewfinderSize.height,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Custom Painter for Brackets
            Align(
              alignment: Alignment.center,
              child: CustomPaint(
                size: viewfinderSize,
                painter: ViewfinderPainter(
                  color: AppColors.tertiary,
                  strokeWidth: 4.0,
                  bracketLength: 24.0,
                ),
              ),
            ),
          ],
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
