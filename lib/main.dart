//Importações de páginas e dependências
// ignore_for_file: unused_import

import 'package:finance_2026_2s/config/firebase_config.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:finance_2026_2s/pages/finances_page.dart';
import 'package:finance_2026_2s/pages/add_edit_page.dart';

//Função principal
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseConfig.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de Finanças',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const FinancesPage(),
    );
  }
}
