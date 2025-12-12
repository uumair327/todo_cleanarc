import 'package:equatable/equatable.dart';
import '../../../../core/domain/value_objects/user_id.dart';
import '../../../../core/domain/value_objects/email.dart';

class UserEntity extends Equatable {
  final UserId id;
  final Email email;
  final String displayName;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    required this.createdAt,
    this.updatedAt,
  });

  UserEntity copyWith({
    UserId? id,
    Email? email,
    String? displayName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        createdAt,
        updatedAt,
      ];
}