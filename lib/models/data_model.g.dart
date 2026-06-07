// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppUserAdapter extends TypeAdapter<AppUser> {
  @override
  final int typeId = 0;

  @override
  AppUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppUser(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      favoriteRecipes: (fields[3] as List).cast<String>(),
      lastUpdate: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AppUser obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.favoriteRecipes)
      ..writeByte(4)
      ..write(obj.lastUpdate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BookAdapter extends TypeAdapter<Book> {
  @override
  final int typeId = 1;

  @override
  Book read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Book(
      id: fields[0] as String,
      name: fields[1] as String,
      recipeIds: (fields[2] as List).cast<String>(),
      users: (fields[3] as List).cast<String>(),
      access: (fields[4] as Map).cast<String, AccessLevel>(),
      tags: (fields[6] as List).cast<Tag>(),
      bookIngredients: (fields[5] as List).cast<BookIngredient>(),
      lastUpdate: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Book obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.recipeIds)
      ..writeByte(3)
      ..write(obj.users)
      ..writeByte(4)
      ..write(obj.access)
      ..writeByte(5)
      ..write(obj.bookIngredients)
      ..writeByte(6)
      ..write(obj.tags)
      ..writeByte(7)
      ..write(obj.lastUpdate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecipeAdapter extends TypeAdapter<Recipe> {
  @override
  final int typeId = 2;

  @override
  Recipe read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Recipe(
      id: fields[0] as String,
      name: fields[1] as String,
      pictures: (fields[2] as List).cast<String>(),
      preparationTime: fields[3] as int,
      cookingTime: fields[4] as int,
      waitingTime: fields[5] as int,
      tags: (fields[6] as List).cast<String>(),
      quantity: fields[7] as int,
      quantityType: fields[8] as String,
      recipeIngredients: (fields[9] as List).cast<Ingredient>(),
      steps: (fields[10] as List).cast<RecipeStep>(),
      comments: (fields[11] as List).cast<Comment>(),
      creationDate: fields[12] as DateTime,
      lastUpdate: fields[13] as DateTime?,
      isDirty: fields[14] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Recipe obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.pictures)
      ..writeByte(3)
      ..write(obj.preparationTime)
      ..writeByte(4)
      ..write(obj.cookingTime)
      ..writeByte(5)
      ..write(obj.waitingTime)
      ..writeByte(6)
      ..write(obj.tags)
      ..writeByte(7)
      ..write(obj.quantity)
      ..writeByte(8)
      ..write(obj.quantityType)
      ..writeByte(9)
      ..write(obj.recipeIngredients)
      ..writeByte(10)
      ..write(obj.steps)
      ..writeByte(11)
      ..write(obj.comments)
      ..writeByte(12)
      ..write(obj.creationDate)
      ..writeByte(13)
      ..write(obj.lastUpdate)
      ..writeByte(14)
      ..write(obj.isDirty);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CommentAdapter extends TypeAdapter<Comment> {
  @override
  final int typeId = 3;

  @override
  Comment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Comment(
      comment: fields[1] as String,
      userId: fields[0] as String,
      initials: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Comment obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.comment)
      ..writeByte(2)
      ..write(obj.initials);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecipeStepAdapter extends TypeAdapter<RecipeStep> {
  @override
  final int typeId = 4;

  @override
  RecipeStep read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecipeStep(
      step: fields[0] as String,
      time: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, RecipeStep obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.step)
      ..writeByte(1)
      ..write(obj.time);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeStepAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IngredientAdapter extends TypeAdapter<Ingredient> {
  @override
  final int typeId = 5;

  @override
  Ingredient read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Ingredient(
      bookIngredientId: fields[0] as String,
      quantity: fields[1] as double?,
      unitOverride: fields[2] as String?,
      densityOverride: fields[3] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Ingredient obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.bookIngredientId)
      ..writeByte(1)
      ..write(obj.quantity)
      ..writeByte(2)
      ..write(obj.unitOverride)
      ..writeByte(3)
      ..write(obj.densityOverride);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IngredientAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BookIngredientAdapter extends TypeAdapter<BookIngredient> {
  @override
  final int typeId = 15;

  @override
  BookIngredient read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BookIngredient(
      id: fields[0] as String,
      name: fields[1] as String,
      unit: fields[2] as String,
      density: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, BookIngredient obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.unit)
      ..writeByte(3)
      ..write(obj.density);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookIngredientAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TagAdapter extends TypeAdapter<Tag> {
  @override
  final int typeId = 6;

  @override
  Tag read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Tag(
      id: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Tag obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecipeImageAdapter extends TypeAdapter<RecipeImage> {
  @override
  final int typeId = 7;

  @override
  RecipeImage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecipeImage(
      path: fields[0] as String,
      recipeId: fields[1] as String,
      imageId: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RecipeImage obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.path)
      ..writeByte(1)
      ..write(obj.recipeId)
      ..writeByte(2)
      ..write(obj.imageId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeImageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AccessLevelAdapter extends TypeAdapter<AccessLevel> {
  @override
  final int typeId = 8;

  @override
  AccessLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AccessLevel.read;
      case 1:
        return AccessLevel.write;
      case 2:
        return AccessLevel.own;
      default:
        return AccessLevel.read;
    }
  }

  @override
  void write(BinaryWriter writer, AccessLevel obj) {
    switch (obj) {
      case AccessLevel.read:
        writer.writeByte(0);
        break;
      case AccessLevel.write:
        writer.writeByte(1);
        break;
      case AccessLevel.own:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccessLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
