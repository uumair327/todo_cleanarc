import 'package:hive/hive.dart';
import '../models/category_model.dart';

abstract class HiveCategoryDataSource {
  Future<void> cacheCategory(CategoryModel category);
  Future<void> cacheCategories(List<CategoryModel> categories);
  Future<CategoryModel?> getCachedCategory(String id);
  Future<List<CategoryModel>> getCachedCategories(String userId);
  Future<void> deleteCachedCategory(String id);
  Future<void> clearCache();
}

class HiveCategoryDataSourceImpl implements HiveCategoryDataSource {
  static const String boxName = 'categories';
  final Box<CategoryModel> categoryBox;

  HiveCategoryDataSourceImpl(this.categoryBox);

  @override
  Future<void> cacheCategory(CategoryModel category) async {
    await categoryBox.put(category.id, category);
  }

  @override
  Future<void> cacheCategories(List<CategoryModel> categories) async {
    final Map<String, CategoryModel> categoryMap = {
      for (var category in categories) category.id: category
    };
    await categoryBox.putAll(categoryMap);
  }

  @override
  Future<CategoryModel?> getCachedCategory(String id) async {
    return categoryBox.get(id);
  }

  @override
  Future<List<CategoryModel>> getCachedCategories(String userId) async {
    return categoryBox.values
        .where((category) => category.userId == userId && !category.isDeleted)
        .toList();
  }

  @override
  Future<void> deleteCachedCategory(String id) async {
    final category = categoryBox.get(id);
    if (category != null) {
      final updatedCategory = category.copyWith(
        isDeleted: true,
        updatedAt: DateTime.now(),
      );
      await categoryBox.put(id, updatedCategory);
    }
  }

  @override
  Future<void> clearCache() async {
    await categoryBox.clear();
  }
}
