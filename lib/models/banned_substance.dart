class BannedSubstance {
  final String name;
  final String reason;
  final String severity;
  final String? status;
  final String? governingBody;
  final String? sourceUrl;

  const BannedSubstance({
    required this.name,
    required this.reason,
    required this.severity,
    this.status,
    this.governingBody,
    this.sourceUrl,
  });

  factory BannedSubstance.fromJson(Map<String, dynamic> json) {
    return BannedSubstance(
      name: json['name'] as String,
      reason: json['reason'] as String,
      severity: json['severity'] as String,
      status: json['status'] as String?,
      governingBody: json['governing_body'] as String?,
      sourceUrl: json['source_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'reason': reason,
      'severity': severity,
      'status': status,
      'governing_body': governingBody,
      'source_url': sourceUrl,
    };
  }
}
