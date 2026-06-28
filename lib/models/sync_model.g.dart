// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OperationAdapter extends TypeAdapter<Operation> {
  @override
  final int typeId = 13;

  @override
  Operation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Operation(
      type: fields[1] as OperationType,
      object: fields[2] as DatabaseObject,
      id: fields[0] as String,
      targetBookId: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Operation obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.object)
      ..writeByte(3)
      ..write(obj.targetBookId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OperationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OperationQueueAdapter extends TypeAdapter<OperationQueue> {
  @override
  final int typeId = 14;

  @override
  OperationQueue read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OperationQueue()..queue = (fields[0] as List).cast<String>();
  }

  @override
  void write(BinaryWriter writer, OperationQueue obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.queue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OperationQueueAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OperationTypeAdapter extends TypeAdapter<OperationType> {
  @override
  final int typeId = 12;

  @override
  OperationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return OperationType.create;
      case 1:
        return OperationType.delete;
      case 2:
        return OperationType.update;
      default:
        return OperationType.create;
    }
  }

  @override
  void write(BinaryWriter writer, OperationType obj) {
    switch (obj) {
      case OperationType.create:
        writer.writeByte(0);
        break;
      case OperationType.delete:
        writer.writeByte(1);
        break;
      case OperationType.update:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OperationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
