import 'dart:async';

import 'package:bbts_server/screens/bbtm_screens/view/help_page.dart';
import 'package:bbts_server/screens/bbtm_screens/view/routers/router_page.dart';
import 'package:bbts_server/screens/bbtm_screens/view/switches/switch_page.dart';
import 'package:bbts_server/screens/switches/switch_page_cloud.dart';
import 'package:bbts_server/theme/app_colors_extension.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:open_settings/open_settings.dart';
import 'package:permission_handler/permission_handler.dart';

import '../controllers/wifi.dart';
import 'groups/group_page.dart';

class GridItem {
  final String name;
  final String icon;
  final Color? color;
  final Widget navigateTo;

  GridItem(
      {required this.name,
      required this.icon,
      required this.navigateTo,
      this.color});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<GridItem> lists = [
    GridItem(
        name: 'Switches',
        icon: "assets/images/switch.png",
        navigateTo: const SwitchPage(),
        color: Colors.redAccent),
    GridItem(
        name: 'Routers',
        icon: "assets/images/wifi-router.png",
        navigateTo: const RouterPage(),
        color: Colors.deepPurple),
    GridItem(
        name: 'Groups',
        icon: "assets/images/group_icon.png",
        navigateTo: const GroupingPage(),
        color: Colors.green),
    GridItem(
      name: 'Cloud',
      icon: "assets/images/cloud-connect.png",
      navigateTo: const SwitchCloudPage(),
    ),
    GridItem(
        name: 'Help',
        icon: "assets/images/question-bubble.png",
        navigateTo: const HelpPage(),
        color: Colors.deepOrange),
  ];

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;
  late NetworkService _networkService;

  @override
  void initState() {
    requestAllPermissions();
    _networkService = NetworkService();
    _initNetworkInfo();
    connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _updateConnectionStatus(results);
    });
    super.initState();
  }

  Future<void> requestAllPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.contacts,
      Permission.location,
    ].request();

    statuses.forEach((permission, status) {
      debugPrint("Permission: $permission, Status: $status");
    });
  }

  @override
  void dispose() {
    connectivitySubscription?.cancel();
    super.dispose();
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
    final screenSize = MediaQuery.of(context).size;
    final height = screenSize.height;
    final width = screenSize.width;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'BelBird Technologies',
              style: TextStyle(
                color: Colors.red,
                fontSize: width * 0.06,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              'BBT Switch Matrix',
              style: TextStyle(
                color: Theme.of(context).appColors.textPrimary,
                fontSize: width * 0.04,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Image.asset(
              "assets/images/BBT_Logo_2.png",
              width: height * 0.1,
              height: height * 0.1,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              'WIFI is connected to Wifi Name:',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: width * 0.05),
            ),
            Text(
              _connectionStatus.toString(),
              style: TextStyle(
                  color: Theme.of(context).appColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: width * 0.06),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: lists.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemBuilder: (context, index) {
                  final item = lists[index];
                  return GestureDetector(
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => item.navigateTo,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).appColors.background,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .appColors
                                .textPrimary
                                .withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(item.icon,
                              height: height * .045, color: item.color),
                          const SizedBox(height: 10),
                          Text(
                            item.name,
                            style: TextStyle(
                                fontSize: width * 0.035,
                                fontWeight: FontWeight.w700,
                                color:
                                    Theme.of(context).appColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "wifi",
            onPressed: () {
              OpenSettings.openWIFISetting();
            },
            backgroundColor: Theme.of(context).appColors.buttonBackground,
            child: const Icon(Icons.wifi_find),
          ),
          const SizedBox(height: 15),
          FloatingActionButton(
            heroTag: "location",
            onPressed: () {
              OpenSettings.openLocationSourceSetting();
            },
            backgroundColor: Theme.of(context).appColors.buttonBackground,
            child: const Icon(Icons.location_on_rounded),
          ),
        ],
      ),
    );
  }
}
