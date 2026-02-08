import 'package:bbts_server/common/common_services.dart';
import 'package:bbts_server/common/search_utils.dart';
import 'package:bbts_server/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

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
  bool _isFabVisible = true;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  List<SwitchDetails> _allSwitches = [];
  List<SwitchDetails> _filteredSwitches = [];

  @override
  void initState() {
    super.initState();
    fetchSwitches();
    _speech = stt.SpeechToText();
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
    setState(() {
      _filteredSwitches = smartFilter<SwitchDetails>(
        _allSwitches,
        query,
        [
          (item) => item.switchSSID,
          (item) => item.switchId,
          (item) => item.selectedFan ?? "",
        ],
      );
    });

    if (_filteredSwitches.length == 1) {
      _stopListening();
      Future.delayed(const Duration(milliseconds: 200), () {
        _singleCardKey?.currentState?.performTap();
      });
    }
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
            _filterSwitches(result.recognizedWords);
          });
        },
      );
    }
  }

  void _stopListening() {
    if (_isListening) {
      setState(() {
        _isListening = false;
        _showListeningUI = false;
      });
      _speech.stop();
    }
  }

  GlobalKey<SwitchCardState>? _singleCardKey;

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
                              onChanged: _filterSwitches,
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
                child: _filteredSwitches.isEmpty
                    ? CommonServices.noDataWidget()
                    : ListView.separated(
                        controller: _scrollController,
                        padding: EdgeInsets.all(screenWidth * 0.06),
                        itemCount: _filteredSwitches.length,
                        itemBuilder: (context, index) {
                          final reversedIndex =
                              _filteredSwitches.length - 1 - index;
                          final switchDetails =
                              _filteredSwitches[reversedIndex];
                          return SwitchCard(
                            key: _filteredSwitches.length == 1
                                ? (_singleCardKey =
                                    GlobalKey<SwitchCardState>())
                                : GlobalKey(),
                            switchDetails: switchDetails,
                          );
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
