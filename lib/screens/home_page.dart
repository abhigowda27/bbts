//
// import 'package:flutter/material.dart';
// import 'package:bbt_multi_switch/screens/switches/switch_page_cloud.dart';
// import 'package:open_settings/open_settings.dart';
//
// import '../../constants.dart';
//
// class GridItem {
//   final String name;
//   final String icon;
//   final Color? color;
//   final Widget navigateTo;
//
//   GridItem(
//       {required this.name,
//       required this.icon,
//       required this.navigateTo,
//       required this.color});
// }
//
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   final List<GridItem> lists = [
//     GridItem(
//         name: 'Switches',
//         icon: "assets/images/switch.png",
//         navigateTo: const SwitchPage(),
//         color: Colors.redAccent),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final height = screenSize.height;
//     final width = screenSize.width;
//
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(70),
//         child: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 Theme.of(context).appColors.buttonBackground,
//                 Theme.of(context).appColors.textSecondary,
//                 Theme.of(context).appColors.primary
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//           child: AppBar(
//             title: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   'BelBird Technologies',
//                   style: TextStyle(
//                     color: Colors.red,
//                     fontSize: width * 0.06,
//                     fontWeight: FontWeight.w600,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 Text(
//                   'BBT Switch',
//                   style: TextStyle(
//                     color: Theme.of(context).appColors.textPrimary,
//                     fontSize: width * 0.04,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//             actions: [
//               Padding(
//                 padding: const EdgeInsets.only(right: 16),
//                 child: Image.asset(
//                   "assets/images/BBT_Logo_2.png",
//                   width: height * 0.1,
//                   height: height * 0.1,
//                 ),
//               ),
//             ],
//             backgroundColor: Colors.transparent,
//           ),
//         ),
//       ),
//       body: Stack(
//         children: [
//           // Background design or image
//           Container(
//             width: double.infinity,
//             height: double.infinity,
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Theme.of(context).appColors.buttonBackground,
//                   Theme.of(context).appColors.textSecondary,
//                   Theme.of(context).appColors.primary
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),
//           Positioned(
//             top: 50,
//             left: 0,
//             child: Opacity(
//               opacity: 0.2,
//               child: Image.asset(
//                 "assets/images/BBT_Logo_2.png",
//                 height: height * 0.4,
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 50,
//             right: 0,
//             child: Opacity(
//               opacity: 0.2,
//               child: Image.asset(
//                 "assets/images/BBT_Logo_2.png",
//                 height: height * 0.4,
//               ),
//             ),
//           ),
//
//           // Main content
//           SingleChildScrollView(
//             child: Column(
//               children: [
//                 // Align(
//                 //   alignment: const AlignmentDirectional(0, 0),
//                 //   child: Text(
//                 //     'WIFI is connected to Wifi Name:',
//                 //     style: TextStyle(
//                 //         fontWeight: FontWeight.bold, fontSize: width * 0.05),
//                 //   ),
//                 // ),
//                 // Align(
//                 //   alignment: const AlignmentDirectional(0, 0),
//                 //   child: Text(
//                 //     _connectionStatus.toString(),
//                 //     style: TextStyle(
//                 //         color: Colors.white,
//                 //         fontWeight: FontWeight.bold,
//                 //         fontSize: width * 0.06),
//                 //   ),
//                 // ),
//                 Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: GridView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     itemCount: lists.length,
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 3,
//                       childAspectRatio: 1,
//                       crossAxisSpacing: 20,
//                       mainAxisSpacing: 20,
//                     ),
//                     itemBuilder: (context, index) {
//                       final item = lists[index];
//                       return GestureDetector(
//                         onTap: () async {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => item.navigateTo,
//                             ),
//                           );
//                         },
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(1),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.grey.withOpacity(1),
//                                 blurRadius: 5,
//                                 offset: const Offset(2, 2),
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Image.asset(item.icon,
//                                   height: height * .045, color: item.color),
//                               const SizedBox(height: 10),
//                               Text(
//                                 item.name,
//                                 style: TextStyle(
//                                   fontSize: width * 0.035,
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.black,
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//       floatingActionButton: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           FloatingActionButton(
//             heroTag: "wifiButton",
//             onPressed: () {
//               OpenSettings.openWIFISetting();
//             },
//             backgroundColor: Theme.of(context).appColors.primary,
//             child: const Icon(
//               Icons.wifi_find,
//               color: Colors.white,
//             ),
//           ),
//           const SizedBox(height: 15),
//           FloatingActionButton(
//             heroTag: "locationButton",
//             onPressed: () {
//               OpenSettings.openLocationSourceSetting();
//             },
//             backgroundColor: Theme.of(context).appColors.primary,
//             child: const Icon(
//               Icons.location_pin,
//               color: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
