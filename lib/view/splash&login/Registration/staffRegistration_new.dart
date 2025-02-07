import 'dart:convert';
import 'dart:typed_data';

import 'package:c9_app/Modules/StaffModule/MODEL/staff_registrationModel/ConsultantNames.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/utils/routes/routes_name.dart';
import 'package:c9_app/utils/utils.dart';
import 'package:c9_app/view/splash&login/login_view.dart';
import 'package:c9_app/view/widgets/checkBox_FilePicker_Widgets.dart';
import 'package:c9_app/view/widgets/file_picker_widgets.dart';
import 'package:c9_app/view/widgets/image_picker_Widgets.dart';
import 'package:c9_app/view_model/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Modules/StaffModule/MODEL/staff_registrationModel/StaffRole.dart';


class StaffRegistrationNew extends StatefulWidget {
  const StaffRegistrationNew({Key? key}) : super(key: key);

  @override
  _StaffRegistrationNewState createState() => _StaffRegistrationNewState();
}

class _StaffRegistrationNewState extends State<StaffRegistrationNew> {
  bool isLoading = false;
  bool _isLicenceNumberFilled = false;

  List<String> _selectedLicenseTypes = [];
  final List<String> _licenseTypes = [
    'Class B',
    'Class C',
    'Class D',
    'Class D1',
    'Class E'
  ];

  String? _selectStaffRole;
  List<Data> _roleTypes = [];

  List<String> _accountTypes = ['Bank Account'];
  final List<String> _accountTypeLists = [
    'Bank Account',
    'Building Society',
    'International Bank Account'
  ];
  List<String> _maritalStatuses = [];
   final List<String> _maritalStatusOptions = [
    'Single',
    'Married',
    'Divorced',
    'Widowed',
    'Separated',
  ];

  bool _showBuildingSociety = false; // Initially inactive
  bool _showInternationalBankAccount = false; // Initially inactive

  final List<String> _dropdownOptions = ['Yes', 'No'];
  String? _selectedOption1 = '';
  String? _selectedOption2 = '';
  String? _selectedOption3 = '';

  String? _selected1 = '';
  String? _selected2 = '';
  String? _selected3 = '';
  String? _selected4 = '';
  String? _selected5 = '';
  String? _selected6 = '';
  String? _selected7 = '';
  String? _selected8 = '';
  String? _selected9 = '';
  String? _selected10 = '';
  String? _selected11 = '';
  String? _selected12 = '';
  String? _selected13 = '';
  String? _selected14 = '';
  String? _selected15 = '';

  Map<String, dynamic> _formData = {
    'right_to_work': 0,
    'dbs_edbs': 0,
    'pension_scheme': 0,
    'uk_driving_experience': 0,
    'valid_uk_driving_license': 0,
    'penalty_points': 0,
    'physical_incapabilities': 0,
    'ongoing_medical_conditions': 0,
    'taking_medication': 0,
    'drug_or_alcohol_issues': 0,
    'wears_glasses': 0,
    'dismissed_for_medical_reasons': 0,
    'dismissed_from_driving_roles': 0,
    'is_uk_citizen': 0,
    'is_authorized_to_work_in_uk': 0,
    'has_unspent_criminal_convictions': 0,
    'noCpcCard': 0,
    'noTachoCard': 0,
  };
  List<ConsultantNames> consultantNames = [];
  List<ConsultantNames> filteredConsultants = [];
  bool _isExpanded = false;

  String? _selectedLicenseType;
  bool permissionGranted = false;

  Uint8List? _selectedStaffImage;
  String? _selectedStaffImageName;

  Uint8List? _selectedStaffFile;
  String? _selectedStaffFileName;

  Uint8List? _selectedEmployeeFile;
  String? _selectedEmployeeFileName;

  Uint8List? _selectedFile1;
  String? _selectedFileName1;

  Uint8List? _selectedFile2;
  String? _selectedFileName2;

  Uint8List? _selectedFile3;
  String? _selectedFileName3;

  String shortenFileName(String filePath) {
    if (filePath.length <= 5) {
      return filePath;
    } else {
      String fileName = filePath.substring(filePath.lastIndexOf('/') + 1);
      String extension = fileName.split('.').last;
      String nameWithoutExtension =
          fileName.substring(0, fileName.lastIndexOf('.'));
      int maxLength = 5;
      if (nameWithoutExtension.length <= maxLength) {
        return '${nameWithoutExtension}...$extension';
      } else {
        return '${nameWithoutExtension.substring(0, maxLength)}...$extension';
      }
    }
  }

  String getFileNameFromPath(String path) {
    List<String> pathSegments = path.split('/');
    return pathSegments.last;
  }

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    fetchStaffRoles();
    fetchConsultantNames();
    consultantFocusNode.addListener(() {
      if (!consultantFocusNode.hasFocus) {
        setState(() {
          _isExpanded = false;
        });
      }
    });
  }

  Future<void> fetchStaffRoles() async {
    try {
      final response =
          await https.get(Uri.parse('${AppUrl.baseUrl}/api/app/role/type'));

      if (response.statusCode == 200) {
        StaffRole staffRoles = StaffRole.fromJson(json.decode(response.body));

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
      final response = await https.get(
          Uri.parse('${AppUrl.baseUrl}/api/app/staff-registration-dropdown'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          consultantNames =
              data.map((item) => ConsultantNames.fromJson(item)).toList();
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
              .where((consultant) =>
                  consultant.name
                      ?.toLowerCase()
                      .contains(query.toLowerCase()) ??
                  false)
              .toList()
          : consultantNames;
    });
  }

  final ValueNotifier<bool> _isCPCCheckBoxSelected = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isTachoCheckBoxSelected =
      ValueNotifier<bool>(false);

  ValueNotifier<bool> _isPasswordMatching = ValueNotifier<bool>(true);
  void _checkPasswordMatch() {
    _isPasswordMatching.value =
        _passwordController.text == _reEnterpasswordController.text;
  }

  TextEditingController _FirstnameController = TextEditingController();
  TextEditingController _LastnameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  ValueNotifier<bool> _obsecurePassword = ValueNotifier<bool>(true);
  TextEditingController _passwordController = TextEditingController();

  ValueNotifier<bool> _reobsecurePassword = ValueNotifier<bool>(true);
  TextEditingController _reEnterpasswordController = TextEditingController();

  TextEditingController _address1Controller = TextEditingController();
  TextEditingController _address2Controller = TextEditingController();

  TextEditingController _townCityController = TextEditingController();
  TextEditingController _postCodeController = TextEditingController();

  TextEditingController _dobController = TextEditingController();
  TextEditingController _regnumberController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController consultantController = TextEditingController();

  ///Banking Controllers
  TextEditingController _bankNameController = TextEditingController();
  TextEditingController _accountNameController = TextEditingController();
  TextEditingController _accountNumberController = TextEditingController();
  TextEditingController _bankCodeController = TextEditingController();
  TextEditingController _buildingSocietyRollNumberController =
      TextEditingController();
  TextEditingController _Recipient1Controller = TextEditingController();
  TextEditingController _Recipient2Controller = TextEditingController();
  TextEditingController _Recipient3Controller = TextEditingController();
  TextEditingController _IBAnController = TextEditingController();
  TextEditingController _BIcController = TextEditingController();
  TextEditingController _paymentCountryCodeController = TextEditingController();
  TextEditingController _creditCurrencyController = TextEditingController();

  TextEditingController _passportNumberController = TextEditingController();

  String SelectedGender = '';
  String? errorMessage;
  //Image here
  //_selectedLicenseType
  TextEditingController _licNumController = TextEditingController();
  TextEditingController _licExpiryController = TextEditingController();

  TextEditingController _anyPointController = TextEditingController();

  TextEditingController _cpcNumController = TextEditingController();
  TextEditingController _cpcExpiryController = TextEditingController();
  TextEditingController _tachoExpiryController = TextEditingController();
  TextEditingController _dbsExpiryController = TextEditingController();

  TextEditingController _techoDropFileController = TextEditingController();
  TextEditingController _techoNumberFileController = TextEditingController();

  // -----------------------------------------------
  // TextEditingController _descriptionController = TextEditingController();
  TextEditingController _medicalController = TextEditingController();

  FocusNode firstnameFocusNode = FocusNode();
  FocusNode lastnameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode reEnterpasswordFocusNode = FocusNode();
  FocusNode address1FocusNode = FocusNode();
  FocusNode address2FocusNode = FocusNode();
  FocusNode townFocusNode = FocusNode();
  FocusNode postFocusNode = FocusNode();
  FocusNode dobFocusNode = FocusNode();
  FocusNode regnumberFocusNode = FocusNode();
  FocusNode phoneFocusNode = FocusNode();
  FocusNode passwordNumFocusNode = FocusNode();
  FocusNode licNumFocusNode = FocusNode();
  FocusNode licExpiryFocusNode = FocusNode();
  FocusNode anyPointFocusNode = FocusNode();
  FocusNode cpcNumFocusNode = FocusNode();
  FocusNode cpcExpiryFocusNode = FocusNode();
  FocusNode techoDropFocusNode = FocusNode();
  FocusNode techoNumFocusNode = FocusNode();
  FocusNode medicalFocusNode = FocusNode();
  FocusNode consultantFocusNode = FocusNode();

  FocusNode bankingFocus = FocusNode();
  FocusNode acchountNameFocus = FocusNode();
  FocusNode accnountNumber = FocusNode();
  FocusNode bankCodeFocus = FocusNode();
  FocusNode buildSocietyFocus = FocusNode();
  FocusNode recipientAddress1Focus = FocusNode();
  FocusNode recipientAddress2Focus = FocusNode();
  FocusNode recipientAddress3Focus = FocusNode();
  FocusNode iBANFocus = FocusNode();
  FocusNode BICFocus = FocusNode();
  FocusNode paymentIosCountryFocus = FocusNode();
  FocusNode creditIosCurrencyFocus = FocusNode();

  TextEditingController _drivingLicenseNumberController =
      TextEditingController();
  TextEditingController _drivingLicenseNumberController2 =
      TextEditingController();
  TextEditingController _drivingLicenseNumberController3 =
      TextEditingController();
  TextEditingController _dateofIssueDrivingController = TextEditingController();
  TextEditingController _drivingLicensecategoryController =
      TextEditingController();
  TextEditingController _checkCodeDrivingLicenseController =
      TextEditingController();
  TextEditingController _detailMedicalConditionController =
      TextEditingController();
  TextEditingController _detailOfMedicationController = TextEditingController();
  TextEditingController _lasteyeController = TextEditingController();
  TextEditingController _reasonForDismissalController = TextEditingController();
  TextEditingController _reasondatesForDrivingRolesController =
      TextEditingController();
  FocusNode drivingLicenseFocus = FocusNode();
  FocusNode drivingLicensecategoryFocus = FocusNode();
  FocusNode checkCodeDrivingLicenseFocus = FocusNode();
  FocusNode detailOfMedacationFocus = FocusNode();
  FocusNode lastEyeFocus = FocusNode();
  FocusNode reasonForDismissalFocus = FocusNode();
  FocusNode reasondatesForDrivingRolesFocus = FocusNode();
  final FocusNode materialStatusFocus = FocusNode();
  final FocusNode citizenOfUkFocus = FocusNode();
  final FocusNode authorizedToWorkInUKFocus = FocusNode();
  final FocusNode anyUnspentCriminalConvictionsFocus = FocusNode();
  final FocusNode pleaseSpecifyFocus = FocusNode();
  //Questions 4 No

  String _passwordValidationError = '';
  String _confirmPassValidationError = '';
  String _licenseTypeValidationError = '';
  Map<String, String> _validationErrors = {};

  String _cpcNumberValidationError = '';
  String _cpcExpiryValidationError = '';
  String _tachoExpiryValidationError = '';
  String _tachNumberValidationError = '';
  String _medicalValidationError = '';
  String? _passportValidationError = '';
  String? _upCPCValidationError = '';
  String? _upTachoValidationError = '';
  String? _genderValidationError = '';
  String? _roleValidationError = '';
  // New validation error strings
  String _accountTypeValidationError = '';
  String _bankNameValidationError = '';
  String _accountNameValidationError = '';
  String _accountNumberValidationError = '';
  String _bankCodeValidationError = '';
  String _buildingSocietyRollNumberValidationError = '';

  String _recipientAddress1ValidationError = '';
  String _recipientAddress2ValidationError = '';
  String _recipientAddress3ValidationError = '';
  String _ibanValidationError = '';
  String _bicSwiftValidationError = '';
  String _paymentIsoCountryCodeValidationError = '';
  String _creditIsoCurrencyCodeValidationError = '';

  String _firstValidationError = '';
  String _lastValidationError = '';
  String _emailValidationError = '';

  String _phoneValidationError = '';
  String? _workerImageValidationError = '';
  String _addressLine1ValidationError = '';
  String _addressLine2ValidationError = '';
  String _townOrCityValidationError = '';
  String _postCodeValidationError = '';
  String _passportNumberValidationError = '';

  String _dobValidationError = '';
  String _dbsValidationError = '';
  String _niValidationError = '';
  String _licExpiryValidationError = '';
  String _licenceEndorValidationError = '';

  /// New validation fields
  String _ukDrivingExperienceError = '';
  String _cpcValidHolderError = '';
  String _tachoValidHolderError = '';
  String _validUKDrivingExperienceError = '';
  String _panaltyPointsError = '';
  String _drivingLicenseNumberError = '';
  String _dateofIssueDrivingLicenseError = '';
  String _drivingLicenseCategoryError = '';
  String _checkCodeDrivingLicenseError = '';
  String _anyPhysicalIncapabilitiesError = '';
  String _anyOngoingMedicalConditionError = '';
  String _currentlyTakingAnyMedicationError = '';
  String _detailsOfMedicationError = '';
  String _drugsOrAlcoholError = '';
  String _currentlyWearGlassesError = '';
  String _lastEyeError = '';
  String _dismissedForMedicalReasonError = '';
  String _dismissalDueToMedicalReasonError = '';
  String _reasonForDismissalMedicalReasonError = '';
  String _previousDrivingRolesLast3yearsError = '';
  String _dismissalFromDrivingRolesError = '';
  String _materialStatusError = '';
  String _citizenOfUkError = '';
  String _authorizedToWorkInUKError = '';
  String _anyUnspentCriminalConvictionsError = '';
  String _pleaseSpecifyError = '';

  // _licenseTypeValidationError = '';
  String _licNumValidationError = '';
  // _cpcNumberValidationError = '';
  // _cpcExpiryValidationError = '';
  // _tachNumberValidationError = '';

  // _passwordValidationError = '';
  // _confirmPassValidationError = '';
  // _medicalValidationError = '';

  // _passportValidationError = '';
  // _upCPCValidationError = '';
  // _upTachoValidationError = '';
  // _genderValidationError = '';
  String _drivingLicenceValidationError = '';
  String _proofOfAddressValidationError = '';

  TextEditingController materialStatusController = TextEditingController();

  TextEditingController pleaseSpecifyController = TextEditingController();

  void _updateCPCValidationError(String? message) {
    setState(() {
      _upCPCValidationError = message;
    });
  }

  void _updateTachoValidationError(String? message) {
    setState(() {
      _upTachoValidationError = message;
    });
  }

  Future<void> postData() async {
    setState(() {
      isLoading = true;
      _updateValidationErrorState();
    });

    final Map<String, String> licenseTypeMap = {
      'Class B': 'classB',
      'Class C': 'classC',
      'Class D': 'classD',
      'Class D1': 'classD1',
      'Class E': 'classE',
    };

    final Map<String, String> accountTypeMap = {
      'Bank Account': 'BANK_ACCOUNT',
      'Building Society': 'BUILDING_SOCIETY',
      'International Bank Account': 'INTERNATIONAL_BANK_ACCOUNT',
    };
    final Map<String, String> maritalTypeMap = {
      'Single': 'single',
      'Married': 'married',
      'Divorced': 'divorced',
      'Widowed': 'widowed',
      'Separated': 'separated',
    };

    if(_maritalStatuses.isEmpty || !maritalTypeMap.values.contains(_maritalStatuses[0])){
      _materialStatusError = 'Marital status is required .';
    }

    if (_accountTypes.isEmpty ||
        !accountTypeMap.values.contains(_accountTypes[0])) {
      _accountTypeValidationError = 'Account type is required.';
    }

    // Validate fields based on account type
    if (_accountTypes.contains('Bank Account') ||
        _accountTypes.contains('Building Society')) {
      if (_bankNameController.text.isEmpty) {
        _bankNameValidationError =
            'Bank name is required for Bank Account or Building Society.';
      }

      if (_accountNameController.text.isEmpty) {
        _accountNameValidationError =
            'Account name is required for Bank Account or Building Society.';
      }

      if (_accountNumberController.text.isEmpty) {
        _accountNumberValidationError =
            'Account number is required for Bank Account or Building Society.';
      } else if (_accountNumberController.text.length < 1 ||
          _accountNumberController.text.length > 8) {
        _accountNumberValidationError =
            'Account number must be between 1 and 8 digits.';
      }

      if (_bankCodeController.text.isEmpty) {
        _bankCodeValidationError =
            'Bank code is required for Bank Account or Building Society.';
      } else if (!RegExp(r'^\d{6}$|^\d{2}-\d{2}-\d{2}$|^\d{2} \d{2} \d{2}$')
          .hasMatch(_bankCodeController.text)) {
        _bankCodeValidationError =
            'Bank code format must be 123456, 12-34-56, or 12 34 56.';
      }

      if (_accountTypes.contains('Building Society') &&
          _buildingSocietyRollNumberController.text.isEmpty) {
        _buildingSocietyRollNumberValidationError =
            'Building Society roll number is required for Building Society.';
      }

      // Validate International Bank Account fields
    } else if (_accountTypes.contains('International Bank Account')) {
      if (_Recipient1Controller.text.isEmpty) {
        _recipientAddress1ValidationError =
            'Recipient address line 1 is required for International Bank Account.';
      }

      if (_Recipient2Controller.text.isEmpty) {
        _recipientAddress2ValidationError =
            'Recipient address line 2 is required for International Bank Account.';
      }

      if (_Recipient3Controller.text.isEmpty) {
        _recipientAddress3ValidationError =
            'Recipient address line 3 is required for International Bank Account.';
      }

      if (_IBAnController.text.isEmpty) {
        _ibanValidationError =
            'IBAN is required for International Bank Account.';
      }

      if (_BIcController.text.isEmpty) {
        _bicSwiftValidationError =
            'BIC/SWIFT code is required for International Bank Account.';
      } else if (_BIcController.text.length > 34) {
        _bicSwiftValidationError =
            'BIC/SWIFT code cannot exceed 34 characters.';
      }

      if (_paymentCountryCodeController.text.isEmpty ||
          _paymentCountryCodeController.text.length != 2) {
        _paymentIsoCountryCodeValidationError =
            'A valid 2-letter ISO country code is required.';
      }

      if (_creditCurrencyController.text.isEmpty ||
          _creditCurrencyController.text.length != 3) {
        _creditIsoCurrencyCodeValidationError =
            'A valid 3-letter ISO currency code is required.';
      }
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String _token = prefs.getString('token') ?? '';

      String apiUrl = '${AppUrl.baseUrl}/api/app/staff-registration';
      var request = https.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers.addAll({
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
      });

      if (_dobController.text.isNotEmpty) {
        try {
          // Parse input as `dd/MM/yyyy` and ensure it's in the same format
          DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(_dobController.text);
          String formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
          request.fields['dob'] = formattedDate;
        } catch (e) {
          print('Invalid date format for licenceExpiry: ${_dobController.text}');

        }
      }
      if (_dbsExpiryController.text.isNotEmpty) {
        try {
          // Parse input as `dd/MM/yyyy` and ensure it's in the same format
          DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(_dbsExpiryController.text);
          String formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
          request.fields['dbsExpiry'] = formattedDate;
        } catch (e) {
          print('Invalid date format for : ${_dbsExpiryController.text}');

        }
      }


      request.fields['first_name'] = _FirstnameController.text;
      request.fields['last_name'] = _LastnameController.text;
      request.fields['email'] = _emailController.text;
      request.fields['addressLine1'] = _address1Controller.text;
      request.fields['addressLine2'] = _address2Controller.text;
      request.fields['townOrCity'] = _townCityController.text;
      request.fields['postCode'] = _postCodeController.text;
      request.fields['password'] = _passwordController.text;
      request.fields['consultant'] = consultantController.text;
      request.fields['confirm_password'] = _reEnterpasswordController.text;

      request.fields['ni_number'] = _regnumberController.text;
      request.fields['phone'] = _phoneNumberController.text;
      // request.fields['passportNumber'] = ;
      request.fields['passportNumber'] = _passportNumberController.text;

      if (_selectStaffRole != null) {
        request.fields['role'] = _selectStaffRole!;
      }

      request.fields['medicalConditions'] = _medicalController.text;
      request.fields['rightToWorkUK'] = _selectedOption1 == 'Yes' ? '1' : '0';
      request.fields['dbsCheck'] = _selectedOption2 == 'Yes' ? '1' : '0';
      request.fields['optOutOfPension'] = _selectedOption3 == 'Yes' ? '1' : '0';
      request.fields['gender'] = SelectedGender.toString();

      // Add image if selected
      if (_selectedStaffImage != null) {
        request.files.add(await https.MultipartFile.fromBytes(
          'image',
          _selectedStaffImage!,
          filename: _selectedStaffImageName!,
        ));
        print("Image added to request: $_selectedStaffImageName");
      }

      if (_selectedEmployeeFile != null) {
        request.files.add(await https.MultipartFile.fromBytes(
          'proofOfAddress',
          _selectedEmployeeFile!,
          filename: _selectedEmployeeFileName!,
        ));
      }

      if (_selectedFile1 != null) {
        request.files.add(await https.MultipartFile.fromBytes(
          'passport',
          _selectedFile1!,
          filename: _selectedFileName1!,
        ));
      }

      if(_maritalStatuses.isEmpty ||_maritalStatusOptions[0].isEmpty){
        _materialStatusError = 'Marital status is required.';
        request.fields['marital_status'] = ''; // Ensure this field is sent

      } else {
        request.fields['marital_status'] = maritalTypeMap[_maritalStatuses[0]] ?? ''; // Send correct account type
      }

      // Validate Account Type and Bank Info
      if (_accountTypes.isEmpty || _accountTypes[0].isEmpty) {
        _accountTypeValidationError = 'Account type is required.';
        request.fields['account_type'] = ''; // Ensure this field is sent
      } else {
        request.fields['account_type'] =
            accountTypeMap[_accountTypes[0]] ?? ''; // Send correct account type
      }



      // request.fields['account_type'] = accountTypeMap[_accountTypes[0]] ?? '';
      request.fields['bank_name'] = _bankNameController.text;
      request.fields['account_name'] = _accountNameController.text;

      if (_accountTypes.contains('Bank Account') ||
          _accountTypes.contains('Building Society')) {
        request.fields['account_number'] = _accountNumberController.text;
        request.fields['bank_code'] = _bankCodeController.text;

        if (_accountTypes.contains('Building Society')) {
          request.fields['building_society_roll_number'] =
              _buildingSocietyRollNumberController.text;
        }
      }

      if (_accountTypes.contains('International Bank Account')) {
        request.fields['recipient_address1'] = _Recipient1Controller.text;
        request.fields['recipient_address2'] = _Recipient2Controller.text;
        request.fields['recipient_address3'] = _Recipient3Controller.text;
        request.fields['iban'] = _IBAnController.text;
        request.fields['bic_swift'] = _BIcController.text;
        request.fields['payment_iso_country_code'] =
            _paymentCountryCodeController.text;
        request.fields['credit_iso_currency_code'] =
            _creditCurrencyController.text;
      }

      /// New fields Validation

      request.fields['is_uk_citizen'] = _selected11 == 'Yes' ? '1' : '0';
      request.fields['has_unspent_criminal_convictions'] =
          _selected12 == 'Yes' ? '1' : '0';
      if (_selected12 == 'Yes') {
        print(" has_unspent_criminal_convictions ----$_selected12");
        request.fields['unspent_criminal_convictions_details'] =
            pleaseSpecifyController.text;
      }
      request.fields['is_authorized_to_work_in_uk'] = _selected13 == 'Yes' ? '1' : '0';
      // request.fields['marital_status'] = materialStatusController.text;

      request.fields['noCpcCard'] = _selected14 == 'Yes' ? '1' : '0';
      if (_selected14 == 'Yes') {
        request.fields['cpcNumber'] = _cpcNumController.text;
        //  if (_cpcExpiryController.text.isNotEmpty) {
        //   request.fields['cpcExpiry'] = DateFormat('yyyy-MM-dd').format(
        //       DateFormat('dd-MM-yyyy').parse(_cpcExpiryController.text));
        // }
        if (_cpcExpiryController.text.isNotEmpty) {
          try {
            // Parse input as `dd/MM/yyyy` and ensure it's in the same format
            DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(_cpcExpiryController.text);
            String formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
            request.fields['cpcExpiry'] = formattedDate;
          } catch (e) {
            print('Invalid date format for CPCExpiry: ${_cpcExpiryController.text}');

          }
        }

        if (_selectedFile2 != null) {
          request.files.add(await https.MultipartFile.fromBytes(
            'cpc',
            _selectedFile2!,
            filename: _selectedFileName2!,
          ));
          print("CPC Image------ $_selectedFile2");
        } else if (_isCPCUploaded) {
          request.fields['noCPC'] = "on";
          print("CPC Else If Executes----------");
        }
      }

      request.fields['noTachoCard'] = _selected15 == 'Yes' ? '1' : '0';
      if (_selected15 == 'Yes') {
        request.fields['tachoNumber'] = _techoNumberFileController.text;

        if (_tachoExpiryController.text.isNotEmpty) {
          try {
            // Parse input as `dd/MM/yyyy` and ensure it's in the same format
            DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(_tachoExpiryController.text);
            String formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
            request.fields['tachoExpiry'] = formattedDate;
          } catch (e) {
            print('Invalid date format for tachoExpiry: ${_tachoExpiryController.text}');

          }
        }


        if (_selectedFile3 != null) {
          request.files.add(await https.MultipartFile.fromBytes(
            'tacho',
            _selectedFile3!,
            filename: _selectedFileName3!,
          ));
          print("Tacho Image------$_selectedFile3");
        } else if (_isTachoUploaded) {
          request.fields['noTacho'] = "on";
          print("Tacho Else If Executes----------");
        }
      }


      request.fields['valid_uk_driving_license'] = _selected1 == 'Yes' ? '1' : '0';
      if (_selected1 == 'Yes') {
        request.fields['uk_driving_experience'] = _selected2 == 'Yes' ? '1' : '0';
      }
      if (_selected2 == 'Yes') {
        request.fields['penalty_points'] = _selected3 == 'Yes' ? '1' : '0';
        request.fields['licenceNumber'] = _licNumController.text;

        // if (_dateofIssueDrivingController.text.isNotEmpty) {
        //   request.fields['driving_license_issue_date'] =
        //       DateFormat('yyyy-MM-dd').format(DateFormat('dd-MM-yyyy')
        //           .parse(_dateofIssueDrivingController.text));
        // }
        if (_dateofIssueDrivingController.text.isNotEmpty) {
          try {
            // Parse input as `dd/MM/yyyy` and ensure it's in the same format
            DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(_dateofIssueDrivingController.text);
            String formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
            request.fields['driving_license_issue_date'] = formattedDate;
          } catch (e) {
            print('Invalid date format for licenceExpiry: ${_dateofIssueDrivingController.text}');
          }
        }

        // if (_licExpiryController.text.isNotEmpty) {
        //   request.fields['licenceExpiry'] = DateFormat('yyyy-MM-dd').format(
        //       DateFormat('dd-MM-yyyy').parse(_licExpiryController.text));
        // }

        if (_licExpiryController.text.isNotEmpty) {
          try {
            // Parse input as `dd/MM/yyyy` and ensure it's in the same format
            DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(_licExpiryController.text);
            String formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
            request.fields['licenceExpiry'] = formattedDate;
          } catch (e) {
            print('Invalid date format for licenceExpiry: ${_licExpiryController.text}');
          }
        }


        request.fields['driving_license_check_code'] =
            _checkCodeDrivingLicenseController.text;

        if (_selectedStaffFile != null) {
          request.files.add(await https.MultipartFile.fromBytes(
            'drivingLicence',
            _selectedStaffFile!,
            filename: _selectedStaffFileName!,
          ));
        }

        List<String> postedLicenseTypes = [];
        for (int i = 0; i < _selectedLicenseTypes.length; i++) {
          String postedValue = licenseTypeMap[_selectedLicenseTypes[i]] ?? '';
          if (postedValue.isNotEmpty) {
            request.fields['licenceTypes[$i]'] = postedValue;
            postedLicenseTypes.add(postedValue);
          }
        }
        print('Licence Types:------------- $postedLicenseTypes');
        request.fields['licenceEndorsements'] = _anyPointController.text;
      }


      request.fields['physical_incapabilities'] =
          _selected4 == 'Yes' ? '1' : '0';
      request.fields['ongoing_medical_conditions'] =
          _selected5 == 'Yes' ? '1' : '0';
      request.fields['taking_medication'] = _selected6 == 'Yes' ? '1' : '0';
      request.fields['drug_or_alcohol_issues'] =
          _selected7 == 'Yes' ? '1' : '0';
      request.fields['wears_glasses'] = _selected8 == 'Yes' ? '1' : '0';
      request.fields['dismissed_for_medical_reasons'] =
          _selected9 == 'Yes' ? '1' : '0';
      request.fields['dismissed_from_driving_roles'] =
          _selected10 == 'Yes' ? '1' : '0';
      request.fields['medical_condition_details'] =
          _detailMedicalConditionController.text;
      request.fields['medication_details'] = _detailOfMedicationController.text;
      request.fields['dismissal_reason'] = _reasonForDismissalController.text;
      request.fields['driving_dismissal_details'] = _reasondatesForDrivingRolesController.text;


      if (_lasteyeController.text.isNotEmpty) {
        try {
          // Parse input as `dd/MM/yyyy` and ensure it's in the same format
          DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(_lasteyeController.text);
          String formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
          request.fields['last_eye_test'] = formattedDate;
        } catch (e) {
          print('Invalid date format for licenceExpiry: ${_lasteyeController.text}');

        }
      }


      // Send request and handle response
      var response = await request.send();
      String responseString = await response.stream.bytesToString();

      print('Request fields: ${request.fields}');
      print('Response status code: ${response.statusCode}');
      print('Response body: $responseString');

      if (response.statusCode == 201) {


        print('Data submitted successfully');
        print(responseString);
        Utils.flushBarSuccessMessageRegistration(
            'Your account was created successfully, Admin will approve your account soon!',
            context);
        setState(() {
          isLoading = false;
        });
        Future.delayed(Duration(seconds: 2), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginView(),
            ),
          );
        });


      } else if (response.statusCode == 422) {
        print(response);

        // Parse and handle validation error response
        final Map<String, dynamic> responseData = jsonDecode(responseString);
        if (responseData.containsKey('errors')) {
          final Map<String, dynamic> errors = responseData['errors'];
          errors.forEach((field, messages) {
            final String errorMessage =
                messages.isNotEmpty ? messages.first : 'Unknown error';
            switch (field) {
              case 'first_name':
                _firstValidationError = errorMessage;
                break;
              case 'last_name':
                _lastValidationError = errorMessage;
                break;
              case 'email':
                _emailValidationError = errorMessage;
                break;
              case 'password':
                _passwordValidationError = errorMessage;
                break;
              case 'confirm_password':
                _confirmPassValidationError = errorMessage;
                break;
              case 'addressLine1':
                _addressLine1ValidationError = errorMessage;
                break;
              case 'addressLine2':
                _addressLine2ValidationError = errorMessage;
                break;
              case 'townOrCity':
                _townOrCityValidationError = errorMessage;
                break;
              case 'postCode':
                _postCodeValidationError = errorMessage;
                break;
              case 'dob':
                _dobValidationError = errorMessage;
                break;
              case 'ni_number':
                _niValidationError = errorMessage;
                break;
              case 'phone':
                _phoneValidationError = errorMessage;
                break;
              case 'image':
                _workerImageValidationError = errorMessage ?? '';
                break;
              case 'staff_type':
                _validationErrors['staff_type'] = errorMessage;
                break;
              case 'licenceExpiry':
                _licExpiryValidationError = errorMessage;
                break;
              case 'licenceEndorsements':
                _licenceEndorValidationError = errorMessage;
                break;
              case 'licenceTypes':
                _licenseTypeValidationError = errorMessage;
                break;
              case 'licenceNumber':
                _licNumValidationError = errorMessage;
                break;
              case 'cpcNumber':
                _cpcNumberValidationError = errorMessage;
                break;
              case 'cpcExpiry':
                _cpcExpiryValidationError = errorMessage;
                break;
              case 'tachoNumber':
                _tachNumberValidationError = errorMessage;
                break;
              case 'tachoExpiry':
                _tachoExpiryValidationError = errorMessage;
                break;

              case 'dbsExpiry':
                _dbsValidationError = errorMessage;
                break;
              case 'medicalConditions':
                _medicalValidationError = errorMessage;
                break;
              case 'drivingLicence':
                _drivingLicenceValidationError = errorMessage;
                break;
              case 'proofOfAddress':
                _proofOfAddressValidationError = errorMessage;
                break;
              case 'passport':
                _passportValidationError = errorMessage ?? '';
                break;
              case 'passportNumber':
                _passportNumberValidationError = errorMessage ?? '';
                break;
              case 'cpc':
                _upCPCValidationError = errorMessage ?? '';
                break;
              case 'tacho':
                _upTachoValidationError = errorMessage ?? '';
                break;
              case 'gender':
                _genderValidationError = errorMessage ?? '';
                break;

              case 'role':
                _roleValidationError = errorMessage ?? '';
                break;

              case 'account_type':
                _validationErrors['account_type'] = errorMessage;

                // _accountTypeValidationError = errorMessage;
                break;

              case 'bank_name':
                _bankNameValidationError = errorMessage;
                break;
              case 'account_name':
                _accountNameValidationError = errorMessage;
                break;
              case 'account_number':
                _accountNumberValidationError = errorMessage;
                break;
              case 'bank_code':
                _bankCodeValidationError = errorMessage;
                break;
              case 'building_society_roll_number':
                _buildingSocietyRollNumberValidationError = errorMessage;
                break;

              case 'recipient_address1':
                _recipientAddress1ValidationError = errorMessage;
                break;

              case 'recipient_address2':
                _recipientAddress2ValidationError = errorMessage;
                break;

              case 'recipient_address3':
                _recipientAddress3ValidationError = errorMessage;
                break;

              case 'iban':
                _ibanValidationError = errorMessage;
                break;

              case 'bic_swift':
                _bicSwiftValidationError = errorMessage;
                break;

              case 'payment_iso_country_code':
                _paymentIsoCountryCodeValidationError = errorMessage;
                break;

              case 'credit_iso_currency_code':
                _creditIsoCurrencyCodeValidationError = errorMessage;
                break;

              /// nEw Fields
              case 'is_uk_citizen':
                _citizenOfUkError = errorMessage;
                break;
              case 'is_authorized_to_work_in_uk':
                _authorizedToWorkInUKError = errorMessage;
                break;
              case 'has_unspent_criminal_convictions':
                _anyUnspentCriminalConvictionsError = errorMessage;
                break;
              case 'marital_status':
                // _materialStatusError = errorMessage;
                _validationErrors['marital_status'] = errorMessage;
                break;

              case 'unspent_criminal_convictions_details':
                _pleaseSpecifyError = errorMessage;
                break;

              case 'uk_driving_experience':
                _ukDrivingExperienceError = errorMessage;
                break;

              case 'noCpcCard':
                _cpcValidHolderError = errorMessage;
                break;

              case 'noTachoCard':
                _tachoValidHolderError = errorMessage;
                break;

              case 'valid_uk_driving_license':
                _validUKDrivingExperienceError = errorMessage;
                break;
              case 'penalty_points':
                _panaltyPointsError = errorMessage;
                break;

              case 'driving_license_check_code':
                _checkCodeDrivingLicenseError = errorMessage;
                break;

              case 'driving_license_issue_date':
                _dateofIssueDrivingLicenseError = errorMessage;
                break;

              case 'physical_incapabilities':
                _anyPhysicalIncapabilitiesError = errorMessage;
                break;

              case 'ongoing_medical_conditions':
                _anyOngoingMedicalConditionError = errorMessage;
                break;

              case 'taking_medication':
                _currentlyTakingAnyMedicationError = errorMessage;
                break;

              case 'drug_or_alcohol_issues':
                _drugsOrAlcoholError = errorMessage;
                break;

              case 'wears_glasses':
                _currentlyWearGlassesError = errorMessage;
                break;

              case 'dismissed_for_medical_reasons':
                _dismissedForMedicalReasonError = errorMessage;
                break;

              case 'dismissed_from_driving_roles':
                _previousDrivingRolesLast3yearsError = errorMessage;
                break;

              case 'medical_condition_details':
                _detailsOfMedicationError = errorMessage;
                break;

              case 'medication_details':
                _dismissalDueToMedicalReasonError = errorMessage;
                break;

              case 'dismissal_reason':
                _reasonForDismissalMedicalReasonError = errorMessage;
                break;

              case 'driving_dismissal_details':
                _dismissalFromDrivingRolesError = errorMessage;
                break;

              case 'last_eye_test':
                _lastEyeError = errorMessage;
                break;
            }
          });

          // Show error messages to the user
          setState(() {
            _validationErrors = {
              for (var entry in errors.entries) entry.key: entry.value.first,

              'first_name': _firstValidationError,
              'last_name': _lastValidationError,
              'email': _emailValidationError,
              'password': _passwordValidationError,
              'confirm_password': _confirmPassValidationError,
              'addressLine1': _addressLine1ValidationError,
              'addressLine2': _addressLine2ValidationError,
              'townOrCity': _townOrCityValidationError,
              'postCode': _postCodeValidationError,
              'dob': _dobValidationError,
              'dbsExpiry': _dbsValidationError,
              'ni_number': _niValidationError,
              'phone': _phoneValidationError,
              'image': _workerImageValidationError?? '',
              'licenceExpiry': _licExpiryValidationError,
              'licenceEndorsements': _licenceEndorValidationError,
              'licenceTypes': _licenseTypeValidationError,
              'licenceNumber': _licNumValidationError,
              'cpcNumber': _cpcNumberValidationError,
              'cpcExpiry': _cpcExpiryValidationError,
              'tachoNumber': _tachNumberValidationError,
              'tachoExpiry': _tachoExpiryValidationError,
              'medicalConditions': _medicalValidationError,
              'drivingLicence': _drivingLicenceValidationError,
              'passport': _passportValidationError ?? '',
              'passportNumber': _passportNumberValidationError,
              'cpc': _upCPCValidationError ?? '',
              'tacho': _upTachoValidationError ?? '',
              'gender': _genderValidationError ?? '',
              'role': _roleValidationError ?? '',
              'proofOfAddress': _proofOfAddressValidationError,
              'account_type': _accountTypeValidationError,
              'bank_name': _bankNameValidationError,
              'account_name': _accountNameValidationError,
              'account_number': _accountNumberValidationError,
              'bank_code': _bankCodeValidationError,
              'building_society_roll_number':
                  _buildingSocietyRollNumberValidationError,
              'recipient_address1': _recipientAddress1ValidationError,
              'recipient_address2': _recipientAddress2ValidationError,
              'recipient_address3': _recipientAddress3ValidationError,
              'iban': _ibanValidationError,
              'bic_swift': _bicSwiftValidationError,
              'payment_iso_country_code': _paymentIsoCountryCodeValidationError,
              'credit_iso_currency_code': _creditIsoCurrencyCodeValidationError,

              /// NEw Fields
              'is_uk_citizen': _citizenOfUkError,
              'is_authorized_to_work_in_uk': _authorizedToWorkInUKError,
              'has_unspent_criminal_convictions':
                  _anyUnspentCriminalConvictionsError,
              'marital_status': _materialStatusError,
              'unspent_criminal_convictions_details': _pleaseSpecifyError,

              'uk_driving_experience': _ukDrivingExperienceError,
              'valid_uk_driving_license': _validUKDrivingExperienceError,
              'penalty_points': _panaltyPointsError,
              'noTachoCard': _tachoValidHolderError,
              'noCpcCard': _cpcValidHolderError,
              // 'driving_license_number': _drivingLicenseNumberError,
              // 'driving_license_category': _drivingLicenseCategoryError,
              'driving_license_check_code': _checkCodeDrivingLicenseError,
              'driving_license_issue_date': _dateofIssueDrivingLicenseError,
              'physical_incapabilities': _anyPhysicalIncapabilitiesError,
              'ongoing_medical_conditions': _anyOngoingMedicalConditionError,
              'taking_medication': _currentlyTakingAnyMedicationError,
              'drug_or_alcohol_issues': _drugsOrAlcoholError,
              'wears_glasses': _currentlyWearGlassesError,
              'dismissed_for_medical_reasons': _dismissedForMedicalReasonError,
              'dismissed_from_driving_roles': _previousDrivingRolesLast3yearsError,
              'medical_condition_details': _detailsOfMedicationError,
              'medication_details': _dismissalDueToMedicalReasonError,
              'dismissal_reason': _reasonForDismissalMedicalReasonError,
              'driving_dismissal_details': _dismissalFromDrivingRolesError,
              'last_eye_test': _lastEyeError
            };
            isLoading = false;
          });

          final Map<String, double> fieldScrollPositions = {
            'first_name': 0.0,
            'last_name': 100.0,
            'email': 200.0,
            'password': 300.0,
            'confirm_password': 400.0,
            'addressLine1': 500.0,
            'addressLine2': 600.0,
            'townOrCity': 700.0,
            'postCode': 800.0,
            'dob': 900.0,
            'ni_number': 1000.0,
            'phone': 1100.0,
            'image': 1200.0,
            'marital_status': 1300.0,
            'is_uk_citizen': 1400.0,
            'has_unspent_criminal_convictions': 1500.0,
            'unspent_criminal_convictions_details': 1600.0,
            'is_authorized_to_work_in_uk': 1700.0,
            'gender': 1800.0,
            'role': 1800.0,
            if (_selectStaffRole != null &&
                _selectStaffRole!.toLowerCase().contains('driver'))
              'licenceNumber': 1900.0,
            'licenceExpiry': 2000.0,
            'licenceTypes': 2100.0,
            'cpcNumber': 2200.0,
            'cpcExpiry': 2300.0,
            'tachoNumber': 2400.0,
            'tachoExpiry': 2500.0,
            'drivingLicence': 2600.0,
            'cpc': 2700.0,
            'tacho': 2800.0,
            'uk_driving_experience': 2900.0,
            'valid_uk_driving_license': 3000.0,
            'penalty_points': 3100.0,
            'driving_license_issue_date': 3300.0,
            'driving_license_check_code': 3500.0,
            'right_to_work': 3600.0,
            'pension_scheme': 3700.0,
            'dbs_edbs': 3800.0,
            'dbsExpiry': 3900.0,
            'passportNumber': 4000.0,
            'passport': 4100.0,
            'proofOfAddress': 4200.0,
            'physical_incapabilities': 4300.0,
            'ongoing_medical_conditions': 4400.0,
            'medical_condition_details': 4500.0,
            'taking_medication': 4600.0,
            'medication_details': 4700.0,
            'drug_or_alcohol_issues': 4800.0,
            'wears_glasses': 4900.0,
            'last_eye_test': 5000.0,
            'dismissed_for_medical_reasons': 5100.0,
            'dismissal_reason': 5200.0,
            'dismissed_from_driving_roles': 5300.0,
            'driving_dismissal_details': 5400.0,
          };

          // Retrieve the first invalid field
          final firstInvalidField = fieldScrollPositions.entries.firstWhere(
            (entry) =>
                entry.value != null &&
                (_validationErrors[entry.key]?.isNotEmpty ?? false),
            orElse: () =>
                MapEntry<String, double>('default', 0.0), // Fallback entry
          );

          if (firstInvalidField.key != 'default') {
            double scrollPosition = firstInvalidField.value;

            // Perform scroll animation
            _scrollController.animateTo(
              scrollPosition,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else {
            print("No invalid fields found.");
          }

          print("--1---");
          print(responseData);
          Utils.flushBarErrorMessage(
              'Please fill all the required field', context);
        } else {
          print("--2---");
          Utils.flushBarErrorMessage(
              'Please fill all the required field', context);
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print("--3--");
        print(responseString);
        Utils.flushBarErrorMessage(
            'Please fill all the required field', context);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("--4--");
      print('Error during data submission: $e');
      Utils.flushBarErrorMessage('An error occurred during SignUp', context);
      setState(() {
        isLoading = false;
      });
    }
  }

  void _updateValidationErrorState(){
    _firstValidationError = '';
    _lastValidationError = '';
    _emailValidationError = '';
    _passwordValidationError = '';
    _confirmPassValidationError = '';
    _addressLine1ValidationError = '';
    _addressLine2ValidationError = '';
    _townOrCityValidationError = '';
    _postCodeValidationError = '';
    _dobValidationError = '';
    _dbsValidationError = '';
    _niValidationError = '';
    _phoneValidationError = '';
    _workerImageValidationError = '';
    _licExpiryValidationError = '';
    _licenceEndorValidationError = '';
    _licenseTypeValidationError = '';
    _licNumValidationError = '';
    _cpcNumberValidationError = '';
    _cpcExpiryValidationError = '';
    _tachNumberValidationError = '';
    _tachoExpiryValidationError = '';
    _medicalValidationError = '';
    _drivingLicenceValidationError = '';
    _passportValidationError = '';
    _passportNumberValidationError = '';
    _upCPCValidationError = '';
    _upTachoValidationError = '';
    _genderValidationError = '';
    _roleValidationError = '';
    _proofOfAddressValidationError = '';
    _accountTypeValidationError = '';
    _bankNameValidationError = '';
    _accountNameValidationError = '';
    _accountNumberValidationError = '';
    _bankCodeValidationError = '';
    _buildingSocietyRollNumberValidationError = '';
    _recipientAddress1ValidationError = '';
    _recipientAddress2ValidationError = '';
    _recipientAddress3ValidationError = '';
    _ibanValidationError = '';
    _bicSwiftValidationError = '';
    _paymentIsoCountryCodeValidationError = '';
    _creditIsoCurrencyCodeValidationError = '';
    _citizenOfUkError = '';
    _authorizedToWorkInUKError = '';
    _anyUnspentCriminalConvictionsError = '';
    _materialStatusError = '';
    _pleaseSpecifyError = '';
    _ukDrivingExperienceError = '';
    _validUKDrivingExperienceError = '';
    _panaltyPointsError = '';
    _tachoValidHolderError = '';
    _cpcValidHolderError = '';
    _checkCodeDrivingLicenseError = '';
    _dateofIssueDrivingLicenseError = '';
    _anyPhysicalIncapabilitiesError = '';
    _anyOngoingMedicalConditionError = '';
    _currentlyTakingAnyMedicationError = '';
    _drugsOrAlcoholError = '';
    _currentlyWearGlassesError = '';
    _dismissedForMedicalReasonError = '';
    _previousDrivingRolesLast3yearsError = '';
    _detailsOfMedicationError = '';
    _dismissalDueToMedicalReasonError = '';
    _reasonForDismissalMedicalReasonError = '';
    _dismissalFromDrivingRolesError = '';
    _lastEyeError = '';
    _validationErrors.clear();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.dispose();

    _FirstnameController.dispose();
    _LastnameController.dispose();
    _emailController.dispose();
    _obsecurePassword.dispose();
    _passwordController.dispose();
    _reobsecurePassword.dispose();
    _reEnterpasswordController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _townCityController.dispose();
    _postCodeController.dispose();
    _dobController.dispose();
    _regnumberController.dispose();
    _phoneNumberController.dispose();
    _licNumController.dispose();
    _licExpiryController.dispose();
    _anyPointController.dispose();
    _cpcNumController.dispose();
    _cpcExpiryController.dispose();
    _tachoExpiryController.dispose();
    _dbsExpiryController.dispose();
    _techoDropFileController.dispose();
    _techoNumberFileController.dispose();
    _tachoExpiryController.dispose();
    _medicalController.dispose();
    _passportNumberController.dispose();
    consultantController.dispose();

    /// New Fields Controller
    _drivingLicenseNumberController.dispose();
    _drivingLicenseNumberController2.dispose();
    _drivingLicenseNumberController3.dispose();
    _drivingLicensecategoryController.dispose();
    _checkCodeDrivingLicenseController.dispose();
    _dateofIssueDrivingController.dispose();
    _detailMedicalConditionController.dispose();
    _detailOfMedicationController.dispose();
    _reasonForDismissalController.dispose();
    _reasondatesForDrivingRolesController.dispose();
    _lasteyeController.dispose();
    materialStatusController.dispose();

    pleaseSpecifyController.dispose();

    /// NEw Fields Focus nodes
    drivingLicenseFocus.dispose();
    drivingLicensecategoryFocus.dispose();
    checkCodeDrivingLicenseFocus.dispose();
    detailOfMedacationFocus.dispose();
    lastEyeFocus.dispose();
    reasonForDismissalFocus.dispose();
    reasondatesForDrivingRolesFocus.dispose();
    materialStatusFocus.dispose();
    citizenOfUkFocus.dispose();
    authorizedToWorkInUKFocus.dispose();
    anyUnspentCriminalConvictionsFocus.dispose();
    pleaseSpecifyFocus.dispose();

    firstnameFocusNode.dispose();
    lastnameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    reEnterpasswordFocusNode.dispose();
    address1FocusNode.dispose();
    address2FocusNode.dispose();
    townFocusNode.dispose();
    postFocusNode.dispose();
    dobFocusNode.dispose();
    regnumberFocusNode.dispose();
    phoneFocusNode.dispose();
    licNumFocusNode.dispose();
    licExpiryFocusNode.dispose();
    anyPointFocusNode.dispose();
    cpcNumFocusNode.dispose();
    cpcExpiryFocusNode.dispose();
    techoDropFocusNode.dispose();
    techoNumFocusNode.dispose();
    medicalFocusNode.dispose();
    consultantFocusNode.dispose();

    bankingFocus.dispose();
    acchountNameFocus.dispose();
    accnountNumber.dispose();
    bankCodeFocus.dispose();

    _bankNameController.dispose();
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _bankCodeController.dispose();
    _buildingSocietyRollNumberController.dispose();
    _Recipient1Controller.dispose();
    _Recipient2Controller.dispose();
    _Recipient3Controller.dispose();
    _IBAnController.dispose();
    _BIcController.dispose();
    _paymentCountryCodeController.dispose();
    _creditCurrencyController.dispose();
  }

  bool _isPassportUploaded = false;
  bool _isCPCUploaded = false;
  bool _isTachoUploaded = false;
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

  Color maleContainerColor = AppColors.navOpacity.withOpacity(0.2);
  Color femaleContainerColor = AppColors.navOpacity.withOpacity(0.2);
  Color othersContainerColor = AppColors.navOpacity.withOpacity(0.2);

  Widget body() {
    final authViewMode = Provider.of<AuthViewModel>(context);
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;

    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginView()));
        return true;
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginView()));
                      },
                      child: HeaderRow(Icons.arrow_back)),
                  Text(
                    "Candidate Registration",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  InVisibleHeaderRow(Icons.arrow_back),
                ],
              ),
              SizedBox(
                height: screenHeight * 0.013,
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Personal Information",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )),
              SizedBox(
                height: screenHeight * .013,
              ),
              Center(
                child: Container(
                  width: screenWidth * 0.95,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          offset: Offset(0, 3),
                          blurRadius: 5,
                          spreadRadius: 2,
                        ),
                      ]),
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * .013),
                      //First Name
                      CustomContainer(
                          titleText: 'First Name',
                          titleText2: "Enter your first name",
                          controller: _FirstnameController,
                          keyboardType: TextInputType.name,
                          focusNode: firstnameFocusNode,
                          focusCurrent: firstnameFocusNode,
                          focusNext: lastnameFocusNode,
                          errorMessage: _validationErrors['first_name'],
                          placeholder: "Enter Your First Name",
                          onChanged: (value) {
                            if (value.isEmpty) {
                              setState(() {
                                _validationErrors['first_name'] = 'First name is required and must be valid.';
                                print("Validation Error: ${_validationErrors['first_name']}");


                              });
                            } else {
                              setState(() {
                                _validationErrors['first_name'] = '';
                                print("Validation Cleared");
                              });
                            }
                          },
                          onFieldSubmitted: (value) {
                            if (_FirstnameController.text.isEmpty) {
                              setState(() {
                                _validationErrors['first_name'] =
                                    'First name is required and must be valid.';
                              });
                            } else {
                              setState(() {
                                _validationErrors['first_name'] = '';
                              });
                            }
                          }
                          ),

                      SizedBox(height: screenHeight * .013),
                      //Last Name
                      CustomContainer(
                          titleText: 'Last Name',
                          titleText2: "Enter your last name",
                          controller: _LastnameController,
                          keyboardType: TextInputType.name,
                          focusNode: lastnameFocusNode,
                          focusCurrent: lastnameFocusNode,
                          focusNext: emailFocusNode,
                          errorMessage: _validationErrors['last_name'],
                          placeholder: "Enter Your Last Name",
                          onChanged: (value) {
                            if (value.isEmpty) {
                              setState(() {
                                _validationErrors['last_name'] =
                                    'Last name is required and must be valid.';
                              });
                            } else {
                              setState(() {
                                _validationErrors['last_name'] = '';
                              });
                            }
                          },
                          onFieldSubmitted: (value) {
                            if (_LastnameController.text.isEmpty) {
                              setState(() {
                                _validationErrors['last_name'] =
                                    'Last name is required and must be valid.';
                              });
                            } else {
                              setState(() {
                                _validationErrors['last_name'] = '';
                              });
                            }
                          }),
                      SizedBox(height: screenHeight * .013),
                      //Email
                      CustomContainer(
                          titleText: 'Email Address',
                          titleText2: "Enter your email",
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          focusNode: emailFocusNode,
                          focusCurrent: emailFocusNode,
                          focusNext: passwordFocusNode,
                          errorMessage: _validationErrors['email'],
                          placeholder: "Enter Your Email  ",
                          onChanged: (value) {
                            if (value.isEmpty ||
                                !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                    .hasMatch(value)) {
                              setState(() {
                                _validationErrors['email'] =
                                    'A valid email is required.';
                              });
                            } else {
                              setState(() {
                                _validationErrors['email'] = '';
                              });
                            }
                          },
                          onFieldSubmitted: (value) {
                            if (_emailController.text.isEmpty ||
                                !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                    .hasMatch(value)) {
                              setState(() {
                                _validationErrors['email'] =
                                    'A valid email is required.';
                              });
                            } else {
                              setState(() {
                                _validationErrors['email'] = '';
                              });
                            }
                          }),

                      SizedBox(
                        height: screenHeight * .013,
                      ),

                      // Password
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, bottom: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Text("Password",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
                              Text(
                                " *",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red),
                              )
                            ],
                          ),
                        ),
                      ),
                      ValueListenableBuilder(
                        valueListenable: _obsecurePassword,
                        builder: (context, value, child) {
                          return Container(
                            // height: screenHeight * 0.065,
                            width: screenWidth * 0.90,
                            decoration: BoxDecoration(
                              color: AppColors.navOpacity.withOpacity(0.2),
                              border: Border.all(
                                color:
                                    AppColors.navButtonColor.withOpacity(0.4),
                                width: 0.4,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: _obsecurePassword.value,
                              focusNode: passwordFocusNode,
                              obscuringCharacter: "*",
                              decoration: InputDecoration(
                                hintText:
                                    "Enter Your Password", // Set the placeholder text here
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 10),
                                // hintText: 'Enter your Password',
                                suffixIcon: InkWell(
                                  onTap: () {
                                    _obsecurePassword.value =
                                        !_obsecurePassword.value;
                                  },
                                  child: Icon(
                                    _obsecurePassword.value
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility,
                                  ),
                                ),
                              ),
                              onFieldSubmitted: (value) {
                                Utils.fieldFocusChange(
                                    context,
                                    passwordFocusNode,
                                    reEnterpasswordFocusNode);

                                if (value.isEmpty || value.length < 8) {
                                  setState(() {
                                    _passwordValidationError =
                                        'Password is required and must be at least 8 characters.';
                                  });
                                } else {
                                  setState(() {
                                    _passwordValidationError = '';
                                  });
                                }
                              },
                              onChanged: (value) {
                                if (_passwordController.text.isEmpty ||
                                    _passwordController.text.length < 8) {
                                  setState(() {
                                    _passwordValidationError =
                                        'Password is required and must be at least 8 characters.';
                                  });
                                } else {
                                  setState(() {
                                    _passwordValidationError = '';
                                  });
                                }
                                _checkPasswordMatch();
                              },
                            ),
                          );
                        },
                      ),
                      SizedBox(height: screenHeight * .005),
                      if (_passwordValidationError != null &&
                          _passwordValidationError
                              .isNotEmpty) // Render error message only if not empty
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              _passwordValidationError,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),

                      SizedBox(height: screenHeight * .013),
                      // Re-Enter Password
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, bottom: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Text("Re-Enter Password",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
                              Text(
                                " *",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red),
                              )
                            ],
                          ),
                        ),
                      ),
                      ValueListenableBuilder(
                        valueListenable: _reobsecurePassword,
                        builder: (context, value, child) {
                          return Container(
                            width: screenWidth * 0.90,
                            decoration: BoxDecoration(
                              color: AppColors.navOpacity.withOpacity(0.2),
                              border: Border.all(
                                color:
                                    AppColors.navButtonColor.withOpacity(0.4),
                                width: 0.4,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: TextFormField(
                              controller: _reEnterpasswordController,
                              obscureText: _reobsecurePassword.value,
                              focusNode: reEnterpasswordFocusNode,
                              obscuringCharacter: "*",
                              decoration: InputDecoration(
                                hintText: "Re-Enter Your Password",
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 10),
                                // hintText: 'Re-enter your Password',
                                suffixIcon: InkWell(
                                  onTap: () {
                                    _reobsecurePassword.value =
                                        !_reobsecurePassword.value;
                                  },
                                  child: Icon(
                                    _reobsecurePassword.value
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility,
                                  ),
                                ),
                              ),
                              onFieldSubmitted: (value) {
                                Utils.fieldFocusChange(
                                    context,
                                    reEnterpasswordFocusNode,
                                    address1FocusNode);

                                if (value.isEmpty) {
                                  setState(() {
                                    _confirmPassValidationError =
                                        'Passwords must match.';
                                  });
                                } else if (value.length < 8) {
                                  _confirmPassValidationError =
                                      'Confirm Password Passwords must match.';
                                } else {
                                  setState(() {
                                    _confirmPassValidationError = '';
                                  });
                                }
                              },
                              onChanged: (value) {
                                if (_reEnterpasswordController.text.isEmpty) {
                                  setState(() {
                                    _confirmPassValidationError =
                                        'Passwords must match.';
                                  });
                                } else if (value.length < 8) {
                                  setState(() {
                                    _confirmPassValidationError =
                                        'Confirm Passwords must match.';
                                  });
                                } else {
                                  setState(() {
                                    _confirmPassValidationError = '';
                                  });
                                }

                                _checkPasswordMatch();
                              },
                            ),
                          );
                        },
                      ),
                      // SizedBox(height: screenHeight * .005),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (_confirmPassValidationError != null &&
                                  _confirmPassValidationError.isNotEmpty)
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: Text(
                                      _confirmPassValidationError,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                      maxLines:
                                          1, // Ensure single-line error message
                                      overflow: TextOverflow
                                          .ellipsis, // Handle longer text gracefully
                                    ),
                                  ),
                                )
                              else
                                Spacer(), // Placeholder to maintain alignment

                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: ValueListenableBuilder<bool>(
                                  valueListenable: _isPasswordMatching,
                                  builder: (context, value, child) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (_passwordController
                                                .text.isNotEmpty &&
                                            _reEnterpasswordController
                                                .text.isNotEmpty)
                                          Text(
                                            value
                                                ? "Password matched"
                                                : "Not matched",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: value
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                        SizedBox(
                                            height: screenHeight *
                                                .013), // Add spacing below
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * .013),

                      //Address
                      CustomContainer(
                          titleText: 'Address Line 1',
                          titleText2: "Enter your address",
                          controller: _address1Controller,
                          keyboardType: TextInputType.text,
                          focusNode: address1FocusNode,
                          focusCurrent: address1FocusNode,
                          focusNext: address2FocusNode,
                          errorMessage: _validationErrors['addressLine1'],
                          placeholder: "Enter Your Address Line 1",
                          onChanged: (value) {
                            if (value.isEmpty || value.length > 35) {
                              setState(() {
                                _validationErrors['addressLine1'] =
                                    'Address Line 1 is required and must be less than 35 characters.';
                              });
                            } else {
                              setState(() {
                                _validationErrors['addressLine1'] = '';
                              });
                            }
                          },
                          onFieldSubmitted: (value) {
                            if (_address1Controller.text.isEmpty ||
                                value.length > 35) {
                              setState(() {
                                _validationErrors['addressLine1'] =
                                    'Address Line 1 is required and must be less than 35 characters.';
                              });
                            } else {
                              setState(() {
                                _validationErrors['addressLine1'] = '';
                              });
                            }
                          }),
                      SizedBox(height: screenHeight * .013),
                      //Address
                      CustomContainer(
                          titleText: 'Address Line 2',
                          titleText2: "Enter your address",
                          controller: _address2Controller,
                          keyboardType: TextInputType.text,
                          focusNode: address2FocusNode,
                          focusCurrent: address2FocusNode,
                          focusNext: townFocusNode,
                          errorMessage: _validationErrors['addressLine2'],
                          placeholder: "Enter Your Address Line 2",
                          onChanged: (value) {
                            if (value.isEmpty || value.length > 35) {
                              setState(() {
                                _validationErrors['addressLine2'] =
                                    'Address Line 2 is required and must be less than 35 characters.';
                              });
                            } else {
                              setState(() {
                                _validationErrors['addressLine2'] = '';
                              });
                            }
                          },
                          onFieldSubmitted: (value) {
                            if (_address2Controller.text.isEmpty ||
                                value.length > 35) {
                              setState(() {
                                _validationErrors['addressLine2'] =
                                    'Address Line 2 is required and must be less than 35 characters.';
                              });
                            } else {
                              setState(() {
                                _validationErrors['addressLine2'] = '';
                              });
                            }
                          }),
                      SizedBox(height: screenHeight * .013),
                      //Town/City
                      CustomContainer(
                          titleText: 'Town / City',
                          titleText2: "Enter your address",
                          controller: _townCityController,
                          keyboardType: TextInputType.text,
                          focusNode: townFocusNode,
                          focusCurrent: townFocusNode,
                          focusNext: postFocusNode,
                          errorMessage: _validationErrors['townOrCity'],
                          placeholder: 'Enter Your Town or City'),
                      SizedBox(height: screenHeight * .013),
                      //PostCode
                      CustomContainer(
                          titleText: 'Post Code',
                          titleText2: "Enter your address",
                          controller: _postCodeController,
                          keyboardType: TextInputType.text,
                          focusNode: postFocusNode,
                          focusCurrent: postFocusNode,
                          focusNext: dobFocusNode,
                          errorMessage: _validationErrors['postCode'],
                          placeholder: "Enter Your Post Code",
                          onChanged: (value) {
                            if (value.isEmpty || value.length > 8) {
                              setState(() {
                                _validationErrors['postCode'] =
                                    'Post Code is required and must be less than 8 characters.';
                              });
                            } else {
                              setState(() {
                                _validationErrors['postCode'] = '';
                              });
                            }
                          },
                          onFieldSubmitted: (value) {
                            if (_postCodeController.text.isEmpty ||
                                value.length > 8) {
                              setState(() {
                                _validationErrors['postCode'] =
                                    'Post Code is required and must be less than 8 characters.';
                              });
                            } else {
                              setState(() {
                                _validationErrors['postCode'] = '';
                              });
                            }
                          }),

                      SizedBox(
                        height: screenHeight * .013,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, bottom: 10),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Text(
                                  'Date Of Birth',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  " *",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red),
                                )
                              ],
                            )),
                      ),
                      buildDateContainer(
                        labelText: '--:--:--',
                        controller: _dobController,
                        errorMessage: _validationErrors['dob'],
                      ),
                      SizedBox(height: screenHeight * .013),
                      CustomContainer(
                        titleText: 'National Insurance Number',
                        titleText2: "Enter your national insurance number",
                        controller: _regnumberController,
                        keyboardType: TextInputType.text,
                        focusNode: regnumberFocusNode,
                        focusCurrent: regnumberFocusNode,
                        focusNext: phoneFocusNode,
                        errorMessage: _validationErrors['ni_number'],
                        placeholder: "Enter Your National Insurance Number",
                        onChanged: (value) {
                          if (value.isEmpty) {
                            setState(() {
                              _validationErrors['ni_number'] =
                                  'National Insurance Number is required';
                            });
                          } else if (!RegExp(
                            r'^(?![DFIQUV]{2})(?![DFIQUV])[A-CEGHJ-NOPRSTW-Z]{2}\d{6}[A-D]$',
                          ).hasMatch(value)) {
                            setState(() {
                              _validationErrors['ni_number'] =
                                  'Invalid format. Example: AB123456C';
                            });
                          } else {
                            setState(() {
                              _validationErrors['ni_number'] = '';
                            });
                          }
                        },
                        onFieldSubmitted: (value) {
                          if (_postCodeController.text.isEmpty ||
                              !RegExp(
                                r'^(?![DFIQUV]{2})(?![DFIQUV])[A-CEGHJ-NOPRSTW-Z]{2}\d{6}[A-D]$',
                              ).hasMatch(value)) {
                            setState(() {
                              _validationErrors['ni_number'] =
                                  'Invalid format. Example: AB123456C';
                            });
                          } else {
                            setState(() {
                              _validationErrors['ni_number'] = '';
                            });
                          }
                        },
                      ),
                      SizedBox(height: screenHeight * .013),
                      //Mobile
                      CustomContainer(
                          titleText: 'Phone Number',
                          titleText2: "Enter your mobile number",
                          controller: _phoneNumberController,
                          keyboardType: TextInputType.phone,
                          focusNode: phoneFocusNode,
                          focusCurrent: phoneFocusNode,
                          focusNext: null,
                          errorMessage: _validationErrors['phone'],
                          placeholder: "Enter Your Phone Number",
                          onChanged: (value) {
                            if (value.isEmpty ||
                                !RegExp(r'^(?:\+44|0)7\d{9}$')
                                    .hasMatch(value)) {
                              setState(() {
                                _validationErrors['phone'] =
                                    'Phone number must be a valid UK phone.';
                              });
                            } else {
                              setState(() {
                                _validationErrors['phone'] = '';
                              });
                            }
                          },
                          onFieldSubmitted: (value) {
                            if (_phoneNumberController.text.isEmpty ||
                                !RegExp(r'^(?:\+44|0)7\d{9}$')
                                    .hasMatch(value)) {
                              setState(() {
                                _validationErrors['phone'] =
                                    'Phone number must be a valid UK phone.';
                              });
                            } else {
                              setState(() {
                                _validationErrors['phone'] = '';
                              });
                            }
                          }),
                      SizedBox(
                        height: screenHeight * .013,
                      ),

                      ImagePickerWidget(
                        title: "Worker Image",
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        onImagePicked:
                            (Uint8List? imageData, String? imageName) {
                          setState(() {
                            _selectedStaffImage = imageData;
                            _selectedStaffImageName = imageName;
                          });
                        },
                        selectedImageName: _selectedStaffImageName,
                        errorMessage: _validationErrors['image'],
                      ),
                      SizedBox(
                        height: screenHeight * .013,
                      ),

                      // Search or Consultant Name
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, bottom: 10),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Text(
                                  'Consultant Name: (Optional)',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            )),
                      ),
                      Container(
                        width: screenWidth * 0.90,
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
                                controller: consultantController,
                                focusNode: consultantFocusNode,
                                onChanged: (value) {
                                  filterConsultants(value);
                                  setState(() {
                                    _isExpanded = true;
                                  });
                                },
                                decoration: InputDecoration(
                                  prefixIcon:
                                      Icon(Icons.search, color: Colors.grey),
                                  border: InputBorder.none,
                                  hintText: "Search or Consultant Name",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 10.10),
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
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_isExpanded && filteredConsultants.isNotEmpty)
                              Container(
                                height: screenHeight * 0.15,
                                width: screenWidth * 0.90,
                                decoration: BoxDecoration(
                                  color: AppColors.navButtonColor
                                      .withOpacity(0.08),
                                  border: Border.all(
                                    color: AppColors.navButtonColor
                                        .withOpacity(0.4),
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
                                            filteredConsultants[index].name ??
                                                '',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          onTap: () {
                                            setState(() {
                                              consultantController.text =
                                                  filteredConsultants[index]
                                                          .name ??
                                                      '';
                                              filteredConsultants = [];
                                              _isExpanded = false;
                                            });
                                          },
                                        );
                                      }),
                                ),
                              ),
                          ]),

                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [

                            Padding(
                              padding:
                              const EdgeInsets.only(left: 10.0, bottom: 10),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Text(
                                      'Marital Status',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      " *",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: screenHeight * 0.065,
                              width: screenWidth * 0.90,
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.4),
                                  width: 0.4,
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  iconSize: 30.0,
                                  hint: Text(
                                    'Select Marital Status',
                                    style: TextStyle(fontSize: 14, color: Colors.grey),
                                  ),
                                  value: _maritalStatuses.isNotEmpty ? _maritalStatuses[0] : null,
                                  items:[
                                    DropdownMenuItem<String>(
                                      value: null, // Null for the default placeholder
                                      child: Text(
                                        'Select Marital Status',
                                        style: TextStyle(fontSize: 14, color: Colors.grey),
                                      ),
                                    ),
                                    ..._maritalStatusOptions.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      );
                                    }).toList(),
                                  ],

                                  onChanged: (String? newValue) {

                                    setState(() {
                                      if (newValue != null) {
                                        _maritalStatuses.clear(); // Clear previous selections
                                        _maritalStatuses.add(newValue);
                                      }
                                      print("Selected Marital Status: ${_maritalStatuses.isNotEmpty ? _maritalStatuses[0] : 'None'}");
                                    });
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              height: screenHeight * .009,
                            ),
                            Column(
                              children: [
                                DynamicDropdown(
                                  title: "Are you a citizen of the UK?",
                                  options: _dropdownOptions,
                                  selectedOption: _selected11 ?? 'Please Select',
                                  // selectedOption: _selected11!,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selected11 = newValue!;
                                      _formData['is_uk_citizen'] =
                                          newValue == 'Yes' ? 1 : 0;

                                    });
                                  },
                                 ),

                              ],
                            ),

                            SizedBox(
                              height: screenHeight * .009,
                            ),
                            DynamicDropdown(
                              title:
                                  "Do you have any unspent criminal convictions?",
                              options: _dropdownOptions,
                              selectedOption: _selected12!,
                              onChanged: (newValue) {
                                setState(() {
                                  _selected12 = newValue!;
                                  _formData[
                                          'has_unspent_criminal_convictions'] =
                                      newValue == 'Yes' ? 1 : 0;
                                });
                              },
                            ),
                            SizedBox(
                              height: screenHeight * .009,
                            ),
                            if (_selected12 == 'Yes')
                              CustomContainer2(
                                  titleText: 'If yes, please specify',
                                  titleText2: "",
                                  controller: pleaseSpecifyController,
                                  keyboardType: TextInputType.name,
                                  focusNode: pleaseSpecifyFocus,
                                  errorMessage: _validationErrors[
                                      'unspent_criminal_convictions_details'],
                                  placeholder:
                                      "Enter details of unspent criminal convictions"),
                            SizedBox(
                              height: screenHeight * .009,
                            ),
                            DynamicDropdown(
                              title: "Are you authorized to work in the UK?",
                              options: _dropdownOptions,
                              selectedOption: _selected13!,
                              onChanged: (newValue) {
                                setState(() {
                                  _selected13 = newValue!;
                                  _formData['is_authorized_to_work_in_uk'] =
                                      newValue == 'Yes' ? 1 : 0;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 10.0,
                          bottom: 10,
                        ),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Text(
                                  'Gender',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  " *",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red),
                                )
                              ],
                            )),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                SelectedGender = "male";
                                maleContainerColor =
                                    AppColors.blueColor.withOpacity(0.2);
                                femaleContainerColor =
                                    AppColors.navOpacity.withOpacity(0.2);
                                othersContainerColor =
                                    AppColors.navOpacity.withOpacity(0.2);
                              });
                            },
                            child: Container(
                              height: screenHeight * 0.065,
                              width: screenWidth * 0.30,
                              decoration: BoxDecoration(
                                color: maleContainerColor,
                                border: Border.all(
                                  color: maleContainerColor,
                                  width: 0.4,
                                ),
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    height: screenHeight * 0.04,
                                    width: screenWidth * 0.08,
                                    decoration: BoxDecoration(
                                        color: AppColors.navOpacity,
                                        border: Border.all(
                                          color: AppColors.blueColor,
                                          width: 0.4,
                                        ),
                                        shape: BoxShape.circle),
                                    child: Icon(Icons.male,
                                        color: Colors.blueAccent),
                                  ),
                                  SizedBox(),
                                  Center(
                                    child: Text(
                                      "Male",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                  SizedBox(),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                SelectedGender = "female";
                                femaleContainerColor =
                                    AppColors.blueColor.withOpacity(0.2);
                                maleContainerColor =
                                    AppColors.navOpacity.withOpacity(0.2);
                                othersContainerColor =
                                    AppColors.navOpacity.withOpacity(0.2);
                              });
                            },
                            child: Container(
                              height: screenHeight * 0.065,
                              width: screenWidth * 0.30,
                              decoration: BoxDecoration(
                                color: femaleContainerColor,
                                border: Border.all(
                                  color: femaleContainerColor,
                                  width: 0.4,
                                ),
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    height: screenHeight * 0.04,
                                    width: screenWidth * 0.08,
                                    decoration: BoxDecoration(
                                        color: AppColors.navOpacity,
                                        border: Border.all(
                                          color: AppColors.blueColor,
                                          width: 0.4,
                                        ),
                                        shape: BoxShape.circle),
                                    child: Icon(Icons.female_outlined,
                                        color: Colors.blueAccent),
                                  ),
                                  SizedBox(),
                                  Center(
                                    child: Text(
                                      "Female",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                  SizedBox(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (SelectedGender.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              _genderValidationError!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),

                      SizedBox(
                        height: screenHeight * .009,
                      ),

                      /// New Updated Staff Role
                      Column(
                        children: [
                          // SizedBox(height: screenHeight * .013),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 10.0, bottom: 10),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Text(
                                    'Worker Role',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    " *",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red),
                                  )
                                ],
                              ),
                            ),
                          ),

                          /// Display selected staff roles
                          Container(
                            height: screenHeight * 0.065,
                            width: screenWidth * 0.90,
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.4),
                                  width: 0.4),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                // iconEnabledColor: Colors.grey,
                                iconSize: 30.0,
                                hint: Text(
                                  _selectStaffRole ?? 'Select',
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.black),
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
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectStaffRole = newValue;
                                    _roleValidationError = null;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_roleValidationError != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              _roleValidationError!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      SizedBox(
                        height: screenHeight * .013,
                      ),
                    ],
                  ),
                ),
              ),

              /// New Updated Staff Role
              if (_selectStaffRole != null &&
                  _selectStaffRole!.toLowerCase().contains('driver')) ...[
                SizedBox(
                  height: screenHeight * .013,
                ),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Driving Information",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    )),
                SizedBox(
                  height: screenHeight * .013,
                ),
                Container(
                  width: screenWidth * 0.95,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          offset: Offset(0, 3),
                          blurRadius: 5,
                          spreadRadius: 2,
                        ),
                      ]),
                  child: Column(
                    children: [
                      /// New Fields for Driverss
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: [

                            DynamicDropdown(
                              title:
                              "Do you hold a valid UK driving licence?",
                              options: _dropdownOptions,
                              selectedOption: _selected1 ??
                                  'Please Select', // Provide a fallback
                              onChanged: (newValue) {
                                setState(() {
                                  _selected1 = newValue!;
                                  _formData['valid_uk_driving_license'] =
                                  newValue == 'Yes' ? 1 : 0;
                                  if (_selected1 != 'Yes') {
                                    _selected2 = null;
                                    _selected3 = null;
                                    _drivingLicenseNumberController.clear();
                                  }
                                });
                              },
                            ),

                            SizedBox(
                              height: screenHeight * .013,
                            ),
                            if (_selected1 == 'Yes') ...[

                              DynamicDropdown(
                                title: "Do you have UK driving experience?",
                                options: _dropdownOptions,
                                selectedOption: _selected2 ?? 'Please Select',
                                onChanged: (newValue) {
                                  setState(() {
                                    _selected2 = newValue!;
                                    _formData['uk_driving_experience'] =
                                    newValue == 'Yes' ? 1 : 0;
                                    if (_selected2 != 'Yes') {
                                      _selected3 = null;
                                      _drivingLicenseNumberController.clear();
                                    }
                                  });
                                },
                              ),

                              SizedBox(
                                height: screenHeight * .013,
                              ),
                            ],
                            if (_selected1 == 'Yes' && _selected2 == 'Yes') ...[

                              CustomContainer(
                                  titleText: 'Licence Number',
                                  titleText2: "Enter your licence number",
                                  controller: _licNumController,
                                  keyboardType: TextInputType.name,
                                  focusNode: licNumFocusNode,
                                  focusCurrent: licNumFocusNode,
                                  focusNext: licExpiryFocusNode,
                                  errorMessage:
                                  _validationErrors['licenceNumber'],
                                  placeholder: "Enter Your Licence Number",
                                onChanged: (value){
                                    setState(() {
                                      _isLicenceNumberFilled = value.isNotEmpty;
                                    });
                                }
                              ),

                              SizedBox(
                                height: screenHeight * .013,
                              ),

                              if(_isLicenceNumberFilled) ...[
                                DynamicDropdown(
                                  title:
                                  "Do you have penalty points on your licence?",
                                  options: _dropdownOptions,
                                  selectedOption:
                                  _selected3 ?? 'No', // Provide a fallback
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selected3 = newValue!;
                                      _formData['penalty_points'] =
                                      newValue == 'Yes' ? 1 : 0;
                                      if (_selected3 == null ||
                                          _selected3!.isEmpty) {
                                        _drivingLicenseNumberController.clear();
                                      }
                                    });
                                  },
                                ),
                                SizedBox(
                                  height: screenHeight * .013,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 2.0, bottom: 10),
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [
                                          Text(
                                            'Date of issue of the driving licence.',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            " *",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red),
                                          )
                                        ],
                                      )),
                                ),
                                buildDateContainer(
                                  labelText: '--:--:--',
                                  controller: _dateofIssueDrivingController,
                                  errorMessage: _validationErrors[
                                  'driving_license_issue_date'],
                                ),
                                SizedBox(
                                  height: screenHeight * .013,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0, bottom: 10),
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [
                                          Text(
                                            'Licence Expiry',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            " *",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red),
                                          )
                                        ],
                                      )),
                                ),
                                buildDateContainer(
                                  labelText: '--:--:--',
                                  controller: _licExpiryController,
                                  errorMessage:
                                  _validationErrors['licenceExpiry'],
                                ),
                                SizedBox(
                                  height: screenHeight * .013,
                                ),
                                CustomContainer2(
                                  titleText: 'Check code for driving licence.',
                                  titleText2: "",
                                  controller: _checkCodeDrivingLicenseController,
                                  keyboardType: TextInputType.name,
                                  focusNode: checkCodeDrivingLicenseFocus,
                                  errorMessage: _validationErrors[
                                  'driving_license_check_code'],
                                ),
                                SizedBox(height: screenHeight * .013),
                                FilePickerWidget(
                                  title: "Upload Driving Licence",
                                  screenWidth: screenWidth,
                                  screenHeight: screenHeight,
                                  onFilePicked:
                                      (Uint8List? fileData, String? fileName) {
                                    setState(() {
                                      _selectedStaffFile = fileData;
                                      _selectedStaffFileName = fileName;
                                    });
                                  },
                                  selectedFileName: _selectedStaffFileName,
                                  errorMessage:
                                  _validationErrors['drivingLicence'],
                                ),
                                SizedBox(height: screenHeight * .013),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0, bottom: 10),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Text(
                                          'Licence Type ',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          '(choose one or multiple types)',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          " *",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: screenHeight * 0.065,
                                      width: screenWidth * 0.90,
                                      decoration: BoxDecoration(
                                        color:
                                        AppColors.navOpacity.withOpacity(0.2),
                                        border: Border.all(
                                          color: AppColors.navButtonColor
                                              .withOpacity(0.4),
                                          width: 0.4,
                                        ),
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            height: screenHeight * 0.065,
                                            width: screenWidth * 0.30,
                                            decoration: BoxDecoration(
                                              color: AppColors.navOpacity,
                                              border: Border.all(
                                                color: AppColors.navOpacity,
                                                width: 0.4,
                                              ),
                                              borderRadius:
                                              BorderRadius.circular(8.0),
                                            ),
                                            child: Center(
                                              child: Text(
                                                "Choose types",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: AppColors.blackColor),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              height: screenHeight * 0.065,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10.0),
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton<String>(
                                                  isExpanded: true,
                                                  iconEnabledColor:
                                                  AppColors.navButtonColor,
                                                  iconSize: 30.0,
                                                  hint: Text(
                                                      'Select Licence Type ',
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: AppColors
                                                              .navButtonColor)),
                                                  items: _licenseTypes
                                                      .map((String value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Text(value,
                                                          style: TextStyle(
                                                              fontSize: 14)),
                                                    );
                                                  }).toList(),
                                                  onChanged: (String? newValue) {
                                                    if (newValue != null &&
                                                        !_selectedLicenseTypes
                                                            .contains(newValue)) {
                                                      setState(() {
                                                        _selectedLicenseTypes
                                                            .add(newValue);
                                                      });
                                                    }
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
                                      children: _selectedLicenseTypes.map((type) {
                                        return Chip(
                                          label: Text(type,
                                              style:
                                              TextStyle(color: Colors.black)),
                                          backgroundColor: AppColors.navOpacity
                                              .withOpacity(0.5),
                                          deleteIcon: Icon(
                                            Icons.cancel,
                                            color: AppColors.navButtonColor,
                                            size: 20,
                                          ),
                                          onDeleted: () {
                                            setState(() {
                                              _selectedLicenseTypes.remove(type);
                                            });
                                          },
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              color: AppColors.navOpacity,
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                            BorderRadius.circular(5),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    if (_licenseTypeValidationError.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0, vertical: 5.0),
                                        child: Text(
                                          _licenseTypeValidationError,
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(
                                  height: screenHeight * .013,
                                ),
                                CustomContainerWithoutStartMark(
                                    titleText:
                                    'Any points/endorsements on your licence?',
                                    titleText2: "Enter your licence number",
                                    controller: _anyPointController,
                                    keyboardType: TextInputType.name,
                                    focusNode: anyPointFocusNode,
                                    focusCurrent: anyPointFocusNode,
                                    focusNext: null,
                                    errorMessage:
                                    _validationErrors['licenceEndorsements'],
                                    placeholder:
                                    "Enter Your Licence Points/Endorsements"),
                                SizedBox(
                                  height: screenHeight * .013,
                                ),
                              ],

                            ],

                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Text(
                                    "CPC CARD",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    " *",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red),
                                  )
                                ],
                              ),
                            ),
                            // Row(
                            //   children: [
                            //     ValueListenableBuilder(
                            //       valueListenable: _isCPCCheckBoxSelected,
                            //       builder: (context, value, child) {
                            //         return Checkbox(
                            //           value: value,
                            //           onChanged: (newValue) {
                            //             // _isCPCCheckBoxSelected.value = newValue!;
                            //             setState(() {
                            //               _isCPCCheckBoxSelected.value =
                            //               newValue!;
                            //               if (newValue!) {
                            //                 _cpcNumController.text = '';
                            //                 _cpcExpiryController.text = '';
                            //               }
                            //             });
                            //           },
                            //         );
                            //       },
                            //     ),
                            //     Text("I don't have one"),
                            //   ],
                            // )
                          ],
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: [
                            DynamicDropdown(
                              title: "Are you a valid CPC holder?",
                              options: _dropdownOptions,
                              selectedOption: _selected14 ?? 'No',
                              onChanged: (newValue) {
                                setState(() {
                                  _selected14 = newValue!;
                                  _formData['noCpcCard'] =
                                      newValue == 'Yes' ? 1 : 0;
                                  if (_selected14 != 'Yes') {
                                    _drivingLicenseNumberController2.clear();
                                  }
                                });
                              },
                            ),
                            if (_selected14 == 'Yes') ...[
                              // CPC Number
                              ValueListenableBuilder(
                                valueListenable: _isCPCCheckBoxSelected,
                                builder: (context, value, child) {
                                  return Column(
                                    children: [
                                      CpcTestCustomContainer(
                                        titleText: 'CPC Number',
                                        titleText2: "Enter your CPC number",
                                        placeholder: "Enter Your CPC Number",
                                        controller: _cpcNumController,
                                        keyboardType: TextInputType.name,
                                        focusNode: cpcNumFocusNode,
                                        focusCurrent: cpcNumFocusNode,
                                        focusNext: cpcExpiryFocusNode,
                                        isEnabled: !value,
                                        fillColor: value
                                            ? Colors.grey[300]!
                                            : AppColors.navOpacity
                                                .withOpacity(0.2),
                                        onChanged: (value) {
                                          if (value.isEmpty ||
                                              value.length > 15) {
                                            setState(() {
                                              _cpcNumberValidationError =
                                                  'CPC number is required and must be less than 15 characters.';
                                            });
                                          } else {
                                            setState(() {
                                              _cpcNumberValidationError = '';
                                            });
                                          }
                                        },
                                        onFieldSubmitted: (value) {
                                          // if (_cpcNumController.text.isEmpty || value.length > 15) {
                                          if (value.isEmpty ||
                                              value.length > 15) {
                                            setState(() {
                                              _cpcNumberValidationError =
                                                  'CPC number is required and must be less than 15 characters.';
                                            });
                                          } else {
                                            setState(() {
                                              _cpcNumberValidationError = '';
                                            });
                                          }
                                        },
                                      ),
                                      if (!value &&
                                          _cpcNumberValidationError.isNotEmpty)
                                        Container(
                                            width: screenWidth * 0.90,
                                            child: Text(
                                              _cpcNumberValidationError,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red,
                                              ),
                                            )),
                                    ],
                                  );
                                },
                              ),
                              SizedBox(height: screenHeight * .013),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, bottom: 10),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      Text(
                                        'CPC Expiry',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        " *",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              ValueListenableBuilder(
                                valueListenable: _isCPCCheckBoxSelected,
                                builder: (context, value, child) {
                                  return Column(
                                    children: [
                                      CpcTestbuildDateContainer(
                                        '--:--:--',
                                        _cpcExpiryController,
                                        isEnabled: !value,
                                        fillColor: value
                                            ? Colors.grey[300]!
                                            : AppColors.navOpacity
                                                .withOpacity(0.2),
                                      ),
                                      if (!value &&
                                          _cpcExpiryValidationError.isNotEmpty)
                                        Container(
                                            width: screenWidth * 0.90,
                                            child: Text(
                                              _cpcExpiryValidationError,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red,
                                              ),
                                            )),
                                    ],
                                  );
                                },
                              ),
                              SizedBox(
                                height: screenHeight * .013,
                              ),
                              CheckFilePickerWidget(
                                  title: "Upload CPC",
                                  screenWidth: screenWidth,
                                  screenHeight: screenHeight,
                                  onFilePicked:
                                      (Uint8List? fileData, String? fileName) {
                                    setState(() {
                                      _selectedFile2 = fileData;
                                      _selectedFileName2 =
                                          fileName; // Update the selected file name
                                    });
                                  },
                                  checkselectedFileName: _selectedFileName2,
                                  onCheckboxChanged: (bool? value) {
                                    setState(() {
                                      _isCPCUploaded = value ?? false;
                                      if (_isCPCUploaded) {
                                        _selectedFile2 = null;
                                        _selectedFileName2 = null;
                                      }
                                    });
                                    print(
                                        'CPC checkbox is checked: $_isCPCUploaded');
                                    _updateCPCValidationError(null);
                                  },
                                  errorMessage: _validationErrors['cpc']),
                            ],
                          ],
                        ),
                      ),

                      SizedBox(height: screenHeight * .013),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "TACHO CARD",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                            // Row(
                            //   children: [
                            //     ValueListenableBuilder(
                            //       valueListenable: _isTachoCheckBoxSelected,
                            //       builder: (context, value, child) {
                            //         return Checkbox(
                            //           value: value,
                            //           onChanged: (newValue) {
                            //             _isTachoCheckBoxSelected.value =
                            //                 newValue!;
                            //           },
                            //         );
                            //       },
                            //     ),
                            //     Text("I don't have one"),
                            //   ],
                            // )
                          ],
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: [
                            DynamicDropdown(
                              title: "Are you a valid TACHO holder?",
                              options: _dropdownOptions,
                              selectedOption: _selected15 ?? 'No',
                              onChanged: (newValue) {
                                setState(() {
                                  _selected15 = newValue!;
                                  _formData['noCpcCard'] =
                                      newValue == 'Yes' ? 1 : 0;
                                  if (_selected15 != 'Yes') {
                                    _drivingLicenseNumberController3.clear();
                                  }
                                });
                              },
                            ),
                            if (_selected15 == 'Yes') ...[
                              ValueListenableBuilder(
                                valueListenable: _isTachoCheckBoxSelected,
                                builder: (context, value, child) {
                                  return Column(
                                    children: [
                                      CpcTestCustomContainer(
                                        titleText: 'Tacho Number',
                                        titleText2: "Enter your Tacho number",
                                        placeholder: "Enter Tacho Number",
                                        controller: _techoNumberFileController,
                                        keyboardType: TextInputType.name,
                                        focusNode: techoNumFocusNode,
                                        focusCurrent: techoNumFocusNode,
                                        focusNext: null,
                                        isEnabled: !value,
                                        fillColor: value
                                            ? Colors.grey[300]!
                                            : AppColors.navOpacity
                                                .withOpacity(0.2),
                                        onChanged: (value) {
                                          if (value.isEmpty ||
                                              value.length != 16) {
                                            setState(() {
                                              _tachNumberValidationError =
                                                  'Tacho number is required and must be 16 characters.';
                                            });
                                          } else {
                                            setState(() {
                                              _tachNumberValidationError = '';
                                            });
                                          }
                                        },
                                        onFieldSubmitted: (value) {
                                          if (value.isEmpty ||
                                              value.length != 16) {
                                            setState(() {
                                              _tachNumberValidationError =
                                                  'Tacho number is required and must be 16 characters.';
                                            });
                                          } else {
                                            setState(() {
                                              _tachNumberValidationError = '';
                                            });
                                          }
                                        },
                                      ),
                                      if (!value &&
                                          _tachNumberValidationError.isNotEmpty)
                                        Container(
                                            width: screenWidth * 0.90,
                                            child: Text(
                                              _tachNumberValidationError,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red,
                                              ),
                                            )),
                                    ],
                                  );
                                },
                              ),

                              SizedBox(height: screenHeight * .013),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, bottom: 10),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      Text(
                                        'Tacho Expiry',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        " *",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red),
                                      )
                                    ],
                                  ),
                                ),
                              ),

                              ///  Tacho expiry Date
                              ValueListenableBuilder(
                                valueListenable: _isTachoCheckBoxSelected,
                                builder: (context, value, child) {
                                  return Column(
                                    children: [
                                      CpcTestbuildDateContainer(
                                        '--:--:--',
                                        _tachoExpiryController,
                                        isEnabled: !value,
                                        fillColor: value
                                            ? Colors.grey[300]!
                                            : AppColors.navOpacity
                                                .withOpacity(0.2),
                                      ),
                                      if (!value &&
                                          _tachoExpiryValidationError
                                              .isNotEmpty)
                                        Container(
                                            width: screenWidth * 0.90,
                                            child: Text(
                                              _tachoExpiryValidationError,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red,
                                              ),
                                            )),
                                    ],
                                  );
                                },
                              ),

                              SizedBox(height: screenHeight * .013),
                              CheckFilePickerWidget(
                                  title: "Upload Tacho ",
                                  screenWidth: screenWidth,
                                  screenHeight: screenHeight,
                                  onFilePicked:
                                      (Uint8List? fileData, String? fileName) {
                                    setState(() {
                                      _selectedFile3 = fileData;
                                      _selectedFileName3 =
                                          fileName; // Update the selected file name
                                    });
                                  },
                                  checkselectedFileName: _selectedFileName3,
                                  onCheckboxChanged: (bool? value) {
                                    setState(() {
                                      _isTachoUploaded = value ?? false;
                                      if (_isTachoUploaded) {
                                        _selectedFile3 = null;
                                        _selectedFileName3 = null;
                                      }
                                    });
                                    print(
                                        'UploadTacho checkbox is checked: $_isTachoUploaded');
                                    _updateTachoValidationError(null);
                                  },
                                  errorMessage: _validationErrors['tacho']),

                              SizedBox(
                                height: screenHeight * .013,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(
                height: screenHeight * .013,
              ),
              Container(
                width: screenWidth * 0.95,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      offset: Offset(0, 3),
                      blurRadius: 5,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Questions",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                      ),
                      DynamicDropdown(
                        title: "Do you have a Right to Work in the UK?",
                        options: _dropdownOptions,
                        selectedOption: _selectedOption1 ?? 'Please Select',
                        onChanged: (newValue) {
                          setState(() {
                            _selectedOption1 = newValue!;
                            _formData['right_to_work'] =
                                newValue == 'Yes' ? 1 : 0;
                          });
                        },
                      ),
                      SizedBox(height: screenHeight * .013),
                      DynamicDropdown(
                        title: "Do you want to opt out of the Pension Scheme?",
                        options: _dropdownOptions,
                        selectedOption: _selectedOption3 ?? 'Please Select',
                        onChanged: (newValue) {
                          setState(() {
                            _selectedOption3 = newValue!;
                            _formData['pension_scheme'] =
                                newValue == 'Yes' ? 1 : 0;
                          });
                        },
                      ),
                      SizedBox(height: screenHeight * .013),
                      DynamicDropdown(
                        title:
                            "Do you have a DBS or EDBS (if applicable for your role)?",
                        options: _dropdownOptions,
                        selectedOption: _selectedOption2 ?? 'Please Select',
                        onChanged: (newValue) {
                          setState(() {
                            _selectedOption2 = newValue!;
                            _formData['dbs_edbs'] = newValue == 'Yes' ? 1 : 0;
                          });
                        },
                      ),
                      SizedBox(height: screenHeight * .013),

                      /// DBS Expiry
                      if (_selectedOption2 == 'Yes') ...[
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 10.0, bottom: 10),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Text(
                                    'DBS Expiry',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    " *",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red),
                                  )
                                ],
                              )),
                        ),
                        buildDateContainer(
                          labelText: '--:--:--',
                          controller: _dbsExpiryController,
                          errorMessage: _validationErrors['dbsExpiry'],
                        ),
                      ],

                      SizedBox(height: screenHeight * .013),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Flexible(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black),
                                  children: [
                                    TextSpan(
                                      text:
                                          "Do you have any Medical Conditions that we should be aware of?",
                                    ),
                                  ],
                                ),
                                overflow: TextOverflow.visible,
                              ),
                            ),
                            Text(
                              ' *',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * .013),
                      Container(
                        width: screenWidth * 0.90,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.4),
                            width: 0.4,
                          ),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: TextFormField(
                          controller: _medicalController,
                          keyboardType: TextInputType.text,
                          focusNode: medicalFocusNode,
                          decoration: InputDecoration(
                            hintText: "Enter Any  Medical Conditions",
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 5),
                          ),
                        ),
                      ),
                      if (_medicalValidationError != null &&
                          _medicalValidationError
                              .isNotEmpty) // Render error message only if not empty
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            _medicalValidationError,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                height: screenHeight * .013,
              ),
              Container(
                width: screenWidth * 0.95,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        offset: Offset(0, 3),
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ]),
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Compliance Documents",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        )),
                  ),
                  CustomContainer(
                    titleText: 'Passport Number',
                    titleText2: "Enter your passport Number",
                    controller: _passportNumberController,
                    keyboardType: TextInputType.name,
                    // focusNode: passwordNumFocusNode,
                    // focusCurrent: passwordNumFocusNode,
                    // focusNext: passwordNumFocusNode,
                    errorMessage: _validationErrors['passportNumber'],
                    placeholder: "Enter Your Passport Number",
                    onChanged: (value) {
                      if (value.isEmpty) {
                        setState(() {
                          _validationErrors['passportNumber'] =
                              'Passport number is required';
                        });
                      } else if (!RegExp(r'^[A-Z0-9]{9}$').hasMatch(value)) {
                        setState(() {
                          _validationErrors['passportNumber'] =
                              'Invalid passport number. Must be 9 alphanumeric characters (e.g., 123456789 or ABC123456)';
                        });
                      } else {
                        setState(() {
                          _validationErrors['passportNumber'] = '';
                        });
                      }
                    },
                  ),
                  SizedBox(height: screenHeight * .013),

                   FilePickerWidget(
                    title: "Upload Passport",
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    onFilePicked: (Uint8List? fileData, String? fileName) {
                      setState(() {
                        _selectedFile1 = fileData;
                        _selectedFileName1 = fileName;
                      });
                    },
                    selectedFileName: _selectedFileName1,
                    errorMessage: _validationErrors['passport'],
                  ),




                  SizedBox(height: screenHeight * .013),
                  FilePickerWidget(
                    title: "Upload Proof of Address",
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    onFilePicked: (Uint8List? fileData, String? fileName) {
                      setState(() {
                        _selectedEmployeeFile = fileData;
                        _selectedEmployeeFileName = fileName;
                      });
                    },
                    selectedFileName: _selectedEmployeeFileName,
                    errorMessage: _validationErrors['proofOfAddress'],
                  ),
                  SizedBox(
                    height: screenHeight * .013,
                  ),
                ]),
              ),
              SizedBox(
                height: screenHeight * .023,
              ),

              /// Fitness to work
              Container(
                width: screenWidth * 0.95,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      offset: Offset(0, 3),
                      blurRadius: 5,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Fitness to Work",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                      ),
                      DynamicDropdown(
                        title: "Do you have any physical incapabilities?",
                        options: _dropdownOptions,
                        selectedOption: _selected4!,
                        onChanged: (newValue) {
                          setState(() {
                            _selected4 = newValue!;
                            _formData['physical_incapabilities'] =
                                newValue == 'Yes' ? 1 : 0;
                          });
                        },
                      ),
                      SizedBox(height: screenHeight * .013),
                      DynamicDropdown(
                        title: "Do you have any ongoing medical conditions?",
                        options: _dropdownOptions,
                        selectedOption: _selected5!,
                        onChanged: (newValue) {
                          setState(() {
                            _selected5 = newValue!;
                            _formData['ongoing_medical_conditions'] =
                                newValue == 'Yes' ? 1 : 0;
                          });
                        },
                      ),
                      SizedBox(height: screenHeight * .013),
                      if (_selected5 == 'Yes') ...[
                        CustomContainer2(
                          titleText: 'Details of medical conditions, if any.',
                          titleText2: "",
                          controller: _detailMedicalConditionController,
                          keyboardType: TextInputType.name,
                          // focusNode: recipientAddress1Focus,
                          errorMessage:
                              _validationErrors['medical_condition_details'],
                        ),
                      ],
                      SizedBox(height: screenHeight * .013),
                      DynamicDropdown(
                        title: "Are you currently taking any medication?",
                        options: _dropdownOptions,
                        selectedOption: _selected6!,
                        onChanged: (newValue) {
                          setState(() {
                            _selected6 = newValue!;
                            _formData['taking_medication'] =
                                newValue == 'Yes' ? 1 : 0;
                          });
                        },
                      ),
                      if (_selected6 == 'Yes') ...[
                        SizedBox(height: screenHeight * .013),
                        CustomContainer2(
                          titleText: 'Details of medication, if any.',
                          titleText2: "",
                          controller: _detailOfMedicationController,
                          keyboardType: TextInputType.name,
                          focusNode: detailOfMedacationFocus,
                          errorMessage: _validationErrors['medication_details'],
                        ),
                      ],
                      SizedBox(height: screenHeight * .013),
                      DynamicDropdown(
                        title:
                            "Do you have ongoing issues with drugs or alcohol?",
                        options: _dropdownOptions,
                        selectedOption: _selected7!,
                        onChanged: (newValue) {
                          setState(() {
                            _selected7 = newValue!;
                            _formData['drug_or_alcohol_issues'] =
                                newValue == 'Yes' ? 1 : 0;
                          });
                        },
                      ),
                      SizedBox(height: screenHeight * .013),
                      DynamicDropdown(
                        title: "Do you currently wear glasses?",
                        options: _dropdownOptions,
                        selectedOption: _selected8!,
                        onChanged: (newValue) {
                          setState(() {
                            _selected8 = newValue!;
                            _formData['wears_glasses'] =
                                newValue == 'Yes' ? 1 : 0;
                          });
                        },
                      ),
                      SizedBox(height: screenHeight * .013),
                      Padding(
                        padding: const EdgeInsets.only(left: 2.0, bottom: 10),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Text(
                                  'When was your last eye test?',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  " *",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red),
                                )
                              ],
                            )),
                      ),
                      buildDateContainer(
                        labelText: '--:--:--',
                        controller: _lasteyeController,
                        errorMessage: _validationErrors['last_eye_test'],
                      ),
                      SizedBox(height: screenHeight * .013),
                      DynamicDropdown(
                        title:
                            "Have you ever been dismissed for medical reasons?",
                        options: _dropdownOptions,
                        selectedOption: _selected9!,
                        onChanged: (newValue) {
                          setState(() {
                            _selected9 = newValue!;
                            _formData['dismissed_for_medical_reasons'] =
                                newValue == 'Yes' ? 1 : 0;
                          });
                        },
                      ),
                      if (_selected9 == 'Yes') ...[
                        SizedBox(height: screenHeight * .013),
                        CustomContainer2(
                          titleText:
                              'Reason for dismissal due to medical reasons.',
                          titleText2: "",
                          controller: _reasonForDismissalController,
                          keyboardType: TextInputType.name,
                          focusNode: reasonForDismissalFocus,
                          errorMessage: _validationErrors['dismissal_reason'],
                        ),
                      ],
                      SizedBox(height: screenHeight * .013),
                      DynamicDropdown(
                        title:
                            "Have you been dismissed from previous driving roles in the last 3 years?",
                        options: _dropdownOptions,
                        selectedOption: _selected10!,
                        onChanged: (newValue) {
                          setState(() {
                            _selected10 = newValue!;
                            _formData['dismissed_from_driving_roles'] =
                                newValue == 'Yes' ? 1 : 0;
                          });
                        },
                      ),
                      if (_selected10 == 'Yes') ...[
                        SizedBox(height: screenHeight * .013),
                        CustomContainer2(
                          titleText:
                              'Reasons/dates for dismissal from driving roles.',
                          titleText2: "",
                          controller: _reasondatesForDrivingRolesController,
                          keyboardType: TextInputType.name,
                          focusNode: reasondatesForDrivingRolesFocus,
                          errorMessage:
                              _validationErrors['driving_dismissal_details'],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              SizedBox(
                height: screenHeight * .023,
              ),

              /// Banking Information
              Container(
                width: screenWidth * 0.95,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        offset: Offset(0, 3),
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ]),
                child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Banking Information",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w500),
                            )),
                        Column(
                          children: [
                            SizedBox(height: screenHeight * .013),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 10.0, bottom: 10),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Text(
                                      'Account Type',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      " *",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red),
                                    )
                                  ],
                                ),
                              ),
                            ),

                            /// Display selected Account Type
                            Container(
                              height: screenHeight * 0.065,
                              width: screenWidth * 0.90,
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                    color: Colors.grey.withOpacity(0.4),
                                    width: 0.4),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  iconSize: 30.0,
                                  hint: Text('Select',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.navButtonColor)),

                                  value: _accountTypes.isNotEmpty
                                      ? _accountTypes[0]
                                      : null, // Ensure a value is selected

                                  items: _accountTypeLists.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value,
                                          style: TextStyle(fontSize: 14)),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _accountTypes[0] =
                                          newValue ?? 'Bank Account';
                                      _showBuildingSociety =
                                          newValue == 'Building Society';
                                      _showInternationalBankAccount =
                                          newValue ==
                                              'International Bank Account';

                                      print("Account Type----$_accountTypes");
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * .013),
                        CustomContainer(
                            titleText: 'Bank Name',
                            titleText2: "Enter your first name",
                            controller: _bankNameController,
                            keyboardType: TextInputType.name,
                            focusNode: bankingFocus,
                            focusCurrent: bankingFocus,
                            focusNext: acchountNameFocus,
                            errorMessage: _validationErrors['bank_name'],
                            placeholder: "Enter Bank Name",
                            onChanged: (value) {
                              if (value.isEmpty) {
                                setState(() {
                                  _validationErrors['bank_name'] =
                                      'Bank name is required for the selected account type.';
                                });
                              } else {
                                setState(() {
                                  _validationErrors['bank_name'] = '';
                                });
                              }
                            },
                            onFieldSubmitted: (value) {
                              if (_bankNameController.text.isEmpty) {
                                setState(() {
                                  _validationErrors['bank_name'] =
                                      'Bank name is required for the selected account type.';
                                });
                              } else {
                                setState(() {
                                  _validationErrors['bank_name'] = '';
                                });
                              }
                            }),
                        SizedBox(height: screenHeight * .013),
                        CustomContainer(
                            titleText: 'Account Name',
                            titleText2: "Enter your first name",
                            controller: _accountNameController,
                            keyboardType: TextInputType.name,
                            focusNode: acchountNameFocus,
                            focusCurrent: acchountNameFocus,
                            focusNext: accnountNumber,
                            errorMessage: _validationErrors['account_name'],
                            placeholder: "Enter Account Holder Name ",
                            onChanged: (value) {
                              if (value.isEmpty || value.length > 35) {
                                setState(() {
                                  _validationErrors['account_name'] =
                                      'Account name is required and must be less than 35 characters.';
                                });
                              } else {
                                setState(() {
                                  _validationErrors['account_name'] = '';
                                });
                              }
                            },
                            onFieldSubmitted: (value) {
                              if (_accountNameController.text.isEmpty ||
                                  value.length > 35) {
                                setState(() {
                                  _validationErrors['account_name'] =
                                      'Account name is required and must be less than 35 characters.';
                                });
                              } else {
                                setState(() {
                                  _validationErrors['account_name'] = '';
                                });
                              }
                            }),
                        if (!_showInternationalBankAccount) ...[
                          SizedBox(height: screenHeight * .013),
                          CustomContainer(
                              titleText: 'Account Number',
                              titleText2: "Enter your first name",
                              controller: _accountNumberController,
                              keyboardType: TextInputType.name,
                              focusNode: accnountNumber,
                              focusCurrent: accnountNumber,
                              focusNext: bankCodeFocus,
                              errorMessage: _validationErrors['account_number'],
                              placeholder: "Enter Account Number ",
                              onChanged: (value) {
                                if (value.isEmpty || value.length != 8) {
                                  setState(() {
                                    _validationErrors['account_number'] =
                                        'Account number must be 8 numeric digits.';
                                  });
                                } else {
                                  setState(() {
                                    _validationErrors['account_number'] = '';
                                  });
                                }
                              },
                              onFieldSubmitted: (value) {
                                if (_accountNumberController.text.isEmpty ||
                                    value.length != 8) {
                                  setState(() {
                                    _validationErrors['account_number'] =
                                        'Account number must be 8 numeric digits.';
                                  });
                                } else {
                                  setState(() {
                                    _validationErrors['account_number'] = '';
                                  });
                                }
                              }),
                          SizedBox(height: screenHeight * .013),
                          CustomContainer(
                              titleText: 'Bank Code',
                              titleText2: "Enter your first name",
                              controller: _bankCodeController,
                              keyboardType: TextInputType.name,
                              focusNode: bankCodeFocus,
                              focusCurrent: bankCodeFocus,
                              focusNext: buildSocietyFocus,
                              errorMessage: _validationErrors['bank_code'],
                              placeholder: "Enter Bank Code ",
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  setState(() {
                                    _validationErrors['bank_code'] =
                                        'Bank code is invalid.';
                                  });
                                } else {
                                  setState(() {
                                    _validationErrors['bank_code'] = '';
                                  });
                                }
                              },
                              onFieldSubmitted: (value) {
                                if (_bankCodeController.text.isEmpty) {
                                  setState(() {
                                    _validationErrors['bank_code'] =
                                        'Bank code is invalid.';
                                  });
                                } else {
                                  setState(() {
                                    _validationErrors['bank_code'] = '';
                                  });
                                }
                              }),
                        ],
                        SizedBox(height: screenHeight * .013),
                        if (_showBuildingSociety)
                          CustomContainer(
                            titleText: 'Building Society Roll Number',
                            titleText2: "Enter your first name",
                            controller: _buildingSocietyRollNumberController,
                            keyboardType: TextInputType.name,
                            focusNode: buildSocietyFocus,
                            focusCurrent: buildSocietyFocus,
                            focusNext: recipientAddress1Focus,
                            errorMessage: _validationErrors[
                                'building_society_roll_number'],
                            placeholder: "Enter Roll Number",
                          ),
                        _showInternationalBankAccount
                            ? Column(
                                children: [
                                  SizedBox(height: screenHeight * .013),
                                  CustomContainer(
                                    titleText: 'Recipient Address 1',
                                    titleText2: "Enter your first name",
                                    controller: _Recipient1Controller,
                                    keyboardType: TextInputType.name,
                                    focusNode: recipientAddress1Focus,
                                    focusCurrent: recipientAddress1Focus,
                                    focusNext: recipientAddress2Focus,
                                    errorMessage:
                                        _validationErrors['recipient_address1'],
                                    placeholder: "Enter Address Line 1",
                                  ),
                                  SizedBox(height: screenHeight * .013),
                                  CustomContainer(
                                    titleText: 'Recipient Address 2',
                                    titleText2: "Enter your first name",
                                    controller: _Recipient2Controller,
                                    keyboardType: TextInputType.name,
                                    focusNode: recipientAddress2Focus,
                                    focusCurrent: recipientAddress2Focus,
                                    focusNext: recipientAddress3Focus,
                                    errorMessage:
                                        _validationErrors['recipient_address2'],
                                    placeholder: "Enter Address Line 2",
                                  ),
                                  SizedBox(height: screenHeight * .013),
                                  CustomContainer(
                                    titleText: 'Recipient Address 3',
                                    titleText2: "Enter your first name",
                                    controller: _Recipient3Controller,
                                    keyboardType: TextInputType.name,
                                    focusNode: recipientAddress3Focus,
                                    focusCurrent: recipientAddress3Focus,
                                    focusNext: iBANFocus,
                                    errorMessage:
                                        _validationErrors['recipient_address3'],
                                    placeholder: "Enter Address Line 3",
                                  ),
                                  SizedBox(height: screenHeight * .013),
                                  CustomContainer(
                                      titleText: 'IBAN ',
                                      titleText2: "Enter your first name",
                                      controller: _IBAnController,
                                      keyboardType: TextInputType.name,
                                      focusNode: iBANFocus,
                                      focusCurrent: iBANFocus,
                                      focusNext: BICFocus,
                                      errorMessage: _validationErrors['iban'],
                                      placeholder: "Enter IBAN ",
                                      onChanged: (value) {
                                        if (value.isEmpty) {
                                          setState(() {
                                            _validationErrors['iban'] =
                                                'IBAN is required and must be valid.';
                                          });
                                        } else {
                                          setState(() {
                                            _validationErrors['iban'] = '';
                                          });
                                        }
                                      },
                                      onFieldSubmitted: (value) {
                                        if (_IBAnController.text.isEmpty) {
                                          setState(() {
                                            _validationErrors['iban'] =
                                                'IBAN is required and must be valid.';
                                          });
                                        } else {
                                          setState(() {
                                            _validationErrors['iban'] = '';
                                          });
                                        }
                                      }),
                                  SizedBox(height: screenHeight * .013),
                                  CustomContainer(
                                      titleText: 'BIC/Swift ',
                                      titleText2: "Enter your first name",
                                      controller: _BIcController,
                                      keyboardType: TextInputType.name,
                                      focusNode: BICFocus,
                                      focusCurrent: BICFocus,
                                      focusNext: paymentIosCountryFocus,
                                      errorMessage:
                                          _validationErrors['bic_swift'],
                                      placeholder: "Enter BIC/Swift ",
                                      onChanged: (value) {
                                        if (value.isEmpty) {
                                          setState(() {
                                            _validationErrors['bic_swift'] =
                                                'BIC/SWIFT code is required and must be valid.';
                                          });
                                        } else {
                                          setState(() {
                                            _validationErrors['bic_swift'] = '';
                                          });
                                        }
                                      },
                                      onFieldSubmitted: (value) {
                                        if (_BIcController.text.isEmpty) {
                                          setState(() {
                                            _validationErrors['bic_swift'] =
                                                'BIC/SWIFT code is required and must be valid.';
                                          });
                                        } else {
                                          setState(() {
                                            _validationErrors['bic_swift'] = '';
                                          });
                                        }
                                      }),
                                  SizedBox(height: screenHeight * .013),
                                  CustomContainer(
                                      titleText: 'Payment ISO Country Code',
                                      titleText2: "Enter your first name",
                                      controller: _paymentCountryCodeController,
                                      keyboardType: TextInputType.name,
                                      focusNode: paymentIosCountryFocus,
                                      focusCurrent: paymentIosCountryFocus,
                                      focusNext: creditIosCurrencyFocus,
                                      errorMessage: _validationErrors[
                                          'payment_iso_country_code'],
                                      placeholder: "Enter Country Code",
                                      onChanged: (value) {
                                        if (value.isEmpty ||
                                            value.length != 2) {
                                          setState(() {
                                            _validationErrors[
                                                    'payment_iso_country_code'] =
                                                'Country code is required and must be 2 letters.';
                                          });
                                        } else {
                                          setState(() {
                                            _validationErrors[
                                                'payment_iso_country_code'] = '';
                                          });
                                        }
                                      },
                                      onFieldSubmitted: (value) {
                                        if (_paymentCountryCodeController
                                                .text.isEmpty ||
                                            value.length != 2) {
                                          setState(() {
                                            _validationErrors[
                                                    'payment_iso_country_code'] =
                                                'Country code is required and must be 2 letters.';
                                          });
                                        } else {
                                          setState(() {
                                            _validationErrors[
                                                'payment_iso_country_code'] = '';
                                          });
                                        }
                                      }),
                                  SizedBox(height: screenHeight * .013),
                                  CustomContainer(
                                      titleText: 'Credit ISO Currency Code',
                                      titleText2: "Enter your first name",
                                      controller: _creditCurrencyController,
                                      keyboardType: TextInputType.name,
                                      focusNode: creditIosCurrencyFocus,
                                      focusCurrent: creditIosCurrencyFocus,
                                      errorMessage: _validationErrors[
                                          'credit_iso_currency_code'],
                                      placeholder: "Enter Currency Code",
                                      onChanged: (value) {
                                        if (value.isEmpty ||
                                            value.length != 3) {
                                          setState(() {
                                            _validationErrors[
                                                    'credit_iso_currency_code'] =
                                                'Currency code is required and must be 3 letters.';
                                          });
                                        } else {
                                          setState(() {
                                            _validationErrors[
                                                'credit_iso_currency_code'] = '';
                                          });
                                        }
                                      },
                                      onFieldSubmitted: (value) {
                                        if (_creditCurrencyController
                                                .text.isEmpty ||
                                            value.length != 3) {
                                          setState(() {
                                            _validationErrors[
                                                    'credit_iso_currency_code'] =
                                                'Currency code is required and must be 3 letters.';
                                          });
                                        } else {
                                          setState(() {
                                            _validationErrors[
                                                'credit_iso_currency_code'] = '';
                                          });
                                        }
                                      }),
                                  SizedBox(
                                    height: screenHeight * .013,
                                  ),
                                ],
                              )
                            : SizedBox.shrink(),
                      ],
                    )),
              ),

              SizedBox(
                height: screenHeight * .023,
              ),

              GestureDetector(
                onTap: () async {
                  await postData();
                  // _submitForm();
                },
                child: Container(
                  height: screenHeight * 0.045,
                  width: screenWidth * 0.4,
                  decoration: BoxDecoration(
                      color: AppColors.navButtonColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          offset: Offset(0, 2),
                          blurRadius: 5,
                          spreadRadius: 2,
                        ),
                      ]),
                  child: Center(
                    child: isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            )) // Show loading indicator if _isLoading is true
                        : Text(
                            "Register",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                  ),
                ),
              ),

              SizedBox(
                height: screenHeight * .02,
              ),
              InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, RoutesName.login);
                  },
                  child: Text(
                    "Already  have an account? Login",
                    style: TextStyle(color: Colors.blue),
                  )),
              SizedBox(
                height: screenHeight * .2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    return emailRegex.hasMatch(email);
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
      child: Icon(
        iconData,
        color: AppColors.navButtonColor,
      ),
    );
  }

  Widget InVisibleHeaderRow(IconData iconData) {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return Container(
      height: screenHeight * 0.055,
      width: screenWidth * 0.12,
      child: Icon(
        iconData,
        color: Colors.transparent,
      ),
    );
  }

  Widget CustomContainer2({
    required String titleText,
    required String titleText2,
    required TextEditingController controller,
    required TextInputType keyboardType,
    FocusNode? focusNode,
    FocusNode? focusCurrent,
    FocusNode? focusNext,
    String? errorMessage,
    String? placeholder,
    Function(String)? onChanged,
    Function(String)?
        onFieldSubmitted, // Callback for field submit (validation when moving to next)
  }) {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;

    return Column(
      children: [
        // For TitleText

        Align(
          alignment: Alignment.centerLeft,
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              children: [
                TextSpan(text: titleText),
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            overflow: TextOverflow.visible,
          ),
        ),
        SizedBox(height: screenHeight * 0.013),
        Container(
          width: screenWidth * 0.90,
          decoration: BoxDecoration(
            color: AppColors.navOpacity.withOpacity(0.2),
            border: Border.all(
              color: AppColors.navButtonColor.withOpacity(0.4),
              width: 0.4,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              focusNode: focusNode,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: placeholder,
                hintStyle: TextStyle(color: Colors.grey),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
              ),
              onChanged: onChanged,
              onFieldSubmitted: (value) {
                onFieldSubmitted?.call(value);
                // onFieldSubmitted(value);
                if (focusCurrent != null && focusNext != null) {
                  Utils.fieldFocusChange(context, focusCurrent, focusNext);
                }
              },
            ),
          ),
        ),
        if (errorMessage != null && errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                errorMessage,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget CustomContainer({
    required String titleText,
    required String titleText2,
    required TextEditingController controller,
    required TextInputType keyboardType,
    FocusNode? focusNode,
    FocusNode? focusCurrent,
    FocusNode? focusNext,
    String? errorMessage,
    String? placeholder, // New optional parameter for placeholder
    Function(String)? onChanged, // Callback to handle real-time validation
    Function(String)?
        onFieldSubmitted, // Callback for field submit (validation when moving to next)
  }) {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;

    return Column(
      children: [
        // For TitleText
        Padding(
          padding: const EdgeInsets.only(left: 10.0, bottom: 10),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text(
                    titleText,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    " *",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red),
                  )
                ],
              )),
        ),
        Container(
          width: screenWidth * 0.90,
          decoration: BoxDecoration(
            color: AppColors.navOpacity.withOpacity(0.2),
            border: Border.all(
              color: AppColors.navButtonColor.withOpacity(0.4),
              width: 0.4,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              focusNode: focusNode,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: placeholder,
                hintStyle: TextStyle(color: Colors.grey),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
              ),
              // onChanged: onChanged,
              onChanged: (value) {
                if (onChanged != null) {
                  onChanged(value);
                }
              },
              onFieldSubmitted: (value) {
                onFieldSubmitted?.call(value);
                // onFieldSubmitted(value);
                if (focusCurrent != null && focusNext != null) {
                  Utils.fieldFocusChange(context, focusCurrent, focusNext);
                }
              },
            ),
          ),
        ),
        if (errorMessage != null && errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                errorMessage,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget CustomContainerWithoutStartMark({
    required String titleText,
    required String titleText2,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required FocusNode focusNode,
    FocusNode? focusCurrent,
    FocusNode? focusNext,
    String? errorMessage,
    String? placeholder, // New optional parameter for placeholder
    Function(String)? onChanged, // Callback to handle real-time validation
    Function(String)?
        onFieldSubmitted, // Callback for field submit (validation when moving to next)
  }) {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;

    return Column(
      children: [
        // For TitleText
        Padding(
          padding: const EdgeInsets.only(left: 10.0, bottom: 10),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text(
                    titleText,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              )),
        ),
        Container(
          width: screenWidth * 0.90,
          decoration: BoxDecoration(
            color: AppColors.navOpacity.withOpacity(0.2),
            border: Border.all(
              color: AppColors.navButtonColor.withOpacity(0.4),
              width: 0.4,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              focusNode: focusNode,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: placeholder,
                hintStyle: TextStyle(color: Colors.grey),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
              ),
              onChanged: onChanged,
              onFieldSubmitted: (value) {
                onFieldSubmitted?.call(value);
                // onFieldSubmitted(value);
                if (focusCurrent != null && focusNext != null) {
                  Utils.fieldFocusChange(context, focusCurrent, focusNext);
                }
              },
            ),
          ),
        ),
        if (errorMessage != null && errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                errorMessage,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget buildDateContainer({
    required String labelText,
    required TextEditingController controller,
    String? errorMessage,
  }) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;

    return Column(
      children: [
        Container(
          // height: screenHeight * 0.06,
          width: screenWidth * 0.90,
          decoration: BoxDecoration(
            color: AppColors.navOpacity.withOpacity(0.2),
            border: Border.all(
              color: AppColors.navButtonColor.withOpacity(0.4),
              width: 0.4,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.datetime,
            readOnly: true,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
              hintText: labelText,
              hintStyle: TextStyle(
                color: AppColors.blackColor.withOpacity(0.5),
                fontSize: 15,
              ),
              prefixIcon: Icon(
                Icons.calendar_month_outlined,
                color: Colors.black,
              ),
              border: OutlineInputBorder(
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

                        onSurface: Colors.black, //TextColor in Calender

                        // onSurfaceVariant: Colors.white,

                        primary: AppColors.navColor, // circle color

                        brightness: Brightness.light, //Brightness

                        surface: Colors.white,
                      ),
                      datePickerTheme: const DatePickerThemeData(
                        headerBackgroundColor:
                            AppColors.navColor, //Header Background Color

                        backgroundColor: Colors.white, //Main Baground

                        headerForegroundColor: Colors.white, //Header Text Color
                        surfaceTintColor: Colors.white, //Main Background Needed
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors
                              .navButtonColor, //Cancel Ok  button text color
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedDate != null) {
                String formattedDate =
                    DateFormat('dd/MM/yyyy').format(pickedDate);
                setState(() {
                  controller.text = formattedDate;
                });
              }
              // if (pickedDate != null) {
              //   setState(() {
              //     controller.text = pickedDate.toString().substring(0, 10);
              //   });
              // }
            },
          ),
        ),
        if (errorMessage != null && errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                errorMessage,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Widget buildDateContainer3({
  //   required String labelText,
  //   required TextEditingController controller,
  //   String? errorMessage,
  // }) {
  //   final screenHeight = MediaQuery.of(context).size.height * 1;
  //   final screenWidth = MediaQuery.of(context).size.width * 1;
  //
  //   return Column(
  //     children: [
  //       Container(
  //         // height: screenHeight * 0.06,
  //         width: screenWidth * 0.90,
  //         decoration: BoxDecoration(
  //           color: AppColors.navOpacity.withOpacity(0.2),
  //           border: Border.all(
  //             color: AppColors.navButtonColor.withOpacity(0.4),
  //             width: 0.4,
  //           ),
  //           borderRadius: BorderRadius.circular(8.0),
  //         ),
  //         child: TextFormField(
  //           controller: controller,
  //           keyboardType: TextInputType.datetime,
  //           readOnly: true,
  //           decoration: InputDecoration(
  //             contentPadding: EdgeInsets.symmetric(horizontal: 12),
  //             hintText: labelText,
  //             hintStyle: TextStyle(
  //               color: AppColors.blackColor.withOpacity(0.5),
  //               fontSize: 15,
  //             ),
  //             prefixIcon: Icon(
  //               Icons.calendar_month_outlined,
  //               color: Colors.black,
  //             ),
  //             border: OutlineInputBorder(
  //               borderSide: BorderSide.none,
  //             ),
  //           ),
  //           onTap: () async {
  //             DateTime? pickedDate = await showDatePicker(
  //               initialEntryMode: DatePickerEntryMode.calendarOnly,
  //               context: context,
  //               initialDate: DateTime.now(),
  //               firstDate: DateTime(1950),
  //               lastDate: DateTime(2101),
  //               builder: (BuildContext context, Widget? child) {
  //                 return Theme(
  //                   data: Theme.of(context).copyWith(
  //                     colorScheme: const ColorScheme.light(
  //                       onPrimary: Colors.white,
  //                       onBackground: Colors.white,
  //
  //                       onSurface: Colors.black, //TextColor in Calender
  //
  //                       // onSurfaceVariant: Colors.white,
  //
  //                       primary: AppColors.navColor, // circle color
  //
  //                       brightness: Brightness.light, //Brightness
  //
  //                       surface: Colors.white,
  //                     ),
  //                     datePickerTheme: const DatePickerThemeData(
  //                       headerBackgroundColor:
  //                       AppColors.navColor, //Header Background Color
  //
  //                       backgroundColor: Colors.white, //Main Baground
  //
  //                       headerForegroundColor: Colors.white, //Header Text Color
  //                       surfaceTintColor: Colors.white, //Main Background Needed
  //                     ),
  //                     textButtonTheme: TextButtonThemeData(
  //                       style: TextButton.styleFrom(
  //                         foregroundColor: AppColors
  //                             .navButtonColor, //Cancel Ok  button text color
  //                       ),
  //                     ),
  //                   ),
  //                   child: child!,
  //                 );
  //               },
  //             );
  //             if (pickedDate != null) {
  //               String formattedDate =
  //               DateFormat('dd/MM/yyyy').format(pickedDate);
  //               setState(() {
  //                 controller.text = formattedDate;
  //               });
  //             }
  //             // if (pickedDate != null) {
  //             //   setState(() {
  //             //     controller.text = pickedDate.toString().substring(0, 10);
  //             //   });
  //             // }
  //           },
  //         ),
  //       ),
  //       if (errorMessage != null && errorMessage.isNotEmpty)
  //         Padding(
  //           padding: const EdgeInsets.only(left: 10.0),
  //           child: Align(
  //             alignment: Alignment.topLeft,
  //             child: Text(
  //               errorMessage,
  //               style: TextStyle(
  //                 fontSize: 12,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.red,
  //               ),
  //             ),
  //           ),
  //         ),
  //     ],
  //   );
  // }
  // Widget buildDateContainer2({
  //   required String labelText,
  //   required TextEditingController controller,
  //   String? errorMessage,
  // }) {
  //   final screenHeight = MediaQuery.of(context).size.height * 1;
  //   final screenWidth = MediaQuery.of(context).size.width * 1;
  //
  //   return Column(
  //     children: [
  //       Container(
  //         // height: screenHeight * 0.06,
  //         width: screenWidth * 0.90,
  //         decoration: BoxDecoration(
  //           color: AppColors.navOpacity.withOpacity(0.2),
  //           border: Border.all(
  //             color: AppColors.navButtonColor.withOpacity(0.4),
  //             width: 0.4,
  //           ),
  //           borderRadius: BorderRadius.circular(8.0),
  //         ),
  //         child: TextFormField(
  //           controller: controller,
  //           keyboardType: TextInputType.datetime,
  //           readOnly: true,
  //           decoration: InputDecoration(
  //             contentPadding: EdgeInsets.symmetric(horizontal: 12),
  //             hintText: labelText,
  //             hintStyle: TextStyle(
  //               color: AppColors.blackColor.withOpacity(0.5),
  //               fontSize: 15,
  //             ),
  //             prefixIcon: Icon(
  //               Icons.calendar_month_outlined,
  //               color: Colors.black,
  //             ),
  //             border: OutlineInputBorder(
  //               borderSide: BorderSide.none,
  //             ),
  //           ),
  //           onTap: () async {
  //             DateTime? pickedDate = await showDatePicker(
  //               initialEntryMode: DatePickerEntryMode.calendarOnly,
  //               context: context,
  //               initialDate: DateTime.now(),
  //               firstDate: DateTime(1950),
  //               lastDate: DateTime(2101),
  //               builder: (BuildContext context, Widget? child) {
  //                 return Theme(
  //                   data: Theme.of(context).copyWith(
  //                     colorScheme: const ColorScheme.light(
  //                       onPrimary: Colors.white,
  //                       onBackground: Colors.white,
  //
  //                       onSurface: Colors.black, //TextColor in Calender
  //
  //                       // onSurfaceVariant: Colors.white,
  //
  //                       primary: AppColors.navColor, // circle color
  //
  //                       brightness: Brightness.light, //Brightness
  //
  //                       surface: Colors.white,
  //                     ),
  //                     datePickerTheme: const DatePickerThemeData(
  //                       headerBackgroundColor:
  //                       AppColors.navColor, //Header Background Color
  //
  //                       backgroundColor: Colors.white, //Main Baground
  //
  //                       headerForegroundColor: Colors.white, //Header Text Color
  //                       surfaceTintColor: Colors.white, //Main Background Needed
  //                     ),
  //                     textButtonTheme: TextButtonThemeData(
  //                       style: TextButton.styleFrom(
  //                         foregroundColor: AppColors
  //                             .navButtonColor, //Cancel Ok  button text color
  //                       ),
  //                     ),
  //                   ),
  //                   child: child!,
  //                 );
  //               },
  //             );
  //             if (pickedDate != null) {
  //               String formattedDate =
  //               DateFormat('dd/MM/yyyy').format(pickedDate);
  //               setState(() {
  //                 controller.text = formattedDate;
  //               });
  //             }
  //             // if (pickedDate != null) {
  //             //   setState(() {
  //             //     controller.text = pickedDate.toString().substring(0, 10);
  //             //   });
  //             // }
  //           },
  //         ),
  //       ),
  //       if (errorMessage != null && errorMessage.isNotEmpty)
  //         Padding(
  //           padding: const EdgeInsets.only(left: 10.0),
  //           child: Align(
  //             alignment: Alignment.topLeft,
  //             child: Text(
  //               errorMessage,
  //               style: TextStyle(
  //                 fontSize: 12,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.red,
  //               ),
  //             ),
  //           ),
  //         ),
  //     ],
  //   );
  // }

  Widget CpcTestCustomContainer({
    required String titleText,
    required String titleText2,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required FocusNode focusNode,
    FocusNode? focusCurrent,
    FocusNode? focusNext,
    String? placeholder, // New optional parameter for placeholder

    required bool isEnabled,
    required Color fillColor,
    Function(String)? onChanged, // Optional callback for real-time validation
    Function(String)? onFieldSubmitted,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        SizedBox(height: screenHeight * .013),
        // For TitleText
        Padding(
          padding: const EdgeInsets.only(left: 10.0, bottom: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Text(
                  titleText,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  " *",
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                )
              ],
            ),
          ),
        ),
        Container(
          width: screenWidth * 0.90,
          decoration: BoxDecoration(
            color: fillColor,
            border: Border.all(
              color: AppColors.navButtonColor.withOpacity(0.4),
              width: 0.4,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              focusNode: focusNode,
              enabled: isEnabled,
              decoration: InputDecoration(
                hintText: placeholder, // Set the placeholder text here
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
              ),
              onChanged: onChanged,
              onFieldSubmitted: (value) {
                onFieldSubmitted?.call(value);

                if (focusCurrent != null && focusNext != null) {
                  Utils.fieldFocusChange(context, focusCurrent, focusNext);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget CpcTestbuildDateContainer(
    String labelText,
    TextEditingController controller, {
    required bool isEnabled,
    required Color fillColor,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: screenHeight * 0.06,
      width: screenWidth * 0.90,
      decoration: BoxDecoration(
        color: fillColor,
        border: Border.all(
          color: AppColors.navButtonColor.withOpacity(0.4),
          width: 0.4,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.datetime,
        readOnly: true,
        enabled: isEnabled,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12),
          hintText: labelText,
          hintStyle: TextStyle(
              color: AppColors.blackColor.withOpacity(0.5), fontSize: 15),
          prefixIcon: Icon(
            Icons.calendar_month_outlined,
            color: Colors.black,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
        ),
        onTap: isEnabled
            ? () async {
                DateTime? pickedDate = await showDatePicker(
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

                          onSurface: Colors.black, //TextColor in Calender

                          // onSurfaceVariant: Colors.white,

                          primary: AppColors.navColor, // circle color

                          brightness: Brightness.light, //Brightness

                          surface: Colors.white,
                        ),
                        datePickerTheme: const DatePickerThemeData(
                          headerBackgroundColor:
                              AppColors.navColor, //Header Background Color

                          backgroundColor: Colors.white, //Main Baground

                          headerForegroundColor:
                              Colors.white, //Header Text Color
                          surfaceTintColor:
                              Colors.white, //Main Background Needed
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors
                                .navButtonColor, //Cancel Ok  button text color
                          ),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                // if (pickedDate != null) {
                //   setState(() {
                //     controller.text = pickedDate.toString().substring(0, 10);
                //   });
                // }
                if (pickedDate != null) {
                  String formattedDate =
                      DateFormat('dd/MM/yyyy').format(pickedDate);
                  setState(() {
                    controller.text = formattedDate;
                  });
                }
              }
            : null,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              children: [
                TextSpan(text: title),
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            overflow: TextOverflow.visible,
          ),
        ),
        SizedBox(height: screenHeight * 0.013),
        Container(
          width: screenWidth * 0.90,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            border: Border.all(
              color: Colors.grey.withOpacity(0.4),
              width: 0.4,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: InputDecorator(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey.withOpacity(0.4),
                  width: 0.4,
                ),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isDense: true,
                isExpanded: true,
                menuMaxHeight: 350,
                // value: selectedOption.isNotEmpty ? selectedOption : null,
                value: options.contains(selectedOption) ? selectedOption : null,
                hint: Text(
                  'Please Select',
                  style: TextStyle(color: Colors.grey),
                ),
                onChanged: onChanged,
                // onChanged: (String? newValue) {
                //   onChanged(newValue);
                // },
                items: options.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ),

      ],
    );
  }

 }
