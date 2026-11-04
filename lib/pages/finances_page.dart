//Importações de dependências
// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'add_edit_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FinancesPage extends StatefulWidget {
  const FinancesPage({super.key});

  @override
  State<FinancesPage> createState() => _FinancesPageState();
}

class _FinancesPageState extends State<FinancesPage> {
  //Variáveis de busca e ordenação
  String searchText = '';
  String filterType = 'todos';
  String sortBy = 'date';

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
