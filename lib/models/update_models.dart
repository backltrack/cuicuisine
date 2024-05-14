import 'model.dart';

class UserUpdate implements DatabaseObject {
  String id;
  String? name;
  String? email;
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

class BookUpdate implements DatabaseObject {
  String id;
  String? name;
  List<String>? recipeUids;
  List<String>? users;
  Map<String, int>? access;
  List<String>? bookIngredients;
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

class RecipeUpdate implements DatabaseObject {
  String id;
  String? name;
  List<String>? pictures;
  int? preparationTime;
  int? cookingTime;
  int? waitingTime;
  List<String>? tags;
  int? quantity;
  String? quantityType;
  List<Ingredient>? recipeIngredients;
  List<RecipeStep>? steps;
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

    if (name != null) {
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
    if (quantityType != null) {
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
