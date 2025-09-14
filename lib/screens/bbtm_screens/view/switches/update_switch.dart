// import 'package:bbts_server/theme/app_colors_extension.dart';
// import 'package:bbts_server/widgets/mandatory_text.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
//
// import '../../../../constants.dart';
// import '../../../../controllers/apis.dart';
// import '../../../../widgets/text_field.dart';
// import '../../../tabs_page.dart';
// import '../../controllers/storage.dart';
// import '../../models/switch_model.dart';
// import '../../widgets/custom/custom_button.dart';
// import '../../widgets/custom/toast.dart';
//
// class UpdatePage extends StatefulWidget {
//   const UpdatePage({required this.switchDetails, super.key});
//
//   final SwitchDetails switchDetails;
//
//   @override
//   State<UpdatePage> createState() => _UpdateSwitchPageState();
// }
//
// class _UpdateSwitchPageState extends State<UpdatePage> {
//   @override
//   void initState() {
//     super.initState();
//     _password.text = widget.switchDetails.switchPassword;
//     _password1.text = widget.switchDetails.switchPassword;
//     _ssid.text = widget.switchDetails.switchSSID;
//     _passKey.text = widget.switchDetails.switchPassKey;
//     _privatePin.text = widget.switchDetails.privatePin;
//     // Initialize controllers for switch types
//     _switchTypeControllers = widget.switchDetails.switchTypes
//         .map((type) => TextEditingController(text: type))
//         .toList();
//
//     // Selected fan
//     if (widget.switchDetails.selectedFan?.isNotEmpty ?? false) {
//       _fanRequired = true;
//       _selectedFanController.text = widget.switchDetails.selectedFan!;
//     } else {
//       _fanRequired = false;
//     }
//   }
//
//   bool _showPassword = false;
//   bool _showConfirmPassword = false;
//
//   // final TextEditingController _switchId = TextEditingController();
//   bool _fanRequired = true;
//   final TextEditingController _ssid = TextEditingController();
//   final TextEditingController _passKey = TextEditingController();
//   final TextEditingController _password = TextEditingController();
//   final TextEditingController _password1 = TextEditingController();
//   final TextEditingController _privatePin = TextEditingController();
//   List<TextEditingController> _switchTypeControllers = [];
//   final TextEditingController _selectedFanController = TextEditingController();
//
//   final StorageController _storageController = StorageController();
//   final formKey = GlobalKey<FormState>();
//   bool loading = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("AP Update")),
//       body: SingleChildScrollView(
//         child: Form(
//           key: formKey,
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 richTxt(
//                   text: "Switch Name",
//                 ),
//                 CustomTextField(
//                   controller: _ssid,
//                   validator: (value) {
//                     if (value!.isEmpty) return "SSID cannot be empty";
//                     return null;
//                   },
//                   hintText: "New Switch Name",
//                 ),
//                 richTxt(
//                   text: "Switch Password",
//                 ),
//                 CustomTextField(
//                   obscureText: !_showPassword,
//                   controller: _password,
//                   validator: (value) {
//                     if (value!.length <= 7) {
//                       return "Switch Password cannot be less than 8 letters";
//                     }
//                     return null;
//                   },
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _showPassword
//                           ? Icons.visibility_off_outlined
//                           : Icons.visibility_outlined,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _showPassword = !_showPassword;
//                       });
//                     },
//                   ),
//                   hintText: "New Password",
//                 ),
//                 richTxt(
//                   text: "Confirm Password",
//                 ),
//                 CustomTextField(
//                   obscureText: !_showConfirmPassword,
//                   controller: _password1,
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _showConfirmPassword
//                           ? Icons.visibility_off_outlined
//                           : Icons.visibility_outlined,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _showConfirmPassword = !_showConfirmPassword;
//                       });
//                     },
//                   ),
//                   validator: (value) {
//                     if (value!.length <= 7) {
//                       return "Switch Password cannot be less than 8 letters";
//                     }
//                     if (_password.text != _password1.text) {
//                       return "Passwords do not match";
//                     }
//                     return null;
//                   },
//                   hintText: "New Password",
//                 ),
//                 richTxt(
//                   text: "PIN",
//                 ),
//                 CustomTextField(
//                   maxLength: 4,
//                   controller: _privatePin,
//                   validator: (value) {
//                     if (value!.length <= 3) {
//                       return "Switch Pin cannot be less than 4 letters";
//                     }
//                     return null;
//                   },
//                   hintText: "New Pin",
//                 ),
//                 richTxt(
//                   text: "Switch PassKey",
//                 ),
//                 CustomTextField(
//                   validator: (value) {
//                     if (value!.isEmpty) {
//                       return "PassKey Cannot be empty";
//                     }
//                     if (value.length <= 7) {
//                       return "PassKey Cannot be less than 8 letters";
//                     }
//                     final validCharacters = RegExp(r'^[a-zA-Z0-9]+$');
//                     if (validCharacters.hasMatch(value)) {
//                       return "Passkey should be alphanumeric";
//                     }
//                     return null;
//                   },
//                   controller: _passKey,
//                   hintText: "New Passkey",
//                 ),
//                 Row(
//                   children: [
//                     Checkbox(
//                       value: _fanRequired,
//                       onChanged: (val) {
//                         setState(() {
//                           _fanRequired = val ?? true;
//                           if (!_fanRequired) {
//                             _selectedFanController.clear();
//                           }
//                           if (_fanRequired &&
//                               _switchTypeControllers.length > 4) {
//                             _switchTypeControllers.removeLast();
//                           }
//                         });
//                       },
//                     ),
//                     const Text("Fan Required"),
//                   ],
//                 ),
//                 if (_fanRequired) ...[
//                   richTxt(
//                     text: "Fan",
//                   ),
//                   CustomTextField(
//                     controller: _selectedFanController,
//                     validator: (value) {
//                       if (value!.isEmpty) return "Selected fan cannot be empty";
//                       return null;
//                     },
//                     hintText: "Selected Fan",
//                   ),
//                 ],
//                 richTxt(
//                   text: "Switch Types",
//                 ),
//                 const SizedBox(height: 8),
//                 Column(
//                   children: List.generate(
//                     // ✅ limit length based on fan requirement
//                     _switchTypeControllers.length.clamp(
//                       0,
//                       _fanRequired ? 4 : 5,
//                     ),
//                     (index) {
//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 8.0),
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: CustomTextField(
//                                 controller: _switchTypeControllers[index],
//                                 validator: (value) {
//                                   if (value!.isEmpty) {
//                                     return "Switch type cannot be empty";
//                                   }
//                                   return null;
//                                 },
//                                 hintText: "Switch Type ${index + 1}",
//                               ),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.delete_outline_rounded,
//                                   color: Colors.red),
//                               onPressed: () {
//                                 setState(() {
//                                   _switchTypeControllers.removeAt(index);
//                                 });
//                               },
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 if (_switchTypeControllers.length < (_fanRequired ? 4 : 5))
//                   Align(
//                     alignment: Alignment.centerLeft,
//                     child: TextButton.icon(
//                       icon: const Icon(Icons.add),
//                       label: const Text("Add Switch Type"),
//                       onPressed: () {
//                         setState(() {
//                           _switchTypeControllers.add(TextEditingController());
//                         });
//                       },
//                     ),
//                   ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//       bottomNavigationBar: BottomAppBar(
//         color: Theme.of(context).appColors.background,
//         child: loading
//             ? Align(
//                 // alignment: AlignmentDirectional(1, 0),
//                 child: Padding(
//                   padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
//                   child: InkWell(
//                     splashColor: Theme.of(context).appColors.textSecondary,
//                     // onTap: onPressed,
//                     child: Container(
//                       width: 300,
//                       height: 50,
//                       decoration: BoxDecoration(
//                         color: Theme.of(context).appColors.textSecondary,
//                         boxShadow: [
//                           BoxShadow(
//                             blurRadius: 1,
//                             color: Theme.of(context).appColors.textSecondary,
//                             offset: const Offset(0, 2),
//                           )
//                         ],
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(
//                           color: Theme.of(context).appColors.textSecondary,
//                           width: 1,
//                         ),
//                       ),
//                       alignment: const AlignmentDirectional(0, 0),
//                       child: CircularProgressIndicator(
//                           color: Theme.of(context).appColors.buttonBackground),
//                     ),
//                   ),
//                 ),
//               )
//             : CustomButton(
//                 width: 200,
//                 text: "Submit",
//                 onPressed: () async {
//                   if (formKey.currentState!.validate()) {
//                     SwitchDetails switchDetails1 = SwitchDetails(
//                       privatePin: _privatePin.text,
//                       switchId: widget.switchDetails.switchId,
//                       switchSSID: _ssid.text,
//                       switchPassKey: _passKey.text,
//                       switchPassword: _password.text,
//                       iPAddress: widget.switchDetails.iPAddress,
//                       switchTypes:
//                           _switchTypeControllers.map((c) => c.text).toList(),
//                       selectedFan: _selectedFanController.text,
//                     );
//
//                     try {
//                       setState(() {
//                         loading = true;
//                       });
//                       await ApiConnect.hitApiGet(
//                         "${Constants.routerIP}/",
//                       );
//                       var data = {
//                         "Lock_id": widget.switchDetails.switchId,
//                         "lock_name": _ssid.text,
//                         "lock_pass": _password.text
//                       };
//                       debugPrint("$data");
//                       await ApiConnect.hitApiPost(
//                           "${Constants.routerIP}/settings", data);
//
//                       await ApiConnect.hitApiPost(
//                           "${Constants.routerIP}/getSecretKey", {
//                         "Lock_id": switchDetails1.switchId,
//                         "lock_passkey": _passKey.text
//                       });
//                       _storageController.updateSwitch(
//                           switchDetails1.switchId, switchDetails1);
//                       Navigator.pushAndRemoveUntil<dynamic>(
//                         context,
//                         MaterialPageRoute<dynamic>(
//                           builder: (BuildContext context) => const TabsPage(),
//                         ),
//                         (route) => false,
//                       );
//                     } on DioException {
//                       await ApiConnect.hitApiGet(
//                         "${Constants.routerIP}/",
//                       );
//                       await ApiConnect.hitApiPost(
//                           "${Constants.routerIP}/getSecretKey", {
//                         "Lock_id": switchDetails1.switchId,
//                         "lock_passkey": _passKey.text
//                       });
//                       _storageController.updateSwitch(
//                           switchDetails1.switchId, switchDetails1);
//                       Navigator.pushAndRemoveUntil<dynamic>(
//                         context,
//                         MaterialPageRoute<dynamic>(
//                           builder: (BuildContext context) => const TabsPage(),
//                         ),
//                         (route) => false,
//                       );
//                     } catch (e) {
//                       debugPrint(e.toString());
//                       showToast(context, "Failed to Update. Try again");
//                       setState(() {
//                         loading = false;
//                       });
//                     }
//                   }
//                 },
//               ),
//       ),
//     );
//   }
// }
