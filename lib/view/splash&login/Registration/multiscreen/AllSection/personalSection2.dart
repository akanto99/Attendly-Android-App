import 'dart:convert';
import 'dart:typed_data';
import 'package:c9_app/Modules/StaffModule/MODEL/staff_registrationModel/ConsultantNames.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/model/Registration/candidateStaffRole.dart';
import 'package:c9_app/view/splash&login/Registration/multiscreen/AllSection/personalSection.dart';
import 'package:c9_app/view/splash&login/login_view.dart';
import 'package:c9_app/view/widgets/customTextField.dart';
import 'package:c9_app/view/widgets/custom_Validator_formfield.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as https;
import '../../../../../utils/utils.dart';

class PersonalSection2 extends StatefulWidget {
  final ScrollController scrollController;
  final VoidCallback onFinishPersonalStep;
  final VoidCallback onPrevious;
  final GlobalKey<FormState> formKey;
  final TextEditingController firstnameController;
  final TextEditingController lastnameController;

  final Function(String) onGenderChange;
  final TextEditingController dobController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController reEnterpasswordController;

  final TextEditingController address1Controller;
  final TextEditingController address2Controller;
  final TextEditingController townCityController;
  final TextEditingController postCodeController;
  final TextEditingController phoneController;
  final TextEditingController alterphoneController;
  final TextEditingController emgNameController;
  final TextEditingController emgNumController;

  ///section-3
  final Function(String) onRoleChange;
  final Function(String) onCommunicationChange;
  final TextEditingController consultantController;
  final TextEditingController passportNumController;
  final TextEditingController nationalNumController;
  // final TextEditingController medicalController;
  final Function(String) onCitizenUkChange;
  final Function(String) onRightToWorkChange;
  final Function(String) onoptOutChange;
  final Function(String) onDBSChange;
  final Function(String) onDBSCheckTypeChange;
  final Function(String) onMarriedChange;
  final Function(String) onCriminalConvictionChange;
  final TextEditingController specifyController;

  final void Function(Uint8List?, String?) onImageChange;

  ///Fitness Section
  final Function(String) onPhysicalIncapabilitiesChange;
  final Function(String) onMedicalConditionsChange;
  final Function(String) onMedicationChange;
  final Function(String) onDrugsChange;
  final Function(String) onWearGlassesChange;
  final TextEditingController lastWearGlassController;
  final Function(String) onMedicalReasonsChange;
  final Function(String) onLast3YearsChange;
  final TextEditingController detailsMedicalController;
  final TextEditingController detailsMedicationController;
  final TextEditingController detailsReasonController;
  final TextEditingController detailesDrivingRolesController;
  PersonalSection2({
    Key? key,
    required this.scrollController,
    required this.onFinishPersonalStep,
    required this.onPrevious,
    required this.formKey,
    required this.firstnameController,
    required this.lastnameController,
    required this.onGenderChange,
    required this.onImageChange,
    required this.dobController,
    required this.emailController,
    required this.passwordController,
    required this.reEnterpasswordController,
    required this.address1Controller,
    required this.address2Controller,
    required this.townCityController,
    required this.postCodeController,
    required this.phoneController,
    required this.alterphoneController,
    required this.emgNameController,
    required this.emgNumController,

    ///section-3
    required this.onRoleChange,
    required this.onCommunicationChange,
    required this.consultantController,
    required this.passportNumController,
    required this.nationalNumController,
    // required this.medicalController,
    required this.onCitizenUkChange,
    required this.onRightToWorkChange,
    required this.onoptOutChange,
    required this.onDBSChange,
    required this.onDBSCheckTypeChange,
    required this.onMarriedChange,
    required this.onCriminalConvictionChange,
    required this.specifyController,
    ///Fitness  Section
    required this.onPhysicalIncapabilitiesChange,
    required this.onMedicalConditionsChange,
    required this.onMedicationChange,
    required this.onDrugsChange,
    required this.onWearGlassesChange,
    required this.lastWearGlassController,
    required this.onMedicalReasonsChange,
    required this.onLast3YearsChange,

    required this.detailsMedicalController,
    required this.detailsMedicationController,
    required this.detailsReasonController,
    required this.detailesDrivingRolesController,

  }) : super(key: key);

  @override
  _PersonalSection2State createState() => _PersonalSection2State();
}

class _PersonalSection2State extends State<PersonalSection2> {
  final PageController _pageController = PageController();
  int subCurrentStep = 0;
  final List<GlobalKey<FormState>> _formKeys = List.generate(2, (_) => GlobalKey<FormState>());
  FocusNode firstnameFocusNode = FocusNode();
  FocusNode lastnameFocusNode = FocusNode();
  FocusNode genderFocusNode = FocusNode();
  ///
  FocusNode imageFocusNode = FocusNode();
  ///
  FocusNode dobFocusNode = FocusNode();
  ///
  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode repasswordFocusNode = FocusNode();
  FocusNode address1FocusNode = FocusNode();
  FocusNode address2FocusNode = FocusNode();
  FocusNode townCityFocusNode = FocusNode();
  FocusNode postCodeFocusNode = FocusNode();
  FocusNode phoneFocusNode = FocusNode();
  FocusNode alterPhoneFocusNode = FocusNode();
  FocusNode emgNameFocusNode = FocusNode();
  FocusNode emgNumFocusNode = FocusNode();
  FocusNode consltFocusNode = FocusNode();
  ///
  FocusNode passNumFocusNode = FocusNode();
  FocusNode niNumFocusNode = FocusNode();
  FocusNode medicalFocusNode = FocusNode();

  ValueNotifier<bool> _obsecurePassword = ValueNotifier<bool>(true);
  ValueNotifier<bool> _reobsecurePassword = ValueNotifier<bool>(true);
  ValueNotifier<bool> _isPasswordMatching = ValueNotifier<bool>(true);

  String? firstNameValidationError;
  String? lastNameValidationError;
  late final String? genderValidationError;
  String? dobValidationError;
  late final String? imageValidationError;
  String? emailValidationError;
  String? passwordValidationError;
  String? repasswordValidationError;

  String? addressLine1ValidationError;
  String? addressLine2ValidationError;
  String? townCityValidationError;
  String? postCodeValidationError;
  String? phoneValidationError;
  String? alterphoneValidationError;
  String? emgNameValidationError;
  String? emgNumValidationError;

  ///section-3
  late final String? roleValidationError;
  String? consultantValidationError;
  String? passportNumValidationError;
  String? nationalNumValidationError;
  String? medicalValidationError;
  late final String? maritalStatusValidationError;
  String? specifyValidationError;
  void _checkPasswordMatch() {
    _isPasswordMatching.value = widget.passwordController.text == widget.reEnterpasswordController.text;
  }

  final List<String> _dropdownOptions = ['Yes', 'No'];
  String? _selectedDbsOptions;
  final List<String> _conditionalOptions = ['Not Applicable', 'Basic DBS', 'Enhanced DBS'];
  String? _selectedOption0 = 'No';
  String? _selectedOption1 = 'No';
  String? _selectedOption2 = 'No';
  String? _selectedOption3 = 'No';
  String? _selectedOption4 = 'No';
  Map<String, dynamic> _formData = {
    'right_to_work': 0,
    'dbs_edbs': 0,
    'pension_scheme': 0,
  };

  String? selectedGender;
  String? _selectStaffRole;
  String? _selectCM = 'Email';
  List<Data> _roleTypes = [];
  String? selectedMaritalStatus;

  Uint8List? _selectedImageData;
  String? _selectedImageName;

  void onImageChange(Uint8List? imageData, String? imageName) {
    setState(() {
      _selectedImageData = imageData;
      _selectedImageName = imageName;
    });

    widget.onImageChange(imageData, imageName);
  }

  List<ConsultantNames> consultantNames = [];
  List<ConsultantNames> filteredConsultants = [];
  bool _isExpanded = false;
  FocusNode consultantFocusNode = FocusNode();
  String? selectedUKDriving;
  String? selectedUKHold;
  String? selectedUKPenalty;
  String? selectedRole;
  String? selectedCM;
  String? selectedCitizenUk;
  String? selectedRightToWork;
  String? selectedOptOut;
  String? selectedDBS;
  String? selectedDBSCheckType;
  String? selectedonCriminalConviction;

  ///Fitness Section
  final List<String> _fitnessDropdownOptions = ['Yes', 'No'];
  String? selectedPhysicalIncapabilities;
  String? selectedMedicalConditions;
  String? selectedMedication;
  String? selectedDrugs;
  String? selectedWearGlasses;
  String? selectedMedicalReasons;
  String? selectedLast3Years;

  String? physicalIncapabilitiesValidationError;
  String? medicalConditionsValidationError;
  String? medicationValidationError;
  String? drugsValidationError;
  String? wearGlassesValidationError;
  String? lastWeaarGlassValidationError;
  String? medicalReasonsValidationError;
  String? last3YearsValidationError;

  String? detailsMedicalValidationError;
  String? detailsMedicationValidationError;
  String? detailsReasonValidationError;
  String? detailesDrivingRolesValidationError;

  @override
  void initState() {
    super.initState();
    _loadSavedGender();
    _loadSavedImage();
    fetchStaffRoles();
    _loadSavedCommunicationMeth();
    _loadSavedRole();
    _loadSavedCitizenUk();
    _loadSavedRightToWork();
    _loadSavedOptOut();
    _loadSavedDBS();
    _loadSavedDBSCheckType();
    _loadSavedMaritalStatus();
    _loadCriminalConviction();
    fetchConsultantNames();
    consultantFocusNode.addListener(() {
      if (!consultantFocusNode.hasFocus) {
        setState(() {
          _isExpanded = false;
        });
      }
    });
    _loadFormData();
  }


  Future<void> _loadFormData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      ///Personal Section
      widget.firstnameController.text = prefs.getString('first_name') ?? '';
      widget.lastnameController.text = prefs.getString('last_name') ?? '';
      selectedGender = prefs.getString('gender');

      _selectedImageName = prefs.getString('imageName');
      String? base64Image = prefs.getString('image');
      if (base64Image != null) {
        _selectedImageData = base64Decode(base64Image);
      }
      widget.dobController.text = prefs.getString('dob') ?? '';
      widget.emailController.text = prefs.getString('email') ?? '';

      ///Section-2
      widget.address1Controller.text = prefs.getString('addressLine1') ?? '';
      widget.address2Controller.text = prefs.getString('addressLine2') ?? '';
      widget.townCityController.text = prefs.getString('townorcity') ?? '';
      widget.postCodeController.text = prefs.getString('postCode') ?? '';
      widget.phoneController.text = prefs.getString('phone') ?? '';
      widget.alterphoneController.text = prefs.getString('alterPhone') ?? '';
      widget.emgNameController.text = prefs.getString('emerName') ?? '';
      widget.emgNumController.text = prefs.getString('emerNum') ?? '';

      ///Section-3
     selectedCM = prefs.getString('prefsMethod');
      widget.consultantController.text = prefs.getString('consultant') ?? '';
      widget.passportNumController.text = prefs.getString('passportNumber') ?? '';
      widget.nationalNumController.text = prefs.getString('ni_number') ?? '';
      // medicalController.text = prefs.getString('medicalConditions') ?? '';

      selectedCitizenUk = prefs.getString('CitizenUk');
      selectedRightToWork = prefs.getString('rightToWorkUK');
      selectedOptOut = prefs.getString('optOutOfPension');
      selectedDBS = prefs.getString('dbsCheck');
      selectedDBSCheckType = prefs.getString('DBSCheckType');
      selectedMaritalStatus = prefs.getString('maritalStatus');
      selectedonCriminalConviction= prefs.getString('criminalConviction');
      widget.specifyController.text = prefs.getString('specify') ?? '';
      ///Fitness Section
      selectedPhysicalIncapabilities = prefs.getString('PhysicalIncapabilities');
      selectedMedicalConditions = prefs.getString('MedicalConditions');
      selectedMedication = prefs.getString('Medication');
      selectedDrugs = prefs.getString('Drugs');
      selectedWearGlasses = prefs.getString('WearGlasses');
      widget.lastWearGlassController.text = prefs.getString('lasteyetest') ?? '';
      selectedMedicalReasons = prefs.getString('MedicalReasons');
      selectedLast3Years = prefs.getString('Last3Years');

      widget.detailsMedicalController.text = prefs.getString('medicalconditiondetails') ?? '';
      widget.detailsMedicationController.text = prefs.getString('medicationdetails') ?? '';
      widget.detailsReasonController.text = prefs.getString('dismissalreason') ?? '';
      widget.detailesDrivingRolesController.text = prefs.getString('drivingdismissaldetails') ?? '';
    });
  }

  Future<void> _saveFormData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('first_name', widget.firstnameController.text);
    prefs.setString('last_name', widget.lastnameController.text);
    if (selectedGender != null) prefs.setString('gender', selectedGender!);
    if (_selectedImageData != null) {
      String base64Image = base64Encode(_selectedImageData!);
      prefs.setString('image', base64Image);
    }
    if (_selectedImageName != null) {
      prefs.setString('imageName', _selectedImageName!); // Save image name
    }
    prefs.setString('dob', widget.dobController.text);
    prefs.setString('email', widget.emailController.text);

    ///Section-2
    prefs.setString('addressLine1', widget.address1Controller.text);
    prefs.setString('addressLine2', widget.address2Controller.text);
    prefs.setString('townorcity', widget.townCityController.text);
    prefs.setString('postCode', widget.postCodeController.text);
    prefs.setString('phone', widget.phoneController.text);
    prefs.setString('alterPhone', widget.alterphoneController.text);
    prefs.setString('emerName', widget.emgNameController.text);
    prefs.setString('emerNum', widget.emgNumController.text);
    ///Section-3
    if (selectedRole != null) prefs.setString('role', selectedRole!);
    if (selectedCM != null) prefs.setString('prefsMethod', selectedCM!);
    prefs.setString('consultant', widget.consultantController.text);
    prefs.setString('passportNumber', widget.passportNumController.text);
    prefs.setString('ni_number', widget.nationalNumController.text);
    // prefs.setString('medicalConditions', medicalController.text);
    if (selectedCitizenUk != null) prefs.setString('CitizenUk', selectedCitizenUk!);
    if (selectedRightToWork != null) prefs.setString('rightToWorkUK', selectedRightToWork!);
    if (selectedOptOut != null) prefs.setString('optOutOfPension', selectedOptOut!);
    if (selectedDBS != null) prefs.setString('dbsCheck', selectedDBS!);
    if (selectedDBSCheckType != null) prefs.setString('DBSCheckType', selectedDBSCheckType!);
    if (selectedMaritalStatus != null) prefs.setString('maritalStatus', selectedMaritalStatus!);
    if (selectedonCriminalConviction != null) prefs.setString('CriminalConviction', selectedonCriminalConviction!);
    prefs.setString('specify', widget.specifyController.text);

    ///Fitness Section
    if (selectedPhysicalIncapabilities != null) prefs.setString('PhysicalIncapabilities', selectedPhysicalIncapabilities!);
    if (selectedMedicalConditions != null) prefs.setString('MedicalConditions', selectedMedicalConditions!);
    if (selectedMedication != null) prefs.setString('Medication', selectedMedication!);
    if (selectedDrugs != null) prefs.setString('Drugs', selectedDrugs!);
    if (selectedWearGlasses != null) prefs.setString('WearGlasses', selectedWearGlasses!);
    prefs.setString('lasteyetest', widget.lastWearGlassController.text);
    if (selectedMedicalReasons != null) prefs.setString('MedicalReasons', selectedMedicalReasons!);
    if (selectedLast3Years != null) prefs.setString('Last3Years', selectedLast3Years!);

    prefs.setString('medicalconditiondetails', widget.detailsMedicalController.text);
    prefs.setString('medicationdetails', widget.detailsMedicationController.text);
    prefs.setString('dismissalreason', widget.detailsReasonController.text);
    prefs.setString('drivingdismissaldetails', widget.detailesDrivingRolesController.text);
  }
  // Function to load the saved gender from SharedPreferences
  _loadSavedGender() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedGender = prefs.getString('gender') ?? '---Select One---';
    });
  }
  _loadSavedCommunicationMeth() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectCM = prefs.getString('prefsMethod') ?? 'Email';
    });
  }
  _loadSavedCitizenUk() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedOption0 = prefs.getString('CitizenUk') ?? 'No';
    });
  }
  _loadSavedRightToWork() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedOption1 = prefs.getString('rightToWorkUK') ?? 'No';
    });
  }
  _loadSavedOptOut() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedOption2 = prefs.getString('optOutOfPension') ?? 'No';
    });
  }
  _loadSavedDBS() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedOption3 = prefs.getString('dbsCheck') ?? 'No';
    });
  }
  /// Load previously saved DBS Check Type
  void _loadSavedDBSCheckType() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedDbsOptions = prefs.getString('dbsCheckType');
    });
  }
  _loadSavedRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectStaffRole = prefs.getString('role') ?? 'Select Role';
    });
  }

  _loadSavedMaritalStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedMaritalStatus = prefs.getString('maritalStatus') ?? 'Select';
    });
  }


  _loadCriminalConviction() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedOption4 = prefs.getString('criminalConviction') ?? 'No';
    });
  }
  // Function to load the saved image from SharedPreferences
  _loadSavedImage() async {
    final prefs = await SharedPreferences.getInstance();
    // Retrieve the base64 string from SharedPreferences
    String? base64Image = prefs.getString('image');
    if (base64Image != null) {
      // Decode the base64 string into Uint8List
      Uint8List imageData = base64Decode(base64Image);
      setState(() {
        _selectedImageData = imageData;
        _selectedImageName = prefs.getString('imageName');
      });
    }
  }

  Future<void> fetchStaffRoles() async {
    try {
      final response = await https.get(Uri.parse('${AppUrl.baseUrl}/api/app/role/type'));

      if (response.statusCode == 200) {
        CandidateStaffRole staffRoles = CandidateStaffRole.fromJson(json.decode(response.body));

        setState(() {
          _roleTypes = staffRoles.data ?? [];
          print("Fetched roles: ${_roleTypes.length}");
        });
      } else {
        throw Exception('Failed to load worker roles');
      }
    } catch (e) {
      print("Error fetching roles: $e");
    }
  }

  Future<void> fetchConsultantNames() async {
    try {
      final response = await https.get(Uri.parse('${AppUrl.baseUrl}/api/app/staff-registration-dropdown'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          consultantNames = data.map((item) => ConsultantNames.fromJson(item)).toList();
          filteredConsultants = consultantNames; // Show all by default on tap
        });
      } else {
        print("Failed to load consultant names");
      }
    } catch (error) {
      print("Error fetching data: $error");
    }
  }

  // Filter consultants based on user query
  void filterConsultants(String query) {
    setState(() {
      filteredConsultants = query.isNotEmpty
          ? consultantNames
          .where((consultant) => consultant.name?.toLowerCase().contains(query.toLowerCase()) ?? false)
          .toList()
          : consultantNames;
    });
  }


  Future<bool> _postPersonalSection(int subCurrentStep) async {
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

      // Prepare form data for the request based on subCurrentStep
      if (subCurrentStep == 0) {
        // Personal Information Screen
        request.fields['first_name'] = widget.firstnameController.text;
        request.fields['last_name'] = widget.lastnameController.text;
        request.fields['gender'] = selectedGender ?? '';
        if (widget.dobController.text.isNotEmpty) {
          request.fields['dob'] = DateFormat('yyyy-MM-dd').format(DateFormat('dd-MM-yyyy').parse(widget.dobController.text));
        }
        if (_selectedImageData != null) {
          print("Image data is not null. Length: ${_selectedImageData!.length}");
          request.files.add(await https.MultipartFile.fromBytes(
            'image',
            _selectedImageData!,
            filename: _selectedImageName ?? 'image.jpg',
          ));
        }
        request.fields['email'] = widget.emailController.text;
        request.fields['password'] = widget.passwordController.text;
        request.fields['confirm_password'] = widget.reEnterpasswordController.text;
        ///Section-2
        request.fields['addressLine1'] = widget.address1Controller.text;
        request.fields['addressLine2'] = widget.address2Controller.text;
        request.fields['townorcity'] = widget.townCityController.text;
        request.fields['postCode'] = widget.postCodeController.text;
        request.fields['phone'] = widget.phoneController.text;
        request.fields['alterPhone'] = widget.alterphoneController.text;
        request.fields['emerName'] = widget.emgNameController.text;
        request.fields['emerNum'] = widget.emgNumController.text;
        ///Section-3
        request.fields['role'] = selectedRole ?? '';
        request.fields['prefsMethod'] = selectedCM ?? '';
        request.fields['consultant'] = widget.consultantController.text;
        request.fields['passportNumber'] = widget.passportNumController.text;
        request.fields['ni_number'] = widget.nationalNumController.text;
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
          request.fields['specify'] = widget.specifyController.text;
        }

      } else if (subCurrentStep == 1) {
       ///Fitness Section
        request.fields['physical_incapabilities'] = selectedPhysicalIncapabilities == 'Yes' ? '1' : '0';
        request.fields['ongoing_medical_conditions'] = selectedMedicalConditions == 'Yes' ? '1' : '0';
        if (selectedMedicalConditions == 'Yes')
          request.fields['medical_condition_details'] = widget.detailsMedicalController.text;
        request.fields['taking_medication"'] = selectedMedication == 'Yes' ? '1' : '0';
        if (selectedMedication == 'Yes')
          request.fields['medication_details'] = widget.detailsMedicationController.text;
        request.fields['drug_or_alcohol_issues'] = selectedDrugs == 'Yes' ? '1' : '0';
        request.fields['wears_glasses'] = selectedWearGlasses == 'Yes' ? '1' : '0';
        request.fields['last_eye_test'] = widget.lastWearGlassController.text;
        request.fields['dismissed_for_medical_reasons'] = selectedMedicalReasons == 'Yes' ? '1' : '0';
        if (selectedMedicalReasons == 'Yes')
          request.fields['dismissal_reason'] = widget.detailsReasonController.text;
        request.fields['dismissed_from_driving_roles'] = selectedLast3Years == 'Yes' ? '1' : '0';
        if (selectedLast3Years == 'Yes')
          request.fields['driving_dismissal_details'] = widget.detailesDrivingRolesController.text;
      }

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
            // Update the validation errors based on currentStep
            if (subCurrentStep == 0) {
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
            } else if (subCurrentStep == 1) {
              ///Fitness Section
                physicalIncapabilitiesValidationError = validationErrors['physical_incapabilities']?.join(', ');
                medicalConditionsValidationError = validationErrors['ongoing_medical_conditions']?.join(', ');
                medicationValidationError = validationErrors['taking_medication']?.join(', ');
                drugsValidationError = validationErrors['drug_or_alcohol_issues']?.join(', ');
                wearGlassesValidationError = validationErrors['wears_glasses']?.join(', ');
                lastWeaarGlassValidationError = validationErrors['last_eye_test']?.join(', ');
                medicalReasonsValidationError = validationErrors['dismissed_for_medical_reasons']?.join(', ');
                last3YearsValidationError = validationErrors['dismissed_from_driving_roles']?.join(', ');

                detailsMedicalValidationError = validationErrors['medical_condition_details']?.join(', ');
                detailsMedicationValidationError = validationErrors['medication_details']?.join(', ');
                detailsReasonValidationError = validationErrors['dismissal_reason']?.join(', ');
                detailesDrivingRolesValidationError = validationErrors['driving_dismissal_details']?.join(', ');
                int errorCount = [
                  physicalIncapabilitiesValidationError,
                  medicalConditionsValidationError,
                  medicationValidationError,
                  drugsValidationError,
                  wearGlassesValidationError,
                  lastWeaarGlassValidationError,
                  medicalReasonsValidationError,
                  last3YearsValidationError,
                  detailsMedicalValidationError,
                  detailsMedicationValidationError,
                  detailsReasonValidationError,
                  detailesDrivingRolesValidationError,
                ].where((error) => error != null && error.isNotEmpty).length;

                // Display the appropriate message based on the error count
                if (errorCount == 0) {
                  Utils.flushBarSuccessMessage('All fields are valid!', context);
                } else {
                  Utils.flushBarErrorMessage(
                    'Fields Are Empty',
                    context,
                  );
                }
            }
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
    return Column(
      children: [
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTabButton(
              'CRM',
              0,
              isEnabled: true,
            ),
            _buildTabButton(
              'Fitness',
              1,
              isEnabled: true,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildCRMSection(),
              _buildFitnessSection(),
            ],
          ),
        ),
        Container(
          width: screenWidth * 0.95,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (subCurrentStep > 0)
                InkWell(
                  onTap:_PreviousStep,
                  child: ButtonContainer(
                    "Back",
                    // AppColors.blackOpacity,
                    AppColors.navOpacity,
                    Colors.black,
                  ),
                ),
              if (subCurrentStep == 0)
                InkWell(
                  onTap:  _goPreviousStep,
                  child: ButtonContainer(
                    "Go Back",
                    // "Back",
                    AppColors.navOpacity,
                    Colors.black,
                  ),
                ),
              if (subCurrentStep < 1)
                InkWell(
                  onTap: continueButton,
                  child: ButtonContainer(
                    "Continue",
                    AppColors.navColor,
                    Colors.white,
                  ),
                ),
              if (subCurrentStep == 1)
                InkWell(
                  onTap: () async{
                    widget.onFinishPersonalStep();
                    if (validateCurrentStep()) {
                      await _postPersonalSection(1);
                      _saveFormData();
                      if (physicalIncapabilitiesValidationError == null &&
                          medicalConditionsValidationError == null &&
                          medicationValidationError == null &&
                          drugsValidationError == null &&
                          wearGlassesValidationError == null &&
                          lastWeaarGlassValidationError == null &&
                          medicalReasonsValidationError == null &&
                          last3YearsValidationError == null &&
                          detailsMedicalValidationError == null &&
                          detailsMedicationValidationError == null &&
                          detailsReasonValidationError == null &&
                          detailesDrivingRolesValidationError == null
                      ) {
                        widget.onFinishPersonalStep();
                      }
                    }
                  },
                  child: ButtonContainer(
                    "Finish",
                    AppColors.navButtonColor,
                    Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildTabButton(String label, int index, {required bool isEnabled}) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return GestureDetector(
      onTap: () {
        if (index <= subCurrentStep) {
          // Allow navigating back without validation
          _goToPage(index);
        } else {
          // Require validation for forward navigation
          if (_formKeys[subCurrentStep].currentState != null &&
              _formKeys[subCurrentStep].currentState!.validate()) {
            _goToPage(index);
          } else {
            Utils.flushBarErrorMessage(
                'Please complete the current step before proceeding', context);
          }
        }
      },
      child: Container(
        height: screenHeight*0.05,
        width: screenWidth*0.465,
        decoration: BoxDecoration(
          // borderRadius: BorderRadius.circular(8),
          color: subCurrentStep == index
              ? AppColors.navColor
              : isEnabled && subCurrentStep >= index
              ? Color(0xff487eb0)
              : Color(0xff487eb0),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: subCurrentStep == index
                  ? AppColors.whiteColor
                  : isEnabled && subCurrentStep >= index
                  ? AppColors.whiteColor
                  : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
  Widget ButtonContainer(String? label, Color color1, Color color2) {
    return Container(
      height: 40,
      width: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
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


  // Implement these methods for each step
  Widget _buildCRMSection() {
    double screenWidth = MediaQuery.of(context).size.width * 1;
    double screenHeight = MediaQuery.of(context).size.height * 1;
    return SingleChildScrollView(
      // controller: _scrollController,
      child: Form(
        key: _formKeys[0],
        child: Column(
            children: [

              Container(
                height: 45,
                width: screenWidth,
                padding: EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  // borderRadius: BorderRadius.circular(10),
                  // color: Color(0xff487eb0),
                  color: AppColors.navColor,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Personal Information",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.whiteColor,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * .013,),
              CustomTextField(
                titleText: 'First Name',
                requiredStar: "*",
                placeholder: 'Enter your first name',
                controller: widget.firstnameController,
                focusCurrent: firstnameFocusNode,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'First name is required';
                  }
                  if (value.length < 3) {
                    return 'First name must be at least 3 characters long.';
                  }
                  if (RegExp(r'^[^a-zA-Z]').hasMatch(value)) {
                    return 'First name cannot start with a space, special character, or number.';
                  }
                  return null;
                },

              ),

              SizedBox(height: screenHeight * .013,),
              CustomTextField(
                titleText: 'Last Name',
                requiredStar: "*",
                placeholder: 'Enter your last name',
                controller: widget.lastnameController,
                errorMessage: lastNameValidationError,
                focusCurrent: lastnameFocusNode,
                focusNext: null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Last name is required';
                  }
                  if (value.length < 3) {
                    return 'Last name must be at least 3 characters long.';
                  }
                  if (RegExp(r'^[^a-zA-Z]').hasMatch(value)) {
                    return 'Last name cannot start with a space, special character, or number.';
                  }
                  return null;
                },
              ),

              SizedBox(height: screenHeight * .013,),
              _buildGenderDropdown(),
              SizedBox(height: screenHeight * .013,),
              // _selectedImageData != null
              //     ? GestureDetector(
              //   onTap: () {
              //     // Navigate to a new screen with the full image
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => FullImageScreen(imageData: _selectedImageData!),
              //       ),
              //     );
              //   },
              //   child: CircleAvatar(
              //     radius: 50,
              //     backgroundColor: Colors.transparent,
              //     child: ClipOval(
              //       child: Image.memory(
              //         _selectedImageData!,
              //         fit: BoxFit.cover, // To make the image cover the circle
              //       ),
              //     ),
              //   ),
              // )
              //     : SizedBox.shrink(),

              // const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child:  Container(
                  width: screenWidth * 0.95,
                  child: Text(
                    "Image",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              // Form for image selection with validation
              FormField<String>(
                validator: (value) {
                  // Check if image is selected
                  if (_selectedImageData == null || _selectedImageData!.isEmpty) {
                    return 'Image is required';
                  }
                  return null;  // No validation error
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                builder: (FormFieldState<String> state) {
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await _pickImage(ImageSource.gallery);  // Trigger image selection

                          // After image is selected, update the form field state
                          state.didChange(_selectedImageName); // Trigger validation again
                        },
                        child: Container(
                          // height: screenHeight * 0.065,
                          height: 55,
                          width: screenWidth * 0.95,
                          decoration: BoxDecoration(
                            color: AppColors.navOpacity.withOpacity(0.2),
                            border: Border.all(
                              // color: state.hasError
                              //     ? Colors.red // Red border if validation fails
                              //     : AppColors.navButtonColor.withOpacity(0.4),
                              color:  AppColors.navButtonColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: screenHeight * 0.066,
                                width: screenWidth * 0.35,
                                decoration: BoxDecoration(
                                  color: AppColors.navColor,
                                  // border: Border.all(
                                  //   color: AppColors.navOpacity,
                                  //   width: 0.4,
                                  // ),
                                  // borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Center(
                                  child: Text(
                                    "Choose image",
                                    style: TextStyle(fontSize: 15, color: Colors.white),
                                  ),
                                ),
                              ),
                              Text(
                                _selectedImageName ?? "No image chosen",
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,color: AppColors.navColor),
                              ),
                              SizedBox(),
                            ],
                          ),
                        ),
                      ),
                      if (state.hasError)
                        Container(
                          width: screenWidth*0.95,
                          child:Padding(
                            padding: const EdgeInsets.only(top: 4.0,left: 10),
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


              SizedBox(height: screenHeight * .013,),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  width: screenWidth * 0.95,
                  child: Row(
                    children: [
                      Text(
                        'Date of Birth',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        " *",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                      )
                    ],
                  ),
                ),
              ),
              buildDateContainer(
                labelText: 'dd/mm/yyyy',
                controller: widget.dobController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Date of birth is required';
                  }
                  return null;
                },
              ),

              SizedBox(height: screenHeight * .013,),
              CustomTextField(
                titleText: 'Email',
                requiredStar: "*",
                placeholder: 'Enter your email address',
                controller: widget.emailController,
                focusCurrent: emailFocusNode,
                focusNext: passwordFocusNode,
                validator: (value) {
                  // Check if the field is empty or invalid
                  if (value == null || value.isEmpty || !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                    return 'A valid email is required.';
                  }
                  return null; // Valid input
                },
              ),

              SizedBox(height: screenHeight * .013,),

              // Password
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  width: screenWidth * 0.95,
                  child: Row(
                    children: [
                      Text("Password", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      Text(
                        " *",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                      )
                    ],
                  ),
                ),
              ),
              ValueListenableBuilder(
                valueListenable: _obsecurePassword,
                builder: (context, value, child) {
                  return Container(
                    width: screenWidth * 0.95,
                    child: TextFormField(
                      controller: widget.passwordController,
                      obscureText: _obsecurePassword.value,
                      focusNode: passwordFocusNode,
                      obscuringCharacter: "*",
                      decoration: InputDecoration(
                        hintText: "Enter Your Password",
                        hintStyle: const TextStyle(color: Colors.grey),
                        errorMaxLines: 3,
                        errorStyle: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 0.4,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            // color: Colors.red,
                            color: Colors.grey,
                            width: 0.4,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            // color: Colors.red,
                            color: Colors.grey,
                            width: 0.4,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Colors.green,
                            width: 0.4,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 14),
                        suffixIcon: InkWell(
                          onTap: () {
                            _obsecurePassword.value = !_obsecurePassword.value;
                          },
                          child: Icon(
                            _obsecurePassword.value ? Icons.visibility_off_outlined : Icons.visibility,
                          ),
                        ),
                      ),
                      autovalidateMode:
                      AutovalidateMode.onUserInteraction, // Enables auto-validation on user interaction
                      onFieldSubmitted: (value) {
                        Utils.fieldFocusChange(context, passwordFocusNode, repasswordFocusNode);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required and must be at least 8 characters.';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters.';
                        }
                        return null; // Valid input
                      },
                      onChanged: (value) {
                        _checkPasswordMatch(); // Additional password validation logic
                      },
                    ),
                  );
                },
              ),

              // Re-Enter Password
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  width: screenWidth * 0.95,
                  child: Row(
                    children: [
                      Text("Re-Enter Password", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      Text(
                        " *",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                      )
                    ],
                  ),
                ),
              ),
              ValueListenableBuilder(
                valueListenable: _reobsecurePassword,
                builder: (context, value, child) {
                  return Container(
                    width: screenWidth * 0.95,
                    child: TextFormField(
                      controller: widget.reEnterpasswordController,
                      obscureText: _reobsecurePassword.value,
                      focusNode: repasswordFocusNode,
                      obscuringCharacter: "*",
                      decoration: InputDecoration(
                        hintText: "Re-Enter Your Password",
                        hintStyle: TextStyle(color: Colors.grey),
                        errorMaxLines: 3,
                        errorStyle: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 0.4,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            // color: Colors.red,
                            color: Colors.grey,
                            width: 0.4,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            // color: Colors.red,
                            color: Colors.grey,
                            width: 0.4,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                            color: Colors.green,
                            width: 0.4,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 12),
                        suffixIcon: InkWell(
                          onTap: () {
                            _reobsecurePassword.value = !_reobsecurePassword.value;
                          },
                          child: Icon(
                            _reobsecurePassword.value ? Icons.visibility_off_outlined : Icons.visibility,
                          ),
                        ),
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onFieldSubmitted: (value) {
                        Utils.fieldFocusChange(context, repasswordFocusNode, address1FocusNode);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Passwords must match.';
                        } else if (value.length < 8) {
                          return 'Confirm Passwords must match.';
                        }
                        return null; // Valid input
                      },
                      onChanged: (value) {
                        _checkPasswordMatch();
                      },
                    ),
                  );
                },
              ),
              // Password Match Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: screenWidth*0.2,),
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _isPasswordMatching,
                      builder: (context, value, child) {
                        // Using `value` directly here
                        if (widget.passwordController != null &&
                            widget.reEnterpasswordController != null &&
                            widget.passwordController.text.isNotEmpty &&
                            widget.reEnterpasswordController.text.isNotEmpty) {
                          return Text(
                            value ? "Password matched" : "Not matched",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: value ? Colors.green : Colors.red,
                            ),
                          );
                        }
                        return SizedBox.shrink(); // Return empty space if conditions aren't met
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenHeight * .013),
              Container(
                height: 45,
                width: screenWidth,
                padding: EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  // borderRadius: BorderRadius.circular(10),
                  // color: Color(0xff487eb0),
                  color: AppColors.navColor,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Contact Information",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.whiteColor,
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * .013,),
              CustomTextField(
                titleText: 'Address Line 1',
                requiredStar: "*",
                placeholder: 'Enter your address line 1',
                controller: widget.address1Controller,
                focusCurrent: address1FocusNode,
                focusNext: address2FocusNode,
                validator: (value) {
                  // Check if the field is empty or invalid
                  if (value == null || value.isEmpty) {
                    return 'Address Line 1 is required';
                  }

                  return null; // Valid input
                },
              ),
              SizedBox(height: screenHeight * .013,),
              CustomTextField(
                titleText: 'Address Line 2',
                requiredStar: "*",
                placeholder: 'Enter your address line 2',
                controller: widget.address2Controller,
                focusCurrent: address2FocusNode,
                focusNext: townCityFocusNode,
                validator: (value) {
                  // Check if the field is empty or invalid
                  if (value == null || value.isEmpty) {
                    return 'Address Line 2 is required';
                  }
                  return null; // Valid input
                },
              ),

              SizedBox(height: screenHeight * .013,),
              CustomTextField(
                titleText: 'Town/City',
                placeholder: 'Enter your town city',
                controller: widget.townCityController,
                focusCurrent: townCityFocusNode,
                focusNext: postCodeFocusNode,
                validator: (value) {
                  // Check if the field is empty or invalid
                  if (value == null || value.isEmpty) {
                    return 'Town or City address must be required.';
                  }
                  return null; // Valid input
                },
              ),
              SizedBox(height: screenHeight * .013,),
              CustomTextField(
                titleText: 'Post Code',
                requiredStar: "*",
                placeholder: 'Enter your post code',
                controller: widget.postCodeController,
                focusCurrent: postCodeFocusNode,
                focusNext: phoneFocusNode,
                validator: (value) {
                  // Check if the field is empty or invalid
                  if (value == null || value.isEmpty) {
                    return 'Post Code is required.';
                  } else if (value.length > 8) {
                    return 'Post Code must be less than or equal to 8 characters.';
                  }
                  return null; // Valid input
                },
              ),
              SizedBox(height: screenHeight * .013,),
              CustomTextField(
                titleText: 'Phone Number',
                requiredStar: "*",
                placeholder: 'Enter your phone number',
                controller: widget.phoneController,
                focusCurrent: phoneFocusNode,
                focusNext: alterPhoneFocusNode,
                validator: (value) {
                  if (value == null || value.isEmpty || !RegExp(r'^(?:\+44|0)7\d{9}$').hasMatch(value)) {
                    return 'Phone number must be a valid UK phone number';
                  }
                  return null; // Valid input
                },
              ),
              SizedBox(height: screenHeight * .013,),
              CustomTextField(
                titleText: 'Alternative Phone Number',
                requiredStar: "*",
                placeholder: 'Enter your alternative phone number',
                controller: widget.alterphoneController,
                focusCurrent: alterPhoneFocusNode,
                focusNext: emgNameFocusNode,
                validator: (value) {
                  // Check if the field is empty or invalid
                  if (value == null || value.isEmpty || !RegExp(r'^(?:\+44|0)7\d{9}$').hasMatch(value)) {
                    return 'Alternative phone number must be a valid UK phone number';
                  }
                  return null; // Valid input
                },
              ),
              SizedBox(height: screenHeight * .013,),
              CustomTextField(
                titleText: 'Emergency Contact Name',
                requiredStar: "*",
                placeholder: 'Enter your emergency contact name',
                controller: widget.emgNameController,
                focusCurrent: emgNameFocusNode,
                focusNext: emgNumFocusNode,
                validator: (value) {
                  // Check if the field is empty or invalid
                  if (value == null || value.isEmpty) {
                    return 'Emergency contact name is required.';
                  } else if (value.length < 3) {
                    return 'Emergency contact name must be at least 3 characters long.';
                  }
                  return null; // Valid input
                },
              ),
              SizedBox(height: screenHeight * .013,),
              CustomTextField(
                titleText: 'Emergency Contact Number',
                requiredStar: "*",
                placeholder: 'Enter your emergency contact number',
                controller: widget.emgNumController,
                focusCurrent: emgNumFocusNode,
                focusNext: null,
                validator: (value) {
                  if (value == null || value.isEmpty || !RegExp(r'^(?:\+44|0)7\d{9}$').hasMatch(value)) {
                    return 'Emergency Contact number must be a valid UK phone number.';
                  }
                  return null; // Valid input
                },
              ),
              SizedBox(height: screenHeight * .013,),
              Container(
                height: 45,
                width: screenWidth,
                padding: EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  // borderRadius: BorderRadius.circular(10),
                  // color: Color(0xff487eb0),
                  color: AppColors.navColor,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Additional Information",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.whiteColor,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * .013,),
              // SizedBox(height: 10),
              Column(
                children: [
                  // SizedBox(height: screenHeight * .013),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child:  Container(
                      width: screenWidth * 0.95,
                      child: Row(
                        children: [
                          Text(
                            'Worker Role',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            " *",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                          )
                        ],
                      ),
                    ),
                  ),

                  /// Display selected staff roles
                  FormField<String>(
                      initialValue: _selectStaffRole ?? 'Select Role',
                      validator: (value) {
                        // Add your validation logic here
                        if (value == null || value.isEmpty || value == 'Select Role') {
                          return 'Worker role is required';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      builder: (FormFieldState<String> state) {
                        return Column(
                          children: [
                            Container(
                              // height: screenHeight * 0.065,
                              height: 50,
                              width: screenWidth * 0.95,
                              padding: EdgeInsets.symmetric(horizontal: 15.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(color: Colors.grey.withOpacity(0.4), width: 0.4),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  // iconEnabledColor: Colors.grey,
                                  iconSize: 30.0,
                                  hint: Text(
                                    _selectStaffRole ?? 'Select Role',
                                    style: TextStyle(fontSize: 15, color: Colors.black),
                                  ),
                                  items: _roleTypes.map((Data role) {
                                    return DropdownMenuItem<String>(
                                      value: role.staffType,
                                      child: Text(
                                        role.staffType ?? '',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) async {
                                    setState(() {
                                      _selectStaffRole = newValue;
                                    });
                                    final prefs = await SharedPreferences.getInstance();
                                    prefs.setString('role', newValue!);
                                    widget.onRoleChange(newValue);
                                    state.didChange(newValue);
                                  },
                                ),
                              ),
                            ),
                            if (state.hasError)
                              Container(
                                width: screenWidth*0.95,
                                child:      Padding(
                                  padding: const EdgeInsets.only(top: 4.0,left :10),
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
                      }

                  ),
                  SizedBox(height: screenHeight * .013,),
                  _buildMeritalDropdown(),
                  SizedBox(height: screenHeight * .013,),
                  Column(
                    children: [
                      Container(
                        width: screenWidth * 0.95,
                        child: Row(
                          children: [
                            const Text(
                              'Preferred Communication Method',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const Text(
                              ' *',
                              style: TextStyle(color: Colors.red, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                          // height: screenHeight * 0.065,
                          height: 55,
                          width: screenWidth * 0.95,
                          padding: EdgeInsets.symmetric(horizontal: 15.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Colors.grey.withOpacity(0.4), width: 0.4),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              // iconEnabledColor: Colors.grey,
                              iconSize: 30.0,
                              value: _selectCM,
                              items: ['Email', 'Phone'].map((communication) {
                                return DropdownMenuItem(
                                  value: communication,
                                  child: Text(communication),
                                );
                              }).toList(),
                              onChanged: (String? newValue) async {
                                setState(() {
                                  _selectCM = newValue;
                                });
                                // Save selected gender to SharedPreferences
                                final prefs = await SharedPreferences.getInstance();
                                prefs.setString('prefsMethod', newValue!);
                                widget.onCommunicationChange(newValue);
                              },
                            ),
                          )),
                    ],
                  ),
                  SizedBox(height: screenHeight * .013,),
                  // Search or Consultant Name
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child:  Container(
                      width: screenWidth * 0.95,
                      child: Row(
                        children: [
                          Text(
                            'Consultant Name: (Optional)',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.95,
                    decoration: BoxDecoration(
                      color: AppColors.navOpacity.withOpacity(0.2),
                      border: Border.all(
                        color: AppColors.navButtonColor.withOpacity(0.4),
                        width: 0.4,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextField(
                            controller: widget.consultantController,
                            focusNode: consultantFocusNode,
                            onChanged: (value) {
                              filterConsultants(value);
                              setState(() {
                                _isExpanded = true;
                              });
                            },
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.search, color: Colors.grey),
                              border: InputBorder.none,
                              hintText: "Search or Consultant Name",
                              hintStyle: TextStyle(color: Colors.grey),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.10),
                            ),
                            onTap: () {
                              fetchConsultantNames();
                              setState(() {
                                _isExpanded = true;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * .009,
                  ),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (_isExpanded && filteredConsultants.isNotEmpty)
                      Container(
                        height: screenHeight * 0.15,
                        width: screenWidth * 0.95,
                        decoration: BoxDecoration(
                          color: AppColors.navButtonColor.withOpacity(0.08),
                          border: Border.all(
                            color: AppColors.navButtonColor.withOpacity(0.4),
                            width: 0.4,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Scrollbar(
                          child: ListView.builder(
                              itemCount: filteredConsultants.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(
                                    filteredConsultants[index].name ?? '',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      widget.consultantController.text = filteredConsultants[index].name ?? '';
                                      filteredConsultants = [];
                                      _isExpanded = false;
                                    });
                                  },
                                );
                              }),
                        ),
                      ),
                  ]),

                  SizedBox(height: screenHeight * .013,),
                  CustomTextField(
                    titleText: 'Passport Number',
                    requiredStar: "*",
                    placeholder: 'Enter your passport number',
                    controller: widget.passportNumController,
                    focusCurrent: passNumFocusNode,
                    focusNext: niNumFocusNode,
                    validator: (value) {
                      final ukPassportRegex = RegExp(r'^[A-Z]{2}[0-9]{7}$');
                      if (value == null || value.isEmpty) {
                        return 'Passport Number is required.';
                      } else if (!ukPassportRegex.hasMatch(value)) {
                        return 'Invalid passport number. It must start with 2 uppercase letters followed by 7 digits.';
                      }
                      return null; // Valid input
                    },
                    onChanged: (value) {
                      setState(() {
                       passportNumValidationError = "";
                      });
                    },
                  ),
                  SizedBox(
                    height: screenHeight * .013,
                  ),
                  CustomTextField(
                    titleText: 'National Insurance Number',
                    requiredStar: "*",
                    placeholder: 'Enter your national insurance number',
                    controller: widget.nationalNumController,
                    focusCurrent: niNumFocusNode,
                    focusNext: null,
                    validator: (value) {
                      final niNumberRegex = RegExp(
                        r'^(?![DFIQUV]{2})(?![DFIQUV])[A-CEGHJ-NOPRSTW-Z]{2}\d{6}[A-D]$',
                      );
                      if (value == null || value.isEmpty) {
                        return 'National Insurance number is required.';
                      } else if (!niNumberRegex.hasMatch(value)) {
                        return 'Enter a valid NI number (e.g., AB123456C). Prefix: no D, F, I, Q, U, or V. Suffix: A-D only.';
                      }
                      return null; // Valid input
                    },
                  ),
                  SizedBox(
                    height: screenHeight * .013,
                  ),
                  DynamicDropdown(
                    title: "Are you a citizen of the UK?",
                    options: _dropdownOptions,
                    selectedOption: _selectedOption0 ?? "No",
                    onChanged: (newValue) async {
                      setState(() {
                        _selectedOption0 = newValue!;
                        _formData['CitizenUk'] = newValue == 'Yes' ? 1 : 0;
                      });
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setString('CitizenUk', newValue!);
                      widget.onCitizenUkChange(newValue);
                    },
                  ),
                  SizedBox(height: screenHeight * .013,),
                  DynamicDropdown(
                    title: "Do you have a Right to Work in the UK?",
                    options: _dropdownOptions,
                    selectedOption: _selectedOption1 ?? "No",
                    onChanged: (newValue) async {
                      setState(() {
                        _selectedOption1 = newValue!;
                        _formData['right_to_work'] = newValue == 'Yes' ? 1 : 0;
                      });
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setString('rightToWorkUK', newValue!);
                      widget.onRightToWorkChange(newValue);
                    },
                  ),
                  SizedBox(height: screenHeight * .013),

                  DynamicDropdown(
                    title: "Do you want to opt out of the Pension Scheme?",
                    options: _dropdownOptions,
                    selectedOption: _selectedOption2 ?? "No",
                    onChanged: (newValue) async {
                      setState(() {
                        _selectedOption2 = newValue!;
                        _formData['pension_scheme'] = newValue == 'Yes' ? 1 : 0;
                      });
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setString('optOutOfPension', newValue!);
                      widget.onoptOutChange(newValue);
                    },
                  ),
                  SizedBox(height: screenHeight * .013),
                  DynamicDropdown(
                    title: "Do you have a DBS or EDBS (if applicable for your role)?",
                    options: _dropdownOptions,
                    selectedOption: _selectedOption3 ?? "No",
                    onChanged: (newValue) async {
                      setState(() {
                        _selectedOption3 = newValue!;
                        _formData['dbs_edbs'] = newValue == 'Yes' ? 1 : 0;
                      });
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setString('dbsCheck', newValue!);
                      widget.onDBSChange(newValue);
                    },
                  ),
                  // SizedBox(height: screenHeight * .013),

                  if (_selectedOption3 == 'Yes') ...[
                    SizedBox(height: screenHeight * .013,),
                    ConditionalDropdown(
                      title: "DBS Check Type",
                      options: _conditionalOptions,
                      selectedOption: _conditionalOptions.contains(_selectedDbsOptions) ? _selectedDbsOptions : null,
                      onChanged: (newValue) async {
                        setState(() {
                          _selectedDbsOptions = newValue;
                        });
                        final prefs = await SharedPreferences.getInstance();
                        prefs.setString('dbsCheckType', newValue!);
                        widget.onDBSCheckTypeChange(newValue);
                      },
                      validator: (value) {
                        if (_selectedOption3 == 'Yes' && (value == null || value.isEmpty)) {
                          return 'Please select a DBS Check Type.';
                        }
                        return null;
                      },
                    ),

                  ],
                  SizedBox(height: screenHeight * .013),
                  DynamicDropdown(
                    title: "Do you have any unspent criminal convictions?",
                    options: _dropdownOptions,
                    selectedOption: _selectedOption4 ?? "No",
                    onChanged: (newValue) async {
                      setState(() {
                        _selectedOption4 = newValue!;
                        _formData['criminalConviction'] = newValue == 'Yes' ? 1 : 0;
                      });
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setString('criminalConviction', newValue!);
                      widget.onCriminalConvictionChange(newValue);
                    },
                  ),


                  if (_selectedOption4 == 'Yes') ...[
                    SizedBox(height: screenHeight * .013),
                    Container(
                      width: screenWidth * 0.95,
                      child: Align(
                      alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Flexible(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                                  children: [
                                    TextSpan(
                                      text: "If yes, please specify:",
                                    ),
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
                    SizedBox(height: screenHeight * .013),
                    FormField<String>(
                      validator: (value) {
                        // Enable validation only if _selectedOption4 is 'Yes'
                        if (_selectedOption4 == 'Yes' && (value == null || value.isEmpty)) {
                          return 'Please enter details of unspent criminal convictions';
                        }
                        return null; // No error
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      initialValue: widget.specifyController.text,
                      builder: (FormFieldState<String> state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: screenHeight * 0.15,
                              width: screenWidth * 0.95,
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.navButtonColor, width: 0.4),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: TextFormField(
                                controller: widget.specifyController,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  prefixIcon: Icon(
                                    Icons.edit,
                                    size: 20,
                                  ),
                                  border: InputBorder.none,
                                  hintText: "Enter details of unspent criminal convictions",
                                  hintStyle: TextStyle(fontSize: 14),
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                onChanged: (value) {
                                  // Trigger re-validation when text changes
                                  state.didChange(value);
                                },
                              ),
                            ),
                            if (state.hasError)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  state.errorText ?? '',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    )

                  ],
                  SizedBox(height: screenHeight * .2
                  ),
                ],
              ),
            ]
        ),
      ),
    );
  }
  Widget _buildFitnessSection() {
    double screenWidth = MediaQuery.of(context).size.width * 1;
    double screenHeight = MediaQuery.of(context).size.height * 1;
    return SingleChildScrollView(
      child: Form(
        key: _formKeys[1],
        child: Column(
          children: [
            Container(
              height: 45,
              width: screenWidth,
              padding: EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                // borderRadius: BorderRadius.circular(10),
                // color: Color(0xff487eb0),
                color: AppColors.navColor,
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
            ConditionalDropdown(
              title: "Do you have any physical incapabilities?",
              options: _fitnessDropdownOptions,
              selectedOption: selectedPhysicalIncapabilities,
              onChanged: (newValue) async {
                setState(() {
                  selectedPhysicalIncapabilities = newValue;
                });
      
                // Post the selected value
                final valueToPost = newValue == 'Yes' ? 1 : 0;
                if (newValue != null) {
                  print("Value to post: $valueToPost");
                }
                // Save to SharedPreferences
                final prefs = await SharedPreferences.getInstance();
                prefs.setString('PhysicalIncapabilities', newValue ?? "");
                widget.onPhysicalIncapabilitiesChange(newValue!);
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select an option.';
                }
                return null;
              },
            ),
            ConditionalDropdown(
              title: "Do you have any ongoing medical conditions?",
              options: _fitnessDropdownOptions,
              selectedOption: selectedMedicalConditions,
              onChanged: (newValue) async {
                setState(() {
                  selectedMedicalConditions = newValue;
                });
      
                // Post the selected value
                final valueToPost = newValue == 'Yes' ? 1 : 0;
                if (newValue != null) {
                  print("Value to post: $valueToPost");
                }
                // Save to SharedPreferences
                final prefs = await SharedPreferences.getInstance();
                prefs.setString('MedicalConditions', newValue ?? "");
                widget.onMedicalConditionsChange(newValue!);
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select an option.';
                }
                return null;
              },
            ),
          if (selectedMedicalConditions == 'Yes')
            CustomValidateFormField(
              controller: widget.detailsMedicalController,
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
            ConditionalDropdown(
              title: "Are you currently taking any medication?",
              options: _fitnessDropdownOptions,
              selectedOption: selectedMedication,
              onChanged: (newValue) async {
                setState(() {
                  selectedMedication = newValue;
                });
      
                // Post the selected value
                final valueToPost = newValue == 'Yes' ? 1 : 0;
                if (newValue != null) {
                  print("Value to post: $valueToPost");
                }
                // Save to SharedPreferences
                final prefs = await SharedPreferences.getInstance();
                prefs.setString('Medication', newValue ?? "");
                widget.onMedicationChange(newValue!);
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select an option.';
                }
                return null;
              },
            ),
            if (selectedMedication == 'Yes')
              CustomValidateFormField(
                controller: widget.detailsMedicationController,
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
            ConditionalDropdown(
              title: "Do you have ongoing issues with drugs or alcohol?",
              options: _fitnessDropdownOptions,
              selectedOption: selectedDrugs,
              onChanged: (newValue) async {
                setState(() {
                  selectedDrugs = newValue;
                });
      
                // Post the selected value
                final valueToPost = newValue == 'Yes' ? 1 : 0;
                if (newValue != null) {
                  print("Value to post: $valueToPost");
                }
                // Save to SharedPreferences
                final prefs = await SharedPreferences.getInstance();
                prefs.setString('Drugs', newValue ?? "");
                widget.onDrugsChange(newValue!);
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select an option.';
                }
                return null;
              },
            ),
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
                widget.onWearGlassesChange(newValue!);
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select an option.';
                }
                return null;
              },
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                width: screenWidth * 0.95,
                child: Row(
                  children: [
                    Text(
                      'When was your last eye test?',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      " *",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                    )
                  ],
                ),
              ),
            ),
            buildDateContainer(
              labelText: 'dd/mm/yyyy',
              controller: widget.lastWearGlassController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Date of birth is required';
                }
                return null;
              },
            ),
            ConditionalDropdown(
              title: "Have you ever been dismissed for medical reasons?",
              options: _fitnessDropdownOptions,
              selectedOption: selectedMedicalReasons,
              onChanged: (newValue) async {
                setState(() {
                  selectedMedicalReasons = newValue;
                });
      
                // Post the selected value
                final valueToPost = newValue == 'Yes' ? 1 : 0;
                if (newValue != null) {
                  print("Value to post: $valueToPost");
                }
                // Save to SharedPreferences
                final prefs = await SharedPreferences.getInstance();
                prefs.setString('MedicalReasons', newValue ?? "");
                widget.onMedicalReasonsChange(newValue!);
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select an option.';
                }
                return null;
              },
            ),
            if (selectedMedicalReasons == 'Yes')
              CustomValidateFormField(
                controller: widget.detailsReasonController,
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
            ConditionalDropdown(
              title: "Have you been dismissed from previous driving roles in the last 3 years?",
              options: _fitnessDropdownOptions,
              selectedOption: selectedLast3Years,
              onChanged: (newValue) async {
                setState(() {
                  selectedLast3Years = newValue;
                });
      
                // Post the selected value
                final valueToPost = newValue == 'Yes' ? 1 : 0;
                if (newValue != null) {
                  print("Value to post: $valueToPost");
                }
                // Save to SharedPreferences
                final prefs = await SharedPreferences.getInstance();
                prefs.setString('Last3Years', newValue ?? "");
                widget.onLast3YearsChange(newValue!);
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select an option.';
                }
                return null;
              },
            ),
            if (selectedLast3Years == 'Yes')
              CustomValidateFormField(
                controller: widget.detailesDrivingRolesController,
                titleText: "Reasons/dates for dismissal from driving roles.",
                requiredStar: " *",
                hintText: 'enter',
                validator: (value) {
                  if (selectedLast3Years == 'Yes' && (value == null || value.isEmpty)) {
                    return 'This field cannot be empty';
                  }
                  return null;
                },
              ),

            SizedBox(height: screenHeight * .2,),
          ],
        ),
      ),
    );
  }


  // void continueButton() async {
  //   FocusScope.of(context).unfocus();
  //   _saveFormData();
  //   if (_formKeys[subCurrentStep].currentState != null) {
  //     if (_formKeys[subCurrentStep].currentState!.validate()) {
  //       _formKeys[subCurrentStep].currentState!.save();
  //       // bool isSuccess = await _postPersonalSection(subCurrentStep);
  //       // if (isSuccess) {
  //       _goToPage(subCurrentStep + 1);
  //       // }
  //     }
  //   }
  // }
  void continueButton() async {
    FocusScope.of(context).unfocus();
    _saveFormData();
    _goToPage(subCurrentStep + 1);
    // if (_formKeys[subCurrentStep].currentState != null) {
    //   if (_formKeys[subCurrentStep].currentState!.validate()) {
    //     _formKeys[subCurrentStep].currentState!.save();
    //     if (subCurrentStep == 0) {
    //       // firstNameEditing=false;
    //       // print("Next Step---$firstNameEditing");
    //       print("Step 0: Personal Information");
    //       await _postPersonalSection(0);
    //
    //       if (
    //       firstNameValidationError == null &&
    //           lastNameValidationError == null &&
    //           genderValidationError == null &&
    //           imageValidationError == null &&
    //           dobValidationError == null &&
    //           emailValidationError == null &&
    //           passwordValidationError == null &&
    //           repasswordValidationError == null &&
    //           ///Section-2
    //           addressLine1ValidationError == null &&
    //           addressLine2ValidationError == null &&
    //           townCityValidationError == null &&
    //           postCodeValidationError == null &&
    //           phoneValidationError == null &&
    //           alterphoneValidationError == null &&
    //           emgNameValidationError == null &&
    //           emgNumValidationError == null &&
    //
    //           ///section-3
    //           roleValidationError == null &&
    //           consultantValidationError == null &&
    //           passportNumValidationError == null &&
    //           nationalNumValidationError == null &&
    //           // medicalValidationError == null &&
    //           maritalStatusValidationError == null &&
    //           specifyValidationError == null
    //       ) {
    //         // Move to the next step if there are no validation errors
    //         _goToPage(subCurrentStep + 1);
    //       }
    //     }
    //       // else if (subCurrentStep == 1) {
    //     //
    //     //   await _postPersonalSection(1);
    //     //   if (addressLine1ValidationError == null) {
    //     //     _goToPage(subCurrentStep + 1);
    //     //   }
    //     // }
    //   }
    // }

  }
  void _goPreviousStep() {
    Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginView()));
  }
  void _PreviousStep() {
    if (subCurrentStep > 0) {
      _goToPage(subCurrentStep - 1);
    }
  }
  bool validateCurrentStep() {
    final form = _formKeys[subCurrentStep].currentState;
    if (form != null && form.validate()) {
      return true;
    }
    return false;
  }
  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      subCurrentStep = page;
    });
  }


  final ImagePicker _imagePicker = ImagePicker();
  Future<void> _pickImage(ImageSource source) async {
    XFile? pickedImage = await _imagePicker.pickImage(source: source);

    if (pickedImage != null) {
      Uint8List imageData = await pickedImage.readAsBytes();
      String imageName = pickedImage.name;
      List<String> fileNameParts = imageName.split('.');
      String imageExtension = fileNameParts.last;
      String imageNameShortened =
      imageName.length > 15 ? imageName.substring(0, 15) + "..." + imageExtension : imageName;

      // Save image as base64 string
      String base64Image = base64Encode(imageData);

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('image', base64Image);
      prefs.setString('imageName', imageNameShortened);

      setState(() {
        _selectedImageData = imageData;
        _selectedImageName = imageNameShortened;
      });
      onImageChange(imageData, imageNameShortened);
    } else {
      print('No image selected');
    }
  }

  Widget _buildGenderDropdown() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Container(
          width: screenWidth * 0.95,
          child: Row(
            children: [
              const Text(
                'Gender ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const Text(
                '*',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        FormField<String>(
          initialValue: selectedGender ?? '---Select One---', // Set the initial value properly
          validator: (value) {
            // If the gender is not selected or is 'Select Gender', trigger the validation error
            if (value == null || value.isEmpty || value == '---Select One---') {
              return 'Gender is required';
            }
            return null; // No error if gender is selected
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
          builder: (FormFieldState<String> state) {
            return Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  // height: screenHeight * 0.065,
                  height: 55,
                  width: screenWidth * 0.95,
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      // color: state.hasError ? Colors.red : Colors.grey.withOpacity(0.4),
                      color:  Colors.grey.withOpacity(0.4),
                      width: 0.4,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      iconSize: 30.0,
                      value: selectedGender == '---Select One---' ? null : selectedGender,
                      hint: const Text('---Select One---'),
                      items: ['Male', 'Female', 'Other'].map((gender) {
                        return DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                      onChanged: (String? newValue) async {
                        setState(() {
                          selectedGender = newValue; // Update the gender value
                        });
                        // Save selected gender to SharedPreferences
                        final prefs = await SharedPreferences.getInstance();
                        if (newValue != null) {
                          await prefs.setString('gender', newValue); // Store in SharedPreferences
                        }
                        state.didChange(newValue); // Trigger the state change for the form field

                        // Trigger revalidation by explicitly calling setState to recheck the validation
                        setState(() {});
                        widget.onGenderChange(newValue!);
                      },
                    ),
                  ),
                ),
                if (state.hasError)
                  Container(
                    width: screenWidth*0.95,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3.0,left: 10),
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

  Widget _buildMeritalDropdown() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Container(
          width: screenWidth * 0.95,
          child: Row(
            children: [
              const Text(
                'Marital Status ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const Text(
                '*',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        FormField<String>(
          initialValue: selectedMaritalStatus ?? 'Select', // Set the initial value properly
          validator: (value) {
            // If the gender is not selected or is 'Select Gender', trigger the validation error
            if (value == null || value.isEmpty || value == 'Select') {
              return 'Marital status is required';
            }
            return null; // No error if gender is selected
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
          builder: (FormFieldState<String> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  // height: screenHeight * 0.065,
                  height: 55,
                  width: screenWidth * 0.95,
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      // color: state.hasError ? Colors.red : Colors.grey.withOpacity(0.4),
                      color:  Colors.grey.withOpacity(0.4),
                      width: 0.4,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      iconSize: 30.0,
                      value: selectedMaritalStatus == 'Select' ? null : selectedMaritalStatus,
                      hint: const Text('Select'),
                      items: ['Single', 'Married', 'Divorced', 'Widowed', 'Separated'].map((marriedchange) {
                        return DropdownMenuItem(
                          value: marriedchange,
                          child: Text(marriedchange),
                        );
                      }).toList(),
                      onChanged: (String? newValue) async {
                        setState(() {
                          selectedMaritalStatus = newValue; // Update the gender value
                        });
                        // Save selected gender to SharedPreferences
                        final prefs = await SharedPreferences.getInstance();
                        if (newValue != null) {
                          await prefs.setString('maritalStatus', newValue); // Store in SharedPreferences
                        }
                        state.didChange(newValue); // Trigger the state change for the form field

                        // Trigger revalidation by explicitly calling setState to recheck the validation
                        setState(() {});
                        widget.onMarriedChange(newValue!);
                      },
                    ),
                  ),
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0,left: 12),
                    child: Text(
                      state.errorText ?? '',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
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

  Widget buildDateContainer({
    required String labelText,
    required TextEditingController controller,
    required String? Function(String?) validator,
    // required Function(String?) onDateChanged,
  }) {
    final screenWidth = MediaQuery.of(context).size.width * 1;

    return Column(
      children: [
        Container(
          width: screenWidth * 0.95,
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.datetime,
            readOnly: true,
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              hintText: labelText,
              hintStyle: TextStyle(
                color: AppColors.blackColor.withOpacity(0.5),
                fontSize: 15,
              ),
              errorMaxLines: 3,
              errorStyle: TextStyle(
                  fontSize: 12.0,
                  color: Colors.red,
                  fontWeight: FontWeight.bold
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Colors.grey,
                  width: 0.4,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 14.0,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Colors.grey,
                  width: 0.4,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Colors.grey,
                  width: 0.4,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Colors.green,
                  width: 0.4,
                ),
              ),
              prefixIcon: const Icon(
                Icons.calendar_month_outlined,
                color: Colors.black,
              ),
              border: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
            ),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                initialEntryMode: DatePickerEntryMode.calendarOnly,
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1950),
                lastDate: DateTime(2101),
                builder: (BuildContext context, Widget? child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        onPrimary: Colors.white,
                        onBackground: Colors.white,
                        onSurface: Colors.black,
                        primary: AppColors.navColor,
                        brightness: Brightness.light,
                        surface: Colors.white,
                      ),
                      datePickerTheme: const DatePickerThemeData(
                        headerBackgroundColor: AppColors.navColor,
                        backgroundColor: Colors.white,
                        headerForegroundColor: Colors.white,
                        surfaceTintColor: Colors.white,
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.navButtonColor,
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (pickedDate != null) {
                String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
                setState(() {
                  controller.text = formattedDate;
                });

                // Trigger onDateChanged callback
                // onDateChanged(controller.text);
              }
            },
          ),
        ),
      ],
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
          width: screenWidth * 0.95,
          child:  Align(
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
        FormField<String>(
          initialValue: selectedOption, // Set the initial value properly
          validator: validator, // Use the validator passed as a parameter
          autovalidateMode: AutovalidateMode.onUserInteraction,
          builder: (FormFieldState<String> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: screenWidth * 0.95,
                  height: screenHeight * 0.065,
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
                      value: selectedOption, // Nullable value
                      onChanged: (newValue) {
                        state.didChange(newValue); // Update the state when value changes
                        onChanged(newValue); // Call the parent onChanged callback
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
                    width: screenWidth*0.95,
                    child:    Padding(
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
