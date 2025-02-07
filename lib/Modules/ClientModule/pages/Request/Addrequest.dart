import 'dart:async';
import 'dart:convert';

import 'package:c9_app/DarkAndLightTheme/theme_provider.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart'as https;
import '../../../../utils/utils.dart';
class AddRequest extends StatefulWidget {
  const AddRequest({super.key});

  @override
  State<AddRequest> createState() => _AddRequestState();
}

class _AddRequestState extends State<AddRequest> {
  TextEditingController _reqNum = TextEditingController();
  TextEditingController _DatePickerController = TextEditingController();
  // TextEditingController _jobType = TextEditingController();
  TextEditingController _staffType = TextEditingController();

  String? _selectedJobType;

  Map<String, String> _validationErrors = {};
  String _numberValidationError = '';
  String _dateValidationError = '';
  String _jobTypeValidationError = '';
  String _typeOFValidationError = '';


  Future<void> _PostRequest() async {
    setState(() {
      isLoading = true;
    });
     _numberValidationError = '';
     _dateValidationError = '';
     _jobTypeValidationError = '';
     _typeOFValidationError = '';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';

    try {
      String apiUrl = '${AppUrl.baseUrl}/api/app/request/store';
      var request = https.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers.addAll({
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
      });

      request.fields['number_of_staff'] = _reqNum.text.toString();
      request.fields['date'] = _DatePickerController.text.toString();
      request.fields['job_type'] = _selectedJobType.toString();
      request.fields['types_of_staff'] = _staffType.text.toString();

      var response = await request.send();

      if (response.statusCode == 200) {
        print('Registration Successful');
        setState(() {
          isLoading = false;
        });
        _reqNum.clear();
        _selectedJobType = null;
        _staffType.clear();
        _DatePickerController.clear();
        Utils.flushBarSuccessMessage("Data Submit Successfully", context);
      }else if (response.statusCode == 422) {
        // Parse and handle validation error response
        final Map<String, dynamic> responseData = jsonDecode(await response.stream.bytesToString());
        print(responseData);
        if (responseData.containsKey('errors')) {
          final Map<String, dynamic> errors = responseData['errors'];
          errors.forEach((field, messages) {
            final String errorMessage = messages.isNotEmpty ? messages.first : 'Unknown error';
            switch (field) {
              case 'number_of_staff':
                _numberValidationError = errorMessage;
                break;
              case 'date':
                _dateValidationError = errorMessage;
                break;
              case 'job_type':
                _jobTypeValidationError = errorMessage;
                break;
              case 'types_of_staff':
                _typeOFValidationError = errorMessage;
                break;
            }
          });
          // Show error messages to the user
          setState(() {
            _validationErrors = {
              'number_of_staff': _numberValidationError,
              'date': _dateValidationError,
              'job_type': _jobTypeValidationError,
              'types_of_staff': _typeOFValidationError,
            };
            isLoading = false;
          });
          Utils.flushBarErrorMessage('Please fill all the rquired field', context);
        } else {
          Utils.flushBarErrorMessage('Please fill all the rquired field', context);
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print('Failed to register. Status code: ${response.statusCode}');
        Utils.flushBarErrorMessage("Failed to Register", context);
        setState(() {
          isLoading=false;
        });
      }
    } catch (e) {
      print('Error during registration: $e');

    }
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ResPonsiveUi(
          mobile: body(),
          desktop: body(),
          tablet: body(),
        ),
      ),
    );
  }


  Widget body() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final List<String> jobTypes = ['Driver'];
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Align(alignment: Alignment.centerLeft,
                child: Text("Create New Request",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),)),
            SizedBox(height: screenHeight * 0.013,),
          Column(
            crossAxisAlignment:CrossAxisAlignment.start ,
            children: [
              SingleHeader(context: context,labelText: 'How many staff do you require?',  text: 'Number Of Staff',controllers: _reqNum, keyboard: TextInputType.text, iconData: Icons.account_balance_wallet_outlined),
              if ( _numberValidationError.isNotEmpty)
                Align(
                  alignment: Alignment.topLeft,
                  child: Text( _numberValidationError,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),),
                ),

              SizedBox(height: screenHeight * 0.013,),


              Row(
                children: [
                  Text('Date', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),),
                  Text(
                    ' *',
                    style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.005,),
              Container(
                // height: screenHeight * 0.065,
                width: screenWidth*0.95,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.navButtonColor,width: 0.4,),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextFormField(
                  controller: _DatePickerController,
                  keyboardType: TextInputType.datetime,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 14),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                    hintText: 'yyyy/mm/dd',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    prefixIcon: Icon(Icons.calendar_today,size: 20,),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                      initialEntryMode: DatePickerEntryMode.calendar, // Set the initial entry mode to calendar
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _DatePickerController.text = pickedDate.toString().split(' ')[0]; // Only show the date part
                      });
                    }
                  },
                ),
              ),
              if ( _dateValidationError.isNotEmpty)
                Align(
                  alignment: Alignment.topLeft,
                  child: Text( _dateValidationError,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),),
                ),
              SizedBox(height: screenHeight * 0.013,),

              Row(
                children: [
                  Text(
                    "Staff Job Type",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    ' *',
                    style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.005,),
              Container(
                width: screenWidth * 0.95,
                decoration: BoxDecoration(
                  border: Border.all(color:  AppColors.navButtonColor, width: 0.4,),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    // iconEnabledColor: AppColors.navButtonColor,
                    iconSize: 30.0,
                    value: _selectedJobType,
                    items: jobTypes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child:  Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedJobType = newValue!;
                      });
                    },
                    decoration: InputDecoration(
                      hintStyle: TextStyle(fontSize: 14),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                      prefixIcon: Icon(Icons.location_on,size: 20,),
                      hintText: 'Select job type',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ),
              if ( _jobTypeValidationError.isNotEmpty)
                Align(
                  alignment: Alignment.topLeft,
                  child: Text( _jobTypeValidationError,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),),
                ),
            ],
          ),
            SizedBox(height: screenHeight * 0.013,),

            Row(
              children: [
                Align(alignment:Alignment.centerLeft,child: Text("Type Of Staff", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),)),
                Text(
                  ' *',
                  style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.005,),
            Container(
              height: screenHeight * 0.2,
              width: screenWidth * 0.95,
              decoration: BoxDecoration(
                border: Border.all(color:  AppColors.navButtonColor,width: 0.4,),
                borderRadius: BorderRadius.circular(5),
              ),
              child: TextFormField(
                controller: _staffType,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  hintStyle: TextStyle(fontSize: 14),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                  hintText: "Which types of staff do you needs?",
                  prefixIcon: Icon(Icons.edit,size: 20,),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
            if ( _typeOFValidationError.isNotEmpty)
              Align(
                alignment: Alignment.topLeft,
                child: Text( _typeOFValidationError,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),),
              ),
            SizedBox(height: screenHeight * 0.013,),

            InkWell(
              onTap: () async {
                await _PostRequest();
              },
              child: Container(
                height: screenHeight * 0.055,
                width: screenWidth * 0.3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color:  AppColors.navButtonColor,
                  border: Border.all(
                    width: 0.2,
                    color:  AppColors.greyOpacity,
                  ),
                ),
                child: Center(
                  child: isLoading
                      ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white,)) // Show loading indicator if isLoading is true
                      : Text("Submit", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1,),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.2),
          ],
        ),
      ),
    );
  }

  Widget SingleHeader({
    String? text,
    required BuildContext context,
    required TextEditingController controllers,
    required TextInputType keyboard,
    IconData? iconData,
    required String labelText, // Corrected parameter name
  }) {

    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (text != null) // Only add the Text widget if text is provided
              Text(
                text,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
            Text(
              ' *',
              style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.005,),
        Container(
          // height: screenHeight * 0.065,
          width: screenWidth * 0.95,
          decoration: BoxDecoration(
            border: Border.all(color:  AppColors.navButtonColor, width: 0.4,),
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextFormField(
            controller: controllers,
            keyboardType: keyboard,
            textAlign: TextAlign.left,
            decoration: InputDecoration(
              hintStyle: TextStyle(fontSize: 14),
              contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
              prefixIcon: Icon(iconData,size: 20,),
              hintText: labelText, // Corrected parameter name
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }


  Widget HeaderRow(IconData iconData) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return Container(
      height: screenHeight * 0.055,
      width: screenWidth * 0.12,
      decoration: BoxDecoration(
        color:AppColors.whiteColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color:AppColors.greyOpacity,
            offset: Offset(0, 2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(iconData,color:  AppColors.navColor,),
    );
  }
}
