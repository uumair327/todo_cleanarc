import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/domain/value_objects/user_id.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/hive_category_datasource.dart';
import '../datasources/supabase_category_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final SupabaseCategoryDataSource remoteDataSource;
  final HiveCategoryDataSource localDataSource;
  final NetworkInfo networkInfo;
  final Uuid uuid;

  CategoryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  @override
  Future<Either<Failure, CategoryEntity>> createCategory({
    required UserId userId,
    required String name,
    required String colorHex,
  }) async {
    try {
      final now = DateTime.now();
      final categoryModel = CategoryModel(
        id: uuid.v4(),
        userId: userId.value,
        name: name,
        colorHex: colorHex,
        isDefault: false,
        createdAt: now,
        updatedAt: now,
        isDeleted: false,
      );

      // Cache locally first
      await localDataSource.cacheCategory(categoryModel);

      // Try to sync with remote if online
      if (await networkInfo.isConnected) {
        try {
          final remoteCategory = await remoteDataSource.createCategory(categoryModel);
          await localDataSource.cacheCategory(remoteCategory);
          return Right(remoteCategory.toEntity());
        } catch (e) {
          // If remote fails, return local version
          return Right(categoryModel.toEntity());
        }
      }

      return Right(categoryModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to create category: $e'));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> updateCategory({
    required String id,
    String? name,
    String? colorHex,
  }) async {
    try {
      // Get existing category from cache
      final cachedCategory = await localDataSource.getCachedCategory(id);
      if (cachedCategory == null) {
        return const Left(CacheFailure(message: 'Category not found'));
      }

      final updatedCategory = cachedCategory.copyWith(
        name: name ?? cachedCategory.name,
        colorHex: colorHex ?? cachedCategory.colorHex,
        updatedAt: DateTime.now(),
      );

      // Update local cache
      await localDataSource.cacheCategory(updatedCategory);

      // Try to sync with remote if online
      if (await networkInfo.isConnected) {
        try {
          final remoteCategory = await remoteDataSource.updateCategory(updatedCategory);
          await localDataSource.cacheCategory(remoteCategory);
          return Right(remoteCategory.toEntity());
        } catch (e) {
          // If remote fails, return local version
          return Right(updatedCategory.toEntity());
        }
      }

      return Right(updatedCategory.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update category: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      // Soft delete in local cache
      await localDataSource.deleteCachedCategory(id);

      // Try to sync with remote if online
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.deleteCategory(id);
        } catch (e) {
          // If remote fails, local delete is still valid
        }
      }

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to delete category: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories(UserId userId) async {
    try {
      // Try to get from remote if online
      if (await networkInfo.isConnected) {
        try {
          final remoteCategories = await remoteDataSource.getCategories(userId.value);
          await localDataSource.cacheCategories(remoteCategories);
          return Right(remoteCategories.map((model) => model.toEntity()).toList());
        } catch (e) {
          // Fall back to cache if remote fails
        }
      }

      // Get from local cache
      final cachedCategories = await localDataSource.getCachedCategories(userId.value);
      return Right(cachedCategories.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get categories: $e'));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> getCategoryById(String id) async {
    try {
      // Try cache first
      final cachedCategory = await localDataSource.getCachedCategory(id);
      if (cachedCategory != null) {
        return Right(cachedCategory.toEntity());
      }

      // Try remote if online
      if (await networkInfo.isConnected) {
        final remoteCategory = await remoteDataSource.getCategoryById(id);
        await localDataSource.cacheCategory(remoteCategory);
        return Right(remoteCategory.toEntity());
      }

      return const Left(CacheFailure(message: 'Category not found'));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get category: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getDefaultCategories() async {
    try {
      if (await networkInfo.isConnected) {
        final defaultCategories = await remoteDataSource.getDefaultCategories();
        return Right(defaultCategories.map((model) => model.toEntity()).toList());
      }
      return const Left(ServerFailure(message: 'No internet connection'));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get default categories: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> syncCategories(UserId userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(ServerFailure(message: 'No internet connection'));
      }

      // Get remote categories
      final remoteCategories = await remoteDataSource.getCategories(userId.value);
      
      // Update local cache
      await localDataSource.cacheCategories(remoteCategories);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to sync categories: $e'));
    }
  }
}
