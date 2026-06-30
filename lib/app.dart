import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:leximpactai/domain/presentation/pages/about_page.dart';
import 'package:leximpactai/core/theme/app_theme.dart';
import 'package:leximpactai/domain/presentation/pages/home_page.dart';
import 'package:leximpactai/domain/presentation/pages/materi_page.dart';
import 'package:leximpactai/domain/presentation/pages/quiz_page.dart';
import 'package:leximpactai/domain/presentation/pages/simulation_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main()  async {

  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    /// 🏠 HOME
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),

    /// 🎮 SIMULASI
    GoRoute(
      path: '/simulation',
      builder: (context, state) => const SimulationPage(),
    ),

    /// 📚 MATERI
    GoRoute(
      path: '/materi',
      builder: (context, state) => const MateriPage(),
    ),

    // 🧪 KUIS
    GoRoute(
      path: '/quiz',
      builder: (context, state) => const QuizPage(),
    ),

      GoRoute(
      path: '/about',
      builder: (context, state) => const AboutPage(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      routerConfig: _router,
    );
  }
}
