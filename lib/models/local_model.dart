import 'data_model.dart';

// Units and measures
class MassUnit {
  MassUnit();

  String get g => "g";
  String get kg => "kg";
  String get lb => "lb";
  String get oz => "oz";
  List<String> get unitList => [g, kg, lb, oz];

  String defaultUnit = 'g';

  // conversion table
  Map<String, int> get conversionMap => {
    g: 1,
    kg: 1000,
    lb: 454,
    oz: 28
  };

  double? massConversionFactor(String currentUnit, String wantedUnit) {
    if (unitList.contains(currentUnit) && unitList.contains(wantedUnit)) {
      return conversionMap[currentUnit]! / conversionMap[wantedUnit]!;
    } else {
      print('Unit error');
      return(0);
    }
  }
}

class VolumeUnit {
  final String locale;
  VolumeUnit(this.locale);

  String get tsp => locale == 'fr' ? 'cac' : 'tsp';
  String get tbs => locale == 'fr' ? 'cas' : 'Tbs';
  String get cup => locale == 'fr' ? 'tasse' : 'cup';
  String get mL => 'mL';
  String get cL => 'cL';
  String get L => 'L';

  String defaultUnit = 'cL';

  Map<String, String> aliases = {
    'cac': 'tsp',
    'tsp': 'tsp',
    'cas': 'Tbs',
    'Tbs': 'Tbs',
    'tasse': 'cup',
    'cup': 'cup',
    'mL': 'mL',
    'cL': 'cL',
    'L': 'L'
  };

  List<String> get unitList => [tsp, tbs, cup, mL, cL, L];
  List<String> get aliasesList => aliases.keys.toList();

  // conversion table
  Map<String, int> get conversionMap => {
    tsp: 5,
    tbs: 15,
    cup: 250,
    mL: 1,
    cL: 10,
    L: 1000
  };

  double? volumeConversionFactor(String currentUnit, String wantedUnit) {
    if (unitList.contains(currentUnit) && unitList.contains(wantedUnit)) {
      return conversionMap[currentUnit]! / conversionMap[wantedUnit]!;
    } else {
      print('Unit error');
      return(0);
    }
  }
}

class SmallQuantityUnit {
  // not convertible
  final String locale;
  SmallQuantityUnit(this.locale);

  String get cap => locale == 'fr' ? "bouchon" : "cap";
  String get drop => locale == 'fr' ? "goutte" : "drop";
  String get pinch => locale == 'fr' ? "pincée" : "pinch";
  String get glass => locale == 'fr' ? "verre" : "glass";

  Map<String, String> aliases = {
    'bouchon': 'cap',
    'cap': 'cap',
    'goutte': 'drop',
    'drop': 'drop',
    'pincée': 'pinch',
    'pinch': 'pinch',
    'verre': 'glass',
    'glass': 'glass'
  };

  List<String> get unitList => [cap, drop, pinch, glass];
  List<String> get aliasesList => aliases.keys.toList();
}

class Unit {
  final String locale;
  VolumeUnit volumes;
  MassUnit masses;
  SmallQuantityUnit quantities;

  Unit(this.locale) :
    volumes = VolumeUnit(locale),
    masses = MassUnit(),
    quantities = SmallQuantityUnit(locale);

  List<String> getCompatibleUnits(Ingredient ingredient) {
    if (masses.unitList.contains(ingredient.unit) && ingredient.density == 0) return masses.unitList;
    else if (masses.unitList.contains(ingredient.unit) && ingredient.density != 0) return masses.unitList + volumes.unitList;
    else if (volumes.aliasesList.contains(ingredient.unit) && ingredient.density == 0) return volumes.unitList;
    else if (volumes.aliasesList.contains(ingredient.unit) && ingredient.density != 0) return volumes.unitList + masses.unitList;
    else return [ingredient.unit];
  }

  double getConversionFactor(Ingredient ingredient, String wantedUnit) {
    if (masses.unitList.contains(ingredient.unit) && masses.unitList.contains(wantedUnit)) {
      // mass conversion
      return masses.massConversionFactor(ingredient.unit, wantedUnit)!;
    }
    else if (volumes.aliasesList.contains(ingredient.unit) && volumes.unitList.contains(wantedUnit)) {
      // volume conversion
      return volumes.volumeConversionFactor(ingredient.unit, wantedUnit)!;
    }
    else if (ingredient.density != 0 && masses.unitList.contains(ingredient.unit) && volumes.unitList.contains(wantedUnit)) {
      // mass to volume conversion
      // mass to g -> / density*10 (g/cL) -> cL -> wanted volume
      return masses.massConversionFactor(ingredient.unit, masses.defaultUnit)!
          / (ingredient.density * 10) * volumes.volumeConversionFactor(volumes.defaultUnit, wantedUnit)!;
    }
    else if (ingredient.density != 0 && volumes.unitList.contains(ingredient.unit) && masses.unitList.contains(wantedUnit)) {
      // volume to mass conversion
      // volume to cL -> * density*10 (g/cL) -> g -> wanted mass
      return volumes.volumeConversionFactor(ingredient.unit, volumes.defaultUnit)!
          * (ingredient.density * 10) * masses.massConversionFactor(masses.defaultUnit, wantedUnit)!;
    }
    else {
      print("Impossible conversion");
      return 1;
    }
  }

  List<String> getAllUnits() {
    return ['none'] + volumes.unitList + masses.unitList + quantities.unitList;
  }
}

class DensityTable {
  late Map<String, double> translationToDensityMap;

  DensityTable() {
    translationToDensityMap = constructMap();
  }

  static const Map<String, List<String>> _translationTable = {
    "water": ["water","eau"],
    "oil": ["oil", "huile"],
    "cocoa": ["cocoa", "cacao"],
    "butter": ["butter", "beurre"],
    "flour": ["flour", "farine"],
    "sugar": ["sugar", "sucre"],
    "honey": ["honey", "miel"],
    "lemon": ["lemon", "citron"]
  };

  static const Map<String, double> _densityTable = {
    "water": 1,
    "oil": 0.8,
    "cocoa": 0.34,
    "butter": 0.9,
    "flour": 0.5,
    "sugar": 0.8,
    "honey": 1.42,
    "lemon": 1,
  };

  Map<String, double> constructMap() {
    Map<String, double> map = {};
    for (int i=0; i<_translationTable.keys.length; i++) {
      _translationTable.values.toList()[i].forEach((String ingredient) {
        map[ingredient] = _densityTable[_translationTable.keys.toList()[i]] ?? 0;
      });
    }
    return map;
  }

  double getDensity(String ingredient) {
    for (String densityIngredient in translationToDensityMap.keys) {
      if (ingredient.contains(densityIngredient)) {
        return translationToDensityMap[densityIngredient] ?? 0;
      }
    }
    return 0;
  }
}