import 'package:hive/hive.dart';

  part 'model.g.dart';

@HiveType(typeId: 9)
enum OperationType {
  @HiveField(0)
  create,
  @HiveField(1)
  delete,
  @HiveField(2)
  update
}

@HiveType(typeId: 8)
class Operation extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  OperationType type;
  @HiveField(2)
  DatabaseObject object;

  Operation({required this.type, required this.object, required this.id});

  dynamic getTypedObject() {
    if (object is AppUser) {
      return object as AppUser;
    }
    else if (object is Book) {
      return object as Book;
    }
    else if (object is Recipe) {
      return object as Recipe;
    }
  }
}


@HiveType(typeId: 7)
class OperationQueue extends HiveObject {
  @HiveField(0)
  List<String> queue = [];

  OperationQueue();

  void addOperation(String operationId) {
    queue.add(operationId);
    save();
    
    print('added');
    print(length());
  }

  String? getFirstOperationId() {
    if (queue.isNotEmpty ) {
      String id = queue.removeAt(0);
      save();
      return id;
    }
    return null;
  }

  int length() {
    return queue.length;
  }
}

class DatabaseObject {}

@HiveType(typeId: 0)
class AppUser extends HiveObject implements DatabaseObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String email;
  @HiveField(3)
  List<String> favoriteRecipes;
  @HiveField(4)
  DateTime? lastUpdate;

  AppUser({
    this.id = '',
    required this.name,
    required this.email,
    this.favoriteRecipes = const [],
    this.lastUpdate
  }) {
    lastUpdate ??= DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'favoriteRecipes': favoriteRecipes,
      'lastUpdate': lastUpdate!.toString()
    };
  }

  Map<String, String> toFormField() => {
    'name': name,
    'email': email,
    'favoriteRecipes': favoriteRecipes.toString()
  };

  factory AppUser.fromJson(Map<String, dynamic> json) {
    // send the DocumentSnapshot of the current user
    final List<String> snapFav = [];
    for (String recipeUid in json['favoriteRecipes']) {
      snapFav.add(recipeUid);
    }
    return AppUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      favoriteRecipes: snapFav,
      lastUpdate: DateTime.parse(json['lastUpdate'])
    );
  }
}

@HiveType(typeId: 1)
class Book extends HiveObject implements DatabaseObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  List<String> recipeUids;
  @HiveField(3)
  List<String> users;
  @HiveField(4)
  Map<String, int> access;
  @HiveField(5)
  List<String> bookIngredients;
  @HiveField(6)
  List<String> tags;
  @HiveField(7)
  DateTime? lastUpdate;

  Book({
    required this.id,
    required this.name,
    required this.recipeUids,
    required this.users,
    required this.access,
    this.tags = const [],
    this.bookIngredients = const [],
    this.lastUpdate
  }) {
    lastUpdate ??= DateTime.now();
  }

  Map<String,dynamic> toJson() {
    return {
      'name': name,
      'recipes': recipeUids,
      'access': access,
      'users': users,
      'lastUpdate': lastUpdate.toString()
    };
  }

  Map<String,String> toFormField() => {
    'id': id,
    'name': name,
    'recipes': recipeUids.toString(),
    'access': access.toString(),
    'users': users.toString()
  };

  factory Book.fromJson(Map<String, dynamic> data, {id=""}) {
    // parse access
    Map<String, int> access = {};
    for (String userUid in data['access'].keys.toList()) {
      access[userUid] = data['access'][userUid];
    }

    return Book(
      id: id,
      name: data['name'],
      users: List.generate(data['users'].length, (index) => data['users'][index] as String),
      access: access,
      recipeUids: List.generate(data['recipeUids'].length, (index) => data['recipeUids'][index] as String),
      lastUpdate: DateTime.parse(data['lastUpdate'])
    );
  }
}

@HiveType(typeId: 2)
class Recipe extends HiveObject implements DatabaseObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  List<String> pictures;
  @HiveField(3)
  int preparationTime;
  @HiveField(4)
  int cookingTime;
  @HiveField(5)
  int waitingTime;
  @HiveField(6)
  List<String> tags;
  @HiveField(7)
  int quantity;
  @HiveField(8)
  String quantityType;
  @HiveField(9)
  List<Ingredient> recipeIngredients;
  @HiveField(10)
  List<RecipeStep> steps;
  @HiveField(11)
  List<Variant> variants;
  @HiveField(12)
  DateTime creationDate;
  @HiveField(13)
  DateTime? lastUpdate;

  Recipe(
  {
    required this.id,
    required this.name,
    this.pictures=const [],
    required this.preparationTime,
    required this.cookingTime,
    required this.waitingTime,
    required this.tags,
    required this.quantity,
    this.quantityType = "",
    required this.recipeIngredients,
    required this.steps,
    this.variants=const [],
    required this.creationDate,
    this.lastUpdate
  }) {
    lastUpdate ??= DateTime.now();
  }

  // factory Recipe.fromDocument(DocumentSnapshot snapshot) {
  //   Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
  //   return Recipe.fromJson(data, id: snapshot.id);
  // }

  factory Recipe.fromJson(Map<String, dynamic> data, {String id=""}) {
    // parse ingredients
    List<Ingredient> snapIngredients = [];
    for (Map<String, dynamic> ingredient in data['recipeIngredients']) {
      snapIngredients.add(
          Ingredient(
              name: ingredient['name'],
              quantity: double.parse(ingredient['quantity'].toString()),
              unit: ingredient['unit'],
              density: double.parse(ingredient['density'].toString())
          )
      );
    }

    // parse tags
    // List<Tag> snapTags = [];
    // for (Map<String, dynamic> tag in data['tags']) {
    //   snapTags.add(
    //     Tag(
    //       name: tag['name'],
    //       index: tag['index']
    //     )
    //   );
    // }

    // parse Steps
    List<RecipeStep> snapSteps = [];
    for (Map<String, dynamic> step in data['steps']) {
      snapSteps.add(
        RecipeStep(
          step: step['step'],
          time: int.parse(step['time'].toString())
        )
      );
    }

    return Recipe(
      id: id,
      pictures: List.generate(data['pictures'].length, (index) => data['pictures'][index] as String),
      name: data['name'],
      preparationTime: data['preparationTime'],
      cookingTime: data['cookingTime'],
      waitingTime: data['waitingTime'],
      tags: List.generate(data['tags'].length, (index) => data['tags'][index] as String),
      quantity: data['quantity'],
      quantityType: data['quantityType'] ?? "",
      recipeIngredients: snapIngredients,
      steps: snapSteps,
      variants: List.generate(data['variants'].length, (index) => Variant.fromDocument(data['variants'][index])),
      creationDate: DateTime.parse(data['creationDate']),
      lastUpdate: DateTime.parse(data['lastUpdate']),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'pictures': pictures,
    'preparationTime': preparationTime,
    'cookingTime': cookingTime,
    'waitingTime': waitingTime,
    'tags': tags,
    'quantity': quantity,
    'quantityType': quantityType,
    'recipeIngredients': List<Map>.generate(recipeIngredients.length, (index) => recipeIngredients[index].toJson()),
    'steps': List<Map>.generate(steps.length, (index) => steps[index].toJson()),
    'variants': List<Map>.generate(variants.length, (index) => variants[index].toJson()),
    'creationDate': creationDate,
    'lastUpdate': lastUpdate
  };

  Map<String,String> toFormField() => {
    'id': id,
    'name': name,
    'pictures': pictures.toString(),
    'preparationTime': preparationTime.toString(),
    'cookingTime': cookingTime.toString(),
    'waitingTime': waitingTime.toString(),
    'tags': tags.toString(),
    'quantity': quantity.toString(),
    'quantityType': quantityType,
    'recipeIngredients': List<Map>.generate(recipeIngredients.length, (index) => recipeIngredients[index].toJson()).toString(),
    'steps': List<Map>.generate(steps.length, (index) => steps[index].toJson()).toString(),
    'variants': variants.toString()
  };

  void copy(Recipe recipe) {
    pictures = recipe.pictures;
    name = recipe.name;
    preparationTime = recipe.preparationTime;
    cookingTime = recipe.cookingTime;
    waitingTime = recipe.waitingTime;
    tags = recipe.tags;
    quantity = recipe.quantity;
    quantityType = recipe.quantityType;
    recipeIngredients = recipe.recipeIngredients;
    steps = recipe.steps;
    variants = recipe.variants;
  }

  int getTotalTime() {
    return preparationTime + cookingTime + waitingTime;
  }
}

@HiveType(typeId: 3)
class Variant extends HiveObject {
  @HiveField(0)
  String userUid;
  @HiveField(1)
  String variant;

  Variant({
    required this.variant,
    required this.userUid
  });

  Map<String, dynamic> toJson() => {
    "userUid": userUid,
    "variant": variant
  };

  factory Variant.fromDocument(Map<String, dynamic> data) {
    return Variant(
      variant: data['variant'] as String,
      userUid: data['userUid'] as String
    );
  }
}

@HiveType(typeId: 4)
class RecipeStep extends HiveObject {
  @HiveField(0)
  String step;
  @HiveField(1)
  int time;

  RecipeStep({
    required this.step,
    this.time=0
  });

  Map<String, dynamic> toJson() => {
    'step': step,
    'time': time
  };
}

@HiveType(typeId: 5)
class Ingredient extends HiveObject {
  @HiveField(0)
  String name;
  @HiveField(1)
  double quantity;
  @HiveField(2)
  String unit;
  @HiveField(3)
  double density;

  Ingredient({
    required this.name,
    required this.quantity,
    required this.unit,
    this.density=0.0
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'quantity': quantity,
    'unit': unit,
    'density': density
  };
}

@HiveType(typeId: 6)
class Tag extends HiveObject {
  @HiveField(0)
  String name;
  @HiveField(1)
  int index;

  Tag({
    required this.name,
    required this.index
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'index': index
  };
}

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

