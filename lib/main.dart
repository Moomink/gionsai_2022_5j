import 'package:flutter/material.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:kiosk_plugin/kiosk_plugin.dart';
import 'package:torch_light/torch_light.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fullscreen/fullscreen.dart';
import 'package:kiosk_mode/kiosk_mode.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: '5J お化け屋敷',
      home: MyHomePage(title: 'OBAKE'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State createState() => TestHomePage();
}

class TestHomePage extends State<MyHomePage> {
  Future<void> fullscreen() async {
    await FullScreen.enterFullScreen(FullScreenMode.EMERSIVE);
  }

  Future<void> notify() {
    final flnp = FlutterLocalNotificationsPlugin();
    return flnp
        .initialize(
          InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          ),
        )
        .then((_) => flnp.show(
            0,
            'title',
            'body',
            NotificationDetails(
              android: AndroidNotificationDetails(
                'channel_id',
                'channel_name',
                channelDescription: 'channel_description',
                importance: Importance.max,
                priority: Priority.high,
              ),
            )));
  }

  late final Stream<KioskMode> _currentMode = watchKioskMode();
  double currentBrightness = 0.0;
  double _value = 0.0;
  bool _light = false;

  Future<void> toggleLight(bool light) async {
    if (light) {
      try {
        await TorchLight.enableTorch();
      } on Exception catch (_) {
        // Handle error
      }
    } else {
      try {
        await TorchLight.disableTorch();
      } on Exception catch (_) {
        // Handle error
      }
    }
  }

  @override
  void initState() {
    Future(() async {
      currentBrightness = await ScreenBrightness().current;
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
            OutlinedButton(onPressed: fullscreen, child: Text("FullScreen")),
            OutlinedButton(onPressed: notify, child: Text("Notification TEST")),
            SwitchListTile(
                title: Text("Light: $_light"),
                value: _light,
                onChanged: (bool v) async {
                  await toggleLight(v);
                  setState(() {
                    _light = v;
                  });
                }),
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
            StreamBuilder<double>(
              stream: ScreenBrightness().onCurrentBrightnessChanged,
              builder: (context, snapshot) {
                double changedBrightness = currentBrightness;
                if (snapshot.hasData) {
                  changedBrightness = snapshot.data!;
                }

                return Text(
                    'current brightness ${changedBrightness.toStringAsFixed(3)}');
              },
            ),
            Text('current value ${_value.toStringAsFixed(3)}.'),
            Slider(
              min: 0.0,
              max: 1.0,
              label: '$_value',
              value: _value,
              onChanged: (double bright) async {
                await ScreenBrightness().setScreenBrightness(bright);
                setState(() {
                  _value = bright;
                });
              },
            )
          ],
        )));
  }
}
