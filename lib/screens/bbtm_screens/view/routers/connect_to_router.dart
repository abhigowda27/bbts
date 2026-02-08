import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:bbts_server/screens/bbtm_screens/view/routers/router_on_off.dart';
import 'package:bbts_server/theme/app_colors_extension.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../controllers/wifi.dart';
import '../../models/router_model.dart';
import '../../widgets/custom/custom_button.dart';

class ConnectToRouterPage extends StatefulWidget {
  final RouterDetails routerDetails;
  const ConnectToRouterPage({super.key, required this.routerDetails});

  @override
  State<ConnectToRouterPage> createState() => _ConnectToRouterPageState();
}

class _ConnectToRouterPageState extends State<ConnectToRouterPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
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
    return GestureDetector(
      child: Scaffold(
        appBar: AppBar(title: Text(widget.routerDetails.routerName)),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              if (widget.routerDetails.switchTypes.isNotEmpty ||
                  widget.routerDetails.selectedFan!.isNotEmpty) ...[
                CustomButton(
                    text: "Connect to ${widget.routerDetails.switchName}",
                    onPressed: () {
                      if (!_connectionStatus
                              .contains(widget.routerDetails.routerName) &&
                          !widget.routerDetails.routerName
                              .contains(_connectionStatus)) {
                        Fluttertoast.showToast(
                          toastLength: Toast.LENGTH_LONG,
                          backgroundColor:
                              Theme.of(context).appColors.textSecondary,
                          textColor: Theme.of(context).appColors.background,
                          msg:
                              "Please Connect WIFI to ${widget.routerDetails.routerName} to proceed",
                        );
                        AppSettings.openAppSettings(type: AppSettingsType.wifi);
                        return;
                      }
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RouterOnOff(
                                    routerDetails: widget.routerDetails,
                                  )));
                    })
              ],
              // const SizedBox(
              //   height: 15,
              // ),
              // if (widget.routerDetails.selectedFan!.isNotEmpty) ...[
              //   CustomButton(
              //       text:
              //           "Connect to ${widget.routerDetails.selectedFan}",
              //       onPressed: () {
              //         if (!_connectionStatus
              //             .contains(widget.routerDetails.routerName)) {
              //           showToast(context,
              //               "Please Connect WIFI to ${widget.routerDetails.routerName} to proceed");
              //           return;
              //         }
              //         Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //                 builder: (context) => FanFanControl(
              //                       routerDetails: widget.routerDetails,
              //                     )));
              //       })
              // ],

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'WIFI is connected to Wifi Name',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '"$_connectionStatus"',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium!
                      .copyWith(color: Theme.of(context).appColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
