import 'dart:async';

import 'package:bbts_server/screens/bbtm_screens/view/switches/switch_on_off.dart';
import 'package:bbts_server/theme/app_colors_extension.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:open_settings/open_settings.dart';

import '../../controllers/wifi.dart';
import '../../models/switch_model.dart';
import '../../widgets/custom/custom_button.dart';
import '../../widgets/custom/toast.dart';

class ConnectToSwitchPage extends StatefulWidget {
  final SwitchDetails switchDetails;
  const ConnectToSwitchPage({required this.switchDetails, super.key});

  @override
  State<ConnectToSwitchPage> createState() => _ConnectToSwitchPageState();
}

class _ConnectToSwitchPageState extends State<ConnectToSwitchPage> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;
  late NetworkService _networkService;
  @override
  void initState() {
    super.initState();
    _networkService = NetworkService();
    _initNetworkInfo();
    connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _updateConnectionStatus(results);
    });
  }

  @override
  void dispose() {
    connectivitySubscription?.cancel();
    super.dispose();
  }

  String _connectionStatus = 'Unknown';
  Future<void> _updateConnectionStatus(
          List<ConnectivityResult> results) async =>
      _initNetworkInfo();

  Future<void> _initNetworkInfo() async {
    String? wifiName = await _networkService.initNetworkInfo();
    setState(() => _connectionStatus = wifiName ?? "Unknown");
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    return Scaffold(
      appBar: AppBar(title: Text(widget.switchDetails.switchSSID)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            CustomButton(
                text: "Open WIFI Settings",
                icon: Icons.wifi_find,
                onPressed: () {
                  OpenSettings.openWIFISetting();
                }),
            if (widget.switchDetails.switchTypes.isNotEmpty ||
                widget.switchDetails.selectedFan!.isNotEmpty) ...[
              CustomButton(
                  icon: Icons.lightbulb_outlined,
                  text: "Connect to ${widget.switchDetails.switchSSID}",
                  onPressed: () {
                    if (!_connectionStatus
                            .contains(widget.switchDetails.switchSSID) &&
                        !widget.switchDetails.switchSSID
                            .contains(_connectionStatus)) {
                      showToast(
                          "Please Connect WIFI to ${widget.switchDetails.switchSSID} to proceed");
                      return;
                    }
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SwitchOnOff(
                                  switchDetails: widget.switchDetails,
                                )));
                  })
            ],
            // const SizedBox(
            //   height: 30,
            // ),
            // if (widget.switchDetails.selectedFan!.isNotEmpty) ...[
            //   CustomButton(
            //       icon: Icons.wind_power_rounded,
            //       text:
            //           "Connect to ${widget.switchDetails.selectedFan}",
            //       onPressed: () {
            //         if (!_connectionStatus
            //             .contains(widget.switchDetails.switchSSID)) {
            //           showToast(context,
            //               "Please Connect WIFI to ${widget.switchDetails.switchSSID} to proceed");
            //           return;
            //         }
            //         debugPrint("connecting to fan");
            //         Navigator.push(
            //             context,
            //             MaterialPageRoute(
            //                 builder: (context) => FanSwitchControl(
            //                       switchDetails: widget.switchDetails,
            //                     )));
            //       })
            // ],

            Text(
              'WIFI is connected to Wifi Name',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: width * 0.05),
            ),
            Text(
              _connectionStatus.toString(),
              style: TextStyle(
                  color: Theme.of(context).appColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: width * 0.06),
            ),
          ],
        ),
      ),
    );
  }
}
