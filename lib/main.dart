import 'dart:io';
import 'package:c9_app/Modules/StaffModule/Assignment/assignment_Action/WeekDataByStaff/weekdataStaffs_new.dart';
import 'package:c9_app/Modules/StaffModule/GoogleMap/googleMapStyaffTest.dart';
import 'package:c9_app/provider/PermisionProvider.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/utils/routes/routes.dart';
import 'package:c9_app/view_model/auth_view_model.dart';
import 'package:c9_app/view_model/services/rolebasedmodel/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';
import 'package:workmanager/workmanager.dart';
import 'DarkAndLightTheme/theme_provider.dart';
import 'utils/routes/routes_name.dart';

/** **/

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HttpOverrides.global = MyHttpOverrides();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: AppColors.navColor,
    statusBarColor: AppColors.navColor,
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation .portraitDown,
  ]);
  await Upgrader.clearSavedSettings();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  Workmanager().registerOneOffTask(
    '1',
    'simpleTask',
    inputData: <String, dynamic>{'key': 'value'},
  );

  ThemeProvider themeProvider = ThemeProvider();
  themeProvider.initializeTheme();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        // ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => PermissionProvider()),
        // ChangeNotifierProvider(create: (_) => TimerProviderNew()),
        ChangeNotifierProvider(create: (_) => TimerProviderAgain()),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => themeProvider,),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: MyThemes.lightTheme,
            darkTheme: MyThemes.darkTheme,
            initialRoute: RoutesName.splash,
            onGenerateRoute: Routes.generateRoute,
          );
        },
      ),
    ),
  );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

