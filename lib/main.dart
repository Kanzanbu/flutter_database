import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Detect platform and initialize the correct database factory
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await DatabaseHelper.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQLite Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SQLiteScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SQLiteScreen extends StatefulWidget {
  const SQLiteScreen({super.key});

  @override
  State<SQLiteScreen> createState() => _SQLiteScreenState();
}

class _SQLiteScreenState extends State<SQLiteScreen> {
  String _output = '';

  void _insert() async {
    await DatabaseHelper.insertItem({'name': 'Item ${DateTime.now().millisecondsSinceEpoch}'});
    setState(() => _output = 'Inserted new record');
  }

  void _query() async {
    final items = await DatabaseHelper.getItems();
    setState(() => _output = 'Query result:\n${items.map((e) => e['name']).join('\n')}');
  }

  void _update() async {
    await DatabaseHelper.updateFirstItem('Updated Item');
    setState(() => _output = 'Updated first record');
  }

  void _delete() async {
    await DatabaseHelper.clearItems();
    setState(() => _output = 'All records deleted');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('sqlite')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButton('insert', _insert),
            _buildButton('query', _query),
            _buildButton('update', _update),
            _buildButton('delete', _delete),
            const SizedBox(height: 20),
            Text(_output, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          minimumSize: const Size(100, 40),
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
