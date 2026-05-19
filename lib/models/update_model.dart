import 'package:hive/hive.dart';

import 'data_model.dart';

  part 'update_model.g.dart';

@HiveType(typeId: 9)
class UserUpdate implements DatabaseObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String? name;
  @HiveField(2)
  String? email;
  @HiveField(3)
  List<String>? favoriteRecipes;
  @HiveField(4)
  late DateTime requestDate;

  UserUpdate({
    required this.id,
    this.name,
    this.email,
    this.favoriteRecipes
  }) {
    requestDate = DateTime.now().toUtc();
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'id': id,
      'requestDate': requestDate.toIso8601String()
    };

    if (name != null) {
      json['name'] = name!;
    }
    if (email != null) {
      json['email'] = email!;
    }
    if (favoriteRecipes != null) {
      json['favoriteRecipes'] = favoriteRecipes!;
    }

    return json;
  }
}

@HiveType(typeId: 10)
class BookUpdate implements DatabaseObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String? name;
  @HiveField(2)
  List<String>? recipeIds;
  @HiveField(3)
  List<String>? users;
  @HiveField(4)
  Map<String, AccessLevel>? access;
  @HiveField(5)
  List<BookIngredient>? bookIngredients;
  @HiveField(6)
  List<Tag>? tags;
  @HiveField(7)
  late DateTime requestDate;

  BookUpdate({
    required this.id,
    this.name,
    this.recipeIds,
    this.users,
    this.access,
    this.bookIngredients,
    this.tags
  }) {
    requestDate = DateTime.now().toUtc();
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'id': id,
      'requestDate': requestDate.toIso8601String()
    };

    if (name != null) {
      json['name'] = name!;
    }
    if (recipeIds != null) {
      json['recipeIds'] = recipeIds!;
    }
    if (access != null) {
      Map<String, int> jsonAccess = {};
      for (String userId in access!.keys.toList()) {
        jsonAccess[userId] = access![userId]!.index;
      }
      json['access'] = jsonAccess;
    }
    if (users != null) {
      json['users'] = users!;
    }
    if (tags != null) {
      json['tags'] = List<Map>.generate(tags!.length, (index) => tags![index].toJson());
    }
    if (bookIngredients != null) {
      json['bookIngredients'] = List<Map>.generate(bookIngredients!.length, (index) => bookIngredients![index].toJson());
    }

    return json;
  }
}

@HiveType(typeId: 11)
class RecipeUpdate implements DatabaseObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String? name;
  @HiveField(2)
  List<String>? pictures;
  @HiveField(3)
  int? preparationTime;
  @HiveField(4)
  int? cookingTime;
  @HiveField(5)
  int? waitingTime;
  @HiveField(6)
  List<String>? tags; // tags ids from book tag list
  @HiveField(7)
  int? quantity;
  @HiveField(8)
  String? quantityType;
  @HiveField(9)
  List<Ingredient>? recipeIngredients;
  @HiveField(10)
  List<RecipeStep>? steps;
  @HiveField(11)
  List<Variant>? variants;
  @HiveField(12)
  late DateTime requestDate;

  RecipeUpdate({
    required this.id,
    this.name,
    this.pictures,
    this.preparationTime,
    this.cookingTime,
    this.waitingTime,
    this.tags,
    this.quantity,
    this.quantityType,
    this.recipeIngredients,
    this.steps,
    this.variants
  }) {
    requestDate = DateTime.now().toUtc();
  }

  Map<String,dynamic> toJson() {
    Map<String,dynamic> json = {
      'id': id,
      'requestDate': requestDate.toIso8601String()
    };

    if (name != null && name != "") {
      json['name'] = name!;
    }
    if (pictures != null) {
      json['pictures'] = pictures!;
    }
    if (preparationTime != null) {
      json['preparationTime'] = preparationTime!;
    }
    if (cookingTime != null) {
      json['cookingTime'] = cookingTime!;
    }
    if (waitingTime != null) {
      json['waitingTime'] = waitingTime!;
    }
    if (tags != null) {
      json['tags'] = tags!;
    }
    if (quantity != null) {
      json['quantity'] = quantity!;
    }
    if (quantityType != null && quantityType != "") {
      json['quantityType'] = quantityType!;
    }
    if (recipeIngredients != null) {
      json['recipeIngredients'] = List<Map>.generate(recipeIngredients!.length, (index) => recipeIngredients![index].toJson());
    }
    if (steps != null) {
      json['steps'] = List<Map>.generate(steps!.length, (index) => steps![index].toJson());
    }
    if (variants != null) {
      json['variants'] = variants;
    }

    return json;
  } 
}
