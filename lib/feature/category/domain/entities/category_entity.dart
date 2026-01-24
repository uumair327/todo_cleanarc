import 'package:equatable/equatable.dart';
import '../../../../core/domain/value_objects/user_id.dart';

class CategoryEntity extends Equatable {
  final String id;
  final UserId userId;
  final String name;
  final String colorHex;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  const CategoryEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.colorHex,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  CategoryEntity copyWith({
    String? id,
    UserId? userId,
    String? name,
    String? colorHex,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object> get props => [
        id,
        userId,
        name,
        colorHex,
        isDefault,
        createdAt,
        updatedAt,
        isDeleted,
      ];
}
