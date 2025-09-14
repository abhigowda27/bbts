import 'dart:convert';

import 'package:bbts_server/blocs/switch/switch_bloc.dart';
import 'package:bbts_server/blocs/switch/switch_event.dart';
import 'package:bbts_server/screens/bbtm_screens/controllers/storage.dart';
import 'package:bbts_server/screens/bbtm_screens/models/group_model.dart';
import 'package:bbts_server/screens/bbtm_screens/models/router_model.dart';
import 'package:bbts_server/screens/bbtm_screens/models/switch_model.dart';
import 'package:bbts_server/screens/bbtm_screens/widgets/custom/custom_button.dart';
import 'package:bbts_server/screens/bbtm_screens/widgets/custom/toast.dart';
import 'package:bbts_server/screens/bbtm_screens/widgets/group/group_card.dart';
import 'package:bbts_server/screens/bbtm_screens/widgets/router/router_card.dart';
import 'package:bbts_server/screens/bbtm_screens/widgets/switches/switches_card.dart';
import 'package:bbts_server/screens/tabs_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class ScanQr extends StatefulWidget {
  const ScanQr({required this.type, super.key});
  final String type;

  @override
  State<ScanQr> createState() => _QRViewState();
}

class _QRViewState extends State<ScanQr> {
  SwitchDetails? details;
  RouterDetails? routerDetails;
  GroupDetails? groupDetails;
  final SwitchBloc _switchBloc = SwitchBloc();
  String _scanBarcode = 'Unknown';
  final StorageController _storageController = StorageController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    scanQR();
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.QR,
      );
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (!mounted) return;

    String scannedData = 'Unknown';
    try {
      debugPrint("barcode Scan Res");
      debugPrint(barcodeScanRes);

      Map<String, dynamic> qrData = jsonDecode(barcodeScanRes);

      if (widget.type == "switch") {
        if (qrData['data'].containsKey("switch")) {
          final SwitchDetails switchDetails = SwitchDetails.fromJson(
            qrData['data']['switch'],
            qrData['data']['contact'],
          );
          setState(() {
            details = switchDetails;
          });
        } else {
          await _showMismatchDialog("Switch", qrData['data'].keys.first);
          return;
        }
      } else if (widget.type == "router") {
        if (qrData['data'].containsKey("router")) {
          final RouterDetails router = RouterDetails.fromJsonAdd(
            qrData['data']['router'],
            qrData['data']['contact'],
          );
          setState(() {
            routerDetails = router;
          });
        } else {
          await _showMismatchDialog("Router", qrData['data'].keys.first);
          return;
        }
      } else if (widget.type == "group") {
        if (qrData['data'].containsKey("group")) {
          final GroupDetails group = GroupDetails.fromJsonAdd(
            qrData['data']['group'],
            qrData['data']['contact'],
          );
          setState(() {
            groupDetails = group;
          });
        } else {
          await _showMismatchDialog("Group", qrData['data'].keys.first);
          return;
        }
      }

      setState(() {
        scannedData = qrData.toString();
      });
    } catch (e, stack) {
      debugPrint("QR parsing error: $e $stack");
      setState(() {
        scannedData = "The QR does not have the right data: ${e.toString()}";
      });
    }

    setState(() {
      _scanBarcode = scannedData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add ${widget.type}"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.type == "switch") ...[
              details != null
                  ? SwitchCard(
                      switchDetails: details!,
                      showOptions: false,
                    )
                  : const CircularProgressIndicator()
            ] else if (widget.type == "router") ...[
              routerDetails != null
                  ? RouterCard(
                      routerDetails: routerDetails!,
                      showOptions: false,
                    )
                  : const CircularProgressIndicator()
            ] else if (widget.type == "group") ...[
              groupDetails != null
                  ? GroupCard(
                      groupDetails: groupDetails!,
                      showOptions: false,
                    )
                  : const CircularProgressIndicator()
            ] else ...[
              Text("Invalid Type ${widget.type}")
            ],
            CustomButton(
              text: "Add",
              onPressed: () async {
                debugPrint(_scanBarcode);
                if (_scanBarcode == "Unknown") {
                  showToast("QR data is not correct.");
                  return;
                }
                if (widget.type == "switch" && details != null) {
                  _storageController.addSwitches(details!);
                } else if (widget.type == "router" && routerDetails != null) {
                  try {
                    // Build the switches list
                    List<Map<String, dynamic>> switchesPayload = [];

                    // Add selected switches
                    for (var i = 0;
                        i < routerDetails!.switchTypes.length;
                        i++) {
                      switchesPayload.add({
                        "type": 1,
                        "name": routerDetails?.switchTypes[i],
                        "order": i + 1,
                      });
                    }

                    if (routerDetails != null &&
                        routerDetails!.selectedFan != null &&
                        routerDetails!.selectedFan!.isNotEmpty) {
                      switchesPayload.add({
                        "type": 2, // 2 = fan
                        "name": routerDetails!.selectedFan,
                      });
                    }

                    // Final payload
                    final payload = {
                      "deviceName": routerDetails?.switchName,
                      "deviceType": 3,
                      "deviceId": routerDetails?.deviceMacId,
                      "switches": switchesPayload
                    };

                    _switchBloc.add(AddSwitchEvent(payload: payload));
                  } catch (e) {
                    debugPrint("Error ${e.toString()}");
                  }
                  _storageController.addRouters(routerDetails!);
                } else if (widget.type == "group" && groupDetails != null) {
                  await _storageController.saveGroupDetails(groupDetails!);
                } else {
                  showToast("No details available to save.");
                  return;
                }

                Navigator.pushAndRemoveUntil<dynamic>(
                  context,
                  MaterialPageRoute<dynamic>(
                    builder: (BuildContext context) => const TabsPage(),
                  ),
                  (route) => false,
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Future<void> _showMismatchDialog(String expected, String found) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("QR Type Mismatch"),
          content: Text(
            "Expected a \"$expected\" QR but scanned a \"$found\" QR.\n\nPlease scan again.",
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
                scanQR(); // rescan directly
              },
              child: const Text("Scan Again"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
                Navigator.of(context).pop(); // just close
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }
}
