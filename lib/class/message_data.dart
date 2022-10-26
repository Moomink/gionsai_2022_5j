import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gionsai_5j/widget/chat_container.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:kiosk_plugin/kiosk_plugin.dart';

class MessageData extends ChangeNotifier {
  final _controller = StreamController<Widget>();

  final AudioCache _player = AudioCache();

  final List<Widget> _messages = [];

  List<Widget> get messages => _messages;

  Stream<Widget> get stream => _controller.stream;


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.close();
  }

  void clear(){
    this.messages.clear();
    notifyListeners();
  }

  void addWidget(String action, dynamic body) {
    late Widget widget;
    this._player.play("line_simplebell.mp3");
    switch (action) {
      case "message":
        print("Received [$body].");
        this._player.play("line_simplebell.mp3");
        widget = ChatContainer(child: Text(body));
        break;

      case "image":
        String base = body.split(',')[1];
        print("Received [$base]");
        var image = Image.memory(base64Decode(base));
        widget = ChatContainer(child: image, isImage: true);
        break;

      case "template":
        var jsonData = jsonDecode(body);
    }

    // notifyListeners();
    // _messages.add(widget);
    _controller.sink.add(widget);
  }
}
