import 'package:c9_app/model/Registration/candidateStaffRole.dart';
import 'package:flutter/material.dart';
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

class FirstCandidateMultiStep extends StatefulWidget {
  const FirstCandidateMultiStep({Key? key}) : super(key: key);

  @override
  _FirstCandidateMultiStepState createState() => _FirstCandidateMultiStepState();
}

class _FirstCandidateMultiStepState extends State<FirstCandidateMultiStep> {
  bool isLoading = false;
  List<String> _selectedLicenseTypes = [];
  final List<String> _licenseTypes = ['Class B', 'Class C', 'Class D', 'Class D1', 'Class E'];

  String? _selectStaffRole;
  List<Data> _roleTypes = [];

  List<String> _accountTypes = ['Bank Account'];
  final List<String> _accountTypeLists = ['Bank Account', 'Building Society', 'International Bank Account'];
  bool _showBuildingSociety = false; // Initially inactive
  bool _showInternationalBankAccount = false; // Initially inactive

  final List<String> _dropdownOptions = ['Yes', 'No'];
  String? _selectedOption1 = 'No';
  String? _selectedOption2 = 'No';
  String? _selectedOption3 = 'No';
  Map<String, dynamic> _formData = {
    'right_to_work': 0,
    'dbs_edbs': 0,
    'pension_scheme': 0,
  };
  List<ConsultantNames> consultantNames = [];
  List<ConsultantNames> filteredConsultants = [];
  bool _isExpanded = false;

  String? _selectedLicenseType;
  bool permissionGranted = false;

  String? _selectedGender;

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
      String nameWithoutExtension = fileName.substring(0, fileName.lastIndexOf('.'));
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

  @override
  void initState() {
    super.initState();
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

  final ValueNotifier<bool> _isCPCCheckBoxSelected = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isTachoCheckBoxSelected = ValueNotifier<bool>(false);

  ValueNotifier<bool> _isPasswordMatching = ValueNotifier<bool>(true);
  void _checkPasswordMatch() {
    _isPasswordMatching.value = _passwordController.text == _reEnterpasswordController.text;
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
  TextEditingController _alterphoneNumberController = TextEditingController();
  TextEditingController _alterEmerContactNameController = TextEditingController();
  TextEditingController _alterEmerContactNumController = TextEditingController();

  TextEditingController consultantController = TextEditingController();

  ///Banking Controllers
  TextEditingController _bankNameController = TextEditingController();
  TextEditingController _accountNameController = TextEditingController();
  TextEditingController _accountNumberController = TextEditingController();
  TextEditingController _bankCodeController = TextEditingController();
  TextEditingController _buildingSocietyRollNumberController = TextEditingController();
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
  FocusNode alterphoneNumberFocusNode = FocusNode();
  FocusNode alterEmerContactNameFocusNode = FocusNode();
  FocusNode alterEmerContactNumFocusNode = FocusNode();

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

  // FocusNode descriptionFocusNode = FocusNode();
  //Questions 4 No

  String _passwordValidationError = '';
  String _confirmPassValidationError = '';
  String _licenseTypeValidationError = '';
  Map<String, String> _validationErrors = {};

  String _cpcNumberValidationError = '';
  String _cpcExpiryValidationError = '';
  String _tachNumberValidationError = '';
  String _medicalValidationError = '';
  String? _passportValidationError = '';
  String? _upCPCValidationError = '';
  String? _upTachoValidationError = '';
  String? _genderValidationError = '';


  Future<void> postData() async {
    setState(() {
      isLoading = true;
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
    String _alterphoneValidationError = '';
    String _alterEmerNameValidationError = '';
    String _alterEmerNumValidationError = '';
    String _addressLine1ValidationError = '';
    String _addressLine2ValidationError = '';
    String _townOrCityValidationError = '';
    String _postCodeValidationError = '';
    String _passportNumberValidationError = '';

    String _dobValidationError = '';
    String _niValidationError = '';
    String _licExpiryValidationError = '';
    String _licenceEndorValidationError = '';

    _licenseTypeValidationError = '';
    String _licNumValidationError = '';
    _cpcNumberValidationError = '';
    _cpcExpiryValidationError = '';
    _tachNumberValidationError = '';

    _passwordValidationError = '';
    _confirmPassValidationError = '';
    _medicalValidationError = '';

    _passportValidationError = '';
    _upCPCValidationError = '';
    _upTachoValidationError = '';
    _genderValidationError = '';
    String _drivingLicenceValidationError = '';
    String _proofOfAddressValidationError = '';

    if (_accountTypes.isEmpty || !accountTypeMap.values.contains(_accountTypes[0])) {
      _accountTypeValidationError = 'Account type is required.';
    }

    // Validate fields based on account type
    if (_accountTypes.contains('Bank Account') || _accountTypes.contains('Building Society')) {
      if (_bankNameController.text.isEmpty) {
        _bankNameValidationError = 'Bank name is required for Bank Account or Building Society.';
      }

      if (_accountNameController.text.isEmpty) {
        _accountNameValidationError = 'Account name is required for Bank Account or Building Society.';
      }

      if (_accountNumberController.text.isEmpty) {
        _accountNumberValidationError = 'Account number is required for Bank Account or Building Society.';
      } else if (_accountNumberController.text.length < 1 || _accountNumberController.text.length > 8) {
        _accountNumberValidationError = 'Account number must be between 1 and 8 digits.';
      }

      if (_bankCodeController.text.isEmpty) {
        _bankCodeValidationError = 'Bank code is required for Bank Account or Building Society.';
      } else if (!RegExp(r'^\d{6}$|^\d{2}-\d{2}-\d{2}$|^\d{2} \d{2} \d{2}$').hasMatch(_bankCodeController.text)) {
        _bankCodeValidationError = 'Bank code format must be 123456, 12-34-56, or 12 34 56.';
      }

      if (_accountTypes.contains('Building Society') && _buildingSocietyRollNumberController.text.isEmpty) {
        _buildingSocietyRollNumberValidationError = 'Building Society roll number is required for Building Society.';
      }

      // Validate International Bank Account fields
    } else if (_accountTypes.contains('International Bank Account')) {
      if (_Recipient1Controller.text.isEmpty) {
        _recipientAddress1ValidationError = 'Recipient address line 1 is required for International Bank Account.';
      }

      if (_Recipient2Controller.text.isEmpty) {
        _recipientAddress2ValidationError = 'Recipient address line 2 is required for International Bank Account.';
      }

      if (_Recipient3Controller.text.isEmpty) {
        _recipientAddress3ValidationError = 'Recipient address line 3 is required for International Bank Account.';
      }

      if (_IBAnController.text.isEmpty) {
        _ibanValidationError = 'IBAN is required for International Bank Account.';
      }

      if (_BIcController.text.isEmpty) {
        _bicSwiftValidationError = 'BIC/SWIFT code is required for International Bank Account.';
      } else if (_BIcController.text.length > 34) {
        _bicSwiftValidationError = 'BIC/SWIFT code cannot exceed 34 characters.';
      }

      if (_paymentCountryCodeController.text.isEmpty || _paymentCountryCodeController.text.length != 2) {
        _paymentIsoCountryCodeValidationError = 'A valid 2-letter ISO country code is required.';
      }

      if (_creditCurrencyController.text.isEmpty || _creditCurrencyController.text.length != 3) {
        _creditIsoCurrencyCodeValidationError = 'A valid 3-letter ISO currency code is required.';
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
        request.fields['dob'] = DateFormat('yyyy-MM-dd').format(DateFormat('dd-MM-yyyy').parse(_dobController.text));
      }

      if (_licExpiryController.text.isNotEmpty) {
        request.fields['licenceExpiry'] =
            DateFormat('yyyy-MM-dd').format(DateFormat('dd-MM-yyyy').parse(_licExpiryController.text));
      }

      // print('DOB: $formattedDOB');
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
      // request.fields['dob'] = formattedDob;
      // request.fields['licenceExpiry'] =formattedLicenceExpiry;
      // request.fields['dob'] = _dobController.text;
      // request.fields['licenceExpiry'] = _licExpiryController.text;
      request.fields['ni_number'] = _regnumberController.text;

      request.fields['phone'] = _phoneNumberController.text;
      ///
      // request.fields['phone'] = _phoneNumberController.text;
      // request.fields['phone'] = _phoneNumberController.text;
      // request.fields['phone'] = _phoneNumberController.text;
      ///
      request.fields['licenceEndorsements'] = _anyPointController.text;
      // request.fields['passportNumber'] = ;
      request.fields['passportNumber'] = _passportNumberController.text;

      if (_selectStaffRole != null) {
        request.fields['role'] = _selectStaffRole!;
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

      request.fields['licenceNumber'] = _licNumController.text;

      // CPC Checkbox
      bool isCheckboxSelected = _isCPCCheckBoxSelected.value;
      if (!isCheckboxSelected) {
        request.fields['cpcNumber'] = _cpcNumController.text;
        // request.fields['cpcExpiry'] = _cpcExpiryController.text;
        if (_cpcExpiryController.text.isNotEmpty) {
          request.fields['cpcExpiry'] =
              DateFormat('yyyy-MM-dd').format(DateFormat('dd-MM-yyyy').parse(_cpcExpiryController.text));
        }
      } else {
        request.fields['noCpcCard'] = "on";
      }

      // Tacho Checkbox
      bool isTechoCheckboxSelected = _isTachoCheckBoxSelected.value;
      if (!isTechoCheckboxSelected) {
        request.fields['tachoNumber'] = _techoNumberFileController.text;
      } else {
        request.fields['noTachoCard'] = "on";
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

      // Add other files if selected
      if (_selectedStaffFile != null) {
        request.files.add(await https.MultipartFile.fromBytes(
          'drivingLicence',
          _selectedStaffFile!,
          filename: _selectedStaffFileName!,
        ));
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

      // Validate Account Type and Bank Info
      if (_accountTypes.isEmpty || _accountTypes[0].isEmpty) {
        _accountTypeValidationError = 'Account type is required.';
        request.fields['account_type'] = ''; // Ensure this field is sent
      } else {
        request.fields['account_type'] = accountTypeMap[_accountTypes[0]] ?? ''; // Send correct account type
      }

      // request.fields['account_type'] = accountTypeMap[_accountTypes[0]] ?? '';
      request.fields['bank_name'] = _bankNameController.text;
      request.fields['account_name'] = _accountNameController.text;

      if (_accountTypes.contains('Bank Account') || _accountTypes.contains('Building Society')) {
        request.fields['account_number'] = _accountNumberController.text;
        request.fields['bank_code'] = _bankCodeController.text;

        if (_accountTypes.contains('Building Society')) {
          request.fields['building_society_roll_number'] = _buildingSocietyRollNumberController.text;
        }
      }

      if (_accountTypes.contains('International Bank Account')) {
        request.fields['recipient_address1'] = _Recipient1Controller.text;
        request.fields['recipient_address2'] = _Recipient2Controller.text;
        request.fields['recipient_address3'] = _Recipient3Controller.text;
        request.fields['iban'] = _IBAnController.text;
        request.fields['bic_swift'] = _BIcController.text;
        request.fields['payment_iso_country_code'] = _paymentCountryCodeController.text;
        request.fields['credit_iso_currency_code'] = _creditCurrencyController.text;
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
            'Your account was created successfully, Admin will approve your account soon!', context);
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
            final String errorMessage = messages.isNotEmpty ? messages.first : 'Unknown error';
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

              case 'phone':
                _alterphoneValidationError = errorMessage;
                break;
              case 'phone':
                _alterEmerNameValidationError = errorMessage;
                break;
              case 'phone':
                _alterEmerNumValidationError = errorMessage;
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
            }
          });

          // Show error messages to the user
          setState(() {
            _validationErrors = {
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
              'ni_number': _niValidationError,

              'phone': _phoneValidationError,
              'phone': _alterphoneValidationError,
              'phone': _alterEmerNameValidationError,
              'phone': _alterEmerNumValidationError,

              'licenceExpiry': _licExpiryValidationError,
              'licenceEndorsements': _licenceEndorValidationError,
              'licenceTypes': _licenseTypeValidationError,
              'licenceNumber': _licNumValidationError,
              'cpcNumber': _cpcNumberValidationError,
              'cpcExpiry': _cpcExpiryValidationError,
              'tachoNumber': _tachNumberValidationError,
              'medicalConditions': _medicalValidationError,
              'drivingLicence': _drivingLicenceValidationError,
              'passport': _passportValidationError ?? '',
              'passportNumber': _passportNumberValidationError,
              'cpc': _upCPCValidationError ?? '',
              'tacho': _upTachoValidationError ?? '',
              'gender': _genderValidationError ?? '',
              'proofOfAddress': _proofOfAddressValidationError,
              'account_type': _accountTypeValidationError,
              'bank_name': _bankNameValidationError,
              'account_name': _accountNameValidationError,
              'account_number': _accountNumberValidationError,
              'bank_code': _bankCodeValidationError,
              'building_society_roll_number': _buildingSocietyRollNumberValidationError,
              'recipient_address1': _recipientAddress1ValidationError,
              'recipient_address2': _recipientAddress2ValidationError,
              'recipient_address3': _recipientAddress3ValidationError,
              'iban': _ibanValidationError,
              'bic_swift': _bicSwiftValidationError,
              'payment_iso_country_code': _paymentIsoCountryCodeValidationError,
              'credit_iso_currency_code': _creditIsoCurrencyCodeValidationError,
            };
            isLoading = false;
          });
          print("--1---");
          print(responseData);
          Utils.flushBarErrorMessage('Please fill all the required field', context);
        } else {
          print("--2---");
          Utils.flushBarErrorMessage('Please fill all the required field', context);
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print("--3--");
        print(responseString);
        Utils.flushBarErrorMessage('Please fill all the required field', context);
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

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
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
    _alterphoneNumberController.dispose();
    _alterEmerContactNameController.dispose();
    _alterEmerContactNumController.dispose();
    _licNumController.dispose();
    _licExpiryController.dispose();
    _anyPointController.dispose();
    _cpcNumController.dispose();
    _cpcExpiryController.dispose();
    _techoDropFileController.dispose();
    _techoNumberFileController.dispose();
    _medicalController.dispose();
    _passportNumberController.dispose();
    consultantController.dispose();

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
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginView()));
        return true;
      },
      child: SingleChildScrollView(
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
                        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginView()));
                      },
                      child: HeaderRow(Icons.arrow_back)),
                  Text(
                    "MultiStep Candidate",
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
              // Align(
              //     alignment: Alignment.centerLeft,
              //     child: Text(
              //       "Personal Information",
              //       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              //     )),

              Container(
                  width: screenWidth * 0.95,
                  height: screenHeight * 0.06,
                  decoration: BoxDecoration(
                    color: AppColors.navColor,
                    border: Border.all(
                      color: AppColors.navButtonColor.withOpacity(0.4),
                      width: 0.4,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(
                    child: Text(
                      "Personal Information",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                  )),
              SizedBox(
                height: screenHeight * .013,
              ),
              Center(
                child: Container(
                  width: screenWidth * 0.95,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      offset: Offset(0, 3),
                      blurRadius: 5,
                      spreadRadius: 2,
                    ),
                  ]),
                  child: Column(children: [
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
                            });
                          } else {
                            setState(() {
                              _validationErrors['first_name'] = '';
                            });
                          }
                        },
                        onFieldSubmitted: (value) {
                          if (_FirstnameController.text.isEmpty) {
                            setState(() {
                              _validationErrors['first_name'] = 'First name is required and must be valid.';
                            });
                          } else {
                            setState(() {
                              _validationErrors['first_name'] = '';
                            });
                          }
                        }),
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
                              _validationErrors['last_name'] = 'Last name is required and must be valid.';
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
                              _validationErrors['last_name'] = 'Last name is required and must be valid.';
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
                          if (value.isEmpty || !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
                            setState(() {
                              _validationErrors['email'] = 'A valid email is required.';
                            });
                          } else {
                            setState(() {
                              _validationErrors['email'] = '';
                            });
                          }
                        },
                        onFieldSubmitted: (value) {
                          if (_emailController.text.isEmpty || !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
                            setState(() {
                              _validationErrors['email'] = 'A valid email is required.';
                            });
                          } else {
                            setState(() {
                              _validationErrors['email'] = '';
                            });
                          }
                        }),

                    SizedBox(height: screenHeight * .013,),

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
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                " *",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
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
                              maleContainerColor = AppColors.blueColor.withOpacity(0.2);
                              femaleContainerColor = AppColors.navOpacity.withOpacity(0.2);
                              othersContainerColor = AppColors.navOpacity.withOpacity(0.2);
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                  child: Icon(Icons.male, color: Colors.blueAccent),
                                ),
                                SizedBox(),
                                Center(
                                  child: Text(
                                    "Male",
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
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
                              femaleContainerColor = AppColors.blueColor.withOpacity(0.2);
                              maleContainerColor = AppColors.navOpacity.withOpacity(0.2);
                              othersContainerColor = AppColors.navOpacity.withOpacity(0.2);
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                  child: Icon(Icons.female_outlined, color: Colors.blueAccent),
                                ),
                                SizedBox(),
                                Center(
                                  child: Text(
                                    "Female",
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
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

                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, bottom: 10),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Text(
                                'Date Of Birth',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                " *",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
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


                    // Password
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, bottom: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
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
                          // height: screenHeight * 0.065,
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
                            controller: _passwordController,
                            obscureText: _obsecurePassword.value,
                            focusNode: passwordFocusNode,
                            obscuringCharacter: "*",
                            decoration: InputDecoration(
                              hintText: "Enter Your Password", // Set the placeholder text here
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                              // hintText: 'Enter your Password',
                              suffixIcon: InkWell(
                                onTap: () {
                                  _obsecurePassword.value = !_obsecurePassword.value;
                                },
                                child: Icon(
                                  _obsecurePassword.value ? Icons.visibility_off_outlined : Icons.visibility,
                                ),
                              ),
                            ),
                            onFieldSubmitted: (value) {
                              Utils.fieldFocusChange(context, passwordFocusNode, reEnterpasswordFocusNode);

                              if (value.isEmpty || value.length < 8) {
                                setState(() {
                                  _passwordValidationError = 'Password is required and must be at least 8 characters.';
                                });
                              } else {
                                setState(() {
                                  _passwordValidationError = '';
                                });
                              }
                            },
                            onChanged: (value) {
                              if (_passwordController.text.isEmpty || _passwordController.text.length < 8) {
                                setState(() {
                                  _passwordValidationError = 'Password is required and must be at least 8 characters.';
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
                        _passwordValidationError.isNotEmpty) // Render error message only if not empty
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
                            controller: _reEnterpasswordController,
                            obscureText: _reobsecurePassword.value,
                            focusNode: reEnterpasswordFocusNode,
                            obscuringCharacter: "*",
                            decoration: InputDecoration(
                              hintText: "Re-Enter Your Password",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                              // hintText: 'Re-enter your Password',
                              suffixIcon: InkWell(
                                onTap: () {
                                  _reobsecurePassword.value = !_reobsecurePassword.value;
                                },
                                child: Icon(
                                  _reobsecurePassword.value ? Icons.visibility_off_outlined : Icons.visibility,
                                ),
                              ),
                            ),
                            onFieldSubmitted: (value) {
                              Utils.fieldFocusChange(context, reEnterpasswordFocusNode, address1FocusNode);

                              if (value.isEmpty) {
                                setState(() {
                                  _confirmPassValidationError = 'Passwords must match.';
                                });
                              } else if (value.length < 8) {
                                _confirmPassValidationError = 'Confirm Password Passwords must match.';
                              } else {
                                setState(() {
                                  _confirmPassValidationError = '';
                                });
                              }
                            },
                            onChanged: (value) {
                              if (_reEnterpasswordController.text.isEmpty) {
                                setState(() {
                                  _confirmPassValidationError = 'Passwords must match.';
                                });
                              } else if (value.length < 8) {
                                setState(() {
                                  _confirmPassValidationError = 'Confirm Passwords must match.';
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
                            if (_confirmPassValidationError != null && _confirmPassValidationError.isNotEmpty)
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
                                    maxLines: 1, // Ensure single-line error message
                                    overflow: TextOverflow.ellipsis, // Handle longer text gracefully
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (_passwordController.text.isNotEmpty &&
                                          _reEnterpasswordController.text.isNotEmpty)
                                        Text(
                                          value ? "Password matched" : "Not matched",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: value ? Colors.green : Colors.red,
                                          ),
                                        ),
                                      SizedBox(height: screenHeight * .013), // Add spacing below
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ]),
                ),
              ),

              ///Contact Information
              SizedBox(
                height: screenHeight * 0.015,
              ),
              // Align(
              //     alignment: Alignment.centerLeft,
              //     child: Text(
              //       "Contact Information",
              //       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              //     )),
              Container(
                  width: screenWidth * 0.95,
                  height: screenHeight * 0.06,
                  decoration: BoxDecoration(
                    color: AppColors.navColor,
                    border: Border.all(
                      color: AppColors.navButtonColor.withOpacity(0.4),
                      width: 0.4,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(
                    child: Text(
                      "Contact Information",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                  )),
              SizedBox(
                height: screenHeight * .013,
              ),
              Center(
                child: Container(
                  width: screenWidth * 0.95,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      offset: Offset(0, 3),
                      blurRadius: 5,
                      spreadRadius: 2,
                    ),
                  ]),
                  child: Column(children: [
                    SizedBox(
                      height: screenHeight * .013,
                    ),
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
                          if (_address1Controller.text.isEmpty || value.length > 35) {
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
                          if (_address2Controller.text.isEmpty || value.length > 35) {
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
                          if (_postCodeController.text.isEmpty || value.length > 8) {
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

                    SizedBox(height: screenHeight * .013,),
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
                          if (value.isEmpty || !RegExp(r'^(?:\+44|0)7\d{9}$').hasMatch(value)) {
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
                          if (_phoneNumberController.text.isEmpty || !RegExp(r'^(?:\+44|0)7\d{9}$').hasMatch(value)) {
                            setState(() {
                              _validationErrors['phone'] =
                              'Phone number must be a valid UK phone.';
                            });
                          } else {
                            setState(() {
                              _validationErrors['phone'] = '';
                            });
                          }
                        }

                    ),
                    SizedBox(height: screenHeight * .013,),
                    CustomContainer(
                        titleText: 'Alternative Phone Number',
                        titleText2: "Enter Your Alternative Phone Number",
                        controller: _alterphoneNumberController,
                        keyboardType: TextInputType.phone,
                        focusNode: alterphoneNumberFocusNode,
                        focusCurrent: alterphoneNumberFocusNode,
                        focusNext: alterEmerContactNameFocusNode,
                        errorMessage: _validationErrors['phone1'],
                        placeholder:"Enter Your Alternative Phone Number",
                        onChanged: (value) {
                          if (value.isEmpty || !RegExp(r'^(?:\+44|0)7\d{9}$').hasMatch(value)) {
                            setState(() {
                              _validationErrors['phone1'] =
                              'Alternative Phone number must be a valid UK phone.';
                            });
                          } else {
                            setState(() {
                              _validationErrors['phone1'] = '';
                            });
                          }
                        },
                        onFieldSubmitted: (value) {
                          if (_alterphoneNumberController.text.isEmpty || !RegExp(r'^(?:\+44|0)7\d{9}$').hasMatch(value)) {
                            setState(() {
                              _validationErrors['phone1'] =
                              'Alternative Phone number must be a valid UK phone.';
                            });
                          } else {
                            setState(() {
                              _validationErrors['phone1'] = '';
                            });
                          }
                        }

                    ),
                    SizedBox(height: screenHeight * .013,),
                    CustomContainer(
                        titleText: 'Emergency Contact Name',
                        titleText2: "Enter Your Emergency Contact Name",
                        controller: _alterEmerContactNameController,
                        keyboardType: TextInputType.name,
                        focusNode: alterEmerContactNameFocusNode,
                        focusCurrent: alterEmerContactNameFocusNode,
                        focusNext: alterEmerContactNumFocusNode,
                        errorMessage: _validationErrors['first_name2'],
                        placeholder: "Enter Your Emergency Contact Name",
                        onChanged: (value) {
                          if (value.isEmpty) {
                            setState(() {
                              _validationErrors['first_name2'] = 'Emergency contact name is required and must be valid.';
                            });
                          } else {
                            setState(() {
                              _validationErrors['first_name2'] = '';
                            });
                          }
                        },
                        onFieldSubmitted: (value) {
                          if (_alterEmerContactNameController.text.isEmpty) {
                            setState(() {
                              _validationErrors['first_name2'] = 'Emergency Contact name is required and must be valid.';
                            });
                          } else {
                            setState(() {
                              _validationErrors['first_name2'] = '';
                            });
                          }
                        }),
                    SizedBox(height: screenHeight * .013,),
                    CustomContainer(
                        titleText: 'Emergency Contact Number',
                        titleText2: "Enter your mobile number",
                        controller: _alterEmerContactNumController,
                        keyboardType: TextInputType.phone,
                        focusNode: alterEmerContactNumFocusNode,
                        focusCurrent: alterEmerContactNumFocusNode,
                        focusNext: null,
                        errorMessage: _validationErrors['phone2'],
                        placeholder: "Enter Your Emergency Contact Number",
                        onChanged: (value) {
                          if (value.isEmpty || !RegExp(r'^(?:\+44|0)7\d{9}$').hasMatch(value)) {
                            setState(() {
                              _validationErrors['phone2'] =
                              'Emergency contact number must be a valid UK phone.';
                            });
                          } else {
                            setState(() {
                              _validationErrors['phone2'] = '';
                            });
                          }
                        },
                        onFieldSubmitted: (value) {
                          if (_alterEmerContactNumController.text.isEmpty || !RegExp(r'^(?:\+44|0)7\d{9}$').hasMatch(value)) {
                            setState(() {
                              _validationErrors['phone2'] =
                              'Emergency contact number must be a valid UK phone.';
                            });
                          } else {
                            setState(() {
                              _validationErrors['phone2'] = '';
                            });
                          }
                        }

                    ),
                    SizedBox(height: screenHeight * .013,),
                  ]),
                ),
              ),

              ///Additional Information
              SizedBox(
                height: screenHeight * 0.015,
              ),
              // Align(
              //     alignment: Alignment.centerLeft,
              //     child: Text(
              //       "Additional Information",
              //       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              //     )),
              Container(
                  width: screenWidth * 0.95,
                  height: screenHeight * 0.06,
                  decoration: BoxDecoration(
                    color: AppColors.navColor,
                    border: Border.all(
                      color: AppColors.navButtonColor.withOpacity(0.4),
                      width: 0.4,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(
                    child: Text(
                      "Additional Information",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                  )),

              ///Additional Information
              SizedBox(
                height: screenHeight * .013,
              ),
              Center(
                child: Container(
                    width: screenWidth * 0.95,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        offset: Offset(0, 3),
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ]),
                    child: Column(children: [
                      SizedBox(
                        height: screenHeight * .013,
                      ),
                      Column(
                        children: [
                          // SizedBox(height: screenHeight * .013),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, bottom: 10),
                            child: Align(
                              alignment: Alignment.centerLeft,
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
                          Container(
                            height: screenHeight * 0.065,
                            width: screenWidth * 0.90,
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
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
                                  _selectStaffRole ?? 'Select',
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
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectStaffRole = newValue;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * .013,),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, bottom: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Text(
                                'Preferred Communication Method',
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
                      Container(
                        height: screenHeight * 0.065,
                        width: screenWidth * 0.90,
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.grey.withOpacity(0.4), width: 0.4),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            iconSize: 30.0,
                            hint: Text('Select', style: TextStyle(fontSize: 15, color: Colors.black),),
                            value: _selectedGender,
                            items: ['Email', 'Phone'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedGender = newValue;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * .013,),
                      CustomContainer(
                          titleText: 'Passport Number',
                          titleText2: "Enter your passport Number",
                          controller: _passportNumberController,
                          keyboardType: TextInputType.name,
                          focusNode: passwordNumFocusNode,
                          focusCurrent: passwordNumFocusNode,
                          focusNext: passwordNumFocusNode,
                          errorMessage: _validationErrors['passportNumber'],
                          placeholder: "Enter Your Passport Number"),
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
                            if (value.isEmpty ||
                                !RegExp(
                                  r'^(?![DFIQUV]{2})(?![DFIQUV])[A-CEGHJ-NOPRSTW-Z]{2}\d{6}[A-D]$',
                                ).hasMatch(value)) {
                              setState(() {
                                _validationErrors['ni_number'] = 'NI number is invalid';
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
                                _validationErrors['ni_number'] = 'NI number is invalid';
                              });
                            } else {
                              setState(() {
                                _validationErrors['ni_number'] = '';
                              });
                            }
                          }),
                      SizedBox(height: screenHeight * .013),

                      // Search or Consultant Name
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, bottom: 10),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Text(
                                  'Consultant Name: (Optional)',
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
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        if (_isExpanded && filteredConsultants.isNotEmpty)
                          Container(
                            height: screenHeight * 0.3,
                            width: screenWidth * 0.90,
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
                                          consultantController.text = filteredConsultants[index].name ?? '';
                                          filteredConsultants = [];
                                          _isExpanded = false;
                                        });
                                      },
                                    );
                                  }),
                            ),
                          ),
                      ]),
                      SizedBox(
                        height: screenHeight * .013,
                      ),
                      ImagePickerWidget(
                        title: "Worker Image",
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        onImagePicked: (Uint8List? imageData, String? imageName) {
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
                      DynamicDropdown(
                        title: "Do you have a Right to Work in the UK?",
                        options: _dropdownOptions,
                        selectedOption: _selectedOption1!,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedOption1 = newValue!;
                            _formData['right_to_work'] = newValue == 'Yes' ? 1 : 0;
                          });
                        },
                      ),
                      SizedBox(height: screenHeight * .013),
                      DynamicDropdown(
                        title: "Do you have a DBS or EDBS (if applicable for your role)?",
                        options: _dropdownOptions,
                        selectedOption: _selectedOption2!,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedOption2 = newValue!;
                            _formData['dbs_edbs'] = newValue == 'Yes' ? 1 : 0;
                          });
                        },
                      ),
                      SizedBox(height: screenHeight * .013),
                      DynamicDropdown(
                        title: "Do you want to opt out of the Pension Scheme?",
                        options: _dropdownOptions,
                        selectedOption: _selectedOption3!,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedOption3 = newValue!;
                            _formData['pension_scheme'] = newValue == 'Yes' ? 1 : 0;
                          });
                        },
                      ),
                      SizedBox(height: screenHeight * .013),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0,right: 5),
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
                                        text: "Do you have any Medical Conditions that we should be aware of?",
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
                            hintText: "Enter Any  Medical Conditions", // Set the placeholder text here
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                          ),
                        ),
                      ),
                      if (_medicalValidationError != null &&
                          _medicalValidationError.isNotEmpty) // Render error message only if not empty
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
                      SizedBox(height: screenHeight * .013),
                    ])),
              ),

              SizedBox(
                height: screenHeight * .05,
              ),

              GestureDetector(
                onTap: () async {
                  // await postData();
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
                            "Next",
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

  Widget CustomContainer({
    required String titleText,
    required String titleText2,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required FocusNode focusNode,
    FocusNode? focusCurrent,
    FocusNode? focusNext,
    String? errorMessage,
    String? placeholder,
    Function(String)? onChanged,
    Function(String)? onFieldSubmitted,
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
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
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
                contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
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
                        headerBackgroundColor: AppColors.navColor, //Header Background Color

                        backgroundColor: Colors.white, //Main Baground

                        headerForegroundColor: Colors.white, //Header Text Color
                        surfaceTintColor: Colors.white, //Main Background Needed
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.navButtonColor, //Cancel Ok  button text color
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
              }
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
        Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 5),
          child: Align(
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
        Padding(
          padding: const EdgeInsets.only(
            left: 10.0,
          ),
          child: Container(
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
          ),
        ),
      ],
    );
  }
}
