
import 'package:c9_app/Modules/StaffModule/DashBoard/staff_navigationScreen.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/view/widgets/header_widgets.dart';
import 'package:flutter/material.dart';

class FullScreenImageStaff extends StatefulWidget {
  final String imageUrl;

  FullScreenImageStaff({required this.imageUrl});

  @override
  State<FullScreenImageStaff> createState() => _FullScreenImageStaffState();
}

class _FullScreenImageStaffState extends State<FullScreenImageStaff> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          body: ResPonsiveUi(
            mobile: body(),
            desktop: body(),
            tablet: body(),
          )),
    );
  }

  Widget body() {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: screenHeight * 0.085,
            width: screenWidth*.98,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: HeaderRow(Icons.arrow_back)),
                GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>StaffCurveNabBar()));
                    },
                    child: HeaderRow(Icons.home)),
              ],
            ),
          ),
          Container(
            height: screenHeight * 0.85,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Center(
                child: Hero(
                  tag: 'imageHero',
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'images/default_image.png', // Path to your default image
                        fit: BoxFit.contain,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

