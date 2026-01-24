import 'package:equatable/equatable.dart';
import '../../../../core/domain/value_objects/user_id.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryEvent {
  final UserId userId;

  const LoadCategories(this.userId);

  @override
  List<Object?> get props => [userId];
}

class CreateCategory extends CategoryEvent {
  final UserId userId;
  final String name;
  final String colorHex;

  const CreateCategory({
    required this.userId,
    required this.name,
    required this.colorHex,
  });

  @override
  List<Object?> get props => [userId, name, colorHex];
}

class UpdateCategory extends CategoryEvent {
  final String id;
  final String? name;
  final String? colorHex;

  const UpdateCategory({
    required this.id,
    this.name,
    this.colorHex,
  });

  @override
  List<Object?> get props => [id, name, colorHex];
}

class DeleteCategory extends CategoryEvent {
  final String id;

  const DeleteCategory(this.id);

  @override
  List<Object?> get props => [id];
}

class SyncCategories extends CategoryEvent {
  final UserId userId;

  const SyncCategories(this.userId);

  @override
  List<Object?> get props => [userId];
}
