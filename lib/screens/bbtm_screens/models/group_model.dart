import 'package:bbts/screens/bbtm_screens/models/contacts.dart';

import 'router_model.dart';

class GroupDetails {
  late String groupName;
  late String selectedRouter;
  late String routerPassword;
  late List<RouterDetails> selectedSwitches;
  late int maximumWattage;
  late ContactsModel contactsModel;

  GroupDetails({
    required this.groupName,
    required this.selectedRouter,
    required this.routerPassword,
    required this.selectedSwitches,
    required this.maximumWattage,
    required this.contactsModel,
  });

  GroupDetails.fromJson(Map<String, dynamic> json) {
    groupName = json['groupName'];
    selectedRouter = json['selectedRouter'];
    routerPassword = json['routerPassword'];
    maximumWattage = json['maximumWattage'] ?? 00;
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
    maximumWattage = json['maximumWattage'] ?? 00;
    var switchList = json['selectedSwitches'] as List;
    selectedSwitches =
        switchList.map((e) => RouterDetails.fromJsonGroup(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['groupName'] = groupName;
    data['selectedRouter'] = selectedRouter;
    data['contactsModel'] = contactsModel.toJson();
    data['maximumWattage'] = maximumWattage;
    data['routerPassword'] = routerPassword;
    data['selectedSwitches'] =
        selectedSwitches.map((e) => e.toJsonGroup()).toList();
    return data;
  }
}
