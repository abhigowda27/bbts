import 'dart:async';
import 'dart:convert';

import 'package:bbts_server/screens/bbtm_screens/widgets/custom/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/group_model.dart';
import '../models/mac_model.dart';
import '../models/router_model.dart';
import '../models/schedule_model.dart';
import '../models/switch_model.dart';

class StorageController {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  // Switch

  Future<void> updateSwitch(
      String idOfSwitch, SwitchDetails switchDetails) async {
    List<SwitchDetails> switchesList = await readSwitches();
    List<RouterDetails> routersList = await readRouters();

    debugPrint("-------------");
    debugPrint(
        "Switches before update: ${switchesList.map((e) => e.toJson()).toList()}");
    debugPrint(
        "Routers before update: ${routersList.map((e) => e.toJson()).toList()}");

    // Update switch details in the list
    for (var element in switchesList) {
      if (element.switchId == idOfSwitch) {
        element.switchId = switchDetails.switchId;
        element.switchPassword = switchDetails.switchPassword;
        element.switchSSID = switchDetails.switchSSID;
        element.switchPassKey = switchDetails.switchPassKey;
        element.selectedFan = switchDetails.selectedFan;
        element.switchTypes = switchDetails.switchTypes;
        break;
      }
    }

    debugPrint(
        "Switches after update: ${switchesList.map((e) => e.toJson()).toList()}");

    await deleteSwitches();
    await storage.write(
        key: "switches",
        value: json.encode(switchesList.map((e) => e.toJson()).toList()));

    // Update router details if the router is associated with the switch
    for (var element in routersList) {
      if (element.switchID == idOfSwitch) {
        element.switchID = switchDetails.switchId;
        element.switchName = switchDetails.switchSSID;
        element.switchPasskey = switchDetails.switchPassKey;
        element.selectedFan = switchDetails.selectedFan;
        element.switchTypes = switchDetails.switchTypes;
        // Keep the name, password, and ipAddress the same
        element.deviceMacId = element.deviceMacId;
        element.routerName = element.routerName;
        element.routerPassword = element.routerName;
        element.iPAddress = element.iPAddress;
        break;
      }
    }

    debugPrint(
        "Routers after update: ${routersList.map((e) => e.toJson()).toList()}");

    await deleteRouters();
    await storage.write(
        key: "routers",
        value: json.encode(routersList.map((e) => e.toJson()).toList()));
  }

  Future<void> updateSwitchIfIdExist(
      String idOfSwitch, String switchName, SwitchDetails switchDetails) async {
    List<SwitchDetails> switchesList = await readSwitches();
    List<RouterDetails> routersList = await readRouters();

    debugPrint("-------------");
    debugPrint(
        "Switches before update: ${switchesList.map((e) => e.toJson()).toList()}");
    debugPrint(
        "Routers before update: ${routersList.map((e) => e.toJson()).toList()}");

    // Update switch details in the list
    for (var element in switchesList) {
      if (element.switchId == idOfSwitch ||
          element.switchSSID == switchDetails.switchSSID) {
        element.switchId = switchDetails.switchId;
        element.switchPassword = switchDetails.switchPassword;
        element.switchSSID = switchDetails.switchSSID;
        element.switchPassKey = switchDetails.switchPassKey;
        element.selectedFan = switchDetails.selectedFan;
        element.switchTypes = switchDetails.switchTypes;
        break;
      }
    }

    debugPrint(
        "Switches after update: ${switchesList.map((e) => e.toJson()).toList()}");

    await deleteSwitches();
    await storage.write(
        key: "switches",
        value: json.encode(switchesList.map((e) => e.toJson()).toList()));

    // Update router details if the router is associated with the switch
    for (var element in routersList) {
      if (element.switchID == idOfSwitch ||
          element.switchName == switchDetails.switchSSID) {
        element.switchID = switchDetails.switchId;
        element.switchName = switchDetails.switchSSID;
        element.switchPasskey = switchDetails.switchPassKey;
        element.routerName = element.routerName;
        element.routerPassword = element.routerName;
        element.iPAddress = element.iPAddress;
        break;
      }
    }

    debugPrint(
        "Routers after update: ${routersList.map((e) => e.toJson()).toList()}");

    // Update the storage for routers
    await deleteRouters();
    await storage.write(
        key: "routers",
        value: json.encode(routersList.map((e) => e.toJson()).toList()));
  }

  Future<void> deleteSwitches() async {
    await storage.delete(key: "switches");
  }

  Future<List<SwitchDetails>> readSwitches() async {
    String? switches = await storage.read(key: "switches");
    List<SwitchDetails> model = [];

    if (switches == null) {
      // Write an empty list to storage if no switches exist
      await storage.write(key: "switches", value: json.encode([]));
    } else {
      try {
        // Decode the JSON string into a List of Maps (i.e., List<Map<String, dynamic>>)
        List<dynamic> jsonContacts = json.decode(switches);
        debugPrint(switches);

        // Iterate over the decoded list and convert each map to SwitchDetails
        for (var element in jsonContacts) {
          if (element is Map<String, dynamic>) {
            model.add(SwitchDetails.fromStorageJson(element));
          }
        }
      } catch (e) {
        // Handle potential decoding errors
        debugPrint('Error decoding switches: $e');
      }
    }

    return model;
  }

  Future<SwitchDetails?>? getSwitchBySSID(String switchName) async {
    List<SwitchDetails> switchesList = await readSwitches();
    for (var element in switchesList) {
      if (element.switchSSID == switchName) return element;
    }
    return null;
  }

  Future<void> deleteOneSwitch(SwitchDetails switchDetails) async {
    List<SwitchDetails> switchList = await readSwitches();
    switchList.removeWhere(
        (element) => element.switchSSID == switchDetails.switchSSID);
    List listContactsInJson = switchList.map((e) {
      return e.toJson();
    }).toList();
    await deleteSwitches();
    storage.write(key: "switches", value: json.encode(listContactsInJson));
  }

  Future<void> deleteOneSwitchType({
    required SwitchDetails switchDetails,
    required String typeToRemove,
  }) async {
    // Read the list from storage
    List<SwitchDetails> switchList = await readSwitches();

    // Find the switch by SSID
    final index = switchList.indexWhere(
        (element) => element.switchSSID == switchDetails.switchSSID);

    if (index != -1) {
      // Remove the specific switch type
      switchList[index].switchTypes.remove(typeToRemove);

      // If no switchTypes left, remove the whole switch
      if (switchList[index].switchTypes.isEmpty) {
        switchList.removeAt(index);
      }

      // Save updated list back to storage
      final updatedJson =
          switchList.map((switchItem) => switchItem.toJson()).toList();
      await deleteSwitches();
      await storage.write(
        key: "switches",
        value: json.encode(updatedJson),
      );
    }
  }

  Future<bool> isSwitchNameExists(String switchName, String switchId) async {
    List<SwitchDetails> switchesList = await readSwitches();
    for (var switchDetails in switchesList) {
      if (switchDetails.switchSSID == switchName ||
          switchDetails.switchId == switchId) {
        return true;
      }
    }
    return false;
  }

  Future<bool> isSwitchSSIDExists(String switchSSID) async {
    List<SwitchDetails> switchesList = await readSwitches();
    for (var switchDetails in switchesList) {
      if (switchDetails.switchSSID == switchSSID) {
        return true;
      }
    }
    return false;
  }

  void addSwitches(SwitchDetails switchDetails) async {
    bool exists = await isSwitchSSIDExists(switchDetails.switchSSID);
    if (exists) {
      showToast("Switch Name already exists.");
      return;
    }
    List<SwitchDetails> switchesList = await readSwitches();
    switchesList.add(switchDetails);
    List listContectsInJson = switchesList.map((e) {
      return e.toJson();
    }).toList();
    storage.write(key: "switches", value: json.encode(listContectsInJson));
  }

  // ROUTERS
  Future<void> updateRouter(
    RouterDetails routerDetails,
  ) async {
    List<RouterDetails> routersList = await readRouters();
    routersList
        .removeWhere((element) => element.switchID == routerDetails.switchID);
    routersList.add(routerDetails);
    await storage.write(
      key: "routers",
      value: json.encode(routersList.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> deleteRouters() async {
    await storage.delete(key: "routers");
  }

  Future<RouterDetails?>? getRouterByName(String switchName) async {
    List<RouterDetails> routerList = await readRouters();
    for (var element in routerList) {
      if ("${element.routerName}_${element.switchName}" == switchName) {
        return element;
      }
    }
    return null;
  }

  Future<List<RouterDetails>> readRouters() async {
    String? switches = await storage.read(key: "routers");
    List<RouterDetails> model = [];
    if (switches == null) {
      List listContectsInJson = model.map((e) {
        return e.toJson();
      }).toList();
      storage.write(key: "routers", value: json.encode(listContectsInJson));
    } else {
      model = [];
      debugPrint("routers $switches");

      var jsonContacts = json.decode(switches);
      for (var element in jsonContacts) {
        model.add(RouterDetails.fromJson(element));
      }
    }
    return model;
  }

  Future<void> deleteOneRouter(String switchId) async {
    List<RouterDetails> switchList = await readRouters();

    switchList.removeWhere((element) => element.switchID == switchId);

    List listContectsInJson = switchList.map((e) {
      return e.toJson();
    }).toList();
    storage.write(key: "routers", value: json.encode(listContectsInJson));
  }

  Future<void> deleteOneSwitchTypeFromRouter({
    required String switchId,
    required String switchTypeToRemove,
  }) async {
    List<RouterDetails> routerList = await readRouters();

    // Find router by switchID
    final index =
        routerList.indexWhere((element) => element.switchID == switchId);

    if (index != -1) {
      // Remove the specific switchType
      routerList[index].switchTypes.remove(switchTypeToRemove);

      // If no switchTypes left, remove the whole router
      if (routerList[index].switchTypes.isEmpty) {
        routerList.removeAt(index);
      }

      // Save updated list back to storage
      List listRoutersInJson = routerList.map((e) => e.toJson()).toList();
      await storage.write(
          key: "routers", value: json.encode(listRoutersInJson));
    }
  }

  Future<String?> getRouterNameIfSwitchIDExists(String switchID) async {
    List<RouterDetails> routerList = await readRouters();
    for (var switchDetails in routerList) {
      if (switchDetails.switchID == switchID) {
        debugPrint("${switchDetails.switchID} SwitchDetails Switch ID");
        debugPrint("$switchID SwitchID");
        return switchDetails.routerName;
      }
    }
    return null;
  }

  Future<bool> isSwitchIDExists(String switchID) async {
    List<RouterDetails> routerList = await readRouters();
    for (var switchDetails in routerList) {
      if (switchDetails.switchID == switchID) {
        return true;
      }
    }
    return false;
  }

  void addRouters(RouterDetails switchDetails) async {
    bool exists = await isSwitchIDExists(switchDetails.switchID);
    if (exists) {
      showToast("Router Switch ID already exists.");
      return;
    }
    List<RouterDetails> switchesList = await readRouters();
    switchesList.add(switchDetails);
    List listContectsInJson = switchesList.map((e) {
      return e.toJson();
    }).toList();
    storage.write(key: "routers", value: json.encode(listContectsInJson));
  }

  //Group
  static const _groupStateKey = 'isGroupSwitchOn';

  Future<bool> loadGroupSwitchState() async {
    String? value = await storage.read(key: _groupStateKey);
    return value != null && value.toLowerCase() == 'true';
  }

  Future<void> saveGroupSwitchState(bool value) async {
    await storage.write(key: _groupStateKey, value: value.toString());
  }

  Future<void> deleteGroups() async {
    await storage.delete(key: "groups");
  }

  Future<GroupDetails?>? getGroupByName(String groupName) async {
    List<GroupDetails> groupList = await readAllGroups();
    for (var element in groupList) {
      if (element.groupName == groupName) return element;
    }
    return null;
  }

  Future<bool> groupExists(String groupName) async {
    List<GroupDetails> allGroups = await readAllGroups();

    return allGroups.any((group) => group.groupName == groupName);
  }

  Future<void> saveGroupDetails(GroupDetails groupDetails) async {
    bool exists = await groupExists(groupDetails.groupName);
    if (exists) {
      showToast("Group Name already exists.");
      return;
    }
    List<GroupDetails> groups = await readAllGroups();
    groups.add(groupDetails);
    List listContectsInJson = groups.map((e) {
      return e.toJson();
    }).toList();
    await storage.write(key: "groups", value: json.encode(listContectsInJson));
  }

  Future<List<GroupDetails>> readAllGroups() async {
    String? groupsJson = await storage.read(key: 'groups');
    if (groupsJson == null) return [];
    List<dynamic> groupsList = jsonDecode(groupsJson);
    return groupsList.map((json) => GroupDetails.fromJson(json)).toList();
  }

  Future<void> updateGroupDetails(String groupName, String routerName,
      List<RouterDetails> selectedSwitches) async {
    // Assuming you have a method to fetch all group details from storage
    List<GroupDetails> allGroups = await readAllGroups();
    debugPrint("-------------");
    List listContectsInJson = allGroups.map((e) {
      return e.toJson();
    }).toList();
    debugPrint("$listContectsInJson");
    debugPrint("${allGroups.length}");
    for (var element in allGroups) {
      if (element.groupName == groupName) {
        element.groupName = groupName;
        element.selectedRouter = routerName;
        element.selectedSwitches = selectedSwitches;
        break;
      }
    }
    listContectsInJson = allGroups.map((e) {
      return e.toJson();
    }).toList();
    debugPrint("$listContectsInJson");
    await deleteGroups();
    storage.write(key: "groups", value: json.encode(listContectsInJson));
  }

  Future<void> deleteOneGroup(GroupDetails groupDetails) async {
    List<GroupDetails> groups = await readAllGroups();
    groups.removeWhere((group) => group.groupName == groupDetails.groupName);
    await storage.write(
      key: 'groups',
      value: jsonEncode(groups.map((group) => group.toJson()).toList()),
    );
  }

  Future<void> deleteMacs() async {
    await storage.delete(key: "macs");
  }

  // Retrieve the state of a MAC card
  Future<bool> getMacState(MacsDetails mac) async {
    final state = await storage.read(
        key: 'mac_${mac.id}_${mac.switchDetails.switchSSID}');
    return state == 'true';
  }

  // Delete a MAC card's state
  Future<void> deleteMacState(MacsDetails mac) async {
    await storage.delete(key: 'mac_${mac.id}_${mac.switchDetails.switchSSID}');
  }

  // QR PIN

  Future<String?> getQrPin() async {
    return await storage.read(key: 'qrPinKey');
  }

  Future<void> setQrPin(String pin) async {
    await storage.write(key: 'qrPinKey', value: pin);
  }

  // factory Reset
  Future<void> deleteEverythingWithRespectToSwitchID(
      SwitchDetails switchDetails) async {
    debugPrint("Deleting all routers");
    List<RouterDetails> routerList = await readRouters();
    routerList
        .removeWhere((element) => element.switchID == switchDetails.switchId);
    List routerListContectsInJson = routerList.map((e) {
      return e.toJson();
    }).toList();
    storage.write(key: "routers", value: json.encode(routerListContectsInJson));
    debugPrint("Deleted all routers");
    debugPrint("Deleting all switches");
    deleteOneSwitch(switchDetails);
    debugPrint("Deleted all switches");
  }

  // Schedule ON OFF

  Future<void> saveAlarm(String key, Schedule alarm) async {
    await storage.write(
      key: key,
      value: jsonEncode(alarm.toJson()),
    );
  }

  Future<Schedule?> loadAlarm(String key) async {
    final savedData = await storage.read(key: key);
    if (savedData != null) {
      return Schedule.fromJson(jsonDecode(savedData));
    }
    return null;
  }

  Future<void> deleteAlarm(String key) async {
    await storage.delete(key: key);
  }
}
