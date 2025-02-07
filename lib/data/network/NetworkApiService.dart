
import 'dart:convert';
import 'dart:io';
import 'package:c9_app/data/app_excaptions.dart';
import 'package:c9_app/data/network/BaseApiServices.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as https;
import 'package:shared_preferences/shared_preferences.dart';


class NetworkApiService extends BaseApiServices {


  @override
  Future getGetApiResponse(String url) async {

    dynamic responseJson ;
    try {

      final response = await https.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      responseJson = returnResponse(response);
    }on SocketException {

      throw FetchDataException(' No Internet Connection');
    }

    return responseJson;

  }



  @override
  Future getPostApiResponse(String url , dynamic data) async{

    dynamic responseJson ;
    try {

      Response response = await post(
        Uri.parse(url),
        body: data
      ).timeout(Duration(seconds: 10));

      responseJson = returnResponse(response);
    }on SocketException {

      throw FetchDataException(' No Internet Connection');
    }

    return responseJson ;
  }

  dynamic returnResponse (https.Response response){

    switch(response.statusCode){
      case 200:
        dynamic responseJson = jsonDecode(response.body);
        return responseJson ;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
        throw UnauthorisedExceptionLogin(response.body.toString());
      case 422:
        final dynamic responseBody = jsonDecode(response.body);
        final dynamic data = responseBody['data'];
        if (data != null && data is Map<String, dynamic>) {
          final List<dynamic>? emailErrors = data['email'];
        }
        throw UnauthorisedExceptionLogin("Unknown validation error occurred");
        // throw UnauthorisedException(response.body.toString());
        // // throw FetchDataException(" Your Account Not approved yet");
      case 500:
        throw FetchDataException(" Server error");
      case 404:
        throw UnauthorisedException(response.body.toString());
      default:
        // throw FetchDataException('Error accured while communicating with server'+
        //     'with status code' +response.statusCode.toString());
        throw FetchDataException(" Check your email or password");

    }
  }

}