import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// A single recognized ingredient with its hazard classification.
class IngredientResult {
  final String name;
  final bool isHazardous;
  final String? hazardLabel;

  const IngredientResult({
    required this.name,
    required this.isHazardous,
    this.hazardLabel,
  });
}

/// Service responsible for performing OCR and classifying ingredients.
class OcrService {
  static final OcrService _instance = OcrService._internal();
  factory OcrService() => _instance;
  OcrService._internal();

  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  /// Known Hazards map: ingredient keyword (lowercase) -> hazard type
  static const Map<String, String> _knownHazards = {
    'red 40': 'Carcinogen',
    'red40': 'Carcinogen',
    'yellow 5': 'Allergen',
    'yellow 6': 'Allergen',
    'blue 1': 'Carcinogen',
    'sodium nitrate': 'Carcinogen',
    'sodium nitrite': 'Carcinogen',
    'bht': 'Endocrine Disruptor',
    'bha': 'Endocrine Disruptor',
    'tbhq': 'Carcinogen',
    'msg': 'Neurotoxin',
    'aspartame': 'Neurotoxin',
    'saccharin': 'Carcinogen',
    'high fructose corn syrup': 'Metabolic Risk',
    'hfcs': 'Metabolic Risk',
    'acrylamide': 'Carcinogen',
    'potassium bromate': 'Carcinogen',
    'brominated vegetable oil': 'Endocrine Disruptor',
    'bvo': 'Endocrine Disruptor',
    'carrageenan': 'Inflammatory Agent',
    'propyl gallate': 'Endocrine Disruptor',
  };

  /// Mock ingredients used when camera is unavailable (web/testing).
  static const List<String> _mockIngredients = [
    'Filtered Water',
    'Almonds',
    'High Fructose Corn Syrup',
    'BHT',
    'Calcium Carbonate',
    'Vitamin E',
    'Red 40',
    'Sunflower Lecithin',
    'Sea Salt',
  ];

  /// Extracts ingredients from an image XFile.
  ///
  /// Cleans the OCR result by removing the 'Ingredients:' prefix,
  /// newlines, and extra whitespace, then splits by commas.
  Future<List<String>> scanIngredients(XFile image) async {
    try {
      final inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      // Concatenate all recognized text blocks
      final rawText = recognizedText.blocks
          .map((block) => block.text)
          .join(' ');

      debugPrint('--- OCR RAW TEXT ---');
      debugPrint(rawText);
      debugPrint('--------------------');

      // 1. Remove "Ingredients:" prefix (case-insensitive)
      final cleaned = rawText
          .replaceAll(RegExp(r'ingredients\s*:', caseSensitive: false), '')
          // 2. Replace newlines with spaces
          .replaceAll(RegExp(r'\n+'), ' ')
          // 3. Collapse multiple spaces
          .replaceAll(RegExp(r'\s{2,}'), ' ')
          .trim();

      // 4. Split by commas, trim each entry, and remove empty entries
      final ingredients = cleaned
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      debugPrint('--- PARSED INGREDIENTS ---');
      for (final ingredient in ingredients) {
        debugPrint('  - $ingredient');
      }
      debugPrint('--------------------------');

      return ingredients;
    } catch (e) {
      debugPrint('scanIngredients error: $e');
      return [];
    }
  }

  /// Processes the given image path and returns classified ingredients.
  Future<List<Map<String, dynamic>>> processImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      debugPrint('--- OCR RESULTS ---');
      final List<String> rawIngredients = [];
      for (TextBlock block in recognizedText.blocks) {
        debugPrint('Block: ${block.text}');
        final parts = block.text.split(RegExp(r'[,\n]'));
        for (final part in parts) {
          final trimmed = part.trim();
          if (trimmed.isNotEmpty) rawIngredients.add(trimmed);
        }
      }
      debugPrint('-------------------');

      return _classifyIngredients(rawIngredients);
    } catch (e) {
      debugPrint('OCR error: $e');
      return [];
    }
  }

  /// Returns mock results for web/no-camera environments.
  List<Map<String, dynamic>> getMockResults() {
    debugPrint('[MOCK] Using mock ingredient list.');
    return _classifyIngredients(List.from(_mockIngredients));
  }

  /// Temporary classification logic for UI testing.
  List<Map<String, dynamic>> _classifyIngredients(List<String> ingredients) {
    return ingredients.map((name) => {
      'name': name,
      'severity': 'green',
      'reason': 'Safe',
    }).toList();
  }

  /// Classifies a list of ingredient names against the known hazard map.
  List<IngredientResult> classifyIngredients(List<String> ingredients) {
    return ingredients.map((name) {
      final lower = name.toLowerCase().trim();
      String? hazardLabel;
      for (final entry in _knownHazards.entries) {
        if (lower.contains(entry.key)) {
          hazardLabel = entry.value;
          break;
        }
      }
      return IngredientResult(
        name: name,
        isHazardous: hazardLabel != null,
        hazardLabel: hazardLabel,
      );
    }).toList();
  }

  void dispose() {
    _textRecognizer.close();
  }
}
