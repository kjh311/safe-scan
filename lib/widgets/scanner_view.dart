import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import '../theme/app_theme.dart';
import '../services/barcode_service.dart';
import '../services/ocr_service.dart';
import 'viewfinder_overlay.dart';

class ScannerView extends StatefulWidget {
  final VoidCallback onScanComplete;
  final Function(List<String>) onResult;
  final CameraController? controller;
  final bool isInitializing;
  final bool isCameraReady;
  final DetectedBarcode? detectedBarcode;
  final VoidCallback? onBarcodeScanned;

  const ScannerView({
    super.key, 
    required this.onScanComplete,
    required this.onResult,
    this.controller,
    this.isInitializing = false,
    this.isCameraReady = false,
    this.detectedBarcode,
    this.onBarcodeScanned,
  });

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  Timer? _scanTimer;
  final BarcodeScanner _barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.all]);
  bool _isProcessing = false;
  
  @override
  void initState() {
    super.initState();
    _startContinuousScanning();
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _barcodeScanner.close();
    if (widget.controller != null && widget.controller!.value.isStreamingImages) {
      widget.controller!.stopImageStream();
    }
    super.dispose();
  }

  void _startContinuousScanning() {
    // If controller is ready, use image stream for better performance
    if (widget.isCameraReady && widget.controller != null && !widget.isInitializing) {
      if (!widget.controller!.value.isStreamingImages) {
        widget.controller!.startImageStream(_processCameraImage);
      }
    }

    // Keep the timer for any other periodic tasks or fallback
    _scanTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (widget.isCameraReady && !widget.isInitializing) {
        widget.onBarcodeScanned?.call();
      }
    });
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) return;
      
      final barcodes = await _barcodeScanner.processImage(inputImage);
      
      if (barcodes.isNotEmpty && mounted) {
        final barcode = barcodes.first;
        if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
          // 1. Trigger haptic feedback
          await HapticFeedback.lightImpact();
          
          // 2. Fetch product data
          final product = await BarcodeService().fetchProduct(barcode.rawValue!);
          
          if (product != null && product.ingredients.isNotEmpty && mounted) {
            // 3. Navigate (via callback)
            widget.onResult(product.ingredients);
          }
        }
      }
    } catch (e) {
      debugPrint('Barcode stream error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (widget.controller == null) return null;

    final camera = widget.controller!.description;
    final sensorOrientation = camera.sensorOrientation;
    final rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    if (image.planes.isEmpty) return null;
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

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
            if (widget.isCameraReady && widget.controller != null && widget.controller!.value.isInitialized)
              Positioned.fill(
                child: CameraPreview(widget.controller!),
              )
            else if (!widget.isCameraReady && !widget.isInitializing)
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

            // 5b. Barcode detection overlay - blue circle on detected barcode
            if (widget.detectedBarcode != null)
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final barcode = widget.detectedBarcode!;
                    // Convert normalized coordinates to screen coordinates
                    final box = barcode.boundingBox;
                    final left = box.left * constraints.maxWidth;
                    final top = box.top * constraints.maxHeight;
                    final width = box.width * constraints.maxWidth;
                    final height = box.height * constraints.maxHeight;
                    
                    return Stack(
                      children: [
                        Positioned(
                          left: left,
                          top: top,
                          width: width,
                          height: height,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.blue,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        // Small blue circle indicator
                        Positioned(
                          left: left + width / 2 - 12,
                          top: top - 24,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

            // 6. Capture Button: Region 68% to 83%
            Positioned(
              top: screenHeight * 0.68,
              left: 32,
              right: 32,
              height: screenHeight * 0.15,
              child: Center(
                child: GestureDetector(
                  onTap: widget.onScanComplete,
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
            if (widget.isInitializing)
              const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
          ],
        );
      },
    );
  }

}
