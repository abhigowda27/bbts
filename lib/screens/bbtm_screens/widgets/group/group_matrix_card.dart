import 'dart:async';

import 'package:bbts_server/theme/app_colors_extension.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../controllers/apis.dart';
import '../../controllers/wifi.dart';
import '../../models/router_model.dart';
import '../custom/toast.dart';

class GroupMatrixCard extends StatefulWidget {
  final RouterDetails switchDetails;
  const GroupMatrixCard({
    required this.switchDetails,
    super.key,
  });

  @override
  State<GroupMatrixCard> createState() => _GroupMatrixCardState();
}

class _GroupMatrixCardState extends State<GroupMatrixCard> {
  String switchStatus = "Off";
  bool switchOff = true;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late NetworkService _networkService;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _networkService = NetworkService();
    _initNetworkInfo();
    updateSwitch();
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

  void updateSwitch() async {
    String res = await ApiConnect.hitApiGet(
        "${widget.switchDetails.iPAddress}/Switchstatus");
    debugPrint(res);
    setState(() {
      if (res.contains("OPEN")) {
        switchOff = false;
        switchStatus = "On";
      } else {
        switchOff = true;
        switchStatus = "Off";
      }
    });
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 12.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 7,
            offset: const Offset(5, 5),
          ),
        ],
        color: Theme.of(context).appColors.buttonBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              widget.switchDetails.switchName,
              style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).appColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Transform.scale(
            scale: 1,
            child: Switch(
              onChanged: (value) async {
                if (!_connectionStatus
                        .contains(widget.switchDetails.routerName) &&
                    !widget.switchDetails.routerName
                        .contains(_connectionStatus)) {
                  showToast(
                      "Please Connect WIFI to ${widget.switchDetails.routerName} to proceed");
                  return;
                }
                try {
                  final totalSwitches = widget.switchDetails.switchTypes.length;
                  final switchDetails = widget.switchDetails;
                  for (int i = 1; i <= totalSwitches; i++) {
                    await ApiConnect.hitApiPost(
                        "${switchDetails.iPAddress}/getSwitchcmd$i", {
                      "Lock_id": switchDetails.switchID,
                      "lock_passkey": switchDetails.switchPasskey,
                      "lock_cmd$i": value ? "ON$i" : "OFF$i",
                    }).timeout(const Duration(seconds: 5));
                    debugPrint(value ? "ON$i" : "OFF$i");
                  }
                  setState(() {
                    switchOff = !value;
                  });
                } on DioException catch (e) {
                  final scaffold = ScaffoldMessenger.of(context);
                  scaffold.showSnackBar(
                    SnackBar(
                      content: Text(
                          "Unable to perform. Try Again. Error: ${e.message}"),
                    ),
                  );
                } catch (e) {
                  debugPrint(e.toString());
                }
              },
              value: !switchOff,
              activeColor: Theme.of(context).appColors.greenButton,
              activeTrackColor: Theme.of(context).appColors.green,
              inactiveThumbColor: Theme.of(context).appColors.redButton,
              inactiveTrackColor: Theme.of(context).appColors.red,
            ),
          ),
        ],
      ),
    );
  }
}
