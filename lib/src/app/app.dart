import 'package:flutter/material.dart';
import '../features/boutique/presentation/controllers/boutique_selection_controller.dart';
import 'app_routes.dart';
import 'app_theme.dart';

/// Root application widget for Kapada Creation Customer application.
class KcApp extends StatefulWidget {
  const KcApp({super.key});

  @override
  State<KcApp> createState() => _KcAppState();
}

class _KcAppState extends State<KcApp> {
  final _selectionController = BoutiqueSelectionController();

  @override
  void dispose() {
    _selectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BoutiqueSelectionScope(
      controller: _selectionController,
      child: MaterialApp.router(
        title: 'Kapada Creation',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
