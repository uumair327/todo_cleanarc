import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/domain/value_objects/user_id.dart';
import '../entities/category_entity.dart';

abstract class CategoryRepository {
  /// Create a new category
  Future<Either<Failure, CategoryEntity>> createCategory({
    required UserId userId,
    required String name,
    required String colorHex,
  });

  /// Update an existing category
  Future<Either<Failure, CategoryEntity>> updateCategory({
    required String id,
    String? name,
    String? colorHex,
  });

  /// Delete a category (soft delete)
  Future<Either<Failure, void>> deleteCategory(String id);

  /// Get all categories for a user
  Future<Either<Failure, List<CategoryEntity>>> getCategories(UserId userId);

  /// Get a single category by id
  Future<Either<Failure, CategoryEntity>> getCategoryById(String id);

  /// Get default categories
  Future<Either<Failure, List<CategoryEntity>>> getDefaultCategories();

  /// Sync categories with remote
  Future<Either<Failure, void>> syncCategories(UserId userId);
}
