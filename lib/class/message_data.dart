import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kiosk_plugin/kiosk_plugin.dart';

class MessageData extends ChangeNotifier {
  final _controller = StreamController<Widget>();

  /*
  List<Widget> _messages = [
    const MaterialButton(
      onPressed: KioskPlugin.stopKioskMode,
      child: Text('Stop Kiosk Mode'),
    ),
  ];
  */


 // List<Widget> get messages => _messages;

  Stream<Widget> get stream => _controller.stream;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.close();
  }

  void addWidget(String action, dynamic body) {
    late Widget widget;

    switch (action) {
      case "message":
        print("Received [$body].");
        widget = Text(body, textAlign: TextAlign.center);
        break;

      case "image":
        String base = body.split(',')[1];
        print("Received [$base]");
        var imageData = base64Decode(base);
        widget = Image.memory(imageData);
        break;
    }

    // notifyListeners();
    // _messages.add(widget);
    _controller.sink.add(widget);
  }
}