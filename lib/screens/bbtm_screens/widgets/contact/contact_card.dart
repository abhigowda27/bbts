import 'package:bbts_server/theme/app_colors_extension.dart';
import 'package:flutter/material.dart';

import '../../../tabs_page.dart';
import '../../controllers/storage.dart';
import '../../models/contacts.dart';

class ContactsCard extends StatelessWidget {
  final ContactsModel contactsDetails;
  ContactsCard({
    required this.contactsDetails,
    super.key,
  });
  final StorageController _storageController = StorageController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.all(width * 0.03),
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).appColors.textSecondary.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(5, 5), // changes position of shadow
            ),
          ],
          color: Theme.of(context).appColors.background,
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Contact Name : ",
                style: TextStyle(
                    fontSize: width * 0.04,
                    color: Theme.of(context).appColors.textPrimary,
                    fontWeight: FontWeight.w600),
              ),
              Flexible(
                child: Text(
                  contactsDetails.name,
                  // maxLines: 2,
                  // overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: width * 0.04,
                      color: Theme.of(context).appColors.textPrimary,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                "Access Permission : ",
                style: TextStyle(
                    fontSize: width * 0.04,
                    color: Theme.of(context).appColors.textPrimary,
                    fontWeight: FontWeight.bold),
              ),
              Flexible(
                child: Text(
                  contactsDetails.accessType,
                  style: TextStyle(
                      fontSize: width * 0.04,
                      color: Theme.of(context).appColors.textPrimary,
                      fontWeight: FontWeight.w400),
                ),
              )
            ],
          ),
          Row(
            children: [
              Text(
                "Start and End Date : ",
                style: TextStyle(
                    fontSize: width * 0.04,
                    color: Theme.of(context).appColors.textPrimary,
                    fontWeight: FontWeight.bold),
              ),
              Flexible(
                child: Text(
                  contactsDetails.accessType.contains("Timed")
                      ? "${contactsDetails.startDateTime.day}/${contactsDetails.startDateTime.month}/${contactsDetails.startDateTime.year}-${contactsDetails.endDateTime.day}/${contactsDetails.endDateTime.month}/${contactsDetails.endDateTime.year}"
                      : "00-00",
                  style: TextStyle(
                      fontSize: width * 0.04,
                      color: Theme.of(context).appColors.textPrimary,
                      fontWeight: FontWeight.w400),
                ),
              )
            ],
          ),
          Row(
            children: [
              Text(
                "Start and End Time : ",
                style: TextStyle(
                    fontSize: width * 0.04,
                    color: Theme.of(context).appColors.textPrimary,
                    fontWeight: FontWeight.bold),
              ),
              Flexible(
                child: Text(
                  contactsDetails.accessType.contains("Timed")
                      ? "${contactsDetails.startDateTime.hour}:${contactsDetails.startDateTime.minute}-${contactsDetails.endDateTime.hour}:${contactsDetails.endDateTime.minute}"
                      : "00:00-00:00",
                  style: TextStyle(
                      fontSize: width * 0.04,
                      color: Theme.of(context).appColors.textPrimary,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
                color: Theme.of(context).appColors.primary,
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (cont) {
                            return AlertDialog(
                              title: const Text('BBT Switch'),
                              content:
                                  const Text('This will delete the Switch'),
                              actions: [
                                OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'CANCEL',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .appColors
                                            .primary),
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: () async {
                                    _storageController
                                        .deleteOneContact(contactsDetails);
                                    Navigator.pushAndRemoveUntil<dynamic>(
                                      context,
                                      MaterialPageRoute<dynamic>(
                                        builder: (BuildContext context) =>
                                            const TabsPage(),
                                      ),
                                      (route) =>
                                          false, //if you want to disable back feature set to false
                                    );
                                  },
                                  child: Text(
                                    'OK',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .appColors
                                            .primary),
                                  ),
                                ),
                              ],
                            );
                          });
                    },
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: Theme.of(context).appColors.textPrimary,
                    ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
