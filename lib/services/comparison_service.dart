import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/banned_substance.dart';
import '../models/analyzed_ingredient.dart';

class ComparisonService {
  static final ComparisonService _instance = ComparisonService._internal();
  factory ComparisonService() => _instance;
  ComparisonService._internal();

  final _supabase = Supabase.instance.client;

  /// Fetches the current list of prohibited items from Supabase.
  Future<List<BannedSubstance>> fetchBannedSubstances() async {
    try {
      final List<dynamic> response = await _supabase
          .from('banned_substances')
          .select('name, reason, severity');
      
      return response.map((json) => BannedSubstance.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      // In production, we might want to return cached data or handle logout
      return [];
    }
  }

  /// Comparison Engine logic with "contains" check.
  Future<List<AnalyzedIngredient>> analyzeIngredients(List<String> ingredients) async {
    final bannedList = await fetchBannedSubstances();

    return ingredients.map((ingredient) {
      final lowerIng = ingredient.toLowerCase().trim();
      
      BannedSubstance? matchingBanned;
      for (final banned in bannedList) {
        final bannedNameLower = banned.name.toLowerCase().trim();
        if (bannedNameLower.isNotEmpty && lowerIng.contains(bannedNameLower)) {
          matchingBanned = banned;
          break;
        }
      }

      final isBanned = matchingBanned != null;

      return AnalyzedIngredient(
        originalName: ingredient,
        isBanned: isBanned,
        metadata: isBanned 
            ? {
                'reason': matchingBanned.reason,
                'severity': matchingBanned.severity,
              }
            : null,
      );
    }).toList();
  }
}
