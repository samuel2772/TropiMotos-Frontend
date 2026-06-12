import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_routes.dart';
import 'config/app_theme.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(const TropiMotosApp());
}

class TropiMotosApp extends StatelessWidget {
  const TropiMotosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'TropiMotos',
        theme: AppTheme.darkTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
