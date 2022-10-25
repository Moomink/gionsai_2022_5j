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
  IO.Socket socket = IO.io('http://192.168.11.10:18526', <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false,
  });

  late final Stream<KioskMode> _currentMode = watchKioskMode();

  @override
  void initState() {
    super.initState();
    IO.Socket socket = IO.io('http://192.168.11.10:18526', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.onConnect((_) {
      print('connect');
    });
    socket.on(
        "message",
        (data) => Provider.of<MessageData>(context, listen: false)
            .addWidget("message", data));

    socket.onDisconnect((_) => print('disconnect'));

    socket.connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
            child: StreamBuilder(
          stream: context.watch<MessageData>().stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text("ERROR");
              //TODO 何とかする
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            } else {
              var widgetList = context.watch<MessageData>().messages;
              return ListView.builder(
                  itemCount: widgetList.length,
                  itemBuilder: (context, index) {
                    return widgetList[index];
                  });
            }
          },
        )));
  }
}
