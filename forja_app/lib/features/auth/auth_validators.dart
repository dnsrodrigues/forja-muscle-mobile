/// Valida o e-mail. Retorna mensagem de erro ou `null` se válido.
String? validateEmail(String value) {
  final v = value.trim();
  if (v.isEmpty) return 'Informe seu e-mail';
  final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!re.hasMatch(v)) return 'E-mail inválido';
  return null;
}

/// Valida a senha. Retorna mensagem de erro ou `null` se válida.
String? validatePassword(String value) {
  if (value.isEmpty) return 'Informe sua senha';
  if (value.length < 6) return 'A senha precisa de ao menos 6 caracteres';
  return null;
}
