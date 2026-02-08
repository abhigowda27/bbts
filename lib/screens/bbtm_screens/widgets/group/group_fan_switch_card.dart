import 'dart:async';

import 'package:bbts_server/theme/app_colors_extension.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

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
    Map<String, dynamic> apiRes = await ApiConnect.hitApiGet(
        "${widget.switchDetails.iPAddress}/Switchstatus");
    final Map<String, dynamic> res = Map<String, dynamic>.from(apiRes["data"]);
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
      padding: const EdgeInsets.all(20),
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
              Expanded(
                child: Text(
                  "${widget.switchDetails.routerName}-${widget.switchDetails.selectedFan}",
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Theme.of(context).appColors.background),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.2),
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
                  icon: Icon(
                    FontAwesomeIcons.arrowsRotate,
                    color: Theme.of(context).appColors.background,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                FontAwesomeIcons.fan,
                size: 35,
                color: Colors.deepPurpleAccent,
              ),
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
          //             .contains(widget.switchDetails.routerName) &&
          //         !widget.switchDetails.routerName
          //             .contains(_connectionStatus)) {
          //       showToast(
          //         context,
          //         "Please Connect WIFI to ${widget.switchDetails.routerName} to proceed",
          //       );
          //       setState(() {});
          //       return;
          //     }
          //     setState(() {
          //       selectedControl = value!;
          //     });
          //     debugPrint(value);
          //     await sendFanCommand(widget.switchDetails, value!);
          //   },
          // ),

// Inside your widget build:
          SleekCircularSlider(
            min: 0,
            max: controls.length.toDouble() - 1, // total steps
            initialValue: controls.indexOf(selectedControl).toDouble(),
            appearance: CircularSliderAppearance(
              size: 150,
              startAngle: 150,
              angleRange: 240, // like a dial
              customWidths: CustomSliderWidths(
                trackWidth: 8,
                progressBarWidth: 12,
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
                dotColor: Colors.white,
                shadowColor: Colors.black26,
              ),
              infoProperties: InfoProperties(
                mainLabelStyle: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Theme.of(context).appColors.background),
                modifier: (value) {
                  final index = value.round();
                  return controls[index]; // show control name
                },
              ),
            ),
            onChangeEnd: (value) async {
              final control = controls[value.round()];

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
                selectedControl = control;
              });

              debugPrint(control);
              await sendFanCommand(widget.switchDetails, control);
            },
          ),
        ],
      ),
    );
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
      debugPrint(e.toString());
      showToast("An unexpected error occurred}");
    } catch (e) {
      debugPrint(e.toString());

      showToast("An unexpected error occurred}");
    }
  }
}
