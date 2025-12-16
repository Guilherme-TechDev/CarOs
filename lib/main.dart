import 'package:flutter/material.dart';

import 'app_state.dart'; // ✅ IMPORTANTE: onde está o ValueNotifier<AppState> appState
import 'componentes/menu_inferior.dart';

import 'pages/dashboard.dart';
import 'pages/zonas.dart';
import 'pages/utilidades.dart';
import 'pages/perfil.dart';

void main() {
  runApp(const CarOs2App());
}

class CarOs2App extends StatelessWidget {
  const CarOs2App({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppState>(
      valueListenable: appState,
      builder: (context, st, _) {
        return MaterialApp(
          title: 'CarOs2',
          debugShowCheckedModeBanner: false,

          // ✅ Agora o app alterna de fato
          themeMode: st.darkMode ? ThemeMode.dark : ThemeMode.light,

          // Tema claro
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF4F4F4),
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2E6BFF),
              brightness: Brightness.light,
            ),
          ),

          // Tema escuro
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0E0E10),
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2E6BFF),
              brightness: Brightness.dark,
            ),
          ),

          home: const AppShell(),
        );
      },
    );
  }
}

/// Container principal que controla as 4 abas e desenha o menu inferior
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _aba = 0; // 0=Dashboard, 1=Zonas, 2=Utilidades, 3=Perfil

  // ✅ Ajuste fino: espaço reservado para o menu inferior para não “atropelar” a página
  static const double _alturaReservadaMenu = 92;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ✅ Evita sobreposição do conteúdo com o menu inferior
          Padding(
            padding: const EdgeInsets.only(bottom: _alturaReservadaMenu),
            child: _conteudo(),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              minimum: const EdgeInsets.only(bottom: 12),
              child: MenuInferior(
                indiceAtual: _aba,
                aoTocar: (i) => setState(() => _aba = i),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _conteudo() {
    switch (_aba) {
      case 0:
        return const DashboardPage();
      case 1:
        return const ZonasPage();
      case 2:
        return const UtilidadesPage();
      case 3:
        return const PerfilPage();
      default:
        return const SizedBox.shrink();
    }
  }
}
