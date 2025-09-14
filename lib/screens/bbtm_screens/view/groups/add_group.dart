// import 'package:bbts_server/screens/bbtm_screens/controllers/storage.dart';
// import 'package:bbts_server/screens/bbtm_screens/models/group_model.dart';
// import 'package:bbts_server/screens/bbtm_screens/models/router_model.dart';
// import 'package:bbts_server/screens/bbtm_screens/widgets/custom/custom_button.dart';
// import 'package:bbts_server/screens/bbtm_screens/widgets/custom/toast.dart';
// import 'package:bbts_server/screens/tabs_page.dart';
// import 'package:bbts_server/theme/app_colors_extension.dart';
// import 'package:bbts_server/widgets/text_field.dart';
// import 'package:flutter/material.dart';
//
// class NewGroupInstallationPage extends StatefulWidget {
//   const NewGroupInstallationPage({super.key});
//
//   @override
//   State<NewGroupInstallationPage> createState() =>
//       _NewGroupInstallationPageState();
// }
//
// class _NewGroupInstallationPageState extends State<NewGroupInstallationPage> {
//   final StorageController _storage = StorageController();
//   final TextEditingController _groupName = TextEditingController();
//   bool loading = false;
//   List<RouterDetails> selectedSwitches = [];
//   List<RouterDetails> availableSwitches = [];
//   String? selectedRouter;
//   List<RouterDetails> availableRouters = [];
//
//   @override
//   void initState() {
//     super.initState();
//     fetchAvailableRouters();
//   }
//
//   void fetchAvailableSwitches(String routerName) async {
//     try {
//       List<RouterDetails> allSwitches = await _storage.readRouters();
//       List<RouterDetails> filteredSwitches = allSwitches
//           .where((switchItem) => (switchItem.routerName.contains(routerName) ||
//               routerName.contains(switchItem.routerName)))
//           .toList();
//
//       setState(() {
//         availableSwitches = filteredSwitches;
//       });
//     } catch (e) {
//       showToast(context, "Error fetching switches");
//     }
//   }
//
//   void fetchAvailableRouters() async {
//     try {
//       List<RouterDetails> routers = await _storage.readRouters();
//       Set<String> seenNames = {};
//       List<RouterDetails> uniqueRouters = [];
//
//       for (var router in routers) {
//         if (!seenNames.contains(router.routerName)) {
//           seenNames.add(router.routerName);
//           uniqueRouters.add(router);
//         }
//       }
//       setState(() {
//         availableRouters = uniqueRouters;
//       });
//     } catch (e) {
//       showToast(context, "Error fetching routers");
//     }
//   }
//
//   void handleRouterChange(String? selectedRouter) {
//     setState(() {
//       this.selectedRouter = selectedRouter;
//       if (selectedRouter != null) {
//         fetchAvailableSwitches(selectedRouter);
//       } else {
//         availableSwitches = [];
//         selectedSwitches = [];
//       }
//     });
//   }
//
//   Future<void> handleSubmit() async {
//     if (_groupName.text.isEmpty) {
//       showToast(context, "Group name cannot be empty.");
//       return;
//     }
//     String groupName = _groupName.text;
//     bool groupExists = await _storage.groupExists(groupName);
//     if (groupExists) {
//       showToast(context, "Group name already exists.");
//       return;
//     }
//     try {
//       setState(() {
//         loading = true;
//       });
//
//       // Fetch the selected router's details
//       RouterDetails? selectedRouterDetails = availableRouters
//           .firstWhere((router) => router.routerName == selectedRouter);
//
//       GroupDetails groupDetails = GroupDetails(
//         groupName: groupName,
//         selectedRouter: selectedRouterDetails.routerName,
//         routerPassword: selectedRouterDetails.routerPassword,
//         selectedSwitches: selectedSwitches,
//       );
//
//       await _storage.saveGroupDetails(groupDetails);
//
//       setState(() {
//         loading = false;
//       });
//
//       Navigator.pushAndRemoveUntil<dynamic>(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const TabsPage(),
//         ),
//         (route) => false,
//       );
//     } catch (e) {
//       showToast(context, "Unable to connect. Try Again.");
//       setState(() {
//         loading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final width = screenSize.width;
//     final height = screenSize.height;
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Add Group"),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             children: [
//               CustomTextField(
//                 controller: _groupName,
//                 hintText: "New Group Name",
//               ),
//               SizedBox(height: height * 0.03),
//               DropdownButtonFormField<String>(
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   hintText: "Select Router",
//                   contentPadding: const EdgeInsets.all(10),
//                   labelStyle: TextStyle(fontSize: width * 0.035),
//                 ),
//                 value: selectedRouter,
//                 onChanged: handleRouterChange,
//                 items: availableRouters
//                     .map((routerItem) => DropdownMenuItem(
//                           value: routerItem.routerName,
//                           child: Text(routerItem.routerName),
//                         ))
//                     .toList(),
//               ),
//               SizedBox(height: height * 0.01),
//               Text("Selected Router:",
//                   style: TextStyle(
//                       fontSize: width * 0.04, fontWeight: FontWeight.bold)),
//               if (selectedRouter != null)
//                 ListTile(
//                   title: Text(selectedRouter!),
//                   trailing: IconButton(
//                     icon: Icon(Icons.delete_outline_outlined,
//                         color: Theme.of(context).appColors.textSecondary),
//                     onPressed: () {
//                       setState(() {
//                         selectedRouter = null;
//                         availableSwitches = [];
//                         selectedSwitches = [];
//                       });
//                     },
//                   ),
//                 ),
//               SizedBox(height: height * 0.03),
//               DropdownButtonFormField<RouterDetails>(
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   contentPadding: const EdgeInsets.all(10),
//                   hintText: "Select Switches",
//                   labelStyle: TextStyle(fontSize: width * 0.035),
//                 ),
//                 padding: EdgeInsets.zero,
//                 value: null,
//                 onChanged: (selectedSwitch) {
//                   setState(() {
//                     if (selectedSwitch != null &&
//                         !selectedSwitches.contains(selectedSwitch)) {
//                       selectedSwitches.add(selectedSwitch);
//                     }
//                   });
//                 },
//                 items: availableSwitches
//                     .map((switchItem) => DropdownMenuItem(
//                           value: switchItem,
//                           child: Text(
//                               "${switchItem.routerName}_${switchItem.switchName}"),
//                         ))
//                     .toList(),
//               ),
//               SizedBox(height: height * 0.01),
//               Text("Selected Switches:",
//                   style: TextStyle(
//                       fontSize: width * 0.04, fontWeight: FontWeight.bold)),
//               SizedBox(
//                 height: 200,
//                 child: ListView.builder(
//                   itemCount: selectedSwitches.length,
//                   itemBuilder: (context, index) {
//                     return ListTile(
//                       title: Text(selectedSwitches[index].switchName),
//                       trailing: IconButton(
//                         icon: Icon(Icons.delete_outline,
//                             color: Theme.of(context).appColors.textSecondary),
//                         onPressed: () {
//                           setState(() {
//                             selectedSwitches.removeAt(index);
//                           });
//                         },
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: BottomAppBar(
//         color: Theme.of(context).appColors.background,
//         child: loading
//             ? CircularProgressIndicator(
//                 color: Theme.of(context).appColors.buttonBackground)
//             : CustomButton(
//                 text: "Submit",
//                 onPressed: handleSubmit,
//               ),
//       ),
//     );
//   }
// }
