import 'package:bbts_server/screens/bbtm_screens/models/contacts.dart';

import 'router_model.dart';

class GroupDetails {
  late String groupName;
  late String selectedRouter;
  late String routerPassword;
  late List<RouterDetails> selectedSwitches;
  late ContactsModel contactsModel;

  GroupDetails({
    required this.groupName,
    required this.selectedRouter,
    required this.routerPassword,
    required this.selectedSwitches,
    required this.contactsModel,
  });

  GroupDetails.fromJson(Map<String, dynamic> json) {
    groupName = json['groupName'];
    selectedRouter = json['selectedRouter'];
    routerPassword = json['routerPassword'];
    contactsModel = ContactsModel.fromJson(json['contactsModel']);
    var switchList = json['selectedSwitches'] as List;
    selectedSwitches =
        switchList.map((e) => RouterDetails.fromJsonGroup(e)).toList();
  }

  GroupDetails.fromJsonAdd(
      Map<String, dynamic> json, Map<String, dynamic> contact) {
    groupName = json['groupName'];
    selectedRouter = json['selectedRouter'];
    routerPassword = json['routerPassword'];
    contactsModel = ContactsModel.fromJson(contact);
    var switchList = json['selectedSwitches'] as List;
    selectedSwitches =
        switchList.map((e) => RouterDetails.fromJsonGroup(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['groupName'] = groupName;
    data['selectedRouter'] = selectedRouter;
    data['contactsModel'] = contactsModel.toJson();

    data['routerPassword'] = routerPassword;
    data['selectedSwitches'] =
        selectedSwitches.map((e) => e.toJsonGroup()).toList();
    return data;
  }
}
