import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/database_provider.dart';
import '../../data/datasource/category_datasource.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/repositories/category_repository.dart';

final categoryDataSourceProvider = Provider<CategoryDataSource>((ref) {
  final db = ref.watch(databaseProvider);
  return CategoryDataSource(db);
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final dataSource = ref.watch(categoryDataSourceProvider);
  return CategoryRepositoryImpl(dataSource);
});
