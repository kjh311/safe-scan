import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'viewfinder_overlay.dart';

class ScannerView extends StatelessWidget {
  final VoidCallback onScanComplete;

  const ScannerView({super.key, required this.onScanComplete});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenHeight = constraints.maxHeight;

        return Stack(
          children: [
            // 1. Base Layer: Camera Feed Placeholder
            Container(color: Colors.black),

            // 2. Global Glassmorphism Layer
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.8),
                ),
              ),
            ),

            // 3. Header: Black Navbar (Top 10%)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: screenHeight * 0.1,
              child: Container(
                color: Colors.black,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.bolt_outlined, color: AppColors.primary, size: 28),
                        Text(
                          "SAFE SCAN",
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            fontSize: 22,
                          ),
                        ),
                        const Icon(Icons.flashlight_on_outlined, color: AppColors.primary, size: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 4. Align Text: Top 13% (Shifted Up)
            Positioned(
              top: screenHeight * 0.13,
              left: 0,
              right: 0,
              child: const Center(
                child: Text(
                  "ALIGN INGREDIENTS WITHIN FRAME.",
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // 5. Viewfinder: Center 45% (Shifted Up, starting at 18%)
            Positioned(
              top: screenHeight * 0.18,
              left: 0,
              right: 0,
              height: screenHeight * 0.45,
              child: const ViewfinderOverlay(),
            ),

            // 6. Capture Button: Region 68% to 83% (Shifted Up)
            Positioned(
              top: screenHeight * 0.68,
              left: 32,
              right: 32,
              height: screenHeight * 0.15,
              child: Center(
                child: GestureDetector(
                  onTap: onScanComplete,
                  child: Container(
                    height: 64,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.circle_outlined, color: AppColors.primary, size: 20),
                        SizedBox(width: 16),
                        Text(
                          "SNAP INGREDIENTS LABEL",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
