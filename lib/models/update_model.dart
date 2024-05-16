import 'package:hive/hive.dart';

import 'data_model.dart';

  part 'update_model.g.dart';

@HiveType(typeId: 10)
class UserUpdate implements DatabaseObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String? name;
  @HiveField(2)
  String? email;
  @HiveField(3)
  List<String>? favoriteRecipes;

  UserUpdate({
    required this.id,
    this.name,
    this.email,
    this.favoriteRecipes
  });

  Map<String, String> toJson() {
    Map<String, String> json = {
      'id': id
    };

    if (name != null) {
      json['name'] = name!;
    }
    if (email != null) {
      json['email'] = email!;
    }
    if (favoriteRecipes != null) {
      json['favoriteRecipes'] = favoriteRecipes!.toString();
    }

    return json;
  }
}

@HiveType(typeId: 11)
class BookUpdate implements DatabaseObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String? name;
  @HiveField(2)
  List<String>? recipeUids;
  @HiveField(3)
  List<String>? users;
  @HiveField(4)
  Map<String, int>? access;
  @HiveField(5)
  List<String>? bookIngredients;
  @HiveField(6)
  List<String>? tags;

  BookUpdate({
    required this.id,
    this.name,
    this.recipeUids,
    this.users,
    this.access,
    this.bookIngredients,
    this.tags
  });

  Map<String, String> toJson() {
    Map<String, String> json = {
      'id': id
    };

    if (name != null) {
      json['name'] = name!;
    }
    if (recipeUids != null) {
      json['recipeUids'] = recipeUids!.toString();
    }
    if (access != null) {
      json['access'] = access!.toString();
    }
    if (users != null) {
      json['users'] = users!.toString();
    }

    return json;
  }
}

@HiveType(typeId: 12)
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
  List<String>? tags;
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
  });

  Map<String,dynamic> toJson() {
    Map<String,dynamic> json = {
      'id': id
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
