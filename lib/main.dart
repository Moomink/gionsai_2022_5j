import 'package:flutter/material.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:kiosk_plugin/kiosk_plugin.dart';
import 'package:torch_light/torch_light.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fullscreen/fullscreen.dart';
import 'package:kiosk_mode/kiosk_mode.dart';

/// main文アプリケーションを実行してる
void main() => runApp(const MyApp());

/**
全てをまとめたアプリケーションを定義
こいつ自体はタイトルを決めて他のウィジェットを呼び出してるだけ
**/
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

/**
上で呼び出されているウィジェット
タイトル文字列を受取り、状態をもとに色々描画？
**/
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State createState() => TestHomePage();
}

/// 上で読み込まれている状態
class TestHomePage extends State<MyHomePage> {
///フルスクリーン、実動作不明
  Future<void> fullscreen() async {
    await FullScreen.enterFullScreen(FullScreenMode.EMERSIVE);
  }
///通知、実動作不明
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
///他アプリ切り替え不能、実動作不明
  late final Stream<KioskMode> _currentMode = watchKioskMode();
  double currentBrightness = 0.0;
  double _value = 0.0;
  bool _light = false;
//ライトトグルしてる
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
///状態の初期化
  @override
  void initState() {
    Future(() async {
      currentBrightness = await ScreenBrightness().current;
      await FullScreen.enterFullScreen(FullScreenMode.EMERSIVE);
    });
    super.initState();
  }

/**
各種状態をもとにウィジェットを構成
ボタンとかテキストとか色々表示するようにしてる
**/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
///受け取ったタイトルを表示
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
