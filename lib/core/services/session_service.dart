import 'package:shared_preferences/shared_preferences.dart';

class SessionService {

  static const String guardianIdKey = "guardian_id";
  static const String emailKey = "guardian_email";
  static const String loginKey = "is_logged_in";

  /// Save session after successful login
  Future<void> saveSession({
    required String guardianId,
    required String email,
  }) async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      guardianIdKey,
      guardianId,
    );

    await prefs.setString(
      emailKey,
      email,
    );

    await prefs.setBool(
      loginKey,
      true,
    );
  }

  /// Clear session
  Future<void> clearSession() async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(guardianIdKey);
    await prefs.remove(emailKey);
    await prefs.remove(loginKey);
  }

  /// Check login status
  Future<bool> isLoggedIn() async {

    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(loginKey) ?? false;
  }

  /// Get Guardian ID
  Future<String?> getGuardianId() async {

    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(
      guardianIdKey,
    );
  }

  /// Get Guardian Email
  Future<String?> getEmail() async {

    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(
      emailKey,
    );
  }
}

final sessionService = SessionService();