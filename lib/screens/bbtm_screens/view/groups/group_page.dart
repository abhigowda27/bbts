import 'package:bbts_server/common/common_services.dart';
import 'package:bbts_server/common/search_utils.dart';
import 'package:bbts_server/screens/bbtm_screens/view/qr/gallery_qr.dart';
import 'package:bbts_server/screens/bbtm_screens/view/qr/qr_view.dart';
import 'package:bbts_server/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

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
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
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
    setState(() {
      _filteredGroups = smartFilter<GroupDetails>(
        _allGroups,
        query,
        [
          (item) => item.groupName,
          (item) => item.selectedRouter,
        ],
      );
    });
  }

  bool _showListeningUI = false;

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
        _showListeningUI = true;
      });

      _speech.listen(
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenMode: stt.ListenMode.search,
        ),
        onResult: (result) {
          setState(() {
            _searchController.text = result.recognizedWords;
            _filterGroups(result.recognizedWords);
          });
        },
      );
    }
  }

  void _stopListening() {
    if (_isListening) {
      setState(() {
        _isListening = false;
        _showListeningUI = false; // Hide animation
      });
      _speech.stop();
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
      body: Stack(
        children: [
          Column(
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
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).appColors.background,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: _filterGroups,
                              decoration: InputDecoration(
                                hintText: 'Search devices...',
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                                prefixIcon: const Icon(Icons.search,
                                    color: Colors.grey),
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 15),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onLongPressStart: (_) => _startListening(),
                            onLongPressEnd: (_) => _stopListening(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                color: Theme.of(context).appColors.background,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                size: 25,
                                _isListening ? Icons.mic : Icons.mic_none,
                                color: Theme.of(context).appColors.primary,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Expanded(
                child: _filteredGroups.isEmpty
                    ? CommonServices.noDataWidget()
                    : ListView.separated(
                        padding: EdgeInsets.all(screenWidth * 0.06),
                        itemCount: _filteredGroups.length,
                        itemBuilder: (context, index) {
                          final groupDetails = _filteredGroups[index];
                          return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ConnectToGroupWidget(
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

          // 🎙️ LISTENING OVERLAY UI
          if (_showListeningUI)
            Center(
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withValues(alpha: 0.15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withValues(alpha: 0.4),
                      blurRadius: 50,
                      spreadRadius: 20,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.mic,
                  size: 90,
                  color: Theme.of(context).appColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
