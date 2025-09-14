import 'dart:async';

import 'package:bbts_server/theme/app_colors_extension.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:open_settings/open_settings.dart';

import '../../controllers/wifi.dart';
import '../../models/router_model.dart';
import '../../widgets/custom/custom_button.dart';
import '../../widgets/custom/toast.dart';
import 'group_fan_switch_control.dart';
import 'group_on_off.dart';

class ConnectToGroupWidget extends StatefulWidget {
  final String groupName;
  final String selectedRouter;
  final List<RouterDetails> selectedSwitches;

  const ConnectToGroupWidget(
      {required this.groupName,
      required this.selectedRouter,
      required this.selectedSwitches,
      super.key});

  @override
  State<ConnectToGroupWidget> createState() => _ConnectToSwitchWidgetState();
}

class _ConnectToSwitchWidgetState extends State<ConnectToGroupWidget> {
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
    return Scaffold(
      appBar: AppBar(title: Text(widget.groupName)),
      body: Column(
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
          if (widget.selectedSwitches
              .any((element) => element.switchTypes.isNotEmpty)) ...[
            CustomButton(
                icon: Icons.lightbulb,
                text: "Connect to Group Switch",
                onPressed: () {
                  if (!_connectionStatus.contains(widget.selectedRouter) &&
                      !widget.selectedRouter.contains(_connectionStatus)) {
                    showToast(
                        "Please Connect WIFI to '${widget.selectedRouter}' to proceed");
                    return;
                  }
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GroupSwitchOnOff(
                                groupName: widget.groupName,
                                selectedRouter: widget.selectedRouter,
                                selectedSwitches: widget.selectedSwitches,
                              )));
                }),
          ],
          if (widget.selectedSwitches
              .any((element) => element.selectedFan!.isNotEmpty)) ...[
            CustomButton(
                text: "Connect to Group Fans",
                icon: Icons.wind_power_outlined,
                onPressed: () {
                  if (!_connectionStatus.contains(widget.selectedRouter) &&
                      !widget.selectedRouter.contains(_connectionStatus)) {
                    showToast(
                        "Please Connect WIFI to '${widget.selectedRouter}' to proceed");
                    return;
                  }
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GroupFanSwitchControl(
                                groupName: widget.groupName,
                                selectedRouter: widget.selectedRouter,
                                selectedSwitches: widget.selectedSwitches,
                              )));
                }),
          ],
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
    );
  }
}
