import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("🎉 Selesai"),
            const Text("+50 XP"),

            ElevatedButton(
              onPressed: () => context.go('/simulation'),
              child: const Text("Main Lagi"),
            )
          ],
        ),
      ),
    );
  }
}