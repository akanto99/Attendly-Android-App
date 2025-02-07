import 'package:url_launcher/url_launcher.dart';
import 'package:c9_app/Modules/ClientModule/client_screen.dart';
import 'package:c9_app/Modules/StaffModule/DashBoard/staff_navigationScreen.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

class NoNotificationClient extends StatefulWidget {
  const NoNotificationClient({Key? key}) : super(key: key);

  @override
  State<NoNotificationClient> createState() => _NoNotificationClientState();
}

class _NoNotificationClientState extends State<NoNotificationClient> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ResPonsiveUi(
          mobile: body(context),
          desktop: body(context),
          tablet: body(context),
        ),
      ),
    );
  }

  Widget body(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        SizedBox(height: screenHeight * 0.013),
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: HeaderRow(Icons.arrow_back, context),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ClientCurveNabBar()),
                  );
                },
                child: HeaderRow(Icons.home_filled, context),
              ),
            ],
          ),
        ),
        SizedBox(height: screenHeight * 0.013),
        Container(
          height: screenHeight * 0.75,
          width: screenWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child:Text("No Notification...")
          ),
        ),
      ],
    );
  }

  Widget HeaderRow(IconData iconData, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.055,
      width: screenWidth * 0.12,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            offset: Offset(0, 2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        iconData,
        color: AppColors.navButtonColor,
      ),
    );
  }
}
