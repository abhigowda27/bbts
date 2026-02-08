import 'dart:async';

import 'package:bbts_server/main.dart';
import 'package:bbts_server/theme/app_colors_extension.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

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
  bool switchOn = false;
  Map<String, dynamic> statusRes = {};
  late String selectedControl = "OFF";
  final List<String> controls = [
    "OFF",
    "LOW",
    "MEDIUM",
    "HIGH",
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
    Map<String, dynamic> apiRes = await ApiConnect.hitApiGet(
        "${widget.switchDetails.iPAddress}/Switchstatus");
    final Map<String, dynamic> res = Map<String, dynamic>.from(apiRes["data"]);
    int totalSwitches = widget.switchDetails.switchTypes.length;
    setState(() {
      bool anyClosed = false;
      for (int i = 1; i <= totalSwitches; i++) {
        final key = "ON$i";
        if (res.containsKey(key)) {
          if (res[key].toString() == "0") {
            anyClosed = true;
            break;
          }
        }
      }
      statusRes = res;
      switchOn = !anyClosed;
    });
    setState(() {
      if (res["FAN"] == "LOW") {
        debugPrint("low");
        selectedControl = "LOW";
      } else if (res["FAN"] == "MED") {
        debugPrint("medium");
        selectedControl = "MEDIUM";
      } else if (res["FAN"] == "HIGH") {
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
                      color: Colors.grey.withValues(alpha: 0.2),
                      blurRadius: 7,
                      offset: const Offset(5, 5),
                    ),
                  ],
                  color: Theme.of(context)
                      .appColors
                      .primary
                      .withValues(alpha: 0.7),
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
                        activeThumbColor:
                            Theme.of(context).appColors.greenButton,
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
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      debugPrint(snapshot.data?[index]);
                      return SwitchMatrixCard(
                        switchDetails: widget.switchDetails,
                        index: index,
                        switchStatus:
                            statusRes["ON${index + 1}"]?.toString() == "1",
                        wifiName: _connectionStatus,
                      );
                    },
                  );
                }),
            if (widget.switchDetails.selectedFan != null &&
                widget.switchDetails.selectedFan!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(20),
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
                  borderRadius: BorderRadius.circular(10),
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
                        const Icon(
                          FontAwesomeIcons.fan,
                          size: 35,
                          color: Colors.deepPurpleAccent,
                        )
                      ],
                    ),
                    Divider(
                      color: Theme.of(context).appColors.background,
                    ),
                    // CupertinoSlidingSegmentedControl<String>(
                    //   groupValue: selectedControl,
                    //   backgroundColor: Colors.transparent,
                    //   thumbColor: const Color(0xff2cd2ec),
                    //   children: {
                    //     for (var control in controls)
                    //       control: Text(
                    //         control,
                    //         style: const TextStyle(
                    //           color: Colors.white,
                    //           fontSize: 18,
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       ),
                    //   },
                    //   onValueChanged: (value) async {
                    //     if (!_connectionStatus
                    //             .contains(widget.switchDetails.switchSSID) &&
                    //         !widget.switchDetails.switchSSID
                    //             .contains(_connectionStatus)) {
                    //       showToast(
                    //         context,
                    //         "Please Connect WIFI to ${widget.switchDetails.switchSSID} to proceed",
                    //       );
                    //       setState(() {});
                    //       return;
                    //     }
                    //     setState(() {
                    //       selectedControl = value!;
                    //     });
                    //     debugPrint(value);
                    //     await sendFanCommand(value!);
                    //   },
                    // ),
                    SleekCircularSlider(
                      min: 0,
                      max: controls.length.toDouble() - 1,
                      initialValue:
                          controls.indexOf(selectedControl).toDouble(),
                      appearance: CircularSliderAppearance(
                        size: 150,
                        customWidths: CustomSliderWidths(
                          trackWidth: 8,
                          progressBarWidth: 15,
                          handlerSize: 12,
                        ),
                        customColors: CustomSliderColors(
                          trackColors: [
                            Colors.blueAccent,
                            Colors.lightBlueAccent,
                            Colors.greenAccent,
                          ],
                          progressBarColors: [
                            Colors.blueAccent,
                            Colors.lightBlueAccent,
                            Colors.greenAccent,
                          ],
                          dotColor: Theme.of(context).appColors.background,
                          shadowColor: Colors.black26,
                        ),
                        infoProperties: InfoProperties(
                          mainLabelStyle: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                                  color:
                                      Theme.of(context).appColors.background),
                          modifier: (value) {
                            final index = value.round();
                            return controls[index]; // show control name
                          },
                        ),
                      ),
                      onChangeEnd: (value) async {
                        final control = controls[value.round()];
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
                          selectedControl = control;
                        });
                        debugPrint(control);
                        await sendFanCommand(control);
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
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
            content: Text("An unexpected error occurred: ${e.toString()}")),
      );
    }
  }
}
