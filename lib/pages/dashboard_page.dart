// ignore_for_file: unused_import, unused_local_variable, unused_element

import 'package:finance_2026_2s/pages/finances_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard de Finanças')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Finances')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Erro ao carregar dados: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          double entradas = 0;
          double saidas = 0;
          Map<String, double> categorias = {};

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;

            final value = (data['value'] as num?)?.toDouble() ?? 0;
            final type = data['type'] ?? 'saida';

            if (type == 'entrada') {
              entradas += value;
            } else {
              saidas += value;

              final category = data['category'] ?? 'Outros';

              categorias[category] = (categorias[category] ?? 0) + value;
            }
          }

          final saldo = entradas - saidas;
          final maiorValor = entradas > saidas ? entradas : saidas;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumo financeiro',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text('${docs.length} movimentações encontradas'),
                const SizedBox(height: 20),
                _cardSaldo(
                  'Saldo',
                  saldo,
                  saldo > 0 ? Colors.green : Colors.red,
                  Icons.account_balance_wallet,
                ),
                IconButton(
                  icon: const Icon(Icons.list),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => FinancesPage()),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  //Componente do saldo
  Widget _cardSaldo(String titulo, double valor, Color cor, IconData icone) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icone, color: cor, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(
                    'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')},',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: cor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
