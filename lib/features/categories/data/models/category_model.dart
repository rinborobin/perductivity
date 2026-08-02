import '../../../../core/database/database.dart';
import '../../domain/entities/category_entity.dart';

class CategoryModel {
  final int? id;
  final String name;
  final String color;
  final String icon;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CategoryModel({
    this.id,
    required this.name,
    required this.color,
    required this.icon,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      color: entity.color,
      icon: entity.icon,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  factory CategoryModel.fromDrift(Category data) {
    return CategoryModel(
      id: data.id,
      name: data.name,
      color: data.color,
      icon: data.icon,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      color: color,
      icon: icon,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  CategoriesCompanion toCompanion() {
    return CategoriesCompanion.insert(
      name: name,
      color: color,
      icon: icon,
    );
  }
}
