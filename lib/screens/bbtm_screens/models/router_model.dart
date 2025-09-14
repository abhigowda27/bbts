import 'contacts.dart';

class RouterDetails {
  late String switchID;
  late String switchName;
  late String routerName;
  late String routerPassword;
  late String? selectedFan;
  late List<String> switchTypes;
  late String? iPAddress;
  late String? deviceMacId;
  late String switchPasskey;
  late ContactsModel? contactsModel;

  RouterDetails(
      {required this.switchID,
      required this.routerName,
      required this.routerPassword,
      required this.iPAddress,
      required this.deviceMacId,
      required this.selectedFan,
      required this.switchTypes,
      required this.switchPasskey,
      required this.switchName,
      required this.contactsModel});

  RouterDetails.fromJson(Map<String, dynamic> json) {
    switchID = json['SwitchId'];
    switchName = json['SwitchName'];
    routerName = json['RouterName'];
    routerPassword = json['RouterPassword'];
    selectedFan = json['SelectedFan'];
    switchTypes = List<String>.from(json['SwitchTypes'] ?? []);
    switchPasskey = json['SwitchPassKey'];
    iPAddress = json['IPAddress'];
    deviceMacId = json["macId"];
    contactsModel = ContactsModel.fromJson(json['contactsModel']);
  }

  RouterDetails.fromJsonGroup(Map<String, dynamic> json) {
    switchID = json['SwitchId'];
    switchName = json['SwitchName'];
    routerName = json['RouterName'];
    routerPassword = json['RouterPassword'];
    selectedFan = json['SelectedFan'];
    switchTypes = List<String>.from(json['SwitchTypes'] ?? []);
    switchPasskey = json['SwitchPassKey'];
    iPAddress = json['IPAddress'];
    deviceMacId = json["macId"];
  }

  RouterDetails.fromJsonAdd(
      Map<String, dynamic> json, Map<String, dynamic> contacts) {
    switchID = json['SwitchId'];
    switchName = json['SwitchName'];
    routerName = json['RouterName'];
    routerPassword = json['RouterPassword'];
    selectedFan = json['SelectedFan'];
    switchTypes = List<String>.from(json['SwitchTypes'] ?? []);
    switchPasskey = json['SwitchPassKey'];
    iPAddress = json['IPAddress'];
    deviceMacId = json["macId"];
    contactsModel = ContactsModel.fromJson(contacts);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['SwitchId'] = switchID;
    data['SwitchName'] = switchName;
    data['RouterName'] = routerName;
    data['RouterPassword'] = routerPassword;
    data['SwitchTypes'] = switchTypes;
    data['SelectedFan'] = selectedFan;
    data['SwitchPassKey'] = switchPasskey;
    data['IPAddress'] = iPAddress;
    data['macId'] = deviceMacId;
    data['contactsModel'] = contactsModel?.toJson() ?? {};
    return data;
  }

  Map<String, dynamic> toJsonGroup() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['SwitchId'] = switchID;
    data['SwitchName'] = switchName;
    data['RouterName'] = routerName;
    data['RouterPassword'] = routerPassword;
    data['SwitchTypes'] = switchTypes;
    data['SelectedFan'] = selectedFan;
    data['SwitchPassKey'] = switchPasskey;
    data['IPAddress'] = iPAddress;
    data['macId'] = deviceMacId;
    return data;
  }

  String toRouterQR() {
    return "ROUTER,$switchID,$switchName,$routerName,$routerPassword,$switchPasskey,$selectedFan,$iPAddress,$switchTypes";
  }

  String routerQRGroup() {
    return "$switchID,$switchName,$switchPasskey,${switchTypes.length},$selectedFan,$iPAddress";
  }
}
