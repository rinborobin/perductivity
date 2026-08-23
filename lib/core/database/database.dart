import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100).unique()();
  TextColumn get color => text()();
  TextColumn get icon => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 150)();
  TextColumn get description => text().withLength(max: 5000).nullable()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get priority => textEnum<TaskPriority>()();
  TextColumn get status => textEnum<TaskStatus>()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get recurrence => text().withDefault(const Constant('none'))();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Subtasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get taskId => integer().references(Tasks, #id)();
  TextColumn get title => text().withLength(min: 1, max: 150)();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class TaskHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get taskId => integer().references(Tasks, #id)();
  TextColumn get action => text()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
}

enum TaskPriority { low, medium, high }

enum TaskStatus { todo, inProgress, completed, archived }

enum TaskRecurrence { none, daily, weekly, monthly }

@DriftDatabase(tables: [Categories, Tasks, Subtasks, TaskHistory])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await into(categories).insert(
          CategoriesCompanion.insert(
            name: 'Personal',
            color: '55B58A',
            icon: '58281',
          ),
        );
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          final existingCategory = await (select(categories)..limit(1)).get();
          if (existingCategory.isEmpty) {
            await into(categories).insert(
              CategoriesCompanion.insert(
                name: 'Personal',
                color: '55B58A',
                icon: '58281',
              ),
            );
          }
        }
        if (from < 3) {
          await m.addColumn(tasks, tasks.recurrence);
        }
        if (from < 4) {
          await m.createTable(subtasks);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'perductivity.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
