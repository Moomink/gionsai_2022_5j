import 'package:flutter/material.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:kiosk_plugin/kiosk_plugin.dart';
import 'package:torch_light/torch_light.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fullscreen/fullscreen.dart';
import 'package:kiosk_mode/kiosk_mode.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State createState() => TestHomePage();
}

class TestHomePage extends State<MyHomePage> {
  late final Stream<KioskMode> _currentMode = watchKioskMode();

  @override
  void initState() {
    Future(() async {
      await FullScreen.enterFullScreen(FullScreenMode.EMERSIVE);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const MaterialButton(
              onPressed: KioskPlugin.startKioskMode,
              child: Text('Start Kiosk Mode'),
            ),
            const MaterialButton(
              onPressed: KioskPlugin.stopKioskMode,
              child: Text('Stop Kiosk Mode'),
            ),
            MaterialButton(
              onPressed: () => getKioskMode().then(
                (value) => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Kiosk mode: $value')),
                ),
              ),
              child: const Text('Check mode'),
            ),
            StreamBuilder<KioskMode>(
              stream: _currentMode,
              builder: (context, snapshot) => Text(
                'Current mode: ${snapshot.data}',
              ),
            ),
          ],
        )));
  }
}
