import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'services/ads/ads_manager.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    const adsEnabled = false; // enable after consent wiring
    if (adsEnabled) {
      // Initialize ads only when consented and properly configured
      try {
        // MobileAds.instance.initialize(); // uncomment when enabling ads
        ref.read(adsManagerProvider).initialize();
      } catch (e) {
        // ignore init errors in early development
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
      useMaterial3: true,
    );
    return MaterialApp.router(
      title: 'Android Toolset',
      theme: theme,
      routerConfig: router,
    );
  }
}
