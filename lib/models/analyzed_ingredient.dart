class AnalyzedIngredient {
  final String originalName;
  final bool isBanned;
  final Map<String, dynamic>? metadata;

  const AnalyzedIngredient({
    required this.originalName,
    required this.isBanned,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'original_name': originalName,
      'is_banned': isBanned,
      'metadata': metadata,
    };
  }
}
