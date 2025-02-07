import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';


class PermissionProvider extends ChangeNotifier {
  PermissionStatus _storagePermissionStatus = PermissionStatus.denied;
  PermissionStatus _photosPermissionStatus = PermissionStatus.denied;

  PermissionStatus get storagePermissionStatus => _storagePermissionStatus;
  PermissionStatus get photosPermissionStatus => _photosPermissionStatus;

  Future<void> requestFileAndMediaPermission() async {
    _storagePermissionStatus = await Permission.storage.request();
    _photosPermissionStatus = await Permission.photos.request();

    notifyListeners();
  }
}
