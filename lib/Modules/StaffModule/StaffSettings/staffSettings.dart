import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:c9_app/DarkAndLightTheme/theme_provider.dart';
import 'package:c9_app/Modules/ClientModule/pages/noInternetConnectionWidget.dart';
import 'package:c9_app/Modules/StaffModule/DashBoard/staff_navigationScreen.dart';
import 'package:c9_app/Modules/StaffModule/StaffSettings/aboutScreenStaff.dart';
import 'package:c9_app/Modules/StaffModule/StaffSettings/noNotification.dart';
import 'package:c9_app/Modules/StaffModule/StaffSettings/permissionSettingsScreen.dart';
import 'package:c9_app/loadingScreen.dart';
import 'package:c9_app/model/profileModel/profileapi_model.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/utils/routes/routes_name.dart';
import 'package:c9_app/view/widgets/error_logout.dart';
import 'package:c9_app/view/widgets/header_widgets.dart';
import 'package:c9_app/view_model/services/rolebasedmodel/user_view_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as https;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Profile/staff_profilev2.dart';

class StaffSettings extends StatefulWidget {
  const StaffSettings({super.key});

  @override
  State<StaffSettings> createState() => _StaffSettingsState();
}

class _StaffSettingsState extends State<StaffSettings>with WidgetsBindingObserver{
  String _urlPrivacy = "https://c9.excelengine.com/privacy-policy/";
  String _urlTerms = "https://c9.excelengine.com/terms-conditions/";

  late Future<ProfileApiModel?> _userProfileFuture;

  bool _showNoInternetConnectionMessage = false;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _userProfileFuture = fetchData();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result)async{
      bool hasInternet = await _hasInternetConnection();
      setState(() {
        _showNoInternetConnectionMessage = (result == ConnectivityResult.none || !hasInternet);
      });
    });

  }
  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription.cancel(); // Cancel subscription

    super.dispose();
  }
  Future<ProfileApiModel?> fetchData() async {
    // first check user's network connectivity
    var connectivityResult = await (Connectivity().checkConnectivity());
    bool hasInternet = await _hasInternetConnection();

    if(connectivityResult == ConnectivityResult.none || !hasInternet){
      // show No internet connection
      setState(() {
        _showNoInternetConnectionMessage = true;
      });
      return null;
    }else{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String _token = prefs.getString('token') ?? '';

      final String apiUrl = '${AppUrl.baseUrl}/api/app/profile';
      final response = await https.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData == null) {
          throw Exception('Response data is null');
        }

        return ProfileApiModel.fromJson(responseData);
      } else {
        throw Exception(
            'Failed to fetch user data. Status code: ${response.statusCode}');
      }
    }
  }

  bool showText = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: _showNoInternetConnectionMessage ? Colors.red : AppColors.navColor,
    ));
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          body:_showNoInternetConnectionMessage ? NoInternetConnection(): ResPonsiveUi(
            mobile: body(),
            desktop: body(),
            tablet: body(),
          )),
    );
  }

  Widget body() {
    final userPrefernece = Provider.of<UserViewModel>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;

    return SingleChildScrollView(
      child: FutureBuilder<ProfileApiModel?>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: screenHeight * 0.9,
              width: screenWidth,
              color: AppColors.whiteColor,
              child: LoadingScreen(),
            );
          } else if (snapshot.hasError) {
            return Column(
              children: [
                SizedBox(height:screenHeight * 0.013),
                Padding(
                  padding: const EdgeInsets.only(left:10.0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>StaffCurveNabBar()));
                          },
                          child: HeaderRow(Icons.arrow_back))),
                ),
                SizedBox(height:screenHeight * 0.013),
                ErrorLogOutScreen(
                  screenHeight: screenHeight*0.8,
                  screenWidth: screenWidth,
                  errorMessage: 'Oops! Something went wrong.',
                  subMessage: 'Try logging out and back in.',
                  icon: CupertinoIcons.exclamationmark_circle,
                  buttonText: 'Logout',
                  onButtonPressed: () {
                    userPrefernece.remove().then((value){
                      Navigator.pushNamed(context, RoutesName.login);
                    });
                  },
                ),
              ],
            );
            // return Text("${snapshot.error}");
          } else if (!snapshot.hasData) {
            return Column(
              children: [
                SizedBox(height: screenHeight*0.013,),
                Padding(
                  padding: const EdgeInsets.only(left:5.0,right: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => StaffCurveNabBar()));
                          },
                          child: HeaderRow(Icons.arrow_back)),
                      Container(
                        height: screenHeight * 0.14,
                        width: screenWidth * 0.31,
                        decoration: BoxDecoration(color: Colors.white
                        ),
                        child: Center(
                          child: Container(
                              alignment: Alignment.center,
                              child: Image.asset(
                                "images/c9.png",
                                height: screenHeight * 0.13,
                                width: screenWidth * 0.29,
                                color: AppColors.navColor,
                              )),
                        ),
                      ),
                      Container(
                        height: screenHeight * 0.055,
                        width: screenWidth * 0.12,
                        child: Icon(
                          Icons.home,
                          color: Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight*0.013,),
                Center(child: Text('No user data found.')),
              ],
            );
          } else {
            final ProfileApiModel profileData = snapshot.data!;
            final Data profile = profileData.data;
            dynamic peopleId = profileData.data.peopleId;
            return Column(
              children: [
                //Header

                SizedBox(
                  height: screenHeight * 0.013,
                ),
                Padding(
                  padding: const EdgeInsets.only(left:5.0,right: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => StaffCurveNabBar()));
                          },
                          child: HeaderRow(Icons.arrow_back)),
                      Container(
                        height: screenHeight * 0.14,
                        width: screenWidth * 0.31,
                        decoration: BoxDecoration(color: Colors.white
                            ),
                        child: Center(
                          child: Container(
                              alignment: Alignment.center,
                              child: Image.asset(
                                "images/c9Profile.png",
                                height: screenHeight * 0.13,
                                width: screenWidth * 0.29,
                                color: AppColors.navColor,
                              )),
                        ),
                      ),
                      Container(
                        height: screenHeight * 0.055,
                        width: screenWidth * 0.12,
                        child: Icon(
                          Icons.home,
                          color: Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Account",
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                    ),
                    SizedBox(
                      height: screenHeight * 0.013,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (peopleId != null) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => StaffProfile()));
                        } else {
                          Fluttertoast.showToast(
                            msg: "You are not registered in My Digital. Please contact with Admin",
                            backgroundColor: Colors.black,
                            textColor: Colors.white,
                          );
                        }
                      },
                      child: Container(
                        width: screenWidth *
                            0.95, // Set width to take up all available horizontal space
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey,
                            width: 0.2,
                          ),
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: screenHeight * 0.009),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(width: 10),
                                Container(
                                  height: 65,
                                  width: 65,
                                  child: CircleAvatar(
                                    backgroundColor: AppColors.navOpacity,
                                    backgroundImage: NetworkImage(
                                        "${AppUrl.staffDriver}/${profile.image}"),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${profile.firstName ?? "no"} ${profile.lastName ?? "name"}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 20),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "${profile.email}", style: TextStyle(fontSize: 13), softWrap: true, overflow: TextOverflow.visible,
                                            ),
                                          ),
                                          // Padding(
                                          //   padding: const EdgeInsets.only(right: 5.0),
                                          //   child: Icon(Icons.note_alt_outlined,size: 25,),
                                          // ),
                                          Padding(
                                            padding: EdgeInsets.only(right: 10),
                                            child: Image.asset(
                                              "images/staff/eidt.png",
                                              height: 25,
                                              width: 25,
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.009),
                          ],
                        ),
                      ),
                    ),
                    // Divider(height: 1,),
                    SizedBox(
                      height: screenHeight * 0.013,
                    ),
                  ],
                ),

                //General
                Padding(
                    padding: const EdgeInsets.only(bottom: 10.0, left: 15),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "General",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 20),
                      ),
                    )),
                Container(
                  width: screenWidth * 0.95,
                  decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      // color:themeProvider.isDarkMode ? AppColors.blackOpacity : AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.greyOpacity,
                          offset: Offset(0, 2),
                          blurRadius: 5,
                          spreadRadius: 2,
                        ),
                      ]),
                  child: Column(
                    children: [
                      SizedBox(
                        height: screenHeight * 0.013,
                      ),
                      GestureDetector(
                        onTap: () {
                          final String selectedEmail =
                              profile.email ?? "no email";
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PermissonSettingsScreen(
                                  passEmail: selectedEmail),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 10),
                          child: Container(
                            width: screenWidth * 0.95,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.5),
                                width: 0.2,
                              ),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: screenHeight * 0.009,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 5.0, right: 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            height: 45,
                                            width: 45,
                                            decoration: BoxDecoration(
                                              color: Color(0xffFFF9DD)
                                                  .withOpacity(0.5),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              image: DecorationImage(
                                                image: AssetImage(
                                                    "images/staff/settingsIcon/setting.png"),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Account Settings",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 18),
                                              ),
                                              Text("Privacy, Security ..."),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: screenHeight * 0.009,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.013,
                      ),
                      GestureDetector(
                        onTap: () {
                          // Utils.showSnackBar(context, 'working on it...');

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NoNotification()));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 10),
                          child: Container(
                            width: screenWidth * 0.95,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.grey.withOpacity(0.5),
                                    width: 0.2)),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: screenHeight * 0.009,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 5.0, right: 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            height: 45,
                                            width: 45,
                                            decoration: BoxDecoration(
                                                color: Color(0xffFFF9DD)
                                                    .withOpacity(0.5),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                image: DecorationImage(
                                                  image: AssetImage(
                                                      "images/staff/settingsIcon/noti.png"),
                                                )),
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Notification",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 18),
                                              ),
                                              Text("App Updates",
                                                  style:
                                                      TextStyle(fontSize: 12))
                                            ],
                                          ),
                                        ],
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: screenHeight * 0.009,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.013,
                      ),
                      GestureDetector(
                        onTap: _launchTerms,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 10),
                          child: Container(
                            width: screenWidth * 0.95,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.grey.withOpacity(0.5),
                                    width: 0.2)),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: screenHeight * 0.009,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 5.0, right: 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            height: 45,
                                            width: 45,
                                            decoration: BoxDecoration(
                                                color: Color(0xffFFF9DD)
                                                    .withOpacity(0.5),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                image: DecorationImage(
                                                  image: AssetImage(
                                                      "images/staff/settingsIcon/terms.png"),
                                                )),
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Terms & Conditions",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 18),
                                              ),
                                              Text(
                                                  "General terms and conditions",
                                                  style:
                                                      TextStyle(fontSize: 12))
                                            ],
                                          ),
                                        ],
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: screenHeight * 0.009,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.013,
                      ),
                      GestureDetector(
                        onTap: _launchPrivacy,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 10),
                          child: Container(
                            width: screenWidth * 0.95,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.grey.withOpacity(0.5),
                                    width: 0.2)),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: screenHeight * 0.009,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 5.0, right: 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            height: 45,
                                            width: 45,
                                            decoration: BoxDecoration(
                                                color: Color(0xffFFF9DD)
                                                    .withOpacity(0.5),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                image: DecorationImage(
                                                  image: AssetImage(
                                                      "images/staff/settingsIcon/privacy.png"),
                                                )),
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Privacy Policy",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 18),
                                              ),
                                              Text(
                                                  "Application's Privacy Policy",
                                                  style:
                                                      TextStyle(fontSize: 12))
                                            ],
                                          ),
                                        ],
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: screenHeight * 0.009,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.013,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AboutUsStaff()));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 10),
                          child: Container(
                            width: screenWidth * 0.95,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.grey.withOpacity(0.5),
                                    width: 0.2)),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: screenHeight * 0.009,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 5.0, right: 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            height: 45,
                                            width: 45,
                                            decoration: BoxDecoration(
                                                color: Color(0xffFFF9DD)
                                                    .withOpacity(0.5),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                image: DecorationImage(
                                                  image: AssetImage(
                                                      "images/staff/settingsIcon/about.png"),
                                                )),
                                          ),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "About Us",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 18),
                                              ),
                                              Text("History, Contact Info",
                                                  style:
                                                      TextStyle(fontSize: 12))
                                            ],
                                          ),
                                        ],
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: screenHeight * 0.009,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.013,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.013,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0, left: 15),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Feedback",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 20),
                      )),
                ),

                Container(
                  width: screenWidth * 0.95,
                  decoration: BoxDecoration(
                      color: themeProvider.isDarkMode
                          ? AppColors.blackOpacity
                          : AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: themeProvider.isDarkMode
                              ? AppColors.blackOpacity
                              : AppColors.greyOpacity,
                          offset: Offset(0, 2),
                          blurRadius: 5,
                          spreadRadius: 2,
                        ),
                      ]),
                  child: Column(
                    children: [
                      //FeedBack
                      SizedBox(
                        height: screenHeight * 0.013,
                      ),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Coming soon!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          // Navigator.push(context, MaterialPageRoute(builder: (context)=> ReportABugStaff()));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 10),
                          child: Container(
                            width: screenWidth * 0.95,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.grey.withOpacity(0.5),
                                    width: 0.2)),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: screenHeight * 0.009,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 5.0, right: 5),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 45,
                                        width: 45,
                                        decoration: BoxDecoration(
                                            color: Color(0xffFFF9DD)
                                                .withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  "images/staff/settingsIcon/report.png"),
                                            )),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        "Report A Bug",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 18),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: screenHeight * 0.009,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.013,
                      ),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Coming soon!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          // Navigator.push(context, MaterialPageRoute(builder: (context)=> SendAfeedBackStaff()));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 10),
                          child: Container(
                            width: screenWidth * 0.95,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.grey.withOpacity(0.8),
                                    width: 0.2)),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: screenHeight * 0.009,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 5.0, right: 5),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 45,
                                        width: 45,
                                        decoration: BoxDecoration(
                                            color: Color(0xffFFF9DD)
                                                .withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  "images/staff/settingsIcon/send.png"),
                                            )),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        "Send A FeedBack",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 18),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: screenHeight * 0.009,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.013,
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: screenHeight * 0.013,
                ),
                Container(
                  width: screenWidth * 0.4,
                  height: screenHeight * 0.05,
                  child: ElevatedButton(
                    onPressed: () {
                      userPrefernece.remove().then((value) {
                        Navigator.pushNamed(context, RoutesName.login);
                      });
                    },
                    child: AutoSizeText(
                      'Logout',
                      style: TextStyle(
                        fontSize: 18,
                        letterSpacing: 2,
                        color: AppColors.whiteColor,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navColor,
                      foregroundColor: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
              ],
            );
          }
        },
      ),
    );
  }

  void _launchPrivacy() async {
    if (!await launch(_urlPrivacy)) throw 'Couldnot launch $_urlPrivacy';
  }

  void _launchTerms() async {
    if (!await launch(_urlTerms)) throw 'Couldnot launch $_urlTerms';
  }
}
