import 'package:hive/hive.dart';
import 'package:uuid/v4.dart';

import '../database/database_mgr.dart';
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
    lastUpdate ??= DateTime.now().toUtc();
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
  Map<String, AccessLevel> access;
  @HiveField(5)
  List<BookIngredient> bookIngredients;
  @HiveField(6)
  List<Tag> tags;
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
    lastUpdate ??= DateTime.now().toUtc();
  }

  Map<String,String> toJson() {
    return {
      'id': id,
      'name': name,
      'recipeIds': recipeIds.toString(),
      'access': Map<String, int>.fromEntries(access.entries.map((entry) => MapEntry(entry.key, entry.value.index))).toString(),
      'users': users.toString(),
      'tags': List<Map>.generate(tags.length, (index) => tags[index].toJson()).toString()
    };
  }

  factory Book.fromJson(Map<String, dynamic> data) {
    return Book(
      id: data['id'],
      name: data['name'],
      users: List.generate(data['users'].length, (index) => data['users'][index] as String),
      access: Map<String, AccessLevel>.fromEntries(Map<String, int>.from(data['access']).entries.map((entry) => MapEntry(entry.key, AccessLevel.values[entry.value]))),
      recipeIds: List.generate(data['recipeIds'].length, (index) => data['recipeIds'][index] as String),
      lastUpdate: DateTime.parse(data['lastUpdate']),
      tags: List.generate(data['tags'].length, (index) => Tag.fromJson(data['tags'][index])),
      bookIngredients: data['bookIngredients'] != null
          ? List.generate(data['bookIngredients'].length, (index) => BookIngredient.fromJson(data['bookIngredients'][index]))
          : [],
    );
  }

  factory Book.fromBookCopy(Book book) {
    return Book(
      id: book.id,
      name: book.name,
      access: book.access,
      recipeIds: [...book.recipeIds],
      users: [...book.users],
      lastUpdate: book.lastUpdate,
      tags: List.generate(book.tags.length, (index) => book.tags[index].copy()),
      bookIngredients: List.generate(book.bookIngredients.length, (index) => book.bookIngredients[index].copy()),
    );
  }

  void copyFromBook(Book book) {
    name = book.name;
    users = [...book.users];
    recipeIds = [...book.recipeIds];
    access = book.access;
    lastUpdate = book.lastUpdate;
    tags = List.generate(book.tags.length, (index) => book.tags[index].copy());
    bookIngredients = List.generate(book.bookIngredients.length, (index) => book.bookIngredients[index].copy());
  }

  void copyFromUpdate(BookUpdate bookUpdate) {
    name = bookUpdate.name ?? name;
    recipeIds = bookUpdate.recipeIds != null ? [...bookUpdate.recipeIds!] : recipeIds;
    access = bookUpdate.access ?? access;
    users = bookUpdate.users != null ? [...bookUpdate.users!] : users;
    tags = bookUpdate.tags != null ? List.generate(bookUpdate.tags!.length, (index) => bookUpdate.tags![index].copy()) : tags;
    bookIngredients = bookUpdate.bookIngredients != null ? List.generate(bookUpdate.bookIngredients!.length, (index) => bookUpdate.bookIngredients![index].copy()) : bookIngredients;
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
  List<String> tags; // tags ids from book tag list
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
    lastUpdate ??= DateTime.now().toUtc();
  }

  factory Recipe.fromJson(Map<String, dynamic> data) {
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
      recipeIngredients: List.generate(data['recipeIngredients'].length, (index) => Ingredient.fromJson(data['recipeIngredients'][index])),
      steps: List.generate(data['steps'].length, (index) => RecipeStep.fromJson(data['steps'][index])),
      variants: List.generate(data['variants'].length, (index) => Variant.fromJson(data['variants'][index])),
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
    recipeIngredients = List.generate(recipe.recipeIngredients.length, (index) => recipe.recipeIngredients[index].copy());
    steps = List.generate(recipe.steps.length, (index) => recipe.steps[index].copy());
    variants = List.generate(recipe.variants.length, (index) => recipe.variants[index].copy());
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
    recipeIngredients = recipeUpdate.recipeIngredients != null ? List.generate(recipeUpdate.recipeIngredients!.length, (index) => recipeUpdate.recipeIngredients![index].copy()) : recipeIngredients;
    steps = recipeUpdate.steps != null ? List.generate(recipeUpdate.steps!.length, (index) => recipeUpdate.steps![index].copy()) : steps;
    variants = recipeUpdate.variants != null ? List.generate(recipeUpdate.variants!.length, (index) => recipeUpdate.variants![index].copy()) : variants;
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

  factory Variant.fromJson(Map<String, dynamic> data) {
    return Variant(
      variant: data['variant'] as String,
      userId: data['userId'] as String,
      initials: data['initials'] as String
    );
  }

  Variant copy() {
    return Variant(variant: variant, userId: userId, initials: initials);
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

  factory RecipeStep.fromJson(Map<String, dynamic> data) {
    return RecipeStep(
      step: data['step'] as String,
      time: int.parse(data['time'].toString())
    );
  }

  RecipeStep copy() {
    return RecipeStep(step: step, time: time);
  }
}

@HiveType(typeId: 5)
class Ingredient extends HiveObject {
  @HiveField(0)
  String bookIngredientId;
  @HiveField(1)
  double? quantity;
  @HiveField(2)
  String? unitOverride;
  @HiveField(3)
  double? densityOverride;

  Ingredient({
    required this.bookIngredientId,
    required this.quantity,
    this.unitOverride,
    this.densityOverride
  });

  Map<String, dynamic> toJson() => {
    'bookIngredientId': bookIngredientId,
    'quantity': quantity,
    'unit': unitOverride,
    'density': densityOverride
  };

  factory Ingredient.fromJson(Map<String, dynamic> data) {
    return Ingredient(
      bookIngredientId: data['bookIngredientId'] as String,
      quantity: data['quantity'] != null ? double.tryParse(data['quantity'].toString()) : null,
      unitOverride: data['unit'] != null && data['unit'] != '' ? data['unit'] as String : null,
      densityOverride: data['density'] != null ? double.tryParse(data['density'].toString()) : null,
    );
  }

  Ingredient copy() {
    return Ingredient(bookIngredientId: bookIngredientId, quantity: quantity, unitOverride: unitOverride, densityOverride: densityOverride);
  }

  String getName() {
    return DatabaseMgr().localMgr.getBookIngredient(bookIngredientId)?.name ?? '';
  }

  String getUnit() {
    if (unitOverride != null && unitOverride != "") {
      return unitOverride!;
    } 
    return DatabaseMgr().localMgr.getBookIngredient(bookIngredientId)?.unit ?? '';
  }

  double getDensity() {
    if (densityOverride != null && densityOverride != 0) {
      return densityOverride!;
    }
    return DatabaseMgr().localMgr.getBookIngredient(bookIngredientId)?.density ?? 0.0;
  }
}

@HiveType(typeId: 15)
class BookIngredient extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String unit;
  @HiveField(3)
  double density;

  BookIngredient({
    required this.id,
    required this.name,
    required this.unit,
    this.density=0.0
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'unit': unit,
    'density': density
  };

  factory BookIngredient.fromJson(Map<String, dynamic> data) {
    return BookIngredient(
      id: data['id'] as String,
      name: data['name'] as String,
      unit: data['unit'] as String,
      density: double.parse(data['density'].toString())
    );
  }

  BookIngredient copy() {
    return BookIngredient(id: id, name: name, unit: unit, density: density);
  }
}

@HiveType(typeId: 6)
class Tag extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String category;

  Tag({
    required this.id,
    required this.name,
    required this.category
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category
  };

  factory Tag.fromJson(Map<String, dynamic> data) {
    return Tag(
      id: data['id'] as String,
      name: data['name'] as String,
      category: data['category'] as String
    );
  }

  factory Tag.newTag(String name, String category) {
    return Tag(id: UuidV4().generate(), name: name, category: category);
  }

  Tag copy() {
    return Tag(id: id, name: name, category: category);
  }
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

@HiveType(typeId: 8)
enum AccessLevel {
  @HiveField(0)
  read,
  @HiveField(1)
  write,
  @HiveField(2)
  own
}

class Result {
  bool result;
  String reason;

  Result({
    required this.result,
    this.reason = ''
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(result: json['result'], reason: json['reason'] ?? '');
  }
}