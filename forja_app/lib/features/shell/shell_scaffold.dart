import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/accent_theme.dart';
import '../../theme/forja_colors.dart';

/// Scaffold principal com BottomAppBar de 4 abas + FAB central.
/// Recebe [tabIndex] (0=Hoje, 1=Semana, 2=Exercícios, 3=Perfil) e [child]
/// vindo do ShellRoute do GoRouter.
class ShellScaffold extends ConsumerWidget {
  final int tabIndex;
  final Widget child;

  const ShellScaffold({
    super.key,
    required this.tabIndex,
    required this.child,
  });

  static const _routes = ['/today', '/week', '/library', '/profile'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = ref.watch(accentProvider);

    void onTabTap(int index) => context.go(_routes[index]);

    return Scaffold(
      backgroundColor: ForjaColors.bg0,
      body: child,
      bottomNavigationBar: BottomAppBar(
        color: ForjaColors.bg1,
        height: 64,
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            _TabItem(
              icon: Icons.home_rounded,
              label: 'Hoje',
              index: 0,
              currentIndex: tabIndex,
              accent: accent.accent,
              onTap: () => onTabTap(0),
            ),
            _TabItem(
              icon: Icons.calendar_today_rounded,
              label: 'Semana',
              index: 1,
              currentIndex: tabIndex,
              accent: accent.accent,
              onTap: () => onTabTap(1),
            ),
            const SizedBox(width: 72), // espaço do FAB
            _TabItem(
              icon: Icons.fitness_center_rounded,
              label: 'Exercícios',
              index: 2,
              currentIndex: tabIndex,
              accent: accent.accent,
              onTap: () => onTabTap(2),
            ),
            _TabItem(
              icon: Icons.person_rounded,
              label: 'Perfil',
              index: 3,
              currentIndex: tabIndex,
              accent: accent.accent,
              onTap: () => onTabTap(3),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accent.accent,
        foregroundColor: accent.fg,
        shape: const CircleBorder(),
        elevation: 4,
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Execução de treino chega na Fase 5 💪'),
            duration: Duration(seconds: 2),
          ),
        ),
        child: const Icon(Icons.play_arrow_rounded, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final Color accent;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    final color = isActive ? accent : ForjaColors.textFaint;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
