import 'package:c9_app/res/color.dart';
import 'package:c9_app/view/widgets/header_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ErrorLogOutScreen extends StatefulWidget {
  final double screenHeight;
  final double screenWidth;
  final String errorMessage;
  final String subMessage;
  final IconData icon;
  final String buttonText;
  final VoidCallback onButtonPressed;

  const ErrorLogOutScreen({
    required this.screenHeight,
    required this.screenWidth,
    this.errorMessage = 'Something Went Wrong',
    this.subMessage = 'Please logout & try again',
    this.icon = CupertinoIcons.exclamationmark,
    this.buttonText = 'Logout',
    required this.onButtonPressed,
    Key? key,
  }) : super(key: key);

  @override
  State<ErrorLogOutScreen> createState() => _ErrorLogOutScreenState();
}

class _ErrorLogOutScreenState extends State<ErrorLogOutScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.screenHeight,
      width: widget.screenWidth,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Container(
            padding: EdgeInsets.symmetric(horizontal: widget.screenWidth * 0.1),
            width: widget.screenWidth,
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    color: Colors.red,
                    size: 45,
                  ),
                  SizedBox(height: widget.screenHeight * 0.02),
                  AutoSizeText(
                    widget.errorMessage,
                    style: TextStyle(
                      fontSize:20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: widget.screenHeight * 0.01),
                  Text(
                    widget.subMessage,
                    style: TextStyle(
                      fontSize:15,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: widget.screenHeight * 0.04),
          Container(
            height: 35,
            width: 100,
            decoration: BoxDecoration(
              color:AppColors.navButtonColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  offset: Offset(0, 2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: widget.onButtonPressed,
              child: AutoSizeText(
                widget.buttonText,
                style: TextStyle(fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:  AppColors.navButtonColor,
                foregroundColor: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          SizedBox(height: widget.screenHeight * 0.2),
        ],
      ),
    );
  }
}
