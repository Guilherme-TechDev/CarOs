import 'dart:developer';

/// Serviço de comunicação com o ESP32.
/// Agora é "stub" (só loga). Depois você troca a implementação para BLE/Wi-Fi.
class DeviceService {
  Future<void> connect() async {
    log('[ESP32] connect()');
  }

  Future<void> disconnect() async {
    log('[ESP32] disconnect()');
  }

  Future<void> sendGlobalBrightness(int brightness0to100) async {
    log('[ESP32] sendGlobalBrightness: $brightness0to100');
  }

  Future<void> sendProfile(String profileName) async {
    log('[ESP32] sendProfile: $profileName');
  }

  Future<void> setShowMode(bool enabled) async {
    log('[ESP32] setShowMode: $enabled');
  }

  Future<void> sendConfigSnapshot(Map<String, dynamic> payload) async {
    log('[ESP32] sendConfigSnapshot: $payload');
  }
}

final deviceService = DeviceService();
