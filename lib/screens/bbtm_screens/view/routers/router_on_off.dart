import 'dart:async';

import 'package:bbts_server/theme/app_colors_extension.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../controllers/apis.dart';
import '../../../tabs_page.dart';
import '../../controllers/wifi.dart';
import '../../models/router_model.dart';
import '../../widgets/custom/toast.dart';
import '../../widgets/router/router_list_card.dart';

class RouterOnOff extends StatefulWidget {
  final RouterDetails routerDetails;

  const RouterOnOff({
    required this.routerDetails,
    super.key,
  });

  @override
  State<RouterOnOff> createState() => _RouterOnOffState();
}

class _RouterOnOffState extends State<RouterOnOff> {
  late Timer _timer;
  late String selectedControl = "OFF";
  final List<String> controls = [
    "OFF",
    "HIGH",
    "LOW",
    "MEDIUM",
  ];

  final Duration _timerDuration = const Duration(minutes: 2);
  late List<String> switchTypes;
  String switchStatus = "Off";
  bool switchOn = false;
  String statusRes = "";
  Future<List<String>> fetchSwitches() async {
    return widget.routerDetails.switchTypes;
  }

  late NetworkService _networkService;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _networkService = NetworkService();
    updateSwitch();
    switchTypes = widget.routerDetails.switchTypes;
    _initNetworkInfo();
    connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _updateConnectionStatus(results);
    });
  }

  Future<void> updateSwitch() async {
    debugPrint("${widget.routerDetails.iPAddress}/Switchstatus");
    String res = await ApiConnect.hitApiGet(
        "${widget.routerDetails.iPAddress}/Switchstatus");
    int totalSwitches = widget.routerDetails.switchTypes.length;
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
        appBar: AppBar(title: Text(widget.routerDetails.routerName)),
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
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.routerDetails.switchTypes.isNotEmpty) ...[
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
                        widget.routerDetails.switchName,
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
                            // final isApiOnline =
                            //     await ApiConnect.isApiAvailable();
                            const isApiOnline = false;
                            debugPrint("internet available $isApiOnline");
                            if (!isApiOnline) {
                              if (!_connectionStatus.contains(
                                      widget.routerDetails.routerName) &&
                                  !widget.routerDetails.routerName
                                      .contains(_connectionStatus)) {
                                showToast(
                                    "Please connect WIFI to ${widget.routerDetails.routerName} to proceed");
                                return;
                              }

                              // Connected to router without internet → Make local API calls
                              final totalSwitches =
                                  widget.routerDetails.switchTypes.length;

                              try {
                                List<Future<void>> apiCalls = [];

                                for (int i = 1;
                                    i <=
                                        totalSwitches +
                                            (widget.routerDetails.selectedFan!
                                                    .isNotEmpty
                                                ? 1
                                                : 0);
                                    i++) {
                                  final uri =
                                      "${widget.routerDetails.iPAddress}/getSwitchcmd$i";
                                  final payload = {
                                    "Lock_id": widget.routerDetails.switchID,
                                    "lock_passkey":
                                        widget.routerDetails.switchPasskey,
                                    "lock_cmd$i": (widget.routerDetails
                                                .selectedFan!.isNotEmpty &&
                                            i == totalSwitches + 1)
                                        ? (value ? "HIGH" : "OFF")
                                        : (value ? "ON$i" : "OFF$i"),
                                  };

                                  apiCalls.add(
                                    ApiConnect.hitApiPost(uri, payload)
                                        .timeout(const Duration(seconds: 1))
                                        .then((_) =>
                                            debugPrint(value ? "ON" : "OFF"))
                                        .catchError((e) => debugPrint(
                                            "Error on switch $i: $e")),
                                  );
                                }

                                setState(() {
                                  switchOn = value;
                                });

                                await Future.wait(apiCalls);
                                await updateSwitch();
                              } catch (e) {
                                debugPrint('Local API call timed out.');
                              }
                            }
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
                        return RouterListCard(
                          routerDetails: widget.routerDetails,
                          index: index,
                          switchStatus:
                              statusRes.contains("OK${index + 1} OPEN")
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
              if (widget.routerDetails.selectedFan != null &&
                  widget.routerDetails.selectedFan!.isNotEmpty) ...[
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
                            widget.routerDetails.selectedFan ?? "No Name",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: width * 0.05,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            FontAwesomeIcons.fan,
                            size: 35,
                            color: Colors.deepPurpleAccent,
                          )
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
                                  .contains(widget.routerDetails.routerName) &&
                              !widget.routerDetails.routerName
                                  .contains(_connectionStatus)) {
                            showToast(
                              "Please Connect WIFI to ${widget.routerDetails.routerName} to proceed",
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
              ]
            ],
          ),
        ),
      ),
    );
  }

  Future<void> sendFanCommand(String command) async {
    try {
      debugPrint("${widget.routerDetails.iPAddress}/getSwitchcmd $command ");
      final response = await ApiConnect.hitApiPost(
        "${widget.routerDetails.iPAddress}/getSwitchcmd",
        {
          "Lock_id": widget.routerDetails.switchID,
          "lock_passkey": widget.routerDetails.switchPasskey,
          "lock_cmd": command,
        },
      );
      debugPrint("${response.runtimeType}");
      debugPrint(response);
      debugPrint(command);
      debugPrint("${widget.routerDetails.iPAddress}/getSwitchcmd" "$command ");
      if (response.toLowerCase() == "ok") {
        showToast("Fan '$command' executed successfully");
      } else {
        showToast("Failed to execute. Try again.");
      }
    } on DioException catch (e) {
      debugPrint("Api Error $e");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("An unexpected error occurred: ${e.toString()}")),
      );
    }
  }
}
