import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/router/redirect_logic.dart';

void main() {
  group('resolveRedirect', () {
    test('logado em "/" vai para /home', () {
      expect(
        resolveRedirect(loggedIn: true, onboardingSeen: true, location: '/'),
        '/home',
      );
    });

    test('logado já em /home permanece (null)', () {
      expect(
        resolveRedirect(loggedIn: true, onboardingSeen: true, location: '/home'),
        isNull,
      );
    });

    test('logado em /auth é mandado para /home', () {
      expect(
        resolveRedirect(loggedIn: true, onboardingSeen: true, location: '/auth'),
        '/home',
      );
    });

    test('deslogado sem onboarding em "/" vai para /onboarding', () {
      expect(
        resolveRedirect(loggedIn: false, onboardingSeen: false, location: '/'),
        '/onboarding',
      );
    });

    test('deslogado sem onboarding já em /onboarding permanece (null)', () {
      expect(
        resolveRedirect(loggedIn: false, onboardingSeen: false, location: '/onboarding'),
        isNull,
      );
    });

    test('deslogado tentando /auth sem ter visto onboarding volta para /onboarding', () {
      expect(
        resolveRedirect(loggedIn: false, onboardingSeen: false, location: '/auth'),
        '/onboarding',
      );
    });

    test('deslogado com onboarding visto em "/" vai para /auth', () {
      expect(
        resolveRedirect(loggedIn: false, onboardingSeen: true, location: '/'),
        '/auth',
      );
    });

    test('deslogado com onboarding visto já em /auth permanece (null)', () {
      expect(
        resolveRedirect(loggedIn: false, onboardingSeen: true, location: '/auth'),
        isNull,
      );
    });

    test('deslogado tentando /home é mandado para /auth', () {
      expect(
        resolveRedirect(loggedIn: false, onboardingSeen: true, location: '/home'),
        '/auth',
      );
    });
  });
}
