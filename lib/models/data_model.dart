import 'package:hive/hive.dart';

import 'update_model.dart';

  part 'data_model.g.dart';

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
      'name': name,
      'email': email,
      'favoriteRecipes': favoriteRecipes
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    // send the DocumentSnapshot of the current user
    final List<String> snapFav = [];
    for (String recipeId in json['favoriteRecipes']) {
      snapFav.add(recipeId);
    }
    return AppUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      favoriteRecipes: snapFav,
      lastUpdate: DateTime.parse(json['lastUpdate'])
    );
  }

  void copyFromUser(AppUser user) {
    name = user.name;
    email = user.email;
    favoriteRecipes = [...user.favoriteRecipes];
  }

  void copyFromUpdate(UserUpdate userUpdate) {
    name = userUpdate.name ?? name;
    email = userUpdate.email ?? email;
    favoriteRecipes = userUpdate.favoriteRecipes != null ? [...userUpdate.favoriteRecipes!] : favoriteRecipes;
  }
}

@HiveType(typeId: 1)
class Book extends HiveObject implements DatabaseObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  List<String> recipeIds;
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
    required this.recipeIds,
    required this.users,
    required this.access,
    this.tags = const [],
    this.bookIngredients = const [],
    this.lastUpdate
  }) {
    lastUpdate ??= DateTime.now();
  }

  Map<String,String> toJson() => {
    'id': id,
    'name': name,
    'recipeIds': recipeIds.toString(),
    'access': access.toString(),
    'users': users.toString()
  };

  factory Book.fromJson(Map<String, dynamic> data) {
    // parse access
    Map<String, int> access = {};
    for (String userId in data['access'].keys.toList()) {
      access[userId] = data['access'][userId];
    }

    return Book(
      id: data['id'],
      name: data['name'],
      users: List.generate(data['users'].length, (index) => data['users'][index] as String),
      access: access,
      recipeIds: List.generate(data['recipeIds'].length, (index) => data['recipeIds'][index] as String),
      lastUpdate: DateTime.parse(data['lastUpdate'])
    );
  }

  factory Book.fromBookCopy(Book book) {
    return Book(
      id: book.id,
      name: book.name,
      access: book.access,
      recipeIds: [...book.recipeIds],
      users: [...book.users],
      lastUpdate: book.lastUpdate
    );
  }

  void copyFromBook(Book book) {
    name = book.name;
    users = [...book.users];
    recipeIds = [...book.recipeIds];
    access = book.access;
    lastUpdate = book.lastUpdate;
  }

  void copyFromUpdate(BookUpdate bookUpdate) {
    name = bookUpdate.name ?? name;
    recipeIds = bookUpdate.recipeIds != null ? [...bookUpdate.recipeIds!] : recipeIds;
    access = bookUpdate.access ?? access;
    users = bookUpdate.users != null ? [...bookUpdate.users!] : users;
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
  @HiveField(14)
  bool isDirty;
  @HiveField(15)
  String? initId;

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
    this.lastUpdate,
    this.isDirty=true
  }) {
    lastUpdate ??= DateTime.now();
    initId = id;
  }

  // factory Recipe.fromDocument(DocumentSnapshot snapshot) {
  //   Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
  //   return Recipe.fromJson(data, id: snapshot.id);
  // }

  factory Recipe.fromJson(Map<String, dynamic> data) {
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
      id: data['id'],
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
      lastUpdate: DateTime.parse(data['lastUpdate'])
    );
  }

  factory Recipe.fromRecipeCopy(Recipe recipe) {
    return Recipe(
      id: recipe.id,
      pictures: [...recipe.pictures],
      name: recipe.name,
      preparationTime: recipe.preparationTime,
      cookingTime: recipe.cookingTime,
      waitingTime: recipe.waitingTime,
      tags: [...recipe.tags],
      quantity: recipe.quantity,
      quantityType: recipe.quantityType,
      recipeIngredients: [...recipe.recipeIngredients],
      steps: [...recipe.steps],
      variants: [...recipe.variants],
      creationDate: recipe.creationDate,
      lastUpdate: recipe.lastUpdate
    );
  }

  Map<String,String> toJson() => {
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

  void copyFromRecipe(Recipe recipe) {
    pictures = [...recipe.pictures];
    name = recipe.name;
    preparationTime = recipe.preparationTime;
    cookingTime = recipe.cookingTime;
    waitingTime = recipe.waitingTime;
    tags = [...recipe.tags];
    quantity = recipe.quantity;
    quantityType = recipe.quantityType;
    recipeIngredients = [...recipe.recipeIngredients];
    steps = [...recipe.steps];
    variants = [...recipe.variants];
    lastUpdate = recipe.lastUpdate;
  }

  void copyFromUpdate(RecipeUpdate recipeUpdate) {
    pictures = recipeUpdate.pictures != null ? [...recipeUpdate.pictures!] : pictures;
    name = recipeUpdate.name ?? name;
    preparationTime = recipeUpdate.preparationTime ?? preparationTime;
    cookingTime = recipeUpdate.cookingTime ?? cookingTime;
    waitingTime = recipeUpdate.waitingTime ?? waitingTime;
    tags = recipeUpdate.tags != null ? [...recipeUpdate.tags!] : tags;
    quantity = recipeUpdate.quantity ?? quantity;
    quantityType = recipeUpdate.quantityType ?? quantityType;
    recipeIngredients = recipeUpdate.recipeIngredients != null ? [...recipeUpdate.recipeIngredients!] : recipeIngredients;
    steps = recipeUpdate.steps != null ? [...recipeUpdate.steps!] : steps;
    variants = recipeUpdate.variants != null ? [...recipeUpdate.variants!] : variants;
  }

  int getTotalTime() {
    return preparationTime + cookingTime + waitingTime;
  }
}

@HiveType(typeId: 3)
class Variant extends HiveObject {
  @HiveField(0)
  String userId;
  @HiveField(1)
  String variant;
  @HiveField(2)
  String initials;

  Variant({
    required this.variant,
    required this.userId,
    required this.initials
  });

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "variant": variant,
    "initials": initials
  };

  factory Variant.fromDocument(Map<String, dynamic> data) {
    return Variant(
      variant: data['variant'] as String,
      userId: data['userId'] as String,
      initials: data['initials'] as String
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

@HiveType(typeId: 7)
class RecipeImage implements DatabaseObject {
  @HiveField(0)
  String path;
  @HiveField(1)
  String recipeId;
  @HiveField(2)
  String imageId;

  RecipeImage({required this.path, required this.recipeId, required this.imageId});
}