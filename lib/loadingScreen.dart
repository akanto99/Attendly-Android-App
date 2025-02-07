import 'package:c9_app/res/color.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return Center(
        child: Container(
        height: screenHeight * 0.055,
        width: screenWidth * 0.15,
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

        child: Center(
          child: SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(color: AppColors.navButtonColor,)),
        )));
  }
}
