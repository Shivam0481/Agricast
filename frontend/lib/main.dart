import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/app_state.dart';
import 'screens/landing_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/scenario_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/about_screen.dart';
import 'widgets/app_shell.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..loadDistricts(),
      child: const AgriCastApp(),
    ),
  );
}

class AgriCastApp extends StatelessWidget {
  const AgriCastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriCAST — Crop Recommendation System',
      debugShowCheckedModeBanner: false,
      theme: AgriCastTheme.theme,
      home: const AppRootView(),
    );
  }
}

class AppRootView extends StatelessWidget {
  const AppRootView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    if (state.currentScreen == AppScreen.landing) {
      return const LandingScreen();
    }

    return AppShell(
      currentScreen: state.currentScreen,
      child: _screenFor(state.currentScreen),
    );
  }

  Widget _screenFor(AppScreen screen) {
    return switch (screen) {
      AppScreen.landing => const LandingScreen(),
      AppScreen.dashboard => const DashboardScreen(),
      AppScreen.scenario => const ScenarioScreen(),
      AppScreen.analytics => const AnalyticsScreen(),
      AppScreen.reports => const ReportsScreen(),
      AppScreen.about => const AboutScreen(),
    };
  }
}
