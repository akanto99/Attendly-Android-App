import 'package:api_cache_manager/api_cache_manager.dart';
import 'package:c9_app/model/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserViewModel with ChangeNotifier {
  String? _token;
  String? get token => _token;

  dynamic _id;
  dynamic get id => _id;

  String? _message;
  String? get message => _message;

 String ? _role;
 String ? get role=> _role;

  String ? _image;
  String ? get image=> _image;

  String ? _name;
  String ? get name=> _name;

  String ? _latitude;
  String ? get latitude=> _latitude;


  String ? _longitude;
  String ? get longitude=> _longitude;


  void setUserDetails(String email, String token, String message, String password, dynamic id) {
    _id = id;
    _token = token;
    _message = message;
   _role=role;
   _image=image;
   _name=name;
   _latitude=latitude;
   _longitude=longitude;
    notifyListeners();
  }

  Future<bool> saveUser(UserModel user) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString('id', user.id.toString());
    sp.setString('token', user.token.toString());
    sp.setString('message', user.message.toString());
    sp.setString('role', user.role.toString());
    sp.setString('image', user.image.toString());
    sp.setString('name', user.name.toString());
    sp.setString('latitude', user.latitude.toString());
    sp.setString('longitude', user.longitude.toString());

    _id = user.id.toString();
    _token = user.token.toString();
    _message = user.message.toString();
    _role = user.role.toString();
    _image = user.image.toString();
    _name = user.name.toString();
    _latitude = user.latitude.toString();
    _longitude = user.longitude.toString();

    notifyListeners();
    return true;
  }


  Future<UserModel> getUser() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    final dynamic id = sp.getString('id');
    final String? token = sp.getString('token');
    final String? message = sp.getString('message');
    final String? role = sp.getString('role');
    final String? image = sp.getString('image');
    final String? name = sp.getString('name');
    final String? latitude = sp.getString('latitude');
    final String? longitude = sp.getString('longitude');


    if (token != null) {
      return UserModel(token: token, message: message ?? '', role: role,image: image,name: name,latitude: latitude,longitude: longitude,id:id);
    } else {
      return UserModel(token: '', message: '', role: '',image: "",name: "",latitude: "",longitude: "",id:"");
    }
  }

  // Future<bool> remove() async {
  //   final SharedPreferences sp = await SharedPreferences.getInstance();
  //   sp.remove('id');
  //   sp.remove('token');
  //   sp.remove('message');
  //   sp.remove('email');
  //   sp.remove('password');
  //
  //   await APICacheManager().deleteCache('Active Client');
  //   await APICacheManager().deleteCache('Previous Client');
  //   await APICacheManager().deleteCache('Client DashBoard');
  //   await APICacheManager().deleteCache('Clients List');
  //   await APICacheManager().deleteCache('Staff Profile');
  //   await APICacheManager().deleteCache('Client Profile');
  //
  //   await APICacheManager().deleteCache('Request List'); //delete previous cached Data
  //   await APICacheManager().deleteCache('Request Tab'); //delete previous cached Data
  //   await APICacheManager().deleteCache('Department Tab'); //delete previous cached Data
  //   await  APICacheManager().deleteCache('Department List'); //delete previous cached Data
  //
  //
  //   await APICacheManager().deleteCache('WeekData List'); //delete previous cached Data
  //   await APICacheManager().deleteCache('WeekDataDetails List'); //delete previous cached Data
  //
  //
  //   await APICacheManager().deleteCache('Payslip');
  //
  //
  //   return true;
  // }

  Future<bool> remove() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.remove('id');
    sp.remove('token');
    sp.remove('message');
    sp.remove('email');
    sp.remove('password');

    _id = null;
    _token = null;
    _message = null;
    _role = null;
    _image = null;
    _name = null;
    _latitude = null;
    _longitude = null;

    // Notify listeners to update UI
    notifyListeners();

    // Clear API cache
    await APICacheManager().emptyCache();

    return true;
  }

}
