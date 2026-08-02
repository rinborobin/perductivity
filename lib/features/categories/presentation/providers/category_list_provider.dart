import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category_entity.dart';
import 'category_providers.dart';

class CategoryListNotifier extends StateNotifier<AsyncValue<List<CategoryEntity>>> {
  final CategoryRepository _repository;

  CategoryListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    state = const AsyncValue.loading();
    try {
      final categories = await _repository.getAllCategories();
      state = AsyncValue.data(categories);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createCategory({
    required String name,
    required String color,
    required String icon,
  }) async {
    try {
      await _repository.createCategory(
        CategoryEntity(name: name, color: color, icon: icon),
      );
      await loadCategories();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateCategory({
    required int id,
    required String name,
    required String color,
    required String icon,
  }) async {
    try {
      await _repository.updateCategory(
        id,
        CategoryEntity(name: name, color: color, icon: icon),
      );
      await loadCategories();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _repository.deleteCategory(id);
      await loadCategories();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final categoryListProvider =
    StateNotifierProvider<CategoryListNotifier, AsyncValue<List<CategoryEntity>>>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return CategoryListNotifier(repository);
});
