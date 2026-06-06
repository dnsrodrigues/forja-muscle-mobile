# FORJA Mobile — Fase 2 (Entrada): Onboarding + Login/Cadastro — Documento de Design

**Versão:** 1.0
**Data:** 06 de junho de 2026
**Autor:** Denis Rodrigues (brainstorming com Claude Code)
**Status:** 🟡 Aguardando revisão do usuário
**Fase:** 2 de 12 — "Entrada"
**Branch:** `fase-2-entrada`

> Continuação do design geral em `docs/superpowers/specs/2026-06-03-forja-mobile-flutter-design.md`.
> Este documento detalha **apenas a Fase 2**. O próximo passo após aprovação é a skill
> **writing-plans**, que transforma este design num plano de implementação tarefa-a-tarefa.

---

## 1. Objetivo

Entregar a porta de entrada do app FORJA: as telas de **Onboarding** (boas-vindas, 3 passos)
e **Login/Cadastro** com autenticação real via Supabase Auth, mais a lógica de navegação
("porteiro") que decide qual tela o usuário vê ao abrir o app.

Ao final da fase, o app deve permitir: ver o onboarding na primeira vez, **criar uma conta**,
**fazer login**, permanecer logado entre aberturas do app, e **sair da conta** — tudo
comprovável de ponta a ponta rodando no Chrome.

---

## 2. Decisões deste brainstorming

| # | Decisão | Escolha |
|---|---------|---------|
| 1 | Animação da arte do Onboarding | **Shader completo** (fiel ao design — ondas com aberração cromática na cor de acento) |
| 2 | Confirmação de e-mail ao criar conta | **Sem confirmação** — usuário entra direto após o cadastro |
| 3 | Recuperação de senha ("Esqueceu?") | **Adiada** — link visível na UI, sem funcionalidade nesta fase |
| 4 | Arquitetura de navegação/auth | **Opção A** — porteiro central reativo (GoRouter `redirect` + Riverpod observando o estado de auth) |

### Fora de escopo nesta fase (YAGNI)
- Recuperação de senha funcional (apenas link decorativo).
- Login social Google/Apple (botões decorativos; ao tocar, exibem "em breve").
- Diferenciação de papel Aluno × Personal no roteamento (entra na Fase 3, quando as telas
  de cada perfil existirem). Nesta fase, todo usuário logado cai na tela inicial provisória.
- Dashboard real ("Hoje") — Fase 3.

---

## 3. Fluxo de navegação (o "porteiro")

Ao abrir, o app decide a rota com base em dois sinais:
1. **Existe sessão Supabase ativa?** (o `supabase_flutter` persiste a sessão automaticamente)
2. **O onboarding já foi visto?** (flag booleana em `shared_preferences`)

```
App abre
   │
   ├─ Sessão ativa? ───────── SIM ──→ /home  (tela inicial provisória)
   │
   └─ NÃO há sessão
        │
        ├─ onboarding_visto == false ──→ /onboarding ──(concluir/pular)──→ /auth
        │
        └─ onboarding_visto == true  ──→ /auth
```

- O onboarding aparece **apenas na primeira vez** (a flag persiste mesmo após logout).
- Concluir ou "Pular" o onboarding grava `onboarding_visto = true` e leva a `/auth`.
- **Reatividade:** ao logar, o porteiro redireciona para `/home`; ao sair, volta para `/auth`.
  Isso é feito com o `redirect` do GoRouter + um `refreshListenable` ligado ao stream de auth.

---

## 4. Telas

### 4.1 Onboarding (`/onboarding`)
Carrossel de 3 telas (`PageView`), seguindo a especificação visual do handoff (seção "1. Onboarding"):
- **Topo (~40% da altura):** arte com **shader animado** (ondas horizontais com aberração
  cromática tingidas na cor de acento), com fade para `bgDark` na base.
- **Eyebrow:** "FORJA · 0X / 03" em `accent` (Bebas Neue).
- **Título:** Bebas Neue 56, `height: 0.95`, com uma palavra-chave em `accent`.
- **Parágrafo:** descritivo em `textDim` (Space Grotesk).
- **Rodapé:** dots de paginação (ativo = pílula alongada `accent` ~26px) + "Pular";
  botão primário largura cheia "PRÓXIMO →" (na última tela: "COMEÇAR →").
- **Comportamento:** desliza com o dedo; "Pular" e "COMEÇAR" finalizam o onboarding.

**Conteúdo dos 3 slides** (texto definido em arquivo de dados próprio):
| # | Título (palavra em acento) | Parágrafo (resumo) |
|---|---|---|
| 1 | REGISTRE CADA **SÉRIE** | Anote cargas, repetições e descanso direto do celular, em segundos. |
| 2 | ACOMPANHE SEU **PROGRESSO** | Veja sua evolução de carga e volume com gráficos claros. |
| 3 | TREINE NO SEU **RITMO** | Cronômetro de descanso e treinos offline, onde você estiver. |

> Textos são provisórios e podem ser ajustados; ficam isolados em `onboarding_data.dart`
> para facilitar a edição.

### 4.2 Login / Cadastro (`/auth`)
Tela única com alternância (segmented control), seguindo o handoff (seção "2. Login / Cadastro"):
- **Banda superior (~200px):** shader + wordmark "FORJA." (Bebas Neue, ponto em `accent`),
  fade para `bg0`.
- **Segmented control:** "Entrar" | "Criar conta" (trilho `bg2`, item ativo `accent`).
- **Campos:**
  - Modo **Entrar:** Email, Senha (com link "Esqueceu?" em `accent`, decorativo).
  - Modo **Criar conta:** Email, Senha. (Sem campo de nome nesta fase — o perfil é
    complementado depois; manter enxuto.)
- **Botão primário:** "ENTRAR →" / "CRIAR CONTA →" (largura cheia).
- **Divisor "OU"** + dois `OutlinedButton` (Google / Apple) — decorativos ("em breve").
- **Rodapé:** texto de termos/privacidade (estático).

**Comportamento de autenticação:**
- **Entrar:** `supabase.auth.signInWithPassword(email, password)`.
- **Criar conta:** `supabase.auth.signUp(email, password)`. Como não há confirmação de e-mail,
  o cadastro retorna sessão ativa → o porteiro redireciona para `/home`.
- **Validação (antes de chamar o backend):** campos não vazios; formato de e-mail válido;
  senha com mínimo de 6 caracteres. Erros mostram borda `danger` + mensagem curta.
- **Estado "carregando":** o botão exibe spinner e fica desabilitado durante a chamada
  (evita duplo toque).
- **Erros do backend:** traduzidos para mensagens amigáveis em português
  (ex.: credenciais inválidas → "E-mail ou senha incorretos"; e-mail já cadastrado →
  "Este e-mail já está em uso"). Demais erros → mensagem genérica + opção de tentar de novo.

### 4.3 Tela inicial provisória (`/home`)
Tela temporária que **substitui** a `_dev/connection_check_page` como destino pós-login.
Existe só para comprovar o ciclo de auth de ponta a ponta; será substituída na Fase 3 pelo
Dashboard "Hoje" + navegação por abas.
- Mostra: wordmark "FORJA", o e-mail do usuário logado, um aviso
  "O Dashboard chega na Fase 3" e um botão **"Sair da conta"** (em `danger`).
- "Sair da conta": `supabase.auth.signOut()` → o porteiro volta para `/auth`.

---

## 5. Arquitetura e organização de arquivos

Estrutura *feature-first*, alinhada à "Arquitetura sugerida" do handoff:

```
lib/
├── core/
│   └── widgets/
│       ├── forja_primary_button.dart   # FilledButton FORJA (largura cheia + estado loading)
│       ├── forja_text_field.dart        # TextField FORJA (label, erro, foco em accent)
│       ├── forja_segmented.dart         # Segmented control "Entrar | Criar conta"
│       └── forja_shader_art.dart        # Widget reutilizável da arte animada (shader)
├── features/
│   ├── onboarding/
│   │   ├── onboarding_page.dart         # PageView com os 3 slides + rodapé
│   │   └── onboarding_data.dart         # conteúdo dos 3 slides (texto)
│   ├── auth/
│   │   ├── auth_page.dart               # UI login/cadastro (segmented + campos)
│   │   └── auth_controller.dart         # Riverpod: signIn/signUp/signOut + estado (AsyncValue)
│   └── home/
│       └── home_placeholder_page.dart   # tela inicial provisória
├── router/
│   ├── app_router.dart                  # GoRouter + redirect (o "porteiro")
│   └── auth_providers.dart              # providers de estado de auth (stream do Supabase)
├── services/
│   └── onboarding_prefs.dart            # wrapper de shared_preferences (flag onboarding_visto)
└── shaders/
    └── forja_wave.frag                  # shader GLSL das ondas (declarado no pubspec)

# Removido:
└── features/_dev/connection_check_page.dart   # cumpriu o papel; substituído por /home
```

### Pacote novo
- **`shared_preferences`** — persistência leve da flag `onboarding_visto`
  (e, futuramente, do tema na Fase 7).

### Gerência de estado (Riverpod)
- `authStateChangesProvider` — `StreamProvider` que escuta `supabase.auth.onAuthStateChange`.
- `authControllerProvider` — `AsyncNotifier`/`Notifier` que expõe `signIn`, `signUp`, `signOut`
  e o estado de carregamento/erro consumido pela `auth_page`.
- O `GoRouter` recebe um `refreshListenable` derivado do stream de auth para reagir a
  login/logout.

### Shader (arte animada)
- Arquivo `forja_wave.frag` (fragment shader GLSL) declarado em `pubspec.yaml` na seção
  `flutter: shaders:`.
- Carregado com `FragmentProgram.fromAsset` e animado por um `AnimationController` que
  alimenta o uniform de tempo (`uTime`), mais resolução e cor de acento como uniforms.
- Encapsulado em `forja_shader_art.dart` (recebe a cor de acento), reutilizado no Onboarding
  e na banda do Login. Inclui *fallback* gracioso (gradiente estático) caso o shader não
  compile em alguma plataforma.

---

## 6. Estados de UI (loading / erro / vazio)

- **Onboarding:** sem dependência de rede; estados triviais.
- **Auth:**
  - *Loading:* botão com spinner, campos desabilitados.
  - *Erro de validação:* borda `danger` + texto curto sob o campo.
  - *Erro de backend:* `SnackBar`/área de erro com mensagem amigável em PT-BR.
- **Home provisória:** exibe o e-mail da sessão; botão "Sair".

---

## 7. Testes

- **Widget tests:**
  - Onboarding avança pelos 3 slides e o botão final navega para `/auth`.
  - Auth alterna entre "Entrar" e "Criar conta".
  - Validação exibe erro para e-mail inválido e senha curta.
- **Verificação manual (Chrome):** criar conta nova, sair, logar de novo — ciclo completo,
  observando o redirecionamento do porteiro.
- **Regressão:** os testes existentes (`theme_test`, `smoke_test`) continuam passando
  (o `smoke_test` será ajustado, pois a tela inicial mudou).
- *Observação:* o login real depende do Supabase; os testes automáticos cobrem
  validação/navegação. A integração real é verificada manualmente no Chrome.

---

## 8. Critério de conclusão da fase

- App compila e roda no Chrome sem erros.
- Onboarding aparece na 1ª vez, é "pulável" e não reaparece depois.
- É possível criar conta, logar, permanecer logado ao reabrir, e sair.
- O porteiro redireciona corretamente em todos os casos.
- Testes (novos + existentes) passando.
- Tela `_dev/connection_check_page` removida.

---

## 9. Riscos e atenção

- **Shader (maior risco de esforço):** é a parte mais complexa. Mitigação: encapsular num
  widget isolado com *fallback* de gradiente estático; se o shader atrasar, o app não quebra.
- **Configuração do Supabase Auth:** assume-se que o cadastro por e-mail/senha **sem
  confirmação** está habilitado no projeto Supabase. Se estiver exigindo confirmação,
  ajustaremos a UI (tela "verifique seu e-mail") — verificar no início da implementação.
- **Persistência de sessão na web:** confirmar que a sessão do `supabase_flutter` persiste
  entre recargas no Chrome (comportamento padrão; validar no teste manual).

---

## 10. Comunicação

Desenvolvimento em **português brasileiro**, explicações simples (nível "15 anos"),
dizendo o que será feito antes e confirmando depois, com commits frequentes e mensagens claras.
