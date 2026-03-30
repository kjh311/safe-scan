import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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

    final overallColor = bannedCount == 0 ? AppColors.primary : const Color(0xFFD32F2F);
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
              _buildStatChip('$bannedCount', 'BANNED', const Color(0xFFD32F2F)),
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
            ...ingredients.map((ingredient) => _buildIngredientRow(context, ingredient)),

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

  Widget _buildIngredientRow(BuildContext context, AnalyzedIngredient ingredient) {
    if (!ingredient.isBanned) {
      // SAFE Ingredient: Black text on light background
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.black, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                ingredient.originalName,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // BANNED Ingredient: Severity Color Mapping
    final severity = ingredient.severity?.toLowerCase() ?? 'caution';
    final Color severityColor;
    switch (severity) {
      case 'danger':
        severityColor = const Color(0xFFD32F2F);
        break;
      case 'warning':
        severityColor = const Color(0xFFF57C00);
        break;
      case 'caution':
      default:
        severityColor = const Color(0xFFFBC02D);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: severityColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: severityColor.withValues(alpha: 0.25)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: severityColor,
          collapsedIconColor: severityColor,
          tilePadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: severityColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ingredient.displayName ?? ingredient.originalName,
                          style: TextStyle(
                            color: severityColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          ingredient.statusText ?? 'Flagged Substance',
                          style: TextStyle(
                            color: severityColor.withValues(alpha: 0.8),
                            fontSize: 11,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Moved Reason for Flagging here to be visible outside accordion children
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Reason for Flagging:",
                      style: TextStyle(
                        color: severityColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ingredient.reasonText ?? 'No official reason provided in the database.',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1, color: Colors.white10),
                  const SizedBox(height: 16),
                  if (ingredient.documentationUrl != null)
                    InkWell(
                      onTap: () async {
                        final url = Uri.parse(ingredient.documentationUrl!);
                        try {
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          } else {
                            debugPrint('Could not launch ${ingredient.documentationUrl}');
                          }
                        } catch (e) {
                          debugPrint('Error launching URL: $e');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: severityColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: severityColor.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.school_outlined, color: severityColor, size: 16),
                            const SizedBox(width: 10),
                            Text(
                              "Source documentation",
                              style: TextStyle(
                                color: severityColor,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
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
