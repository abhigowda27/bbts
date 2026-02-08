import 'dart:async';

import 'package:bbts_server/main.dart';
import 'package:bbts_server/screens/bbtm_screens/widgets/router/router_list_card.dart';
import 'package:bbts_server/theme/app_colors_extension.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../controllers/apis.dart';
import '../../controllers/wifi.dart';
import '../../models/router_model.dart';
import '../custom/toast.dart';

class GroupMatrixCard extends StatefulWidget {
  final RouterDetails switchDetails;
  const GroupMatrixCard({
    required this.switchDetails,
    super.key,
  });

  @override
  State<GroupMatrixCard> createState() => _GroupMatrixCardState();
}

class _GroupMatrixCardState extends State<GroupMatrixCard> {
  bool switchOff = true;
  Map<String, dynamic> statusRes = {};

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late NetworkService _networkService;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _networkService = NetworkService();
    _initNetworkInfo();
    updateSwitch();
    connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _updateConnectionStatus(results);
    });
  }

  @override
  void dispose() {
    connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> updateSwitch() async {
    Map<String, dynamic> apiRes = await ApiConnect.hitApiGet(
        "${widget.switchDetails.iPAddress}/Switchstatus");
    final Map<String, dynamic> res = Map<String, dynamic>.from(apiRes["data"]);

    int totalSwitches = widget.switchDetails.switchTypes.length;
    setState(() {
      bool anyClosed = false;
      for (int i = 1; i <= totalSwitches; i++) {
        final key = "ON$i";
        if (res.containsKey(key)) {
          if (res[key].toString() == "0") {
            anyClosed = true;
            break;
          }
        }
      }
      statusRes = res;
      switchOff = anyClosed;
    });
  }

  String _connectionStatus = 'Unknown';
  Future<void> _updateConnectionStatus(
          List<ConnectivityResult> results) async =>
      _initNetworkInfo();

  Future<void> _initNetworkInfo() async {
    String? wifiName = await _networkService.initNetworkInfo();
    setState(() => _connectionStatus = wifiName ?? "Unknown");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 5,
            offset: const Offset(5, 5),
          ),
        ],
        color: Theme.of(context).appColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    widget.switchDetails.switchName,
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).appColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    updateSwitch();
                  },
                  icon: Icon(
                    FontAwesomeIcons.arrowsRotate,
                    color: Theme.of(context).appColors.buttonBackground,
                  ),
                ),
                Switch(
                  onChanged: (value) async {
                    if (!_connectionStatus
                            .contains(widget.switchDetails.routerName) &&
                        !widget.switchDetails.routerName
                            .contains(_connectionStatus)) {
                      showToast(
                          "Please Connect WIFI to ${widget.switchDetails.routerName} to proceed");
                      return;
                    }
                    try {
                      final totalSwitches =
                          widget.switchDetails.switchTypes.length;
                      final switchDetails = widget.switchDetails;
                      for (int i = 1; i <= totalSwitches; i++) {
                        await ApiConnect.hitApiPost(
                            "${switchDetails.iPAddress}/getSwitchcmd$i", {
                          "Lock_id": switchDetails.switchID,
                          "lock_passkey": switchDetails.switchPasskey,
                          "lock_cmd$i": value ? "ON$i" : "OFF$i",
                        }).timeout(const Duration(seconds: 5));
                        debugPrint(value ? "ON$i" : "OFF$i");
                      }
                      setState(() {
                        switchOff = !value;
                      });
                      await updateSwitch();
                    } on DioException catch (e) {
                      final scaffold =
                          ScaffoldMessenger.of(navigatorKey.currentContext!);
                      scaffold.showSnackBar(
                        SnackBar(
                          content: Text(
                              "Unable to perform. Try Again. Error: ${e.message}"),
                        ),
                      );
                    } catch (e) {
                      debugPrint(e.toString());
                    }
                  },
                  value: !switchOff,
                  activeThumbColor: Theme.of(context).appColors.greenButton,
                  activeTrackColor: Theme.of(context).appColors.green,
                  inactiveThumbColor: Theme.of(context).appColors.redButton,
                  inactiveTrackColor: Theme.of(context).appColors.red,
                ),
              ],
            ),
          ),
          FutureBuilder<List<String>>(
              future: fetchSwitches(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(
                      color: Theme.of(context).appColors.buttonBackground);
                }
                if (snapshot.hasError) {
                  return const Text("ERROR");
                }
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data?.length ?? 0,
                  itemBuilder: (context, index) {
                    debugPrint(statusRes["ON${index + 1}"]?.toString());
                    return RouterListCard(
                      routerDetails: widget.switchDetails,
                      index: index,
                      switchStatus:
                          statusRes["ON${index + 1}"]?.toString() == "1",
                      wifiName: _connectionStatus,
                    );
                  },
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                );
              }),
        ],
      ),
    );
  }

  Future<List<String>> fetchSwitches() async {
    return widget.switchDetails.switchTypes;
  }
}
