import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/domain/value_objects/user_id.dart';
import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class CreateCategoryUseCase {
  final CategoryRepository repository;

  CreateCategoryUseCase(this.repository);

  Future<Either<Failure, CategoryEntity>> call({
    required UserId userId,
    required String name,
    required String colorHex,
  }) async {
    // Validate name
    if (name.trim().isEmpty) {
      return Left(ValidationFailure('Category name cannot be empty'));
    }

    // Validate color hex format
    if (!_isValidColorHex(colorHex)) {
      return Left(ValidationFailure('Invalid color format. Use hex format like #FF5733'));
    }

    return await repository.createCategory(
      userId: userId,
      name: name.trim(),
      colorHex: colorHex,
    );
  }

  bool _isValidColorHex(String colorHex) {
    final hexPattern = RegExp(r'^#?([0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$');
    return hexPattern.hasMatch(colorHex);
  }
}
