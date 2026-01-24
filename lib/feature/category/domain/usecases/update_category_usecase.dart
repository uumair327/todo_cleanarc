import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class UpdateCategoryUseCase {
  final CategoryRepository repository;

  UpdateCategoryUseCase(this.repository);

  Future<Either<Failure, CategoryEntity>> call({
    required String id,
    String? name,
    String? colorHex,
  }) async {
    // Validate name if provided
    if (name != null && name.trim().isEmpty) {
      return Left(ValidationFailure('Category name cannot be empty'));
    }

    // Validate color hex format if provided
    if (colorHex != null && !_isValidColorHex(colorHex)) {
      return Left(ValidationFailure('Invalid color format. Use hex format like #FF5733'));
    }

    return await repository.updateCategory(
      id: id,
      name: name?.trim(),
      colorHex: colorHex,
    );
  }

  bool _isValidColorHex(String colorHex) {
    final hexPattern = RegExp(r'^#?([0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$');
    return hexPattern.hasMatch(colorHex);
  }
}
