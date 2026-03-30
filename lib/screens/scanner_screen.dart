import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/comparison_service.dart';
import '../services/barcode_service.dart';
import '../services/ocr_service.dart';
import '../models/analyzed_ingredient.dart';
import '../theme/app_theme.dart';
import '../widgets/scanner_view.dart';
import '../widgets/results_view.dart';

class ScannerScreen extends StatefulWidget {
  final CameraController? initialController;
  const ScannerScreen({super.key, this.initialController});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _showResults = false;
  bool _isInitializing = true;
  bool _isCameraReady = false;

  CameraController? _nativeController;
  final OcrService _ocrService = OcrService();
  final BarcodeService _barcodeService = BarcodeService();
  final ComparisonService _comparisonService = ComparisonService();
  List<AnalyzedIngredient> _ingredientResults = [];
  
  // Barcode detection state
  DetectedBarcode? _detectedBarcode;
  bool _isBarcodeProcessing = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialController != null) {
      _nativeController = widget.initialController;
      _isCameraReady = true;
      _isInitializing = false;
    } else {
      _setupCameras();
    }
  }

  Future<void> _setupCameras() async {
    try {
      // Request camera permission first (on native platforms)
      if (!kIsWeb) {
        final status = await Permission.camera.request();
        if (!status.isGranted) {
          debugPrint('Camera permission denied: ${status.name}');
          if (mounted) {
            setState(() => _isInitializing = false);
          }
          return;
        }
      }

      // Use camera plugin for both web and native
      // On web, availableCameras() uses camera_web plugin
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _nativeController = CameraController(
          cameras[0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _nativeController!.initialize();
        _isCameraReady = true;
        debugPrint('Camera initialized: ${cameras[0].name} (${kIsWeb ? "web" : "native"})');
      } else {
        debugPrint('No cameras detected.');
      }
    } on CameraException catch (e) {
      debugPrint('Camera error: ${e.code} — ${e.description}');
    } catch (e) {
      debugPrint('Camera init error: $e');
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  @override
  void dispose() {
    _nativeController?.dispose();
    _ocrService.dispose();
    _barcodeService.dispose();
    super.dispose();
  }

  /// Continuously scan for barcodes while on scanner view
  Future<void> _scanForBarcodes() async {
    if (_isBarcodeProcessing || !_isCameraReady || _showResults) return;
    if (_nativeController == null || !_nativeController!.value.isInitialized) return;

    _isBarcodeProcessing = true;
    try {
      final image = await _nativeController!.takePicture();
      final barcode = await _barcodeService.processImage(image);

      if (mounted && barcode != null && barcode.rawValue.isNotEmpty) {
        setState(() {
          _detectedBarcode = barcode;
        });
        
        // Fetch product data from OpenFoodFacts
        final product = await _barcodeService.fetchProduct(barcode.rawValue);
        if (mounted && product != null && product.ingredients.isNotEmpty) {
          // Analyze ingredients with Comparison Service (Supabase sync)
          final results = await _comparisonService.analyzeIngredients(product.ingredients);
          setState(() {
            _ingredientResults = results;
            _showResults = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Barcode scan error: $e');
    } finally {
      _isBarcodeProcessing = false;
    }
  }

  void _toggleView() {
    setState(() {
      _showResults = !_showResults;
    });
  }

  Future<void> _onSnap() async {
    if (!_isCameraReady || _nativeController == null || !_nativeController!.value.isInitialized) {
      debugPrint('[FALLBACK] Camera not ready — using mock data.');
      final mockData = ['Organic Vegetable Oil', 'Red 40', 'Water', 'Sugar'];
      final results = await _comparisonService.analyzeIngredients(mockData);
      
      setState(() {
        _ingredientResults = results;
        _showResults = true;
      });
      return;
    }

    try {
      final image = await _nativeController!.takePicture();
      debugPrint('Frame captured: ${image.path}');
      
      List<String> ingredients;
      if (kIsWeb) {
        debugPrint('[WEB] OCR not yet implemented — using mock data.');
        ingredients = ['Organic Vegetable Oil', 'Titanium Dioxide', 'Yellow 5', 'Water'];
      } else {
        ingredients = await _ocrService.scanIngredients(image);
      }

      final results = await _comparisonService.analyzeIngredients(ingredients);

      setState(() {
        _ingredientResults = results;
        _showResults = true;
      });
    } on CameraException catch (e) {
      debugPrint('Capture error: ${e.code} — ${e.description}');
      final mockData = ['Organic Vegetable Oil', 'BHT', 'BHA'];
      final results = await _comparisonService.analyzeIngredients(mockData);
      
      setState(() {
        _ingredientResults = results;
        _showResults = true;
      });
    } catch (e) {
      debugPrint('Snap error: $e');
      final mockData = ['Vegetable Oil', 'Corn Syrup', 'Red 40'];
      final results = await _comparisonService.analyzeIngredients(mockData);
      
      setState(() {
        _ingredientResults = results;
        _showResults = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _showResults
                ? ResultsView(
                    key: const ValueKey('results'),
                    onReset: _toggleView,
                    ingredients: _ingredientResults,
                  )
                : ScannerView(
                    key: const ValueKey('scanner'),
                    onScanComplete: _onSnap,
                    onResult: (names) async {
                      final results = await _comparisonService.analyzeIngredients(names);
                      if (mounted) {
                        setState(() {
                          _ingredientResults = results;
                          _showResults = true;
                        });
                      }
                    },
                    controller: _nativeController,
                    isInitializing: _isInitializing,
                    isCameraReady: _isCameraReady,
                    detectedBarcode: _detectedBarcode,
                    onBarcodeScanned: _scanForBarcodes,
                  ),
          ),

          // Floating Island Navigation
          Positioned(
            bottom: 20,
            left: 24,
            right: 24,
            child: Center(child: _buildFloatingNavigation(context)),
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
        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
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
