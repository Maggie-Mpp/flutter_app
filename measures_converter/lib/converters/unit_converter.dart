/// Unit conversion utilities for the app.
///
/// Base units:
/// - length: meters
/// - weight: kilograms
enum UnitCategory { length, weight }

class UnitDefinition {
  final String label;
  final UnitCategory category;

  /// Converts FROM this unit TO the base unit for its category.
  final double Function(double v) toBase;

  /// Converts FROM the base unit TO this unit.
  final double Function(double v) fromBase;

  const UnitDefinition({
    required this.label,
    required this.category,
    required this.toBase,
    required this.fromBase,
  });
}

class UnitConverter {
  static final Map<String, UnitDefinition> units = <String, UnitDefinition>{
    // LENGTH (base = meters)
    'meters': UnitDefinition(
      label: 'meters',
      category: UnitCategory.length,
      toBase: (v) => v,
      fromBase: (v) => v,
    ),
    'kilometers': UnitDefinition(
      label: 'kilometers',
      category: UnitCategory.length,
      toBase: (v) => v * 1000.0,
      fromBase: (v) => v / 1000.0,
    ),
    'feet': UnitDefinition(
      label: 'feet',
      category: UnitCategory.length,
      toBase: (v) => v * 0.3048,
      fromBase: (v) => v / 0.3048,
    ),
    'miles': UnitDefinition(
      label: 'miles',
      category: UnitCategory.length,
      toBase: (v) => v * 1609.344,
      fromBase: (v) => v / 1609.344,
    ),

    // WEIGHT (base = kilograms)
    'kilograms': UnitDefinition(
      label: 'kilograms',
      category: UnitCategory.weight,
      toBase: (v) => v,
      fromBase: (v) => v,
    ),
    'pounds': UnitDefinition(
      label: 'pounds',
      category: UnitCategory.weight,
      toBase: (v) => v * 0.45359237,
      fromBase: (v) => v / 0.45359237,
    ),
  };

  static List<String> unitsForCategory(UnitCategory category) {
    return units.entries
        .where((e) => e.value.category == category)
        .map((e) => e.key)
        .toList()
      ..sort();
  }

  static double convert({
    required double value,
    required String fromUnitKey,
    required String toUnitKey,
  }) {
    final fromUnit = units[fromUnitKey];
    final toUnit = units[toUnitKey];

    if (fromUnit == null) throw ArgumentError('Unknown from unit: $fromUnitKey');
    if (toUnit == null) throw ArgumentError('Unknown to unit: $toUnitKey');
    if (fromUnit.category != toUnit.category) {
      throw ArgumentError('Unit categories must match.');
    }

    final baseValue = fromUnit.toBase(value);
    return toUnit.fromBase(baseValue);
  }
}
