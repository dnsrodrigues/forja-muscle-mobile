// lib/router/app_router.dart
import 'package:go_router/go_router.dart';
import '../features/_dev/connection_check_page.dart';

/// Rotas do app. Nesta fase, só a tela de verificação.
/// As rotas reais (login, hoje, etc.) entram a partir da Fase 2.
final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const ConnectionCheckPage(),
    ),
  ],
);
