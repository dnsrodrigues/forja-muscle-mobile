import 'package:supabase_flutter/supabase_flutter.dart';

/// Converte um erro de autenticação em uma mensagem clara em PT-BR.
String mapAuthErrorToMessage(Object error) {
  if (error is AuthException) {
    final msg = error.message.toLowerCase();
    if (msg.contains('invalid login credentials')) {
      return 'E-mail ou senha incorretos';
    }
    if (msg.contains('already registered') ||
        msg.contains('already been registered') ||
        msg.contains('user already')) {
      return 'Este e-mail já está em uso';
    }
    if (msg.contains('password')) {
      return 'Senha inválida (mínimo 6 caracteres)';
    }
    return 'Não foi possível concluir. Tente novamente.';
  }
  return 'Algo deu errado. Verifique sua conexão e tente de novo.';
}
