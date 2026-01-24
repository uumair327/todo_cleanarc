import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_category_usecase.dart';
import '../../domain/usecases/update_category_usecase.dart';
import '../../domain/usecases/delete_category_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/repositories/category_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategoriesUseCase getCategoriesUseCase;
  final CreateCategoryUseCase createCategoryUseCase;
  final UpdateCategoryUseCase updateCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;
  final CategoryRepository categoryRepository;

  CategoryBloc({
    required this.getCategoriesUseCase,
    required this.createCategoryUseCase,
    required this.updateCategoryUseCase,
    required this.deleteCategoryUseCase,
    required this.categoryRepository,
  }) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<CreateCategory>(_onCreateCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
    on<SyncCategories>(_onSyncCategories);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());

    final result = await getCategoriesUseCase(event.userId);

    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (categories) => emit(CategoryLoaded(categories)),
    );
  }

  Future<void> _onCreateCategory(
    CreateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());

    final result = await createCategoryUseCase(
      userId: event.userId,
      name: event.name,
      colorHex: event.colorHex,
    );

    await result.fold(
      (failure) async => emit(CategoryError(failure.message)),
      (category) async {
        // Reload categories after creation
        final categoriesResult = await getCategoriesUseCase(event.userId);
        categoriesResult.fold(
          (failure) => emit(CategoryError(failure.message)),
          (categories) => emit(CategoryOperationSuccess(
            message: 'Category created successfully',
            categories: categories,
          )),
        );
      },
    );
  }

  Future<void> _onUpdateCategory(
    UpdateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());

    final result = await updateCategoryUseCase(
      id: event.id,
      name: event.name,
      colorHex: event.colorHex,
    );

    await result.fold(
      (failure) async => emit(CategoryError(failure.message)),
      (category) async {
        // Reload categories after update
        final categoriesResult = await getCategoriesUseCase(category.userId);
        categoriesResult.fold(
          (failure) => emit(CategoryError(failure.message)),
          (categories) => emit(CategoryOperationSuccess(
            message: 'Category updated successfully',
            categories: categories,
          )),
        );
      },
    );
  }

  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    // Get current categories to determine userId for reload
    final currentState = state;
    if (currentState is! CategoryLoaded && currentState is! CategoryOperationSuccess) {
      emit(const CategoryError('Cannot delete category: no categories loaded'));
      return;
    }

    final categories = currentState is CategoryLoaded
        ? currentState.categories
        : (currentState as CategoryOperationSuccess).categories;

    if (categories.isEmpty) {
      emit(const CategoryError('Cannot delete category: no categories loaded'));
      return;
    }

    emit(CategoryLoading());

    final result = await deleteCategoryUseCase(event.id);

    await result.fold(
      (failure) async => emit(CategoryError(failure.message)),
      (_) async {
        // Reload categories after deletion
        final userId = categories.first.userId;
        final categoriesResult = await getCategoriesUseCase(userId);
        categoriesResult.fold(
          (failure) => emit(CategoryError(failure.message)),
          (categories) => emit(CategoryOperationSuccess(
            message: 'Category deleted successfully',
            categories: categories,
          )),
        );
      },
    );
  }

  Future<void> _onSyncCategories(
    SyncCategories event,
    Emitter<CategoryState> emit,
  ) async {
    final result = await categoryRepository.syncCategories(event.userId);

    await result.fold(
      (failure) async => emit(CategoryError(failure.message)),
      (_) async {
        // Reload categories after sync
        final categoriesResult = await getCategoriesUseCase(event.userId);
        categoriesResult.fold(
          (failure) => emit(CategoryError(failure.message)),
          (categories) => emit(CategoryLoaded(categories)),
        );
      },
    );
  }
}
