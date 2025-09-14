import 'package:bbts_server/common/common_services.dart';
import 'package:bbts_server/screens/bbtm_screens/view/qr/gallery_qr.dart';
import 'package:bbts_server/screens/bbtm_screens/view/qr/qr_view.dart';
import 'package:bbts_server/theme/app_colors_extension.dart';
import 'package:bbts_server/widgets/text_field.dart';
import 'package:flutter/material.dart';

import '../../controllers/storage.dart';
import '../../models/group_model.dart';
import '../../widgets/group/group_card.dart';
import 'connect_to_group.dart';

class GroupingPage extends StatefulWidget {
  const GroupingPage({super.key});

  @override
  State<GroupingPage> createState() => _GroupingPageState();
}

class _GroupingPageState extends State<GroupingPage> {
  final StorageController _storageController = StorageController();
  final TextEditingController _searchController = TextEditingController();
  List<GroupDetails> _allGroups = [];
  List<GroupDetails> _filteredGroups = [];

  @override
  void initState() {
    super.initState();
    fetchGroups();
  }

  Future<void> fetchGroups() async {
    final groups = await _storageController.readAllGroups();
    setState(() {
      _allGroups = groups;
      _filteredGroups = groups;
    });
  }

  void _filterGroups(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredGroups = _allGroups;
      });
    } else {
      setState(() {
        _filteredGroups = _allGroups
            .where((groupDetails) => groupDetails.groupName
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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            backgroundColor: Theme.of(context).appColors.primary,
            child: Icon(Icons.camera_alt_outlined,
                color: Theme.of(context).appColors.background),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScanQr(
                    type: 'group',
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "gallery",
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const GalleryQRPage(
                  type: 'group',
                ),
              ));
            },
            backgroundColor: Theme.of(context).appColors.primary,
            child: Icon(Icons.image_outlined,
                color: Theme.of(context).appColors.background),
          ),
        ],
      ),
      appBar: AppBar(
        title: const Text("GROUPS"),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
                top: screenWidth * 0.06,
                left: screenWidth * 0.06,
                right: screenWidth * 0.06),
            child: CustomTextField(
              controller: _searchController,
              hintText: 'Search by Group Name',
              prefixIcon: const Icon(Icons.search),
              onChanged: _filterGroups, // Call the filter function
            ),
          ),
          Expanded(
            child: _filteredGroups.isEmpty
                ? CommonServices.noDataWidget()
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.all(screenWidth * 0.06),
                    itemCount: _filteredGroups.length,
                    itemBuilder: (context, index) {
                      final groupDetails = _filteredGroups[index];
                      return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ConnectToGroupWidget(
                                          groupName: groupDetails.groupName,
                                          selectedRouter:
                                              groupDetails.selectedRouter,
                                          selectedSwitches:
                                              groupDetails.selectedSwitches,
                                        )));
                          },
                          child: GroupCard(
                            groupDetails: groupDetails,
                          ));
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
