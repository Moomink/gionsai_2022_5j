class Utils {
  //フラッシュの切り替え  引数にtrueがあると光る
  static Future<void> toggleLight([bool enable = true]) {}

  //明るさの変更
  static Future<void> changeBrightness(double value) {}

  //KioskModeの変更 引数にtrueがあるとKioskModeになる
  static Future<void> toggleKioskMode([bool enable = true]) {}
}
