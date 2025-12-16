import 'package:flutter/material.dart';

class LampLiveState {
  final bool presenca;
  final bool freio;
  final bool setaEsq;
  final bool setaDir;
  final bool re;
  final bool neblina;

  const LampLiveState({
    required this.presenca,
    required this.freio,
    required this.setaEsq,
    required this.setaDir,
    required this.re,
    required this.neblina,
  });

  LampLiveState copyWith({
    bool? presenca,
    bool? freio,
    bool? setaEsq,
    bool? setaDir,
    bool? re,
    bool? neblina,
  }) {
    return LampLiveState(
      presenca: presenca ?? this.presenca,
      freio: freio ?? this.freio,
      setaEsq: setaEsq ?? this.setaEsq,
      setaDir: setaDir ?? this.setaDir,
      re: re ?? this.re,
      neblina: neblina ?? this.neblina,
    );
  }
}

final ValueNotifier<LampLiveState> liveState = ValueNotifier<LampLiveState>(
  const LampLiveState(
    presenca: true,
    freio: false,
    setaEsq: false,
    setaDir: false,
    re: false,
    neblina: false,
  ),
);
  