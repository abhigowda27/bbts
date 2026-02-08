import 'dart:async';

import 'package:bbts_server/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../controllers/apis.dart';
import '../../../tabs_page.dart';
import '../../controllers/storage.dart';
import '../../models/router_model.dart';
import '../../widgets/group/group_fan_switch_card.dart';

class GroupFanSwitchControl extends StatefulWidget {
  final String groupName;
  final String selectedRouter;
  final List<RouterDetails> selectedSwitches;
  const GroupFanSwitchControl({
    required this.groupName,
    required this.selectedRouter,
    required this.selectedSwitches,
    super.key,
  });

  @override
  State<GroupFanSwitchControl> createState() => _GroupFanSwitchControlState();
}

class _GroupFanSwitchControlState extends State<GroupFanSwitchControl> {
  final StorageController _storageController = StorageController();
  late Timer _timer;
  late String selectedControl = "OFF";
  final Duration _timerDuration = const Duration(seconds: 30);
  List<String> controls = [
    "OFF",
    "HIGH",
  ];
  late bool isSwitchOn = false;
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

  void _resetTimer() {
    _startTimer();
    _timer.cancel();
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
        appBar: AppBar(title: const Text("Fan Control")),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.2),
                      blurRadius: 7,
                      offset: const Offset(5, 5),
                    ),
                  ],
                  color: Theme.of(context)
                      .appColors
                      .primary
                      .withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.groupName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).appColors.background),
                    ),
                    Icon(
                      FontAwesomeIcons.fan,
                      size: width * 0.1,
                      color: Theme.of(context).appColors.background,
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
                                  widget.selectedSwitches.length;
                              try {
                                for (int i = 1; i <= totalSwitches; i++) {
                                  final response = await ApiConnect.hitApiPost(
                                    "${switchDetails.iPAddress}/getSwitchcmd",
                                    {
                                      "Lock_id": switchDetails.switchID,
                                      "lock_passkey":
                                          switchDetails.switchPasskey,
                                      "lock_cmd": value ? "HIGH" : "OFF",
                                    },
                                  );
                                  // debugPrint(command);
                                  debugPrint(response);
                                  debugPrint(
                                      "${switchDetails.iPAddress}/getSwitchcmd");
                                }
                              } catch (e) {
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
              ...widget.selectedSwitches
                  .where((switchDetail) => switchDetail.selectedFan!.isNotEmpty)
                  .map((switchDetail) {
                return GroupFanSwitchCard(
                  switchDetails: switchDetail,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
