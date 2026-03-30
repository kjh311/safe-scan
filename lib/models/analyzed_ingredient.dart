class AnalyzedIngredient {
  final String originalName;
  final String? displayName;
  final bool isBanned;
  final String? statusText;
  final String? reasonText;
  final String? documentationUrl;
  final String? severity;
  final Map<String, dynamic>? metadata;

  const AnalyzedIngredient({
    required this.originalName,
    this.displayName,
    required this.isBanned,
    this.statusText,
    this.reasonText,
    this.documentationUrl,
    this.severity,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'original_name': originalName,
      'display_name': displayName,
      'is_banned': isBanned,
      'status_text': statusText,
      'reason_text': reasonText,
      'documentation_url': documentationUrl,
      'severity': severity,
      'metadata': metadata,
    };
  }
}
