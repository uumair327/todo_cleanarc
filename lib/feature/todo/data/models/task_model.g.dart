// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskModelAdapter extends TypeAdapter<TaskModel> {
  @override
  final int typeId = 0;

  @override
  TaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      title: fields[2] as String,
      description: fields[3] as String,
      dueDate: fields[4] as DateTime,
      dueTime: fields[5] as String,
      category: fields[6] as String,
      priority: fields[7] as int,
      progressPercentage: fields[8] as int,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
      isDeleted: fields[11] as bool,
      needsSync: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.dueDate)
      ..writeByte(5)
      ..write(obj.dueTime)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.priority)
      ..writeByte(8)
      ..write(obj.progressPercentage)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.isDeleted)
      ..writeByte(12)
      ..write(obj.needsSync);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
