import 'dart:async';
import 'dart:io';
import 'package:c9_app/DarkAndLightTheme/theme_provider.dart';
import 'package:c9_app/Modules/ClientModule/pages/ClientMap/clientMapScreen.dart';
import 'package:c9_app/Modules/ClientModule/pages/ClientStaffDirectory/client_staff_directory.dart';
import 'package:c9_app/Modules/ClientModule/pages/DepartMent/DepartmentListTabs.dart';
import 'package:c9_app/Modules/ClientModule/pages/Profile_&_Setting/ClientSettings.dart';
import 'package:c9_app/Modules/ClientModule/pages/Request/RequestTabBar.dart';
import 'package:c9_app/res/color.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

class ClientCurveNabBar extends StatefulWidget {
  final int initialIndex;
  const ClientCurveNabBar({super.key, this.initialIndex =2});

  @override
  State<ClientCurveNabBar> createState() => _ClientCurveNabBarState();
}

class _ClientCurveNabBarState extends State<ClientCurveNabBar> with TickerProviderStateMixin {
  int _currentIndex = 2;

  late AnimationController _bounceController;

  // List of pages
  final List<Widget> _pages = [
    DepartMentTabScreenNew(),
    // DepartMent(),
    // DeviceInfoScreen(),
    // RequestStaff(),
    RequestTabScreenNew(),
    // TabletResponsive(),
    ClientStaffDirectory(),
    GoogleMapsAllListClient(),
    ClientSettings()
    // SettingsPage()

  ];

  final List<String> _labels = [ 'Docs', 'Req','Home', 'Map', 'Settings',];
  final List<String> _imagePaths = [

    'images/staff/document.png',
    'images/staff/request.png',
    'images/staff/home.png',
    'images/staff/googlemap.png',
    'images/staff/settings.png',

  ];
  // Initialize the bounce animation controller
  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _currentIndex = widget.initialIndex;
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width * 1;
    double screenHeight = MediaQuery.of(context).size.height * 1;
    return UpgradeAlert(
      canDismissDialog: false,
      showLater: false,
      showIgnore: false,
      showReleaseNotes: false,
      upgrader: Upgrader(),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            final value = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return Theme(
                    data: ThemeData(
                      dialogBackgroundColor: Colors.white,
                    ),
                    child: AlertDialog(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.02,
                        vertical: screenHeight * 0.02,
                      ),
                      insetPadding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.1,
                        vertical: screenHeight * 0.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      content: Text(
                        "  Are you sure you want to exit ?",
                        style: TextStyle(fontSize: 18),
                      ),
                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                exit(0);
                              },
                              child: Container(
                                width: screenWidth * 0.2,
                                padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.011,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.navButtonColor,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Center(
                                  child: Text(
                                    'Yes',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: screenWidth * 0.020,
                            ),
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(false),
                              child: Container(
                                width: screenWidth * 0.2,
                                padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.011,
                                  // horizontal: screenWidth * 0.001
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.navOpacity,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Center(
                                  child: Text(
                                    'No',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                });
            if (value != null) {
              return Future.value(value);
            } else {
              return Future.value(false);
            }
          },child: Scaffold(
          body: _pages[_currentIndex],
          bottomNavigationBar: Container(
            height: screenHeight * 0.08,
            color: AppColors.navColor, // Set background color of the bottom bar
            padding: EdgeInsets.symmetric(horizontal: 15,),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                bool isSelected = _currentIndex == index;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _currentIndex = index;
                      _bounceController.reset();
                      _bounceController.forward();
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _bounceController,
                        builder: (context, child) {
                          double scale = isSelected
                              ? 1.3 + _bounceController.value * 0.1
                              : 1.0;
                          return Transform.scale(
                            scale: scale,
                            child: child,
                          );
                        },
                        child: Container(
                          width: screenWidth*0.14,
                          child: Image.asset(
                            _imagePaths[index],
                            height: 25,
                            width: 26,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        _labels[index],
                        style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white,
                            fontSize:isSelected ? 12:10,
                            fontWeight: isSelected ? FontWeight.bold: FontWeight.normal
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
        ),
      ),
    );
  }
}

