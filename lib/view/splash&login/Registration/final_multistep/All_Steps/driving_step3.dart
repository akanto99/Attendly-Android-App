import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/view/splash&login/Registration/final_multistep/All_Steps/Widgets/customtext_with_formfield.dart';
import 'package:c9_app/view/splash&login/Registration/final_multistep/All_Steps/Widgets/datepicker_with_formField.dart';
import 'package:c9_app/view/widgets/customTextField.dart';
import 'package:c9_app/view/widgets/date_pickerContainer.dart';
import 'package:c9_app/view/widgets/dropdown_yesno.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as https;
import '../../../../../utils/utils.dart';

class DrivingStep3 extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final VoidCallback onStep3;
  final Function(String) onUkExperienceChanged;
  final Function(String) onValidCPCChanged;
  final Function(String) onValidTachoChanged;

  DrivingStep3({
    required this.formKey,
    required this.onStep3,
    required this.onUkExperienceChanged,
    required this.onValidCPCChanged,
    required this.onValidTachoChanged,
    Key? key,
  }) : super(key: key);

  @override
  _DrivingStep3State createState() => _DrivingStep3State();
}

class _DrivingStep3State extends State<DrivingStep3> {
  int subCurrentStep = 0;


  ///Bank Section
  List<String> selectedLicenseTypes = [];
  late TextEditingController liNumberController;
  String? liNumberValidationError;
  late TextEditingController anyEndorsmentController;
  late TextEditingController cpcNumController;
  late TextEditingController techoNumberController;

  final List<String> _dropdownOptions = ['Yes', 'No'];
  String? selectedUKHold;
  String? selectedUKDriving;
  String? selectedUKPenalty;
  String? selectedValidCPC;
  String? selectedValidTacho;
  // late TextEditingController dlNumberController;
  late TextEditingController dlIssueController;
  // late TextEditingController dlCategoryController;
  late TextEditingController dlCheckController;

  final List<String> _licenseTypes = ['Class B', 'Class C', 'Class D', 'Class D1', 'Class E'];
  final Map<String, String> licenseTypeMap = {
    'Class B': 'classB',
    'Class C': 'classC',
    'Class D': 'classD',
    'Class D1': 'classD1',
    'Class E': 'classE',
  };


  Future<void> _loadFormData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      ///Bank Section
      String? encodedList = prefs.getString('selectedLicenseTypes');
      if (encodedList != null) {
        selectedLicenseTypes = List<String>.from(jsonDecode(encodedList));
      } else {
        selectedLicenseTypes = [];
      }
      print("Loaded selectedLicenseTypes: $selectedLicenseTypes");

      liNumberController.text = prefs.getString('licenceNumber') ?? '';
      anyEndorsmentController.text = prefs.getString('licenceEndorsements') ?? '';
      cpcNumController.text = prefs.getString('cpcNumber') ?? '';
      techoNumberController.text = prefs.getString('tachoNumber') ?? '';

      selectedUKDriving = prefs.getString('UKDriving');
      selectedUKHold = prefs.getString('UKHold');
      selectedUKPenalty = prefs.getString('UKPenalty');
      selectedValidCPC = prefs.getString('noCpcCard');
      selectedValidTacho = prefs.getString('noTachoCard');
      // dlNumberController.text = prefs.getString('dlNumber') ?? '';
      dlIssueController.text = prefs.getString('dlIssue') ?? '';
      // dlCategoryController.text = prefs.getString('dlCategory') ?? '';
      dlCheckController.text = prefs.getString('dlCheck') ?? '';
    });
  }

  Future<void> _saveFormData() async {
    final prefs = await SharedPreferences.getInstance();

    ///Bank Section
    prefs.setString('selectedLicenseTypes', jsonEncode(selectedLicenseTypes));
    print("Saving selectedLicenseTypes: $selectedLicenseTypes");

    prefs.setString('licenceNumber', liNumberController.text);
    prefs.setString('licenceEndorsements', anyEndorsmentController.text);
    prefs.setString('cpcNumber', cpcNumController.text);
    prefs.setString('tachoNumber', techoNumberController.text);
    if (selectedUKDriving != null) prefs.setString('UKDriving', selectedUKDriving!);
    if (selectedUKHold != null) prefs.setString('UKHold', selectedUKHold!);
    if (selectedUKPenalty != null) prefs.setString('UKPenalty', selectedUKPenalty!);
    if (selectedValidCPC != null) prefs.setString('noCpcCard', selectedValidCPC!);
    if (selectedValidTacho != null) prefs.setString('noTachoCard', selectedValidTacho!);
    // prefs.setString('dlNumber', dlNumberController.text);
    prefs.setString('dlIssue', dlIssueController.text);
    // prefs.setString('dlCategory', dlCategoryController.text);
    prefs.setString('dlCheck', dlCheckController.text);

  }


  Future<bool> _postDrivingStep(int subCurrentStep) async {
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

      request.fields['valid_uk_driving_license'] = selectedUKHold == 'Yes' ? '1' : '0';
      if(selectedUKHold=="Yes"){
        request.fields['uk_driving_experience'] = selectedUKDriving == 'Yes' ? '1' : '0';
      }
      if( selectedUKHold=="Yes" && selectedUKDriving=="Yes"  ){
        request.fields['licenceNumber'] = liNumberController.text;
      }



      if (selectedUKHold == 'Yes' && selectedUKDriving == "Yes" && liNumberController.text.isNotEmpty) {
        request.fields['penalty_points'] = selectedUKPenalty == 'Yes' ? '1' : '0';
        request.fields['driving_license_issue_date'] = dlIssueController.text;
        request.fields['driving_license_check_code'] = dlCheckController.text;


        print('Print for 0:$subCurrentStep');
        List<String> postedLicenseTypes = [];
        for (int i = 0; i < selectedLicenseTypes.length; i++) {
          String postedValue = licenseTypeMap[selectedLicenseTypes[i]] ?? '';
          if (postedValue.isNotEmpty) {
            request.fields['licenceTypes[$i]'] = postedValue;
            postedLicenseTypes.add(postedValue);
          }
        }
        print('Licence Types:------------- $postedLicenseTypes');

        request.fields['licenceEndorsements'] = anyEndorsmentController.text;
      }
      request.fields['noCpcCard'] = selectedValidCPC == 'Yes' ? '1' : '0';
      if (selectedValidCPC == 'Yes') {
        request.fields['cpcNumber'] = cpcNumController.text;
      }
      request.fields['noTachoCard'] = selectedValidTacho == 'Yes' ? '1' : '0';
      if (selectedValidTacho == 'Yes') {
        request.fields['tachoNumber'] = techoNumberController.text;
      }
        // request.fields['driving_license_number'] = dlNumberController.text;
        // request.fields['driving_license_category'] = dlCategoryController.text;
      var response = await request.send();

      print("API URL: $apiUrl");
      print("Headers: ${request.headers}");
      String responseString = await response.stream.bytesToString();
      print('Request fields: ${request.fields}');
      print('Response status code: ${response.statusCode}');
      print('Response body: $responseString');

      if (response.statusCode == 201) {
        print("API Request Successful for Step $subCurrentStep");
        Utils.flushBarSuccessMessage('Data submitted successfully', context);
        return true; // Success
      } else if (response.statusCode == 422) {
        // Parse the validation errors
        final responseData = jsonDecode(responseString) as Map<String, dynamic>;
        if (responseData.containsKey('errors')) {
          final validationErrors = responseData['errors'] as Map<String, dynamic>;
          Navigator.pop(context);
        }
        return false; // Validation error
      } else {
        Utils.flushBarErrorMessage('Error: $responseString', context);
        return false; // General error
      }
    } catch (e) {
      print("An error occurred: $e");
      Utils.flushBarErrorMessage('An error occurred: $e', context);
      return false; // Exception
    }
  }
  @override
  void initState() {
    super.initState();
    ///Bank Section
    liNumberController = TextEditingController();
    anyEndorsmentController = TextEditingController();
    cpcNumController = TextEditingController();
    techoNumberController = TextEditingController();
    selectedUKDriving ;
    selectedUKHold ;
    selectedUKPenalty ;
    selectedValidCPC ;
    selectedValidTacho;
    // dlNumberController = TextEditingController();
    dlIssueController = TextEditingController();
    // dlCategoryController = TextEditingController();
    dlCheckController = TextEditingController();
    _loadFormData();

    liNumberController.addListener(() {
      setState(() {});
    });
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
      // controller: _scrollController,
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                  "Driving Information",
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
                 ConditionalDropdown(
                   title: "Do you hold a valid UK driving license?",
                   options: _dropdownOptions,
                   selectedOption: selectedUKHold,
                   onChanged: (newValue) async {
                     setState(() {
                       selectedUKHold = newValue!;
                     });
                     final prefs = await SharedPreferences.getInstance();
                     prefs.setString('UKHold', newValue!);
                   },
                   validator: (value) {
                     if (value == null) {
                       return 'Please select an option.';
                     }
                     return null;
                   },
                 ),
                 if(selectedUKHold=="Yes")...[
                   SizedBox(height: screenHeight * .013,),
                   ConditionalDropdown(
                     title:"Do you have UK driving experience?",
                     options: _dropdownOptions,
                     selectedOption: selectedUKDriving,
                     onChanged: (newValue) async {
                       setState(() {
                         selectedUKDriving = newValue!;
                       });
                       final prefs = await SharedPreferences.getInstance();
                       prefs.setString('UKDriving', newValue!);
                       widget.onUkExperienceChanged(newValue);
                     },
                     validator: (value) {
                       if (selectedUKHold=="Yes" && value == null) {
                         return 'Please select an option.';
                       }
                       return null;
                     },
                   ),


                   if(selectedUKHold=="Yes" && selectedUKDriving=="Yes")...[
                     SizedBox(height: screenHeight * .013,),
                     CustomTextFieldWithFormField(
                       titleText: 'License Number',
                       requiredStar: '*',
                       placeholder: 'Enter your license number',
                       controller: liNumberController,
                       validator: (value) {
                         // Check if the field is empty or invalid
                         if (selectedUKHold == "Yes" && selectedUKDriving == "Yes" && (liNumberController.text == null || liNumberController.text.isEmpty)) {
                           return 'License Number is required.';
                         } else if (selectedUKHold == "Yes" && selectedUKDriving == "Yes" && liNumberController.text!.length < 16) {
                           return 'License Number must be at least 16 characters.';
                         }
                         return null; // Valid input
                       },

                     ),
                   ],

                   if (selectedUKHold=="Yes" && selectedUKDriving=="Yes" &&liNumberController.text.isNotEmpty)...[
                     SizedBox(height: screenHeight * .013),
                     ConditionalDropdown(
                       title: "Do you have penalty points on your license?",
                       options: _dropdownOptions,
                       selectedOption: selectedUKPenalty,
                       onChanged: (newValue) async {
                         setState(() {
                           selectedUKPenalty = newValue!;
                         });
                         final prefs = await SharedPreferences.getInstance();
                         prefs.setString('UKPenalty', newValue!);
                       },
                       validator: (value) {
                         if (selectedUKHold=="Yes" && selectedUKDriving=="Yes"&& liNumberController.text.isNotEmpty && value == null) {
                           return 'Please select an option.';
                         }
                         return null;
                       },
                     ),

                     SizedBox(height: screenHeight * .013),
                     CustomDatePickerFormField(
                       title: "Date of issue of the driving license.",
                       // requiredStar:"",
                       labelText: 'dd/mm/yyyy',
                       controller: dlIssueController,
                       validator: (value) {
                         if (selectedUKHold == "Yes" &&
                             selectedUKDriving == "Yes" &&
                             liNumberController.text.isNotEmpty &&
                             (dlIssueController.text == null || dlIssueController.text.isEmpty)) {
                           return 'Date of issue of the driving license is required';
                         }
                         return null;
                       },

                     ),
                     SizedBox(height: screenHeight * .013),
                     CustomTextFieldWithFormField(
                       titleText: 'Check code for driving license.',
                       requiredStar: '*',
                       placeholder: 'Enter your code',
                       controller: dlCheckController,
                       validator: (value) {
                         // Check if the field is empty or invalid
                         if (selectedUKHold == "Yes" &&
                             selectedUKDriving == "Yes" &&
                             liNumberController.text.isNotEmpty &&
                             (dlCheckController.text == null || dlCheckController.text.isEmpty)) {
                           return 'Code Number is required.';
                         }
                         return null; // Valid input
                       },

                     ),
                     SizedBox(height: screenHeight * .013,),


                     Padding(
                       padding: const EdgeInsets.only(bottom: 10),
                       child: Container(
                         width: screenWidth * 0.90,
                         child: Row(
                           children: [
                             Text(
                               'Licence Type ',
                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                             ),
                             Text(
                               '(choose one or multiple types)',
                               style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                             ),
                             Text(
                               " *",
                               style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                             )
                           ],
                         ),
                       ),
                     ),
                     FormField<List<String>>(
                       initialValue: selectedLicenseTypes,
                       autovalidateMode: AutovalidateMode.onUserInteraction,
                       validator: (value) {
                         if (selectedUKHold == "Yes" &&
                             selectedUKDriving == "Yes" &&
                             liNumberController.text.isNotEmpty &&
                             (value == null || value.isEmpty)) {
                           return "Please select at least one license type.";
                         }
                         return null;
                       },

                       builder: (FormFieldState<List<String>> field) {
                         return Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Container(
                               height: screenHeight * 0.055,
                               width: screenWidth * 0.90,
                               decoration: BoxDecoration(
                                 color: Color(0xffF2F5F6),
                                 borderRadius: BorderRadius.circular(10.0),
                                 border: Border.all(
                                   color: Color(0xffEAECED),
                                   width: 1,
                                 ),
                               ),
                               child: Row(
                                 children: [
                                   Container(
                                     width: screenWidth * 0.35,
                                     decoration: BoxDecoration(
                                         color: AppColors.navColor,
                                         borderRadius: BorderRadius.only(topLeft: Radius.circular(5),bottomLeft: Radius.circular(5))
                                     ),
                                     child: Center(
                                       child: Text(
                                         "Choose types",
                                         style: TextStyle(fontSize: 15, color: AppColors.whiteColor),
                                       ),
                                     ),
                                   ),
                                   Expanded(
                                     child: Container(
                                       height: screenHeight * 0.055,
                                       padding: EdgeInsets.symmetric(horizontal: 10.0),
                                       child: DropdownButtonHideUnderline(
                                         child: DropdownButton<String>(
                                           isExpanded: true,
                                           iconEnabledColor: AppColors.navButtonColor,
                                           iconSize: 30.0,
                                           hint: Text(
                                             'Select Licence Type',
                                             style: TextStyle(fontSize: 14, color: AppColors.navButtonColor),
                                           ),
                                           items: _licenseTypes.map((String value) {
                                             return DropdownMenuItem<String>(
                                               value: value,
                                               child: Text(value, style: TextStyle(fontSize: 14)),
                                             );
                                           }).toList(),
                                           onChanged: (String? newValue) async {
                                             if (newValue != null && !selectedLicenseTypes.contains(newValue)) {
                                               setState(() {
                                                 selectedLicenseTypes.add(newValue);
                                               });
                                               field.didChange(List.from(selectedLicenseTypes)); // Update field state
                                             }
                                             final prefs = await SharedPreferences.getInstance();
                                             prefs.setString('selectedLicenseTypes', newValue!);
                                           },
                                         ),
                                       ),
                                     ),
                                   ),
                                 ],
                               ),
                             ),
                             Wrap(
                               spacing: 8.0,
                               runSpacing: 1.0,
                               children: selectedLicenseTypes.map((type) {
                                 return Chip(
                                   label: Text(type, style: TextStyle(color: Colors.black)),
                                   backgroundColor: AppColors.navOpacity.withOpacity(0.5),
                                   deleteIcon: Icon(
                                     Icons.cancel,
                                     color: AppColors.navButtonColor,
                                     size: 20,
                                   ),
                                   onDeleted: () {
                                     setState(() {
                                       selectedLicenseTypes.remove(type);
                                     });
                                     field.didChange(List.from(selectedLicenseTypes));
                                   },
                                   shape: RoundedRectangleBorder(
                                     side: BorderSide(
                                       color: AppColors.navOpacity,
                                       width: 1.0,
                                     ),
                                     borderRadius: BorderRadius.circular(5),
                                   ),
                                 );
                               }).toList(),
                             ),
                             if (field.hasError)
                               Padding(
                                 padding: const EdgeInsets.only(top: 8.0),
                                 child: Text(
                                   field.errorText!,
                                   style: TextStyle(
                                     color: Colors.red,
                                     fontSize: 12,
                                     fontWeight: FontWeight.bold,
                                   ),
                                 ),
                               ),
                           ],
                         );
                       },
                     ),

                     SizedBox(height: screenHeight * .013,),
                     CustomTextFieldWithFormField(
                       titleText: 'Any points/endorsements on your licence?',
                       requiredStar: '*',
                       placeholder: 'Type licence points/endorsements.',
                       controller: anyEndorsmentController,
                       validator: (value) {
                         // Check if the field is empty or invalid
                         if (selectedUKHold == "Yes" &&
                             selectedUKDriving == "Yes" &&
                             liNumberController.text.isNotEmpty &&
                             (anyEndorsmentController.text == null || anyEndorsmentController.text.isEmpty)) {
                           return 'Any points/endorsements on licence is required.';
                         }
                         return null; // Valid input
                       },
                     ),
                   ],
                 ],

                 SizedBox(height: screenHeight * .013),
                 ConditionalDropdown(
                   title: "Are you a valid CPC holder?",
                   options: _dropdownOptions,
                   selectedOption: selectedValidCPC,
                   onChanged: (newValue) async {
                     setState(() {
                       selectedValidCPC = newValue!;
                       // _formData['noCpcCard'] = newValue == 'Yes' ? 1 : 0;
                     });
                     final prefs = await SharedPreferences.getInstance();
                     prefs.setString('noCpcCard', newValue!);
                     widget.onValidCPCChanged(newValue);
                   },
                   validator: (value) {
                     if (value == null) {
                       return 'Please select an option.';
                     }
                     return null;
                   },
                 ),


                 if(selectedValidCPC=="Yes")...[
                   SizedBox(height: screenHeight * .013),
                   CustomTextFieldWithFormField(
                     titleText: 'CPC Number',
                     requiredStar: '*',
                     placeholder: 'Enter your cpc number',
                     controller: cpcNumController,
                     validator: (value) {
                       if (selectedValidCPC=="Yes" && (cpcNumController.text == null || cpcNumController.text.isEmpty)) {
                         return 'CPC Number  is requireds.';
                       } else if (selectedValidCPC=="Yes" && (cpcNumController.text!.length < 8)) {
                         return 'CPC Number is minimum 8 characters.';
                       }
                       return null; // Valid input
                     },
                   ),
                 ],

                 SizedBox(height: screenHeight * .013),
                 ConditionalDropdown(
                   title: "Are you a valid TACHO holder?",
                   options: _dropdownOptions,
                   selectedOption: selectedValidTacho,
                   onChanged: (newValue) async {
                     setState(() {
                       selectedValidTacho = newValue!;
                       // _formData['noTachoCard'] = newValue == 'Yes' ? 1 : 0;
                     });
                     final valueToPost = newValue == 'Yes' ? 1 : 0;
                     if (newValue != null) {
                       print("Value to post: $valueToPost");
                     }
                     final prefs = await SharedPreferences.getInstance();
                     prefs.setString('noTachoCard', newValue!);
                     widget.onValidTachoChanged(newValue);
                   },
                   validator: (value) {
                     if (value == null) {
                       return 'Please select an option.';
                     }
                     return null;
                   },
                 ),
                 if(selectedValidTacho=="Yes")...[SizedBox(height: screenHeight * .013),
                   CustomTextFieldWithFormField(
                     titleText: 'Tacho Number',
                     requiredStar: '*',
                     placeholder: 'Enter your tacho number',
                     controller:techoNumberController,
                     validator: (value) {
                       // Check if the field is empty or invalid
                       if (selectedValidTacho=="Yes" && (techoNumberController.text == null || techoNumberController.text.isEmpty)) {
                         return 'Tacho Number  is requireds.';
                       } else if ( selectedValidTacho=="Yes" && (techoNumberController.text!.length < 16)) {
                         return 'Tacho Number is minimum 16 characters.';
                       }
                       return null; // Valid input
                     },
                   ),
                 ],
                 SizedBox(height: screenHeight * .013,),
               ],
             ),
           ),
            SizedBox(height: screenHeight * .02,),

            GestureDetector(
              onTap: ()async{
                _saveFormData();
                if (widget.formKey.currentState?.validate() ?? false ) {
                  widget.onStep3();
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

  Widget ConditionalDropdown({
    required String title,
    required List<String> options,
    String? selectedOption, // Nullable value
    required ValueChanged<String?> onChanged,
    required String? Function(String?)? validator, // Accept validator function
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Container(
          width: screenWidth * 0.90,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(fontSize: 15),
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                ' *',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ],
          ),
        ),
        SizedBox(height: screenHeight * 0.013),
        FormField<String>(
          initialValue: selectedOption,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          builder: (FormFieldState<String> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: screenHeight * 0.055,
                  width: screenWidth * 0.90,
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  decoration: BoxDecoration(
                    color: Color(0xffF2F5F6),
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(
                      color: Color(0xffEAECED),
                      width: 1,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isDense: true,
                      isExpanded: true,
                      iconSize: 30.0,
                      menuMaxHeight: 350,
                      value: selectedOption,
                      onChanged: (newValue) {
                        state.didChange(newValue);
                        onChanged(newValue);
                      },
                      hint: const Text('---Select One---'),
                      items: options.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                // Show error message if validation fails
                if (state.hasError)
                  Container(
                    width: screenWidth * 0.90,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 10),
                      child: Text(
                        state.errorText ?? '',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
