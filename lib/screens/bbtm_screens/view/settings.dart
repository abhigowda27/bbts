// import 'dart:async';
//
// import 'package:bbts_server/screens/bbtm_screens/view/switches/factory_reset.dart';
// import 'package:bbts_server/theme/app_colors_extension.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:open_settings/open_settings.dart';
//
// import '../controllers/storage.dart';
// import '../controllers/wifi.dart';
// import '../models/switch_model.dart';
// import '../widgets/custom/custom_button.dart';
// import '../widgets/custom/toast.dart';
//
// class SettingsPage extends StatefulWidget {
//   const SettingsPage({super.key});
//
//   @override
//   State<SettingsPage> createState() => _SettingsPageState();
// }
//
// class _SettingsPageState extends State<SettingsPage> {
//   final scaffoldKey = GlobalKey<ScaffoldState>();
//   final StorageController _storageController = StorageController();
//   final Connectivity _connectivity = Connectivity();
//   StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;
//   late NetworkService _networkService;
//   @override
//   void initState() {
//     super.initState();
//     _networkService = NetworkService();
//     _initNetworkInfo();
//     connectivitySubscription = _connectivity.onConnectivityChanged
//         .listen((List<ConnectivityResult> results) {
//       _updateConnectionStatus(results);
//     });
//   }
//
//   @override
//   void dispose() {
//     connectivitySubscription?.cancel();
//     super.dispose();
//   }
//
//   String _connectionStatus = 'Unknown';
//   Future<void> _updateConnectionStatus(
//           List<ConnectivityResult> results) async =>
//       _initNetworkInfo();
//
//   Future<void> _initNetworkInfo() async {
//     String? wifiName = await _networkService.initNetworkInfo();
//     setState(() => _connectionStatus = wifiName ?? "Unknown");
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("SETTINGS"),
//       ),
//       body: SafeArea(
//         top: true,
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.max,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(
//                 height: 20,
//               ),
//               const Align(
//                 alignment: AlignmentDirectional(0, 0),
//                 child: Text(
//                   'WIFI is connected to Wifi Name',
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//                 ),
//               ),
//               Align(
//                 alignment: const AlignmentDirectional(0, 0),
//                 child: Text(
//                   _connectionStatus,
//                   style: TextStyle(
//                       color: Theme.of(context).appColors.primary,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 30),
//                 ),
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               CustomButton(
//                 text: "Open WIFI Settings",
//                 icon: Icons.wifi_find,
//                 onPressed: () {
//                   OpenSettings.openWIFISetting();
//                 },
//               ),
//               CustomButton(
//                 text: "Factory Reset",
//                 icon: Icons.lock_reset_rounded,
//                 bgmColor: Theme.of(context).appColors.redButton,
//                 onPressed: () async {
//                   List<SwitchDetails> switches =
//                       await _storageController.readSwitches();
//                   String localConnectStatus = _connectionStatus;
//                   for (var element in switches) {
//                     if (localConnectStatus == (element.switchSSID)) {
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => FactoryReset(
//                                     currentSwitch: _connectionStatus,
//                                     switchDetails: element,
//                                   )));
//                       return;
//                     }
//                   }
//                   showToast(context, "You may not be connected to AP Mode.");
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//       // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       // floatingActionButton: Stack(
//       //   children: [
//       //     Align(
//       //       alignment: Alignment.bottomRight,
//       //       child: Column(
//       //         mainAxisSize: MainAxisSize.min,
//       //         children: [
//       //           FloatingActionButton(
//       //             onPressed: () {
//       //               OpenSettings.openWIFISetting();
//       //             },
//       //             child: const Icon(Icons.wifi_find),
//       //             backgroundColor: backGroundColour,
//       //           ),
//       //           const SizedBox(height: 5), // Adjust spacing between buttons
//       //           FloatingActionButton(
//       //             onPressed: () {
//       //               OpenSettings.openLocationSourceSetting();
//       //             },
//       //             backgroundColor: backGroundColour,
//       //             child: const Icon(Icons.location_on_rounded),
//       //           ),
//       //         ],
//       //       ),
//       //     ),
//       //   ],
//       // ),
//     );
//   }
// }
