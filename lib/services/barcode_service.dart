import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Represents a detected barcode with its position
class DetectedBarcode {
  final String rawValue;
  final BarcodeFormat format;
  final Rect boundingBox;
  final Point<double> cornerPoints;

  const DetectedBarcode({
    required this.rawValue,
    required this.format,
    required this.boundingBox,
    required this.cornerPoints,
  });
}

/// Product data from OpenFoodFacts API
class ProductData {
  final String? productName;
  final List<String> ingredients;
  final String? imageUrl;

  const ProductData({
    this.productName,
    this.ingredients = const [],
    this.imageUrl,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    if (product == null) {
      return const ProductData();
    }

    List<String> ingredientsList = [];
    final ingredientsText = product['ingredients_text'] as String?;
    if (ingredientsText != null && ingredientsText.isNotEmpty) {
      // Split by newlines, commas, or other delimiters
      ingredientsList = ingredientsText
          .split(RegExp(r'[\n,;]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return ProductData(
      productName: product['product_name'] as String?,
      ingredients: ingredientsList,
      imageUrl: product['image_url'] as String?,
    );
  }
}

/// Service for barcode scanning and product lookup
class BarcodeService {
  static final BarcodeService _instance = BarcodeService._internal();
  factory BarcodeService() => _instance;
  BarcodeService._internal();

  final BarcodeScanner _barcodeScanner = BarcodeScanner(
    formats: [BarcodeFormat.ean13, BarcodeFormat.upca],
  );

  DetectedBarcode? _lastDetectedBarcode;
  bool _isProcessing = false;
  Timer? _scanDebounce;

  DetectedBarcode? get lastDetectedBarcode => _lastDetectedBarcode;

  /// Process an image from the camera for barcodes
  Future<DetectedBarcode?> processImage(XFile image) async {
    if (_isProcessing) return null;
    _isProcessing = true;

    try {
      final inputImage = InputImage.fromFilePath(image.path);
      final barcodes = await _barcodeScanner.processImage(inputImage);

      if (barcodes.isNotEmpty) {
        final barcode = barcodes.first;
        
        // Convert Barcode to our DetectedBarcode
        final detected = DetectedBarcode(
          rawValue: barcode.rawValue ?? '',
          format: barcode.format,
          boundingBox: barcode.boundingBox,
          cornerPoints: barcode.cornerPoints.isNotEmpty
              ? Point<double>(
                  barcode.cornerPoints.first.x.toDouble(),
                  barcode.cornerPoints.first.y.toDouble(),
                )
              : const Point(0.0, 0.0),
        );

        // Trigger haptic feedback
        await _triggerHapticFeedback();

        _lastDetectedBarcode = detected;
        return detected;
      }

      _lastDetectedBarcode = null;
      return null;
    } catch (e) {
      debugPrint('Barcode scanning error: $e');
      return null;
    } finally {
      _isProcessing = false;
    }
  }

  /// Trigger haptic feedback
  Future<void> _triggerHapticFeedback() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Haptic feedback error: $e');
    }
  }

  /// Fetch product data from OpenFoodFacts API
  Future<ProductData?> fetchProduct(String barcode) async {
    try {
      final url = Uri.parse(
        'https://world.openfoodfacts.org/api/v0/product/$barcode.json',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final status = json['status'] as int?;

        if (status == 1) {
          return ProductData.fromJson(json);
        }
      }

      debugPrint('Product not found: $barcode');
      return null;
    } catch (e) {
      debugPrint('OpenFoodFacts API error: $e');
      return null;
    }
  }

  /// Clear the last detected barcode
  void clearLastDetected() {
    _lastDetectedBarcode = null;
  }

  /// Dispose resources
  void dispose() {
    _scanDebounce?.cancel();
    _barcodeScanner.close();
  }
}
