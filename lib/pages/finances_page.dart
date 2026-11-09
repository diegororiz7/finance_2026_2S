//Importações de dependências
// ignore_for_file: unused_import, unused_element, unused_local_variable

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

  //Definir ícones das categorias
  final Map<String, IconData> categoryIcons = {
    'Educação': Icons.school,
    'Saúde': Icons.local_hospital,
    'Alimentação': Icons.restaurant,
    'Lazer': Icons.sports_esports,
    'Salário': Icons.attach_money,
    'Vendas': Icons.store,
    'Outros': Icons.category,
  };

  //Definir a cor do Card
  Color _getCardColor(String type) {
    return type == 'entrada' ? Colors.green.shade400 : Colors.red.shade400;
  }

  //Definir o ícone da categoria
  IconData _getCardIcon(String category, String type) {
    if (categoryIcons.containsKey(category)) {
      return categoryIcons[category]!;
    }
    return type == 'entrada' ? Icons.arrow_circle_up : Icons.arrow_circle_down;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Finanças Pessoais'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: filterType,
                  items: const [
                    DropdownMenuItem(
                      value: 'todos',
                      child: Text('Entradas & Saídas'),
                    ),
                    DropdownMenuItem(
                      value: 'entrada',
                      child: Text('Somente Entradas'),
                    ),
                    DropdownMenuItem(
                      value: 'saida',
                      child: Text('Somente Saídas'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      filterType = value!;
                    });
                  },
                ),
                DropdownButton<String>(
                  value: sortBy,
                  items: const [
                    DropdownMenuItem(
                      value: 'entrada',
                      child: Text('Entradas Primeiro'),
                    ),
                    DropdownMenuItem(
                      value: 'saida',
                      child: Text('Saídas Primeiro'),
                    ),
                    DropdownMenuItem(
                      value: 'date',
                      child: Text('Ordenado por Data'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      sortBy = value!;
                    });
                  },
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Pesquisar descrição',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchText = value.toLowerCase();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Finances')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                //Filtrar documentos
                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final type = data['type'] ?? 'saida';
                  final description = (data['description'] ?? '')
                      .toString()
                      .toLowerCase();
                  final typeMatch = filterType == 'todos' || type == filterType;
                  final searchMatch = description.contains(searchText);
                  return typeMatch && searchMatch;
                }).toList();

                //Ordenar documentos
                if (sortBy == 'entrada') {
                  filteredDocs.sort((a, b) {
                    final aType =
                        (a.data() as Map<String, dynamic>)['type'] ?? 'saida';
                    final bType =
                        (b.data() as Map<String, dynamic>)['type'] ?? 'saida';
                    if (aType == bType) {
                      final aDate =
                          (a.data() as Map<String, dynamic>)['date']
                              as Timestamp;
                      final bDate =
                          (b.data() as Map<String, dynamic>)['date']
                              as Timestamp;
                      return bDate.compareTo(aDate);
                    }
                    return aType == 'entrda' ? -1 : 1;
                  });
                } else if (filterType == 'saida') {
                } else {}

                return Center();
              },
            ),
          ),
        ],
      ),
    );
  }
}
