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
  TextColumn get securityQuestion => text()();
  TextColumn get securityAnswerHash => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Database class
@DriftDatabase(tables: [Users])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        // Add security question columns with default values
        await customStatement(
          'ALTER TABLE users ADD COLUMN security_question TEXT NOT NULL DEFAULT "What was the name of your first pet?"',
        );
        await customStatement(
          'ALTER TABLE users ADD COLUMN security_answer_hash TEXT NOT NULL DEFAULT ""',
        );
      }
    },
  );

  // Get user by username
  Future<User?> getUserByUsername(String username) async {
    return (select(
      users,
    )..where((u) => u.username.equals(username))).getSingleOrNull();
  }

  // Create new user
  Future<int> createUser(
    String username,
    String passwordHash,
    String securityQuestion,
    String securityAnswerHash,
  ) async {
    return into(users).insert(
      UsersCompanion.insert(
        username: username,
        passwordHash: passwordHash,
        securityQuestion: securityQuestion,
        securityAnswerHash: securityAnswerHash,
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
    return (select(users)..where(
          (u) =>
              u.username.equals(username) & u.passwordHash.equals(passwordHash),
        ))
        .getSingleOrNull();
  }

  // Update user password
  Future<void> updatePassword(String username, String newPasswordHash) async {
    await (update(users)..where((u) => u.username.equals(username))).write(
      UsersCompanion(passwordHash: Value(newPasswordHash)),
    );
  }

  // Validate security answer
  Future<bool> validateSecurityAnswer(
    String username,
    String answerHash,
  ) async {
    final user = await getUserByUsername(username);
    return user?.securityAnswerHash == answerHash;
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
