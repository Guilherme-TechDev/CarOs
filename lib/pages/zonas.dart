import 'package:flutter/material.dart';
import '../config_store.dart';
import '../device/device_service.dart';

class ZonasPage extends StatelessWidget {
  const ZonasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ZONAS',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Toque em uma zona para configurar cor e efeito.',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 12),

                // ✅ Ações globais
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _abrirAlterarTodos(context),
                        icon: const Icon(Icons.tune_rounded),
                        label: const Text('Alterar todos'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.surface,
                          foregroundColor: cs.onSurface,
                          elevation: 0,
                          side: BorderSide(color: cs.outlineVariant.withAlpha(140)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _abrirFestaGlobal(context),
                        icon: const Icon(Icons.celebration_rounded),
                        label: const Text('Modo festa'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Expanded(
                  child: ValueListenableBuilder<AppConfig>(
                    valueListenable: appConfig,
                    builder: (context, cfg, child) {
                      return GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.05,
                        children: [
                          ZonaCard(zoneKey: zFreio, icon: Icons.warning_amber_rounded, cfg: cfg),
                          ZonaCard(zoneKey: zSetaEsq, icon: Icons.arrow_back, cfg: cfg),
                          ZonaCard(zoneKey: zSetaDir, icon: Icons.arrow_forward, cfg: cfg),
                          ZonaCard(zoneKey: zPresenca, icon: Icons.lightbulb_outline, cfg: cfg),
                          ZonaCard(zoneKey: zRe, icon: Icons.replay, cfg: cfg),
                          ZonaCard(zoneKey: zNeblina, icon: Icons.blur_on, cfg: cfg),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------ ALTERAR TODOS ------------------
  void _abrirAlterarTodos(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cfg = appConfig.value;

    // pega a primeira zona como referência inicial
    final primeiro = cfg.zones.values.first;
    Color cor = primeiro.color;
    String efeito = primeiro.effect;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      // ✅ não forçar branco
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final cs2 = Theme.of(ctx).colorScheme;

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Alterar todos',
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // cor
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: cor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: cs2.outlineVariant),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final selecionada = await _pickColorSheet(context, cor);
                            if (selecionada != null) {
                              setSheetState(() => cor = selecionada);
                            }
                          },
                          child: const Text('Escolher cor'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // efeito
                  DropdownButtonFormField<String>(
                    initialValue: efeito,
                    items: efeitosDisponiveis
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setSheetState(() => efeito = v);
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      labelText: 'Efeito',
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
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
                            final atual = appConfig.value;
                            final novoMapa = <String, ZoneConfig>{};

                            for (final entry in atual.zones.entries) {
                              novoMapa[entry.key] = entry.value.copyWith(color: cor, effect: efeito);
                            }

                            final novoCfg = atual.copyWith(zones: novoMapa);
                            appConfig.value = novoCfg;

                            // ✅ pronto para ESP32
                            await _enviarSnapshotParaESP32(novoCfg);

                            if (ctx.mounted) Navigator.pop(ctx);
                          },
                          child: const Text('Aplicar'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  Text(
                    'Dica: você pode aplicar o mesmo estilo em todas as zonas rapidamente.',
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

  // ------------------ MODO FESTA GLOBAL ------------------
  void _abrirFestaGlobal(BuildContext context) {
    String efeitoFesta = efeitosFesta.first;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      // ✅ não forçar branco
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final cs2 = Theme.of(ctx).colorScheme;

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Modo festa (global)',
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    initialValue: efeitoFesta,
                    items: efeitosFesta.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setSheetState(() => efeitoFesta = v);
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      labelText: 'Efeito festa',
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
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
                            final atual = appConfig.value;
                            final novoMapa = <String, ZoneConfig>{};

                            // aplica o efeito festa em todas as zonas (cor fica como está)
                            for (final entry in atual.zones.entries) {
                              novoMapa[entry.key] = entry.value.copyWith(effect: efeitoFesta);
                            }

                            final novoCfg = atual.copyWith(zones: novoMapa);
                            appConfig.value = novoCfg;

                            // ✅ pronto para ESP32
                            await _enviarSnapshotParaESP32(novoCfg);

                            if (ctx.mounted) Navigator.pop(ctx);
                          },
                          child: const Text('Ativar em todos'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  Text(
                    'Para usar festa só em uma zona, abra a zona e selecione um “Festa - ...” no efeito.',
                    style: TextStyle(color: cs2.onSurfaceVariant, fontSize: 12),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ------------------ ENVIO PADRÃO PARA ESP32 ------------------

  Future<void> _enviarSnapshotParaESP32(AppConfig cfg) async {
    final payload = _buildEsp32ConfigPayload(cfg);
    await deviceService.sendConfigSnapshot(payload);
  }

  Map<String, dynamic> _buildEsp32ConfigPayload(AppConfig cfg) {
    final startupName = cfg.startupAnimation;
    final startupIndex = animacoesStartup.indexOf(startupName);
    final startupId = (startupIndex >= 0) ? (startupIndex + 1) : 0; // 0 = desconhecido/auto

    return {
      "type": "config",
      "startupId": startupId,
      "startupName": startupName,
      "zones": cfg.zones.entries.map((e) {
        final zoneKey = e.key;
        final z = e.value;
        return {
          "id": _zoneIdFromKey(zoneKey),
          "key": zoneKey,
          "color": _colorToHex(z.color), // "#RRGGBB"
          "effectId": _effectIdFromName(z.effect),
          "effectName": z.effect,
          "isParty": ehEfeitoFesta(z.effect),
        };
      }).toList(),
      "ts": DateTime.now().toIso8601String(),
    };
  }

  int _zoneIdFromKey(String key) {
    switch (key) {
      case zPresenca:
        return 0;
      case zFreio:
        return 1;
      case zSetaEsq:
        return 2;
      case zSetaDir:
        return 3;
      case zRe:
        return 4;
      case zNeblina:
        return 5;
      default:
        return 99;
    }
  }

  int _effectIdFromName(String name) {
    switch (name) {
      case 'Cor fixa':
        return 0;
      case 'Respirar (fade)':
        return 1;
      case 'Piscar':
        return 2;
      case 'Sequencial (chase)':
        return 3;
      case 'Varredura (wipe)':
        return 4;

      case 'Festa - Arco-íris':
        return 10;
      case 'Festa - Polícia':
        return 11;
      case 'Festa - Estrobo':
        return 12;
      case 'Festa - Pulsar RGB':
        return 13;

      default:
        return 0;
    }
  }

  // ✅ Corrigido: Color.red/green/blue foram depreciados em versões novas.
  int _to255(double v) => (v * 255.0).round().clamp(0, 255);

  String _colorToHex(Color c) {
    final r = _to255(c.r).toRadixString(16).padLeft(2, '0').toUpperCase();
    final g = _to255(c.g).toRadixString(16).padLeft(2, '0').toUpperCase();
    final b = _to255(c.b).toRadixString(16).padLeft(2, '0').toUpperCase();
    return '#$r$g$b';
  }

  // ------------------ PICK COLOR ------------------
  Future<Color?> _pickColorSheet(BuildContext context, Color atual) async {
    final cores = <Color>[
      const Color(0xFFE53935),
      const Color(0xFFFF9800),
      const Color(0xFFFFEB3B),
      const Color(0xFF4CAF50),
      const Color(0xFF00BCD4),
      const Color(0xFF2196F3),
      const Color(0xFF9C27B0),
      const Color(0xFFFF4081),
      const Color(0xFFFFFFFF),
      const Color(0xFF000000),
    ];

    return showModalBottomSheet<Color>(
      context: context,
      showDragHandle: true,
      // ✅ não forçar branco
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Selecione uma cor',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: cores.map((c) {
                  return InkWell(
                    onTap: () => Navigator.pop(ctx, c),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(color: cs.outlineVariant, width: 1),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ZonaCard extends StatelessWidget {
  final String zoneKey;
  final IconData icon;
  final AppConfig cfg;

  const ZonaCard({
    super.key,
    required this.zoneKey,
    required this.icon,
    required this.cfg,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final z = cfg.zones[zoneKey]!;
    final festa = ehEfeitoFesta(z.effect);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ZonaDetalhesPage(zoneKey: zoneKey)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outlineVariant.withAlpha(120)),
          boxShadow: [
            BoxShadow(
              blurRadius: 14,
              offset: const Offset(0, 6),
              color: Colors.black.withAlpha(18),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 30, color: const Color(0xFFE53935)),
                const Spacer(),
                if (festa)
                  const Icon(Icons.celebration_rounded, size: 18, color: Color(0xFFE53935)),
                const SizedBox(width: 6),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: z.color,
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.outlineVariant),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              nomeZona(zoneKey),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              z.effect,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------ DETALHES DA ZONA ------------------
class ZonaDetalhesPage extends StatefulWidget {
  final String zoneKey;
  const ZonaDetalhesPage({super.key, required this.zoneKey});

  @override
  State<ZonaDetalhesPage> createState() => _ZonaDetalhesPageState();
}

class _ZonaDetalhesPageState extends State<ZonaDetalhesPage> {
  late Color _cor;
  late String _efeito;

  @override
  void initState() {
    super.initState();
    final cfg = appConfig.value;
    final z = cfg.zones[widget.zoneKey]!;
    _cor = z.color;
    _efeito = z.effect;
  }

  Future<void> _salvar() async {
    final cfg = appConfig.value;
    final novoMapa = Map<String, ZoneConfig>.from(cfg.zones);
    novoMapa[widget.zoneKey] = novoMapa[widget.zoneKey]!.copyWith(color: _cor, effect: _efeito);
    final novoCfg = cfg.copyWith(zones: novoMapa);

    appConfig.value = novoCfg;

    // ✅ pronto para ESP32
    final payload = _buildEsp32ConfigPayload(novoCfg);
    await deviceService.sendConfigSnapshot(payload);

    if (mounted) Navigator.pop(context);
  }

  // ✅ Corrigido: Color.red/green/blue foram depreciados.
  int _to255(double v) => (v * 255.0).round().clamp(0, 255);

  String _colorToHex(Color c) {
    final r = _to255(c.r).toRadixString(16).padLeft(2, '0').toUpperCase();
    final g = _to255(c.g).toRadixString(16).padLeft(2, '0').toUpperCase();
    final b = _to255(c.b).toRadixString(16).padLeft(2, '0').toUpperCase();
    return '#$r$g$b';
  }

  Map<String, dynamic> _buildEsp32ConfigPayload(AppConfig cfg) {
    final startupName = cfg.startupAnimation;
    final startupIndex = animacoesStartup.indexOf(startupName);
    final startupId = (startupIndex >= 0) ? (startupIndex + 1) : 0;

    int zoneIdFromKey(String key) {
      switch (key) {
        case zPresenca:
          return 0;
        case zFreio:
          return 1;
        case zSetaEsq:
          return 2;
        case zSetaDir:
          return 3;
        case zRe:
          return 4;
        case zNeblina:
          return 5;
        default:
          return 99;
      }
    }

    int effectIdFromName(String name) {
      switch (name) {
        case 'Cor fixa':
          return 0;
        case 'Respirar (fade)':
          return 1;
        case 'Piscar':
          return 2;
        case 'Sequencial (chase)':
          return 3;
        case 'Varredura (wipe)':
          return 4;

        case 'Festa - Arco-íris':
          return 10;
        case 'Festa - Polícia':
          return 11;
        case 'Festa - Estrobo':
          return 12;
        case 'Festa - Pulsar RGB':
          return 13;

        default:
          return 0;
      }
    }

    return {
      "type": "config",
      "startupId": startupId,
      "startupName": startupName,
      "zones": cfg.zones.entries.map((e) {
        final zoneKey = e.key;
        final z = e.value;
        return {
          "id": zoneIdFromKey(zoneKey),
          "key": zoneKey,
          "color": _colorToHex(z.color),
          "effectId": effectIdFromName(z.effect),
          "effectName": z.effect,
          "isParty": ehEfeitoFesta(z.effect),
        };
      }).toList(),
      "ts": DateTime.now().toIso8601String(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final festaSelecionado = ehEfeitoFesta(_efeito);

    return Scaffold(
      // ✅ não forçar cor de fundo (tema cuida disso)
      appBar: AppBar(
        title: Text('Zona: ${nomeZona(widget.zoneKey)}'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                _card(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Prévia', style: TextStyle(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 10),
                      Container(
                        height: 90,
                        decoration: BoxDecoration(
                          color: _cor.withAlpha(70),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _cor, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _efeito.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      if (festaSelecionado) ...[
                        const SizedBox(height: 10),
                        const Row(
                          children: [
                            Icon(Icons.celebration_rounded, color: Color(0xFFE53935)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Modo festa ativo nesta zona.',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _card(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cor da zona', style: TextStyle(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _cor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: cs.outlineVariant),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _abrirSeletorCor,
                              child: const Text('Escolher cor'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _card(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Efeito', style: TextStyle(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: _efeito,
                        items: efeitosDisponiveis
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => _efeito = v ?? _efeito),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        festaSelecionado
                            ? 'Este efeito será interpretado como “modo festa” no ESP32.'
                            : 'Depois vamos mapear este efeito para o comportamento real no ESP32.',
                        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _salvar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Salvar configuração'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(BuildContext context, {required Widget child}) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withAlpha(120)),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            offset: const Offset(0, 6),
            color: Colors.black.withAlpha(18),
          ),
        ],
      ),
      child: child,
    );
  }

  void _abrirSeletorCor() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      // ✅ não forçar branco
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;

        final cores = <Color>[
          const Color(0xFFE53935),
          const Color(0xFFFF9800),
          const Color(0xFFFFEB3B),
          const Color(0xFF4CAF50),
          const Color(0xFF00BCD4),
          const Color(0xFF2196F3),
          const Color(0xFF9C27B0),
          const Color(0xFFFF4081),
          const Color(0xFFFFFFFF),
          const Color(0xFF000000),
        ];

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Selecione uma cor',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: cores.map((c) {
                  return InkWell(
                    onTap: () {
                      setState(() => _cor = c);
                      Navigator.pop(ctx);
                    },
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(color: cs.outlineVariant, width: 1),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
