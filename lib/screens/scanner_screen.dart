import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/viewfinder_overlay.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Placeholder for camera
      body: Stack(
        children: [
          // Simulated Camera View (just a black background for now)
          const Center(
            child: Text(
              "CAMERA_FEED_SIMULATION",
              style: TextStyle(color: Colors.white24, fontSize: 12),
            ),
          ),
          
          // Viewfinder Overlay
          const ViewfinderOverlay(),

          // Top Branding
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  "SAFE SCAN",
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 32,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "READY TO SCAN",
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          // Diagnostic Data Overlay (Mock)
          Positioned(
            bottom: 120,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Last Diagnostic",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  "Almond Milk: 98% Bio-Safe",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Floating Island Navigation
          Positioned(
            bottom: 30,
            left: 40,
            right: 40,
            child: _buildFloatingNavigation(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNavigation(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          color: AppColors.surfaceContainerHigh.withOpacity(0.8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(context, Icons.document_scanner, "SCAN", true),
              _buildNavItem(context, Icons.storage_rounded, "HISTORY", false),
              _buildNavItem(context, Icons.person_outline_rounded, "BIO", false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive) {
    final Color color = isActive ? AppColors.primary : AppColors.onSurfaceVariant;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: color,
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        if (isActive)
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}
