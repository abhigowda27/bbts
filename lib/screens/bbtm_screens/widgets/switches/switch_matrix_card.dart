import 'package:bbts_server/theme/app_colors_extension.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../controllers/apis.dart';
import '../../models/switch_model.dart';
import '../custom/toast.dart';

class SwitchMatrixCard extends StatefulWidget {
  final SwitchDetails switchDetails;
  final int index;
  final bool switchStatus;
  final String wifiName;
  const SwitchMatrixCard({
    required this.switchDetails,
    required this.index,
    required this.switchStatus,
    super.key,
    required this.wifiName,
  });

  @override
  State<SwitchMatrixCard> createState() => _SwitchMatrixCardState();
}

class _SwitchMatrixCardState extends State<SwitchMatrixCard> {
  late int slNo;
  bool switchOff = false;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    slNo = widget.index + 1;
    switchOff = !widget.switchStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 12.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 7,
            offset: const Offset(5, 5),
          ),
        ],
        color: Theme.of(context).appColors.buttonBackground.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(
            FontAwesomeIcons.solidLightbulb,
            color: switchOff ? Colors.yellow : Colors.grey,
            size: 40,
          ),
          Flexible(
            child: Text(
              widget.switchDetails.switchTypes[widget.index],
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Switch(
            onChanged: (value) async {
              if (!widget.wifiName.contains(widget.switchDetails.switchSSID) &&
                  !widget.switchDetails.switchSSID.contains(widget.wifiName)) {
                showToast(
                    "Please Connect WIFI to ${widget.switchDetails.switchSSID} to proceed");
                return;
              }
              try {
                if (value) {
                  ApiConnect.hitApiPost(
                      "${widget.switchDetails.iPAddress}/getSwitchcmd$slNo", {
                    "Lock_id": widget.switchDetails.switchId,
                    "lock_passkey": widget.switchDetails.switchPassKey,
                    "lock_cmd$slNo": "ON$slNo"
                  });
                  setState(() {
                    switchOff = true;
                  });
                } else if (!value) {
                  ApiConnect.hitApiPost(
                      "${widget.switchDetails.iPAddress}/getSwitchcmd$slNo", {
                    "Lock_id": widget.switchDetails.switchId,
                    "lock_passkey": widget.switchDetails.switchPassKey,
                    "lock_cmd$slNo": "OFF$slNo"
                  });
                  setState(() {
                    switchOff = false;
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
            value: switchOff,
            activeColor: Theme.of(context).appColors.greenButton,
            activeTrackColor: Theme.of(context).appColors.green,
            inactiveThumbColor: Theme.of(context).appColors.grey,
            inactiveTrackColor: Theme.of(context).appColors.white,
          ),
        ],
      ),
    );
  }
}
