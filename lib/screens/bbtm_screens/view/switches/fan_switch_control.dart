import 'dart:async';

import 'package:bbts_server/main.dart';
import 'package:bbts_server/screens/bbtm_screens/models/switch_model.dart';
import 'package:bbts_server/theme/app_colors_extension.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../controllers/apis.dart';
import '../../../tabs_page.dart';
import '../../controllers/wifi.dart';
import '../../widgets/custom/toast.dart';

class FanSwitchControl extends StatefulWidget {
  final SwitchDetails switchDetails;

  const FanSwitchControl({
    required this.switchDetails,
    super.key,
  });

  @override
  State<FanSwitchControl> createState() => _FanSwitchControlState();
}

class _FanSwitchControlState extends State<FanSwitchControl> {
  late Timer _timer;
  late String selectedControl = "OFF";
  final Duration _timerDuration = const Duration(seconds: 30);
  List<String> controls = [
    "OFF",
    "HIGH",
    "LOW",
    "MEDIUM",
  ];
  late NetworkService _networkService;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _networkService = NetworkService();
    _startTimer();
    updateSwitch();
    _initNetworkInfo();
    connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _updateConnectionStatus(results);
    });
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

  @override
  void dispose() {
    connectivitySubscription?.cancel();
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer(_timerDuration, _navigateToNextPage);
  }

  void _resetTimer() {
    _startTimer();
    _timer.cancel();
  }

  String _connectionStatus = 'Unknown';
  Future<void> _updateConnectionStatus(
          List<ConnectivityResult> results) async =>
      _initNetworkInfo();

  Future<void> _initNetworkInfo() async {
    String? wifiName = await _networkService.initNetworkInfo();
    setState(() => _connectionStatus = wifiName ?? "Unknown");
  }

  void _navigateToNextPage() {
    if (mounted) {
      Navigator.pushAndRemoveUntil<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => const TabsPage(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;

    return GestureDetector(
      onTap: _resetTimer,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).appColors.primary,
          onPressed: updateSwitch,
          child: const Icon(Icons.refresh_rounded),
        ),
        appBar: AppBar(title: const Text("Fan Control")),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade400,
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(5, 5),
                      ),
                    ],
                    color: Theme.of(context).appColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${widget.switchDetails.switchSSID}_${widget.switchDetails.selectedFan}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: width * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.wind_power_outlined,
                        size: width * 0.1,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 250,
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.teal.shade600,
                      Colors.blue.shade400,
                      Colors.red.shade400
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
                child: CupertinoSlidingSegmentedControl<String>(
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
                            .contains(widget.switchDetails.switchSSID) &&
                        !widget.switchDetails.switchSSID
                            .contains(_connectionStatus)) {
                      showToast(
                        "Please Connect WIFI to ${widget.switchDetails.switchSSID} to proceed",
                      );
                      setState(() {});
                      return;
                    }
                    setState(() {
                      selectedControl = value!;
                    });
                    debugPrint(value);
                    await sendFanCommand(value!);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> sendFanCommand(String command) async {
    try {
      final response = await ApiConnect.hitApiPost(
        "${widget.switchDetails.iPAddress}/getSwitchcmd",
        {
          "Lock_id": widget.switchDetails.switchId,
          "lock_passkey": widget.switchDetails.switchPassKey,
          "lock_cmd": command,
        },
      );
      debugPrint(command);
      debugPrint(response);
      debugPrint("${widget.switchDetails.iPAddress}/getSwitchcmd" "$command ");
      if (response.toLowerCase() == "ok") {
        showToast("Fan '$command' executed successfully");
      } else {
        showToast("Failed to execute. Try again.");
      }
    } on DioException catch (e) {
      debugPrint("$e");
    } catch (e) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
            content: Text("An unexpected error occurred: ${e.toString()}")),
      );
    }
  }
}
