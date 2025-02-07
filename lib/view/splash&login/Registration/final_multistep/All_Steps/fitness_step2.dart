import 'package:auto_size_text/auto_size_text.dart';
import 'package:c9_app/view/splash&login/Registration/final_multistep/All_Steps/Widgets/datepicker_with_formField.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/view/widgets/custom_Validator_formfield.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as https;
import '../../../../../utils/utils.dart';

class FitnessStep2 extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final VoidCallback onStep2;
  FitnessStep2({
    Key? key,
    required this.formKey,
    required this.onStep2,

  }) : super(key: key);

  @override
  _FitnessStep2State createState() => _FitnessStep2State();
}

class _FitnessStep2State extends State<FitnessStep2> {

  ///Fitness Section
  final List<String> _fitnessDropdownOptions = ['Yes', 'No'];
  String? selectedPhysicalIncapabilities;
  String? selectedMedicalConditions;
  String? selectedMedication;
  String? selectedDrugs;
  String? selectedWearGlasses;
  late TextEditingController lastWearGlassController;
  String? selectedMedicalReasons;
  String? selectedLast3Years;
  late TextEditingController detailsMedicalController;
  late TextEditingController detailsMedicationController;
  late TextEditingController detailsReasonController;
  late TextEditingController detailesDrivingRolesController;

  @override
  void initState() {
    super.initState();
    selectedPhysicalIncapabilities;
    selectedMedicalConditions;
    selectedMedication;
    selectedDrugs;
    selectedWearGlasses;
    lastWearGlassController=TextEditingController();
    selectedMedicalReasons;
    selectedLast3Years;
    detailsMedicalController=TextEditingController();
    detailsMedicationController=TextEditingController();
    detailsReasonController=TextEditingController();
    detailesDrivingRolesController=TextEditingController();
    _loadFormData();
  }


  Future<void> _loadFormData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      ///Fitness Section
      selectedPhysicalIncapabilities = prefs.getString('PhysicalIncapabilities');
      selectedMedicalConditions = prefs.getString('MedicalConditions');
      selectedMedication = prefs.getString('Medication');
      selectedDrugs = prefs.getString('Drugs');
      selectedWearGlasses = prefs.getString('WearGlasses');
      lastWearGlassController.text = prefs.getString('lasteyetest') ?? '';
      selectedMedicalReasons = prefs.getString('MedicalReasons');
      selectedLast3Years = prefs.getString('Last3Years');

      detailsMedicalController.text = prefs.getString('medicalconditiondetails') ?? '';
      detailsMedicationController.text = prefs.getString('medicationdetails') ?? '';
      detailsReasonController.text = prefs.getString('dismissalreason') ?? '';
      detailesDrivingRolesController.text = prefs.getString('drivingdismissaldetails') ?? '';

    });
  }

  Future<void> _saveFormData() async {
    final prefs = await SharedPreferences.getInstance();
    ///Fitness Section
    if (selectedPhysicalIncapabilities != null) prefs.setString('PhysicalIncapabilities', selectedPhysicalIncapabilities!);
    if (selectedMedicalConditions != null) prefs.setString('MedicalConditions', selectedMedicalConditions!);
    if (selectedMedication != null) prefs.setString('Medication', selectedMedication!);
    if (selectedDrugs != null) prefs.setString('Drugs', selectedDrugs!);
    if (selectedWearGlasses != null) prefs.setString('WearGlasses', selectedWearGlasses!);
    prefs.setString('lasteyetest', lastWearGlassController.text);
    if (selectedMedicalReasons != null) prefs.setString('MedicalReasons', selectedMedicalReasons!);
    if (selectedLast3Years != null) prefs.setString('Last3Years', selectedLast3Years!);
    prefs.setString('medicalconditiondetails',detailsMedicalController.text);
    prefs.setString('medicationdetails', detailsMedicationController.text);
    prefs.setString('dismissalreason', detailsReasonController.text);
    prefs.setString('drivingdismissaldetails', detailesDrivingRolesController.text);
  }

  Future<bool> _postFitnessStep(int subCurrentStep) async {
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

      ///Fitness Section
      request.fields['physical_incapabilities'] = selectedPhysicalIncapabilities == 'Yes' ? '1' : '0';
      request.fields['ongoing_medical_conditions'] = selectedMedicalConditions == 'Yes' ? '1' : '0';
      if (selectedMedicalConditions == 'Yes')
        request.fields['medical_condition_details'] = detailsMedicalController.text;
      request.fields['taking_medication"'] = selectedMedication == 'Yes' ? '1' : '0';
      if (selectedMedication == 'Yes')
        request.fields['medication_details'] = detailsMedicationController.text;
      request.fields['drug_or_alcohol_issues'] = selectedDrugs == 'Yes' ? '1' : '0';
      request.fields['wears_glasses'] = selectedWearGlasses == 'Yes' ? '1' : '0';
      request.fields['last_eye_test'] = lastWearGlassController.text;
      request.fields['dismissed_for_medical_reasons'] = selectedMedicalReasons == 'Yes' ? '1' : '0';
      if (selectedMedicalReasons == 'Yes')
        request.fields['dismissal_reason'] = detailsReasonController.text;
      request.fields['dismissed_from_driving_roles'] = selectedLast3Years == 'Yes' ? '1' : '0';
      if (selectedLast3Years == 'Yes')
        request.fields['driving_dismissal_details'] = detailesDrivingRolesController.text;

      print("API URL: $apiUrl");
      print("Headers: ${request.headers}");
      print("Fields: ${request.fields}");

      var response = await request.send();
      String responseString = await response.stream.bytesToString();
      print('Request fields: ${request.fields}');
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
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return SingleChildScrollView(
      child: Form(
        key: widget.formKey,
        child: Column(
          children: [
            Container(
              height: 45,
              width: screenWidth *0.95,
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
                  "Fitness to Work",
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
                    title: "Do you have any physical incapabilities?",
                    options: _fitnessDropdownOptions,
                    selectedOption: selectedPhysicalIncapabilities,
                    onChanged: (newValue) async {
                      setState(() {
                        selectedPhysicalIncapabilities = newValue;
                      });
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setString('PhysicalIncapabilities', newValue ?? "");
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select an option.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight * .013,),
                  ConditionalDropdown(
                    title: "Do you have any ongoing medical conditions?",
                    options: _fitnessDropdownOptions,
                    selectedOption: selectedMedicalConditions,
                    onChanged: (newValue) async {
                      setState(() {
                        selectedMedicalConditions = newValue;
                      });
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setString('MedicalConditions', newValue ?? "");
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select an option.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight * .013,),
                  if (selectedMedicalConditions == 'Yes')...[
                    CustomValidateFormField(
                      controller: detailsMedicalController,
                      titleText: "Details of medical conditions, if any.",
                      requiredStar: " *",
                      hintText: 'Enter details of medical conditions.',
                      validator: (value) {
                        if (selectedMedicalConditions == 'Yes' && (value == null || value.isEmpty)) {
                          return 'This field cannot be empty';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenHeight * .013,),
                  ],

                  ConditionalDropdown(
                    title: "Are you currently taking any medication?",
                    options: _fitnessDropdownOptions,
                    selectedOption: selectedMedication,
                    onChanged: (newValue) async {
                      setState(() {
                        selectedMedication = newValue;
                      });
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setString('Medication', newValue ?? "");
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select an option.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight * .013,),

                  if (selectedMedication == 'Yes')...[
                    CustomValidateFormField(
                      controller: detailsMedicationController,
                      titleText: "Details of medication, if any.",
                      requiredStar: " *",
                      hintText: 'Enter details of medication.',
                      validator: (value) {
                        if (selectedMedication == 'Yes' && (value == null || value.isEmpty)) {
                          return 'This field cannot be empty';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenHeight * .013,),
                  ],

                  ConditionalDropdown(
                    title: "Do you have ongoing issues with drugs or alcohol?",
                    options: _fitnessDropdownOptions,
                    selectedOption: selectedDrugs,
                    onChanged: (newValue) async {
                      setState(() {
                        selectedDrugs = newValue;
                      });
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setString('Drugs', newValue ?? "");
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select an option.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight * .013,),
                  ConditionalDropdown(
                    title: "Do you currently wear glasses?",
                    options: _fitnessDropdownOptions,
                    selectedOption: selectedWearGlasses,
                    onChanged: (newValue) async {
                      setState(() {
                        selectedWearGlasses = newValue;
                      });

                      // Post the selected value
                      final valueToPost = newValue == 'Yes' ? 1 : 0;
                      if (newValue != null) {
                        print("Value to post: $valueToPost");
                      }
                      // Save to SharedPreferences
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setString('WearGlasses', newValue ?? "");
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select an option.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight * .013,),

                  CustomDatePickerFormField(
                    title: "When was your last eye test?",
                    labelText: 'dd/mm/yyyy',
                    controller: lastWearGlassController,
                    validator: (value) {
                      if (lastWearGlassController.text== null || lastWearGlassController.text.isEmpty) {
                        return 'Date is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight * .013,),

                  ConditionalDropdown(
                    title: "Have you ever been dismissed for medical reasons?",
                    options: _fitnessDropdownOptions,
                    selectedOption: selectedMedicalReasons,
                    onChanged: (newValue) async {
                      setState(() {
                        selectedMedicalReasons = newValue;
                      });
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setString('MedicalReasons', newValue ?? "");
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select an option.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight * .013,),
                  if (selectedMedicalReasons == 'Yes')...[
                    CustomValidateFormField(
                      controller: detailsReasonController,
                      titleText: "Reason for dismissal due to medical reasons.",
                      requiredStar: " *",
                      hintText: 'Enter details of dismissal reasons.',
                      validator: (value) {
                        if (selectedMedicalReasons == 'Yes' && (value == null || value.isEmpty)) {
                          return 'This field cannot be empty';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenHeight * .013,),
                  ],

                  ConditionalDropdown(
                    title: "Have you been dismissed from previous driving roles in the last 3 years?",
                    options: _fitnessDropdownOptions,
                    selectedOption: selectedLast3Years,
                    onChanged: (newValue) async {
                      setState(() {
                        selectedLast3Years = newValue;
                      });
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setString('Last3Years', newValue ?? "");
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select an option.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight * .013,),
                  if (selectedLast3Years == 'Yes')...[
                    CustomValidateFormField(
                      controller:detailesDrivingRolesController,
                      titleText: "Reasons/dates for dismissal from driving roles.",
                      requiredStar: " *",
                      hintText: 'Enter reasons/dates for dismissal from driving roles.',
                      validator: (value) {
                        if (selectedLast3Years == 'Yes' && (value == null || value.isEmpty)) {
                          return 'This field cannot be empty';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: screenHeight * .013,),
                  ],
                ],
              ),
            ),


            SizedBox(height: screenHeight * .02,),

            GestureDetector(
              onTap: ()async{
                _saveFormData();
                if (widget.formKey.currentState?.validate() ?? false ) {
                  widget.onStep2();
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


  Widget DynamicDropdown({
    required String title,
    required List<String> options,
    required String selectedOption,
    required ValueChanged<String?> onChanged,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Container(
          width: screenWidth * 0.95,
          // color: Colors.black,
          child:Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Flexible(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                      children: [
                        TextSpan(text: title),
                      ],
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
                Text(
                  ' *',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.013),
        Container(
          width: screenWidth * 0.95,
          // height: screenHeight * 0.065,
          height: 55,
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            border: Border.all(
              color: Colors.grey.withOpacity(0.4),
              width: 0.4,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isDense: true,
              isExpanded: true,
              iconSize: 30.0,
              menuMaxHeight: 350,
              value: selectedOption,
              onChanged: onChanged,
              items: options.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
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
