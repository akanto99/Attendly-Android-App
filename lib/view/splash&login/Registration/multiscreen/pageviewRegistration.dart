import 'dart:convert';
import 'dart:typed_data';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/view/splash&login/Registration/multiscreen/AllSection/addressSection.dart';
import 'package:c9_app/view/splash&login/Registration/multiscreen/AllSection/bankSection.dart';
import 'package:c9_app/view/splash&login/Registration/multiscreen/AllSection/confirmationSection.dart';
import 'package:c9_app/view/splash&login/Registration/multiscreen/AllSection/contactSection.dart';
import 'package:c9_app/view/splash&login/Registration/multiscreen/AllSection/personalSection.dart';
import 'package:c9_app/view/splash&login/Registration/multiscreen/AllSection/preferencesSection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as https;
import '../../../../utils/utils.dart';

class MultiStepRegistration1 extends StatefulWidget {
  @override
  _MultiStepRegistration1State createState() => _MultiStepRegistration1State();
}

class _MultiStepRegistration1State extends State<MultiStepRegistration1> {
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
  String? firstNameValidationError;
   FocusNode firstnameFocusNode = FocusNode();
   bool firstNameEditing =true;
  late TextEditingController lastnameController;
  String? lastNameValidationError;
  FocusNode lastnameFocusNode = FocusNode();
  String? selectedGender;
  String? genderValidationError;
  late TextEditingController dobController;
  String? dobValidationError;

  Uint8List? _selectedImageData;
  String? _selectedImageName;
  String? imageValidationError;

  late TextEditingController emailController;
  String? emailValidationError;

  late TextEditingController passwordController;
  String? passwordValidationError;
  late TextEditingController reEnterpasswordController;
  String? repasswordValidationError;

  ///Section-2
  late TextEditingController address1Controller;
  String? addressLine1ValidationError;
  late TextEditingController address2Controller;
  String? addressLine2ValidationError;
  late TextEditingController townCityController;
  String? townCityValidationError;
  late TextEditingController postCodeController;
  String? postCodeValidationError;
  late TextEditingController phoneController;
  String? phoneValidationError;
  late TextEditingController alterphoneController;
  String? alterphoneValidationError;
  late TextEditingController emgNameController;
  String? emgNameValidationError;
  late TextEditingController emgNumController;
  String? emgNumValidationError;

  ///Section-3
  String? selectedRole;
  String? roleValidationError;

  String? selectedCM;
  String? cmValidationError;
  late TextEditingController consultantController;
  String? consultantValidationError;
  late TextEditingController passportNumController;
  String? passportNumValidationError;
  late TextEditingController nationalNumController;
  String? nationalNumValidationError;
  // late TextEditingController medicalController;
  // String? medicalValidationError;

  String? selectedCitizenUk;
  String? selectedRightToWork;
  String? selectedOptOut;
  String? selectedDBS;
  String? selectedDBSCheckType;

  String? selectedMaritalStatus;
  String? maritalStatusValidationError;
  String? selectedonCriminalConviction;
  late TextEditingController specifyController;
  String? specifyValidationError;

  late TextEditingController niNumberController;

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
    firstNameValidationError = null;
    lastnameController = TextEditingController();
    lastNameValidationError = null;
    selectedGender;
    genderValidationError = null;

    _selectedImageData;
    imageValidationError = null;

    dobController = TextEditingController();
    dobValidationError = null;

    emailController = TextEditingController();
    emailValidationError = null;
    passwordController = TextEditingController();
    passwordValidationError = null;
    reEnterpasswordController = TextEditingController();
    repasswordValidationError = null;
    ///section-2
    address1Controller = TextEditingController();
    addressLine1ValidationError=null;
    address2Controller = TextEditingController();
    addressLine2ValidationError=null;
    townCityController = TextEditingController();
    townCityValidationError = null;
    postCodeController = TextEditingController();
    postCodeValidationError = null;
    phoneController = TextEditingController();
    phoneValidationError = null;
    alterphoneController = TextEditingController();
    alterphoneValidationError = null;
    emgNameController = TextEditingController();
    emgNameValidationError = null;
    emgNumController = TextEditingController();
    emgNumValidationError = null;


    passportNumController = TextEditingController();
    passportNumValidationError = null;
    nationalNumController = TextEditingController();
    nationalNumValidationError = null;
    // medicalController = TextEditingController();
    // medicalValidationError = null;

    ///Section-3
    selectedRole;
    selectedCM;
    consultantController = TextEditingController();
    consultantValidationError = null;
    selectedRightToWork;
    selectedOptOut;
    selectedDBS;
    selectedDBSCheckType;
    roleValidationError = null;

 selectedMaritalStatus;
    maritalStatusValidationError=null;
    selectedonCriminalConviction;

    specifyController = TextEditingController();
    specifyValidationError = null;
    ///Personal Section Ended



    ///NI Number
    niNumberController = TextEditingController();
    lastNameValidationError = null;

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
    dlNumberController = TextEditingController();
    dlIssueController = TextEditingController();
    dlCategoryController = TextEditingController();
    dlCheckController = TextEditingController();
    _loadFormData();
  }

  Future<void> _loadFormData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nameController.text = prefs.getString('name') ?? '';
      nickNameController.text = prefs.getString('nickname') ?? '';

      ///Personal Section
      firstnameController.text = prefs.getString('first_name') ?? '';
      lastnameController.text = prefs.getString('last_name') ?? '';
      selectedGender = prefs.getString('gender');

      _selectedImageName = prefs.getString('imageName');
      String? base64Image = prefs.getString('image');
      if (base64Image != null) {
        _selectedImageData = base64Decode(base64Image);
      }
      dobController.text = prefs.getString('dob') ?? '';
      emailController.text = prefs.getString('email') ?? '';

      ///Section-2
      address1Controller.text = prefs.getString('addressLine1') ?? '';
      address2Controller.text = prefs.getString('addressLine2') ?? '';
      townCityController.text = prefs.getString('townorcity') ?? '';
      postCodeController.text = prefs.getString('postCode') ?? '';
      phoneController.text = prefs.getString('phone') ?? '';
      alterphoneController.text = prefs.getString('alterPhone') ?? '';
      emgNameController.text = prefs.getString('emerName') ?? '';
      emgNumController.text = prefs.getString('emerNum') ?? '';

      ///Section-3
      selectedRole = prefs.getString('role');
      selectedCM = prefs.getString('prefsMethod');
      consultantController.text = prefs.getString('consultant') ?? '';
      passportNumController.text = prefs.getString('passportNumber') ?? '';
      nationalNumController.text = prefs.getString('ni_number') ?? '';
      // medicalController.text = prefs.getString('medicalConditions') ?? '';

      selectedCitizenUk = prefs.getString('CitizenUk');
      selectedRightToWork = prefs.getString('rightToWorkUK');
      selectedOptOut = prefs.getString('optOutOfPension');
      selectedDBS = prefs.getString('dbsCheck');
      selectedDBSCheckType = prefs.getString('DBSCheckType');
      selectedMaritalStatus = prefs.getString('maritalStatus');
      selectedonCriminalConviction= prefs.getString('criminalConviction');
      specifyController.text = prefs.getString('specify') ?? '';

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
      dlNumberController.text = prefs.getString('dlNumber') ?? '';
      dlIssueController.text = prefs.getString('dlIssue') ?? '';
      dlCategoryController.text = prefs.getString('dlCategory') ?? '';
      dlCheckController.text = prefs.getString('dlCheck') ?? '';
    });
  }

  Future<void> _saveFormData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('name', nameController.text);
    prefs.setString('nickname', nickNameController.text);

    prefs.setString('first_name', firstnameController.text);
    prefs.setString('last_name', lastnameController.text);
    if (selectedGender != null) prefs.setString('gender', selectedGender!);
    if (_selectedImageData != null) {
      String base64Image = base64Encode(_selectedImageData!);
      prefs.setString('image', base64Image);
    }
    if (_selectedImageName != null) {
      prefs.setString('imageName', _selectedImageName!); // Save image name
    }
    prefs.setString('dob', dobController.text);
    prefs.setString('email', emailController.text);

    ///Section-2
    prefs.setString('addressLine1', address1Controller.text);
    prefs.setString('addressLine2', address2Controller.text);
    prefs.setString('townorcity', townCityController.text);
    prefs.setString('postCode', postCodeController.text);
    prefs.setString('phone', phoneController.text);
    prefs.setString('alterPhone', alterphoneController.text);
    prefs.setString('emerName', emgNameController.text);
    prefs.setString('emerNum', emgNumController.text);
    ///Section-3
    if (selectedRole != null) prefs.setString('role', selectedRole!);
    if (selectedCM != null) prefs.setString('prefsMethod', selectedCM!);
    prefs.setString('consultant', consultantController.text);
    prefs.setString('passportNumber', passportNumController.text);
    prefs.setString('ni_number', nationalNumController.text);
    // prefs.setString('medicalConditions', medicalController.text);
    if (selectedCitizenUk != null) prefs.setString('CitizenUk', selectedCitizenUk!);
    if (selectedRightToWork != null) prefs.setString('rightToWorkUK', selectedRightToWork!);
    if (selectedOptOut != null) prefs.setString('optOutOfPension', selectedOptOut!);
    if (selectedDBS != null) prefs.setString('dbsCheck', selectedDBS!);
    if (selectedDBSCheckType != null) prefs.setString('DBSCheckType', selectedDBSCheckType!);
    if (selectedMaritalStatus != null) prefs.setString('maritalStatus', selectedMaritalStatus!);
    if (selectedonCriminalConviction != null) prefs.setString('CriminalConviction', selectedonCriminalConviction!);
    prefs.setString('specify', specifyController.text);
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
        request.fields['gender'] = selectedGender ?? '';
        if (dobController.text.isNotEmpty) {
          request.fields['dob'] = DateFormat('yyyy-MM-dd').format(DateFormat('dd-MM-yyyy').parse(dobController.text));
        }
        if (_selectedImageData != null) {
          print("Image data is not null. Length: ${_selectedImageData!.length}");
          request.files.add(await https.MultipartFile.fromBytes(
            'image',
            _selectedImageData!,
            filename: _selectedImageName ?? 'image.jpg',
          ));
        }
        request.fields['email'] = emailController.text;
        request.fields['password'] = passwordController.text;
        request.fields['confirm_password'] = reEnterpasswordController.text;
        ///Section-2
        request.fields['addressLine1'] = address1Controller.text;
        request.fields['addressLine2'] = address2Controller.text;
        request.fields['townorcity'] = townCityController.text;
        request.fields['postCode'] = postCodeController.text;
        request.fields['phone'] = phoneController.text;
        request.fields['alterPhone'] = alterphoneController.text;
        request.fields['emerName'] = emgNameController.text;
        request.fields['emerNum'] = emgNumController.text;
        ///Section-3
        request.fields['role'] = selectedRole ?? '';
        request.fields['prefsMethod'] = selectedCM ?? '';
        request.fields['consultant'] = consultantController.text;
        request.fields['passportNumber'] = passportNumController.text;
        request.fields['ni_number'] = nationalNumController.text;
        // request.fields['medicalConditions'] = medicalController.text;
        request.fields['CitizenUk'] = selectedCitizenUk == 'Yes' ? '1' : '0';
        request.fields['rightToWorkUK'] = selectedRightToWork == 'Yes' ? '1' : '0';
        request.fields['dbsCheck'] = selectedDBS == 'Yes' ? '1' : '0';
        if(selectedDBS == 'Yes') {
          request.fields['DBSCheckType'] = selectedDBSCheckType == 'Yes' ? '1' : '0';
        }

        request.fields['optOutOfPension'] = selectedOptOut == 'Yes' ? '1' : '0';

        request.fields['uk_driving_experience'] = selectedUKDriving == 'Yes' ? '1' : '0';
        print("-------------$selectedUKDriving");
        request.fields['valid_uk_driving_license'] = selectedUKHold == 'Yes' ? '1' : '0';
        print("-------------$selectedUKHold");
        request.fields['penalty_points'] = selectedUKPenalty == 'Yes' ? '1' : '0';
        print("-------------$selectedUKPenalty");

        request.fields['maritalStatus'] = selectedMaritalStatus ?? '';
        request.fields['criminalConviction'] = selectedonCriminalConviction == 'Yes' ? '1' : '0';
        if(selectedonCriminalConviction== 'Yes'){
          request.fields['specify'] = specifyController.text;
        }

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
            if (currentStep == 0) {
              firstNameValidationError = validationErrors['first_name']?.join(', ');
              lastNameValidationError = validationErrors['last_name']?.join(', ');
              dobValidationError = validationErrors['dob']?.join(', ');
              genderValidationError = validationErrors['gender']?.join(', ');
              imageValidationError = validationErrors['image']?.join(', ');
              emailValidationError = validationErrors['email']?.join(', ');
              passwordValidationError = validationErrors['password']?.join(', ');
              repasswordValidationError = validationErrors['confirm_password']?.join(', ');
             ///section-2
              addressLine1ValidationError = validationErrors['addressLine1']?.join(', ');
              addressLine2ValidationError = validationErrors['addressLine2']?.join(', ');
              townCityValidationError = validationErrors['townorcity']?.join(', ');
              postCodeValidationError = validationErrors['postCode']?.join(', ');
              phoneValidationError = validationErrors['phone']?.join(', ');
              alterphoneValidationError = validationErrors['alterPhone']?.join(', ');
              emgNameValidationError = validationErrors['emerName']?.join(', ');
              emgNumValidationError = validationErrors['emerNum']?.join(', ');
              ///section-3
              roleValidationError = validationErrors['role']?.join(', ');
              consultantValidationError = validationErrors['consultant']?.join(', ');
              passportNumValidationError = validationErrors['passportNumber']?.join(', ');
              nationalNumValidationError = validationErrors['ni_number']?.join(', ');
              // medicalValidationError = validationErrors['medicalConditions']?.join(', ');
              maritalStatusValidationError = validationErrors['maritalStatus']?.join(', ');
              specifyValidationError = validationErrors['specify']?.join(', ');
              int errorCount = [
                firstNameValidationError,
                lastNameValidationError,
                genderValidationError,
                dobValidationError,
                imageValidationError,
                emailValidationError,
                passwordValidationError,
                repasswordValidationError,
                ///section-2
                addressLine1ValidationError,
                addressLine2ValidationError,
                townCityValidationError,
                postCodeValidationError,
                phoneValidationError,
                alterphoneValidationError,
                emgNameValidationError,
                emgNumValidationError,
                ///section-3
                roleValidationError,
                consultantValidationError,
                passportNumValidationError,
                nationalNumValidationError,
                // medicalValidationError,
                maritalStatusValidationError,
                specifyValidationError

              ].where((error) => error != null && error.isNotEmpty).length;

              // Display the appropriate message based on the error count
              if (errorCount == 0) {
                // Utils.flushBarSuccessMessage('All fields are valid!', context);
              } else {
                // Utils.flushBarErrorMessage(
                //   'Fields Are Empty',
                //   context,
                // );
              }
            } else if (currentStep == 1) {
              ///Bank Section
              addressLine1ValidationError = validationErrors['addressLine1']?.join(', ');
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

          if (
              firstNameValidationError == null &&
              lastNameValidationError == null &&
              genderValidationError == null &&
              imageValidationError == null &&
              dobValidationError == null &&
              emailValidationError == null &&
              passwordValidationError == null &&
              repasswordValidationError == null &&
              ///Section-2
              addressLine1ValidationError == null &&
              addressLine2ValidationError == null &&
              townCityValidationError == null &&
              postCodeValidationError == null &&
              phoneValidationError == null &&
              alterphoneValidationError == null &&
              emgNameValidationError == null &&
              emgNumValidationError == null &&

              ///section-3
              roleValidationError == null &&
              consultantValidationError == null &&
              passportNumValidationError == null &&
              nationalNumValidationError == null &&
              // medicalValidationError == null &&
                  maritalStatusValidationError == null &&
                  specifyValidationError == null
              ) {
            // Move to the next step if there are no validation errors
            _goToStep(_currentStep + 1);
          }
        } else if (_currentStep == 1) {
          print("Step 1: Address Information");
          await _postPersonalData(1);
          if (addressLine1ValidationError == null) {
            _goToStep(_currentStep + 1);
          }
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

        if (firstnameController.text.isEmpty  || firstNameValidationError!=null ) {
          print('firstnameController validation failed');
          failedFields.add('firstnameController');
        }
        if (lastnameController.text.isEmpty || lastNameValidationError!=null) {
          print('lastnameController validation failed');
          failedFields.add('lastnameController');
        }
        if (emailController.text.isEmpty || emailValidationError!=null) {
          print('emailController validation failed');
          failedFields.add('emailController');
        }
        if (selectedGender == null || selectedGender!.isEmpty) {
          print('selectedGender validation failed');
          failedFields.add('selectedGender');
        }
        if (_selectedImageData == null || _selectedImageData!.isEmpty) {
          print('_selectedImageData validation failed');
          failedFields.add('_selectedImageData');
        }

        if (dobController.text.isEmpty || dobValidationError!=null) {
          print('dobController validation failed');
          failedFields.add('dobController');
        }
        if (passwordController.text.isEmpty || passwordValidationError!=null) {
          print('passwordController validation failed');
          failedFields.add('passwordController');
        }
        if (reEnterpasswordController.text.isEmpty || repasswordValidationError!=null) {
          print('reEnterpasswordController validation failed');
          failedFields.add('reEnterpasswordController');
        }
        if (address1Controller.text.isEmpty || addressLine1ValidationError!=null) {
          print('address1Controller validation failed');
          failedFields.add('address1Controller');
        }
        if (address2Controller.text.isEmpty || addressLine2ValidationError!=null) {
          print('address2Controller validation failed');
          failedFields.add('address2Controller');
        }
        if (townCityController.text.isEmpty || townCityValidationError!=null) {
          print('townCityController validation failed');
          failedFields.add('townCityController');
        }
        if (postCodeController.text.isEmpty || postCodeValidationError!=null) {
          print('postCodeController validation failed');
          failedFields.add('postCodeController');
        }
        if (phoneController.text.isEmpty || phoneValidationError!=null) {
          print('phoneController validation failed');
          failedFields.add('phoneController');
        }
        if (alterphoneController.text.isEmpty || alterphoneValidationError!=null) {
          print('alterphoneController validation failed');
          failedFields.add('alterphoneController');
        }
        if (emgNameController.text.isEmpty || emgNameValidationError!=null) {
          print('emgNameController validation failed');
          failedFields.add('emgNameController');
        }
        if (emgNumController.text.isEmpty || emgNumValidationError!=null) {
          print('emgNumController validation failed');
          failedFields.add('emgNumController');
        }
        if (passportNumController.text.isEmpty || passportNumValidationError!=null) {
          print('passportNumController validation failed');
          failedFields.add('passportNumController');
        }
        if (nationalNumController.text.isEmpty || nationalNumValidationError!=null) {
          print('nationalNumController validation failed');
          failedFields.add('nationalNumController');
        }
        // if (medicalController.text.isEmpty || medicalValidationError!=null) {
        //   print('medicalController validation failed');
        //   failedFields.add('medicalController');
        // }
        if (selectedMaritalStatus == null || selectedMaritalStatus!.isEmpty) {
          print('selectedMaritalStatus validation failed');
          failedFields.add('selectedMaritalStatus');
        }
        if (specifyController == null || specifyValidationError!.isEmpty) {
          print('specifyController validation failed');
          failedFields.add('specifyController');
        }
        // Scroll to the first validation error field
        if (failedFields.isNotEmpty) {
          String firstFailedField = failedFields.first;
          // scrolledtoField(firstFailedField);
        }
      }
    }
  }


  // void scrolledtoField(String field) {
  //   switch (field) {
  //     case 'firstnameController':
  //       _scrollToField(0);
  //       break;
  //     case 'lastnameController':
  //       _scrollToField(1);
  //       break;
  //     case 'selectedGender':
  //       _scrollToField(2);
  //       break;
  //       case '_selectedImageData':
  //       _scrollToField(18);
  //       break;
  //     case 'dobController':
  //       _scrollToField(3);
  //       break;
  //     case 'emailController':
  //       _scrollToField(4);
  //       break;
  //     case 'passwordController':
  //       _scrollToField(5);
  //       break;
  //     case 'reEnterpasswordController':
  //       _scrollToField(6);
  //       break;
  //     case 'address1Controller':
  //       _scrollToField(7);
  //       break;
  //     case 'address2Controller':
  //       _scrollToField(8);
  //       break;
  //     case 'townCityController':
  //       _scrollToField(9);
  //       break;
  //     case 'postCodeController':
  //       _scrollToField(10);
  //       break;
  //     case 'phoneController':
  //       _scrollToField(11);
  //       break;
  //     case 'alterphoneController':
  //       _scrollToField(12);
  //       break;
  //     case 'emgNameController':
  //       _scrollToField(13);
  //       break;
  //     case 'emgNumController':
  //       _scrollToField(14);
  //       break;
  //     case 'passportNumController':
  //       _scrollToField(15);
  //       break;
  //     case 'nationalNumController':
  //       _scrollToField(16);
  //       break;
  //     case 'medicalController':
  //       _scrollToField(17);
  //       break;
  //     case 'selectedMaritalStatus':
  //       _scrollToField(18);
  //       break;
   ///      case 'specifyController':
  ///       _scrollToField(19);
  ///       break;
  //     default:
  //       break;
  //   }
  // }

  ScrollController _scrollController = ScrollController();

  void _scrollToField(int index) {
    _scrollController.animateTo(
      // index * 100.0,
      index * 125.0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
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

  Widget body() {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(height: screenHeight * 0.013,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              // children: List.generate(6, (index) {
              children: List.generate(4, (index) {
                bool isCompleted = index < _currentStep; // Completed steps
                bool isCurrent = index == _currentStep; // Current step
                // bool isLastStep = index == 5;
                bool isLastStep = index == 3;

                return Row(
                  children: [
                    // Circle for the step
                    CircleAvatar(
                      radius: MediaQuery.of(context).size.width * 0.035,
                      backgroundColor: isCompleted || isCurrent ? Colors.green : AppColors.navColor,
                      child: isCompleted
                          ? const Icon(Icons.check, size: 15, color: Colors.white) // Checkmark for completed steps
                          : Text(
                              '${index + 1}', // Display step number
                              style: TextStyle(
                                color: isCurrent ? Colors.white : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    // Line connecting circles
                    if (!isLastStep)
                      Container(
                        width: screenWidth*0.225,
                        height: screenHeight * 0.004,
                        color: isCompleted ? Colors.green : AppColors.navColor,
                      ),
                  ],
                );
              }),
            ),
            // SizedBox(height: screenHeight * 0.013,),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  PersonalSection(
                    scrollController: _scrollController,
                    formKey: _formKeys[0],
                    firstnameController: firstnameController,
                    firstNameEditing: firstNameEditing,
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
                    onCitizenUkChange: (CitizenUk) {
                      setState(() {
                        selectedCitizenUk = CitizenUk;
                      });
                    },
                    onRightToWorkChange: (rightToWork) {
                      setState(() {
                        selectedRightToWork = rightToWork;
                      });
                    },
                    onoptOutChange: (optOut) {
                      setState(() {
                        selectedOptOut = optOut;
                      });
                    },
                    onDBSChange: (dbs) {
                      setState(() {
                        selectedDBS = dbs;
                      });
                    },
                    onDBSCheckTypeChange: (dbsCheckType) {
                      setState(() {
                        selectedDBSCheckType = dbsCheckType;
                      });
                    },
                    onMarriedChange: (marriedchange) {
                      setState(() {
                        selectedMaritalStatus = marriedchange;
                      });
                    },
                    onCriminalConvictionChange: (criminalConviction) {
                      setState(() {
                        selectedonCriminalConviction = criminalConviction;
                      });
                    },
                    firstNameValidationError: firstNameValidationError,
                    lastNameValidationError: lastNameValidationError,
                    dobValidationError: dobValidationError,
                    genderValidationError: genderValidationError,
                    imageValidationError: imageValidationError,
                    emailValidationError: emailValidationError,
                    passwordValidationError: passwordValidationError,
                    repasswordValidationError: repasswordValidationError,
                    ///Section-2
                    addressLine1ValidationError: addressLine1ValidationError,
                    addressLine2ValidationError: addressLine2ValidationError,
                    townCityValidationError: townCityValidationError,
                    postCodeValidationError: postCodeValidationError,
                    phoneValidationError: phoneValidationError,
                    alterphoneValidationError: alterphoneValidationError,
                    emgNameValidationError: emgNameValidationError,
                    emgNumValidationError: emgNumValidationError,
                    ///Section-3
                    roleValidationError: roleValidationError,
                    consultantValidationError: consultantValidationError,
                    passportNumValidationError: passportNumValidationError,
                    nationalNumValidationError: nationalNumValidationError,
                    // medicalValidationError: medicalValidationError,
                    maritalStatusValidationError: maritalStatusValidationError,
                    specifyValidationError: specifyValidationError,

                  ),
                  // AddressStep(
                  //   formKey: _formKeys[1],
                  //   addressController: addressController,
                  //   addressLine1ValidationError: addressLine1ValidationError,
                  // ),
                  // ContactDetailsStep(
                  //   formKey: _formKeys[2],
                  //   niNumberController: niNumberController,
                  //   niNumberValidationError: niNumberValidationError,
                  // ),
                  BankStep(
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
                  if (_currentStep == 0 )
                    InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: ButtonContainer(
                        "Back",
                        AppColors.blackOpacity, // Background color
                        Colors.black,
                      ),
                    ),
                  if (_currentStep < 3 && !_isBankStep)
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
                                  'Registration Completed! Name: ${nameController.text}, Address: ${address1Controller.text}, ni number: ${niNumberController.text},License Number: ${liNumberController.text},First Name: ${firstnameController.text},Last Name: ${lastnameController.text},Worker Role: ${selectedRole}, '
                                      'Do you UK: ${selectedRightToWork}, optOUt: ${selectedOptOut}, dbs: ${selectedDBS}, dbs Check Type: ${selectedDBSCheckType}')),
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
