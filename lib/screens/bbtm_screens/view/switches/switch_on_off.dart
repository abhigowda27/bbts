import 'dart:async';

import 'package:bbts_server/theme/app_colors_extension.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../controllers/apis.dart';
import '../../../tabs_page.dart';
import '../../controllers/wifi.dart';
import '../../models/switch_model.dart';
import '../../widgets/custom/toast.dart';
import '../../widgets/switches/switch_matrix_card.dart';

class SwitchOnOff extends StatefulWidget {
  final SwitchDetails switchDetails;

  const SwitchOnOff({
    required this.switchDetails,
    super.key,
  });

  @override
  State<SwitchOnOff> createState() => _SwitchOnOffState();
}

class _SwitchOnOffState extends State<SwitchOnOff> {
  late Timer _timer;
  final Duration _timerDuration = const Duration(minutes: 2);
  late List<String> switchTypes;
  String switchStatus = "Off";
  bool switchOn = false;
  String statusRes = "";
  late String selectedControl = "OFF";
  List<String> controls = [
    "OFF",
    "HIGH",
    "LOW",
    "MEDIUM",
  ];
  Future<List<String>> fetchSwitches() async {
    return widget.switchDetails.switchTypes;
  }

  late NetworkService _networkService;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _networkService = NetworkService();
    updateSwitch();
    switchTypes = widget.switchDetails.switchTypes;
    _initNetworkInfo();
    _startTimer();
    connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _updateConnectionStatus(results);
    });
  }

  Future<void> updateSwitch() async {
    String res = await ApiConnect.hitApiGet(
        "${widget.switchDetails.iPAddress}/Switchstatus");
    debugPrint("${widget.switchDetails.iPAddress}/Switchstatus");
    debugPrint(res);
    int totalSwitches = widget.switchDetails.switchTypes.length;
    setState(() {
      bool anyClosed = false;
      for (int i = 1; i <= totalSwitches; i++) {
        if (res.contains("OK$i CLOSE")) {
          anyClosed = true;
          break;
        }
      }
      statusRes = res;
      switchOn = !anyClosed;
      switchStatus = anyClosed ? "Off" : "On";
    });
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
    debugPrint("statusRes");
    debugPrint(statusRes);
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
    _timer.cancel();
    _startTimer();
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
      onTap: () => _resetTimer,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).appColors.primary,
          onPressed: () {
            updateSwitch();
          },
          child: const Icon(
            Icons.refresh_rounded,
            color: Colors.white,
          ),
        ),
        appBar: AppBar(title: Text(widget.switchDetails.switchSSID)),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.switchDetails.switchTypes.isNotEmpty) ...[
              Container(
                margin: EdgeInsets.all(width * 0.04),
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 7,
                      offset: const Offset(5, 5),
                    ),
                  ],
                  color: Theme.of(context).appColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.switchDetails.switchSSID,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Transform.scale(
                      scale: 1,
                      child: Switch(
                        onChanged: (value) async {
                          debugPrint(_connectionStatus);
                          debugPrint(widget.switchDetails.switchSSID);
                          if (!_connectionStatus
                                  .contains(widget.switchDetails.switchSSID) &&
                              widget.switchDetails.switchSSID
                                  .contains(_connectionStatus)) {
                            showToast(
                                "Please Connect WIFI to ${widget.switchDetails.switchSSID} to proceed");
                            return;
                          }
                          int totalSwitches =
                              widget.switchDetails.switchTypes.length;
                          try {
                            // for (int i = 1; i <= totalSwitches; i++) {
                            //   await ApiConnect.hitApiPost(
                            //       "${widget.switchDetails.iPAddress}/getSwitchcmd$i",
                            //       {
                            //         "Lock_id": widget.switchDetails.switchId,
                            //         "lock_passkey":
                            //             widget.switchDetails.switchPassKey,
                            //         "lock_cmd$i": value ? "ON$i" : "OFF$i",
                            //       }).timeout(const Duration(seconds: 2));
                            //   debugPrint(value ? "ON$i" : "OFF$i");
                            // }

                            // await ApiConnect.hitApiPost(
                            //     "${widget.switchDetails.iPAddress}/getSwitchcmd",
                            //     {
                            //       "Lock_id": widget.switchDetails.switchId,
                            //       "lock_passkey":
                            //           widget.switchDetails.switchPassKey,
                            //       "lock_cmd": value ? "ON" : "OFF",
                            //     }).timeout(const Duration(seconds: 50));
                            // debugPrint(value ? "ON" : "OFF");

                            List<Future<void>> apiCalls = [];

                            for (int i = 1;
                                i <=
                                    totalSwitches +
                                        (widget.switchDetails.selectedFan!
                                                .isNotEmpty
                                            ? 1
                                            : 0);
                                i++) {
                              final uri =
                                  "${widget.switchDetails.iPAddress}/getSwitchcmd$i";
                              final payload = {
                                "Lock_id": widget.switchDetails.switchId,
                                "lock_passkey":
                                    widget.switchDetails.switchPassKey,
                                "lock_cmd$i": (widget.switchDetails.selectedFan!
                                            .isNotEmpty &&
                                        i == totalSwitches + 1)
                                    ? (value ? "HIGH" : "OFF")
                                    : (value ? "ON$i" : "OFF$i"),
                              };

                              apiCalls.add(
                                ApiConnect.hitApiPost(uri, payload)
                                    .timeout(const Duration(seconds: 1))
                                    .then(
                                        (_) => debugPrint(value ? "ON" : "OFF"))
                                    .catchError((e) =>
                                        debugPrint("Error on switch $i: $e")),
                              );
                            }
                            setState(() {
                              switchOn = value;
                            });
                            await Future.wait(apiCalls);
                            await updateSwitch();
                          } catch (e) {
                            debugPrint(
                                'API call to ${widget.switchDetails.iPAddress} timed out.');
                          }
                          await updateSwitch();
                        },
                        value: switchOn,
                        activeColor: Theme.of(context).appColors.greenButton,
                        activeTrackColor: Theme.of(context).appColors.green,
                        inactiveThumbColor:
                            Theme.of(context).appColors.redButton,
                        inactiveTrackColor: Theme.of(context).appColors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            FutureBuilder<List<String>>(
                future: fetchSwitches(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(
                        color: Theme.of(context).appColors.buttonBackground);
                  }
                  if (snapshot.hasError) {
                    return const Text("ERROR");
                  }
                  return ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.03),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      debugPrint(snapshot.data?[index]);
                      debugPrint("OK${index + 1} CLOSE");
                      return SwitchMatrixCard(
                        switchDetails: widget.switchDetails,
                        index: index,
                        switchStatus: statusRes.contains("OK${index + 1} OPEN")
                            ? false
                            : true,
                        wifiName: _connectionStatus,
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(height: width * 0.03);
                    },
                  );
                }),
            if (widget.switchDetails.selectedFan != null &&
                widget.switchDetails.selectedFan!.isNotEmpty) ...[
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
                          widget.switchDetails.selectedFan ?? "No Name",
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
                  ],
                ),
              )
            ],
          ],
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("An unexpected error occurred: ${e.toString()}")),
      );
    }
  }
}
