import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/widgets/forja_primary_button.dart';
import '../../core/widgets/forja_shader_art.dart';
import '../../router/auth_providers.dart';
import '../../theme/forja_colors.dart';
import 'onboarding_data.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == onboardingSlides.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(onboardingSeenProvider.notifier).markSeen();
    if (mounted) context.go('/auth');
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: ForjaColors.bg0,
      body: SafeArea(
        child: Column(
          children: [
            // Arte (shader) — ~40% da altura
            Expanded(
              flex: 4,
              child: ForjaShaderArt(accent: accent),
            ),
            // Conteúdo
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _controller,
                        itemCount: onboardingSlides.length,
                        onPageChanged: (i) => setState(() => _index = i),
                        itemBuilder: (context, i) {
                          final slide = onboardingSlides[i];
                          return SingleChildScrollView(
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                slide.eyebrow,
                                style: GoogleFonts.bebasNeue(
                                  fontSize: 13,
                                  letterSpacing: 2.0,
                                  color: accent,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                children: [
                                  Text(
                                    slide.titleBefore,
                                    style: textTheme.displayLarge,
                                  ),
                                  Text(
                                    slide.titleAccent,
                                    style: textTheme.displayLarge
                                        ?.copyWith(color: accent),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                slide.body,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 15,
                                  height: 1.5,
                                  color: ForjaColors.textDim,
                                ),
                              ),
                            ],
                          ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Rodapé: dots + Pular
                    Row(
                      children: [
                        for (int i = 0; i < onboardingSlides.length; i++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 6),
                            height: 6,
                            width: i == _index ? 26 : 6,
                            decoration: BoxDecoration(
                              color: i == _index ? accent : ForjaColors.bg3,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        const Spacer(),
                        TextButton(
                          onPressed: _finish,
                          child: Text(
                            'Pular',
                            style: GoogleFonts.spaceGrotesk(
                              color: ForjaColors.textDim,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ForjaPrimaryButton(
                      label: _isLast ? 'Começar →' : 'Próximo →',
                      onPressed: _next,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
