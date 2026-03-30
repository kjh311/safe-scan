import 'package:flutter/material.dart';
import '../models/analyzed_ingredient.dart';
import '../theme/app_theme.dart';

class ResultsView extends StatelessWidget {
  final VoidCallback onReset;
  final List<AnalyzedIngredient> ingredients;

  const ResultsView({
    super.key,
    required this.onReset,
    required this.ingredients,
  });

  @override
  Widget build(BuildContext context) {
    final bannedCount = ingredients.where((i) => i.isBanned).length;
    final safeCount = ingredients.length - bannedCount;
    final safePercent = ingredients.isEmpty
        ? 100
        : ((safeCount / ingredients.length) * 100).round();

    final overallColor = bannedCount == 0 ? AppColors.primary : Colors.redAccent;
    final overallLabel = bannedCount == 0 ? 'SAFE' : 'BANNED DETECTED';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 150),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Result Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "SCAN COMPLETE",
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: overallColor,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Analysis Report",
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 28,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: overallColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: overallColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '$safePercent%\n$overallLabel',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: overallColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Summary stats
          Row(
            children: [
              _buildStatChip('${ingredients.length}', 'TOTAL', Colors.white54),
              const SizedBox(width: 12),
              _buildStatChip('$safeCount', 'SAFE', AppColors.primary),
              const SizedBox(width: 12),
              _buildStatChip('$bannedCount', 'BANNED', Colors.redAccent),
            ],
          ),

          const SizedBox(height: 32),

          // Ingredient List
          _buildSectionHeader("INGREDIENT ANALYSIS"),
          const SizedBox(height: 16),

          if (ingredients.isEmpty)
            const Center(
              child: Text(
                'No ingredients detected.',
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
            )
          else
            ...ingredients.map((ingredient) => _buildIngredientRow(ingredient)),

          const SizedBox(height: 48),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: onReset,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                "INITIATE NEW SCAN",
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label,
              style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 9, letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _buildIngredientRow(AnalyzedIngredient ingredient) {
    // Requirement logic: Red (Banned) vs Black (Safe)
    final textColor = ingredient.isBanned ? Colors.redAccent : Colors.black;
    // To make Black text visible in a dark theme, we use a light background for the row
    final bgColor = ingredient.isBanned 
        ? Colors.redAccent.withValues(alpha: 0.1) 
        : Colors.white.withValues(alpha: 0.9);
    final icon = ingredient.isBanned ? Icons.warning_amber_rounded : Icons.check_circle_outline;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ingredient.isBanned ? Colors.redAccent.withValues(alpha: 0.3) : Colors.white24),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ingredient.originalName,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: ingredient.isBanned ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
          if (ingredient.isBanned && ingredient.metadata != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                ingredient.metadata!['severity'].toString().toUpperCase(),
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white38,
        fontSize: 12,
        letterSpacing: 1.5,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
