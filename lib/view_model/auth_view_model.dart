import 'package:c9_app/model/user_model.dart';
import 'package:c9_app/respository/auth_repository.dart';
import 'package:c9_app/utils/routes/routes_name.dart';
import 'package:c9_app/utils/utils.dart';
import 'package:c9_app/view_model/services/rolebasedmodel/user_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class AuthViewModel with ChangeNotifier {

  final _myRepo = AuthRepository();

  bool _loading = false ;
  bool get loading => _loading ;

  bool _signUpLoading = false ;
  bool get signUpLoading => _signUpLoading ;

  bool _createLoading = false ;
  bool get createLoading => _createLoading ;


  setLoading(bool value){
    _loading = value;
    notifyListeners();
  }

  setSignUpLoading(bool value){
    _signUpLoading = value;
    notifyListeners();
  }

  setcreateLoading(bool value){
    _createLoading = value;
    notifyListeners();
  }

  // Future<void> loginApi(dynamic data , BuildContext context) async {
  //
  //   setLoading(true);
  //
  //   _myRepo.loginApi(data).then((value){
  //     setLoading(false);
  //     final userPreference = Provider.of<UserViewModel>(context , listen: false);
  //     userPreference.saveUser(
  //         UserModel(
  //           token: value['token'].toString(),
  //           message: value['message'].toString(), // Provide the required message parameter
  //           role: value['role'].toString()
  //         )
  //     );
  //
  //     Utils.flushBarErrorMessage('Login Successfully', context);
  //     Navigator.pushNamed(context, RoutesName.home);
  //     if(kDebugMode){
  //       print(value.toString());
  //
  //     }
  //   }).onError((error, stackTrace){
  //     setLoading(false);
  //     Utils.flushBarErrorMessage(error.toString(), context);
  //     if(kDebugMode){
  //       print(error.toString());
  //     }
  //
  //   });
  // }
  Future<void> loginApi(dynamic data, BuildContext context) async {
    setLoading(true);

    _myRepo.loginApi(data).then((value) {
      setLoading(false);

      final userPreference = Provider.of<UserViewModel>(context, listen: false);

      userPreference.saveUser(
        UserModel(
          id: value['id'].toString(),
          token: value['token'].toString(),
          message: value['message'].toString(),
          role: value['role'].toString(),
          image: value['image'].toString(),
          name: value['name'].toString(),
          latitude: value['latitude'].toString(),
          longitude: value['longitude'].toString(),
        ),
      );

      Utils.flushBarSuccessMessage('Login Successfully', context);

      String role = value['role'].toString().toLowerCase();
      switch (role) {
        case 'clients':
          Navigator.pushNamed(context, RoutesName.clientVies);
          break;
        case 'staff':
          Navigator.pushNamed(context, RoutesName.staffVies);
          break;
        case 'admin':
          Navigator.pushNamed(context, RoutesName.home);
          break;
        default:
          break;
      }

      if (kDebugMode) {
        print(value.toString());
      }
    }).onError((error, stackTrace) {
      setLoading(false);
      Utils.flushBarErrorLoginMessage(error.toString(), context);
      if (kDebugMode) {
        print(error.toString());
      }
    });
  }



  Future<void> signUpApi(dynamic data, BuildContext context) async {
    setSignUpLoading(true);

    try {
      dynamic value = await _myRepo.signUpApi(data);
      setSignUpLoading(false);

      // Successful response handling
      Utils.flushBarSuccessMessage('SignUp Successfully', context);
      // Navigator.pushNamed(context, RoutesName.login);

      if (kDebugMode) {
        print(value.toString());
      }
    } catch (error) {
      setSignUpLoading(false);
      Utils.flushBarErrorMessage('Error: $error', context);
      if (kDebugMode) {
        print('Error: $error');
      }
    }
  }






}