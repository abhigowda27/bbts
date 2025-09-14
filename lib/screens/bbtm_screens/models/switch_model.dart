import 'package:bbts_server/screens/bbtm_screens/models/contacts.dart';

class SwitchDetails {
  late String switchId;
  late String switchSSID;
  late String switchPassword;
  late String? selectedFan;
  late String iPAddress;
  late String switchPassKey;
  late List<String> switchTypes;
  late ContactsModel contactsModel;

  SwitchDetails(
      {required this.switchId,
      required this.switchPassKey,
      required this.switchSSID,
      required this.switchTypes,
      required this.switchPassword,
      required this.selectedFan,
      required this.iPAddress,
      required this.contactsModel});

  factory SwitchDetails.fromJson(
    Map<String, dynamic> switchJson,
    Map<String, dynamic> contactJson,
  ) {
    return SwitchDetails(
      switchId: switchJson['SwitchId'] ?? '',
      switchSSID: switchJson['SwitchSSID'] ?? '',
      switchTypes: List<String>.from(switchJson['SwitchTypes'] ?? []),
      selectedFan: switchJson['SelectedFan'] ?? '',
      switchPassword: switchJson['SwitchPassword'] ?? '',
      iPAddress: switchJson['IPAddress'] ?? '',
      switchPassKey: switchJson['SwitchPasskey'] ?? '',
      contactsModel: ContactsModel.fromJson(contactJson),
    );
  }

  factory SwitchDetails.fromStorageJson(Map<String, dynamic> json) {
    return SwitchDetails(
      switchId: json['SwitchId'] ?? '',
      switchSSID: json['SwitchSSID'] ?? '',
      switchTypes: List<String>.from(json['SwitchTypes'] ?? []),
      selectedFan: json['SelectedFan'] ?? '',
      switchPassword: json['SwitchPassword'] ?? '',
      iPAddress: json['IPAddress'] ?? '',
      switchPassKey: json['SwitchPasskey'] ?? '',
      contactsModel: ContactsModel.fromJson(json['contactsModel'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['SwitchId'] = switchId;
    data['SwitchSSID'] = switchSSID;
    data['SwitchTypes'] = switchTypes;
    data['SelectedFan'] = selectedFan;
    data['SwitchPassword'] = switchPassword;
    data['IPAddress'] = iPAddress;
    data['SwitchPasskey'] = switchPassKey;
    data['contactsModel'] = contactsModel.toJson();
    return data;
  }

  String toSwitchQR() {
    return "SWITCH,$switchId,$switchSSID,$switchPassKey,$switchPassword,$selectedFan,$switchTypes";
  }
}
