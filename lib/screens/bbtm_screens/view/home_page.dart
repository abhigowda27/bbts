import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:bbts_server/main.dart';
import 'package:bbts_server/screens/bbtm_screens/view/help_page.dart';
import 'package:bbts_server/screens/bbtm_screens/view/home_screen.dart';
import 'package:bbts_server/screens/bbtm_screens/view/routers/router_page.dart';
import 'package:bbts_server/screens/bbtm_screens/view/switches/switch_page.dart';
import 'package:bbts_server/screens/switches/switch_page_cloud.dart';
import 'package:bbts_server/theme/app_colors_extension.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
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
  bool _locationEnabled = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    requestAllPermissions();
    _networkService = NetworkService();
    _initNetworkInfo();
    connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _updateConnectionStatus(results);
    });
    super.initState();
  }

  void _showEnableLocationDialog() {
    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (ctx) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: Theme.of(context).appColors.background,
            content: const Text(
              "Location services are turned off. Please enable GPS to continue.",
            ),
            icon: Image.asset(
              "assets/images/gps.gif",
              height: 100,
              width: 100,
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: const Text("Go To Settings"),
                  onPressed: () async {
                    await AppSettings.openAppSettings(
                        type: AppSettingsType.location);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      // ✅ Check again when user comes back from Settings
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled && !_locationEnabled) {
        setState(() => _locationEnabled = true);
        // Close dialog if still open
        _initNetworkInfo();
        if (Navigator.canPop(navigatorKey.currentContext!)) {
          Navigator.of(navigatorKey.currentContext!).pop();
        }
      } else if (!serviceEnabled && _locationEnabled) {
        setState(() => _locationEnabled = false);
        _showEnableLocationDialog();
      }
    }
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

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    setState(() => _locationEnabled = serviceEnabled);

    if (!serviceEnabled) {
      _showEnableLocationDialog();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
      // appBar: NetworkAppBar(
      //   height: height,
      //   connectionStatus: _connectionStatus,
      // ),
      backgroundColor: Theme.of(context).appColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ImageCarouselWidget(
              connectionStatus: _connectionStatus,
            ),
            GridView.builder(
              padding: const EdgeInsets.all(20.0),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: lists.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.9,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemBuilder: (context, index) {
                final item = lists[index];
                return GestureDetector(
                  onTap: () async {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, _, __) => item.navigateTo,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Theme.of(context).appColors.primary),
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
                              color: Theme.of(context).appColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
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
              AppSettings.openAppSettings(type: AppSettingsType.wifi);
            },
            backgroundColor: Theme.of(context).appColors.buttonBackground,
            child: const Icon(Icons.wifi_find),
          ),
          const SizedBox(height: 15),
          FloatingActionButton(
            heroTag: "location",
            onPressed: () {
              AppSettings.openAppSettings(type: AppSettingsType.location);
            },
            backgroundColor: Theme.of(context).appColors.buttonBackground,
            child: const Icon(Icons.location_on_rounded),
          ),
        ],
      ),
    );
  }
}
