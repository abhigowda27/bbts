// import 'package:flutter/material.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';
//
// import '../../../../controllers/apis.dart';
// import '../../../tabs_page.dart';
// import '../../controllers/storage.dart';
// import '../../models/switch_model.dart';
// import '../../widgets/custom/custom_button.dart';
//
// class FactoryReset extends StatefulWidget {
//   const FactoryReset(
//       {required this.switchDetails, required this.currentSwitch, super.key});
//   final String currentSwitch;
//   final SwitchDetails switchDetails;
//   @override
//   State<FactoryReset> createState() => _FactoryResetState();
// }
//
// class _FactoryResetState extends State<FactoryReset> {
//   final TextEditingController _controller = TextEditingController();
//   final scaffoldKey = GlobalKey<ScaffoldState>();
//   final StorageController _storageController = StorageController();
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('PinCode'),
//         ),
//         body: Padding(
//           padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
//           child: Column(
//             mainAxisSize: MainAxisSize.max,
//             children: [
//               const Text(
//                 'Enter Your Pin',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const Padding(
//                 padding: EdgeInsetsDirectional.fromSTEB(44, 8, 44, 0),
//                 child: Text(
//                   'This code helps keep your account safe and secure.',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsetsDirectional.fromSTEB(0, 32, 0, 0),
//                 child: PinCodeTextField(
//                   autoDisposeControllers: false,
//                   appContext: context,
//                   length: 4,
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   enableActiveFill: false,
//                   autoFocus: true,
//                   enablePinAutofill: false,
//                   errorTextSpace: 0,
//                   showCursor: true,
//                   cursorColor: const Color(0xFF4B39EF),
//                   obscureText: false,
//                   hintCharacter: '-',
//                   controller: _controller,
//                   autovalidateMode: AutovalidateMode.onUserInteraction,
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsetsDirectional.fromSTEB(0, 32, 0, 0),
//                 child: CustomButton(
//                   text: "Confirm",
//                   width: 250,
//                   onPressed: () async {
//                     if (_controller.text == widget.switchDetails.privatePin) {
//                       try {
//                         await ApiConnect.hitApiPost(
//                             "${widget.switchDetails.iPAddress}/Factoryreset", {
//                           "USER_DEVID": widget.switchDetails.switchId,
//                           "USER_PASSKEY": widget.switchDetails.switchPassKey
//                         });
//                         _storageController
//                             .deleteEverythingWithRespectToSwitchID(
//                                 widget.switchDetails);
//                       } catch (e) {
//                         debugPrint(e.toString());
//                       } finally {
//                         Navigator.pushAndRemoveUntil(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => const TabsPage()),
//                           (route) => false,
//                         );
//                       }
//                     } else {
//                       final scaffold = ScaffoldMessenger.of(context);
//                       scaffold.showSnackBar(
//                         const SnackBar(
//                           content: Text("Incorrect Pin"),
//                         ),
//                       );
//                       _controller.text = "";
//                     }
//                   },
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text("You are connected to : ${widget.currentSwitch}"),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
