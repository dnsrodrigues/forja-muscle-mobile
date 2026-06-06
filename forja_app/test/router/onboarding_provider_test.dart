import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:forja_app/router/auth_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('valor inicial vem do override', () {
    final container = ProviderContainer(
      overrides: [initialOnboardingSeenProvider.overrideWithValue(true)],
    );
    addTearDown(container.dispose);
    expect(container.read(onboardingSeenProvider), true);
  });

  test('markSeen muda o estado para true', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(
      overrides: [initialOnboardingSeenProvider.overrideWithValue(false)],
    );
    addTearDown(container.dispose);
    expect(container.read(onboardingSeenProvider), false);
    await container.read(onboardingSeenProvider.notifier).markSeen();
    expect(container.read(onboardingSeenProvider), true);
  });
}
