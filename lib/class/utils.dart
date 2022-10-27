import 'package:torch_light/torch_light.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:kiosk_plugin/kiosk_plugin.dart';
import 'package:kiosk_mode/kiosk_mode.dart';

class Utils {
  bool _light = false;
  //フラッシュの切り替え  引数にtrueがあると光る
  static Future<void> changeLight({required bool enable}) async {
    if (enable) {
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

  //明るさの変更
  static Future<void> changeBrightness(double value) async {
    await ScreenBrightness().setScreenBrightness(value);
  }

  //KioskModeの変更 引数にtrueがあるとKioskModeになる
  static Future<void> changeKioskMode({required bool enable}) async {
    if (enable) {
      KioskPlugin.startKioskMode();
    } else {
      KioskPlugin.stopKioskMode();
    }
  }
}
