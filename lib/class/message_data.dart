import 'package:flutter/material.dart';
import 'package:kiosk_plugin/kiosk_plugin.dart';

class MessageData extends ChangeNotifier {
  List<Widget> _messages = [
    const MaterialButton(
      onPressed: KioskPlugin.stopKioskMode,
      child: Text('Stop Kiosk Mode'),
    ),
  ];

  List<Widget> get messages => _messages;

  void addWidget(String action, dynamic body) {
    switch (action) {
      case "message":
        messages.add(Text(body, textAlign: TextAlign.center));
        break;
    }
    notifyListeners();
  }
}