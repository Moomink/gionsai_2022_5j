import 'package:flutter/material.dart';
import 'package:kiosk_mode/kiosk_mode.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:kiosk_plugin/kiosk_plugin.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State createState() => TestHomePage();
}

class TestHomePage extends State<MyHomePage> {
  final List<Widget> _messages = [const MaterialButton(
    onPressed: KioskPlugin.stopKioskMode,
    child: Text('Stop Kiosk Mode'),
  ),];
  late final Stream<KioskMode> _currentMode = watchKioskMode();

  @override
  void initState() {
    super.initState();
    IO.Socket socket = IO.io('http://192.168.11.2:3000');
    socket.onConnect((_) {
      print('connect');
    });
    socket.on("message",(data)=>{
      _messages.add(Text(data))
    });
    socket.onDisconnect((_) => print('disconnect'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body:ListView(
          children: _messages,
        )
    );
  }
}
