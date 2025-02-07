import 'package:c9_app/Modules/StaffModule/DashBoard/staff_navigationScreen.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/view/widgets/header_widgets.dart';
import 'package:flutter/material.dart';


class NoNotification extends StatefulWidget {
  const NoNotification({Key? key}) : super(key: key);

  @override
  State<NoNotification> createState() => _NoNotificationState();
}

class _NoNotificationState extends State<NoNotification> {
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
                child: HeaderRow(Icons.arrow_back),
              ),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StaffCurveNabBar()),
                  );
                },
                child: HeaderRow(Icons.home_filled),
              ),
            ],
          ),
        ),
        SizedBox(height: screenHeight * 0.013),
        Container(
          height: screenHeight*0.75,
          width: screenWidth,
          child: Center(
            child: Text("No Notification..."),
          ),
        ),
      ],
    );
  }
}
