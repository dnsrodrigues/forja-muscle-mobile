import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/router/redirect_logic.dart';

void main() {
  group('resolveRedirect', () {
    // ── Logado ───────────────────────────────────────────────────────────────
    test('logado em "/" vai para /today', () {
      expect(
        resolveRedirect(loggedIn: true, onboardingSeen: true, location: '/'),
        '/today',
      );
    });

    test('logado já em /today permanece (null)', () {
      expect(
        resolveRedirect(
            loggedIn: true, onboardingSeen: true, location: '/today'),
        isNull,
      );
    });

    test('logado já em /week permanece (null)', () {
      expect(
        resolveRedirect(
            loggedIn: true, onboardingSeen: true, location: '/week'),
        isNull,
      );
    });

    test('logado em /auth é mandado para /today', () {
      expect(
        resolveRedirect(
            loggedIn: true, onboardingSeen: true, location: '/auth'),
        '/today',
      );
    });

    test('logado em /home (legado) é mandado para /today', () {
      expect(
        resolveRedirect(
            loggedIn: true, onboardingSeen: true, location: '/home'),
        '/today',
      );
    });

    // ── Deslogado ─────────────────────────────────────────────────────────────
    test('deslogado sem onboarding em "/" vai para /onboarding', () {
      expect(
        resolveRedirect(
            loggedIn: false, onboardingSeen: false, location: '/'),
        '/onboarding',
      );
    });

    test('deslogado sem onboarding já em /onboarding permanece (null)', () {
      expect(
        resolveRedirect(
            loggedIn: false,
            onboardingSeen: false,
            location: '/onboarding'),
        isNull,
      );
    });

    test('deslogado sem onboarding tentando /auth volta para /onboarding',
        () {
      expect(
        resolveRedirect(
            loggedIn: false, onboardingSeen: false, location: '/auth'),
        '/onboarding',
      );
    });

    test('deslogado com onboarding visto em "/" vai para /auth', () {
      expect(
        resolveRedirect(
            loggedIn: false, onboardingSeen: true, location: '/'),
        '/auth',
      );
    });

    test('deslogado com onboarding visto já em /auth permanece (null)', () {
      expect(
        resolveRedirect(
            loggedIn: false, onboardingSeen: true, location: '/auth'),
        isNull,
      );
    });

    test('deslogado tentando /today é mandado para /auth', () {
      expect(
        resolveRedirect(
            loggedIn: false, onboardingSeen: true, location: '/today'),
        '/auth',
      );
    });

    test('deslogado tentando /week é mandado para /auth', () {
      expect(
        resolveRedirect(
            loggedIn: false, onboardingSeen: true, location: '/week'),
        '/auth',
      );
    });

    test('deslogado tentando /home (legado) é mandado para /auth', () {
      expect(
        resolveRedirect(
            loggedIn: false, onboardingSeen: true, location: '/home'),
        '/auth',
      );
    });
  });
}
