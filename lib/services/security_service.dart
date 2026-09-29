import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Handles the local 4-digit passcode + fingerprint ("High Security") gate.
/// The passcode is hashed (SHA-256 + a per-device salt) before it ever touches
/// storage or the network — the plaintext passcode is never persisted.
class SecurityService {
  static SecurityService? _instance;
  static SecurityService get instance => _instance ??= SecurityService._();
  SecurityService._();

  static const _passcodeHashKey = 'high_security_passcode_hash';
  static const _saltKey = 'high_security_passcode_salt';
  static const _biometricEnabledKey = 'high_security_biometric_enabled';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> hasPasscode() async {
    final hash = await _storage.read(key: _passcodeHashKey);
    return hash != null && hash.isNotEmpty;
  }

  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _biometricEnabledKey);
    return value == 'true';
  }

  String _hash(String passcode, String salt) {
    return sha256.convert(utf8.encode('$salt:$passcode')).toString();
  }

  /// Sets a new 4-digit passcode. Returns the hash to sync to the backend.
  Future<String> setPasscode(String passcode) async {
    final salt = DateTime.now().microsecondsSinceEpoch.toString();
    final hash = _hash(passcode, salt);
    await _storage.write(key: _saltKey, value: salt);
    await _storage.write(key: _passcodeHashKey, value: hash);
    return hash;
  }

  Future<bool> verifyPasscode(String passcode) async {
    final salt = await _storage.read(key: _saltKey);
    final storedHash = await _storage.read(key: _passcodeHashKey);
    if (salt == null || storedHash == null) return false;
    return _hash(passcode, salt) == storedHash;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricEnabledKey, value: enabled.toString());
  }

  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// Prompts the OS fingerprint/biometric dialog. Returns true on success.
  Future<bool> authenticateWithBiometrics({
    String reason = 'Authenticate to access High Security options',
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  /// Clears the locally stored passcode/biometric preference, e.g. on logout.
  Future<void> clearLocalSecurity() async {
    await _storage.delete(key: _saltKey);
    await _storage.delete(key: _passcodeHashKey);
    await _storage.delete(key: _biometricEnabledKey);
  }
}
