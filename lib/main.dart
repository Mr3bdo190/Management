import 'package:flutter/material.dart';

void main() {
  runApp(const FactoryApp());
}

class FactoryApp extends StatelessWidget {
  const FactoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Factory Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('جاري بناء نظام إدارة المصنع...', style: TextStyle(fontSize: 24)),
        ),
      ),
    );
  }
}
