import 'package:bbts_server/blocs/switch/switch_bloc.dart';
import 'package:bbts_server/blocs/switch/switch_event.dart';
import 'package:bbts_server/common/api_status.dart';
import 'package:bbts_server/common/common_state.dart';
import 'package:bbts_server/screens/switches/widgets/multi_switch_list.dart';
import 'package:bbts_server/theme/app_colors_extension.dart';
import 'package:bbts_server/widgets/common_snackbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import 'fan_controller_widget.dart';

class SwitchesCard extends StatefulWidget {
  final Map<String, dynamic> switchesDetails;
  final Function onChanged;

  const SwitchesCard({
    required this.switchesDetails,
    super.key,
    required this.onChanged,
  });

  @override
  State<SwitchesCard> createState() => _SwitchesCardState();
}

class _SwitchesCardState extends State<SwitchesCard> {
  Map<String, bool> switchStates = {};
  Map<String, dynamic> statusList = {};
  Map<String, dynamic> fanStatusList = {};
  Map<String, dynamic> multiStatusList = {};
  Map<String, dynamic> deviceDetails = {};
  List<dynamic> deviceList = [];
  final SwitchBloc _switchBloc = SwitchBloc();
  String? _pendingToggleId;
  bool? _previousToggleValue;
  String? _pendingDeleteId;

  @override
  void initState() {
    super.initState();
    setValues();
  }

  void setValues() {
    final statusConfigs = widget.switchesDetails["deviceStatus"] ?? [];

    for (var config in statusConfigs) {
      final deviceType = config["deviceType"];
      final statuses = config["status"];

      if (deviceType == 1) {
        statusList = {
          for (var s in statuses) s["title"]: s["id"],
        };
      } else if (deviceType == 2) {
        fanStatusList = {
          for (var s in statuses) s["title"]: s["id"],
        };
      } else if (deviceType == 3) {
        multiStatusList = {
          for (var s in statuses) s["title"]: s["id"],
        };
      }
    }

    deviceList = widget.switchesDetails["list"] ?? [];
    for (var device in deviceList) {
      final id = device["device_id"];
      switchStates[id] = device["details"]["statusTxt"] == "ON" ? true : false;
      debugPrint("${switchStates[id]}");
    }
    debugPrint("?????$statusList");
    debugPrint("?????$fanStatusList");
    debugPrint("?????$multiStatusList");
  }

  Future<void> toggleSwitch(
    String switchId,
    String newStatus,
    String uid,
    int deviceType,
  ) async {
    try {
      _pendingToggleId = switchId;
      _previousToggleValue = switchStates[switchId];

      // For deviceType 1 (boolean switch), update internal toggle state
      if (deviceType == 1) {
        final isOn =
            newStatus == statusList.entries.firstWhere((e) => e.value == 1).key;
        setState(() {
          switchStates[switchId] = isOn;
        });
      }

      await Future.delayed(const Duration(milliseconds: 600));

      _switchBloc.add(TriggerSwitchEvent(
        deviceId: switchId,
        status: newStatus,
        uuid: uid,
        deviceType: deviceType,
        childuid: '',
      ));

      debugPrint("Switch $switchId toggled to $newStatus");
    } catch (e) {
      debugPrint("Toggle failed: $e");

      // Restore toggle state if applicable
      if (deviceType == 1) {
        setState(() {
          switchStates[switchId] = _previousToggleValue ?? false;
        });
      }
    }
  }

  void deleteDevice(BuildContext context, Map<String, dynamic> device1) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Theme.of(context).appColors.redButton,
            ),
            const SizedBox(width: 10),
            Text(
              "Delete Device",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).appColors.textSecondary,
              ),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to delete this device?\nThis action cannot be undone.",
          style: TextStyle(
            color: Theme.of(context).appColors.textSecondary,
          ),
        ),
        actionsPadding: const EdgeInsets.only(right: 12, bottom: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).appColors.textSecondary,
            ),
            child: const Text("Cancel"),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text("Delete"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).appColors.redButton,
              foregroundColor: Theme.of(context).appColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _pendingDeleteId = device1["device_id"];
              });
              _switchBloc.add(DeleteSwitchEvent(
                deviceId: device1["device_id"],
                uuid: device1["uid"],
              ));
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    deviceDetails = widget.switchesDetails;
    deviceList = deviceDetails["list"] ?? [];
    return BlocConsumer<SwitchBloc, CommonState>(
        bloc: _switchBloc,
        listener: (context, state) {
          final apiResponse = state.apiStatus;

          if (apiResponse is ApiResponse) {
            final responseData = apiResponse.response;
            if (responseData != null && responseData["status"] == "success") {
              // widget.onChanged.call();
              if (_pendingDeleteId != null) {
                setState(() {
                  deviceList.removeWhere(
                      (device) => device["device_id"] == _pendingDeleteId);
                  switchStates.remove(_pendingDeleteId);
                  _pendingDeleteId = null;
                });
              }
              commonSnackBar(context, responseData["message"]);
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
                switchStates[_pendingToggleId!] = _previousToggleValue ?? false;
                _pendingToggleId = null;
                _previousToggleValue = null;
              });
            }

            _pendingDeleteId = null;
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              if (deviceDetails["title"] != null &&
                  deviceDetails["title"].isNotEmpty) ...[
                Text(
                  deviceDetails["title"] ?? "",
                  style: TextStyle(
                    fontSize: 28,
                    color: Theme.of(context).appColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              ListView.separated(
                shrinkWrap: true,
                itemCount: deviceList.length,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final device0 = deviceList[index];
                  final imageUrl = device0["details"]["icon"] ?? "";
                  debugPrint("${device0.runtimeType}");
                  return Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade400,
                            blurRadius: 1,
                          ),
                        ],
                        color: Theme.of(context).appColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          if (device0["device_type"] == 3) ...[
                            MultiDevicesWidget(
                              deleteDevice: deleteDevice,
                              onChanged: widget.onChanged,
                              statusList: statusList,
                              switches: device0,
                              fanStatusList: fanStatusList,
                            )
                          ] else ...[
                            ExpansionTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              collapsedShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor:
                                  Theme.of(context).appColors.buttonBackground,
                              collapsedBackgroundColor:
                                  Theme.of(context).appColors.background,
                              iconColor: Theme.of(context).appColors.background,
                              collapsedIconColor:
                                  Theme.of(context).appColors.textSecondary,
                              dense: true,
                              visualDensity: VisualDensity.compact,
                              title: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrl ?? "",
                                      height: screenWidth * 0.1,
                                      width: screenWidth * 0.1,
                                      color: Theme.of(context)
                                          .appColors
                                          .textSecondary,
                                      placeholder: (context, url) =>
                                          Shimmer.fromColors(
                                        baseColor: Colors.grey.shade300,
                                        highlightColor: Colors.grey.shade100,
                                        child: Container(
                                          height: screenWidth * 0.1,
                                          width: screenWidth * 0.1,
                                          decoration: BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(
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
                                      device0["device_name"] ?? "",
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .appColors
                                            .textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () =>
                                          deleteDevice(context, device0),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.delete_outline,
                                          color:
                                              Theme.of(context).appColors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              children: [
                                Divider(
                                  color: Theme.of(context)
                                      .appColors
                                      .textPrimary
                                      .withOpacity(0.1),
                                  thickness: 1,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .appColors
                                          .buttonBackground),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: device0["device_type"] == 2
                                      ? FanSpeedControl(
                                          deviceId: device0["device_id"],
                                          fanStatusList: fanStatusList,
                                          device: device0,
                                          toggleSwitch: toggleSwitch,
                                          deviceType: device0["device_type"],
                                        )
                                      : ToggleButtons(
                                          constraints: const BoxConstraints(
                                            minWidth: 100,
                                            minHeight: 100,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          isSelected: [
                                            switchStates[
                                                    device0["device_id"]] ??
                                                false
                                          ],
                                          fillColor:
                                              Theme.of(context).appColors.green,
                                          selectedColor: Theme.of(context)
                                              .appColors
                                              .greenButton,
                                          color: Theme.of(context)
                                              .appColors
                                              .redButton,
                                          onPressed: (index) {
                                            final newValue = !(switchStates[
                                                    device0["device_id"]] ??
                                                false);

                                            toggleSwitch(
                                              device0["device_id"] ?? "",
                                              newValue ? "ON" : "OFF",
                                              device0["uid"] ?? "",
                                              device0["device_type"] ?? 0,
                                            );

                                            setState(() {
                                              switchStates[
                                                      device0["device_id"]] =
                                                  newValue;
                                            });
                                          },
                                          children: [
                                            AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 400),
                                              curve: Curves.easeInOut,
                                              decoration: BoxDecoration(
                                                color: (switchStates[device0[
                                                            "device_id"]] ??
                                                        false)
                                                    ? Theme.of(context)
                                                        .appColors
                                                        .green
                                                    : Theme.of(context)
                                                        .appColors
                                                        .red,
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: (switchStates[device0[
                                                                "device_id"]] ??
                                                            false)
                                                        ? Colors.green
                                                            .withOpacity(0.5)
                                                        : Colors.red
                                                            .withOpacity(0.5),
                                                    blurRadius: 15,
                                                    spreadRadius: 3,
                                                    offset: const Offset(0, 5),
                                                  ),
                                                ],
                                              ),
                                              padding: const EdgeInsets.all(30),
                                              child: AnimatedSwitcher(
                                                duration: const Duration(
                                                    milliseconds: 400),
                                                transitionBuilder:
                                                    (child, animation) =>
                                                        ScaleTransition(
                                                  scale: animation,
                                                  child: child,
                                                ),
                                                child: Icon(
                                                  Icons
                                                      .power_settings_new_outlined,
                                                  key: ValueKey<bool>(
                                                      switchStates[device0[
                                                              "device_id"]] ??
                                                          false),
                                                  size: 40,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                ),
                              ],
                            )
                          ],

                          // Expansion for device_type == 3
                        ],
                      ));
                },
              ),
            ],
          );
        });
  }
}

// Updated UI structure inspired by the design in the uploaded image
// Key changes:
// - For deviceType 1: ON/OFF button
// - For deviceType 2: vertical slider with HIGH, MED, LOW, OFF

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:bbt_multi_switch/blocs/switch/switch_bloc.dart';
// import 'package:bbt_multi_switch/blocs/switch/switch_event.dart';
// import 'package:bbt_multi_switch/common/api_status.dart';
// import 'package:bbt_multi_switch/common/common_state.dart';
// import 'package:bbt_multi_switch/theme/app_colors_extension.dart';
// import 'package:bbt_multi_switch/widgets/common_snackbar.dart';
// import 'package:shimmer/shimmer.dart';
//
// class SwitchesCard extends StatefulWidget {
//   final Map<String, dynamic> switchesDetails;
//   const SwitchesCard({required this.switchesDetails, super.key});
//
//   @override
//   State<SwitchesCard> createState() => _SwitchesCardState();
// }
//
// class _SwitchesCardState extends State<SwitchesCard> {
//   Map<String, bool> switchStates = {};
//   Map<String, dynamic> statusList = {};
//   Map<String, dynamic> fanStatusList = {};
//   Map<String, dynamic> deviceDetails = {};
//   List<dynamic> deviceList = [];
//   final SwitchBloc _switchBloc = SwitchBloc();
//   String? _pendingToggleId;
//   bool? _previousToggleValue;
//   String? _pendingDeleteId;
//
//   @override
//   void initState() {
//     super.initState();
//     setValues();
//   }
//
//   void setValues() {
//     final statusConfigs = widget.switchesDetails["deviceStatus"] ?? [];
//
//     for (var config in statusConfigs) {
//       final deviceType = config["deviceType"];
//       final statuses = config["status"];
//
//       if (deviceType == 1) {
//         statusList = {for (var s in statuses) s["title"]: s["id"]};
//       } else if (deviceType == 2) {
//         fanStatusList = {for (var s in statuses) s["title"]: s["id"]};
//       }
//     }
//
//     deviceList = widget.switchesDetails["list"] ?? [];
//     for (var device in deviceList) {
//       final id = device["device_id"];
//       switchStates[id] = device["details"]["statusTxt"] == "ON";
//     }
//   }
//
//   Future<void> toggleSwitch(
//       String switchId, String newStatus, String uid, int deviceType) async {
//     try {
//       _pendingToggleId = switchId;
//       _previousToggleValue = switchStates[switchId];
//       if (deviceType == 1) {
//         final isOn =
//             newStatus == statusList.entries.firstWhere((e) => e.value == 1).key;
//         setState(() {
//           switchStates[switchId] = isOn;
//         });
//       }
//       await Future.delayed(const Duration(milliseconds: 600));
//       _switchBloc.add(TriggerSwitchEvent(
//           deviceId: switchId,
//           status: newStatus,
//           uuid: uid,
//           deviceType: deviceType));
//     } catch (e) {
//       if (deviceType == 1) {
//         setState(() {
//           switchStates[switchId] = _previousToggleValue ?? false;
//         });
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     deviceDetails = widget.switchesDetails;
//     deviceList = deviceDetails["list"] ?? [];
//
//     return BlocConsumer<SwitchBloc, CommonState>(
//       bloc: _switchBloc,
//       listener: (context, state) {
//         final apiResponse = state.apiStatus;
//         if (apiResponse is ApiResponse) {
//           final responseData = apiResponse.response;
//           if (responseData != null && responseData["status"] == "success") {
//             if (_pendingDeleteId != null) {
//               setState(() {
//                 deviceList.removeWhere(
//                     (device) => device["device_id"] == _pendingDeleteId);
//                 switchStates.remove(_pendingDeleteId);
//                 _pendingDeleteId = null;
//               });
//             }
//             commonSnackBar(context, responseData["message"]);
//           }
//         } else if (apiResponse is ApiFailureState) {
//           final exception = apiResponse.exception.toString();
//           String errorMessage = 'Something went wrong! Please try again';
//           final messageMatch =
//               RegExp(r'message:\s*([^}]+)').firstMatch(exception);
//           if (messageMatch != null) {
//             errorMessage = messageMatch.group(1)?.trim() ?? errorMessage;
//           }
//           showSnackBar(context, errorMessage);
//
//           // 👉 Restore switch state if it was a toggle failure
//           if (_pendingToggleId != null) {
//             setState(() {
//               switchStates[_pendingToggleId!] = _previousToggleValue ?? false;
//               _pendingToggleId = null;
//               _previousToggleValue = null;
//             });
//           }
//
//           _pendingDeleteId = null;
//         }
//       },
//       builder: (context, state) {
//         return Column(
//           children: [
//             if (deviceDetails["title"] != null &&
//                 deviceDetails["title"].isNotEmpty) ...[
//               Text(
//                 deviceDetails["title"] ?? "",
//                 style: TextStyle(
//                   fontSize: 28,
//                   color: Theme.of(context).appColors.textSecondary,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 10),
//             ],
//             ListView.separated(
//               shrinkWrap: true,
//               itemCount: deviceList.length,
//               physics: const NeverScrollableScrollPhysics(),
//               separatorBuilder: (_, __) => const SizedBox(height: 16),
//               itemBuilder: (context, index) {
//                 final device = deviceList[index];
//                 final imageUrl = device["details"]["icon"] ?? "";
//                 final name = device["device_name"] ?? "";
//                 final type = device["device_type"] ?? 1;
//                 final status = device["details"]["status"];
//                 final statusTxt = device["details"]["statusTxt"];
//                 debugPrint("$device");
//                 if (type == 1) {
//                   return Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).appColors.background,
//                       borderRadius: BorderRadius.circular(20),
//                       boxShadow: const [
//                         BoxShadow(
//                           color: Colors.black12,
//                           blurRadius: 6,
//                           offset: Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Align(
//                           alignment: Alignment.topLeft,
//                           child: Text(
//                             name,
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               color: Theme.of(context).appColors.textPrimary,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         // CachedNetworkImage(
//                         //   imageUrl: imageUrl,
//                         //   height: 70,
//                         //   width: 70,
//                         //   color: Theme.of(context).appColors.textSecondary,
//                         //   placeholder: (_, __) => Shimmer.fromColors(
//                         //     baseColor: Colors.grey.shade300,
//                         //     highlightColor: Colors.grey.shade100,
//                         //     child: Container(
//                         //       height: 60,
//                         //       width: 60,
//                         //       decoration: BoxDecoration(
//                         //         color: Colors.grey,
//                         //         borderRadius: BorderRadius.circular(8),
//                         //       ),
//                         //     ),
//                         //   ),
//                         //   errorWidget: (_, __, ___) => const Icon(Icons.image,
//                         //       size: 60, color: Colors.grey),
//                         // ),
//                         // const SizedBox(height: 10),
//                         IconButton(
//                             onPressed: () {
//                               final newState =
//                                   switchStates[device["device_id"]] == true
//                                       ? "OFF"
//                                       : "ON";
//                               toggleSwitch(device["device_id"], newState,
//                                   device["uid"], type);
//                             },
//                             icon: Container(
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.2),
//                                     blurRadius: 10,
//                                     spreadRadius: 2,
//                                     offset: const Offset(0, 4),
//                                   ),
//                                 ],
//                               ),
//                               child: CircleAvatar(
//                                 radius: 70,
//                                 backgroundColor:
//                                     switchStates[device["device_id"]] == true
//                                         ? const Color(
//                                             0xFF4CAF50) // Vibrant Green
//                                         : const Color(0xFFE53935), // Bold Red
//                                 child: CachedNetworkImage(
//                                   imageUrl: imageUrl,
//                                   height: 90,
//                                   width: 90,
//                                   fit: BoxFit.cover,
//                                   color: Theme.of(context)
//                                       .appColors
//                                       .background
//                                       .withOpacity(0.8),
//                                   placeholder: (_, __) => Shimmer.fromColors(
//                                     baseColor: Colors.grey.shade300,
//                                     highlightColor: Colors.grey.shade100,
//                                     child: Container(
//                                       height: 120,
//                                       width: 120,
//                                       decoration: const BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: Colors.grey,
//                                       ),
//                                     ),
//                                   ),
//                                   errorWidget: (_, __, ___) => const Icon(
//                                     Icons.broken_image,
//                                     size: 60,
//                                     color: Colors.white70,
//                                   ),
//                                 ),
//                               ),
//                             ))
//                       ],
//                     ),
//                   );
//                 } else if (type == 2) {
//                   return Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).appColors.background,
//                       borderRadius: BorderRadius.circular(20),
//                       boxShadow: const [
//                         BoxShadow(
//                           color: Colors.black12,
//                           blurRadius: 6,
//                           offset: Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           name,
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: Theme.of(context).appColors.textPrimary,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         Row(
//                           children: [
//                             Expanded(
//                               flex: 4,
//                               child: CachedNetworkImage(
//                                 imageUrl: imageUrl,
//                                 height: 90,
//                                 width: 90,
//                                 color:
//                                     Theme.of(context).appColors.textSecondary,
//                                 placeholder: (_, __) => Shimmer.fromColors(
//                                   baseColor: Colors.grey.shade300,
//                                   highlightColor: Colors.grey.shade100,
//                                   child: Container(
//                                     height: 60,
//                                     width: 60,
//                                     decoration: BoxDecoration(
//                                       color: Colors.grey,
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                   ),
//                                 ),
//                                 errorWidget: (_, __, ___) => const Icon(
//                                     Icons.image,
//                                     size: 60,
//                                     color: Colors.grey),
//                               ),
//                             ),
//                             Expanded(
//                               child: Column(
//                                 children: [
//                                   Text(
//                                     "HIGH",
//                                     style: TextStyle(
//                                       color: Theme.of(context)
//                                           .appColors
//                                           .textPrimary,
//                                     ),
//                                   ),
//                                   RotatedBox(
//                                     quarterTurns: -1,
//                                     child: Builder(
//                                       builder: (context) {
//                                         final keys =
//                                             fanStatusList.keys.toList();
//                                         final values =
//                                             fanStatusList.values.toList();
//                                         debugPrint("$keys");
//                                         debugPrint("$values");
//                                         final currentIndex =
//                                             values.indexOf(status);
//                                         final double safeValue =
//                                             currentIndex >= 0
//                                                 ? currentIndex.toDouble()
//                                                 : 0.0;
//
//                                         return SliderTheme(
//                                           data:
//                                               SliderTheme.of(context).copyWith(
//                                             trackHeight: 6.0,
//                                             activeTrackColor: Theme.of(context)
//                                                 .appColors
//                                                 .primary,
//                                             inactiveTrackColor:
//                                                 Theme.of(context)
//                                                     .appColors
//                                                     .primary
//                                                     .withOpacity(0.3),
//                                             trackShape:
//                                                 const RoundedRectSliderTrackShape(),
//                                             thumbColor: Theme.of(context)
//                                                 .appColors
//                                                 .white,
//                                             thumbShape:
//                                                 const RoundSliderThumbShape(
//                                                     enabledThumbRadius: 12),
//                                             overlayColor: Theme.of(context)
//                                                 .appColors
//                                                 .primary
//                                                 .withOpacity(0.4),
//                                             overlayShape:
//                                                 const RoundSliderOverlayShape(
//                                                     overlayRadius: 24),
//                                             tickMarkShape:
//                                                 const RoundSliderTickMarkShape(),
//                                             activeTickMarkColor:
//                                                 Theme.of(context)
//                                                     .appColors
//                                                     .white,
//                                             inactiveTickMarkColor:
//                                                 Theme.of(context)
//                                                     .appColors
//                                                     .grey,
//                                             valueIndicatorColor:
//                                                 Theme.of(context)
//                                                     .appColors
//                                                     .primary,
//                                             valueIndicatorTextStyle: TextStyle(
//                                               color: Theme.of(context)
//                                                   .appColors
//                                                   .background,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                           child: Slider(
//                                             value: safeValue,
//                                             min: 0,
//                                             max: (keys.length - 1).toDouble(),
//                                             divisions: keys.length - 1,
//                                             label: statusTxt,
//                                             onChanged: (value) {
//                                               final selected =
//                                                   keys[value.round()];
//                                               final newStatus =
//                                                   fanStatusList[selected];
//                                               toggleSwitch(device["device_id"],
//                                                   selected, device["uid"], 2);
//                                               setState(() {
//                                                 device["details"]["status"] =
//                                                     newStatus;
//                                                 device["details"]["statusTxt"] =
//                                                     selected;
//                                               });
//                                             },
//                                           ),
//                                         );
//                                       },
//                                     ),
//                                   ),
//                                   Text(
//                                     "LOW",
//                                     style: TextStyle(
//                                       color: Theme.of(context)
//                                           .appColors
//                                           .textPrimary,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   );
//                 }
//                 return null;
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
