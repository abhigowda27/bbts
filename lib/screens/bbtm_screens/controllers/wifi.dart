import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../controllers/permission.dart';

class NetworkService {
  final NetworkInfo _networkInfo = NetworkInfo();

  Future<String?> initNetworkInfo() async {
    String? wifiName = 'Unknown';
    try {
      await requestPermission(Permission.nearbyWifiDevices);
    } catch (e) {
      debugPrint(e.toString());
    }

    try {
      if (!kIsWeb && Platform.isIOS) {
        // iOS specific logic for network info
        // var status = await _networkInfo.getLocationServiceAuthorization();
        // if (status == LocationAuthorizationStatus.notDetermined) {
        //   status = await _networkInfo.requestLocationServiceAuthorization();
        // }
        // if (status == LocationAuthorizationStatus.authorizedAlways ||
        //     status == LocationAuthorizationStatus.authorizedWhenInUse) {
        //   wifiName = await _networkInfo.getWifiName();
        // } else {
        //   wifiName = await _networkInfo.getWifiName();
        // }
      } else {
        wifiName = await _networkInfo.getWifiName();
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi Name', error: e);
      wifiName = 'Failed to get Wifi Name';
    }
    debugPrint(wifiName);
    return wifiName?.replaceAll('"', "").trim() ?? "unknown";
  }
}
