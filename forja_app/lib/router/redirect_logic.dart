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
    if (location == '/' || inOnboarding || inAuth) return '/home';
    return null;
  }

  // A partir daqui: NÃO está logado.
  if (!onboardingSeen) {
    return inOnboarding ? null : '/onboarding';
  }

  // Onboarding já visto e não logado → tela de login.
  return inAuth ? null : '/auth';
}
