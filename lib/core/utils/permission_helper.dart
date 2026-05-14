import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future<void> requestBatteryOptimization() async {
    final status = await Permission.ignoreBatteryOptimizations.status;
    if (!status.isGranted) {
      await Permission.ignoreBatteryOptimizations.request();
    }
  }
}