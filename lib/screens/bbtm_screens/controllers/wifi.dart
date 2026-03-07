// import 'dart:developer' as developer;
// import 'dart:io';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';
// import 'package:network_info_plus/network_info_plus.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// import '../../../controllers/permission.dart';
//
// class NetworkService {
//   final NetworkInfo _networkInfo = NetworkInfo();
//
//   Future<String?> initNetworkInfo() async {
//     String? wifiName = 'Unknown';
//     try {
//       await requestPermission(Permission.nearbyWifiDevices);
//     } catch (e) {
//       debugPrint(e.toString());
//     }
//
//     try {
//       if (!kIsWeb && Platform.isIOS) {
//         // iOS specific logic for network info
//         // var status = await _networkInfo.getLocationServiceAuthorization();
//         // if (status == LocationAuthorizationStatus.notDetermined) {
//         //   status = await _networkInfo.requestLocationServiceAuthorization();
//         // }
//         // if (status == LocationAuthorizationStatus.authorizedAlways ||
//         //     status == LocationAuthorizationStatus.authorizedWhenInUse) {
//         //   wifiName = await _networkInfo.getWifiName();
//         // } else {
//         //   wifiName = await _networkInfo.getWifiName();
//         // }
//       } else {
//         wifiName = await _networkInfo.getWifiName();
//       }
//     } on PlatformException catch (e) {
//       developer.log('Failed to get Wifi Name', error: e);
//       wifiName = 'Failed to get Wifi Name';
//     }
//     debugPrint(wifiName);
//     return wifiName?.replaceAll('"', "").trim() ?? "unknown";
//   }
// }

import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class NetworkService {
  final NetworkInfo _networkInfo = NetworkInfo();

  Future<String?> initNetworkInfo() async {
    try {
      // iOS requires location permission
      if (Platform.isIOS) {
        final status = await Permission.locationWhenInUse.request();
        if (!status.isGranted) {
          debugPrint("iOS: Location permission denied");
          return null;
        }
      }
      if (Platform.isIOS && !kIsWeb) {
        // iOS simulator will always return null
        debugPrint("iOS Simulator: WiFi SSID not available, use a real device");
      }
      // Android requires location permission (Android 8+)
      if (Platform.isAndroid) {
        final status = await Permission.location.request();
        if (!status.isGranted) {
          debugPrint("Android: Location permission denied");
          return null;
        }
      }

      final wifiName = await _networkInfo.getWifiName();

      debugPrint("SSID: $wifiName");

      return wifiName?.replaceAll('"', '').trim();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi Name', error: e);
      return null;
    } catch (e) {
      developer.log('Unexpected error getting Wifi Name', error: e);
      return null;
    }
  }
}
