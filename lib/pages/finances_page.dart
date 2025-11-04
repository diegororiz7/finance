// ignore_for_file: unused_import, unused_element, unused_local_variable, use_build_context_synchronously, sort_child_properties_last

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
  //variaves de busca e ordenação
  String searchText = '';
  String filterType = 'todos';
  String sortBy = 'date';

  //definir icones das categorias
  final Map<String, IconData> categoryIcons = {
    'Educação': Icons.school,
    'Saúde': Icons.local_hospital,
    'Alimentação': Icons.restaurant,
    'Lazer': Icons.sports_esports,
    'Salário': Icons.attach_money,
    'Vendas': Icons.store,
    'Outros': Icons.category,
  };

  //define cor do cartão
  Color _getCardColor(String type) {
    return type == 'entrada' ? Colors.green.shade400 : Colors.red.shade400;
  }

  //definir o ícone da categoria
  IconData _getCardIcon(String category, String type) {
    if (categoryIcons.containsKey(category)) {
      return categoryIcons[category]!;
    }
    return type == 'entrada' ? Icons.arrow_circle_up : Icons.arrow_circle_down;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('Finanças Pessoais')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                DropdownButton<String>(
                  value: filterType,
                  items: const [
                    DropdownMenuItem(value: 'todos', child: Text('Todos')),
                    DropdownMenuItem(value: 'entrada', child: Text('Entradas')),
                    DropdownMenuItem(value: 'saida', child: Text('Saídas')),
                  ],
                  onChanged: (val) {
                    setState(() {
                      filterType = val!;
                    });
                  },
                ),
                DropdownButton<String>(
                  value: sortBy,
                  items: const [
                    DropdownMenuItem(value: 'date', child: Text('Data')),
                    DropdownMenuItem(
                      value: 'entrada',
                      child: Text('Entradas primeiro'),
                    ),
                    DropdownMenuItem(
                      value: 'saida',
                      child: Text('Saídas primeiro'),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() {
                      sortBy = val!;
                    });
                  },
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Pesquisar descrição...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      setState(() {
                        searchText = val.toLowerCase();
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
                    return aType == 'entrada' ? -1 : 1;
                  });
                } else if (sortBy == 'saida') {
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
                    return aType == 'saida' ? -1 : 1;
                  });
                } else {
                  filteredDocs.sort((a, b) {
                    final aDate =
                        (a.data() as Map<String, dynamic>)['date'] as Timestamp;
                    final bDate =
                        (b.data() as Map<String, dynamic>)['date'] as Timestamp;
                    return bDate.compareTo(aDate);
                  });
                }

                //Calcular o resumo
                double totalEntrada = 0;
                double totalSaida = 0;
                for (var doc in filteredDocs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final value = (data['value'] ?? 0).toDouble();
                  if ((data['type'] ?? 'saida') == 'entrada') {
                    totalEntrada += value;
                  } else {
                    totalSaida += value;
                  }
                }
                final saldo = totalEntrada - totalSaida;

                if (filteredDocs.isEmpty) {
                  return const Center(
                    child: Text('Não existem dados a serem exibidos'),
                  );
                }

                return Column(
                  children: [
                    //Resumo financeiro
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.blue.shade50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            'Entrada: R\$ ${totalEntrada.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Saída: R\$ ${totalSaida.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Saldo: R\$ ${saldo.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: saldo > 0
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    //Lista de registros
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, index) {
                          final doc = filteredDocs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final type = data['type'] ?? 'saida';
                          final description = data['description'] ?? '';
                          final category = data['category'] ?? 'Outros';
                          final value = (data['value'] ?? 0).toDouble();
                          final date = (data['date'] as Timestamp).toDate();

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            color: _getCardColor(type),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: Icon(
                                _getCardIcon(category, type),
                                size: 40,
                                color: Colors.white,
                              ),
                              title: Text(
                                description,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Text(
                                'Categoria: $category\nData: ${date.day}/${date.month}/${date.year}',
                                style: TextStyle(color: Colors.white),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Valor: R\$ ${value.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.orange,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AddEditPage(
                                            docId: doc.id,
                                            data: data,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.purple,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Confirmação'),
                                            content: const Text(
                                              'Deseja realmente excluir o registro?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text(
                                                  'Não',
                                                  style: TextStyle(
                                                    color: Colors.purple,
                                                  ),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  FirebaseFirestore.instance
                                                      .collection('Finances')
                                                      .doc(doc.id)
                                                      .delete()
                                                      .then(
                                                        (_) => Navigator.of(
                                                          context,
                                                        ).pop(),
                                                      );
                                                },
                                                child: Text(
                                                  'Sim',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      //Botão de incluir registros
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddEditPage()),
          );
        },
      ),
    );
  }
}
