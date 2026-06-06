import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/features/auth/auth_validators.dart';

void main() {
  group('validateEmail', () {
    test('vazio retorna mensagem', () {
      expect(validateEmail(''), isNotNull);
    });
    test('sem @ é inválido', () {
      expect(validateEmail('joao.com'), isNotNull);
    });
    test('válido retorna null', () {
      expect(validateEmail('joao@forja.com'), isNull);
    });
    test('ignora espaços nas pontas', () {
      expect(validateEmail('  joao@forja.com  '), isNull);
    });
  });

  group('validatePassword', () {
    test('vazia retorna mensagem', () {
      expect(validatePassword(''), isNotNull);
    });
    test('curta (<6) retorna mensagem', () {
      expect(validatePassword('123'), isNotNull);
    });
    test('com 6+ caracteres retorna null', () {
      expect(validatePassword('123456'), isNull);
    });
  });
}
