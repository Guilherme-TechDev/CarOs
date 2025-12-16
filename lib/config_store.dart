import 'package:flutter/material.dart';

class ZoneConfig {
  Color color;
  String effect;

  ZoneConfig({
    required this.color,
    required this.effect,
  });

  ZoneConfig copyWith({Color? color, String? effect}) {
    return ZoneConfig(
      color: color ?? this.color,
      effect: effect ?? this.effect,
    );
  }
}

class AppConfig {
  final Map<String, ZoneConfig> zones;
  final String startupAnimation;

  AppConfig({
    required this.zones,
    required this.startupAnimation,
  });

  AppConfig copyWith({
    Map<String, ZoneConfig>? zones,
    String? startupAnimation,
  }) {
    return AppConfig(
      zones: zones ?? this.zones,
      startupAnimation: startupAnimation ?? this.startupAnimation,
    );
  }
}

// Zonas (lowerCamelCase)
const String zFreio = 'freio';
const String zSetaEsq = 'seta_esq';
const String zSetaDir = 'seta_dir';
const String zPresenca = 'presenca';
const String zRe = 're';
const String zNeblina = 'neblina';

// Efeitos básicos
const List<String> efeitosBasicos = [
  'Cor fixa',
  'Respirar (fade)',
  'Piscar',
  'Sequencial (chase)',
  'Varredura (wipe)',
];

// ✅ Efeitos festa
const List<String> efeitosFesta = [
  'Festa - Arco-íris',
  'Festa - Polícia',
  'Festa - Estrobo',
  'Festa - Pulsar RGB',
];

// ✅ Lista completa
final List<String> efeitosDisponiveis = [
  ...efeitosBasicos,
  ...efeitosFesta,
];

// Startup
const List<String> animacoesStartup = [
  'Nenhuma (instantâneo)',
  'Fade-in suave',
  'Varredura (wipe)',
  'Sequencial rápido',
  'Show curto (2s)',
];

final ValueNotifier<AppConfig> appConfig = ValueNotifier<AppConfig>(
  AppConfig(
    startupAnimation: 'Fade-in suave',
    zones: {
      zFreio: ZoneConfig(color: const Color(0xFFE53935), effect: 'Cor fixa'),
      zSetaEsq: ZoneConfig(color: const Color(0xFFFF9800), effect: 'Sequencial (chase)'),
      zSetaDir: ZoneConfig(color: const Color(0xFFFF9800), effect: 'Sequencial (chase)'),
      zPresenca: ZoneConfig(color: const Color(0xFFE53935), effect: 'Cor fixa'),
      zRe: ZoneConfig(color: const Color(0xFF90CAF9), effect: 'Cor fixa'),
      zNeblina: ZoneConfig(color: const Color(0xFFE53935), effect: 'Cor fixa'),
    },
  ),
);

String nomeZona(String key) {
  switch (key) {
    case zFreio:
      return 'Freio';
    case zSetaEsq:
      return 'Seta Esq.';
    case zSetaDir:
      return 'Seta Dir.';
    case zPresenca:
      return 'Presença';
    case zRe:
      return 'Ré';
    case zNeblina:
      return 'Neblina';
    default:
      return key;
  }
}

// ✅ Função usada no zonas.dart
bool ehEfeitoFesta(String effect) => efeitosFesta.contains(effect);
