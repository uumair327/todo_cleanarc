import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/category_model.dart';

abstract class SupabaseCategoryDataSource {
  Future<CategoryModel> createCategory(CategoryModel category);
  Future<CategoryModel> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
  Future<List<CategoryModel>> getCategories(String userId);
  Future<CategoryModel> getCategoryById(String id);
  Future<List<CategoryModel>> getDefaultCategories();
}

class SupabaseCategoryDataSourceImpl implements SupabaseCategoryDataSource {
  final SupabaseClient client;
  static const String tableName = 'categories';

  SupabaseCategoryDataSourceImpl(this.client);

  @override
  Future<CategoryModel> createCategory(CategoryModel category) async {
    try {
      final response = await client
          .from(tableName)
          .insert(category.toJson())
          .select()
          .single();

      return CategoryModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to create category: $e');
    }
  }

  @override
  Future<CategoryModel> updateCategory(CategoryModel category) async {
    try {
      final response = await client
          .from(tableName)
          .update(category.toJson())
          .eq('id', category.id)
          .select()
          .single();

      return CategoryModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to update category: $e');
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      await client
          .from(tableName)
          .update({'is_deleted': true, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', id);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to delete category: $e');
    }
  }

  @override
  Future<List<CategoryModel>> getCategories(String userId) async {
    try {
      final response = await client
          .from(tableName)
          .select()
          .eq('user_id', userId)
          .eq('is_deleted', false)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get categories: $e');
    }
  }

  @override
  Future<CategoryModel> getCategoryById(String id) async {
    try {
      final response = await client
          .from(tableName)
          .select()
          .eq('id', id)
          .single();

      return CategoryModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get category: $e');
    }
  }

  @override
  Future<List<CategoryModel>> getDefaultCategories() async {
    try {
      final response = await client
          .from(tableName)
          .select()
          .eq('is_default', true)
          .eq('is_deleted', false)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Failed to get default categories: $e');
    }
  }
}
