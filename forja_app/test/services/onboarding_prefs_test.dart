import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:forja_app/services/onboarding_prefs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('isSeen é false quando nada foi gravado', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await OnboardingPrefs.isSeen(), false);
  });

  test('markSeen grava e isSeen passa a ser true', () async {
    SharedPreferences.setMockInitialValues({});
    await OnboardingPrefs.markSeen();
    expect(await OnboardingPrefs.isSeen(), true);
  });
}
