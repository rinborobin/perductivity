import '../../domain/entities/category_entity.dart';

abstract class CategoryRepository {
  Future<List<CategoryEntity>> getAllCategories();
  Future<CategoryEntity?> getCategoryById(int id);
  Future<int> createCategory(CategoryEntity category);
  Future<bool> updateCategory(int id, CategoryEntity category);
  Future<bool> deleteCategory(int id);
  Stream<List<CategoryEntity>> watchAllCategories();
}
