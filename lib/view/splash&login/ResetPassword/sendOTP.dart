import 'dart:convert';

import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/utils/utils.dart';
import 'package:c9_app/view/splash&login/ResetPassword/resetPassword.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart'as https;

class SendOTP extends StatefulWidget {
  const SendOTP({super.key});

  @override
  State<SendOTP> createState() => _SendOTPState();
}

class _SendOTPState extends State<SendOTP> {

  TextEditingController  _emailController= TextEditingController();
  bool isLoading = false;



  Future<void> _otpPost() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';

    try {
      String apiUrl = '${AppUrl.baseUrl}/api/app/password/reset';
      var request = https.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers.addAll({
        'Authorization': 'Bearer $_token',
      });

      request.fields['email'] = _emailController.text.toString();

      var response = await request.send();
      var responseString = await response.stream.bytesToString();

      // Print the full response
      print('Response status: ${response.statusCode}');
      print('Response body: $responseString');

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        Utils.snackBar("OTP sent to your email", context);
        Future.delayed(Duration(seconds: 2), () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPassword(email: _emailController.text),),);
        });
      } else if (response.statusCode == 422) {
        setState(() {
          isLoading = false;
        });
        // Validation failed
        Map<String, dynamic> errorJson = json.decode(responseString);
        if (errorJson.containsKey('data')) {
          Map<String, dynamic> data = errorJson['data'];
          if (data.containsKey('email')) {
            List<String> emailErrors = data['email'].cast<String>();
            Utils.flushBarErrorMessage(emailErrors.join('\n'), context);
          } else {
            Utils.flushBarErrorMessage("Email validation error.", context);
          }
        } else {
          Utils.flushBarErrorMessage("Validation failed.", context);
        }
      } else {
        setState(() {
                  isLoading = false;
                });
                Utils.flushBarErrorMessage("Something went wrong", context);
                print('Failed to register. Status code: ${response.statusCode}');
                print(response.reasonPhrase);

              }
    } catch (e) {
      print('Error during registration: $e');
      setState(() {
        isLoading = false;
      });
      Utils.flushBarErrorMessage("An error occurred during registration.", context);
    }
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: ResPonsiveUi(
            mobile: body(),
            desktop: body(),
            tablet: body(),
          ),
        ),
      ),
    );
  }

  Widget body() {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Column(
            children: [
              SizedBox(height: screenHeight * 0.013,),
              Align(
                alignment: Alignment.topCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                        onTap: () {Navigator.pop(context);},
                        child: HeaderRow(Icons.arrow_back)),
                    Text(
                      "Forgot Password",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      height: screenHeight * 0.055, width: screenWidth * 0.12,
                      child: Icon(Icons.home,color: Colors.transparent,),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.1,),
              Container(
                height: screenHeight*0.2,
                width: screenWidth*0.4,
                decoration: BoxDecoration(
                  color: AppColors.navOpacity,
                    shape: BoxShape.circle,
                ),
                child:Center(
                  child: Container(
                    height: screenHeight*0.16,
                    width: screenWidth*0.35,
                    decoration: BoxDecoration(
                      color: AppColors.navButtonColor,
                      // color: Color(0xffF19951),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        height: screenHeight*0.07,
                        width: screenWidth*0.18,
      
                        decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("images/staff/settingsIcon/acountSettings/emailForgot.png",)
                            )
                        ),
                      ),
                    ),
                  ),
                ),
              ),
               SizedBox(height: screenHeight * 0.05,),
              Text("Find Your Account",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),),
              SizedBox(height: screenHeight * 0.013,),
              Text("Enter your email address for the verification process."),
              Text("We will send 6 digit OTP to your email."),
              SizedBox(height: screenHeight * 0.03,),
              Padding(
                padding: const EdgeInsets.only(left:15.0),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Email address")),
              ),
              SizedBox(height: screenHeight * 0.013,),
              Container(
                height: screenHeight* 0.06,
                width: screenWidth*0.90,
                decoration: BoxDecoration(
                  color: Color(0xffEAEAEA),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: 'email',
                        hintStyle: TextStyle(color: Colors.transparent),
                        alignLabelWithHint: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.1,),
              GestureDetector(
                onTap: (){
                  _otpPost();
                },
                child: Container(
                  height: screenHeight * 0.055,
                  width: screenWidth * 0.55,
                  decoration: BoxDecoration(
                    color:AppColors.navButtonColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        offset: Offset(0, 2),
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: isLoading
                        ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white,)) // Show loading indicator if isLoading is true
                        : Text("Send", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1,),
                    ),
                  ),
                ),
              ),
        ]),
      ),
    );
  }

  Widget HeaderRow(IconData iconData) {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
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
      child: Icon(iconData,color: AppColors.navButtonColor),
    );
  }
}
