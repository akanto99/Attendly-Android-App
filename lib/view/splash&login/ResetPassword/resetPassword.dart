import 'dart:convert';

import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/utils/utils.dart';
import 'package:c9_app/view/splash&login/login_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as https;

class ResetPassword extends StatefulWidget {
  final String email;
  const ResetPassword({super.key, required this.email});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {

  TextEditingController  _otpController= TextEditingController();
  TextEditingController  _emailController= TextEditingController();
  TextEditingController  _passwordController= TextEditingController();
  TextEditingController  _REpasswordController= TextEditingController();


  bool isLoading = false;


  @override
  void initState() {
     super.initState();
    _emailController.text = widget.email; // Auto-fill


  }

  // Future<void> _ChangePassword() async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String _token = prefs.getString('token') ?? '';
  //
  //   try {
  //     String apiUrl = '${AppUrl.baseUrl}/api/app/password/reset-submit';
  //     var request = https.MultipartRequest('POST', Uri.parse(apiUrl));
  //     request.headers.addAll({
  //       'Authorization': 'Bearer $_token',
  //     });
  //
  //     request.fields['email'] = _emailController.text.toString();
  //     request.fields['token'] = _otpController.text.toString();
  //     request.fields['password'] = _passwordController.text.toString();
  //     request.fields['password_confirmation'] = _REpasswordController.text.toString();
  //
  //     var response = await request.send();
  //     if (response.statusCode == 200) {
  //       setState(() {
  //         isLoading = false;
  //       });
  //       Utils.snackBar("OTP send to your email", context);
  //       Future.delayed(Duration(seconds: 2), () {
  //         Navigator.push(context, MaterialPageRoute(builder: (context) => LoginView(),),);
  //       });
  //       print('Registration Successful');
  //       print(await response.stream.bytesToString());
  //
  //     } else {
  //       setState(() {
  //         isLoading = false;
  //       });
  //       Utils.flushBarErrorMessage("Failed to register.", context);
  //       print('Failed to register. Status code: ${response.statusCode}');
  //       print(response);
  //
  //     }
  //   } catch (e) {
  //     print('Error during registration: $e');
  //   }
  // }
  Future<void> _ChangePassword() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String _token = prefs.getString('token') ?? '';

      String apiUrl = '${AppUrl.baseUrl}/api/app/password/reset-submit';
      var request = https.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers.addAll({
        'Authorization': 'Bearer $_token',
      });

      request.fields['email'] = _emailController.text.toString();
      request.fields['token'] = _otpController.text.toString();
      request.fields['password'] = _passwordController.text.toString();
      request.fields['password_confirmation'] =
          _REpasswordController.text.toString();

      var response = await request.send();
      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        Utils.flushBarSuccessMessage("Successfully Changed", context);
        Future.delayed(Duration(seconds: 2), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginView(),
            ),
          );
        });
        print('Registration Successful');
        print(await response.stream.bytesToString());
      } else if (response.statusCode == 422) {
        setState(() {
          isLoading = false;
        });
        // Validation failed
        var errorResponse = await response.stream.bytesToString();
        print(errorResponse);

        Map<String, dynamic> errorJson = json.decode(errorResponse);
        if (errorJson.containsKey('data')) {
          Map<String, dynamic> data = errorJson['data'];
          List<String> errors = [];
          data.forEach((key, value) {
            if (value is List) {
              errors.addAll(value.cast<String>());
            } else {
              errors.add(value.toString());
            }
          });
          Utils.flushBarErrorMessage(errors.join('\n'), context);
        } else {
          Utils.flushBarErrorMessage("Failed to register.", context);
        }
      }
      else {
        setState(() {
          isLoading = false;
        });
        Utils.flushBarErrorMessage("Failed to register.", context);
        print('Failed to register. Status code: ${response.statusCode}');
        print(response);
      }
    } catch (e) {
      print('Error during registration: $e');
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
        padding: const EdgeInsets.all(10.0),
        child: Column(

            children: [
              // SizedBox(
              //   height: screenHeight * 0.013,
              // ),
              Align(
                alignment: Alignment.topCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                        onTap: () {Navigator.pop(context);},
                        child: HeaderRow(Icons.arrow_back)),
                    Text(
                      "Reset Password",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      height: screenHeight * 0.055, width: screenWidth * 0.12,
                      child: Icon(Icons.home,color: Colors.transparent,),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.04,),
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
                      color: AppColors.navButtonColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        height: screenHeight*0.07,
                        width: screenWidth*0.18,

                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage("images/staff/settingsIcon/acountSettings/reset.png",)
                            )
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03,),
              Padding(
                padding: const EdgeInsets.only(left:15.0),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Email Address")),
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
                      // keyboardType: TextInputType.emailAddress,
                      readOnly: true,
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
              SizedBox(height: screenHeight * 0.013,),

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
                      controller: _otpController,
                      keyboardType: TextInputType.text,
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
              SizedBox(height: screenHeight * 0.013,),
               Padding(
                padding: const EdgeInsets.only(left:15.0),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("New Password")),
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
                      controller: _passwordController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: 'password',
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
              SizedBox(height: screenHeight * 0.013,),
              Padding(
                padding: const EdgeInsets.only(left:15.0),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Re-enter Password")),
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
                      controller: _REpasswordController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: 're-enter password',
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
      
              SizedBox(height: screenHeight * 0.02,),
              GestureDetector(
                onTap: (){
                  _ChangePassword();
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
                        : Text("Continue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1,),
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