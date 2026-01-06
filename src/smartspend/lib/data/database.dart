import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';

part 'database.g.dart';

// Users table definition
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text().unique()();
  TextColumn get passwordHash => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Database class
@DriftDatabase(tables: [Users])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Get user by username
  Future<User?> getUserByUsername(String username) async {
    return (select(users)..where((u) => u.username.equals(username)))
        .getSingleOrNull();
  }

  // Create new user
  Future<int> createUser(String username, String passwordHash) async {
    return into(users).insert(
      UsersCompanion.insert(
        username: username,
        passwordHash: passwordHash,
      ),
    );
  }

  // Check if username exists
  Future<bool> usernameExists(String username) async {
    final user = await getUserByUsername(username);
    return user != null;
  }

  // Validate login
  Future<User?> validateLogin(String username, String passwordHash) async {
    return (select(users)
          ..where((u) =>
              u.username.equals(username) & u.passwordHash.equals(passwordHash)))
        .getSingleOrNull();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'smartspend.db'));
    
    // Print the database path for easy access
    debugPrint('═══════════════════════════════════════════════');
    debugPrint('📁 DATABASE PATH:');
    debugPrint('   ${file.path}');
    debugPrint('═══════════════════════════════════════════════');
    
    return NativeDatabase(file);
  });
}
