import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:c9_app/data/network/BaseApiServices.dart';
import 'package:c9_app/data/network/NetworkApiService.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:http/http.dart' as http;

class AuthRepository {
  BaseApiServices _apiServices = NetworkApiService();

  Future<dynamic> loginApi(dynamic data) async {
    try {
      dynamic response = await _apiServices.getPostApiResponse(AppUrl.loginEndPint, data);
      return response;
    } catch (e) {
      throw e;
    }
  }

  Future<dynamic> signUpApi(dynamic data) async {
    try {
      dynamic response = await _apiServices.getPostApiResponse(AppUrl.registerApiEndPoint, data);
      return response;
    } catch (e) {
      throw e;
    }
  }

  Future<void> logoutApi(String token) async {
    try {
      final response = await http.get(
        Uri.parse(AppUrl.logOutEndPoint),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        // Logout was successful
        await _clearAllCaches();
      } else {
        throw Exception('Failed to logout. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw e;
    }
  }

  // Future<void> _clearAllCaches() async {
  //   await APICacheManager().deleteCache('Active Client');
  //   await APICacheManager().deleteCache('Previous Client');
  //   await APICacheManager().deleteCache('Client DashBoard');
  //   await APICacheManager().deleteCache('Clients List');
  //   await APICacheManager().deleteCache('Payslip');
  //   await APICacheManager().deleteCache('Staff Profile');
  //   await APICacheManager().deleteCache('Request List');
  //   await APICacheManager().deleteCache('Request Tab');
  //   await APICacheManager().deleteCache('Department Tab');
  //   await APICacheManager().deleteCache('Department List');
  //   await APICacheManager().deleteCache('WeekDataStaff');
  //   await APICacheManager().deleteCache('WeekDetails_Staff');
  // }

  Future<void> _clearAllCaches() async {
    List<String> cacheKeys = [
      'Active Client',
      'Previous Client',
      'Client DashBoard',
      'Clients List',
      'Payslip',
      'Staff Profile',
      'Client Profile',
      'Request List',
      'Request Tab',
      'Department Tab',
      'Department List',
      'WeekDataStaff',
      'WeekDetails_Staff',
    ];

    for (String key in cacheKeys) {
      await APICacheManager().deleteCache(key);
      print('Cache cleared: $key'); // Print statement to show cache removal
    }
  }
}
