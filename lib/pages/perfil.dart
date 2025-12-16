import 'package:flutter/material.dart';
import '../app_state.dart';
import '../config_store.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            child: ValueListenableBuilder<AppState>(
              valueListenable: appState,
              builder: (context, st, child) {
                return ListView(
                  children: [
                    Text(
                      'PERFIL',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Preferências do app e conexão.',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 14),

                    _titulo(context, 'Conexão'),
                    const SizedBox(height: 10),
                    _card(context, child: _secaoConexao(context, st)),

                    const SizedBox(height: 14),
                    _titulo(context, 'Preferências'),
                    const SizedBox(height: 10),
                    _card(context, child: _secaoPreferencias(context, st)),

                    const SizedBox(height: 14),
                    _titulo(context, 'Sobre'),
                    const SizedBox(height: 10),
                    _card(
                      context,
                      child: const Column(
                        children: [
                          _LinhaInfo('App', 'CarOs2'),
                          SizedBox(height: 10),
                          _LinhaInfo('Versão', '0.1 (protótipo)'),
                          SizedBox(height: 10),
                          _LinhaInfo('Status', 'Em desenvolvimento'),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ================= SEÇÕES =================

  Widget _secaoConexao(BuildContext context, AppState st) {
    return Column(
      children: [
        _LinhaInfo('Módulo', st.deviceName.isEmpty ? '—' : st.deviceName),
        const SizedBox(height: 10),
        _LinhaInfo('Método', _connectionLabel(st.connectionMethod)),
        const SizedBox(height: 14),

        _SwitchLinha(
          title: 'Auto-conectar',
          subtitle: 'Reconectar automaticamente quando possível.',
          value: st.autoConnect,
          onChanged: (v) {
            appState.value = st.copyWith(autoConnect: v);
          },
        ),
        const SizedBox(height: 10),

        _BotaoAcao(
          label: 'Editar nome do módulo',
          icon: Icons.edit_rounded,
          onTap: () => _editarNomeModulo(context),
        ),
        const SizedBox(height: 10),

        _BotaoAcao(
          label: 'Escolher método de conexão',
          icon: Icons.settings_ethernet_rounded,
          onTap: () => _escolherMetodo(context),
        ),

        const SizedBox(height: 14),
        _StatusConexao(st),
      ],
    );
  }

  Widget _secaoPreferencias(BuildContext context, AppState st) {
    return Column(
      children: [
        _SwitchLinha(
          title: 'Modo escuro',
          subtitle: 'Alterna o tema global do app.',
          value: st.darkMode,
          onChanged: (v) => setDarkMode(v), // ✅ usa seu setter
        ),
        const SizedBox(height: 10),

        _BotaoAcao(
          label: 'Restaurar padrão',
          icon: Icons.restart_alt_rounded,
          onTap: () {
            appConfig.value = defaultAppConfig();
            _snack(context, 'Configuração restaurada.');
          },
        ),
      ],
    );
  }

  // ================= AÇÕES =================

  Future<void> _editarNomeModulo(BuildContext context) async {
    final st = appState.value;
    final ctrl = TextEditingController(text: st.deviceName);

    final nome = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Nome do módulo',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 10),
              TextField(controller: ctrl),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pop(sheetCtx, ctrl.text.trim()),
                child: const Text('Salvar'),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted) return;
    if (nome == null || nome.isEmpty) return;

    appState.value = st.copyWith(deviceName: nome);
  }

  Future<void> _escolherMetodo(BuildContext context) async {
    final st = appState.value;
    ConnectionMethod metodo = st.connectionMethod;

    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (sheetCtx, setStateSheet) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Método de conexão',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(height: 10),

                  RadioGroup<ConnectionMethod>(
                    groupValue: metodo,
                    onChanged: (value) {
                      if (value == null) return;
                      setStateSheet(() => metodo = value);
                    },
                    child: const Column(
                      children: [
                        RadioListTile(
                          value: ConnectionMethod.ble,
                          title: Text('Bluetooth (BLE)'),
                        ),
                        RadioListTile(
                          value: ConnectionMethod.wifi,
                          title: Text('Wi-Fi'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      appState.value = st.copyWith(connectionMethod: metodo);
                      Navigator.pop(sheetCtx);
                    },
                    child: const Text('Salvar'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ================= HELPERS =================

  static String _connectionLabel(ConnectionMethod m) {
    switch (m) {
      case ConnectionMethod.ble:
        return 'Bluetooth (BLE)';
      case ConnectionMethod.wifi:
        return 'Wi-Fi';
    }
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  Widget _titulo(BuildContext context, String t) {
    return Text(
      t,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
    );
  }

  Widget _card(BuildContext context, {required Widget child}) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface, // ✅ respeita claro/escuro
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withAlpha(90)),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            offset: const Offset(0, 6),
            color: Colors.black.withAlpha(
              Theme.of(context).brightness == Brightness.dark ? 18 : 18,
            ),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ================= COMPONENTES =================

class _LinhaInfo extends StatelessWidget {
  final String a, b;
  const _LinhaInfo(this.a, this.b);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            a,
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ),
        Text(
          b,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}

class _SwitchLinha extends StatelessWidget {
  final String title, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchLinha({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant)),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _BotaoAcao extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _BotaoAcao({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest, // ✅ respeita claro/escuro
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFE53935)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _StatusConexao extends StatelessWidget {
  final AppState st;
  const _StatusConexao(this.st);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          st.connected ? Icons.check_circle : Icons.cancel,
          color: st.connected ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
        Text(
          st.connected ? 'Conectado' : 'Desconectado',
          style: TextStyle(color: cs.onSurface),
        ),
      ],
    );
  }
}

// ================= DEFAULT FALLBACK =================
// Mantive do jeito que estava no seu código:
AppConfig defaultAppConfig() {
  final zones = <String, ZoneConfig>{
    zPresenca: ZoneConfig(color: const Color(0xFFE53935), effect: 'Cor fixa'),
    zFreio: ZoneConfig(color: const Color(0xFFE53935), effect: 'Cor fixa'),
    zSetaEsq: ZoneConfig(color: const Color(0xFFFF9800), effect: 'Sequencial (chase)'),
    zSetaDir: ZoneConfig(color: const Color(0xFFFF9800), effect: 'Sequencial (chase)'),
    zRe: ZoneConfig(color: const Color(0xFF90CAF9), effect: 'Cor fixa'),
    zNeblina: ZoneConfig(color: const Color(0xFFE53935), effect: 'Cor fixa'),
  };

  return AppConfig(
    startupAnimation: 'Automático (aleatório)',
    zones: zones,
  );
}
