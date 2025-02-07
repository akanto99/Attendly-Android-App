import 'dart:convert';
import 'package:c9_app/Modules/StaffModule/DashBoard/staff_navigationScreen.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/utils/utils.dart';
import 'package:c9_app/view/widgets/header_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart'as https;

class StaffChangePassword extends StatefulWidget {
  final String staffemails;
  const StaffChangePassword({super.key,required this.staffemails});

  @override
  State<StaffChangePassword> createState() => _StaffChangePasswordState();
}

class _StaffChangePasswordState extends State<StaffChangePassword> {
  TextEditingController  _passwordController= TextEditingController();
  TextEditingController  _REpasswordController= TextEditingController();


  bool isLoading = false;

  Future<void> _ChangePassword() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String _token = prefs.getString('token') ?? '';

      String apiUrl = '${AppUrl.baseUrl}/api/app/password/change';
      var request = https.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers.addAll({
        'Authorization': 'Bearer $_token',
      });

      request.fields['email'] = widget.staffemails;
      request.fields['password'] = _passwordController.text.toString();
      request.fields['password_confirmation'] =  _REpasswordController.text.toString();

      var response = await request.send();
      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        Utils.flushBarSuccessMessage("Successfully Changed", context);
        print('Registration Successful');
        print(await response.stream.bytesToString());
        Future.delayed(Duration(seconds: 2), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StaffCurveNabBar(),
            ),
          );
        });
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

        var errorResponse = await response.stream.bytesToString();
        print(errorResponse);

        Map<String, dynamic> jsonResponse = json.decode(errorResponse);
        String errorMessage = jsonResponse['message'];
        print(errorMessage);
        Utils.flushBarErrorMessage(errorMessage,context);
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
              // Text("${widget.staffemails}",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 20),),
              Align(
                alignment: Alignment.topCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                        onTap: () {Navigator.pop(context);},
                        child: HeaderRow(Icons.arrow_back)),
                    Text(
                      "Change Password",
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
                      color:AppColors.navColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        height: screenHeight*0.07,
                        width: screenWidth*0.18,

                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage("images/staff/settingsIcon/acountSettings/change.png",)
                            )
                        ),
                      ),
                    ),
                  ),
                ),
              ),



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
                        hintText: 'new password',
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
                    child: Text("Confirm Password")),
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
                        hintText: 'Confirm password',
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
}