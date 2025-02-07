import 'package:c9_app/Modules/ClientModule/client_screen.dart';
import 'package:c9_app/Modules/ClientModule/pages/ClientStaffDirectory/client_staff_directory.dart';
import 'package:c9_app/Modules/StaffModule/DashBoard/dashBoard.dart';
import 'package:c9_app/Modules/StaffModule/DashBoard/staff_navigationScreen.dart';
import 'package:c9_app/Modules/StaffModule/GoogleMap/googleMapStyaffTest.dart';
import 'package:c9_app/utils/routes/routes_name.dart';
import 'package:c9_app/view/splash&login/Registration/clientRegistration_new.dart';
import 'package:c9_app/view/splash&login/Registration/staffRegistration_new.dart';
import 'package:c9_app/view/splash&login/login_view.dart';
import 'package:c9_app/view/splash&login/splash_view.dart';
import 'package:flutter/material.dart';

import '../../Modules/StaffModule/Profile/staff_profilev2.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.splash:
        return MaterialPageRoute(builder: (BuildContext context) => const SplashView());

       //////////////////////////////////////////
      // case RoutesName.homeFotter:
      //   return MaterialPageRoute(builder: (BuildContext context) => const FreAskQuestions());
      case RoutesName.login:
        return MaterialPageRoute(builder: (BuildContext context) => const LoginView());

        case RoutesName.staffDashBoard:
        return MaterialPageRoute(builder: (BuildContext context) => const StaffDashBoars());




       // NEW------------------------------------------------
    //SignupView for Client and Staff
      case RoutesName.clientRegistrationNew:
        return MaterialPageRoute(builder: (BuildContext context) => const ClientRegistrationNew());
      // case RoutesName.staffRegistrationNew:
      //   return MaterialPageRoute(builder: (BuildContext context) => const StaffRegistrationNew());





    //Client Admin Panel
      case RoutesName.clientVies:
        return MaterialPageRoute(builder: (BuildContext context) => const ClientCurveNabBar());
      case RoutesName.clientStaffDirectoryViews:
        return MaterialPageRoute(builder: (BuildContext context) => const ClientStaffDirectory());


    //Staff Admin Panel
    case RoutesName.staffVies:
        return MaterialPageRoute(builder: (BuildContext context) =>  StaffCurveNabBar());

      case RoutesName.googlemapsStaffTest:
        return MaterialPageRoute(builder: (BuildContext context) =>  GoogleMapsStaffTest());





      case RoutesName.profilepage:
        return MaterialPageRoute(builder: (BuildContext context) =>  StaffProfile());




      default:
        return _errorRoute();






    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return const Scaffold(
        body: Center(
          child: Text('No route defined'),
        ),
      );
    });
  }
}
