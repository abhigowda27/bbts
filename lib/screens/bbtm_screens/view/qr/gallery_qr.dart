import 'dart:convert';

import 'package:bbts_server/main.dart';
import 'package:bbts_server/screens/bbtm_screens/controllers/storage.dart';
import 'package:bbts_server/screens/bbtm_screens/models/group_model.dart';
import 'package:bbts_server/screens/bbtm_screens/models/router_model.dart';
import 'package:bbts_server/screens/bbtm_screens/models/switch_model.dart';
import 'package:bbts_server/screens/bbtm_screens/widgets/custom/custom_button.dart';
import 'package:bbts_server/screens/bbtm_screens/widgets/custom/toast.dart';
import 'package:bbts_server/screens/bbtm_screens/widgets/group/group_card.dart';
import 'package:bbts_server/screens/bbtm_screens/widgets/router/router_card.dart';
import 'package:bbts_server/screens/bbtm_screens/widgets/switches/switches_card.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class GalleryQRPage extends StatefulWidget {
  const GalleryQRPage({required this.type, super.key});
  final String type;

  @override
  State<GalleryQRPage> createState() => _GalleryQRPageState();
}

class _GalleryQRPageState extends State<GalleryQRPage> {
  final StorageController _storageController = StorageController();
  bool loading = false;
  SwitchDetails? details;
  RouterDetails? routerDetails;
  GroupDetails? groupDetails;
  late String groupName;
  late String selectedRouter;
  late String routerPassword;
  List<RouterDetails> selectedSwitches = [];
  String _scanBarcode = 'Unknown';
  late bool exists;

  @override
  void initState() {
    super.initState();
    scanFromGallery();
  }

  Future<void> scanFromGallery() async {
    try {
      final XFile? res =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (res == null) return;

      final controller = MobileScannerController();

      final BarcodeCapture? capture = await controller.analyzeImage(res.path);

      controller.dispose();

      if (capture == null || capture.barcodes.isEmpty) {
        debugPrint("QR code not found in the selected image.");
        return;
      }

      final String? barcodeScanRes = capture.barcodes.first.rawValue;

      if (barcodeScanRes == null || barcodeScanRes.isEmpty) {
        debugPrint("QR value is empty.");
        return;
      }

      setState(() {
        _scanBarcode = barcodeScanRes;
        debugPrint("---------------------");
        debugPrint(_scanBarcode);
        debugPrint("---------------------");
        parseData(_scanBarcode);
      });
    } catch (e, stack) {
      debugPrint("Error scanning QR from gallery: $e");
      debugPrint("$stack");
    }
  }

  Future<void> parseData(String barcodeScanRes) async {
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
                  _storageController.addRouters(routerDetails!);
                } else if (widget.type == "group" && groupDetails != null) {
                  await _storageController.saveGroupDetails(groupDetails!);
                } else {
                  showToast("No details available to save.");
                  return;
                }

                Navigator.popUntil(
                    navigatorKey.currentContext!, (route) => route.isFirst);
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
                scanFromGallery(); // rescan directly
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
