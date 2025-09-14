// import 'package:flutter/material.dart';
// import 'package:bbt_multi_switch/controllers/storage.dart';
// import 'package:bbt_multi_switch/models/switch_model.dart';
// import 'package:bbt_multi_switch/screens/switches/toggle_switch_page.dart';
//
// import '../../constants.dart';
//
// import 'add_switch.dart';
//
// class SwitchPage extends StatefulWidget {
//   const SwitchPage({super.key});
//
//   @override
//   State<SwitchPage> createState() => _SwitchPageState();
// }
//
// class _SwitchPageState extends State<SwitchPage> {
//   final StorageController _storageController = StorageController();
//
//   Future<List<SwitchDetails>> fetchSwitches() async {
//     return _storageController.readSwitches();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//       // floatingActionButton: FloatingActionButton(
//       //   heroTag: "add",
//       //   onPressed: () {
//       //     Navigator.of(context).push(MaterialPageRoute(
//       //       builder: (context) => const NewInstallationPage(),
//       //     ));
//       //   },
//       //   backgroundColor: Constants.appBarColour,
//       //   child: const Icon(
//       //     Icons.add_circle_outline_sharp,
//       //     color: Colors.white,
//       //   ),
//       // ),
//       appBar: AppBar(
//         title: const Text("Device List"),
//         actions: [
//           IconButton(
//             onPressed: () {
//               Navigator.of(context).push(MaterialPageRoute(
//                 builder: (context) => const NewInstallationPage(),
//               ));
//             },
//             icon: const Icon(
//               Icons.add_circle_outline_sharp,
//               color: Colors.white,
//             ),
//           )
//         ],
//       ),
//       body: SingleChildScrollView(
//         physics: const BouncingScrollPhysics(),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             FutureBuilder(
//               future: fetchSwitches(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const CircularProgressIndicator(
//                       color: Theme.of(context).appColors.buttonBackground);
//                 }
//
//                 return ListView.separated(
//                   padding: const EdgeInsets.all(15),
//                   physics: const NeverScrollableScrollPhysics(),
//                   shrinkWrap: true,
//                   itemCount: snapshot.data!.length,
//                   itemBuilder: (context, index) {
//                     return GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => SwitchOnOff(
//                               switchName: snapshot.data![index].switchName,
//                               switchID: snapshot.data![index].switchId,
//                             ),
//                           ),
//                         );
//                       },
//                       child:
//                           SwitchesCard(switchesDetails: snapshot.data![index]),
//                     );
//                   },
//                   separatorBuilder: (BuildContext context, int index) {
//                     return const SizedBox(
//                       height: 15,
//                     );
//                   },
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:bbts_server/blocs/switch/switch_bloc.dart';
import 'package:bbts_server/blocs/switch/switch_event.dart';
import 'package:bbts_server/common/api_status.dart';
import 'package:bbts_server/common/common_services.dart';
import 'package:bbts_server/common/common_state.dart';
import 'package:bbts_server/screens/switches/widgets/switch_lists.dart';
import 'package:bbts_server/widgets/shimmer_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SwitchCloudPage extends StatefulWidget {
  const SwitchCloudPage({super.key});

  @override
  State<SwitchCloudPage> createState() => _SwitchCloudPageState();
}

class _SwitchCloudPageState extends State<SwitchCloudPage> {
  final SwitchBloc _switchBloc = SwitchBloc();
  List<dynamic> _deviceList = [];

  @override
  void initState() {
    fetchSwitches();
    super.initState();
  }

  void fetchSwitches() {
    _switchBloc.add(GetSwitchListEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Device List"),
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       Navigator.of(context).push(MaterialPageRoute(
        //         builder: (context) => const AddSwitchTab(),
        //       ));
        //     },
        //     icon: const Icon(
        //       Icons.add_circle_outline_sharp,
        //       color: Colors.white,
        //       size: 30,
        //     ),
        //   )
        // ],
      ),
      body: SingleChildScrollView(
        child: BlocConsumer<SwitchBloc, CommonState>(
          bloc: _switchBloc,
          listener: (context, state) {
            ApiStatus apiResponse = state.apiStatus;
            if (apiResponse is ApiResponse) {
              final responseData = apiResponse.response;
              debugPrint("Response data====>$responseData");
              if (responseData != null) {
                final deviceList = responseData['data'] ?? [];
                _deviceList = deviceList;
              } else {
                debugPrint("Unexpected response format: $responseData");
              }
            }
          },
          builder: (context, state) {
            ApiStatus apiResponse = state.apiStatus;
            if (apiResponse is ApiResponse) {
              return _deviceList.isNotEmpty
                  ? deviceListWidget()
                  : CommonServices.noDataWidget();
            } else if (apiResponse is ApiLoadingState ||
                apiResponse is ApiInitialState) {
              return _deviceList.isEmpty
                  ? const SwitchLoader()
                  : deviceListWidget();
            } else if (apiResponse is ApiFailureState) {
              return Center(child: CommonServices.failureWidget(() {
                fetchSwitches();
              }));
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }

  Widget deviceListWidget() {
    if (_deviceList.isEmpty) {
      return Center(child: Image.asset("assets/images/no_switch.png"));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(15),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _deviceList.length,
      itemBuilder: (context, index) {
        return SwitchesCard(
          switchesDetails: _deviceList[index],
          onChanged: fetchSwitches,
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(
          height: 15,
        );
      },
    );
  }
}
