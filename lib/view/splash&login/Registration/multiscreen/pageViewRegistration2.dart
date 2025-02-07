import 'dart:convert';
import 'dart:typed_data';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/view/splash&login/Registration/multiscreen/AllSection/addressSection.dart';
import 'package:c9_app/view/splash&login/Registration/multiscreen/AllSection/bankSection.dart';
import 'package:c9_app/view/splash&login/Registration/multiscreen/AllSection/bankSection2.dart';
import 'package:c9_app/view/splash&login/Registration/multiscreen/AllSection/confirmationSection.dart';
import 'package:c9_app/view/splash&login/Registration/multiscreen/AllSection/contactSection.dart';
import 'package:c9_app/view/splash&login/Registration/multiscreen/AllSection/personalSection.dart';
import 'package:c9_app/view/splash&login/Registration/multiscreen/AllSection/personalSection2.dart';
import 'package:c9_app/view/splash&login/Registration/multiscreen/AllSection/preferencesSection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as https;
import '../../../../utils/utils.dart';

class MultiStepRegistration2 extends StatefulWidget {
  @override
  _MultiStepRegistration2State createState() => _MultiStepRegistration2State();
}

class _MultiStepRegistration2State extends State<MultiStepRegistration2> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isBankStep = false;


  // final List<GlobalKey<FormState>> _formKeys = List.generate(6, (_) => GlobalKey<FormState>());
  final List<GlobalKey<FormState>> _formKeys = List.generate(4, (_) => GlobalKey<FormState>());

  ///niNumberValidationError
  String? niNumberValidationError;

  late TextEditingController nameController;
  late TextEditingController nickNameController;

  ///Personal Section-1
  late TextEditingController firstnameController;
  late TextEditingController lastnameController;
  String? selectedGender;
  late TextEditingController dobController;

  Uint8List? _selectedImageData;
  String? _selectedImageName;
  String? imageValidationError;

  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController reEnterpasswordController;

  ///Section-2
  late TextEditingController address1Controller;
  late TextEditingController address2Controller;
  late TextEditingController townCityController;
  late TextEditingController postCodeController;
  late TextEditingController phoneController;
  late TextEditingController alterphoneController;
  late TextEditingController emgNameController;
  late TextEditingController emgNumController;

  ///Section-3
  String? selectedRole;
  String? selectedCM;
  late TextEditingController consultantController;
  late TextEditingController passportNumController;
  late TextEditingController nationalNumController;
  // late TextEditingController medicalController;
  // String? medicalValidationError;
  String? selectedCitizenUk;
  String? selectedRightToWork;
  String? selectedOptOut;
  String? selectedDBS;
  String? selectedDBSCheckType;
  String? selectedMaritalStatus;
  String? selectedonCriminalConviction;
  late TextEditingController specifyController;
  late TextEditingController niNumberController;

  ///Fitness Section
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

  ///Bank Section
  List<String> selectedLicenseTypes = [];
  late TextEditingController liNumberController;
  String? liNumberValidationError;
  late TextEditingController anyEndorsmentController;
  late TextEditingController cpcNumController;
  late TextEditingController techoNumberController;

  String? selectedUKDriving;
  String? selectedUKHold;
  String? selectedUKPenalty;
  String? selectedValidCPC;
  String? selectedValidTacho;
  late TextEditingController dlNumberController;
  late TextEditingController dlIssueController;
  late TextEditingController dlCategoryController;
  late TextEditingController dlCheckController;
  late TextEditingController expiryController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    nickNameController = TextEditingController();
    ///Personal Section
    firstnameController = TextEditingController();
    lastnameController = TextEditingController();
    selectedGender;
    _selectedImageData;
    imageValidationError = null;
    dobController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    reEnterpasswordController = TextEditingController();
    ///section-2
    address1Controller = TextEditingController();
    address2Controller = TextEditingController();
    townCityController = TextEditingController();
    postCodeController = TextEditingController();
    phoneController = TextEditingController();
    alterphoneController = TextEditingController();
    emgNameController = TextEditingController();
    emgNumController = TextEditingController();
    passportNumController = TextEditingController();
    nationalNumController = TextEditingController();
    ///Section-3
    selectedRole;
    selectedCM;
    consultantController = TextEditingController();
    selectedRightToWork;
    selectedOptOut;
    selectedDBS;
    selectedDBSCheckType;
    selectedMaritalStatus;
    selectedonCriminalConviction;
    specifyController = TextEditingController();
///Fitness section
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
    ///Personal Section Ended



    ///NI Number
    niNumberController = TextEditingController();

    ///Bank Section
    liNumberController = TextEditingController();
    liNumberValidationError = null;
    anyEndorsmentController = TextEditingController();
    cpcNumController = TextEditingController();
    techoNumberController = TextEditingController();
    expiryController = TextEditingController();

    selectedUKDriving ;
    selectedUKHold ;
    selectedUKPenalty ;
    selectedValidCPC ;
    selectedValidTacho;
    dlNumberController = TextEditingController();
    dlIssueController = TextEditingController();
    dlCategoryController = TextEditingController();
    dlCheckController = TextEditingController();
    _loadFormData();
  }

  Future<void> _loadFormData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedRole = prefs.getString('role');
      nameController.text = prefs.getString('name') ?? '';
      nickNameController.text = prefs.getString('nickname') ?? '';

      ///Personal Section
      firstnameController.text = prefs.getString('first_name') ?? '';
      lastnameController.text = prefs.getString('last_name') ?? '';

      ///Section-2
      address1Controller.text = prefs.getString('addressLine1') ?? '';
      address2Controller.text = prefs.getString('addressLine2') ?? '';
      niNumberController.text = prefs.getString('ni_number') ?? '';

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
      expiryController.text = prefs.getString('dbsExpiry') ?? '';

      selectedUKDriving = prefs.getString('UKDriving');
      selectedUKHold = prefs.getString('UKHold');
      selectedUKPenalty = prefs.getString('UKPenalty');
      selectedValidCPC = prefs.getString('noCpcCard');
      selectedValidTacho = prefs.getString('noTachoCard');
      dlNumberController.text = prefs.getString('dlNumber') ?? '';
      dlIssueController.text = prefs.getString('dlIssue') ?? '';
      dlCategoryController.text = prefs.getString('dlCategory') ?? '';
      dlCheckController.text = prefs.getString('dlCheck') ?? '';
    });
  }

  Future<void> _saveFormData() async {
    final prefs = await SharedPreferences.getInstance();
    if (selectedRole != null) prefs.setString('role', selectedRole!);
    prefs.setString('name', nameController.text);
    prefs.setString('nickname', nickNameController.text);

    prefs.setString('first_name', firstnameController.text);
    prefs.setString('last_name', lastnameController.text);

    ///Section-2
    prefs.setString('addressLine1', address1Controller.text);
    prefs.setString('addressLine2', address2Controller.text);
    ///NI Number
    prefs.setString('ni_number', niNumberController.text);

    ///Bank Section
// Saving a list
    prefs.setString('selectedLicenseTypes', jsonEncode(selectedLicenseTypes));
    print("Saving selectedLicenseTypes: $selectedLicenseTypes");

    prefs.setString('licenceNumber', liNumberController.text);
    prefs.setString('licenceEndorsements', anyEndorsmentController.text);
    prefs.setString('cpcNumber', cpcNumController.text);
    prefs.setString('tachoNumber', techoNumberController.text);
    prefs.setString('dbsExpiry', expiryController.text);

    if (selectedUKDriving != null) prefs.setString('UKDriving', selectedUKDriving!);
    if (selectedUKHold != null) prefs.setString('UKHold', selectedUKHold!);
    if (selectedUKPenalty != null) prefs.setString('UKPenalty', selectedUKPenalty!);
    if (selectedValidCPC != null) prefs.setString('noCpcCard', selectedValidCPC!);
    if (selectedValidTacho != null) prefs.setString('noTachoCard', selectedValidTacho!);
    prefs.setString('dlNumber', dlNumberController.text);
    prefs.setString('dlIssue', dlIssueController.text);
    prefs.setString('dlCategory', dlCategoryController.text);
    prefs.setString('dlCheck', dlCheckController.text);

  }

  void _goToStep(int step) {
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentStep = step;
      // _isBankStep = _currentStep == 3;
      _isBankStep = _currentStep == 1;
    });
  }

  Future<bool> _postPersonalData(int currentStep) async {
    print("-------------API Hit for Step $currentStep--------------");
    // Utils.showDialogLoading(context);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String _token = prefs.getString('token') ?? '';

      String apiUrl = '${AppUrl.baseUrl}/api/app/staff-registration';
      var request = https.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers.addAll({
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
      });

      // Handle different steps dynamically
      if (currentStep == 0) {
        // Personal Information Screen
        request.fields['first_name'] = firstnameController.text;
        request.fields['last_name'] = lastnameController.text;

        ///Section-2
        request.fields['addressLine1'] = address1Controller.text;
        request.fields['addressLine2'] = address2Controller.text;

      } else if (currentStep == 1) {
        final Map<String, String> licenseTypeMap = {
          'Class B': 'classB',
          'Class C': 'classC',
          'Class D': 'classD',
          'Class D1': 'classD1',
          'Class E': 'classE',
        };
        ///Bank Section
        List<String> postedLicenseTypes = [];
        for (int i = 0; i < selectedLicenseTypes.length; i++) {
          // Map user-selected types to API-compatible values
          String postedValue = licenseTypeMap[selectedLicenseTypes[i]] ?? '';

          if (postedValue.isNotEmpty) {
            // Add to the request fields with indexed keys
            request.fields['licenceTypes[$i]'] = postedValue;
            postedLicenseTypes.add(postedValue);
          }
        }
        // Debugging log to ensure the data is processed correctly
        print('Licence Types to Post: $postedLicenseTypes');
        request.fields['licenceEndorsements'] = anyEndorsmentController.text;
        request.fields['cpcNumber'] = cpcNumController.text;
        request.fields['tachoNumber'] = techoNumberController.text;

        request.fields['uk_driving_experience'] = selectedUKDriving == 'Yes' ? '1' : '0';
        print("-------------$selectedUKDriving");
        request.fields['valid_uk_driving_license'] = selectedUKHold == 'Yes' ? '1' : '0';
        request.fields['penalty_points'] = selectedUKPenalty == 'Yes' ? '1' : '0';
        request.fields['noCpcCard'] = selectedValidCPC == 'Yes' ? '1' : '0';
        request.fields['noTachoCard'] = selectedValidTacho == 'Yes' ? '1' : '0';
        request.fields['dlNumber'] = dlNumberController.text;
        request.fields['dlIssue'] = dlIssueController.text;
        request.fields['dlCategory'] = dlCategoryController.text;
        request.fields['dlCheck'] = dlCheckController.text;

      } else if (currentStep == 2) {
        // Contact Information Screen
        request.fields['ni_number'] = niNumberController.text;
      } else if (currentStep == 3) {
        // Contact Information Screen
        request.fields['licenceNumber'] = liNumberController.text;
      }

      // Debugging logs
      print("API URL: $apiUrl");
      print("Headers: ${request.headers}");
      print("Fields: ${request.fields}");

      var response = await request.send();
      String responseString = await response.stream.bytesToString();
      print('Request fields: ${request.fields}');
      print('Response status code: ${response.statusCode}');
      print('Response body: $responseString');

      if (response.statusCode == 201) {
        print("API Request Successful for Step $currentStep");
        Utils.flushBarSuccessMessage('Data submitted successfully', context);
        return true; // Success
      } else if (response.statusCode == 422) {
        // Parse the validation errors
        final responseData = jsonDecode(responseString) as Map<String, dynamic>;
        if (responseData.containsKey('errors')) {
          final validationErrors = responseData['errors'] as Map<String, dynamic>;
          // Navigator.pop(context);
          setState(() {
            // Update the validation errors based on currentStep
            if (currentStep == 0) {} else if (currentStep == 1) {
              ///Bank Section
            } else if (currentStep == 2) {
              niNumberValidationError = validationErrors['ni_number']?.join(', ');
            } else if (currentStep == 3) {
              liNumberValidationError = validationErrors['licenceNumber']?.join(', ');
            }
          });
        }
        // Utils.flushBarErrorMessage('Validation error: $responseString', context);
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
  List<String> failedFields = [];

  bool _isLoading = false;
  void _nextStep() async {
    FocusScope.of(context).unfocus();
    if (_formKeys[_currentStep].currentState != null) {
      setState(() {
        _isLoading = true; // Start loading

      });
      if (_formKeys[_currentStep].currentState!.validate()) {
        _formKeys[_currentStep].currentState!.save();
        _saveFormData(); // Save data after successful validation
        setState(() {
          _isLoading = false; // Start loading
        });
        if (_currentStep == 0) {
          // firstNameEditing=false;
          // print("Next Step---$firstNameEditing");
          print("Step 0: Personal Information");

          await _postPersonalData(0);
            // Move to the next step if there are no validation errors
            _goToStep(_currentStep + 1);

        } else if (_currentStep == 1) {
          print("Step 1: Address Information");
          await _postPersonalData(1);

            _goToStep(_currentStep + 1);

        } else if (_currentStep == 2) {
          print("Step 2: Contact Information");
          await _postPersonalData(2);
          if (niNumberValidationError == null) {
            _goToStep(_currentStep + 1);
          }
        } else if (_currentStep == 3) {
          await _postPersonalData(3);
          if (liNumberValidationError == null) {
            _goToStep(_currentStep + 1);
          }
        } else if (_currentStep == 4) {
          print(_currentStep);
          _goToStep(_currentStep + 1);
        }
      }
      else if (_currentStep==0){

        // Collect validation errors for each field
        print("Form validation failed for the following fields:");
        // List<String> failedFields = [];

        if (firstnameController.text.isEmpty ) {
          print('firstnameController validation failed');
          failedFields.add('firstnameController');
        }
        if (lastnameController.text.isEmpty ) {
          print('lastnameController validation failed');
          failedFields.add('lastnameController');
        }

        if (address1Controller.text.isEmpty ) {
          print('address1Controller validation failed');
          failedFields.add('address1Controller');
        }
        if (address2Controller.text.isEmpty ) {
          print('address2Controller validation failed');
          failedFields.add('address2Controller');
        }
        // Scroll to the first validation error field
        if (failedFields.isNotEmpty) {
          String firstFailedField = failedFields.first;
          // scrolledtoField(firstFailedField);
        }
      }
    }
  }

  ScrollController _scrollController = ScrollController();

  void _previousStep() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    }
  }

  // Callback for the Finish button in BankStep
  void _onFinishBankStep() {
    setState(() {
      // _goToStep(4); // Move to PreferencesStep (step 5)
      _goToStep(2); // Move to PreferencesStep (step 5)
    });
  }
  void _onFinishPersonalStep() {
    setState(() {
      _goToStep(1);
    });
  }
  void _onPreviousStep() {
    setState(() {
      // _goToStep(2);
      _goToStep(0);
    });
  }


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
  final List<IconData> _stepIcons = [
    Icons.work, // CRM
    Icons.fitness_center, // Fitness
    Icons.rule, // Compliance
    Icons.check_circle, // Complete
  ];

  final List<String> _stepLabels = [
    'Personal',
    'Compliance',
    'Payroll',
    'Complete',
  ];

  Widget body() {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(height: screenHeight * 0.013,),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   // children: List.generate(6, (index) {
            //   children: List.generate(4, (index) {
            //     bool isCompleted = index < _currentStep; // Completed steps
            //     bool isCurrent = index == _currentStep; // Current step
            //     // bool isLastStep = index == 5;
            //     bool isLastStep = index == 3;
            //
            //     return Row(
            //       children: [
            //         // Circle for the step
            //         CircleAvatar(
            //           radius: MediaQuery.of(context).size.width * 0.035,
            //           backgroundColor: isCompleted || isCurrent ? Colors.green : AppColors.navColor,
            //           child: isCompleted
            //               ? const Icon(Icons.check, size: 15, color: Colors.white) // Checkmark for completed steps
            //               : Text(
            //             '${index + 1}', // Display step number
            //             style: TextStyle(
            //               color: isCurrent ? Colors.white : Colors.white,
            //               fontWeight: FontWeight.bold,
            //             ),
            //           ),
            //         ),
            //         // Line connecting circles
            //         if (!isLastStep)
            //           Container(
            //             width: screenWidth*0.225,
            //             height: screenHeight * 0.004,
            //             color: isCompleted ? Colors.green : AppColors.navColor,
            //           ),
            //       ],
            //     );
            //   }),
            // ),
            Column(
              children: [
                // Row for circles and lines
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    bool isCompleted = index < _currentStep; // Completed steps
                    bool isCurrent = index == _currentStep; // Current step

                    return Row(
                      children: [
                        // Half-line before the first circle
                        if (index == 0)
                          Container(
                            width: MediaQuery.of(context).size.width * 0.05, // Half-width line
                            height: 2,
                            color: isCompleted ? Colors.green : AppColors.navColor,
                          ),
                        // Circle with the icon
                        CircleAvatar(
                          radius: MediaQuery.of(context).size.width * 0.035,
                          backgroundColor: isCompleted || isCurrent ? Colors.green : AppColors.navColor,
                          child: isCompleted
                              ? const Icon(Icons.check, size: 15, color: Colors.white) // Checkmark for completed steps
                              : Icon(
                            _stepIcons[index],
                            size: 15,
                            color: isCurrent ? Colors.white : Colors.white70,
                          ),
                        ),
                        // Full line between circles, and half-line after the last circle
                        if (index < 3)
                          Container(
                            width: MediaQuery.of(context).size.width * 0.18, // Full-width line
                            height: 2,
                            color: isCompleted ? Colors.green : AppColors.navColor,
                          ),
                        if (index == 3)
                          Container(
                            width: MediaQuery.of(context).size.width * 0.05, // Half-width line
                            height: 2,
                            color: isCompleted ? Colors.green : AppColors.navColor,
                          ),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 8), // Space between circles and labels
                // Row for text labels under each circle
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return Container(
                      width: MediaQuery.of(context).size.width * 0.25, // Align text under the circles
                      alignment: Alignment.center,
                      child: Text(
                        _stepLabels[index],
                        style: TextStyle(
                          fontSize: 12,
                          color: index <= _currentStep ? Colors.green : AppColors.navColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),



            // SizedBox(height: screenHeight * 0.013,),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  PersonalSection2(
                    scrollController: _scrollController,
                    onFinishPersonalStep: _onFinishPersonalStep,
                    onPrevious: _onPreviousStep,
                    formKey: _formKeys[0],
                    firstnameController: firstnameController,
                    lastnameController: lastnameController,
                    onGenderChange: (gender) {
                      setState(() {
                        selectedGender = gender;
                      });
                    },
                    dobController: dobController,
                    onImageChange: (Uint8List? imageData, String? imageName) {
                      setState(() {
                        _selectedImageData = imageData;
                        _selectedImageName = imageName;
                        imageValidationError = null;
                      });
                    },
                    emailController: emailController,
                    passwordController: passwordController,
                    reEnterpasswordController: reEnterpasswordController,
                    ///Section-2
                    address1Controller: address1Controller,
                    address2Controller: address2Controller,
                    townCityController: townCityController,
                    postCodeController: postCodeController,
                    phoneController: phoneController,
                    alterphoneController: alterphoneController,
                    emgNameController: emgNameController,
                    emgNumController: emgNumController,
                    ///Section-3
                    onRoleChange: (role) {
                      setState(() {
                        selectedRole = role;
                      });
                    },
                    onCommunicationChange: (communication) {
                      setState(() {
                        selectedCM = communication;
                      });
                    },
                    consultantController: consultantController,
                    passportNumController: passportNumController,
                    nationalNumController: nationalNumController,
                    specifyController: specifyController,
                    // medicalController: medicalController,
                    onCitizenUkChange: (CitizenUk) {setState(() {selectedCitizenUk = CitizenUk;});},
                    onRightToWorkChange: (rightToWork) {setState(() {selectedRightToWork = rightToWork;});},
                    onoptOutChange: (optOut) {setState(() {selectedOptOut = optOut;});},
                    onDBSChange: (dbs) {setState(() {selectedDBS = dbs;});},
                    onDBSCheckTypeChange: (dbsCheckType) {setState(() {selectedDBSCheckType = dbsCheckType;});},
                    onMarriedChange: (marriedchange) {setState(() {selectedMaritalStatus = marriedchange;});},
                    onCriminalConvictionChange: (criminalConviction) {setState(() {selectedonCriminalConviction = criminalConviction;});},

                    ///Fitness Section
                    onPhysicalIncapabilitiesChange: (PhysicalIncapabilities) {setState(() {selectedPhysicalIncapabilities = PhysicalIncapabilities;});},
                    onMedicalConditionsChange: (MedicalConditions) {setState(() {selectedMedicalConditions = MedicalConditions;});},
                    onMedicationChange: (Medication) {setState(() {selectedMedication = Medication;});},
                    onDrugsChange: (Drugs) {setState(() {selectedDrugs = Drugs;});},
                    lastWearGlassController:lastWearGlassController,
                    onWearGlassesChange: (WearGlasses) {setState(() {selectedWearGlasses = WearGlasses;});},
                    onMedicalReasonsChange: (MedicalReasons) {setState(() {selectedMedicalReasons = MedicalReasons;});},
                    onLast3YearsChange: (Last3Years) {setState(() {selectedLast3Years = Last3Years;});},
                      detailsMedicalController:detailsMedicalController,
                      detailsMedicationController:detailsMedicationController,
                      detailsReasonController:detailsReasonController,
                      detailesDrivingRolesController:detailesDrivingRolesController,
                  ),

                  BankStep2(
                    // formKey: _formKeys[3],
                    formKey: _formKeys[1],
                    onFinish: _onFinishBankStep,
                    onPrevious: _onPreviousStep,
                    onLicenseTypesChange: (List<String> licenseTypes) {
                      setState(() {
                        selectedLicenseTypes = licenseTypes; // Update the selected license types
                      });
                    },
                    liNumberController: liNumberController,
                    anyEndorsmentController: anyEndorsmentController,
                    cpcNumController: cpcNumController,
                    techoNumberController: techoNumberController,

                    onUKDrivingChange: (UKDriving) {
                      setState(() {
                        selectedUKDriving = UKDriving;
                      });
                    },
                    onUKHoldChange: (UKHold) {
                      setState(() {
                        selectedUKHold = UKHold;
                      });
                    },
                    onUKPenaltyChange: (UKPenalty) {
                      setState(() {
                        selectedUKPenalty = UKPenalty;
                      });
                    },
                    onValidCPCChange: (ValidCPC) {
                      setState(() {
                        selectedValidCPC = ValidCPC;
                      });
                    },
                    onValidTachoChange: (ValidTacho) {
                      setState(() {
                        selectedValidTacho = ValidTacho;
                      });
                    },
                    dlNumberController: dlNumberController,
                    dlIssueController: dlIssueController,
                    dlCategoryController: dlCategoryController,
                    dlCheckController: dlCheckController,


                    expiryController: expiryController,
                    selectedRole: selectedRole ?? "",

                  ),
                  PreferencesStep(
                    // formKey: _formKeys[4],
                    formKey: _formKeys[2],
                  ),
                  ConfirmationStep(
                    // formKey: _formKeys[5],
                    formKey: _formKeys[3],
                  ),
                ],
              ),
            ),
            Container(
              width: screenWidth * 0.95,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0 && !_isBankStep)
                    InkWell(
                      onTap: _previousStep,
                      child: ButtonContainer(
                        "Previous",
                        AppColors.blackOpacity, // Background color
                        Colors.black,
                      ),
                    ),
                  // if (_currentStep < 5 && !_isBankStep)
                  // if (_currentStep == 0 )
                  //   InkWell(
                  //     onTap: (){
                  //       Navigator.pop(context);
                  //     },
                  //     child: ButtonContainer(
                  //       "Back",
                  //       AppColors.blackOpacity, // Background color
                  //       Colors.black,
                  //     ),
                  //   ),
                  if (_currentStep > 0 && _currentStep < 3 && !_isBankStep)
                    InkWell(
                      onTap: _nextStep,
                      child: ButtonContainer(
                        "Next", AppColors.navButtonColor,
                        Colors.white,
                      ),
                    ),
                  // if (_currentStep == 5)
                  if (_currentStep == 3)
                    InkWell(
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Registration Completed! Name: ${nameController.text},'
                                      ' Address: ${address1Controller.text},'
                                      ' ni number: ${niNumberController.text},'
                                      'License Number: ${liNumberController.text},'
                                      'First Name: ${firstnameController.text},'
                                      'Last Name: ${lastnameController.text},'
                                      )),
                        );
                        setState(() {
                          prefs.remove('first_name');
                          prefs.remove('last_name');
                          prefs.remove('licenceNumber');
                          prefs.remove('dbsExp');
                        });
                      },
                      child: ButtonContainer(
                        "Finish",
                        Colors.green,
                        Colors.white,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget ButtonContainer(String? label, Color color1, Color color2) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return Container(
      height: screenHeight*0.05,
      width: screenWidth*0.23,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: color1,
      ),
      child: Center(
        child: Text(
          label ?? '',
          style: TextStyle(
            color: color2,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    nickNameController.dispose();
    address1Controller.dispose();
    niNumberController.dispose();
    super.dispose();
  }
}
