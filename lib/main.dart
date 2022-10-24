import 'package:flutter/material.dart';

import './widget/home_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: '5J お化け屋敷',
      home: MyHomePage(title: 'OBAKE'),
    );
  }
}
