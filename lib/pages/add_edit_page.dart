// ignore_for_file: unused_import

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
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
