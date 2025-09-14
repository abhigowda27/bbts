import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../controllers/apis.dart';
import '../../controllers/wifi.dart';
import '../../models/router_model.dart';
import '../custom/toast.dart';

class GroupFanSwitchCard extends StatefulWidget {
  final RouterDetails switchDetails;
  const GroupFanSwitchCard({
    required this.switchDetails,
    super.key,
  });

  @override
  State<GroupFanSwitchCard> createState() => _GroupFanSwitchCardState();
}

class _GroupFanSwitchCardState extends State<GroupFanSwitchCard> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late String selectedControl = "OFF";
  List<String> controls = [
    "OFF",
    "LOW",
    "MEDIUM",
    "HIGH",
  ];
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;
  late NetworkService _networkService;

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
      if (res.contains("OK5 OPEN")) {
        debugPrint("low");
        selectedControl = "LOW";
      } else if (res.contains("OK6 OPEN")) {
        debugPrint("medium");
        selectedControl = "MEDIUM";
      } else if (res.contains("OK7 OPEN")) {
        debugPrint("high");
        selectedControl = "HIGH";
      } else {
        selectedControl = "OFF";
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
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    return Align(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Colors.blueAccent,
                  Colors.lightBlueAccent,
                  Colors.greenAccent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${widget.switchDetails.selectedFan}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 3,
                            blurRadius: 5,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {
                          updateSwitch();
                        },
                        icon: const Icon(
                          Icons.refresh_rounded,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Icon(
                      FontAwesomeIcons.fan,
                      size: 35,
                      color: Colors.deepPurpleAccent,
                    )
                  ],
                ),
                const Divider(
                  color: Colors.white,
                ),
                CupertinoSlidingSegmentedControl<String>(
                  groupValue: selectedControl,
                  backgroundColor: Colors.transparent,
                  thumbColor: const Color(0xff2cd2ec),
                  children: {
                    for (var control in controls)
                      control: Text(
                        control,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  },
                  onValueChanged: (value) async {
                    if (!_connectionStatus
                            .contains(widget.switchDetails.routerName) &&
                        !widget.switchDetails.routerName
                            .contains(_connectionStatus)) {
                      showToast(
                        "Please Connect WIFI to ${widget.switchDetails.routerName} to proceed",
                      );
                      setState(() {});
                      return;
                    }
                    setState(() {
                      selectedControl = value!;
                    });
                    debugPrint(value);
                    await sendFanCommand(widget.switchDetails, value!);
                  },
                ),
              ],
            ),
          )
        ],
      ),
    ));
  }

  Future<void> sendFanCommand(
      RouterDetails routerDetails, String command) async {
    try {
      final response = await ApiConnect.hitApiPost(
        "${routerDetails.iPAddress}/getSwitchcmd",
        {
          "Lock_id": routerDetails.switchID,
          "lock_passkey": routerDetails.switchPasskey,
          "lock_cmd": command,
        },
      );
      debugPrint(command);
      debugPrint(response);
      debugPrint("${routerDetails.iPAddress}/getSwitchcmd" "$command ");
      if (response == "Ok") {
        showToast(
            "Fan '$command' executed successfully for ${routerDetails.selectedFan}");
      } else {
        showToast("Failed to execute. Try again.");
      }
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("An unexpected error occurred: ${e.toString()}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("An unexpected error occurred: ${e.toString()}")),
      );
    }
  }
}
