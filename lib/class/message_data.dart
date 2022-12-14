import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:gionsai_5j/widget/chat_container.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:gionsai_5j/class/utils.dart';

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

  void clear() {
    messages.clear();
    notifyListeners();
  }

  void addWidget(String action, dynamic body) {
    late Widget widget;
    _player.play("line_simplebell.mp3");
    switch (action) {
      case "debugMessage":
        Utils.changeBrightness(0.9);
        print("Debug Received [$body].");
        // _player.play("line_simplebell.mp3");
        Vibration.vibrate();
        widget = ChatContainer(
            child: Text(body, style: const TextStyle(color: Colors.red)));
        break;

      case "message":
        Utils.changeBrightness(0.9);
        print("Received [$body].");
        Vibration.vibrate();
        // _player.play("line_simplebell.mp3");
        widget = ChatContainer(child: Text(body));
        if (body == "うしろ") {
          print(" うしろ検知");
          Future.delayed(const Duration(seconds: 2), () {
            Utils.changeBrightness(0.01);
          });
        }
        break;

      case "image":
        String base = body.split(',')[1];
        print("Received [$base]");
        Vibration.vibrate();
        var image = GestureDetector(child: Image.memory(base64Decode(base)));
        widget = ChatContainer(isImage: true, child: image);
        break;
    }

    // notifyListeners();
    // _messages.add(widget);
    _controller.sink.add(widget);
  }
}
