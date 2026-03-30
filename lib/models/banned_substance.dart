class BannedSubstance {
  final String name;
  final String reason;
  final String severity;

  const BannedSubstance({
    required this.name,
    required this.reason,
    required this.severity,
  });

  factory BannedSubstance.fromJson(Map<String, dynamic> json) {
    return BannedSubstance(
      name: json['name'] as String,
      reason: json['reason'] as String,
      severity: json['severity'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'reason': reason,
      'severity': severity,
    };
  }
}
