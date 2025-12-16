import 'package:flutter/material.dart';
import '../config_store.dart';
import '../app_state.dart';
import '../live_state.dart';
import '../device/device_service.dart';

class UtilidadesPage extends StatefulWidget {
  const UtilidadesPage({super.key});

  @override
  State<UtilidadesPage> createState() => _UtilidadesPageState();
}

class _UtilidadesPageState extends State<UtilidadesPage> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            child: ListView(
              children: [
                Text(
                  'UTILIDADES',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Atalhos, conexão e prévia ao vivo.',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 14),

                _cardConexao(),
                const SizedBox(height: 12),

                _cardStartup(),
                const SizedBox(height: 12),

                Text(
                  'Prévia da lanterna (ao vivo)',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 10),

                ValueListenableBuilder<LampLiveState>(
                  valueListenable: liveState,
                  builder: (context, st, _) => TailLampPreview(state: st),
                ),
                const SizedBox(height: 12),

                _cardSimulacao(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- CARD: CONEXÃO ----------
  Widget _cardConexao() {
    return ValueListenableBuilder<AppState>(
      valueListenable: appState,
      builder: (context, st, _) {
        final cs = Theme.of(context).colorScheme;
        final conectado = st.connected;

        return Container(
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
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: conectado ? const Color(0xFF2E7D32) : const Color(0xFFE53935),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  conectado ? 'Conectado ao ESP32' : 'Desconectado do ESP32',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async => toggleConnection(),
                child: Text(conectado ? 'Desconectar' : 'Conectar'),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------- CARD: AO LIGAR ----------
  Widget _cardStartup() {
    final List<String> opcoesAoLigar = [
      'Automático (aleatório)',
      ...animacoesStartup,
    ];

    return ValueListenableBuilder<AppConfig>(
      valueListenable: appConfig,
      builder: (context, cfg, _) {
        final cs = Theme.of(context).colorScheme;

        final String valorAtual =
            opcoesAoLigar.contains(cfg.startupAnimation) ? cfg.startupAnimation : 'Automático (aleatório)';

        return Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ao ligar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: valorAtual,
                items: opcoesAoLigar.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
                onChanged: (v) async {
                  if (v == null) return;

                  final novoCfg = cfg.copyWith(startupAnimation: v);
                  appConfig.value = novoCfg;

                  // pronto para ESP32
                  await deviceService.sendConfigSnapshot(_buildStartupPayload(novoCfg));
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                (valorAtual == 'Automático (aleatório)')
                    ? 'O módulo escolherá uma animação aleatória sempre que energizar.'
                    : 'Animação executada quando o módulo é energizado.',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, dynamic> _buildStartupPayload(AppConfig cfg) {
    int startupId;
    if (cfg.startupAnimation == 'Automático (aleatório)') {
      startupId = 0;
    } else {
      final idx = animacoesStartup.indexOf(cfg.startupAnimation);
      startupId = idx >= 0 ? (idx + 1) : 0;
    }

    return {
      "type": "startup",
      "startupId": startupId,
      "startupName": cfg.startupAnimation,
      "ts": DateTime.now().toIso8601String(),
    };
  }

  // ---------- CARD: SIMULAÇÃO ----------
  Widget _cardSimulacao() {
    return ValueListenableBuilder<LampLiveState>(
      valueListenable: liveState,
      builder: (context, st, _) {
        final cs = Theme.of(context).colorScheme;

        return Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Simulação (teste sem ESP32)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _chip('Presença', st.presenca, (v) => _setLive('presenca', v)),
                  _chip('Freio', st.freio, (v) => _setLive('freio', v)),
                  _chip('Seta Esq.', st.setaEsq, (v) => _setLive('setaEsq', v)),
                  _chip('Seta Dir.', st.setaDir, (v) => _setLive('setaDir', v)),
                  _chip('Ré', st.re, (v) => _setLive('re', v)),
                  _chip('Neblina', st.neblina, (v) => _setLive('neblina', v)),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Quando estiver conectado, isso pode ser enviado ao ESP32 como modo teste.',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _setLive(String field, bool value) async {
    final st = liveState.value;

    LampLiveState novo;
    switch (field) {
      case 'presenca':
        novo = st.copyWith(presenca: value);
        break;
      case 'freio':
        novo = st.copyWith(freio: value);
        break;
      case 'setaEsq':
        novo = st.copyWith(setaEsq: value);
        break;
      case 'setaDir':
        novo = st.copyWith(setaDir: value);
        break;
      case 're':
        novo = st.copyWith(re: value);
        break;
      case 'neblina':
        novo = st.copyWith(neblina: value);
        break;
      default:
        novo = st;
    }

    liveState.value = novo;

    // pronto para ESP32
    await deviceService.sendConfigSnapshot({
      "type": "live_state",
      "presenca": novo.presenca,
      "freio": novo.freio,
      "setaEsq": novo.setaEsq,
      "setaDir": novo.setaDir,
      "re": novo.re,
      "neblina": novo.neblina,
      "ts": DateTime.now().toIso8601String(),
    });
  }

  Widget _chip(String label, bool value, void Function(bool) onChanged) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: value ? const Color(0xFFE53935).withAlpha(28) : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: value ? const Color(0xFFE53935) : cs.outlineVariant.withAlpha(120),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: value ? const Color(0xFFE53935) : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class TailLampPreview extends StatelessWidget {
  final LampLiveState state;
  const TailLampPreview({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: 180,
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
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          if (state.presenca)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE53935).withAlpha(120), width: 2),
                ),
              ),
            ),

          Positioned(
            left: 18,
            right: 18,
            top: 26,
            height: 68,
            child: _zona(
              ativa: state.freio,
              corAtiva: const Color(0xFFE53935),
              label: 'FREIO',
              cs: cs,
            ),
          ),

          Positioned(
            left: 18,
            top: 110,
            width: 130,
            height: 48,
            child: _zona(
              ativa: state.setaEsq,
              corAtiva: const Color(0xFFFF9800),
              label: 'SETA E',
              cs: cs,
            ),
          ),
          Positioned(
            right: 18,
            top: 110,
            width: 130,
            height: 48,
            child: _zona(
              ativa: state.setaDir,
              corAtiva: const Color(0xFFFF9800),
              label: 'SETA D',
              cs: cs,
            ),
          ),

          Positioned(
            left: 160,
            top: 110,
            width: 70,
            height: 22,
            child: _zona(
              ativa: state.re,
              corAtiva: const Color(0xFF90CAF9),
              label: 'RÉ',
              pequena: true,
              cs: cs,
            ),
          ),
          Positioned(
            left: 160,
            top: 136,
            width: 70,
            height: 22,
            child: _zona(
              ativa: state.neblina,
              corAtiva: const Color(0xFFE53935),
              label: 'NEB',
              pequena: true,
              cs: cs,
            ),
          ),
        ],
      ),
    );
  }

  Widget _zona({
    required bool ativa,
    required Color corAtiva,
    required String label,
    required ColorScheme cs,
    bool pequena = false,
  }) {
    final bg = ativa ? corAtiva.withAlpha(60) : cs.surfaceContainerHighest;
    final border = ativa ? corAtiva : cs.outlineVariant.withAlpha(160);
    final textColor = ativa ? corAtiva : cs.onSurfaceVariant;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontSize: pequena ? 11 : 14,
          fontWeight: FontWeight.w900,
          color: textColor,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
