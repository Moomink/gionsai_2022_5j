import 'package:flutter/material.dart';
import 'package:gionsai_5j/class/message_data.dart';
import 'package:gionsai_5j/class/utils.dart';
import 'package:kiosk_mode/kiosk_mode.dart';
import 'package:nil/nil.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:audioplayers/audioplayers.dart';
import 'package:kiosk_plugin/kiosk_plugin.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State createState() => TestHomePage();
}

class TestHomePage extends State<MyHomePage> {
  final AudioCache _player = AudioCache();
  bool _visible = false;
  bool _isClear = false;
  bool _isAction = false;
  bool _isActionEnd = false;
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

    socket.on("action", (data) async {
      switch (data) {
        case "clear":
          context.read<MessageData>().clear();
          Utils.changeKioskMode(enable: true);
          Utils.changeLight(enable: true);

          this._isClear = true;
          break;

        case "surprise":
          this._isAction = true;
          var loop = await _player.loop("tutu4.mp3");

          Utils.changeLight(enable: false);
          setState(() {
            _visible = true;
          });

          await Future.delayed(Duration(seconds: 1), () {
            setState(() {
              _visible = false;
            });
          });
          loop.stop();
          this._isAction = false;
          this._isActionEnd = true;
          break;
      }
    });
    socket.onDisconnect((_) => print('disconnect'));

    socket.connect();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
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
            } else if (snapshot.connectionState == ConnectionState.waiting ||
                snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            } else {
              if (this._isClear) {
                var _ = snapshot.data;
                this._isClear = false;
                return Container();
              }
              if (this._isAction == false) {
                if (this._isActionEnd == false) {
                  context.read<MessageData>().messages.add(snapshot.data!);
                } else {
                  this._isActionEnd = false;
                }
              }
              var widgetList = context.read<MessageData>().messages;
              print("length:${context.read<MessageData>().messages.length}");
              return ListView.builder(
                  physics: ClampingScrollPhysics(),
                  itemCount: widgetList.length,
                  itemBuilder: (context, index) {
                    return widgetList[index];
                  });
            }
          },
        )),
        Image.asset("assets/chat.jpg")
      ]),
      Visibility(
          visible: _visible,
          child: FittedBox(
              child: Image.asset("assets/baby.gif"), fit: BoxFit.fill))
    ]));
  }
}
