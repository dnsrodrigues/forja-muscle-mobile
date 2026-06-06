/// Rotas que fazem parte do shell (requerem login).
const _shellRoutes = {'/today', '/week', '/library', '/profile'};

/// Decide para onde o "porteiro" deve mandar o usuário.
///
/// Retorna a rota de destino, ou `null` se já está no lugar certo.
/// Função PURA — sem dependências externas — para ser facilmente testável.
String? resolveRedirect({
  required bool loggedIn,
  required bool onboardingSeen,
  required String location,
}) {
  final inOnboarding = location == '/onboarding';
  final inAuth = location == '/auth';

  if (loggedIn) {
    // Usuário logado não deve ver splash, onboarding nem login.
    if (location == '/' || inOnboarding || inAuth || location == '/home') {
      return '/today';
    }
    return null; // /today, /week, /library, /profile → OK
  }

  // A partir daqui: NÃO está logado.
  // Proteger as rotas do shell.
  if (_shellRoutes.contains(location) || location == '/home') {
    return onboardingSeen ? '/auth' : '/onboarding';
  }

  if (!onboardingSeen) {
    return inOnboarding ? null : '/onboarding';
  }

  // Onboarding já visto e não logado → tela de login.
  return inAuth ? null : '/auth';
}
