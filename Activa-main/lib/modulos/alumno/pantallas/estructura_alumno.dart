import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../datos/estado_app.dart';
import '../../../nucleo/utilidades/textos.dart';

class EstructuraAlumno extends StatelessWidget {
  const EstructuraAlumno({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final sinLeer = context.watch<EstadoApp>().avisosSinLeer;
    Widget campana(IconData i) => Badge(
      isLabelVisible: sinLeer > 0,
      label: Text('$sinLeer'),
      child: Icon(i),
    );

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: context.tr('nav.inicio'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.search),
            label: context.tr('nav.explorar'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_today_outlined),
            selectedIcon: const Icon(Icons.calendar_today),
            label: context.tr('nav.actividades'),
          ),
          NavigationDestination(
            icon: campana(Icons.notifications_outlined),
            selectedIcon: campana(Icons.notifications),
            label: context.tr('nav.avisos'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: context.tr('nav.perfil'),
          ),
        ],
      ),
    );
  }
}