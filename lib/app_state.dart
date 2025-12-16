import 'package:flutter/foundation.dart';
import 'device/device_service.dart';

enum ConnectionMethod { ble, wifi }

extension ConnectionMethodLabel on ConnectionMethod {
  String get label {
    switch (this) {
      case ConnectionMethod.ble:
        return 'Bluetooth (BLE)';
      case ConnectionMethod.wifi:
        return 'Wi-Fi';
    }
  }
}

class AppState {
  // ===== conexão =====
  final bool connected;
  final String deviceName; // ex: "ESP32-CarOs2"
  final bool autoConnect;
  final ConnectionMethod connectionMethod;

  // ===== preferências =====
  final bool darkMode;

  // ===== dashboard =====
  final int globalBrightness; // 0..100
  final String profile; // ex: "Noite"
  final bool showMode;

  const AppState({
    required this.connected,
    required this.deviceName,
    required this.autoConnect,
    required this.connectionMethod,
    required this.darkMode,
    required this.globalBrightness,
    required this.profile,
    required this.showMode,
  });

  AppState copyWith({
    bool? connected,
    String? deviceName,
    bool? autoConnect,
    ConnectionMethod? connectionMethod,
    bool? darkMode,
    int? globalBrightness,
    String? profile,
    bool? showMode,
  }) {
    return AppState(
      connected: connected ?? this.connected,
      deviceName: deviceName ?? this.deviceName,
      autoConnect: autoConnect ?? this.autoConnect,
      connectionMethod: connectionMethod ?? this.connectionMethod,
      darkMode: darkMode ?? this.darkMode,
      globalBrightness: globalBrightness ?? this.globalBrightness,
      profile: profile ?? this.profile,
      showMode: showMode ?? this.showMode,
    );
  }
}

/// Estado global do app (Dashboard/Utilidades/Zonas/Perfil)
final ValueNotifier<AppState> appState = ValueNotifier<AppState>(
  const AppState(
    connected: false,
    deviceName: 'ESP32-CarOs2',
    autoConnect: true,
    connectionMethod: ConnectionMethod.ble,
    darkMode: false,
    globalBrightness: 70,
    profile: 'Noite',
    showMode: false,
  ),
);

Future<void> toggleConnection() async {
  final st = appState.value;

  if (st.connected) {
    await deviceService.disconnect();
    appState.value = st.copyWith(connected: false);
  } else {
    await deviceService.connect();
    appState.value = st.copyWith(connected: true);
  }
}

Future<void> setGlobalBrightness(int value0to100) async {
  final v = value0to100.clamp(0, 100);
  appState.value = appState.value.copyWith(globalBrightness: v);
  await deviceService.sendGlobalBrightness(v);
}

Future<void> setProfile(String profileName) async {
  appState.value = appState.value.copyWith(profile: profileName);
  await deviceService.sendProfile(profileName);
}

Future<void> setShowMode(bool enabled) async {
  appState.value = appState.value.copyWith(showMode: enabled);
  await deviceService.setShowMode(enabled);
}

// ======== novos setters para o Perfil (prontos pro ESP32) ========

Future<void> setDeviceName(String name) async {
  final n = name.trim();
  if (n.isEmpty) return;
  appState.value = appState.value.copyWith(deviceName: n);

  // Se seu deviceService ainda não tem isso, pode deixar só o state por enquanto.
  // Se quiser, crie o método no service depois.
  // await deviceService.setPreferredDeviceName(n);
}

Future<void> setAutoConnect(bool enabled) async {
  appState.value = appState.value.copyWith(autoConnect: enabled);

  // Se não existir no service ainda, não tem problema.
  // await deviceService.setAutoConnect(enabled);
}

Future<void> setConnectionMethod(ConnectionMethod method) async {
  appState.value = appState.value.copyWith(connectionMethod: method);

  // Se não existir no service ainda, não tem problema.
  // await deviceService.setConnectionMethod(method.name);
}

Future<void> setDarkMode(bool enabled) async {
  appState.value = appState.value.copyWith(darkMode: enabled);
}
