import 'package:flutter/material.dart';
import 'package:gionsai_5j/class/message_data.dart';
import 'package:kiosk_mode/kiosk_mode.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:kiosk_plugin/kiosk_plugin.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State createState() => TestHomePage();
}

class TestHomePage extends State<MyHomePage> {
  List<Widget> _messages = [];

  IO.Socket socket = IO.io('http://192.168.11.10:18526', <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false,
  });

  @override
  void initState() {
    super.initState();

    socket.onConnect((_) {
      print('connect');
    });
    socket.on(
        "message",
        (data) => Provider.of<MessageData>(context, listen: false)
            .addWidget("message", data));
    socket.on(
        "image",
        (data) => Provider.of<MessageData>(context, listen: false)
            .addWidget("image", data));

    socket.on(
        "template",
        (data) => Provider.of<MessageData>(context, listen: false)
            .addWidget("template", data));

    socket.on(
        "action",
        (data) => (data) {
              switch (data) {
                case "clear":
                  context.read<MessageData>().clear();
                  break;
              }
            });
    socket.onDisconnect((_) => print('disconnect'));

    socket.connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: <Widget>[
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        AppBar(
          leading: const Icon(Icons.arrow_back_ios),
          centerTitle: true,
          title: const Text("♥ miyu ♥"),
        ),
        Flexible(
            child: StreamBuilder(
          stream: context.watch<MessageData>().stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text("ERROR");
              //TODO 何とかする
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            } else {
              context.read<MessageData>().messages.add(snapshot.data!);
              var widgetList = context.read<MessageData>().messages;
              return ListView.builder(
                  itemCount: widgetList.length,
                  itemBuilder: (context, index) {
                    return widgetList[index];
                  });
            }
          },
        )),
        Image.asset("assets/chat.jpg")
      ]),
    ]));
  }
}
