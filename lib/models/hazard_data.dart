// lib/models/hazard_data.dart

class HazardLevel {
  static const String high = "RED FLAG";
  static const String medium = "CAUTION";
}

final Map<String, Map<String, String>> hazardDictionary = {
  "red 40": {
    "level": HazardLevel.high,
    "description": "Artificial color linked to hyperactivity and DNA damage.",
  },
  "titanium dioxide": {
    "level": HazardLevel.high,
    "description": "Banned in EU; potential carcinogen when ingested.",
  },
  "high fructose corn syrup": {
    "level": HazardLevel.medium,
    "description": "Highly processed sugar linked to metabolic issues.",
  },
  "yellow 5": {
    "level": HazardLevel.high,
    "description": "Artificial color; may cause allergic reactions.",
  },
  "aspartame": {
    "level": HazardLevel.medium,
    "description": "Artificial sweetener; some sensitive users report headaches.",
  },
  "vegetable oil": {
    "level": HazardLevel.medium,
    "description": "TEST TEST.",
  },
};

List<Map<String, String>> analyzeIngredients(String rawText) {
  if (rawText.isEmpty) {
    return [];
  }

  final lowerText = rawText.toLowerCase();
  final List<Map<String, String>> foundHazards = [];

  for (final entry in hazardDictionary.entries) {
    if (lowerText.contains(entry.key)) {
      foundHazards.add({
        "ingredient": entry.key,
        "level": entry.value["level"]!,
        "description": entry.value["description"]!,
      });
    }
  }

  return foundHazards;
}
