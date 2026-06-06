/// Conteúdo de um slide do onboarding. A palavra em destaque (accent) é
/// separada para receber a cor de acento no título.
class OnboardingSlide {
  final String eyebrow;
  final String titleBefore;
  final String titleAccent;
  final String body;

  const OnboardingSlide({
    required this.eyebrow,
    required this.titleBefore,
    required this.titleAccent,
    required this.body,
  });
}

const onboardingSlides = <OnboardingSlide>[
  OnboardingSlide(
    eyebrow: 'FORJA · 01 / 03',
    titleBefore: 'REGISTRE CADA ',
    titleAccent: 'SÉRIE',
    body: 'Anote cargas, repetições e descanso direto do celular, em segundos.',
  ),
  OnboardingSlide(
    eyebrow: 'FORJA · 02 / 03',
    titleBefore: 'ACOMPANHE SEU ',
    titleAccent: 'PROGRESSO',
    body: 'Veja sua evolução de carga e volume com gráficos claros.',
  ),
  OnboardingSlide(
    eyebrow: 'FORJA · 03 / 03',
    titleBefore: 'TREINE NO SEU ',
    titleAccent: 'RITMO',
    body: 'Cronômetro de descanso e treinos offline, onde você estiver.',
  ),
];
