import 'dart:async';

import 'package:bbts_server/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';

import '../../../../controllers/apis.dart';
import '../../../tabs_page.dart';
import '../../controllers/storage.dart';
import '../../models/router_model.dart';
import '../../widgets/group/group_matrix_card.dart';

class GroupSwitchOnOff extends StatefulWidget {
  final String groupName;
  final String selectedRouter;
  final List<RouterDetails> selectedSwitches;

  const GroupSwitchOnOff({
    required this.groupName,
    required this.selectedRouter,
    required this.selectedSwitches,
    super.key,
  });

  @override
  State<GroupSwitchOnOff> createState() => _GroupSwitchOnOffState();
}

class _GroupSwitchOnOffState extends State<GroupSwitchOnOff> {
  final StorageController _storageController = StorageController();
  late bool isSwitchOn = false;
  late Timer _timer;
  final Duration _timerDuration = const Duration(seconds: 30);
  Future<List<RouterDetails>> fetchRouters() async {
    return widget.selectedSwitches;
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
    _loadSwitchState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer(_timerDuration, _navigateToNextPage);
  }

  void _resetTimer() {
    _timer.cancel();
    debugPrint("starts reloading");
    _startTimer();
  }

  Future<void> _loadSwitchState() async {
    bool state = await _storageController.loadGroupSwitchState();
    setState(() {
      isSwitchOn = state;
    });
  }

  Future<void> _saveGroupSwitchState(bool value) async {
    setState(() {
      isSwitchOn = value;
    });
    await _storageController.saveGroupSwitchState(value);
  }

  void _navigateToNextPage() {
    if (mounted) {
      Navigator.pushAndRemoveUntil<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => const TabsPage(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    return GestureDetector(
      onTap: _resetTimer,
      child: Scaffold(
        appBar: AppBar(title: const Text("GROUP SWITCH")),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 7,
                      offset: const Offset(5, 5),
                    ),
                  ],
                  color: Theme.of(context).appColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.groupName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    FutureBuilder<List<RouterDetails>>(
                      future: fetchRouters(),
                      builder: (context, routerSnapshot) {
                        if (routerSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator(
                              color:
                                  Theme.of(context).appColors.buttonBackground);
                        }
                        if (routerSnapshot.hasError) {
                          return const Text("ERROR");
                        }
                        final List<RouterDetails> routers =
                            routerSnapshot.data ?? [];
                        return Switch(
                          onChanged: (value) async {
                            await _saveGroupSwitchState(value);
                            for (var switchDetails in routers) {
                              var totalSwitches =
                                  switchDetails.switchTypes.length;
                              try {
                                for (int i = 1; i <= totalSwitches; i++) {
                                  await ApiConnect.hitApiPost(
                                      "${switchDetails.iPAddress}/getSwitchcmd$i",
                                      {
                                        "Lock_id": switchDetails.switchID,
                                        "lock_passkey":
                                            switchDetails.switchPasskey,
                                        "lock_cmd$i": value ? "ON$i" : "OFF$i",
                                      }).timeout(const Duration(seconds: 5));
                                  debugPrint(value ? "ON" : "OFF");
                                }
                              } catch (e) {
                                // Handle the timeout error if needed
                                debugPrint(
                                    'API call to ${switchDetails.iPAddress} timed out.');
                              }
                            }
                            setState(() {
                              isSwitchOn = value;
                            });
                          },
                          value: isSwitchOn,
                          activeColor: Theme.of(context).appColors.greenButton,
                          activeTrackColor: Theme.of(context).appColors.green,
                          inactiveThumbColor:
                              Theme.of(context).appColors.redButton,
                          inactiveTrackColor: Theme.of(context).appColors.red,
                        );
                      },
                    ),
                  ],
                ),
              ),
              FutureBuilder<List<RouterDetails>>(
                future: fetchRouters(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(
                        color: Theme.of(context).appColors.buttonBackground);
                  }
                  if (snapshot.hasError) {
                    return const Text("ERROR");
                  }
                  return ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.03),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      if (snapshot.data![index].switchTypes.isNotEmpty) {
                        return GroupMatrixCard(
                          switchDetails: snapshot.data![index],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(height: width * 0.03);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
