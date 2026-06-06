import 'package:shared_preferences/shared_preferences.dart';

/// Lembra se o usuário já viu o onboarding (persiste no aparelho).
class OnboardingPrefs {
  static const _key = 'onboarding_visto';

  static Future<bool> isSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  static Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
