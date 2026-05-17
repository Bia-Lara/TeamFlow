import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../../features/profile/data/user.entity.dart';
import '../../../security/password_hash.dart' as pw_hash;

class SqliteBackend {
  SqliteBackend._internal();
  static final SqliteBackend instance = SqliteBackend._internal();

  Database? _db;

  Future<Database> get _database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    // Initialize FFI for desktop platforms (Windows, Linux, macOS)
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
    }

    String dbPath = join(Directory.current.path, 'team_flow.db');

    final factory = Platform.isWindows || Platform.isLinux || Platform.isMacOS
        ? databaseFactoryFfi
        : openDatabase;

    return await (factory is DatabaseFactory
        ? (factory).openDatabase(
            dbPath,
            options: OpenDatabaseOptions(
              version: 1,
              onCreate: (db, version) async {
                await db.execute('''
                  CREATE TABLE IF NOT EXISTS users (
                    id TEXT PRIMARY KEY,
                    name TEXT,
                    email TEXT UNIQUE,
                    password TEXT,
                    groupIds TEXT
                  )
                ''');
              },
            ),
          )
        : (factory as Function)(
            dbPath,
            version: 1,
            onCreate: (db, v) async {
              await db.execute('''
                CREATE TABLE IF NOT EXISTS users (
                  id TEXT PRIMARY KEY,
                  name TEXT,
                  email TEXT UNIQUE,
                  password TEXT,
                  groupIds TEXT
                )
              ''');
            },
          ));
  }

  Future<User> register(User user) async {
    final db = await _database;

    final email = user.email?.toLowerCase();
    if (email == null || email.isEmpty) throw Exception('E-mail inválido');

    final exists = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [email],
    );

    if (exists.isNotEmpty) throw Exception('E-mail já cadastrado');

    final id = DateTime.now().millisecondsSinceEpoch.toString();

    // Hash password with salt before storing
    final pw = user.password ?? '';
    final hashed = pw_hash.generateSaltedHash(pw);
    final pwStore =
        jsonEncode({'salt': hashed['salt'], 'hash': hashed['hash']});

    final map = {
      'id': id,
      'name': user.name,
      'email': user.email,
      'password': pwStore,
      'groupIds': jsonEncode(user.groupIds ?? []),
    };

    await db.insert('users', map);

    return user.copyWith(id: id, groupIds: user.groupIds ?? []);
  }

  Future<User?> getByEmail(String email) async {
    final db = await _database;
    final res = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (res.isEmpty) return null;

    final row = res.first;
    return User(
      id: row['id'] as String?,
      name: row['name'] as String?,
      email: row['email'] as String?,
      password: null,
      groupIds: (row['groupIds'] as String?) != null &&
              (row['groupIds'] as String).isNotEmpty
          ? List<String>.from(jsonDecode(row['groupIds'] as String))
          : [],
    );
  }

  Future<List<User>> allUsers() async {
    final db = await _database;
    final res = await db.query('users');

    return res
        .map((row) => User(
              id: row['id'] as String?,
              name: row['name'] as String?,
              email: row['email'] as String?,
              password: null,
              groupIds: (row['groupIds'] as String?) != null &&
                      (row['groupIds'] as String).isNotEmpty
                  ? List<String>.from(jsonDecode(row['groupIds'] as String))
                  : [],
            ))
        .toList();
  }

  Future<User?> getById(String id) async {
    final db = await _database;
    final res = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (res.isEmpty) return null;

    final row = res.first;
    return User(
      id: row['id'] as String?,
      name: row['name'] as String?,
      email: row['email'] as String?,
      password: null,
      groupIds: (row['groupIds'] as String?) != null &&
              (row['groupIds'] as String).isNotEmpty
          ? List<String>.from(jsonDecode(row['groupIds'] as String))
          : [],
    );
  }

  Future<User> updateUser(User user) async {
    final db = await _database;

    if (user.id == null || user.id!.isEmpty) {
      throw Exception('ID do usuário é obrigatório');
    }

    final exists = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [user.id],
    );

    if (exists.isEmpty) throw Exception('Usuário não encontrado');

    // Check if new email is not already taken (if email was changed)
    if (user.email != null && user.email!.isNotEmpty) {
      final emailExists = await db.query(
        'users',
        where: 'LOWER(email) = ? AND id != ?',
        whereArgs: [user.email!.toLowerCase(), user.id],
      );

      if (emailExists.isNotEmpty) throw Exception('E-mail já cadastrado');
    }

    final map = {
      'name': user.name,
      'email': user.email,
      'groupIds': jsonEncode(user.groupIds ?? []),
      // Note: password is NOT updated here, use separate method for that
    };

    await db.update(
      'users',
      map,
      where: 'id = ?',
      whereArgs: [user.id],
    );

    return user;
  }

  Future<void> deleteUser(String userId) async {
    final db = await _database;

    final exists = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (exists.isEmpty) throw Exception('Usuário não encontrado');

    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<bool> verifyPassword(String userId, String password) async {
    final db = await _database;

    final res = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      columns: ['password'],
    );

    if (res.isEmpty) throw Exception('Usuário não encontrado');

    final pwStore = res.first['password'] as String?;
    if (pwStore == null || pwStore.isEmpty) return false;

    final stored = jsonDecode(pwStore) as Map<String, dynamic>;
    return pw_hash.verifyPassword(
        password, stored['salt'] as String, stored['hash'] as String);
  }

  Future<User> login(String email, String password) async {
    final db = await _database;

    // Find user by email (case-insensitive)
    final res = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (res.isEmpty) throw Exception('E-mail ou senha incorretos');

    final row = res.first;
    final userId = row['id'] as String?;
    final pwStore = row['password'] as String?;

    if (userId == null) throw Exception('Erro ao autenticar usuário');
    if (pwStore == null || pwStore.isEmpty) {
      throw Exception('E-mail ou senha incorretos');
    }

    // Verify password
    final stored = jsonDecode(pwStore) as Map<String, dynamic>;
    final isPasswordValid = pw_hash.verifyPassword(
      password,
      stored['salt'] as String,
      stored['hash'] as String,
    );

    if (!isPasswordValid) throw Exception('E-mail ou senha incorretos');

    // Return user without password
    return User(
      id: row['id'] as String?,
      name: row['name'] as String?,
      email: row['email'] as String?,
      password: null,
      groupIds: (row['groupIds'] as String?) != null &&
              (row['groupIds'] as String).isNotEmpty
          ? List<String>.from(jsonDecode(row['groupIds'] as String))
          : [],
    );
  }
}
