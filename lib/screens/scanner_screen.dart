import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/scanner_view.dart';
import '../widgets/results_view.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _showResults = false;

  void _toggleView() {
    setState(() {
      _showResults = !_showResults;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Content View
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _showResults 
                ? ResultsView(key: const ValueKey('results'), onReset: _toggleView)
                : ScannerView(key: const ValueKey('scanner'), onScanComplete: _toggleView),
          ),

          // Floating Island Navigation (at the very bottom)
          Positioned(
            bottom: 20, // Slightly higher to ensure it's "floating" above the edge
            left: 24,
            right: 24,
            child: Center(
              child: _buildFloatingNavigation(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNavigation(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildNavItem(context, Icons.shutter_speed_rounded, true),
          const SizedBox(width: 48),
          _buildNavItem(context, Icons.layers_outlined, false),
          const SizedBox(width: 48),
          _buildNavItem(context, Icons.person_outline_rounded, false),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, bool isActive) {
    if (isActive) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 24),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Icon(icon, color: Colors.white38, size: 24),
    );
  }
}
