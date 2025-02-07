import 'package:auto_size_text/auto_size_text.dart';
import 'package:c9_app/view/splash&login/Registration/final_multistep/All_Steps/Widgets/datepicker_with_formField.dart';
import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/view/widgets/customTextField.dart';
import 'package:c9_app/view/widgets/date_pickerContainer.dart';
import 'package:c9_app/view/widgets/dropdown_yesno.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as https;
import '../../../../../utils/utils.dart';

class LicexpiryStep4 extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final VoidCallback onStep4;
  final String dbsEdbs;
  final String ukExperience;
  final String validCPC;
  final String validTacho;
  LicexpiryStep4({
    required this.formKey,
    required this.onStep4,
    required this.dbsEdbs,
    required this.ukExperience,
    required this.validCPC,
    required this.validTacho,
    Key? key,
  }) : super(key: key);

  @override
  _LicexpiryStep4State createState() => _LicexpiryStep4State();
}

class _LicexpiryStep4State extends State<LicexpiryStep4> {
  late TextEditingController passportExController;
  late TextEditingController licExController;
  late TextEditingController cpcExController;
  late TextEditingController tachoExController;
  late TextEditingController dbsExController;


  Future<void> _loadFormData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      ///Fitness Section
      passportExController.text = prefs.getString('passportExpiry') ?? '';
      licExController.text = prefs.getString('licenceExpiry') ?? '';
      cpcExController.text = prefs.getString('cpcExpiry') ?? '';
      tachoExController.text = prefs.getString('tachoExpiry') ?? '';
      dbsExController.text = prefs.getString('dbsExpiry') ?? '';


    });
  }

  Future<void> _saveFormData() async {
    final prefs = await SharedPreferences.getInstance();
    ///Fitness Section
    prefs.setString('passportExpiry',passportExController.text);
    prefs.setString('licenceExpiry',licExController.text);
    prefs.setString('cpcExpiry',cpcExController.text);
    prefs.setString('tachoExpiry',tachoExController.text);
    prefs.setString('dbsExpiry',dbsExController.text);

  }

  Future<bool> _postExpiryStep(int subCurrentStep) async {
    print("-------------API Hit for Step $subCurrentStep--------------");
    Utils.showDialogLoading(context);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String _token = prefs.getString('token') ?? '';

      String apiUrl = '${AppUrl.baseUrl}/api/app/staff-registration';
      var request = https.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers.addAll({
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
      });

      ///Expiry Section
      request.fields['passportExpiry'] = passportExController.text;
      if (widget.ukExperience == "Yes"){request.fields['licenceExpiry'] = licExController.text;}
      if (widget.validCPC == "Yes"){request.fields['cpcExpiry'] = cpcExController.text;}
      if (widget.validTacho == "Yes"){request.fields['tachoExpiry'] = tachoExController.text;}
      if (widget.dbsEdbs == "Yes"){request.fields['dbsExpiry'] = dbsExController.text;}

      var response = await request.send();
      String responseString = await response.stream.bytesToString();

      print("API URL: $apiUrl");
      print("Headers: ${request.headers}");
      print("Fields: ${request.fields}");
      print('Response status code: ${response.statusCode}');
      print('Response body: $responseString');

      if (response.statusCode == 201) {
        print("API Request Successful for Step $subCurrentStep");
        Utils.flushBarSuccessMessage('Data submitted successfully', context);
        return true;
      } else if (response.statusCode == 422) {
        // Parse the validation errors
        final responseData = jsonDecode(responseString) as Map<String, dynamic>;
        if (responseData.containsKey('errors')) {
          final validationErrors = responseData['errors'] as Map<String, dynamic>;
          Navigator.pop(context);
          setState(() {
          });
        }
        // Utils.flushBarErrorMessage('Validation error: $responseString', context);
        return false; // Validation error
      }else {
        Utils.flushBarErrorMessage('Error: $responseString', context);
        return false;
      }
    } catch (e) {
      print("An error occurred: $e");
      Utils.flushBarErrorMessage('An error occurred: $e', context);
      return false;
    }
  }



  @override
  void initState() {
    super.initState();
    passportExController = TextEditingController();
    licExController = TextEditingController();
    cpcExController = TextEditingController();
    tachoExController = TextEditingController();
    dbsExController = TextEditingController();
    _loadFormData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return SingleChildScrollView(
      child: Form(
        key: widget.formKey,
        child: Column(
          children: [
            // Text("${widget.dbsEdbs}  test dbs"),
            // Text(widget.ukExperience),
            // Text(widget.validCPC),
            // Text(widget.validTacho),
            Container(
              height: 45,
              width: screenWidth * 0.95,
              padding: EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                color: AppColors.navColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    offset: Offset(5, 5),
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Expiry & Licences",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.whiteColor,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * .013,),
            Container(
              width: screenWidth * 0.95,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    offset: Offset(0, 2),
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(
                  color: Color(0xffdcfdff),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * .013,),
                  CustomDatePickerFormField(
                    title: "Passport Expiry",
                    labelText: 'dd/mm/yyyy',
                    controller: passportExController,
                    validator: (value) {
                      if (passportExController.text == null || passportExController.text.isEmpty) {
                        return 'Passport expiry is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight * .013,),

                if (widget.ukExperience == "Yes")...[
                  CustomDatePickerFormField(
                    title: "Licence Expiry",
                    labelText: 'dd/mm/yyyy',
                    controller: licExController,
                    validator: (value) {
                      if (licExController.text == null || licExController.text.isEmpty) {
                        return 'Licence expiry is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight * .013,),
                ],

                if (widget.validTacho == "Yes")...[
                  CustomDatePickerFormField(
                    title: "CPC Expiry",
                    labelText: 'dd/mm/yyyy',
                    controller: cpcExController,
                    validator: (value) {
                      if (cpcExController.text == null || cpcExController.text.isEmpty) {
                        return 'CPC expiry is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight * .013,),
                ],

                  if (widget.validTacho == "Yes")...[
                    CustomDatePickerFormField(
                      title: "Tacho Card Expiry",
                      labelText: 'dd/mm/yyyy',
                      controller: tachoExController,
                      validator: (value) {
                        if (tachoExController.text == null || tachoExController.text.isEmpty) {
                          return 'Tacho card expiry is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenHeight * .013,),
                  ],



                  if (widget.dbsEdbs == "Yes")
                  CustomDatePickerFormField(
                    title: "DBS Expiry",
                    labelText: 'dd/mm/yyyy',
                    controller: dbsExController,
                    validator: (value) {
                      if (dbsExController.text == null || dbsExController.text.isEmpty) {
                        return 'DBS expiry is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight * .013,),
                ],
              ),
            ),
            SizedBox(
              height: screenHeight * .02,
            ),
      
            GestureDetector(
              onTap: ()async{
                _saveFormData();
                if (widget.formKey.currentState?.validate() ?? false ) {
                  widget.onStep4();

                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('dbsExpiry');
                }
              },
              child: Container(
                height: screenHeight * 0.05,
                width: screenWidth * 0.7,
                decoration: BoxDecoration(
                  color: Color(0xff2664EC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: AutoSizeText(
                    "CONTINUE",
                    maxLines: 1,
                    style: GoogleFonts.openSans(
                      textStyle: TextStyle(fontSize: 16),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
