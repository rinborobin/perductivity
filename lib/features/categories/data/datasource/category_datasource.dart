import 'package:drift/drift.dart';
import '../../../../core/database/database.dart';
import '../models/category_model.dart';

class CategoryDataSource {
  final AppDatabase _db;

  CategoryDataSource(this._db);

  Future<List<CategoryModel>> getAllCategories() async {
    final result = await _db.select(_db.categories).get();
    return result.map((e) => CategoryModel.fromDrift(e)).toList();
  }

  Future<CategoryModel?> getCategoryById(int id) async {
    final result = await (_db.select(
      _db.categories,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return result != null ? CategoryModel.fromDrift(result) : null;
  }

  Future<int> createCategory(CategoryModel category) async {
    return await _db.into(_db.categories).insert(category.toCompanion());
  }

  Future<bool> updateCategory(int id, CategoryModel category) async {
    final rowsAffected =
        await (_db.update(_db.categories)..where((t) => t.id.equals(id))).write(
          CategoriesCompanion(
            name: Value(category.name),
            color: Value(category.color),
            icon: Value(category.icon),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return rowsAffected > 0;
  }

  Future<bool> deleteCategory(int id) async {
    final rowsAffected = await (_db.delete(
      _db.categories,
    )..where((t) => t.id.equals(id))).go();
    return rowsAffected > 0;
  }

  Stream<List<CategoryModel>> watchAllCategories() {
    return _db
        .select(_db.categories)
        .watch()
        .map(
          (result) => result.map((e) => CategoryModel.fromDrift(e)).toList(),
        );
  }
}
