import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:forja_app/features/auth/auth_messages.dart';

void main() {
  test('credenciais inválidas → mensagem amigável', () {
    final msg = mapAuthErrorToMessage(
      const AuthException('Invalid login credentials'),
    );
    expect(msg, 'E-mail ou senha incorretos');
  });

  test('e-mail já registrado → mensagem amigável', () {
    final msg = mapAuthErrorToMessage(
      const AuthException('User already registered'),
    );
    expect(msg, 'Este e-mail já está em uso');
  });

  test('erro genérico (não-AuthException) → mensagem de conexão', () {
    final msg = mapAuthErrorToMessage(Exception('socket'));
    expect(msg, contains('conexão'));
  });
}
