import 'package:bbts_server/common/common_services.dart';
import 'package:bbts_server/common/search_utils.dart';
import 'package:bbts_server/screens/bbtm_screens/controllers/storage.dart';
import 'package:bbts_server/screens/bbtm_screens/models/router_model.dart';
import 'package:bbts_server/screens/bbtm_screens/view/qr/gallery_qr.dart';
import 'package:bbts_server/screens/bbtm_screens/view/qr/qr_view.dart';
import 'package:bbts_server/screens/bbtm_screens/widgets/router/router_card.dart';
import 'package:bbts_server/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class RouterPage extends StatefulWidget {
  const RouterPage({super.key});

  @override
  State<RouterPage> createState() => _RouterPageState();
}

class _RouterPageState extends State<RouterPage> {
  final StorageController _storageController = StorageController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<RouterDetails> _allRouters = [];
  List<RouterDetails> _filteredRouters = [];
  bool _isFabVisible = true;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    fetchRouters();
    _scrollController.addListener(_handleScroll);
  }

  Future<void> fetchRouters() async {
    final routers = await _storageController.readRouters();
    setState(() {
      _allRouters = routers;
      _filteredRouters = routers;
    });
  }

  void _filterRouters(String query) {
    _filteredRouters = smartFilter<RouterDetails>(
      _allRouters,
      query,
      [
        (item) => item.routerName,
        (item) => item.switchName,
        (item) => item.switchID,
        (item) => item.selectedFan ?? "",
      ],
    );
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
            _filterRouters(result.recognizedWords);
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

  void _handleScroll() {
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
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _isFabVisible
          ? Column(
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
                          type: "router",
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
                        type: 'router',
                      ),
                    ));
                  },
                  backgroundColor: Theme.of(context).appColors.primary,
                  child: Icon(Icons.image_outlined,
                      color: Theme.of(context).appColors.background),
                ),
              ],
            )
          : null,
      appBar: AppBar(
        title: const Text('ROUTERS'),
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
                              onChanged: _filterRouters,
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
                child: _filteredRouters.isEmpty
                    ? CommonServices.noDataWidget()
                    : ListView.separated(
                        controller: _scrollController,
                        padding: EdgeInsets.all(screenWidth * 0.06),
                        itemCount: _filteredRouters.length,
                        itemBuilder: (context, index) {
                          final reversedIndex =
                              _filteredRouters.length - 1 - index;
                          final routerDetails = _filteredRouters[reversedIndex];
                          return RouterCard(routerDetails: routerDetails);
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(
                            height: 16,
                          );
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
