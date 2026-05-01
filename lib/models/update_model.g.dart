// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserUpdateAdapter extends TypeAdapter<UserUpdate> {
  @override
  final int typeId = 9;

  @override
  UserUpdate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserUpdate(
      id: fields[0] as String,
      name: fields[1] as String?,
      email: fields[2] as String?,
      favoriteRecipes: (fields[3] as List?)?.cast<String>(),
    )..requestDate = fields[4] as DateTime;
  }

  @override
  void write(BinaryWriter writer, UserUpdate obj) {
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
      ..write(obj.requestDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserUpdateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BookUpdateAdapter extends TypeAdapter<BookUpdate> {
  @override
  final int typeId = 10;

  @override
  BookUpdate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BookUpdate(
      id: fields[0] as String,
      name: fields[1] as String?,
      recipeIds: (fields[2] as List?)?.cast<String>(),
      users: (fields[3] as List?)?.cast<String>(),
      access: (fields[4] as Map?)?.cast<String, AccessLevel>(),
      bookIngredients: (fields[5] as List?)?.cast<BookIngredient>(),
      tags: (fields[6] as List?)?.cast<Tag>(),
    )..requestDate = fields[7] as DateTime;
  }

  @override
  void write(BinaryWriter writer, BookUpdate obj) {
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
      ..write(obj.requestDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookUpdateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecipeUpdateAdapter extends TypeAdapter<RecipeUpdate> {
  @override
  final int typeId = 11;

  @override
  RecipeUpdate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecipeUpdate(
      id: fields[0] as String,
      name: fields[1] as String?,
      pictures: (fields[2] as List?)?.cast<String>(),
      preparationTime: fields[3] as int?,
      cookingTime: fields[4] as int?,
      waitingTime: fields[5] as int?,
      tags: (fields[6] as List?)?.cast<String>(),
      quantity: fields[7] as int?,
      quantityType: fields[8] as String?,
      recipeIngredients: (fields[9] as List?)?.cast<Ingredient>(),
      steps: (fields[10] as List?)?.cast<RecipeStep>(),
      variants: (fields[11] as List?)?.cast<Variant>(),
    )..requestDate = fields[12] as DateTime;
  }

  @override
  void write(BinaryWriter writer, RecipeUpdate obj) {
    writer
      ..writeByte(13)
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
      ..write(obj.variants)
      ..writeByte(12)
      ..write(obj.requestDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeUpdateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
