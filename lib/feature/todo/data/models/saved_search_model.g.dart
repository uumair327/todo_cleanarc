// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_search_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedSearchModelAdapter extends TypeAdapter<SavedSearchModel> {
  @override
  final int typeId = 3;

  @override
  SavedSearchModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedSearchModel(
      id: fields[0] as String,
      name: fields[1] as String,
      searchQuery: fields[2] as String?,
      startDate: fields[3] as DateTime?,
      endDate: fields[4] as DateTime?,
      categories: (fields[5] as List?)?.cast<String>(),
      priorities: (fields[6] as List?)?.cast<String>(),
      minProgress: fields[7] as int?,
      maxProgress: fields[8] as int?,
      isCompleted: fields[9] as bool?,
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SavedSearchModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.searchQuery)
      ..writeByte(3)
      ..write(obj.startDate)
      ..writeByte(4)
      ..write(obj.endDate)
      ..writeByte(5)
      ..write(obj.categories)
      ..writeByte(6)
      ..write(obj.priorities)
      ..writeByte(7)
      ..write(obj.minProgress)
      ..writeByte(8)
      ..write(obj.maxProgress)
      ..writeByte(9)
      ..write(obj.isCompleted)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedSearchModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
