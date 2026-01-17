import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/files/files_screen.dart';
import 'features/cleanup/cleanup_screen.dart';
import 'features/process/process_screen.dart';
import 'features/battery/battery_screen.dart';
import 'features/settings/settings_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/files',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppScaffold(child: child, currentPath: state.uri.path),
        routes: [
          GoRoute(path: '/files', builder: (_, __) => const FilesScreen()),
          GoRoute(path: '/cleanup', builder: (_, __) => const CleanupScreen()),
          GoRoute(path: '/process', builder: (_, __) => const ProcessScreen()),
          GoRoute(path: '/battery', builder: (_, __) => const BatteryScreen()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        ],
      )
    ],
  );
});

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.child, required this.currentPath});
  final Widget child;
  final String currentPath;

  int _indexForLocation(String location) {
    if (location.startsWith('/cleanup')) return 1;
    if (location.startsWith('/process')) return 2;
    if (location.startsWith('/battery')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }

  String _locationForIndex(int index) {
    switch (index) {
      case 1:
        return '/cleanup';
      case 2:
        return '/process';
      case 3:
        return '/battery';
      case 4:
        return '/settings';
      case 0:
      default:
        return '/files';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _indexForLocation(currentPath);
    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => context.go(_locationForIndex(i)),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.folder), label: 'Files'),
          NavigationDestination(icon: Icon(Icons.cleaning_services), label: 'Cleanup'),
          NavigationDestination(icon: Icon(Icons.insights), label: 'Process'),
          NavigationDestination(icon: Icon(Icons.battery_full), label: 'Battery'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
