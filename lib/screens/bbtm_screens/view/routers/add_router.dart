// import 'dart:async';
//
// import 'package:bbts_server/theme/app_colors_extension.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
//
// import '../../../../constants.dart';
// import '../../../../controllers/apis.dart';
// import '../../../../widgets/text_field.dart';
// import '../../../tabs_page.dart';
// import '../../controllers/storage.dart';
// import '../../controllers/wifi.dart';
// import '../../models/router_model.dart';
// import '../../models/switch_model.dart';
// import '../../widgets/custom/custom_button.dart';
// import '../../widgets/custom/toast.dart';
//
// class AddNewRouterPage extends StatefulWidget {
//   final SwitchDetails? switchDetails;
//   final bool isFromSwitch;
//   const AddNewRouterPage(
//       {super.key, required this.isFromSwitch, this.switchDetails});
//
//   @override
//   State<AddNewRouterPage> createState() => _AddNewRouterPageState();
// }
//
// class _AddNewRouterPageState extends State<AddNewRouterPage> {
//   final StorageController _storage = StorageController();
//   late String switchID;
//   late String switchName;
//   String? selectedFan;
//   String? passKey;
//   late List<String> switchList;
//   final TextEditingController _ssid = TextEditingController();
//   final TextEditingController _password = TextEditingController();
//   final formKey = GlobalKey<FormState>();
//
//   final Connectivity _connectivity = Connectivity();
//   StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;
//   late NetworkService _networkService;
//
//   @override
//   void initState() {
//     super.initState();
//     _networkService = NetworkService();
//     _initNetworkInfo();
//     connectivitySubscription = _connectivity.onConnectivityChanged
//         .listen((List<ConnectivityResult> results) {
//       _updateConnectionStatus(results);
//     });
//     if (widget.isFromSwitch) {
//       setState(() {
//         switchID = widget.switchDetails!.switchId;
//         switchName = widget.switchDetails!.switchSSID;
//         passKey = widget.switchDetails!.switchPassKey!;
//         switchList = widget.switchDetails!.switchTypes;
//         selectedFan = widget.switchDetails!.selectedFan;
//       });
//     } else {
//       getSwitchDetails();
//     }
//   }
//
//   getSwitchDetails() async {
//     List<SwitchDetails> switches = await _storage.readSwitches();
//     for (var element in switches) {
//       if (_connectionStatus.contains(element.switchSSID) ||
//           element.switchSSID.contains(_connectionStatus)) {
//         setState(() {
//           passKey = element.switchPassKey!;
//           switchID = element.switchId;
//           switchName = element.switchSSID;
//           switchList = element.switchTypes;
//           selectedFan = element.selectedFan;
//         });
//         break;
//       }
//     }
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
//   bool loading = false;
//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final height = screenSize.height;
//     return Scaffold(
//         appBar: AppBar(title: const Text("Add Router")),
//         body: Center(
//           child: Form(
//             key: formKey,
//             child: Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Column(
//                 children: [
//                   CustomTextField(
//                     controller: _ssid,
//                     validator: (value) {
//                       if (value!.isEmpty) return "SSID cannot be empty";
//                       return null;
//                     },
//                     hintText: "New Router Name",
//                   ),
//                   SizedBox(
//                     height: height * 0.03,
//                   ),
//                   CustomTextField(
//                     controller: _password,
//                     validator: (value) {
//                       if (value!.length <= 7) {
//                         return "Router Password cannot be less than 8 letters";
//                       }
//                       return null;
//                     },
//                     hintText: "New Router Password",
//                   ),
//                   const Spacer(),
//                   loading
//                       ? Padding(
//                           padding: const EdgeInsetsDirectional.fromSTEB(
//                               16, 0, 16, 16),
//                           child: InkWell(
//                             splashColor:
//                                 Theme.of(context).appColors.textSecondary,
//                             // onTap: onPressed,
//                             child: Container(
//                               width: 200,
//                               height: 50,
//                               decoration: BoxDecoration(
//                                 color:
//                                     Theme.of(context).appColors.textSecondary,
//                                 boxShadow: [
//                                   BoxShadow(
//                                     blurRadius: 1,
//                                     color: Theme.of(context)
//                                         .appColors
//                                         .textSecondary,
//                                     offset: const Offset(0, 2),
//                                   )
//                                 ],
//                                 borderRadius: BorderRadius.circular(12),
//                                 border: Border.all(
//                                   color:
//                                       Theme.of(context).appColors.textSecondary,
//                                   width: 1,
//                                 ),
//                               ),
//                               alignment: const AlignmentDirectional(0, 0),
//                               child: CircularProgressIndicator(
//                                 color: Theme.of(context).appColors.primary,
//                               ),
//                             ),
//                           ),
//                         )
//                       : CustomButton(
//                           width: 200,
//                           text: "Submit",
//                           onPressed: () async {
//                             if (formKey.currentState!.validate()) {
//                               try {
//                                 setState(() {
//                                   loading = true;
//                                 });
//                                 if (!widget.isFromSwitch) {
//                                   await getSwitchDetails();
//                                 }
//                                 debugPrint("inside submit $passKey");
//                                 String ssidd = _connectionStatus.substring(
//                                     1, _connectionStatus.length - 1);
//                                 if (passKey == null) {
//                                   showToast(context,
//                                       "No switch found with switch $ssidd");
//                                   setState(() {
//                                     loading = false;
//                                   });
//                                   return;
//                                 }
//                                 String? existedRouter = await _storage
//                                     .getRouterNameIfSwitchIDExists(switchID);
//                                 if (existedRouter == _ssid.text) {
//                                   showToast(context,
//                                       "SwitchId is already Exist with this router");
//                                   setState(() {
//                                     loading = false;
//                                   });
//                                   return;
//                                 }
//                                 if (existedRouter != null) {
//                                   showDialog(
//                                     context: context,
//                                     builder: (cont) {
//                                       return AlertDialog(
//                                         title: const Text('Update Router'),
//                                         content: const Text(
//                                             'SwitchId is already Exist, Do you want to update the existing router'),
//                                         actions: [
//                                           OutlinedButton(
//                                             onPressed: () {
//                                               setState(() {
//                                                 loading = false;
//                                               });
//                                               Navigator.pop(context);
//                                             },
//                                             child: Text(
//                                               'CANCEL',
//                                               style: TextStyle(
//                                                   color: Theme.of(context)
//                                                       .appColors
//                                                       .primary),
//                                             ),
//                                           ),
//                                           OutlinedButton(
//                                             onPressed: () async {
//                                               Navigator.pop(context);
//                                               try {
//                                                 await ApiConnect.hitApiGet(
//                                                     "${Constants.routerIP}/");
//                                                 var res =
//                                                     await ApiConnect.hitApiPost(
//                                                         "${Constants.routerIP}/getWifiParem",
//                                                         {
//                                                       "router_ssid": _ssid.text,
//                                                       "router_password":
//                                                           _password.text,
//                                                       "switch_passkey": passKey,
//                                                     });
//                                                 String ipAddress =
//                                                     res['IPAddress'];
//                                                 if (ipAddress
//                                                     .contains("0.0.0.0")) {
//                                                   showToast(context,
//                                                       "Unable to connect to IP. Try again.");
//                                                   return;
//                                                 }
//                                                 RouterDetails routerDetails =
//                                                     RouterDetails(
//                                                         switchID: switchID,
//                                                         switchName: switchName,
//                                                         routerName: _ssid.text,
//                                                         routerPassword:
//                                                             _password.text,
//                                                         deviceMacId: res['MAC'],
//                                                         switchPasskey: passKey!,
//                                                         iPAddress:
//                                                             res['IPAddress'],
//                                                         switchTypes: switchList,
//                                                         selectedFan:
//                                                             selectedFan);
//                                                 await _storage.updateRouter(
//                                                     routerDetails);
//                                                 Navigator.pushAndRemoveUntil<
//                                                     dynamic>(
//                                                   context,
//                                                   MaterialPageRoute<dynamic>(
//                                                     builder: (BuildContext
//                                                             context) =>
//                                                         const TabsPage(),
//                                                   ),
//                                                   (route) => false,
//                                                 );
//                                               } catch (e) {
//                                                 debugPrint(
//                                                     "Error inside updating");
//                                                 debugPrint("$e");
//                                                 showToast(context, "Error");
//                                               }
//                                             },
//                                             child: Text(
//                                               'OK',
//                                               style: TextStyle(
//                                                   color: Theme.of(context)
//                                                       .appColors
//                                                       .primary),
//                                             ),
//                                           ),
//                                         ],
//                                       );
//                                     },
//                                   );
//                                   return;
//                                 } else {
//                                   showToast(context,
//                                       "You are connected to $_connectionStatus");
//                                   await ApiConnect.hitApiGet(
//                                     "${Constants.routerIP}/",
//                                   );
//                                   var res = await ApiConnect.hitApiPost(
//                                       "${Constants.routerIP}/getWifiParem", {
//                                     "router_ssid": _ssid.text,
//                                     "router_password": _password.text,
//                                     "switch_passkey": passKey,
//                                   });
//                                   String iPAddress = res['IPAddress'];
//                                   if (iPAddress.contains("0.0.0.0")) {
//                                     showToast(context,
//                                         "Unable to connect IP. Try Again., ${iPAddress.contains("0.0.0.0")}");
//                                     setState(() {
//                                       loading = false;
//                                     });
//                                     return;
//                                   }
//                                   setState(() {
//                                     loading = false;
//                                   });
//                                   RouterDetails routerDetails = RouterDetails(
//                                       switchID: switchID,
//                                       switchName: switchName,
//                                       routerName: _ssid.text,
//                                       routerPassword: _password.text,
//                                       switchPasskey: passKey!,
//                                       iPAddress: res['IPAddress'],
//                                       deviceMacId: res['MAC'],
//                                       switchTypes: switchList,
//                                       selectedFan: selectedFan);
//                                   setState(() {
//                                     loading = true;
//                                   });
//                                   _storage.addRouters(routerDetails);
//                                   setState(() {
//                                     loading = false;
//                                   });
//                                   Navigator.pushAndRemoveUntil<dynamic>(
//                                     context,
//                                     MaterialPageRoute<dynamic>(
//                                       builder: (BuildContext context) =>
//                                           const TabsPage(),
//                                     ),
//                                     (route) => false,
//                                   );
//                                 }
//                               } catch (e) {
//                                 debugPrint(e.toString());
//                                 showToast(
//                                     context, "Please connect to correct wifi");
//                                 setState(() {
//                                   loading = false;
//                                 });
//                               }
//                             }
//                           },
//                         )
//                 ],
//               ),
//             ),
//           ),
//         ));
//   }
// }
