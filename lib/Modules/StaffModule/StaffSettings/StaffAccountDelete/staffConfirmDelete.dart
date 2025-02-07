import 'dart:convert';

import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/utils/routes/routes_name.dart';
import 'package:c9_app/utils/utils.dart';
import 'package:c9_app/view/splash&login/ResetPassword/resetPassword.dart';
import 'package:c9_app/view/splash&login/login_view.dart';
import 'package:c9_app/view/widgets/header_widgets.dart';
import 'package:c9_app/view_model/services/rolebasedmodel/user_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart'as https;

class ConfirmDeleteStaff extends StatefulWidget {
  const ConfirmDeleteStaff({super.key});

  @override
  State<ConfirmDeleteStaff> createState() => _ConfirmDeleteStaffState();
}

class _ConfirmDeleteStaffState extends State<ConfirmDeleteStaff> {

  TextEditingController  _OTPController= TextEditingController();
  bool isLoading = false;

  Future<void> _otpPost() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String _token = prefs.getString('token') ?? '';

      final String apiUrl =
          '${AppUrl.baseUrl}/api/app/my-digital-accounts/account-deletion-process/delete?otp=${_OTPController.text}';
      print(apiUrl);
      final response = await https.get(Uri.parse(apiUrl), headers: {
        'Authorization': 'Bearer $_token',
      });

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });

        // Parse the JSON response
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Access the message field
        String message = jsonResponse['message'];

        // Display the message
        Utils.flushBarSuccessMessage(message, context);
        prefs.remove('id');
        prefs.remove('token');
        prefs.remove('message');
        prefs.remove('email');
        prefs.remove('password');

        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginView()));
        print('Account Deletion Successful');
        print(await response.body);
      } else {
        setState(() {
          isLoading = false;
        });
        Utils.flushBarErrorMessage("Something went wrong", context);
        throw Exception('Failed to delete account');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      print('Error during account deletion: $e');
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
    final userPrefernece = Provider.of<UserViewModel>(context);
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
                      "OTP Confirmation",
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
                  color:AppColors.navOpacity,
                  shape: BoxShape.circle,
                ),
                child:Center(
                  child: Container(
                    height: screenHeight*0.16,
                    width: screenWidth*0.35,
                    decoration: BoxDecoration(
                      color:AppColors.navColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        height: screenHeight*0.07,
                        width: screenWidth*0.18,

                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage("images/staff/settingsIcon/acountSettings/otpimg.png",)
                            )
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.05,),
              Text("Delete Your Account",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),),
              SizedBox(height: screenHeight * 0.013,),
              Text("We will send 6 digit OTP to your email."),
              Text("If confirmed, your ID will be permanently deleted."),
              SizedBox(height: screenHeight * 0.03,),
              Padding(
                padding: const EdgeInsets.only(left:15.0),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("OTP")),
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
                      controller: _OTPController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'OTP',
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

                  // if (_otpPost()==200){
                  //   userPrefernece.remove().then((value) {
                  //     Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginView()));
                  //   });
                  // }
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
                        : Text("Confirmation", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1,),
                    ),
                  ),
                ),
              ),
            ]),
      ),
    );
  }}
