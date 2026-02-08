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
    "LOW",
    "MEDIUM",
    "HIGH",
  ];

  final Duration _timerDuration = const Duration(minutes: 2);
  late List<String> switchTypes;
  bool switchOn = false;
  Map<String, dynamic> statusRes = {};
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
    Map<String, dynamic> apiRes = await ApiConnect.hitApiGet(
        "${widget.routerDetails.iPAddress}/Switchstatus");
    final Map<String, dynamic> res = Map<String, dynamic>.from(apiRes["data"]);
    int totalSwitches = widget.routerDetails.switchTypes.length;
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
    return GestureDetector(
      onTap: () => _resetTimer,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.routerDetails.routerName)),
        floatingActionButton: FloatingActionButton(
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
                  margin: const EdgeInsets.all(20),
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
                        widget.routerDetails.switchName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).appColors.background),
                      ),
                      if (widget.routerDetails.switchTypes.length > 1)
                        Switch(
                          onChanged: (value) async {
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
                              debugPrint('Local API call timed out.');
                            }
                          },
                          value: switchOn,
                          activeColor: Theme.of(context).appColors.greenButton,
                          activeTrackColor: Theme.of(context).appColors.green,
                          inactiveThumbColor:
                              Theme.of(context).appColors.redButton,
                          inactiveTrackColor: Theme.of(context).appColors.red,
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
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data?.length ?? 0,
                      itemBuilder: (context, index) {
                        return RouterListCard(
                          routerDetails: widget.routerDetails,
                          index: index,
                          switchStatus:
                              statusRes["ON${index + 1}"]?.toString() == "1",
                          wifiName: _connectionStatus,
                        );
                      },
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                    );
                  }),
              if (widget.routerDetails.selectedFan != null &&
                  widget.routerDetails.selectedFan!.isNotEmpty) ...[
                // Container(
                //   padding: const EdgeInsets.all(20),
                //   margin: const EdgeInsets.all(15),
                //   decoration: BoxDecoration(
                //     gradient: const LinearGradient(
                //       colors: [
                //         Colors.blueAccent,
                //         Colors.lightBlueAccent,
                //         Colors.greenAccent,
                //       ],
                //       begin: Alignment.topLeft,
                //       end: Alignment.bottomRight,
                //     ),
                //     borderRadius: BorderRadius.circular(20),
                //     boxShadow: const [
                //       BoxShadow(
                //         color: Colors.black26,
                //         spreadRadius: 2,
                //         blurRadius: 6,
                //         offset: Offset(2, 2),
                //       ),
                //     ],
                //   ),
                //   child: Column(
                //     children: [
                //       Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           Text(
                //             widget.routerDetails.selectedFan ?? "No Name",
                //             style: TextStyle(
                //               color: Colors.white,
                //               fontSize: width * 0.05,
                //               fontWeight: FontWeight.bold,
                //             ),
                //           ),
                //           const SizedBox(width: 10),
                //           const Icon(
                //             FontAwesomeIcons.fan,
                //             size: 35,
                //             color: Colors.deepPurpleAccent,
                //           )
                //         ],
                //       ),
                //       CupertinoSlidingSegmentedControl<String>(
                //         groupValue: selectedControl,
                //         backgroundColor: Colors.transparent,
                //         thumbColor: const Color(0xff2cd2ec),
                //         children: {
                //           for (var control in controls)
                //             control: Text(
                //               control,
                //               style: const TextStyle(
                //                 color: Colors.white,
                //                 fontSize: 18,
                //                 fontWeight: FontWeight.bold,
                //               ),
                //             ),
                //         },
                //         onValueChanged: (value) async {
                //           if (!_connectionStatus
                //                   .contains(widget.routerDetails.routerName) &&
                //               !widget.routerDetails.routerName
                //                   .contains(_connectionStatus)) {
                //             showToast(
                //               context,
                //               "Please Connect WIFI to ${widget.routerDetails.routerName} to proceed",
                //             );
                //             setState(() {});
                //             return;
                //           }
                //           setState(() {
                //             selectedControl = value!;
                //           });
                //           debugPrint(value);
                //           await sendFanCommand(value!);
                //         },
                //       ),
                //     ],
                //   ),
                // )
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.routerDetails.selectedFan ?? "No Name",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                    color:
                                        Theme.of(context).appColors.background),
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
                            selectedControl = control;
                          });
                          debugPrint(control);
                          await sendFanCommand(control);
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
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
            content: Text("An unexpected error occurred: ${e.toString()}")),
      );
    }
  }
}
