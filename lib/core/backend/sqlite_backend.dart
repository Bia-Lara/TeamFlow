import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../features/profile/data/user.entity.dart';
import '../security/password_hash.dart';

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
        ? (factory as DatabaseFactory).openDatabase(
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
    final hashed = generateSaltedHash(pw);
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
              (row['groupIds'] as String)!.isNotEmpty
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
                      (row['groupIds'] as String)!.isNotEmpty
                  ? List<String>.from(jsonDecode(row['groupIds'] as String))
                  : [],
            ))
        .toList();
  }
}
