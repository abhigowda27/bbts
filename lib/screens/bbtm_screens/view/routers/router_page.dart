import 'package:bbts_server/common/common_services.dart';
import 'package:bbts_server/screens/bbtm_screens/controllers/storage.dart';
import 'package:bbts_server/screens/bbtm_screens/models/router_model.dart';
import 'package:bbts_server/screens/bbtm_screens/view/qr/gallery_qr.dart';
import 'package:bbts_server/screens/bbtm_screens/view/qr/qr_view.dart';
import 'package:bbts_server/screens/bbtm_screens/view/routers/connect_to_router.dart';
import 'package:bbts_server/screens/bbtm_screens/widgets/router/router_card.dart';
import 'package:bbts_server/theme/app_colors_extension.dart';
import 'package:bbts_server/widgets/text_field.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
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
    if (query.isEmpty) {
      setState(() {
        _filteredRouters = _allRouters;
      });
    } else {
      setState(() {
        _filteredRouters = _allRouters
            .where((routerDetails) => routerDetails.routerName
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      });
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
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
                top: screenWidth * 0.06,
                left: screenWidth * 0.06,
                right: screenWidth * 0.06),
            child: CustomTextField(
              controller: _searchController,
              hintText: 'Search Switch',
              prefixIcon: const Icon(Icons.search),
              onChanged: _filterRouters,
            ),
          ),
          Expanded(
            child: _filteredRouters.isEmpty
                ? CommonServices.noDataWidget()
                : ListView.separated(
                    controller: _scrollController,
                    padding: EdgeInsets.all(screenWidth * 0.06),
                    itemCount: _filteredRouters.length,
                    itemBuilder: (context, index) {
                      final reversedIndex = _filteredRouters.length - 1 - index;
                      final routerDetails = _filteredRouters[reversedIndex];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConnectToRouterPage(
                                routerDetails: routerDetails,
                              ),
                            ),
                          );
                        },
                        child: RouterCard(routerDetails: routerDetails),
                      );
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
    );
  }
}
