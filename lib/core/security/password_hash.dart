import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

String _randomSalt([int length = 16]) {
  final rnd = Random.secure();
  final bytes = List<int>.generate(length, (_) => rnd.nextInt(256));
  return base64UrlEncode(bytes);
}

Map<String, String> generateSaltedHash(String password) {
  final salt = _randomSalt();
  final bytes = utf8.encode('$salt$password');
  final digest = sha256.convert(bytes);
  final hash = base64UrlEncode(digest.bytes);
  return {'salt': salt, 'hash': hash};
}

bool verifyPassword(String password, String salt, String hash) {
  final bytes = utf8.encode('$salt$password');
  final digest = sha256.convert(bytes);
  return base64UrlEncode(digest.bytes) == hash;
}
