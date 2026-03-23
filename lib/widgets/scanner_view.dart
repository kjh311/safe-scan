import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../theme/app_theme.dart';
import 'viewfinder_overlay.dart';

class ScannerView extends StatelessWidget {
  final VoidCallback onScanComplete;
  final CameraController? controller;
  final bool isInitializing;
  final bool isCameraReady;

  const ScannerView({
    super.key, 
    required this.onScanComplete,
    this.controller,
    this.isInitializing = false,
    this.isCameraReady = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double screenHeight = constraints.maxHeight;
        final double screenWidth = constraints.maxWidth;

        // Calculate key regions
        final double headerHeight = screenHeight * 0.1;
        final double topDimHeight = screenHeight * 0.18;
        final double viewfinderTop = screenHeight * 0.18;
        final double viewfinderHeight = screenHeight * 0.45;
        final double bottomDimTop = screenHeight * 0.63;

        // Calculate viewfinder dimensions
        final double viewfinderWidth = screenWidth * 0.85;
        final double viewfinderLeft = (screenWidth - viewfinderWidth) / 2;
        
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. Base Layer: Camera Feed - fills entire screen without zoom
            if (isCameraReady && controller != null && controller!.value.isInitialized)
              Positioned.fill(
                child: CameraPreview(controller!),
              )
            else if (!isCameraReady && !isInitializing)
              Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.videocam_off_outlined, color: AppColors.primary.withValues(alpha: 0.3), size: 48),
                      const SizedBox(height: 16),
                      Text(
                        "Camera Not Available",
                        style: TextStyle(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          fontSize: 14,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 2. Dark Overlay Layer - covers everything except viewfinder area
            // Top overlay (below header, above viewfinder)
            Positioned(
              top: headerHeight,
              left: 0,
              right: 0,
              height: topDimHeight - headerHeight,
              child: Container(color: Colors.black.withValues(alpha: 0.6)),
            ),
            // Bottom overlay (below viewfinder)
            Positioned(
              top: bottomDimTop,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(color: Colors.black.withValues(alpha: 0.6)),
            ),
            // Left side overlay (left of viewfinder)
            Positioned(
              top: viewfinderTop,
              left: 0,
              width: viewfinderLeft,
              height: viewfinderHeight,
              child: Container(color: Colors.black.withValues(alpha: 0.6)),
            ),
            // Right side overlay (right of viewfinder)
            Positioned(
              top: viewfinderTop,
              right: 0,
              width: viewfinderLeft,
              height: viewfinderHeight,
              child: Container(color: Colors.black.withValues(alpha: 0.6)),
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

            // 4. Align Text: Top 13%
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

            // 5. Viewfinder: Center 45%
            Positioned(
              top: screenHeight * 0.18,
              left: 0,
              right: 0,
              height: screenHeight * 0.45,
              child: const ViewfinderOverlay(),
            ),

            // 6. Capture Button: Region 68% to 83%
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
            
            // Loading indicator
            if (isInitializing)
              const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
          ],
        );
      },
    );
  }
}
