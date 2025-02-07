import 'package:c9_app/model/user_model.dart';
import 'package:c9_app/utils/routes/routes_name.dart';
import 'package:c9_app/view_model/services/rolebasedmodel/user_view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


class SplashServices {


  Future<UserModel> getUserDate() => UserViewModel().getUser();


  void checkAuthentication(BuildContext context)async{

    getUserDate().then((value)async{

      print(value.token.toString());

      if(value.token.toString() == 'null' || value.token.toString() == ''){
        await Future.delayed(Duration(milliseconds: 1500 ));
        Navigator.pushNamed(context, RoutesName.login);
      }
      else if(value.role.toString() == 'clients' ){
        await  Future.delayed(Duration(milliseconds: 1500 ));
        Navigator.pushNamed(context, RoutesName.clientVies);
      }
      else if(value.role.toString() == 'staff' ){
        await  Future.delayed(Duration(milliseconds: 1500 ));
        Navigator.pushNamed(context, RoutesName.staffVies);
      }
      else if(value.role.toString() == 'admin' ){
        await  Future.delayed(Duration(milliseconds: 1500 ));
        Navigator.pushNamed(context, RoutesName.home);
      }

    }).onError((error, stackTrace){
      if(kDebugMode){
        print(error.toString());
      }
    });

  }



}

