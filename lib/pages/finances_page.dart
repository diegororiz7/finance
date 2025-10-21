// ignore_for_file: unused_import, unused_element

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'add_edit_page.dart';

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
    return type == 'entrada' ? Colors.green.shade700 : Colors.red.shade700;
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
    return const Placeholder();
  }
}
