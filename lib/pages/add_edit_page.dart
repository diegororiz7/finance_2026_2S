//Importações de dependências
// ignore_for_file: unused_import, unused_field, prefer_final_fields, unused_local_variable, deprecated_member_use, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'finances_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEditPage extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? data;

  const AddEditPage({super.key, this.docId, this.data});

  @override
  State<AddEditPage> createState() => _AddEditPageState();
}

class _AddEditPageState extends State<AddEditPage> {
  //Variáveis iniciais
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _valueController = TextEditingController();
  String _category = '';
  String _type = 'saida';
  DateTime _selectDate = DateTime.now();

  //Lista de categorias
  final Map<String, List<String>> categories = {
    'entrada': ['Salário', 'Vendas', 'Outros'],
    'saida': ['Alimentação', 'Lazer', 'Saúde', 'Educação', 'Outros'],
  };

  //Definição do valor inicial
  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      _descriptionController.text = widget.data!['description'];
      _valueController.text = (widget.data!['value']).toString();
      _category = widget.data!['category'];
      _type = (widget.data!['type'] ?? 'saida');
      _selectDate = (widget.data!['date'] as Timestamp).toDate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCategories = categories[_type];
    return Scaffold(
      //Definição do título da página
      appBar: AppBar(
        title: Text(
          widget.docId != null ? 'Editar registro' : 'Adicionar registro',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        //Formulário de inclusão/edição das tarefas
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição:'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Informe a descrição'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _valueController,
                decoration: const InputDecoration(labelText: 'Valor:'),
                validator: (value) {
                  final numero = double.tryParse(value!.replaceAll(',', '.'));

                  if (numero == null || numero.isNaN || numero <= 0) {
                    return 'Informe um valor válido!';
                  }

                  return null;
                },
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField(
                value: _type,
                items: const [
                  DropdownMenuItem(child: Text('entrada'), value: 'entrada'),
                  DropdownMenuItem(child: Text('saida'), value: 'saida'),
                ],
                decoration: const InputDecoration(labelText: 'Tipo:'),
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                    _category = '';
                  });
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField(
                value: _category.isNotEmpty ? _category : null,
                items: currentCategories!
                    .map((c) => DropdownMenuItem(child: Text(c), value: c))
                    .toList(),
                decoration: const InputDecoration(labelText: 'Categoria:'),
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                  });
                },
                validator: (value) => value == null || value.isEmpty
                    ? 'Selecione a categoria'
                    : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'Data: ${_selectDate.day.toString().padLeft(2, '0')}/${_selectDate.month.toString().padLeft(2, '0')}/${_selectDate.year}',
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: Text(
                      'Selecionar data',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectDate,
                        firstDate: DateTime(2025),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectDate = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    //Associandos os campos do formulário ao banco
                    final data = {
                      'description': _descriptionController.text,
                      'value': (double.tryParse(_valueController.text) ?? 0),
                      'category': _category,
                      'type': _type,
                      'date': Timestamp.fromDate(_selectDate),
                    };

                    if (widget.data != null) {
                      //Editando registro
                      FirebaseFirestore.instance
                          .collection('Finances')
                          .doc(widget.docId)
                          .update(data);
                    } else {
                      //Adicionando registro
                      FirebaseFirestore.instance
                          .collection('Finances')
                          .add(data);
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => FinancesPage()),
                    );
                  }
                },
                child: Text(
                  widget.docId != null ? 'Salvar edição' : 'Adicionar registro',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
