import 'package:flutter/material.dart';
import '../app_state.dart';
import '../config_store.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ REMOVIDO: cs aqui era opcional, mas agora usaremos dentro dos builders
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            child: ValueListenableBuilder<AppState>(
              valueListenable: appState,
              builder: (context, st, child) {
                final cs = Theme.of(context).colorScheme;

                return ListView(
                  children: [
                    Text(
                      'DASHBOARD',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Resumo do sistema e monitoramento rápido.',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: _KpiCard(
                            titulo: 'Zonas ativas',
                            valor: _calcZonasAtivas(),
                            icon: Icons.flash_on_rounded,
                            onTap: () => _abrirResumoZonas(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _KpiCard(
                            titulo: 'Perfil',
                            valor: st.profile,
                            icon: Icons.layers_rounded,
                            onTap: () => _abrirPerfil(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _KpiCard(
                            titulo: 'Brilho',
                            valor: '${st.globalBrightness}%',
                            icon: Icons.brightness_6_rounded,
                            onTap: () => _abrirBrilho(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _KpiCard(
                            titulo: 'Modo Show',
                            valor: st.showMode ? 'On' : 'Off',
                            icon: Icons.play_circle_outline_rounded,
                            onTap: () => _abrirModoShow(context),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Text(
                      'Atividade recente',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 10),

                    ...const [
                      _LogItem(
                        titulo: 'Presença ligada',
                        detalhe: 'Intensidade 15%',
                        icon: Icons.lightbulb_outline,
                      ),
                      _LogItem(
                        titulo: 'Freio acionado',
                        detalhe: 'Prioridade alta',
                        icon: Icons.warning_amber_rounded,
                      ),
                      _LogItem(
                        titulo: 'Seta direita',
                        detalhe: 'Animação sequencial',
                        icon: Icons.arrow_forward,
                      ),
                      _LogItem(
                        titulo: 'Configuração salva',
                        detalhe: 'Perfil “Noite”',
                        icon: Icons.save_rounded,
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- KPI Actions ----------------

  static int _to255(double v) => (v * 255.0).round().clamp(0, 255);

  static String _calcZonasAtivas() {
    final cfg = appConfig.value;
    int count = 0;

    const preto = Color(0xFF000000);
    final pr = _to255(preto.r);
    final pg = _to255(preto.g);
    final pb = _to255(preto.b);
    final pa = _to255(preto.a);

    for (final z in cfg.zones.values) {
      if (z.effect != 'Cor fixa') {
        count++;
      } else {
        final zr = _to255(z.color.r);
        final zg = _to255(z.color.g);
        final zb = _to255(z.color.b);
        final za = _to255(z.color.a);

        if (zr != pr || zg != pg || zb != pb || za != pa) {
          count++;
        }
      }
    }

    return count.toString();
  }

  static void _abrirResumoZonas(BuildContext context) {
    final cfg = appConfig.value;
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final cs2 = Theme.of(context).colorScheme;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Resumo das zonas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              const SizedBox(height: 10),
              ...cfg.zones.entries.map((e) {
                final nome = nomeZona(e.key);
                final cor = e.value.color;
                final efeito = e.value.effect;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    // ✅ surfaceVariant -> surfaceContainerHighest
                    color: cs2.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cs2.outlineVariant.withAlpha(90)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: cor,
                          shape: BoxShape.circle,
                          border: Border.all(color: cs2.outlineVariant),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          nome,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      Text(
                        efeito,
                        style: TextStyle(color: cs2.onSurfaceVariant, fontSize: 12),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 6),
              Text(
                'Dica: edite cores e efeitos em ZONAS.',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  static void _abrirBrilho(BuildContext context) {
    int temp = appState.value.globalBrightness;
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Brilho global',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.brightness_6_rounded, color: Color(0xFFE53935)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '$temp%',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          temp = 70;
                          setModalState(() {});
                        },
                        child: const Text('Padrão'),
                      ),
                    ],
                  ),
                  Slider(
                    value: temp.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: '$temp%',
                    onChanged: (v) => setModalState(() => temp = v.round()),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53935),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            await setGlobalBrightness(temp);
                            if (context.mounted) Navigator.pop(context);
                          },
                          child: const Text('Aplicar'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Quando conectado, isso é enviado ao ESP32 imediatamente.',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void _abrirPerfil(BuildContext context) {
    final perfis = <String>['Dia', 'Noite', 'Chuva', 'Estrada', 'Personalizado'];
    String selecionado = appState.value.profile;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Selecionar perfil',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: perfis.contains(selecionado) ? selecionado : 'Noite',
                items: perfis.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (v) => selecionado = v ?? selecionado,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        await setProfile(selecionado);
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text('Aplicar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static void _abrirModoShow(BuildContext context) {
    bool enabled = appState.value.showMode;
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Modo Show',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.play_circle_outline_rounded, color: Color(0xFFE53935)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          enabled ? 'Ativado' : 'Desativado',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                      Switch(
                        value: enabled,
                        onChanged: (v) => setModalState(() => enabled = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No firmware, o Modo Show deve ser desabilitado automaticamente quando freio/seta/ré estiverem ativos.',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53935),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            await setShowMode(enabled);
                            if (context.mounted) Navigator.pop(context);
                          },
                          child: const Text('Aplicar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icon;
  final VoidCallback? onTap;

  const _KpiCard({
    required this.titulo,
    required this.valor,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outlineVariant.withAlpha(90)),
          boxShadow: [
            BoxShadow(
              blurRadius: 14,
              offset: const Offset(0, 6),
              color: Colors.black.withAlpha(18),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 26, color: const Color(0xFFE53935)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    valor,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Toque para ajustar',
                    style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogItem extends StatelessWidget {
  final String titulo;
  final String detalhe;
  final IconData icon;

  const _LogItem({
    required this.titulo,
    required this.detalhe,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withAlpha(90)),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            offset: const Offset(0, 6),
            color: Colors.black.withAlpha(18),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: const Color(0xFFE53935)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(fontWeight: FontWeight.w900, color: cs.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  detalhe,
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
