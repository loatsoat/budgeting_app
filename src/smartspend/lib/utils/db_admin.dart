import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../data/database.dart';

class DatabaseAdmin {
  static final AppDatabase _db = AppDatabase();

  // Get all users
  static Future<List<User>> getAllUsers() async {
    return await _db.select(_db.users).get();
  }

  // Delete a user by ID
  static Future<void> deleteUser(int userId) async {
    await (_db.delete(_db.users)..where((u) => u.id.equals(userId))).go();
  }

  // Get user count
  static Future<int> getUserCount() async {
    final users = await getAllUsers();
    return users.length;
  }

  // Clear all users (CAUTION!)
  static Future<void> clearAllUsers() async {
    await _db.delete(_db.users).go();
  }

  // Print database path
  static Future<String> getDatabasePath() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dbFolder.path, 'smartspend.db');
    
    debugPrint('📁 Database location:');
    debugPrint('   $dbPath');
    return dbPath;
  }

  // Show database stats
  static Future<void> showStats() async {
    final users = await getAllUsers();
    debugPrint('📊 Database Statistics:');
    debugPrint('   Total Users: ${users.length}');
    for (var user in users) {
      debugPrint('   - ID: ${user.id}, Username: ${user.username}, Created: ${user.createdAt}');
    }
  }
}

// Admin Screen Widget
class DatabaseAdminScreen extends StatefulWidget {
  const DatabaseAdminScreen({super.key});

  @override
  State<DatabaseAdminScreen> createState() => _DatabaseAdminScreenState();
}

class _DatabaseAdminScreenState extends State<DatabaseAdminScreen> {
  List<User> _users = [];
  bool _isLoading = true;
  String _dbPath = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadDbPath();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final users = await DatabaseAdmin.getAllUsers();
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  Future<void> _loadDbPath() async {
    final path = await DatabaseAdmin.getDatabasePath();
    setState(() => _dbPath = path);
  }

  Future<void> _deleteUser(int userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Benutzer löschen?'),
        content: const Text('Diese Aktion kann nicht rückgängig gemacht werden.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseAdmin.deleteUser(userId);
      _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Benutzer gelöscht')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datenbank Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
            tooltip: 'Aktualisieren',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Datenbank Info',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Pfad: $_dbPath'),
                        Text('Benutzer: ${_users.length}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Benutzer',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (_users.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Keine Benutzer vorhanden'),
                    ),
                  )
                else
                  ..._users.map((user) => Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(user.username[0].toUpperCase()),
                          ),
                          title: Text(user.username),
                          subtitle: Text(
                            'ID: ${user.id} • Erstellt: ${user.createdAt.toString().split('.')[0]}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteUser(user.id),
                          ),
                        ),
                      )),
              ],
            ),
    );
  }
}
