import 'dart:async';

import 'package:bbts_server/blocs/switch/switch_bloc.dart';
import 'package:bbts_server/blocs/switch/switch_event.dart';
import 'package:bbts_server/common/common_services.dart';
import 'package:bbts_server/common/common_state.dart';
import 'package:bbts_server/screens/switches/switch_page_cloud.dart';
import 'package:bbts_server/theme/app_colors_extension.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/api_status.dart';
import '../../../../widgets/common_snackbar.dart';
import '../../../tabs_page.dart';
import '../../controllers/storage.dart';
import '../../controllers/wifi.dart';
import '../../models/router_model.dart';
import '../../view/schedule_on_off_page.dart';
import '../custom/toast.dart';

class RouterCard extends StatefulWidget {
  final RouterDetails routerDetails;
  final bool showOptions;

  const RouterCard({
    required this.routerDetails,
    this.showOptions = true,
    super.key,
  });

  @override
  State<RouterCard> createState() => _RouterCardState();
}

class _RouterCardState extends State<RouterCard> {
  bool hide = true;
  bool isExpanded = false;
  final StorageController _storageController = StorageController();
  final Connectivity _connectivity = Connectivity();
  late NetworkService _networkService;
  String _connectionStatus = 'Unknown';
  StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;
  final SwitchBloc _addToCloudBloc = SwitchBloc();
  @override
  void initState() {
    super.initState();
    isExpanded = !widget.showOptions;

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

  Future<void> _initNetworkInfo() async {
    String? wifiName = await _networkService.initNetworkInfo();
    setState(() {
      _connectionStatus = wifiName ?? "Unknown";
    });
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    for (var result in results) {
      debugPrint("$result");
      _initNetworkInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    return Container(
      padding: EdgeInsets.all(width * 0.03),
      decoration: widget.showOptions
          ? BoxDecoration(
              boxShadow: [
                  BoxShadow(
                    color: Theme.of(context)
                        .appColors
                        .textSecondary
                        .withOpacity(0.1),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(5, 5),
                  ),
                ],
              color: Theme.of(context).appColors.background,
              borderRadius: BorderRadius.circular(12))
          : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Switch ID : ",
                style: TextStyle(
                    fontSize: width * 0.04,
                    color: Theme.of(context).appColors.textPrimary,
                    fontWeight: FontWeight.bold),
              ),
              Flexible(
                child: Text(
                  widget.routerDetails.switchID,
                  style: TextStyle(
                      fontSize: width * 0.04,
                      color: Theme.of(context).appColors.textPrimary,
                      fontWeight: FontWeight.w400),
                ),
              )
            ],
          ),
          Row(
            children: [
              Text(
                "Switch Name : ",
                style: TextStyle(
                    fontSize: width * 0.04,
                    color: Theme.of(context).appColors.textPrimary,
                    fontWeight: FontWeight.bold),
              ),
              Flexible(
                child: Text(
                  widget.routerDetails.switchName,
                  style: TextStyle(
                      fontSize: width * 0.04,
                      color: Theme.of(context).appColors.textPrimary,
                      fontWeight: FontWeight.w400),
                ),
              )
            ],
          ),
          Row(
            children: [
              Text(
                "Router Name : ",
                style: TextStyle(
                    fontSize: width * 0.04,
                    color: Theme.of(context).appColors.textPrimary,
                    fontWeight: FontWeight.bold),
              ),
              Flexible(
                child: Text(
                  widget.routerDetails.routerName,
                  style: TextStyle(
                      fontSize: width * 0.04,
                      color: Theme.of(context).appColors.textPrimary,
                      fontWeight: FontWeight.w400),
                ),
              )
            ],
          ),
          if (widget.routerDetails.switchTypes.isNotEmpty) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Selected Switches: ${widget.routerDetails.switchTypes.length}",
                        style: TextStyle(
                          fontSize: width * 0.04,
                          color: Theme.of(context).appColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up_outlined
                            : Icons.keyboard_arrow_down_outlined,
                        size: width * 0.06,
                        color: Theme.of(context).appColors.textPrimary,
                      ),
                    ],
                  ),
                ),
                if (isExpanded) ...[
                  Column(
                    children: widget.routerDetails.switchTypes
                        .asMap()
                        .entries
                        .map((entry) {
                      int index = entry.key;
                      String switchType = entry.value;
                      return Row(
                        children: [
                          Text(
                            '${index + 1}: ',
                            style: TextStyle(
                              fontSize: width * 0.04,
                              color: Theme.of(context).appColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              switchType,
                              style: TextStyle(
                                fontSize: width * 0.04,
                                color: Theme.of(context).appColors.textPrimary,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                          if (widget.showOptions)
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded,
                                  color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("Delete Switch Type",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .appColors
                                                .textPrimary)),
                                    content: Text(
                                      "Are you sure you want to delete \"$switchType\" from this router?",
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .appColors
                                              .textPrimary),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text("Delete",
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await _storageController
                                      .deleteOneSwitchTypeFromRouter(
                                    switchId: widget.routerDetails.switchID,
                                    switchTypeToRemove: switchType,
                                  );

                                  setState(() {
                                    widget.routerDetails.switchTypes
                                        .remove(switchType);
                                  });
                                }
                              },
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ],
            )
          ],
          if (widget.routerDetails.selectedFan!.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  "Selected fan: ",
                  style: TextStyle(
                    fontSize: width * 0.04,
                    color: Theme.of(context).appColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Flexible(
                  child: Text(
                    widget.routerDetails.selectedFan!,
                    style: TextStyle(
                      fontSize: width * 0.04,
                      color: Theme.of(context).appColors.textPrimary,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ],
            ),
          ],
          Row(
            children: [
              Text(
                "Switch PassKey : ",
                style: TextStyle(
                    fontSize: width * 0.04,
                    color: Theme.of(context).appColors.textPrimary,
                    fontWeight: FontWeight.bold),
              ),
              Flexible(
                child: Text(
                  hide
                      ? List.generate(widget.routerDetails.switchPasskey.length,
                          (index) => "*").join()
                      : widget.routerDetails.switchPasskey,
                  style: TextStyle(
                      fontSize: width * 0.04,
                      color: Theme.of(context).appColors.textPrimary,
                      fontWeight: FontWeight.w400),
                ),
              )
            ],
          ),
          Row(
            children: [
              Text(
                "Router Password: ",
                style: TextStyle(
                    fontSize: width * 0.04,
                    color: Theme.of(context).appColors.textPrimary,
                    fontWeight: FontWeight.bold),
              ),
              Flexible(
                child: Text(
                  hide
                      ? List.generate(
                          widget.routerDetails.routerPassword.length,
                          (index) => "*").join()
                      : widget.routerDetails.routerPassword,
                  style: TextStyle(
                      fontSize: width * 0.04,
                      color: Theme.of(context).appColors.textPrimary,
                      fontWeight: FontWeight.w400),
                ),
              )
            ],
          ),
          if (widget.showOptions) ...[
            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).appColors.primary,
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                      tooltip: "Delete Router",
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (cont) {
                            return AlertDialog(
                              title: Text('Delete Router',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .appColors
                                          .textPrimary)),
                              content: Text('This will delete the Router',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .appColors
                                          .textPrimary)),
                              actions: [
                                OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'CANCEL',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .appColors
                                            .primary),
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: () async {
                                    _storageController.deleteOneRouter(
                                        widget.routerDetails.switchID);
                                    Navigator.pushAndRemoveUntil<dynamic>(
                                      context,
                                      MaterialPageRoute<dynamic>(
                                        builder: (BuildContext context) =>
                                            const TabsPage(),
                                      ),
                                      (route) =>
                                          false, //if you want to disable back feature set to false
                                    );
                                  },
                                  child: Text(
                                    'OK',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .appColors
                                            .primary),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: Icon(Icons.delete_outline,
                          color: Theme.of(context).appColors.textPrimary)),
                  IconButton(
                      tooltip: "Show Details",
                      onPressed: () {
                        setState(() {
                          hide = !hide;
                        });
                      },
                      icon: hide
                          ? Icon(Icons.visibility_outlined,
                              color: Theme.of(context).appColors.textPrimary)
                          : Icon(Icons.visibility_off_outlined,
                              color: Theme.of(context).appColors.textPrimary)),
                  IconButton(
                      tooltip: "timer",
                      onPressed: () {
                        debugPrint(
                            "${_connectionStatus.contains(widget.routerDetails.routerName)}");
                        debugPrint(
                            "${widget.routerDetails.routerName.contains(_connectionStatus)}");
                        if (!_connectionStatus
                                .contains(widget.routerDetails.routerName) &&
                            !widget.routerDetails.routerName
                                .contains(_connectionStatus)) {
                          showToast(
                              "You should be connected to ${widget.routerDetails.routerName} to add the Proceed");
                          return;
                        }
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ScheduleOnOffPage(
                                      switchName:
                                          widget.routerDetails.switchName,
                                      ipAddress:
                                          widget.routerDetails.iPAddress!,
                                    )));
                      },
                      icon: Icon(Icons.access_alarms_sharp,
                          color: Theme.of(context).appColors.textPrimary)),
                  BlocListener<SwitchBloc, CommonState>(
                    bloc: _addToCloudBloc,
                    listener: (context, state) {
                      ApiStatus apiResponse = state.apiStatus;
                      if (apiResponse is ApiResponse) {
                        final responseData = apiResponse.response;
                        CommonServices.hideLoadingDialog(context);
                        debugPrint("Response data====>$responseData");
                        if (responseData != null &&
                            responseData["status"] == "success") {
                          navigateToHome();
                        }
                      } else if (apiResponse is ApiLoadingState ||
                          apiResponse is ApiInitialState) {
                        CommonServices.showLoadingDialog(context);
                      } else if (apiResponse is ApiFailureState) {
                        CommonServices.hideLoadingDialog(context);
                        final exception = apiResponse.exception.toString();
                        debugPrint(exception);
                        String errorMessage =
                            'Something went wrong! Please try again';
                        final messageMatch =
                            RegExp(r'message:\s*([^}]+)').firstMatch(exception);
                        if (messageMatch != null) {
                          errorMessage =
                              messageMatch.group(1)?.trim() ?? errorMessage;
                        }
                        showSnackBar(context, errorMessage);
                      }
                    },
                    child: IconButton(
                        tooltip: "add to cloud",
                        onPressed: () {
                          try {
                            // Build the switches list
                            List<Map<String, dynamic>> switchesPayload = [];

                            // Add selected switches
                            for (var i = 0;
                                i < widget.routerDetails.switchTypes.length;
                                i++) {
                              switchesPayload.add({
                                "type": 1,
                                "name": widget.routerDetails.switchTypes[i],
                                "order": i + 1,
                              });
                            }

                            // Add fan if selected
                            if (widget.routerDetails.selectedFan!.isNotEmpty) {
                              switchesPayload.add({
                                "type": 2, // 2 = fan
                                "name": widget.routerDetails.selectedFan,
                              });
                            }
                            // Final payload
                            final payload = {
                              "deviceName": widget.routerDetails.switchName,
                              "deviceType": 3,
                              "deviceId": widget.routerDetails.deviceMacId,
                              "switches": switchesPayload
                            };

                            _addToCloudBloc
                                .add(AddSwitchEvent(payload: payload));
                          } catch (e) {
                            debugPrint("Error ${e.toString()}");
                          }
                        },
                        icon: Icon(Icons.cloud_upload_sharp,
                            color: Theme.of(context).appColors.textPrimary)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void navigateToHome() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SwitchCloudPage()),
      );
    }
  }
}
