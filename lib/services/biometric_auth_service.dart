import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricAuthService {
  static final BiometricAuthService _instance = BiometricAuthService._internal();
  factory BiometricAuthService() => _instance;
  BiometricAuthService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();

  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricUserKey = 'biometric_user_id';

  /// Check if the device supports biometric authentication
  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } on PlatformException catch (e) {
      print('❌ Biometric check error: $e');
      return false;
    }
  }

  /// Get list of available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print('❌ Get biometrics error: $e');
      return [];
    }
  }

  /// Authenticate with biometrics
  Future<bool> authenticate({String reason = 'Authenticate to access Faith Klinik'}) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } on PlatformException catch (e) {
      print('❌ Authentication error: $e');
      return false;
    }
  }

  /// Check if biometric login is enabled for current user
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  /// Enable biometric login for a user
  Future<void> enableBiometric(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, true);
    await prefs.setString(_biometricUserKey, userId);
  }

  /// Disable biometric login
  Future<void> disableBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, false);
    await prefs.remove(_biometricUserKey);
  }

  /// Get the user ID stored for biometric login
  Future<String?> getBiometricUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_biometricEnabledKey) ?? false;
    if (!enabled) return null;
    return prefs.getString(_biometricUserKey);
  }

  /// Attempt biometric login — returns userId if successful
  Future<String?> biometricLogin() async {
    final userId = await getBiometricUserId();
    if (userId == null) return null;

    final authenticated = await authenticate(
      reason: 'Use Face ID or Touch ID to sign into Faith Klinik',
    );
    return authenticated ? userId : null;
  }

  /// Cancel any ongoing authentication
  Future<void> cancelAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } on PlatformException catch (e) {
      print('❌ Cancel auth error: $e');
    }
  }

  /// Get a human-readable name for the biometric type
  Future<String> getBiometricTypeName() async {
    final types = await getAvailableBiometrics();
    if (types.contains(BiometricType.face)) return 'Face ID';
    if (types.contains(BiometricType.fingerprint)) return 'Touch ID';
    if (types.contains(BiometricType.iris)) return 'Iris Recognition';
    return 'Biometric';
  }
}
