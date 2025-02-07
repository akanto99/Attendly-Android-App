import 'dart:convert';

import 'package:c9_app/Modules/ClientModule/client_screen.dart';
import 'package:c9_app/Modules/ClientModule/pages/Profile_&_Setting/AccountDeletion/confirmDelete.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/utils/utils.dart';
import 'package:c9_app/view/widgets/header_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as https;

class DeleteAccountClient extends StatefulWidget {
  final String clientemails;
  const DeleteAccountClient({super.key,required this.clientemails});

  @override
  State<DeleteAccountClient> createState() => _DeleteAccountClientState();
}

class _DeleteAccountClientState extends State<DeleteAccountClient> {

  bool isLoading = false;
  Future<void> hitDelete() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String _token = prefs.getString('token') ?? '';

      final String apiUrl =
          '${AppUrl.baseUrl}/api/app/my-digital-accounts/account-deletion-process/submit';
      final response = await https.get(Uri.parse(apiUrl), headers: {
        'Authorization': 'Bearer $_token',
      });

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        // Parse the JSON response
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Access the message field
        String message = jsonResponse['message'];

        // Display the success message
        Utils.flushBarSuccessMessage(message, context);
        Future.delayed(Duration(seconds: 2), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConfirmDelete(),
            ),
          );
        });
        print('Account Deletion Successful');
        print(await response.body);
      } else if (response.statusCode == 404) {
        // Parse and handle the 404 error response
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Display the error message
        if (jsonResponse.containsKey('message')) {
          String errorMessage = jsonResponse['message'];
          Utils.flushBarErrorMessage(errorMessage, context);
        } else {
          Utils.flushBarErrorMessage("Unknown error occurred", context);
        }
      } else {
        Utils.flushBarErrorMessage("Something went wrong", context);
        throw Exception('Failed to delete account ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      print('Error during account deletion: $e');
      Utils.flushBarErrorMessage("An error occurred: $e", context);
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
                      "Delete Account",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      height: screenHeight * 0.055, width: screenWidth * 0.12,
                      child: Icon(Icons.home,color: Colors.transparent,),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.02,),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Are you sure you want to delete your account?",style: TextStyle(fontSize: 18),)),
            Text("\nDeleting your account will permanently remove all your data associated with Attendly. This action cannot be undone.\n\nPlease note:\n⦿ If you're certain about deleting your account, please confirm by tapping the button below.[OTP]\n⦿ If you have any concerns or need assistance, please contact our support team at [attendly@c9-group.co.uk]."),

              SizedBox(height: screenHeight * 0.1,),

              GestureDetector(
                onTap: (){
                  hitDelete();
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
                        : Text("Send OTP", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1,),
                    ),
                  ),
                ),
              ),
            ]),
      ),
    );
  }
}