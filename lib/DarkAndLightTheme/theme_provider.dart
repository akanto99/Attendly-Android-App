import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// class ThemeProvider extends ChangeNotifier{
//   ThemeMode themeMode= ThemeMode.light;
//   bool get isDarkMode =>themeMode==ThemeMode.dark;
//
//   void toggleTheme(bool isOn){
//     themeMode= isOn ? ThemeMode.dark: ThemeMode.light;
//     notifyListeners();
//   }
//
// }
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> toggleTheme(bool isOn) async {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    // Save the selected theme mode to shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isOn);
  }

  Future<void> initializeTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class MyThemes{
  static final darkTheme= ThemeData(
    // scaffoldBackgroundColor: Colors.grey.shade900,
    scaffoldBackgroundColor: Colors.black,
    colorScheme: ColorScheme.dark(),
    primaryColor: Colors.black,
    iconTheme: IconThemeData(color: Colors.white,opacity: 0.8)

  );


  static final lightTheme= ThemeData(
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.light(),
      primaryColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.black,opacity: 0.8)
  );
}