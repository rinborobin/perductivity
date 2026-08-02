import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasource/category_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryDataSource _dataSource;

  CategoryRepositoryImpl(this._dataSource);

  @override
  Future<List<CategoryEntity>> getAllCategories() async {
    final models = await _dataSource.getAllCategories();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<CategoryEntity?> getCategoryById(int id) async {
    final model = await _dataSource.getCategoryById(id);
    return model?.toEntity();
  }

  @override
  Future<int> createCategory(CategoryEntity category) async {
    final model = CategoryModel.fromEntity(category);
    return await _dataSource.createCategory(model);
  }

  @override
  Future<bool> updateCategory(int id, CategoryEntity category) async {
    final model = CategoryModel.fromEntity(category);
    return await _dataSource.updateCategory(id, model);
  }

  @override
  Future<bool> deleteCategory(int id) async {
    return await _dataSource.deleteCategory(id);
  }

  @override
  Stream<List<CategoryEntity>> watchAllCategories() {
    return _dataSource.watchAllCategories().map(
          (models) => models.map((m) => m.toEntity()).toList(),
        );
  }
}
