import 'dart:async';

import 'package:bbts_server/screens/bbtm_screens/controllers/wifi.dart';
import 'package:bbts_server/screens/bbtm_screens/view/switches/connect_to_switch.dart';
import 'package:bbts_server/screens/bbtm_screens/view/switches/switch_on_off.dart';
import 'package:bbts_server/theme/app_colors_extension.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../../../tabs_page.dart';
import '../../controllers/storage.dart';
import '../../models/switch_model.dart';
import '../../view/schedule_on_off_page.dart';
import '../custom/toast.dart';

class SwitchCard extends StatefulWidget {
  final SwitchDetails switchDetails;
  final bool showOptions;
  const SwitchCard({
    required this.switchDetails,
    this.showOptions = true,
    super.key,
  });

  @override
  State<SwitchCard> createState() => _SwitchCardState();
}

class _SwitchCardState extends State<SwitchCard> {
  final StorageController _storageController = StorageController();
  bool hide = true;
  bool isExpanded = false;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;
  late NetworkService _networkService;

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
    return InkWell(
      onTap: widget.showOptions
          ? () {
              (!_connectionStatus.contains(widget.switchDetails.switchSSID) &&
                      !widget.switchDetails.switchSSID
                          .contains(_connectionStatus))
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConnectToSwitchPage(
                          switchDetails: widget.switchDetails,
                        ),
                      ),
                    )
                  : Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SwitchOnOff(
                          switchDetails: widget.switchDetails,
                        ),
                      ),
                    );
            }
          : null,
      child: Container(
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
                  "Switch ID: ",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Flexible(
                  child: Text(
                    widget.switchDetails.switchId,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  "Switch Name: ",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Flexible(
                  child: Text(
                    widget.switchDetails.switchSSID,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
            if (widget.switchDetails.switchTypes.isNotEmpty) ...[
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
                      "Selected Switches: ${widget.switchDetails.switchTypes.length}",
                      style: Theme.of(context).textTheme.titleMedium,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.switchDetails.switchTypes
                      .asMap()
                      .entries
                      .map((entry) {
                    int index = entry.key;
                    String switchType = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Text(
                            '${index + 1}: ',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Expanded(
                            child: Text(
                              switchType,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          if (widget.showOptions)
                            IconButton(
                              icon: Icon(Icons.delete_outline_rounded,
                                  color: Colors.red, size: width * 0.05),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Delete Switch"),
                                    content: Text(
                                        "Are you sure you want to delete \"$switchType\"?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text(
                                          "Cancel",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: Text(
                                          "Delete",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                  color: Theme.of(context)
                                                      .appColors
                                                      .redButton),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await _storageController.deleteOneSwitchType(
                                    switchDetails: widget.switchDetails,
                                    typeToRemove: switchType,
                                  );
                                  setState(() {
                                    widget.switchDetails.switchTypes
                                        .removeAt(index);
                                  });
                                }
                              },
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ]
            ],
            if (widget.switchDetails.selectedFan!.isNotEmpty) ...[
              Row(
                children: [
                  Text(
                    "Selected fan: ",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Flexible(
                    child: Text(
                      widget.switchDetails.selectedFan!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ],
            Row(
              children: [
                Text(
                  "Switch PassKey : ",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Flexible(
                  child: Text(
                    hide
                        ? List.generate(
                            widget.switchDetails.switchPassKey.length,
                            (index) => "*").join()
                        : widget.switchDetails.switchPassKey,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              ],
            ),
            Row(
              children: [
                Text(
                  "Switch Password: ",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Flexible(
                  child: Text(
                    hide
                        ? List.generate(
                            widget.switchDetails.switchPassword.length,
                            (index) => "*").join()
                        : widget.switchDetails.switchPassword,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              ],
            ),
            if (widget.showOptions) ...[
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).appColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                        tooltip: "Delete Switch",
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (cont) {
                                return AlertDialog(
                                  title: const Text(
                                    "Delete Switch",
                                  ),
                                  content: Text(
                                      'Are you sure you want to delete "${widget.switchDetails.switchSSID}"'),
                                  actions: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('CANCEL'),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            _storageController.deleteOneSwitch(
                                                widget.switchDetails);
                                            Navigator.pushAndRemoveUntil<
                                                dynamic>(
                                              context,
                                              MaterialPageRoute<dynamic>(
                                                builder:
                                                    (BuildContext context) =>
                                                        const TabsPage(),
                                              ),
                                              (route) => false,
                                            );
                                          },
                                          child: const Text('Confirm'),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              });
                        },
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: Theme.of(context).appColors.textPrimary,
                        )),
                    IconButton(
                        tooltip: "password",
                        onPressed: () {
                          setState(() {
                            hide = !hide;
                          });
                        },
                        icon: hide
                            ? Icon(
                                Icons.visibility_outlined,
                                color: Theme.of(context).appColors.textPrimary,
                              )
                            : Icon(
                                Icons.visibility_off_outlined,
                                color: Theme.of(context).appColors.textPrimary,
                              )),
                    IconButton(
                        tooltip: "timer",
                        onPressed: () {
                          if (!_connectionStatus
                                  .contains(widget.switchDetails.switchSSID) &&
                              !widget.switchDetails.switchSSID
                                  .contains(_connectionStatus)) {
                            debugPrint(_connectionStatus);
                            showToast(
                                "You should be connected to ${widget.switchDetails.switchSSID} to Proceed");
                            return;
                          }
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ScheduleOnOffPage(
                                        switchName:
                                            widget.switchDetails.switchSSID,
                                        ipAddress:
                                            widget.switchDetails.iPAddress,
                                      )));
                        },
                        icon: Icon(
                          Icons.access_alarms_sharp,
                          color: Theme.of(context).appColors.textPrimary,
                        )),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
