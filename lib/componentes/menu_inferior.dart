import 'package:flutter/material.dart';

class MenuInferior extends StatelessWidget {
  final int indiceAtual;
  final ValueChanged<int> aoTocar;

  const MenuInferior({
    super.key,
    required this.indiceAtual,
    required this.aoTocar,
  });

  Color _alpha(Color c, double pct) {
    final a = (255 * pct).round().clamp(0, 255);
    return c.withAlpha(a);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    const active = Color(0xFFE53935);

    // Fundo do menu (agora respeita dark/light)
    final bg = isDark ? cs.surfaceContainerHighest : cs.surface;

    // Ícone inativo (agora respeita dark/light)
    final inactiveIcon = isDark
        ? cs.onSurface.withOpacity(0.70)
        : const Color(0xFF1F1F1F).withOpacity(0.65);

    // Sombra (mais forte no dark)
    final shadowColor = _alpha(Colors.black, isDark ? 0.35 : 0.12);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cs.outline.withOpacity(isDark ? 0.22 : 0.12),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 8),
            color: shadowColor,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _botao(index: 0, icon: Icons.dashboard_rounded, active: active, inactive: inactiveIcon),
          _botao(index: 1, icon: Icons.grid_view_rounded, active: active, inactive: inactiveIcon),
          _botao(index: 2, icon: Icons.build_rounded, active: active, inactive: inactiveIcon),
          _botao(index: 3, icon: Icons.person_outline, active: active, inactive: inactiveIcon),
        ],
      ),
    );
  }

  Widget _botao({
    required int index,
    required IconData icon,
    required Color active,
    required Color inactive,
  }) {
    final cor = indiceAtual == index ? active : inactive;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => aoTocar(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Icon(icon, size: 26, color: cor),
      ),
    );
  }
}
