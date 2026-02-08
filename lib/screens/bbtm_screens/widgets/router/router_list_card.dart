import 'package:bbts_server/theme/app_colors_extension.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../controllers/apis.dart';
import '../../models/router_model.dart';
import '../custom/toast.dart';

class RouterListCard extends StatefulWidget {
  const RouterListCard({
    required this.routerDetails,
    required this.index,
    required this.switchStatus,
    required this.wifiName,
    super.key,
  });
  final RouterDetails routerDetails;
  final int index;
  final bool switchStatus;
  final String wifiName;
  @override
  State<RouterListCard> createState() => _RouterListCardState();
}

class _RouterListCardState extends State<RouterListCard> {
  late int slNo;
  bool switchOn = false;

  @override
  void initState() {
    debugPrint(widget.switchStatus.toString());
    super.initState();
    slNo = widget.index + 1;
    switchOn = widget.switchStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 12.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 7,
            offset: const Offset(5, 5),
          ),
        ],
        color:
            Theme.of(context).appColors.buttonBackground.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(
            FontAwesomeIcons.solidLightbulb,
            color: switchOn ? Colors.yellow : Colors.grey,
            size: 40,
          ),
          Flexible(
            child: Text(
              widget.routerDetails.switchTypes[widget.index],
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Switch(
            onChanged: (value) async {
              if (!widget.wifiName.contains(widget.routerDetails.routerName) &&
                  !widget.routerDetails.routerName.contains(widget.wifiName)) {
                showToast(
                    "Please Connect WIFI to ${widget.routerDetails.routerName} to proceed");
                return;
              }
              try {
                if (value) {
                  ApiConnect.hitApiPost(
                      "${widget.routerDetails.iPAddress}/getSwitchcmd$slNo", {
                    "Lock_id": widget.routerDetails.switchID,
                    "lock_passkey": widget.routerDetails.switchPasskey,
                    "lock_cmd$slNo": "ON$slNo"
                  });
                  setState(() {
                    switchOn = true;
                  });
                } else if (!value) {
                  ApiConnect.hitApiPost(
                      "${widget.routerDetails.iPAddress}/getSwitchcmd$slNo", {
                    // "192.168.1.1/getSwitchcmd",

                    "Lock_id": widget.routerDetails.switchID,
                    "lock_passkey": widget.routerDetails.switchPasskey,
                    "lock_cmd$slNo": "OFF$slNo"
                  });
                  setState(() {
                    switchOn = false;
                  });
                } else {}
              } on DioException catch (e) {
                final scaffold = ScaffoldMessenger.of(context);
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
            value: switchOn,
            activeColor: Theme.of(context).appColors.greenButton,
            activeTrackColor: Theme.of(context).appColors.green,
            inactiveThumbColor: Theme.of(context).appColors.redButton,
            inactiveTrackColor: Theme.of(context).appColors.red,
          ),
        ],
      ),
    );
  }
}
