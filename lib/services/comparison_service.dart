import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/banned_substance.dart';
import '../models/analyzed_ingredient.dart';

class ComparisonService {
  static final ComparisonService _instance = ComparisonService._internal();
  factory ComparisonService() => _instance;
  ComparisonService._internal();

  final _supabase = Supabase.instance.client;

  /// Fetches the current list of prohibited items from Supabase with all enriched fields.
  Future<List<BannedSubstance>> fetchBannedSubstances() async {
    try {
      final List<dynamic> response = await _supabase
          .from('banned_substances')
          .select('name, reason, severity, status, governing_body, source_url');
      
      return response.map((json) => BannedSubstance.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      // In case of error, return empty list to avoid breaking the UI
      return [];
    }
  }

  /// Comparison Engine logic with enriched output and override logic.
  Future<List<AnalyzedIngredient>> analyzeIngredients(List<String> ingredients) async {
    final bannedList = await fetchBannedSubstances();

    return ingredients.map((ingredient) {
      final lowerIng = ingredient.toLowerCase().trim();
      
      BannedSubstance? matchingBanned;
      for (final banned in bannedList) {
        final bannedNameLower = banned.name.toLowerCase().trim();
        // Use a "contains" check rather than an "exact match" to catch variations
        if (bannedNameLower.isNotEmpty && lowerIng.contains(bannedNameLower)) {
          matchingBanned = banned;
          break;
        }
      }

      final isBanned = matchingBanned != null;

      if (isBanned) {
        // Enriched output Requirements:
        // display_name: The matched name.
        // status_text: "Status: [status] - [governing_body]"
        // reason_text: The official reason from Supabase.
        // documentation_url: The link for the Source accordion.
        return AnalyzedIngredient(
          originalName: ingredient,
          displayName: matchingBanned.name,
          isBanned: true,
          statusText: "Status: ${matchingBanned.status ?? 'Banned'} - ${matchingBanned.governingBody ?? 'Regulatory Body'}",
          reasonText: matchingBanned.reason,
          documentationUrl: matchingBanned.sourceUrl,
          severity: matchingBanned.severity.toLowerCase(),
        );
      } else {
        // Safe ingredient logic
        return AnalyzedIngredient(
          originalName: ingredient,
          isBanned: false,
        );
      }
    }).toList();
  }
}
