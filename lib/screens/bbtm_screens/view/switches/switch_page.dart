import 'package:bbts_server/common/common_services.dart';
import 'package:bbts_server/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';

import '../../controllers/storage.dart';
import '../../models/switch_model.dart';
import '../../widgets/switches/switches_card.dart';
import '../qr/gallery_qr.dart';
import '../qr/qr_view.dart';

class SwitchPage extends StatefulWidget {
  const SwitchPage({super.key});

  @override
  State<SwitchPage> createState() => _SwitchPageState();
}

class _SwitchPageState extends State<SwitchPage> {
  final StorageController _storageController = StorageController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<SwitchDetails> _allSwitches = [];
  List<SwitchDetails> _filteredSwitches = [];
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    fetchSwitches();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent) {
        if (_isFabVisible) {
          setState(() {
            _isFabVisible = false;
          });
        }
      } else {
        if (!_isFabVisible) {
          setState(() {
            _isFabVisible = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchSwitches() async {
    final switches = await _storageController.readSwitches();
    setState(() {
      _allSwitches = switches;
      _filteredSwitches = switches;
    });
  }

  void _filterSwitches(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredSwitches = _allSwitches;
      });
    } else {
      setState(() {
        _filteredSwitches = _allSwitches
            .where((switchDetails) =>
                switchDetails.switchSSID
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                switchDetails.switchId
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Visibility(
        visible: _isFabVisible,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const ScanQr(type: "switch"),
                ));
              },
              heroTag: "QR",
              child: Icon(Icons.camera_alt_outlined,
                  color: Theme.of(context).appColors.background),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              heroTag: "gallery",
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const GalleryQRPage(
                    type: 'switch',
                  ),
                ));
              },
              child: Icon(Icons.image_outlined,
                  color: Theme.of(context).appColors.background),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("SWITCHES"),
      ),
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                  color: Theme.of(context).appColors.primary,
                ),
                height: MediaQuery.of(context).size.height * 0.07,
              ),
              Positioned(
                bottom: -25,
                left: 16,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).appColors.background,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterSwitches,
                    decoration: InputDecoration(
                      hintStyle: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                      hintText: 'Search devices...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Expanded(
            child: _filteredSwitches.isEmpty
                ? CommonServices.noDataWidget()
                : ListView.separated(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.all(screenWidth * 0.06),
                    itemCount: _filteredSwitches.length,
                    itemBuilder: (context, index) {
                      final reversedIndex =
                          _filteredSwitches.length - 1 - index;
                      final switchDetails = _filteredSwitches[reversedIndex];
                      return SwitchCard(switchDetails: switchDetails);
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(height: screenWidth * 0.04);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
