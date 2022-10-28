import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fullscreen/fullscreen.dart';
import 'package:vibration/vibration.dart';
import 'package:gionsai_5j/class/message_data.dart';
import 'package:gionsai_5j/class/utils.dart';
import 'package:kiosk_mode/kiosk_mode.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:audioplayers/audioplayers.dart';
import 'package:volume_control/volume_control.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:kiosk_plugin/kiosk_plugin.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State createState() => TestHomePage();
}

class TestHomePage extends State<MyHomePage> {
  final AudioCache _player = AudioCache();
  final _battery = Battery();
  bool _visible = false;
  bool _isClear = false;
  bool _isAction = false;
  bool _isActionEnd = false;

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
        case "battery":
          int nowBattery = await Battery().batteryLevel;
          Fluttertoast.showToast(
              msg: "now Battery : [${nowBattery}%]",
              gravity: ToastGravity.BOTTOM,
              toastLength: Toast.LENGTH_LONG,
            fontSize: 16.0
          );
          break;

        case "light":
          Utils.changeLight(enable: false);
          Utils.changeLight(enable: true);
          break;

        case "light_del":
          Utils.changeLight(enable: false);
          break;

        case "kiosk":
          var current = await getKioskMode();
          if (current == KioskMode.enabled) {
            Utils.changeKioskMode(enable: false);
          } else {
            Utils.changeKioskMode(enable: true);
          }
          break;

        case "clear":
          Utils.changeLight(enable: false);
          context.read<MessageData>().clear();
          VolumeControl.setVolume(0.4);
          Utils.changeKioskMode(enable: true);
          Utils.changeLight(enable: true);
          Utils.changeBrightness(0.9);

          _isClear = true;
          break;

        case "surprise":
          _isAction = true;
          var loop = await _player.loop("tutu4.mp3");

          VolumeControl.setVolume(1.0);
          Utils.changeLight(enable: false);
          setState(() {
            context.read<MessageData>().clear();
            _visible = true;
          });

          Vibration.vibrate(duration: 2000);

          // _isClear = true;

          await Future.delayed(const Duration(seconds: 2), () {
            setState(() {
              _visible = false;
            });
          });
          loop.stop();

          VolumeControl.setVolume(0.4);
          _isAction = false;
          _isActionEnd = true;
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
        appBar: AppBar(
          leading: const Icon(Icons.arrow_back_ios),
          centerTitle: true,
          title: const Text("♥ miyu ♥"),
        ),
        body: Stack(children: <Widget>[
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Flexible(
                    child: StreamBuilder(
                  stream: context.watch<MessageData>().stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text("ERROR");
                      //TODO 何とかする
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Container();
                    } else {
                      if (_isClear) {
                        var _ = snapshot.data;
                        _isClear = false;
                        return Container();
                      }
                      if (_isAction == false) {
                        if (_isActionEnd == false) {
                          context
                              .read<MessageData>()
                              .messages
                              .add(snapshot.data!);
                        } else {
                          _isActionEnd = false;
                        }
                      }
                      var widgetList = context.read<MessageData>().messages;
                      print(
                          "length:${context.read<MessageData>().messages.length}");
                      return ListView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: widgetList.length,
                          itemBuilder: (context, index) {
                            return widgetList[index];
                          });
                    }
                  },
                )),
                Image.asset("assets/chat.jpg")
              ]),
          Center(
              child: Visibility(
                  visible: _visible,
                  child: FittedBox(
                      fit: BoxFit.cover,
                      child: Image.asset("assets/baby.gif"))))
        ]));
  }
}
