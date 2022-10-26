import 'package:flutter/material.dart';
import 'package:gionsai_5j/class/message_data.dart';
import 'package:provider/provider.dart';

import './widget/home_page.dart';

void main() => runApp(MultiProvider(
    providers: [ChangeNotifierProvider(create: (_) => MessageData())],
    child: const MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: '5J お化け屋敷',
      theme: ThemeData.dark(),
      home: MyHomePage(title: 'OBAKE'),
    );
  }
}
