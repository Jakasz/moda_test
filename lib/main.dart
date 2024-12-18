import 'package:avg_moda_test/providers/calculation_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => CalculationData())],
        child: MaterialApp(home: HomePage()));
  }
}
