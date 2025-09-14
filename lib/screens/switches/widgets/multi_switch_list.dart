import 'package:bbts_server/blocs/switch/switch_bloc.dart';
import 'package:bbts_server/blocs/switch/switch_event.dart';
import 'package:bbts_server/common/api_status.dart';
import 'package:bbts_server/common/common_state.dart';
import 'package:bbts_server/theme/app_colors_extension.dart';
import 'package:bbts_server/widgets/common_snackbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import 'fan_controller_widget.dart';

class MultiDevicesWidget extends StatefulWidget {
  final Map<String, dynamic> switches;
  final Map<String, dynamic> fanStatusList;
  final Map<String, dynamic> statusList;
  final Function onChanged;
  final Function(BuildContext context, Map<String, dynamic> device)
      deleteDevice;

  const MultiDevicesWidget({
    super.key,
    required this.switches,
    required this.fanStatusList,
    required this.statusList,
    required this.onChanged,
    required this.deleteDevice,
  });

  @override
  State<MultiDevicesWidget> createState() => _MultiDevicesWidgetState();
}

class _MultiDevicesWidgetState extends State<MultiDevicesWidget> {
  Map<String, bool> switchStates = {};
  final SwitchBloc _switchBloc = SwitchBloc();
  String? _pendingToggleId;
  bool? _previousToggleValue;
  List<dynamic> multiSwitches = [];
  bool? mainSwitchStatus = false;
  @override
  void initState() {
    multiSwitches = widget.switches["switches"];
    mainSwitchStatus =
        widget.switches["details"]["statusTxt"] == "ON" ? true : false;
    for (var device in multiSwitches) {
      final id = device["uid"];
      debugPrint(device["details"]["statusTxt"]);
      switchStates[id] = device["details"]["statusTxt"] == "ON" ? true : false;
      debugPrint("${switchStates[id]}");
    }
    super.initState();
  }

  Future<void> toggleSwitch(
    String switchId,
    String newStatus,
    String uid,
    int deviceType,
  ) async {
    try {
      _pendingToggleId = uid;
      _previousToggleValue = switchStates[uid];

      // For deviceType 1 (boolean switch), update internal toggle state
      if (deviceType == 1) {
        final isOn = newStatus ==
            widget.statusList.entries.firstWhere((e) => e.value == 1).key;
        setState(() {
          switchStates[uid] = isOn;
        });
      }

      await Future.delayed(const Duration(milliseconds: 600));

      _switchBloc.add(TriggerSwitchEvent(
        deviceId: switchId,
        status: newStatus,
        uuid: widget.switches["uid"],
        deviceType: 3,
        childuid: uid,
      ));

      debugPrint("Switch $uid toggled to $newStatus");
    } catch (e) {
      debugPrint("Toggle failed: $e");

      // Restore toggle state if applicable
      if (deviceType == 1) {
        setState(() {
          switchStates[uid] = _previousToggleValue ?? false;
        });
      }
    }
  }

  Future<bool?> _confirmAction(BuildContext context, bool turnOn) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Action"),
          content: Text(
            turnOn
                ? "Are you sure you want to turn ON all switches?"
                : "Are you sure you want to turn OFF all switches?",
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("CANCEL"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: turnOn
                    ? Theme.of(context).appColors.greenButton
                    : Theme.of(context).appColors.redButton,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("YES"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageUrl = widget.switches["details"]["icon"] ?? "";

    return Column(
      children: [
        BlocListener<SwitchBloc, CommonState>(
          bloc: _switchBloc,
          listener: (context, state) {
            final apiResponse = state.apiStatus;
            if (apiResponse is ApiResponse) {
              final responseData = apiResponse.response;
              if (responseData != null && responseData["status"] == "success") {
                // widget.onChanged.call();
                commonSnackBar(context, responseData["message"]);
                if (responseData["message"] ==
                    "Device turned ONALL successfully!") {
                  setState(() {
                    mainSwitchStatus = true;
                  });
                } else if (responseData["message"] ==
                    "Device turned OFFALL successfully!") {
                  setState(() {
                    mainSwitchStatus = false;
                  });
                }
              }
            } else if (apiResponse is ApiFailureState) {
              final exception = apiResponse.exception.toString();
              String errorMessage = 'Something went wrong! Please try again';
              final messageMatch =
                  RegExp(r'message:\s*([^}]+)').firstMatch(exception);
              if (messageMatch != null) {
                errorMessage = messageMatch.group(1)?.trim() ?? errorMessage;
              }
              showSnackBar(context, errorMessage);

              // 👉 Restore switch state if it was a toggle failure
              if (_pendingToggleId != null) {
                setState(() {
                  switchStates[_pendingToggleId!] =
                      _previousToggleValue ?? false;
                  _pendingToggleId = null;
                  _previousToggleValue = null;
                });
              }
            }
          },
          child: ExpansionTile(
            title: Row(children: [
              Expanded(
                flex: 2,
                child: CachedNetworkImage(
                  imageUrl: imageUrl ?? "",
                  height: screenWidth * 0.1,
                  width: screenWidth * 0.1,
                  color: Theme.of(context).appColors.textSecondary,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      height: screenWidth * 0.1,
                      width: screenWidth * 0.1,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.image_outlined,
                    color: Theme.of(context)
                        .appColors
                        .textPrimary
                        .withOpacity(0.3),
                    size: screenWidth * 0.1,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                flex: 6,
                child: Text(
                  widget.switches["device_name"] ?? "",
                  style: TextStyle(
                    color: Theme.of(context).appColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Expanded(
                  flex: 3,
                  child: ToggleButtons(
                    borderRadius: BorderRadius.circular(50),
                    fillColor: Theme.of(context).appColors.green,
                    selectedColor: Theme.of(context).appColors.greenButton,
                    color: Theme.of(context).appColors.redButton,
                    isSelected: [mainSwitchStatus ?? false],
                    onPressed: (index) async {
                      final newValue = !(mainSwitchStatus ?? false);

                      final confirm = await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: (newValue
                                          ? Theme.of(context)
                                              .appColors
                                              .greenButton
                                          : Theme.of(context)
                                              .appColors
                                              .redButton)
                                      .withOpacity(0.1),
                                  radius: 24,
                                  child: Icon(
                                    Icons.power_settings_new_outlined,
                                    color: newValue
                                        ? Theme.of(context)
                                            .appColors
                                            .greenButton
                                        : Theme.of(context).appColors.redButton,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Confirm Action",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context)
                                                .appColors
                                                .textPrimary),
                                  ),
                                ),
                              ],
                            ),
                            content: Text(
                              newValue
                                  ? "Are you sure you want to turn ON all switches?"
                                  : "Are you sure you want to turn OFF all switches?",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .appColors
                                        .textPrimary
                                        .withOpacity(0.8),
                                  ),
                            ),
                            actions: [
                              OutlinedButton(
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).appColors.redButton,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("CANCEL"),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: newValue
                                      ? Theme.of(context).appColors.greenButton
                                      : Theme.of(context).appColors.redButton,
                                ),
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  "YES",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true) {
                        toggleSwitch(
                          widget.switches["device_id"] ?? "",
                          newValue ? "ONALL" : "OFFALL",
                          "",
                          widget.switches["device_type"] ?? 0,
                        );
                        setState(() {
                          mainSwitchStatus = newValue;
                        });
                      }
                    },
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: (mainSwitchStatus ?? false)
                              ? Theme.of(context).appColors.green
                              : Theme.of(context).appColors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (mainSwitchStatus ?? false)
                                  ? Colors.green.withOpacity(0.5)
                                  : Colors.red.withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(10),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(
                            scale: animation,
                            child: child,
                          ),
                          child: Icon(
                            Icons.power_settings_new_outlined,
                            key: ValueKey<bool>(mainSwitchStatus ?? false),
                            size: 30,
                            color: (mainSwitchStatus ?? false)
                                ? Theme.of(context).appColors.greenButton
                                : Theme.of(context).appColors.redButton,
                          ),
                        ),
                      )
                    ],
                  )),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => widget.deleteDevice(context, widget.switches),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).appColors.red,
                    ),
                  ),
                ),
              ),
            ]),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            backgroundColor: Theme.of(context).appColors.buttonBackground,
            collapsedBackgroundColor: Theme.of(context).appColors.background,
            iconColor: Theme.of(context).appColors.background,
            collapsedIconColor: Theme.of(context).appColors.textSecondary,
            dense: true,
            visualDensity: VisualDensity.compact,
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: multiSwitches.length,
                separatorBuilder: (context, index) => Divider(
                  color:
                      Theme.of(context).appColors.textPrimary.withOpacity(0.1),
                  thickness: 1,
                ),
                itemBuilder: (context, index) {
                  final device = multiSwitches[index];
                  final imageUrl = device["details"]["icon"] ?? "";
                  final deviceName = device["device_name"] ?? "";
                  final deviceType = device["device_type"] ?? 0;
                  final switchIndex = multiSwitches
                          .where((d) => d["device_type"] == 1)
                          .toList()
                          .indexOf(device) +
                      1;
                  debugPrint("$switchIndex");
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Image
                            Expanded(
                              flex: 2,
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                height: screenWidth * 0.1,
                                width: screenWidth * 0.1,
                                color: Theme.of(context).appColors.background,
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: Colors.grey.shade100,
                                  child: Container(
                                    height: screenWidth * 0.1,
                                    width: screenWidth * 0.1,
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.image_outlined,
                                  color: Theme.of(context)
                                      .appColors
                                      .textPrimary
                                      .withOpacity(0.3),
                                  size: screenWidth * 0.1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            // Device name
                            Expanded(
                              flex: 6,
                              child: Text(
                                deviceName,
                                style: TextStyle(
                                  color: Theme.of(context).appColors.background,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (deviceType == 1)
                              Expanded(
                                flex: 3,
                                child: ToggleButtons(
                                  borderRadius: BorderRadius.circular(50),
                                  isSelected: [
                                    switchStates[device["uid"]] ?? false
                                  ],
                                  fillColor: Theme.of(context).appColors.green,
                                  selectedColor:
                                      Theme.of(context).appColors.greenButton,
                                  color: Theme.of(context).appColors.redButton,
                                  onPressed: (i) {
                                    final newValue =
                                        !(switchStates[device["uid"]] ?? false);

                                    toggleSwitch(
                                      widget.switches["device_id"],
                                      newValue
                                          ? "ON$switchIndex"
                                          : "OFF$switchIndex",
                                      device["uid"] ?? "",
                                      deviceType,
                                    );

                                    setState(() {
                                      switchStates[device["uid"]] = newValue;
                                    });
                                  },
                                  children: [
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 400),
                                      curve: Curves.easeInOut,
                                      decoration: BoxDecoration(
                                        color: (switchStates[device["uid"]] ??
                                                false)
                                            ? Theme.of(context).appColors.green
                                            : Theme.of(context).appColors.red,
                                        borderRadius: BorderRadius.circular(50),
                                        boxShadow: [
                                          BoxShadow(
                                            color: (switchStates[
                                                        device["uid"]] ??
                                                    false)
                                                ? Colors.green.withOpacity(0.4)
                                                : Colors.red.withOpacity(0.4),
                                            blurRadius: 12,
                                            spreadRadius: 2,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      child: AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 400),
                                        transitionBuilder: (child, animation) =>
                                            ScaleTransition(
                                          scale: animation,
                                          child: child,
                                        ),
                                        child: Icon(
                                          Icons.power_settings_new_outlined,
                                          key: ValueKey<bool>(
                                              switchStates[device["uid"]] ??
                                                  false),
                                          size: 28,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                          ],
                        ),
                        if (deviceType == 2) ...[
                          FanSpeedControl(
                            deviceId: widget.switches["device_id"],
                            fanStatusList: widget.fanStatusList,
                            device: device,
                            toggleSwitch: toggleSwitch,
                            deviceType: device["device_type"],
                          )
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
