// ignore_for_file: unused_import, unused_field, prefer_final_fields, unused_local_variable, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'add_edit_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEditPage extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? data;
  const AddEditPage({super.key, this.docId, this.data});

  @override
  State<AddEditPage> createState() => _AddEditPageState();
}

class _AddEditPageState extends State<AddEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _valueController = TextEditingController();
  String _category = '';
  String _type = 'saida';
  DateTime _selectedDate = DateTime.now();

  //Lista de categorias
  final Map<String, List<String>> categories = {
    'entrada': ['Salário', 'Vendas', 'Outros'],
    'saida': ['Alimentação', 'Saúde', 'Lazer', 'Educação', 'Outros'],
  };

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      _descriptionController.text = widget.data!['description'];
      _valueController.text = (widget.data!['value']).toString();
      _category = widget.data!['category'];
      _type = widget.data!['type'] ?? 'saida';
      _selectedDate = (widget.data!['date'] as Timestamp).toDate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCategories = categories[_type];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.docId == null ? 'Adicionar registro' : 'Editar registro',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição:'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Informe a descrição' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _valueController,
                decoration: const InputDecoration(labelText: 'Valor:'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Informe o valor' : null,
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField(
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'entrada', child: Text('entrada')),
                  DropdownMenuItem(value: 'saida', child: Text('saida')),
                ],
                onChanged: (val) {
                  setState(() {
                    _type = val!;
                    _category = '';
                  });
                },
                decoration: const InputDecoration(labelText: 'Tipo:'),
              ),
              DropdownButtonFormField(
                value: _category.isNotEmpty ? _category : null,
                items: currentCategories!
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _category = val!;
                  });
                },
                validator: (val) =>
                    val == null || val.isEmpty ? 'Selecione a categoria' : null,
                decoration: const InputDecoration(labelText: 'Categoria:'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'Data: ${_selectedDate.toLocal().toString().split('')[0]}',
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    child: Text(
                      'Selecionar data',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final data = {
                      'description': _descriptionController.text,
                      'value': (double.tryParse(_valueController.text) ?? 0),
                      'type': _type,
                      'category': _category,
                      'date': Timestamp.fromDate(_selectedDate),
                    };
                    if (widget.docId == null) {
                      FirebaseFirestore.instance
                          .collection('Finances')
                          .add(data);
                    } else {
                      FirebaseFirestore.instance
                          .collection('Finances')
                          .doc(widget.docId)
                          .update(data);
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  widget.docId == null ? 'Adicionar' : 'Editar',
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
