import 'package:hive/hive.dart';
import '../../domain/entities/user_entity.dart';
import '../../../../core/utils/typedef.dart';
import '../../../../core/domain/value_objects/user_id.dart';
import '../../../../core/domain/value_objects/email.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String email;
  
  @HiveField(2)
  String displayName;
  
  @HiveField(3)
  DateTime createdAt;
  
  @HiveField(4)
  DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(DataMap json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  DataMap toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: UserId.fromString(id),
      email: Email.fromString(email),
      displayName: displayName,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id.toString(),
      email: entity.email.toString(),
      displayName: entity.displayName,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}