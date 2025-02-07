import 'package:c9_app/res/color.dart';
import 'package:flutter/material.dart';

class HeaderRow extends StatelessWidget {
  final IconData iconData;

  const HeaderRow(this.iconData, {super.key});

  @override
  Widget build(BuildContext context) {
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
            offset: const Offset(0, 2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(iconData, color: AppColors.navButtonColor), // Update this color to match your theme
    );
  }
}
