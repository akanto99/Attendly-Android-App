import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:c9_app/Modules/ClientModule/pages/noInternetConnectionWidget.dart';
import 'package:c9_app/Modules/StaffModule/DashBoard/staff_navigationScreen.dart';
import 'package:c9_app/Modules/StaffModule/Documents/uploadFileNew.dart';
import 'package:c9_app/Modules/StaffModule/Profile/fileUpload_new.dart';
import 'package:c9_app/loadingScreen.dart';
import 'package:c9_app/model/profileModel/profileapi_model.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/utils/routes/routes_name.dart';
import 'package:c9_app/view_model/services/rolebasedmodel/user_view_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as https;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/utils.dart';
import '../../../view/widgets/filepicker_wigetV2.dart';
import '../fullViewImageStaff.dart';

class StaffProfile extends StatefulWidget {
  const StaffProfile({super.key});

  @override
  State<StaffProfile> createState() => _StaffProfileState();
}

class _StaffProfileState extends State<StaffProfile> with WidgetsBindingObserver {
  late Future<ProfileApiModel?> _userProfileFuture;

  bool _showNoInternetConnectionMessage = false;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _userProfileFuture = fetchData();
    _licNumberController.addListener(() {
      setState(() {});
    });

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
      bool hasInternet = await _hasInternetConnection();

      if (result != ConnectivityResult.none && hasInternet && _showNoInternetConnectionMessage) {
        _refreshData().then((_) {
          setState(() {});
        });
      }
      setState(() {
        _showNoInternetConnectionMessage = (result == ConnectivityResult.none || !hasInternet);
      });
    });
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription.cancel(); // Cancel subscription

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _refreshData();
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> _refreshData() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    bool hasInternet = await _hasInternetConnection();

    if (connectivityResult == ConnectivityResult.none || !hasInternet) {
      setState(() {
        _showNoInternetConnectionMessage = true;
      });
    } else {
      setState(() {
        _userProfileFuture = fetchData();
        print("Pull profile");
      });
    }
  }

  final Map<String, String> maritalStatusMapping = {
    "single": "Single",
    "married": "Married",
    "divorced": "Divorced",
    "widowed": "Widowed",
    "separated": "Separated",
  };

  String? _selectedMaratialStatus = "single";

  ///Section--------------5
  bool _isExpanded6 = false;
  bool _isEditing6 = false;
  // String? _selectedBankTypes;
  final Map<String, String> bankTypeMapping = {
    "Bank Account": "BANK_ACCOUNT",
    "Building Society": "BUILDING_SOCIETY",
    "International Bank Account": "INTERNATIONAL_BANK_ACCOUNT",
  };

  String _selectedBankTypes = "BANK_ACCOUNT";
  final TextEditingController _accountTypeController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _bankCodeController = TextEditingController();
  final TextEditingController _buildingSocietyRollNumberController = TextEditingController();
  final TextEditingController _recipientAddress1Controller = TextEditingController();
  final TextEditingController _recipientAddress2Controller = TextEditingController();
  final TextEditingController _recipientAddress3Controller = TextEditingController();
  final TextEditingController _ibanController = TextEditingController();
  final TextEditingController _bicSwiftCodeController = TextEditingController();
  final TextEditingController _paymentIsoCodeController = TextEditingController();
  final TextEditingController _creditIsoCodeController = TextEditingController();
  Future<ProfileApiModel?> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';

    final String apiUrl = '${AppUrl.baseUrl}/api/app/profile';
    final response = await https.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      final ProfileApiModel profileViewset = ProfileApiModel.fromJson(responseData);
      setState(() {
        _firstNameController.text = profileViewset.data.firstName ?? '';
        _lastNameameController.text = profileViewset.data.lastName ?? '';
        _emailController.text = profileViewset.data.email ?? '';
        _phoneController.text = profileViewset.data.phone ?? '';
        _address1Controller.text = profileViewset.data.addressLine1 ?? '';
        _address2Controller.text = profileViewset.data.addressLine2 ?? '';
        _townCityController.text = profileViewset.data.city ?? '';
        _postCodeController.text = profileViewset.data.postCode ?? '';
        _ninController.text = profileViewset.data.niNumber ?? '';
        _ninController.text = profileViewset.data.niNumber ?? '';
        _selectedGender = profileViewset.data.gender?.isNotEmpty ?? false ? capitalizeGender(profileViewset.data.gender!) : 'Male';
        _selectedMaratialStatus = profileViewset.data.maritalStatus?.isNotEmpty ?? false ? profileViewset.data.maritalStatus! : 'single';
        _userName = profileViewset.data.userName ?? "";

        ///Section 2
        _selectedOption2 = profileViewset.data.dbsCheck == 1 ? 'Yes' : 'No';
        if (profileViewset.data.dbsExpiry != null) {
          DateTime dbsExp = DateTime.parse(profileViewset.data.dbsExpiry!);
          _dbsExpiryController.text = '${dbsExp.day.toString().padLeft(2, '0')}/${dbsExp.month.toString().padLeft(2, '0')}/${dbsExp.year}';
        }
        _selectedOption3 = profileViewset.data.optOutOfPension == 1 ? 'Yes' : 'No';
        _selected11 = profileViewset.data.isUkCitizen == 1 ? 'Yes' : 'No';
        _selected12 = profileViewset.data.hasUnspentCriminalConvictions == 1 ? 'Yes' : 'No';
        pleaseSpecifyController.text = profileViewset.data.unspentCriminalConvictionsDetails ?? '';
        _selected13 = profileViewset.data.isAuthorizedToWorkInUk == 1 ? 'Yes' : 'No';
        _consultController.text = profileViewset.data.consultant ?? '';
        _roleController.text = profileViewset.data.roleType ?? '';

        ///Section-------------------3
        _selected2 = profileViewset.data.validUkDrivingLicense == 1 ? 'Yes' : 'No';
        _selected1 = profileViewset.data.ukDrivingExperience == 1 ? 'Yes' : 'No';
        _licNumberController.text = profileViewset.data.licenceNumber ?? '';
        _selectedLicenseTypes = List<String>.from(profileViewset.data.licenceType ?? []);
        if (profileViewset.data.licenceExpiry != null) {
          DateTime licExp = DateTime.parse(profileViewset.data.licenceExpiry!);
          _licExpiryController.text = "${licExp.day.toString().padLeft(2, '0')}/${licExp.month.toString().padLeft(2, '0')}/${licExp.year}";
        }
        _licEndorsementController.text = profileViewset.data.licenceEndorsement ?? '';
        if (profileViewset.data.drivingLicenseIssueDate != null) {
          try {
            DateTime drivingIssueDate = DateTime.parse(profileViewset.data.drivingLicenseIssueDate!);
            _dateofIssueDrivingController.text = '${drivingIssueDate.day.toString().padLeft(2, '0')}/${drivingIssueDate.month.toString().padLeft(2, '0')}/${drivingIssueDate.year}';
          } catch (e) {
            print('Error parsing driving license issue date: $e');
          }
        }
        _drivingLicensecategoryController.text = profileViewset.data.drivingLicenseCategory ?? '';
        _checkCodeDrivingLicenseController.text = profileViewset.data.drivingLicenseCheckCode ?? '';
        _selected3 = profileViewset.data.penaltyPoints == 1 ? 'Yes' : 'No';
        _selected15 = profileViewset.data.noCpcCard == 1 ? 'Yes' : 'No';
        _cpcNumberController.text = profileViewset.data.cpcNumber ?? '';
        if (profileViewset.data.cpcExpiry != null) {
          DateTime cpcExp = DateTime.parse(profileViewset.data.cpcExpiry!);
          _cpcExpiryController.text = "${cpcExp.day.toString().padLeft(2, '0')}/${cpcExp.month.toString().padLeft(2, '0')}/${cpcExp.year}";
        }
        _selected16 = profileViewset.data.noTachoCard == 1 ? 'Yes' : 'No';
        _techoNumberController.text = profileViewset.data.tachoNumber ?? '';
        if (profileViewset.data.tachoExpiry != null) {
          DateTime tachoExp = DateTime.parse(profileViewset.data.tachoExpiry!);
          _tachoExpiryController.text = '${tachoExp.day.toString().padLeft(2, '0')}/${tachoExp.month.toString().padLeft(2, '0')}/${tachoExp.year}';
        }

        ///Section ---------------------4
        _selected4 = profileViewset.data.physicalIncapabilities == 1 ? 'Yes' : 'No';
        _selected5 = profileViewset.data.ongoingMedicalConditions == 1 ? 'Yes' : 'No';
        _detailMedicalConditionController.text = profileViewset.data.medicalConditionDetails ?? '';
        _selected6 = profileViewset.data.takingMedication == 1 ? 'Yes' : 'No';
        _detailOfMedicationController.text = profileViewset.data.medicationDetails ?? '';
        _selected7 = profileViewset.data.drugOrAlcoholIssues == 1 ? 'Yes' : 'No';
        _selected8 = profileViewset.data.wearsGlasses == 1 ? 'Yes' : 'No';
        if (profileViewset.data.lastEyeTest != null) {
          try {
            DateTime lastEyeDate = DateTime.parse(profileViewset.data.lastEyeTest!);
            _lasteyeController.text = '${lastEyeDate.day.toString().padLeft(2, '0')}/${lastEyeDate.month.toString().padLeft(2, '0')}/${lastEyeDate.year}';
          } catch (e) {
            print('Error parsing last eye test date: $e');
          }
        }
        _selected9 = profileViewset.data.dismissedForMedicalReasons == 1 ? 'Yes' : 'No';
        _reasonForDismissalController.text = profileViewset.data.dismissalReason ?? '';
        _selected10 = profileViewset.data.dismissedFromDrivingRoles == 1 ? 'Yes' : 'No';
        _reasondatesForDrivingRolesController.text = profileViewset.data.drivingDismissalDetails ?? '';

        ///Section ------------------------------------------5
        _selectedBankTypes = profileViewset.data.bankDetail!.accountType != null ? profileViewset.data.bankDetail!.accountType.toString() : 'Bank Account';

        if (profileViewset.data.bankDetail != null) {
          _accountTypeController.text = profileViewset.data.bankDetail!.accountType ?? '';
          _bankNameController.text = profileViewset.data.bankDetail!.bankName ?? '';
          _accountNameController.text = profileViewset.data.bankDetail!.accountName ?? '';
          _accountNumberController.text = profileViewset.data.bankDetail!.accountNumber?.toString() ?? '';
          _bankCodeController.text = profileViewset.data.bankDetail!.bankCode ?? '';
          _buildingSocietyRollNumberController.text = profileViewset.data.bankDetail!.buildingSocietyRollNumber ?? '';
          _recipientAddress1Controller.text = profileViewset.data.bankDetail!.recipientAddress1 ?? '';
          _recipientAddress2Controller.text = profileViewset.data.bankDetail!.recipientAddress2 ?? '';
          _recipientAddress3Controller.text = profileViewset.data.bankDetail!.recipientAddress3 ?? '';
          _ibanController.text = profileViewset.data.bankDetail!.iban ?? '';
          _bicSwiftCodeController.text = profileViewset.data.bankDetail!.bicSwiftCode ?? '';
          _paymentIsoCodeController.text = profileViewset.data.bankDetail!.paymentIsoCode ?? '';
          _creditIsoCodeController.text = profileViewset.data.bankDetail!.creditIsoCode ?? '';
        }
      });

      return profileViewset;
    } else {
      throw Exception('Failed to fetch user data. Status code: ${response.statusCode}');
    }
  }

  void _updateProfile() async {
    Utils.showDialogLoading(context);
    String _firstValidationError = '';
    String _lastValidationError = '';
    String _emailValidationError = '';
    String _phoneValidationError = '';
    String _imageValidationError = '';
    String _townOrCityValidationError = '';
    String _postCodeValidationError = '';
    String _addressLine1ValidationError = '';
    String _addressLine2ValidationError = '';
    String _genderValidationError = '';
    String _maritalStatusValidationError = '';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';
    final String apiUrl = '${AppUrl.baseUrl}/api/app/staff/profile/update/with/step';
    var request = https.MultipartRequest('POST', Uri.parse(apiUrl));
    request.headers.addAll({
      'Authorization': 'Bearer $_token',
      'Accept': 'application/json',
    });

    ///Section------------------------------------1
    request.fields['step'] = "1";
    request.fields['first_name'] = _firstNameController.text.toString();
    request.fields['last_name'] = _lastNameameController.text.toString();
    request.fields['email'] = _emailController.text.toString();
    request.fields['phone'] = _phoneController.text.toString();
    request.fields['gender'] = _selectedGender ?? "";

    if (_selectedImage != null) {
      request.files.add(await https.MultipartFile.fromBytes(
        'image',
        _selectedImage!,
        filename: _selectedImageName!,
      ));
    }
    request.fields['city'] = _townCityController.text.toString();
    request.fields['postCode'] = _postCodeController.text.toString();
    request.fields['addressLine1'] = _address1Controller.text.toString();
    request.fields['addressLine2'] = _address2Controller.text.toString();
    request.fields['marital_status'] = _selectedMaratialStatus ?? "";
    if (_selectedPassport != null) {
      request.files.add(await https.MultipartFile.fromBytes(
        'passport_doc',
        _selectedPassport!,
        filename: _selectedPassportName!,
      ));
    }
    if (_selectedProff != null) {
      request.files.add(await https.MultipartFile.fromBytes(
        'proof_of_address_doc',
        _selectedProff!,
        filename: _selectedProffName!,
      ));
    }
    final response = await request.send();

    final responseBody = await response.stream.bytesToString();
    final responseData = jsonDecode(responseBody);

    if (response.statusCode == 200) {
      print(response);
      print(responseData);
      String successMessage = responseData['message'] ?? 'Updated Successfully';

      Utils.flushBarSuccessMessage(successMessage, context);
      Future.delayed(Duration(seconds: 2), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StaffProfile(),
          ),
        );
      });
      print(responseData);
    } else if (response.statusCode == 422) {
      // Handle validation error response
      final Map<String, dynamic> responseData = jsonDecode(responseBody);
      Navigator.pop(context);
      if (responseData.containsKey('errors')) {
        final Map<String, dynamic> errors = responseData['errors'];
        errors.forEach((field, messages) {
          final String errorMessage = messages.isNotEmpty ? messages.first : 'Unknown error';
          switch (field) {
            ///Section------------------------------------1
            case 'first_name':
              _firstValidationError = errorMessage;
              break;
            case 'last_name':
              _lastValidationError = errorMessage;
              break;
            case 'email':
              _emailValidationError = errorMessage;
              break;
            case 'phone':
              _phoneValidationError = errorMessage;
              break;
            case 'image':
              _imageValidationError = errorMessage;
              break;
            case 'townOrCity':
              _townOrCityValidationError = errorMessage;
              break;
            case 'postCode':
              _postCodeValidationError = errorMessage;
              break;
            case 'addressLine1':
              _addressLine1ValidationError = errorMessage;
              break;
            case 'addressLine2':
              _addressLine2ValidationError = errorMessage;
              break;
            case 'gender':
              _genderValidationError = errorMessage;
              break;
            case 'marital_status':
              _maritalStatusValidationError = errorMessage;
              break;
          }
        });

        setState(() {
          _validationErrors = {
            'first_name': _firstValidationError,
            'last_name': _lastValidationError,
            'email': _emailValidationError,
            'phone': _phoneValidationError,
            'image': _imageValidationError,
            'townOrCity': _townOrCityValidationError,
            'postCode': _postCodeValidationError,
            'addressLine1': _addressLine1ValidationError,
            'addressLine2': _addressLine2ValidationError,
            'gender': _genderValidationError,
            'marital_status': _maritalStatusValidationError,
          };
        });
        String errorMessage = responseData['message'] ?? 'Update failed';
        Utils.flushBarErrorMessage(errorMessage, context);
        //
        print(responseData);
      }
    } else {
      String errorMessage = responseData['message'] ?? 'Update failed';
      Utils.flushBarErrorMessage(errorMessage, context);
      setState(() {
        // isLoading = false;
      });
    }
  }

  void _updateProfile2() async {
    Utils.showDialogLoading(context);
    String specifyValidationError = '';
    String dbsExpiryValidationError = '';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';
    final String apiUrl = '${AppUrl.baseUrl}/api/app/staff/profile/update/with/step';
    var request = https.MultipartRequest('POST', Uri.parse(apiUrl));
    request.headers.addAll({
      'Authorization': 'Bearer $_token',
      'Accept': 'application/json',
    });
    request.fields['step'] = "2";
    request.fields['is_uk_citizen'] = _selected11 == 'Yes' ? '1' : '0';

    request.fields['has_unspent_criminal_convictions'] = _selected12 == 'Yes' ? '1' : '0';
    if (_selected12 == "Yes") {
      request.fields['unspent_criminal_convictions_details'] = pleaseSpecifyController.text.toString();
    }

    request.fields['is_authorized_to_work_in_uk'] = _selected13 == 'Yes' ? '1' : '0';

    request.fields['dbsCheck'] = _selectedOption2 == 'Yes' ? '1' : '0';
    if (_selectedOption2 == "Yes") {
      request.fields['dbsExpiry'] = _dbsExpiryController.text.toString();
    }

    request.fields['optOutOfPension'] = _selectedOption3 == 'Yes' ? '1' : '0';

    final response = await request.send();

    final responseBody = await response.stream.bytesToString();
    final responseData = jsonDecode(responseBody);

    if (response.statusCode == 200) {
      print(response);
      print(responseData);
      String successMessage = responseData['message'] ?? 'Updated Successfully';

      Utils.flushBarSuccessMessage(successMessage, context);
      Future.delayed(Duration(seconds: 2), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StaffProfile(),
          ),
        );
      });
      print(responseData);
    } else if (response.statusCode == 422) {
      // Handle validation error response
      final Map<String, dynamic> responseData = jsonDecode(responseBody);
      Navigator.pop(context);
      if (responseData.containsKey('errors')) {
        final Map<String, dynamic> errors = responseData['errors'];
        errors.forEach((field, messages) {
          final String errorMessage = messages.isNotEmpty ? messages.first : 'Unknown error';
          switch (field) {
            ///Section------------------------------------1
            case 'unspent_criminal_convictions_details':
              specifyValidationError = errorMessage;
              break;
            case 'dbsExpiry':
              dbsExpiryValidationError = errorMessage;
              break;
          }
        });

        setState(() {
          _validationErrors = {
            'unspent_criminal_convictions_details': specifyValidationError,
            'dbsExpiry': dbsExpiryValidationError,
          };
        });
        String errorMessage = responseData['message'] ?? 'Update failed';
        Utils.flushBarErrorMessage(errorMessage, context);
        //
        print(responseData);
      }
    } else {
      String errorMessage = responseData['message'] ?? 'Update failed';
      Utils.flushBarErrorMessage(errorMessage, context);
      setState(() {
        // isLoading = false;
      });
    }
  }

  void _updateProfile3() async {
    Utils.showDialogLoading(context);
    String licNumberValidationError = '';
    String licExpiryValidationError = '';
    String licEndorsmentValidationError = '';
    String dateofIssueLicValidationError = '';
    String licCategoryValidationError = '';
    String checkCodeValidationError = '';
    String licTypesValidationError = '';
    String _drivingLicenceValidationError = '';

    String cpcNumberValidationError = '';
    String cpcExpiryValidationError = '';
    String _cpcfileValidationError = '';

    String tachoNumberValidationError = '';
    String tachoExpiryValidationError = '';
    String _tachofileValidationError = '';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';
    final String apiUrl = '${AppUrl.baseUrl}/api/app/staff/profile/update/with/step';
    var request = https.MultipartRequest('POST', Uri.parse(apiUrl));
    request.headers.addAll({
      'Authorization': 'Bearer $_token',
      'Accept': 'application/json',
    });

    ///Section------------------------------------1
    request.fields['step'] = "3";
    request.fields['role'] = _roleController.text.toString();
    request.fields['valid_uk_driving_license'] = _selected2 == 'Yes' ? '1' : '0';
    if (_selected2 == 'Yes') {
      request.fields['uk_driving_experience'] = _selected1 == 'Yes' ? '1' : '0';
    }
    if (_selected2 == 'Yes' && _selected1 == "Yes") {
      request.fields['licenceNumber'] = _licNumberController.text.toString();
    }
    if (_selected2 == 'Yes' && _selected1 == "Yes" && _licNumberController.text.isNotEmpty) {
      request.fields['licenceExpiry'] = _licExpiryController.text.toString();
      request.fields['licence_endorsement'] = _licEndorsementController.text.toString();
      request.fields['driving_license_issue_date'] = _dateofIssueDrivingController.text.toString();
      request.fields['driving_license_category'] = _drivingLicensecategoryController.text.toString();
      request.fields['driving_license_check_code'] = _checkCodeDrivingLicenseController.text.toString();
      if (_selectedLicenseTypes != null && _selectedLicenseTypes.isNotEmpty) {
        for (int i = 0; i < _selectedLicenseTypes.length; i++) {
          request.fields['licenceTypes[$i]'] = _selectedLicenseTypes[i];
        }
      }

      if (_selectedStaffFile != null) {
        request.files.add(await https.MultipartFile.fromBytes(
          'driving_licence_doc',
          _selectedStaffFile!,
          filename: _selectedStaffFileName!,
        ));
        print('Driving License Image Added');
      }
      request.fields['penalty_points'] = _selected3 == 'Yes' ? '1' : '0';
    }

    request.fields['noCpcCard'] = _selected15 == 'Yes' ? '1' : '0';
    if (_selected15 == 'Yes') {
      request.fields['cpcNumber'] = _cpcNumberController.text.toString();
      request.fields['cpcExpiry'] = _cpcExpiryController.text.toString();
      if (_selectedCPC != null) {
        request.files.add(await https.MultipartFile.fromBytes(
          'cpc_doc',
          _selectedCPC!,
          filename: _selectedCPCName!,
        ));
        print('Driving License Image Added');
      }
    }

    request.fields['noTachoCard'] = _selected16 == 'Yes' ? '1' : '0';
    if (_selected16 == 'Yes') {
      request.fields['tachoNumber'] = _techoNumberController.text.toString();
      request.fields['tachoExpiry'] = _tachoExpiryController.text.toString();
      if (_selectedTacho != null) {
        request.files.add(await https.MultipartFile.fromBytes(
          'tacho_doc',
          _selectedTacho!,
          filename: _selectedTachoName!,
        ));
      }
    }

    final response = await request.send();

    final responseBody = await response.stream.bytesToString();
    final responseData = jsonDecode(responseBody);

    if (response.statusCode == 200) {
      print(response);
      print(responseData);
      String successMessage = responseData['message'] ?? 'Updated Successfully';

      Utils.flushBarSuccessMessage(successMessage, context);
      Future.delayed(Duration(seconds: 2), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StaffProfile(),
          ),
        );
      });
      print(responseData);
    } else if (response.statusCode == 422) {
      // Handle validation error response
      final Map<String, dynamic> responseData = jsonDecode(responseBody);
      Navigator.pop(context);
      if (responseData.containsKey('errors')) {
        final Map<String, dynamic> errors = responseData['errors'];
        errors.forEach((field, messages) {
          final String errorMessage = messages.isNotEmpty ? messages.first : 'Unknown error';
          switch (field) {
            ///Section------------------------------------1
            case 'licenceNumber':
              licNumberValidationError = errorMessage;
              break;
            case 'licenceExpiry':
              licExpiryValidationError = errorMessage;
              break;
            case 'licence_endorsement':
              licEndorsmentValidationError = errorMessage;
              break;
            case 'driving_license_issue_date':
              dateofIssueLicValidationError = errorMessage;
              break;
            case 'driving_license_category':
              licCategoryValidationError = errorMessage;
              break;
            case 'driving_license_check_code':
              checkCodeValidationError = errorMessage;
              break;
            case 'licenceTypes':
              licTypesValidationError = errorMessage;
              break;
            case 'driving_licence_doc':
              _drivingLicenceValidationError = errorMessage;
              break;

            case 'cpcNumber':
              cpcNumberValidationError = errorMessage;
              break;
            case 'cpcExpiry':
              cpcExpiryValidationError = errorMessage;
              break;
            case 'cpc_doc':
              _cpcfileValidationError = errorMessage;
              break;

            case 'tachoNumber':
              tachoNumberValidationError = errorMessage;
              break;
            case 'tachoExpiry':
              tachoExpiryValidationError = errorMessage;
              break;
            case 'tacho_doc':
              _tachofileValidationError = errorMessage;
              break;
          }
        });

        setState(() {
          _validationErrors = {
            'licenceNumber': licNumberValidationError,
            'licenceExpiry': licExpiryValidationError,
            'licence_endorsement': licEndorsmentValidationError,
            'driving_license_issue_date': dateofIssueLicValidationError,
            'driving_license_category': licCategoryValidationError,
            'driving_license_check_code': checkCodeValidationError,
            'licenceTypes': licTypesValidationError,
            'driving_licence_doc': _drivingLicenceValidationError,
            'cpcNumber': cpcNumberValidationError,
            'cpcExpiry': cpcExpiryValidationError,
            'cpc_doc': _cpcfileValidationError,
            'tachoNumber': tachoNumberValidationError,
            'tachoExpiry': tachoExpiryValidationError,
            'tacho_doc': _tachofileValidationError,
          };
        });
        String errorMessage = responseData['message'] ?? 'Update failed';
        Utils.flushBarErrorMessage(errorMessage, context);
        //
        print(responseData);
      }
    } else {
      String errorMessage = responseData['message'] ?? 'Update failed';
      Utils.flushBarErrorMessage(errorMessage, context);
      setState(() {
        // isLoading = false;
      });
    }
  }

  void _updateProfile4() async {
    Utils.showDialogLoading(context);

    String _detailsOfMedicationError = '';
    String _medicationDetailsError = '';

    String _lastEyeError = '';

    String _reasonForDismissalMedicalReasonError = '';

    String _dismissalFromDrivingRolesError = '';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';
    final String apiUrl = '${AppUrl.baseUrl}/api/app/staff/profile/update/with/step';
    var request = https.MultipartRequest('POST', Uri.parse(apiUrl));
    request.headers.addAll({
      'Authorization': 'Bearer $_token',
      'Accept': 'application/json',
    });

    ///Section------------------------------------4
    request.fields['step'] = "4";
    request.fields['physical_incapabilities'] = _selected4 == 'Yes' ? '1' : '0';
    request.fields['ongoing_medical_conditions'] = _selected5 == 'Yes' ? '1' : '0';
    if (_selected5 == 'Yes') {
      request.fields['medical_condition_details'] = _detailMedicalConditionController.text;
    }
    request.fields['taking_medication'] = _selected6 == 'Yes' ? '1' : '0';
    if (_selected6 == 'Yes') {
      request.fields['medication_details'] = _detailOfMedicationController.text;
    }
    request.fields['drug_or_alcohol_issues'] = _selected7 == 'Yes' ? '1' : '0';
    request.fields['wears_glasses'] = _selected8 == 'Yes' ? '1' : '0';
    if (_lasteyeController.text.isNotEmpty) {
      try {
        DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(_lasteyeController.text);
        String formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
        request.fields['last_eye_test'] = formattedDate;
      } catch (e) {
        print('Invalid date format for licenceExpiry: ${_lasteyeController.text}');
      }
    }
    request.fields['dismissed_for_medical_reasons'] = _selected9 == 'Yes' ? '1' : '0';
    if (_selected9 == 'Yes') {
      request.fields['dismissal_reason'] = _reasonForDismissalController.text;
    }
    request.fields['dismissed_from_driving_roles'] = _selected10 == 'Yes' ? '1' : '0';
    if (_selected10 == 'Yes') {
      request.fields['driving_dismissal_details'] = _reasondatesForDrivingRolesController.text;
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final responseData = jsonDecode(responseBody);

    if (response.statusCode == 200) {
      print(response);
      print(responseData);
      String successMessage = responseData['message'] ?? 'Updated Successfully';

      Utils.flushBarSuccessMessage(successMessage, context);
      Future.delayed(Duration(seconds: 2), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StaffProfile(),
          ),
        );
      });
      print(responseData);
    } else if (response.statusCode == 422) {
      // Handle validation error response
      final Map<String, dynamic> responseData = jsonDecode(responseBody);
      Navigator.pop(context);
      if (responseData.containsKey('errors')) {
        final Map<String, dynamic> errors = responseData['errors'];
        errors.forEach((field, messages) {
          final String errorMessage = messages.isNotEmpty ? messages.first : 'Unknown error';
          switch (field) {
            ///Section------------------------------------1
            case 'medical_condition_details':
              _detailsOfMedicationError = errorMessage;
              break;
            case 'medication_details':
              _medicationDetailsError = errorMessage;
              break;
            case 'last_eye_test':
              _lastEyeError = errorMessage;
              break;
            case 'dismissal_reason':
              _reasonForDismissalMedicalReasonError = errorMessage;
              break;
            case 'driving_dismissal_details':
              _dismissalFromDrivingRolesError = errorMessage;
              break;
          }
        });

        setState(() {
          _validationErrors = {
            'medical_condition_details': _detailsOfMedicationError,
            'taking_medication': _medicationDetailsError,
            'medication_details': _medicationDetailsError,
            'last_eye_test': _lastEyeError,
            'dismissal_reason': _reasonForDismissalMedicalReasonError,
            'driving_dismissal_details': _dismissalFromDrivingRolesError,
          };
        });
        String errorMessage = responseData['message'] ?? 'Update failed';
        Utils.flushBarErrorMessage(errorMessage, context);
        //
        print(responseData);
      }
    } else {
      String errorMessage = responseData['message'] ?? 'Update failed';
      Utils.flushBarErrorMessage(errorMessage, context);
      setState(() {
        // isLoading = false;
      });
    }
  }

  void _updateProfile6() async {
    Utils.showDialogLoading(context);
    String _bankNameValidationError = '';
    String _accountNameValidationError = '';
    String _accountNumberValidationError = '';
    String _bankCodeValidationError = '';

    String _buildingRollNumberValidationError = '';

    String _recipientAddress1NumberValidationError = '';
    String _recipientAddress2NumberValidationError = '';
    String _recipientAddress3NumberValidationError = '';
    String _ibanValidationError = '';
    String _bicSwiftValidationError = '';
    String _paymentIsoValidationError = '';
    String _creditIsoValidationError = '';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';
    final String apiUrl = '${AppUrl.baseUrl}/api/app/staff/profile/update/with/step';
    var request = https.MultipartRequest('POST', Uri.parse(apiUrl));
    request.headers.addAll({
      'Authorization': 'Bearer $_token',
      'Accept': 'application/json',
    });

    request.fields['step'] = "5";
    request.fields['account_type'] = _selectedBankTypes ?? "";
    print(_selectedBankTypes);
    request.fields['bank_name'] = _bankNameController.text.toString();
    request.fields['account_name'] = _accountNameController.text.toString();
    if (_selectedBankTypes.trim().toUpperCase() == "BANK_ACCOUNT" || _selectedBankTypes == "BUILDING_SOCIETY") {
      request.fields['account_number'] = _accountNumberController.text.toString();
      request.fields['bank_code'] = _bankCodeController.text.toString();
    }
    if (_selectedBankTypes == "BUILDING_SOCIETY") {
      request.fields['building_society_roll_number'] = _buildingSocietyRollNumberController.text.toString();
    }
    if (_selectedBankTypes == "INTERNATIONAL_BANK_ACCOUNT") {
      request.fields['recipient_address1'] = _recipientAddress1Controller.text.toString();
      request.fields['recipient_address2'] = _recipientAddress2Controller.text.toString();
      request.fields['recipient_address3'] = _recipientAddress3Controller.text.toString();
      request.fields['iban'] = _ibanController.text.toString();
      request.fields['bic_swift'] = _bicSwiftCodeController.text.toString();
      request.fields['payment_iso_country_code'] = _paymentIsoCodeController.text.toString();
      request.fields['credit_iso_currency_code'] = _creditIsoCodeController.text.toString();
    }
    final response = await request.send();

    final responseBody = await response.stream.bytesToString();
    final responseData = jsonDecode(responseBody);

    if (response.statusCode == 200) {
      print(response);
      print(responseData);
      String successMessage = responseData['message'] ?? 'Updated Successfully';

      Utils.flushBarSuccessMessage(successMessage, context);
      Future.delayed(Duration(seconds: 2), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StaffProfile(),
          ),
        );
      });
      print(responseData);
    } else if (response.statusCode == 422) {
      // Handle validation error response
      final Map<String, dynamic> responseData = jsonDecode(responseBody);
      Navigator.pop(context);
      if (responseData.containsKey('errors')) {
        final Map<String, dynamic> errors = responseData['errors'];
        errors.forEach((field, messages) {
          final String errorMessage = messages.isNotEmpty ? messages.first : 'Unknown error';
          switch (field) {
            ///Section------------------------------------1
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
              _buildingRollNumberValidationError = errorMessage;
              break;

            case 'recipient_address1':
              _recipientAddress1NumberValidationError = errorMessage;
              break;
            case 'recipient_address2':
              _recipientAddress2NumberValidationError = errorMessage;
              break;
            case 'recipient_address3':
              _recipientAddress3NumberValidationError = errorMessage;
              break;
            case 'iban':
              _ibanValidationError = errorMessage;
              break;
            case 'bic_swift':
              _bicSwiftValidationError = errorMessage;
              break;
            case 'payment_iso_country_code':
              _paymentIsoValidationError = errorMessage;
              break;
            case 'credit_iso_currency_code':
              _creditIsoValidationError = errorMessage;
              break;
          }
        });

        setState(() {
          _validationErrors = {
            'bank_name': _bankNameValidationError,
            'account_name': _accountNameValidationError,
            'account_number': _accountNumberValidationError,
            'bank_code': _bankCodeValidationError,
            'building_society_roll_number': _buildingRollNumberValidationError,
            'recipient_address1': _recipientAddress1NumberValidationError,
            'recipient_address2': _recipientAddress2NumberValidationError,
            'recipient_address3': _recipientAddress3NumberValidationError,
            'iban': _ibanValidationError,
            'bic_swift': _bicSwiftValidationError,
            'payment_iso_country_code': _paymentIsoValidationError,
            'credit_iso_currency_code': _creditIsoValidationError,
          };
        });
        String errorMessage = responseData['message'] ?? 'Update failed';
        Utils.flushBarErrorMessage(errorMessage, context);
        //
        print(responseData);
      }
    } else {
      String errorMessage = responseData['message'] ?? 'Update failed';
      Utils.flushBarErrorMessage(errorMessage, context);
      setState(() {
        // isLoading = false;
      });
    }
  }

  Map<String, String> _validationErrors = {};

  ///Section--------------1
  bool showText = false;
  UniqueKey item1Key = UniqueKey();
  UniqueKey item2Key = UniqueKey();
  UniqueKey item3Key = UniqueKey();
  UniqueKey item4Key = UniqueKey();
  UniqueKey item5Key = UniqueKey();
  UniqueKey item6Key = UniqueKey();
  bool _isExpanded = false;
  bool _isEditing = false;
  Uint8List? _selectedImage;
  String? _selectedImageName;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _townCityController = TextEditingController();
  final TextEditingController _postCodeController = TextEditingController();
  final TextEditingController _address1Controller = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  String? _selectedGender;
  TextEditingController _ninController = TextEditingController();
  // String? _selectedMaratialStatus;
  String? _userName;

  Uint8List? _selectedProff;
  String? _selectedProffName;

  Uint8List? _selectedPassport;
  String? _selectedPassportName;

  ///Section------------------------2
  bool _isExpanded2 = false;
  bool _isEditing2 = false;
  String? _selectedOption2;
  TextEditingController _dbsExpiryController = TextEditingController();
  String? _selectedOption3;
  String? _selected11;
  String? _selected12;
  final TextEditingController pleaseSpecifyController = TextEditingController();
  String? _selected13;
  final TextEditingController _consultController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  ///Section-----------------------3
  bool _isExpanded3 = false;
  bool _isEditing3 = false;
  bool isDriverRole() {
    String roleText = _roleController.text.trim().toLowerCase();
    return roleText.contains('driver');
  }

  String? _selected2 = 'No';
  String? _selected1 = 'No';
  String? _selected15 = 'No';

  String? _selected16 = 'No';
  TextEditingController _licNumberController = TextEditingController();
  List<String> _selectedLicenseTypes = [];
  final List<String> _licenseTypes = ['classB', 'classC', 'classD', 'classD1', 'classE'];
  TextEditingController _licExpiryController = TextEditingController();
  TextEditingController _licEndorsementController = TextEditingController();
  TextEditingController _dateofIssueDrivingController = TextEditingController();
  TextEditingController _drivingLicensecategoryController = TextEditingController();
  TextEditingController _checkCodeDrivingLicenseController = TextEditingController();

  Uint8List? _selectedStaffFile;
  String? _selectedStaffFileName;

  Uint8List? _selectedCPC;
  String? _selectedCPCName;

  Uint8List? _selectedTacho;
  String? _selectedTachoName;

  String? _selected3 = 'No';

  TextEditingController _cpcNumberController = TextEditingController();
  TextEditingController _cpcExpiryController = TextEditingController();
  TextEditingController _tachoExpiryController = TextEditingController();
  TextEditingController _techoNumberController = TextEditingController();

  ///Section--------------4
  UniqueKey openitemKey1 = UniqueKey();
  bool _isVisionRequirementsExpanded = false;
  bool _isExpanded4 = false;
  bool _isEditing4 = false;

  String? _selected4;
  String? _selected5;
  TextEditingController _detailMedicalConditionController = TextEditingController();
  String? _selected6;
  TextEditingController _detailOfMedicationController = TextEditingController();
  String? _selected7;
  String? _selected8;
  TextEditingController _lasteyeController = TextEditingController();
  String? _selected9;
  TextEditingController _reasonForDismissalController = TextEditingController();
  String? _selected10;
  TextEditingController _reasondatesForDrivingRolesController = TextEditingController();
  Map<String, dynamic> _formData = {
    'physical_incapabilities': 0,
    'ongoing_medical_conditions': 0,
    'taking_medication': 0,
    'drug_or_alcohol_issues': 0,
    'wears_glasses': 0,
    'dismissed_for_medical_reasons': 0,
    'dismissed_from_driving_roles': 0,
  };

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: _showNoInternetConnectionMessage ? Colors.red : AppColors.navColor,
    ));

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StaffCurveNabBar()),
        );
        // Prevent default back navigation
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: RefreshIndicator(
            onRefresh: _refreshData,
            child: _showNoInternetConnectionMessage
                ? NoInternetConnection()
                : ResPonsiveUi(
                    mobile: body(),
                    desktop: body(),
                    tablet: body(),
                  ),
          ),
        ),
      ),
    );
  }

  Widget body() {
    final userPrefernece = Provider.of<UserViewModel>(context);
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;

    return SingleChildScrollView(
      child: FutureBuilder<ProfileApiModel?>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: screenHeight * 0.9,
              width: screenWidth,
              color: AppColors.whiteColor,
              child: LoadingScreen(),
            );
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return Text("${snapshot.error}");
          } else if (!snapshot.hasData) {
            return Center(child: Text('No user data found.'));
          } else {
            final ProfileApiModel profileData = snapshot.data!;
            final Data profile = profileData.data;
            dynamic peopleId = profileData.data.peopleId;
            final String? profilePick = profileData.data.image;
            return Column(
              children: [
                Container(
                  width: screenWidth,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.03,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2c3e50), Color(0xFF1a252f)], // Gradient colors
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StaffCurveNabBar(),
                                ),
                              );
                            },
                            child: Icon(
                              Icons.arrow_back,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Profile",
                            style: GoogleFonts.roboto(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Icon(
                            Icons.edit,
                            size: 28,
                            color: Colors.transparent,
                          )
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      GestureDetector(
                        onTap: () {
                          if (profilePick != null && profilePick.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenImageStaff(
                                  imageUrl: '${AppUrl.staffDriver}/$profilePick',
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          height: screenHeight * 0.15,
                          width: screenWidth * 0.3,
                          decoration: BoxDecoration(
                            color: Colors.grey[800], // Dark grey circle
                            shape: BoxShape.circle,
                            image: profilePick != null && profilePick.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage('${AppUrl.staffDriver}/$profilePick'),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: profilePick == null || profilePick.isEmpty
                              ? Icon(
                                  Icons.person,
                                  color: Colors.blueAccent,
                                  size: screenHeight * 0.08,
                                )
                              : null,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        "${profile.firstName ?? ""} ${profile.lastName ?? ""}",
                        style: GoogleFonts.roboto(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        "${profile.email}",
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[400],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.02,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically in the center
                              children: [
                                // Profile Information Text
                                Text(
                                  "Account Overview",
                                  style: GoogleFonts.roboto(
                                    textStyle: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white, // Added for better contrast
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FileUploadStaff(),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(8), // Rounded corners for the tap area
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent.withOpacity(0.1), // Subtle background color
                                      borderRadius: BorderRadius.circular(8), // Rounded corners
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.upload_file,
                                          color: Colors.blueAccent,
                                          size: 20, // Adjusted icon size
                                        ),
                                        SizedBox(width: 8), // Reduced spacing
                                        Text(
                                          "Upload File",
                                          style: GoogleFonts.roboto(
                                            textStyle: TextStyle(
                                              fontSize: 14, // Slightly smaller font size
                                              fontWeight: FontWeight.w600, // Bold for emphasis
                                              color: Colors.blueAccent,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      ///Section------------------------1
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF2c3e50), Color(0xFF1a252f)], // Gradient colors
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF2C3E50), Color(0xFF1A252F)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                              ),
                              child: ExpansionTile(
                                key: item1Key,
                                initiallyExpanded: _isExpanded,
                                onExpansionChanged: (expanded) {
                                  setState(() {
                                    _isExpanded = expanded;
                                    _isEditing = false;
                                    _isEditing2 = false;
                                    _isEditing3 = false;
                                    _isEditing4 = false;
                                    _isEditing6 = false;
                                    // if (expanded) {
                                    // item2Key = UniqueKey();
                                    // item3Key = UniqueKey();
                                    // item4Key = UniqueKey();
                                    // item5Key = UniqueKey();
                                    // }
                                  });
                                },
                                iconColor: AppColors.navColor,
                                collapsedIconColor: Colors.white,
                                backgroundColor: Colors.white,
                                textColor: AppColors.navButtonColor,
                                collapsedTextColor: Colors.white,
                                tilePadding: EdgeInsets.only(left: 10),
                                minTileHeight: screenHeight * 0.06,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                                ),
                                collapsedShape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(screenWidth * 0.12),
                                ),
                                title: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.person_outline),
                                    SizedBox(width: screenWidth * 0.03),
                                    Text(
                                      "Personal Information",
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.042,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: _isExpanded
                                            ? InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _isEditing = true;
                                                  });
                                                },
                                                child: Icon(
                                                  Icons.edit,
                                                  size: 20,
                                                  color: AppColors.navColor,
                                                ),
                                              )
                                            : SizedBox.shrink(),
                                      ),
                                    ),
                                  ],
                                ),
                                children: [
                                  Container(
                                    margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.02),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: Offset(0, 4),
                                        ),
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          spreadRadius: 2,
                                          blurRadius: 10,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(screenWidth * 0.04),
                                      child: Column(
                                        children: [
                                          _buildEditableRow(
                                            "First Name",
                                            _firstNameController,
                                            keyboardType: TextInputType.name,
                                            hintText: "Enter your first name",
                                            isEditable: _isEditing,
                                            errorMessage: _validationErrors['first_name'],
                                          ),
                                          Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                          _buildEditableRow("Last Name", _lastNameameController, isEditable: _isEditing, errorMessage: _validationErrors['last_name']),
                                          Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                          _buildEditableRow("Email", _emailController, isEditable: false),
                                          Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                          _buildEditableRow("Phone", _phoneController, isEditable: _isEditing, errorMessage: _validationErrors['phone']),
                                          Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                          _buildEditableRow("Town/City", _townCityController, isEditable: _isEditing, errorMessage: _validationErrors['city']),
                                          Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                          _buildEditableRow("Post Code", _postCodeController, isEditable: _isEditing, errorMessage: _validationErrors['postCode']),
                                          Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                          _buildEditableRow("Address 1", _address1Controller, isEditable: _isEditing, errorMessage: _validationErrors['addressLine1']),
                                          Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                          _buildEditableRow("Address 2", _address2Controller, isEditable: _isEditing, errorMessage: _validationErrors['addressLine2']),
                                          Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                          // Gender dropdown when in edit mode
                                          _isEditing
                                              ? _buildDropdownRow(
                                                  "Gender",
                                                  _selectedGender,
                                                  [
                                                    "Male",
                                                    "Female",
                                                  ],
                                                  (value) {
                                                    setState(() {
                                                      _selectedGender = value;
                                                    });
                                                  },
                                                )
                                              : _buildEditableRow("Gender", TextEditingController(text: _selectedGender), isEditable: false),
                                          Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),

                                          _isEditing
                                              ? _buildDropdownRow(
                                                  "Marital Status",
                                                  maritalStatusMapping[_selectedMaratialStatus] ?? "Single", // Display UI label
                                                  maritalStatusMapping.values.toList(), // Pass labels to the dropdown
                                                  (value) {
                                                    setState(() {
                                                      // Find the corresponding API value for the selected label
                                                      _selectedMaratialStatus = maritalStatusMapping.entries.firstWhere((entry) => entry.value == value).key;
                                                    });
                                                  },
                                                )
                                              : _buildEditableRow(
                                                  "Marital Status",
                                                  TextEditingController(text: maritalStatusMapping[_selectedMaratialStatus] ?? "Single"), // Display UI label
                                                  isEditable: false,
                                                ),
                                          Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                          // User Name is displayed as text, not editable
                                          _buildEditableRow("User Name", TextEditingController(text: _userName), isEditable: false),
                                          Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                          _isEditing
                                              ? ProfileImagePicker(
                                                  onTap: () {
                                                    _pickImage(ImageSource.gallery);
                                                  },
                                                  hintText: "Change Profile",
                                                  selectedImageName: _selectedImageName,
                                                  screenHeight: screenHeight,
                                                  screenWidth: screenWidth,
                                                  navOpacity: Colors.grey.withOpacity(0.2),
                                                  navButtonColor: Colors.blue,
                                                  blackColor: Colors.black,
                                                )
                                              : ViewProfile(
                                                  onTap: () {
                                                    if (profilePick != null && profilePick.isNotEmpty) {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => FullScreenImageStaff(
                                                            imageUrl: '${AppUrl.staffDriver}/$profilePick',
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  label: "Profile Image",
                                                  profilePick: profilePick, // Replace with actual URL or null
                                                  screenHeight: screenHeight,
                                                  screenWidth: screenWidth,
                                                ),

                                          if (_isEditing) ...[
                                            Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                            FilePickerWidgetV2(
                                              title: "Upload Passport",
                                              screenWidth: screenWidth,
                                              screenHeight: screenHeight,
                                              onFilePicked: (Uint8List? fileData, String? fileName) {
                                                setState(() {
                                                  _selectedPassport = fileData;
                                                  _selectedPassportName = fileName;
                                                  setState(() {});
                                                });
                                              },
                                              selectedFileName: _selectedPassportName,
                                            ),
                                            Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                          ],
                                          if (_isEditing) ...[
                                            FilePickerWidgetV2(
                                              title: "Upload Proof of Address",
                                              screenWidth: screenWidth,
                                              screenHeight: screenHeight,
                                              onFilePicked: (Uint8List? fileData, String? fileName) {
                                                setState(() {
                                                  _selectedProff = fileData;
                                                  _selectedProffName = fileName;
                                                  setState(() {});
                                                });
                                              },
                                              selectedFileName: _selectedProffName,
                                            ),
                                          ],
                                          // Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                          if (_isEditing) ...[
                                            SizedBox(
                                              height: screenHeight * 0.023,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                // setState(() {
                                                //   _isEditing ==false;
                                                // });
                                                _updateProfile();
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
                                                    "UPDATE",
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
                                          ]
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.grey[300],
                        thickness: 0.2,
                        height: screenHeight * 0.002,
                      ),

                      ///Section------------------------2
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF2C3E50), Color(0xFF1A252F)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          // borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        ),
                        child: ExpansionTile(
                          key: item2Key,
                          onExpansionChanged: (expanded) {
                            setState(() {
                              _isExpanded2 = expanded;
                              print(_isExpanded2);
                              _isEditing = false;
                              _isEditing2 = false;
                              _isEditing3 = false;
                              _isEditing4 = false;
                              _isEditing6 = false;
                              // if (expanded) {
                              //   item1Key = UniqueKey();
                              //   item3Key = UniqueKey();
                              //   item4Key = UniqueKey();
                              //   item5Key = UniqueKey();
                              // }
                            });
                          },
                          tilePadding: EdgeInsets.only(left: 10),
                          iconColor: AppColors.navButtonColor,
                          collapsedIconColor: Colors.white,
                          backgroundColor: Colors.white,
                          textColor: AppColors.navButtonColor,
                          collapsedTextColor: Colors.white,
                          minTileHeight: screenHeight * 0.06,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                          ),
                          collapsedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.12),
                          ),
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.work_outline,
                              ),
                              SizedBox(width: screenWidth * 0.03),
                              Text("Employment & Eligibility",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.042,
                                    fontWeight: FontWeight.w500,
                                  )),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: _isExpanded2
                                      ? InkWell(
                                          onTap: () {
                                            setState(() {
                                              _isEditing2 = true;
                                            });
                                          },
                                          child: Icon(
                                            Icons.edit,
                                            size: 20,
                                            color: AppColors.navColor,
                                          ),
                                        )
                                      : SizedBox.shrink(),
                                ),
                              ),
                            ],
                          ),
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.02),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(screenWidth * 0.04),
                                child: Column(
                                  children: [
                                    _buildEditableRow("Agency Consultant", _consultController, isEditable: false),
                                    Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                    _yesNoDropdownRow(
                                      "Are you a citizen of the UK?",
                                      _selected11, // Assuming you will get 0 or 1 from API
                                      ['Yes', 'No'],
                                      (value) {
                                        setState(() {
                                          _selected11 = value;
                                        });
                                      },
                                      _isEditing2,
                                    ),
                                    Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                    _yesNoDropdownRow(
                                      "Do you have any unspent criminal convictions?",
                                      _selected12, // Assuming you will get 0 or 1 from API
                                      ['Yes', 'No'],
                                      (value) {
                                        setState(() {
                                          _selected12 = value;
                                        });
                                      },
                                      _isEditing2,
                                    ),
                                    if (_selected12 == "Yes") ...[
                                      Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                      _buildEditableRow(
                                        "If yes, please specify:",
                                        pleaseSpecifyController,
                                        isEditable: _isEditing2,
                                        errorMessage: _validationErrors['unspent_criminal_convictions_details'],
                                      ),
                                    ],
                                    Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                    _yesNoDropdownRow(
                                      "Do you have a Right to Work in the UK?",
                                      _selected13, // Assuming you will get 0 or 1 from API
                                      ['Yes', 'No'],
                                      (value) {
                                        setState(() {
                                          _selected13 = value;
                                        });
                                      },
                                      _isEditing2,
                                    ),
                                    Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                    _yesNoDropdownRow(
                                      "Do you have a DBS or EDBS (if applicable for your role)?",
                                      _selectedOption2, // Assuming you will get 0 or 1 from API
                                      ['Yes', 'No'],
                                      (value) {
                                        setState(() {
                                          _selectedOption2 = value;
                                        });
                                      },
                                      _isEditing2,
                                    ),
                                    if (_selectedOption2 == "Yes") ...[
                                      Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                      _isEditing2
                                          ? dateCalenderContainer(
                                              controller: _dbsExpiryController,
                                              labelText: "DBS Expiry",
                                              keyboardType: TextInputType.name,
                                              errorMessage: _validationErrors['dbsExpiry'],
                                            )
                                          : Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    "DBS Expiry",
                                                    style: TextStyle(
                                                      fontSize: screenWidth * 0.04,
                                                      fontWeight: FontWeight.w400,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  _dbsExpiryController.text,
                                                  textAlign: TextAlign.right,
                                                  style: GoogleFonts.openSans(
                                                    textStyle: TextStyle(fontSize: 15),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            )
                                    ],
                                    Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                    _yesNoDropdownRow(
                                      "Do you want to opt out of the Pension Scheme?",
                                      _selectedOption3, // This should correctly reflect 'Yes' or 'No'
                                      ['Yes', 'No'],
                                      (value) {
                                        setState(() {
                                          // Update value for _selectedOption3 based on the dropdown selection
                                          _selectedOption3 = value;
                                        });
                                      },
                                      _isEditing2,
                                    ),
                                    if (_isEditing2) ...[
                                      SizedBox(
                                        height: screenHeight * 0.023,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          // setState(() {
                                          //   _isEditing2 ==false;
                                          // });
                                          _updateProfile2();
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
                                              "UPDATE",
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
                                    ]
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),

                      ///Section------------------------3
                      if (isDriverRole()) ...[
                        Divider(
                          color: Colors.grey[300],
                          thickness: 0.2,
                          height: screenHeight * 0.002,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF2C3E50), Color(0xFF1A252F)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                          ),
                          child: ExpansionTile(
                            key: item3Key,
                            initiallyExpanded: _isExpanded3,
                            onExpansionChanged: (expanded) {
                              // if (expanded == true) {
                              //   setState(() {});
                              // }

                              setState(() {
                                _isExpanded3 = expanded;
                                print(_isExpanded3);

                                _isEditing = false;
                                _isEditing2 = false;
                                _isEditing3 = false;
                                _isEditing4 = false;
                                _isEditing6 = false;
                              });
                            },
                            iconColor: AppColors.navButtonColor,
                            collapsedIconColor: Colors.white,
                            backgroundColor: Colors.white,
                            textColor: AppColors.navButtonColor,
                            collapsedTextColor: Colors.white,
                            tilePadding: EdgeInsets.only(left: 10),
                            minTileHeight: screenHeight * 0.06,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(screenWidth * 0.03),
                            ),
                            collapsedShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(screenWidth * 0.12),
                            ),
                            // title: Padding(
                            //   padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                            //   child:,
                            // ),
                            title: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.directions_car),
                                SizedBox(width: screenWidth * 0.03),
                                Text(
                                  "Driving Qualifications",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.042,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: _isExpanded3
                                        ? InkWell(
                                            onTap: () {
                                              setState(() {
                                                _isEditing3 = true;
                                              });
                                            },
                                            child: Icon(
                                              Icons.edit,
                                              size: 20,
                                              color: AppColors.navColor,
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                  ),
                                ),
                              ],
                            ),
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.02),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(screenWidth * 0.04),
                                  child: Column(
                                    children: [
                                      SizedBox(height: 5),
                                      // Subtle divider
                                      // _buildEditableRow("Role", _roleController, isEditable: false),
                                      // Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),

                                      _yesNoDropdownRow(
                                        "Do you hold a valid UK driving licence?",
                                        _selected2,
                                        ['Yes', 'No'],
                                        (value) {
                                          setState(() {
                                            _selected2 = value;
                                          });
                                        },
                                        _isEditing3,
                                      ),

                                      Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                      if (_selected2 == 'Yes') ...[
                                        _yesNoDropdownRow(
                                          "Do you have UK driving experience?",
                                          _selected1,
                                          ['Yes', 'No'],
                                          (value) {
                                            setState(() {
                                              _selected1 = value;
                                            });
                                          },
                                          _isEditing3,
                                        ),
                                        Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                      ],
                                      if (_selected2 == 'Yes' && _selected1 == 'Yes') ...[
                                        _buildEditableRow(
                                          "licence Number",
                                          _licNumberController,
                                          isEditable: _isEditing3,
                                          errorMessage: _validationErrors['licenceNumber'],
                                        ),
                                        Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                      ],
                                      if (_selected2 == 'Yes' && _selected1 == 'Yes' && _licNumberController.text.isNotEmpty) ...[
                                        _isEditing3
                                            ? dateCalenderContainer(
                                                controller: _licExpiryController,
                                                labelText: "licence Expiry",
                                                keyboardType: TextInputType.name,
                                                errorMessage: _validationErrors['licenceExpiry'],
                                              )
                                            : Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      "licence Expiry",
                                                      style: TextStyle(
                                                        fontSize: screenWidth * 0.04,
                                                        fontWeight: FontWeight.w400,
                                                        color: Colors.grey[700],
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    _licExpiryController.text,
                                                    textAlign: TextAlign.right,
                                                    style: GoogleFonts.openSans(
                                                      textStyle: TextStyle(fontSize: 15),
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),

                                        _buildEditableRow(
                                          "licence Endorsements",
                                          _licEndorsementController,
                                          isEditable: _isEditing3,
                                          errorMessage: _validationErrors['licence_endorsement'],
                                        ),
                                        Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),

                                        _isEditing3
                                            ? dateCalenderContainer(
                                                controller: _dateofIssueDrivingController,
                                                labelText: "Date of issue of the driving licence.",
                                                keyboardType: TextInputType.name,
                                                errorMessage: _validationErrors['driving_license_issue_date'],
                                              )
                                            : Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      "Date of issue of the driving licence.",
                                                      style: TextStyle(
                                                        fontSize: screenWidth * 0.04,
                                                        fontWeight: FontWeight.w400,
                                                        color: Colors.grey[700],
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                      _dateofIssueDrivingController.text,
                                                      textAlign: TextAlign.right,
                                                      style: GoogleFonts.openSans(
                                                        textStyle: TextStyle(fontSize: 15),
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),

                                        _buildEditableRow(
                                          "Driving licence category",
                                          _drivingLicensecategoryController,
                                          isEditable: _isEditing3,
                                          errorMessage: _validationErrors['driving_license_category'],
                                        ),
                                        Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),

                                        // Subtle divider
                                        _buildEditableRow("Check code for driving licence.", _checkCodeDrivingLicenseController,
                                            isEditable: _isEditing3, errorMessage: _validationErrors['driving_license_check_code']),
                                        Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                        _isEditing3
                                            ? LicenseSelectedList(
                                                selectedLicenses: _selectedLicenseTypes,
                                                onSelectionChanged: (newSelectedLicenses) {
                                                  setState(() {
                                                    _selectedLicenseTypes = newSelectedLicenses;
                                                  });
                                                },
                                                errorMessage: _validationErrors['licenceTypes'])
                                            : Container(
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      // crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                            "Licence Types",
                                                            style: TextStyle(
                                                              fontSize: screenWidth * 0.04,
                                                              fontWeight: FontWeight.w400,
                                                              color: Colors.grey[700],
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Align(
                                                            alignment: Alignment.centerRight,
                                                            child: Container(
                                                              // padding: EdgeInsets.symmetric(horizontal: 5),
                                                              child: Wrap(
                                                                spacing: 10.0,
                                                                runSpacing: 2.0,
                                                                children: _selectedLicenseTypes.map((license) {
                                                                  return Chip(
                                                                    label: Text(
                                                                      camelCaseToWords(license),
                                                                      style: TextStyle(
                                                                        fontSize: screenWidth * 0.038,
                                                                        color: AppColors.navButtonColor,
                                                                      ),
                                                                    ),
                                                                    backgroundColor: Color(0xffF2F5F6),
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                                                                      side: BorderSide(
                                                                        color: Color(0xffEAECED),
                                                                        width: 0.4,
                                                                      ),
                                                                    ),
                                                                  );
                                                                }).toList(),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),

                                        Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),

                                        if (_isEditing3) ...[
                                          FilePickerWidgetV2(
                                              title: "Upload Driving Licence",
                                              screenWidth: screenWidth,
                                              screenHeight: screenHeight,
                                              onFilePicked: (Uint8List? fileData, String? fileName) {
                                                setState(() {
                                                  _selectedStaffFile = fileData;
                                                  _selectedStaffFileName = fileName;
                                                });
                                              },
                                              selectedFileName: _selectedStaffFileName,
                                              errorMessage: _validationErrors['driving_licence_doc']),
                                          Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                        ],

                                        _yesNoDropdownRow(
                                          "Do you have penalty points on your licence?",
                                          _selected3,
                                          ['Yes', 'No'], // The dropdown options
                                          (value) {
                                            setState(() {
                                              _selected1 = value; // Update the selected value
                                            });
                                          },
                                          _isEditing3,
                                        ),
                                        Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                      ],

                                      // noCpcCard
                                      // noTachoCard
                                      _yesNoDropdownRow(
                                        "Are you a valid CPC holder?",
                                        _selected15, // The current selected value
                                        ['Yes', 'No'], // The dropdown options
                                        (value) {
                                          setState(() {
                                            _selected15 = value; // Update the selected value
                                            print("User selected: $_selected15");
                                          });
                                        },
                                        _isEditing3, // Whether the dropdown is editable
                                      ),

                                      Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),

                                      if (_selected15 == "Yes") ...[
                                        _buildEditableRow("CPC Number", _cpcNumberController, isEditable: _isEditing3, errorMessage: _validationErrors['cpcNumber']),
                                        Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                        _isEditing3
                                            ? dateCalenderContainer(
                                                controller: _cpcExpiryController, labelText: "CPC Expiry", keyboardType: TextInputType.name, errorMessage: _validationErrors['cpcExpiry'])
                                            : Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      "CPC Expiry",
                                                      style: TextStyle(
                                                        fontSize: screenWidth * 0.04,
                                                        fontWeight: FontWeight.w400,
                                                        color: Colors.grey[700],
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                      "${_cpcExpiryController.text}",
                                                      textAlign: TextAlign.right,
                                                      style: GoogleFonts.openSans(
                                                        textStyle: TextStyle(fontSize: 15),
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                        if (_isEditing3) ...[
                                          FilePickerWidgetV2(
                                              title: "Upload CPC",
                                              screenWidth: screenWidth,
                                              screenHeight: screenHeight,
                                              onFilePicked: (Uint8List? fileData, String? fileName) {
                                                setState(() {
                                                  _selectedCPC = fileData;
                                                  _selectedCPCName = fileName;
                                                });
                                              },
                                              selectedFileName: _selectedCPCName,
                                              errorMessage: _validationErrors['cpc_doc']),
                                        ],
                                        Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                      ],

                                      _yesNoDropdownRow(
                                        "Are you a valid TACHO holder?",
                                        _selected16,
                                        ['Yes', 'No'],
                                        (value) {
                                          setState(() {
                                            _selected16 = value;
                                          });
                                        },
                                        _isEditing3,
                                      ),
                                      if (_selected16 == "Yes") ...[
                                        Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                        _buildEditableRow("Tacho Number", _techoNumberController, isEditable: _isEditing3, errorMessage: _validationErrors['tachoNumber']),
                                        Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                        _isEditing3
                                            ? dateCalenderContainer(
                                                controller: _tachoExpiryController, labelText: "Tacho Expiry", keyboardType: TextInputType.name, errorMessage: _validationErrors['tachoExpiry'])
                                            : Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      "Tacho Expiry",
                                                      style: TextStyle(
                                                        fontSize: screenWidth * 0.04,
                                                        fontWeight: FontWeight.w400,
                                                        color: Colors.grey[700],
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                      "${_tachoExpiryController.text}",
                                                      textAlign: TextAlign.right,
                                                      style: GoogleFonts.openSans(
                                                        textStyle: TextStyle(fontSize: 15),
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        if (_isEditing3) ...[
                                          Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                          FilePickerWidgetV2(
                                              title: "Upload Tacho",
                                              screenWidth: screenWidth,
                                              screenHeight: screenHeight,
                                              onFilePicked: (Uint8List? fileData, String? fileName) {
                                                setState(() {
                                                  _selectedTacho = fileData;
                                                  _selectedTachoName = fileName;
                                                });
                                              },
                                              selectedFileName: _selectedTachoName,
                                              errorMessage: _validationErrors['tacho_doc']),
                                        ],
                                      ],

                                      if (_isEditing3) ...[
                                        SizedBox(
                                          height: screenHeight * 0.023,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            // setState(() {
                                            //   _isEditing3 ==false;
                                            // });
                                            _updateProfile3();
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
                                                "UPDATE",
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
                                      ]
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      Divider(
                        color: Colors.grey[300],
                        thickness: 0.2,
                        height: screenHeight * 0.002,
                      ),

                      ///Section------------------------4
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF2C3E50), Color(0xFF1A252F)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        ),
                        child: ExpansionTile(
                          key: item4Key,
                          onExpansionChanged: (expanded) {
                            setState(() {
                              _isExpanded4 = expanded;
                              _isVisionRequirementsExpanded = true;
                              _isEditing = false;
                              _isEditing2 = false;
                              _isEditing3 = false;
                              _isEditing4 = false;
                              _isEditing6 = false;
                              print(_isExpanded4);
                              // if (expanded) {
                              //   item1Key = UniqueKey();
                              //   item2Key = UniqueKey();
                              //   item3Key = UniqueKey();
                              //   item5Key = UniqueKey();
                              //   // openitemKey1 = UniqueKey();
                              // }
                            });
                          },
                          iconColor: AppColors.navButtonColor,
                          collapsedIconColor: Colors.white,
                          backgroundColor: Colors.white,
                          textColor: AppColors.navButtonColor,
                          collapsedTextColor: Colors.white,
                          tilePadding: EdgeInsets.only(left: 10),
                          minTileHeight: screenHeight * 0.06,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                          ),
                          collapsedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.12),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                Icons.medical_information_outlined,
                              ),
                              SizedBox(width: screenWidth * 0.03),
                              Text("Medical & Fitness",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.042,
                                    fontWeight: FontWeight.w500,
                                  )),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: _isExpanded4
                                      ? InkWell(
                                          onTap: () {
                                            setState(() {
                                              _isEditing4 = true;
                                            });
                                          },
                                          child: Icon(
                                            Icons.edit,
                                            size: 20,
                                            color: AppColors.navColor,
                                          ),
                                        )
                                      : SizedBox.shrink(),
                                ),
                              ),
                            ],
                          ),
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.02),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(screenWidth * 0.04),
                                child: Column(
                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _yesNoDropdownRow(
                                      "Do you have any physical incapabilities?",
                                      _selected4,
                                      ['Yes', 'No'],
                                      (value) {
                                        setState(() {
                                          _selected4 = value;
                                        });
                                      },
                                      _isEditing4,
                                    ),
                                    Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                    _yesNoDropdownRow(
                                      "Do you have any ongoing medical conditions?",
                                      _selected5,
                                      ['Yes', 'No'],
                                      (value) {
                                        setState(() {
                                          _selected5 = value;
                                        });
                                      },
                                      _isEditing4,
                                    ),
                                    if (_selected5 == 'Yes') ...[
                                      Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                      _buildEditableRow(
                                        "Details of medical conditions, if any.",
                                        _detailMedicalConditionController,
                                        keyboardType: TextInputType.name,
                                        isEditable: _isEditing4,
                                        errorMessage: _validationErrors['medical_condition_details'],
                                      ),
                                    ],
                                    Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                    _yesNoDropdownRow(
                                      "Are you currently taking any medication?",
                                      _selected6,
                                      ['Yes', 'No'],
                                      (value) {
                                        setState(() {
                                          _selected6 = value;
                                        });
                                      },
                                      _isEditing4,
                                    ),
                                    if (_selected6 == 'Yes') ...[
                                      Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                      _buildEditableRow(
                                        "Details of medication, if any.",
                                        _detailOfMedicationController,
                                        keyboardType: TextInputType.name,
                                        isEditable: _isEditing4,
                                        errorMessage: _validationErrors['medication_details'],
                                      ),
                                    ],
                                    Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                    _yesNoDropdownRow(
                                      "Do you have ongoing issues with drugs or alcohol?",
                                      _selected7,
                                      ['Yes', 'No'],
                                      (value) {
                                        setState(() {
                                          _selected7 = value;
                                        });
                                      },
                                      _isEditing4,
                                    ),
                                    Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Color(0xFF2C3E50), Color(0xFF1A252F)],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                                      ),
                                      child: ExpansionTile(
                                        key: openitemKey1,
                                        initiallyExpanded: _isVisionRequirementsExpanded, // Use the state variable
                                        onExpansionChanged: (expanded) {
                                          setState(() {
                                            _isVisionRequirementsExpanded = expanded; // Update the state when expanded/collapsed
                                          });
                                        },
                                        iconColor: AppColors.navButtonColor,
                                        collapsedIconColor: Colors.white,
                                        backgroundColor: Colors.white,
                                        textColor: AppColors.navButtonColor,
                                        collapsedTextColor: Colors.white,
                                        tilePadding: EdgeInsets.zero,
                                        minTileHeight: screenHeight * 0.03,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(screenWidth * 0.03),
                                        ),
                                        collapsedShape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(screenWidth * 0.12),
                                        ),
                                        title: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                                          child: Row(children: [
                                            Icon(
                                              Icons.visibility_outlined,
                                            ), // Cleaner icon
                                            SizedBox(width: 12),
                                            Text(
                                              "Vision Requirements",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            )
                                          ]),
                                        ),
                                        children: [
                                          Divider(thickness: 1, color: Colors.grey[300]),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                                            child: Column(
                                              children: [
                                                _yesNoDropdownRow(
                                                  "Do you currently wear glasses?",
                                                  _selected8,
                                                  ['Yes', 'No'],
                                                  (value) {
                                                    setState(() {
                                                      _selected8 = value;
                                                    });
                                                  },
                                                  _isEditing4,
                                                ),
                                                Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
                                                _isEditing4
                                                    ? dateCalenderContainer(
                                                        controller: _lasteyeController,
                                                        labelText: "When was your last eye test?",
                                                        keyboardType: TextInputType.name,
                                                        errorMessage: _validationErrors['last_eye_test'],
                                                      )
                                                    : Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            flex: 2,
                                                            child: Text(
                                                              "When was your last eye test?",
                                                              style: TextStyle(
                                                                fontSize: screenWidth * 0.04,
                                                                fontWeight: FontWeight.w400,
                                                                color: Colors.grey[700],
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 3,
                                                            child: Text(
                                                              "${_lasteyeController.text}",
                                                              textAlign: TextAlign.right,
                                                              style: GoogleFonts.openSans(
                                                                textStyle: TextStyle(fontSize: 15),
                                                                fontWeight: FontWeight.w500,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                SizedBox(
                                                  height: screenHeight * 0.013,
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                    _yesNoDropdownRow(
                                      "Have you ever been dismissed for medical reasons?",
                                      _selected9,
                                      ['Yes', 'No'],
                                      (value) {
                                        setState(() {
                                          _selected9 = value;
                                        });
                                      },
                                      _isEditing4,
                                    ),
                                    if (_selected9 == 'Yes') ...[
                                      Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                      _buildEditableRow("Reason for dismissal due to medical reasons.", _reasonForDismissalController,
                                          keyboardType: TextInputType.name, errorMessage: _validationErrors['dismissal_reason'], isEditable: _isEditing4),
                                    ],
                                    Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                    _yesNoDropdownRow(
                                      "Have you been dismissed from previous driving roles in the last 3 years?",
                                      _selected10,
                                      ['Yes', 'No'],
                                      (value) {
                                        setState(() {
                                          _selected10 = value;
                                        });
                                      },
                                      _isEditing4,
                                    ),
                                    if (_selected10 == 'Yes') ...[
                                      Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                      _buildEditableRow("Reasons/dates for dismissal from driving roles.", _reasondatesForDrivingRolesController,
                                          keyboardType: TextInputType.name, errorMessage: _validationErrors['driving_dismissal_details'], isEditable: _isEditing4),
                                      Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                    ],
                                    // Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                    if (_isEditing4) ...[
                                      SizedBox(
                                        height: screenHeight * 0.023,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          // setState(() {
                                          //   _isEditing ==false;
                                          // });
                                          _updateProfile4();
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
                                              "UPDATE",
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
                                    ]
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.grey[300],
                        thickness: 0.2,
                        height: screenHeight * 0.002,
                      ),

                      //     ///Section-------------------------5
                      //
                      //     Container(
                      //   decoration: BoxDecoration(
                      //   gradient: LinearGradient(
                      //     colors: [Color(0xFF2C3E50), Color(0xFF1A252F)],
                      //     begin: Alignment.centerLeft,
                      //     end: Alignment.centerRight,
                      //   ),
                      //   borderRadius: BorderRadius.circular(screenWidth * 0.03),
                      // ),
                      //       child: ExpansionTile(
                      //         key: item5Key,
                      //         onExpansionChanged: (expanded) {
                      //
                      //           setState(() {
                      //             _isEditing = false;
                      //             _isEditing2 = false;
                      //             _isEditing3 = false;
                      //             _isEditing4 = false;
                      //             // if (expanded == true) {
                      //             // item1Key = UniqueKey();
                      //             // item2Key = UniqueKey();
                      //             // item3Key = UniqueKey();
                      //             // item4Key = UniqueKey();}
                      //           });
                      //
                      //         },
                      //         iconColor: AppColors.navButtonColor,
                      //         collapsedIconColor: Colors.white,
                      //         backgroundColor: Colors.white,
                      //         textColor: AppColors.navButtonColor,
                      //         collapsedTextColor: Colors.white,
                      //         tilePadding: EdgeInsets.only(left: 10),
                      //         minTileHeight: screenHeight * 0.06,
                      //         shape: RoundedRectangleBorder(
                      //           borderRadius: BorderRadius.circular(screenWidth * 0.03),
                      //         ),
                      //         collapsedShape: RoundedRectangleBorder(
                      //           borderRadius: BorderRadius.circular(screenWidth * 0.12),
                      //         ),
                      //         title: Row(
                      //           crossAxisAlignment: CrossAxisAlignment.center,
                      //           children: [
                      //             Icon(
                      //               Icons.account_balance_outlined,
                      //             ),
                      //             SizedBox(width: screenWidth * 0.03),
                      //             Text("Banking Information",
                      //                 style: TextStyle(
                      //                   fontSize: screenWidth * 0.042,
                      //                   fontWeight: FontWeight.w500,
                      //                 )),
                      //           ],
                      //         ),
                      //         children: [
                      //           Container(
                      //             margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.02),
                      //             decoration: BoxDecoration(
                      //               color: Colors.white,
                      //               borderRadius: BorderRadius.circular(screenWidth * 0.03),
                      //               boxShadow: [
                      //                 BoxShadow(
                      //                   color: Colors.black.withOpacity(0.1),
                      //                   blurRadius: 8,
                      //                   offset: Offset(0, 4),
                      //                 ),
                      //                 BoxShadow(
                      //                   color: Colors.black.withOpacity(0.1),
                      //                   spreadRadius: 2,
                      //                   blurRadius: 10,
                      //                   offset: Offset(0, 4),
                      //                 ),
                      //               ],
                      //             ),
                      //             child: Padding(
                      //               padding: EdgeInsets.all(screenWidth * 0.04),
                      //               child: Column(
                      //                 crossAxisAlignment: CrossAxisAlignment.start,
                      //                 children: [
                      //                   ..._buildBankDetailsWidgets(profile),
                      //                 ],
                      //               ),
                      //             ),
                      //           )
                      //         ],
                      //       ),
                      //     ),

                      ///Section-------------------------5
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF2C3E50), Color(0xFF1A252F)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        ),
                        child: ExpansionTile(
                          key: item5Key,
                          onExpansionChanged: (expanded) {
                            setState(() {
                              _isExpanded6 = expanded;
                              _isEditing = false;
                              _isEditing2 = false;
                              _isEditing3 = false;
                              _isEditing4 = false;
                              _isEditing6 = false;
                              // if (expanded == true) {
                              // item1Key = UniqueKey();
                              // item2Key = UniqueKey();
                              // item3Key = UniqueKey();
                              // item4Key = UniqueKey();}
                            });
                          },
                          iconColor: AppColors.navButtonColor,
                          collapsedIconColor: Colors.white,
                          backgroundColor: Colors.white,
                          textColor: AppColors.navButtonColor,
                          collapsedTextColor: Colors.white,
                          tilePadding: EdgeInsets.only(left: 10),
                          minTileHeight: screenHeight * 0.06,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                          ),
                          collapsedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.12),
                          ),
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.account_balance_outlined,
                              ),
                              SizedBox(width: screenWidth * 0.03),
                              Text("Banking Information",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.042,
                                    fontWeight: FontWeight.w500,
                                  )),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: _isExpanded6
                                      ? InkWell(
                                          onTap: () {
                                            setState(() {
                                              _isEditing6 = true;
                                              print(_isExpanded6);
                                            });
                                          },
                                          child: Icon(
                                            Icons.edit,
                                            size: 20,
                                            color: AppColors.navColor,
                                          ),
                                        )
                                      : SizedBox.shrink(),
                                ),
                              ),
                            ],
                          ),
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.02),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(screenWidth * 0.04),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _isEditing6
                                        ? _buildBankDropDownRow(
                                            "Account Type",
                                            _selectedBankTypes,
                                            bankTypeMapping.keys.toList(),
                                            (value) {
                                              setState(() {
                                                _selectedBankTypes = value!;
                                              });
                                            },
                                          )
                                        : Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  "Account Type",
                                                  style: TextStyle(
                                                    fontSize: screenWidth * 0.04,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Container(
                                                  height: screenHeight * 0.056,
                                                  // width: screenWidth * 0.85,
                                                  decoration: BoxDecoration(
                                                    color: Color(0xffF2F5F6),
                                                    borderRadius: BorderRadius.circular(10.0),
                                                    border: Border.all(
                                                      color: Color(0xffEAECED),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Center(
                                                      child: AutoSizeText(bankTypeMapping.keys.firstWhere(
                                                        (key) => bankTypeMapping[key] == _selectedBankTypes,
                                                        orElse: () => _selectedBankTypes.isNotEmpty ? _selectedBankTypes : "Bank Account",
                                                      )),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                    Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                    _buildEditableRow(
                                      "Bank Name",
                                      _bankNameController,
                                      keyboardType: TextInputType.name,
                                      hintText: "Enter your bank name",
                                      isEditable: _isEditing6,
                                      errorMessage: _validationErrors['bank_name'],
                                    ),
                                    Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                    _buildEditableRow(
                                      "Account Name",
                                      _accountNameController,
                                      keyboardType: TextInputType.name,
                                      hintText: "Enter your account name",
                                      isEditable: _isEditing6,
                                      errorMessage: _validationErrors['account_name'],
                                    ),
                                    Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),

                                    if (_selectedBankTypes.trim().toUpperCase() == "BANK_ACCOUNT" || _selectedBankTypes == "BUILDING_SOCIETY") ...[
                                      _buildEditableRow(
                                        "Account Number",
                                        _accountNumberController,
                                        keyboardType: TextInputType.number,
                                        hintText: "Enter your account Number",
                                        isEditable: _isEditing6,
                                        errorMessage: _validationErrors['account_number'],
                                      ),
                                      Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                      _buildEditableRow(
                                        "Bank Code",
                                        _bankCodeController,
                                        keyboardType: TextInputType.name,
                                        hintText: "Enter your bank code",
                                        isEditable: _isEditing6,
                                        errorMessage: _validationErrors['bank_code'],
                                      ),
                                    ],

                                    ///Building Society
                                    if (_selectedBankTypes == "BUILDING_SOCIETY") ...[
                                      Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                      _buildEditableRow(
                                        "Building Society Roll Number",
                                        _buildingSocietyRollNumberController,
                                        keyboardType: TextInputType.name,
                                        hintText: "Enter your building society roll number",
                                        isEditable: _isEditing6,
                                        errorMessage: _validationErrors['building_society_roll_number'],
                                      ),
                                    ],

                                    ///InterNational
                                    if (_selectedBankTypes == "INTERNATIONAL_BANK_ACCOUNT") ...[
                                      _buildEditableRow(
                                        "Recipient Address 1",
                                        _recipientAddress1Controller,
                                        keyboardType: TextInputType.name,
                                        hintText: "Enter your recipient address 1",
                                        isEditable: _isEditing6,
                                        errorMessage: _validationErrors['recipient_address1'],
                                      ),
                                      Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                      _buildEditableRow(
                                        "Recipient Address 2",
                                        _recipientAddress2Controller,
                                        keyboardType: TextInputType.name,
                                        hintText: "Enter your recipient address 2",
                                        isEditable: _isEditing6,
                                        errorMessage: _validationErrors['recipient_address2'],
                                      ),
                                      Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                      _buildEditableRow(
                                        "Recipient Address 3",
                                        _recipientAddress3Controller,
                                        keyboardType: TextInputType.name,
                                        hintText: "Enter your recipient address 3",
                                        isEditable: _isEditing6,
                                        errorMessage: _validationErrors['recipient_address3'],
                                      ),
                                      Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                      _buildEditableRow(
                                        "IBAN",
                                        _ibanController,
                                        keyboardType: TextInputType.name,
                                        hintText: "Enter IBAN",
                                        isEditable: _isEditing6,
                                        errorMessage: _validationErrors['iban'],
                                      ),
                                      Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                      _buildEditableRow(
                                        "BIC/Swift",
                                        _bicSwiftCodeController,
                                        keyboardType: TextInputType.name,
                                        hintText: "Enter BIC/Swift",
                                        isEditable: _isEditing6,
                                        errorMessage: _validationErrors['bic_swift'],
                                      ),
                                      Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                      _buildEditableRow(
                                        "Payment ISO Country Code",
                                        _paymentIsoCodeController,
                                        keyboardType: TextInputType.name,
                                        hintText: "Enter your payment ISO country code",
                                        isEditable: _isEditing6,
                                        errorMessage: _validationErrors['payment_iso_country_code'],
                                      ),
                                      Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                      _buildEditableRow(
                                        "Credit ISO Currency Code",
                                        _creditIsoCodeController,
                                        keyboardType: TextInputType.name,
                                        hintText: "Enter your credit ISO currency code",
                                        isEditable: _isEditing6,
                                        errorMessage: _validationErrors['credit_iso_currency_code'],
                                      ),
                                    ],

                                    if (_isEditing6) ...[
                                      SizedBox(
                                        height: screenHeight * 0.023,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          // setState(() {
                                          //   _isEditing6 ==false;
                                          // });
                                          _updateProfile6();
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
                                              "UPDATE",
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
                                    ]
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      Divider(
                        color: Colors.grey[300],
                        thickness: 0.2,
                        height: screenHeight * 0.002,
                      ),
                      SizedBox(
                        height: screenHeight * 0.013,
                      ),
                      SizedBox(height: 5),
                      SizedBox(height: screenHeight * 0.023),
                      Container(
                        height: screenHeight * 0.05,
                        width: screenWidth * 0.4,
                        decoration: BoxDecoration(
                            // color: AppColors.navButtonColor,
                            color: AppColors.navOpacity,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                offset: Offset(0, 2),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ]),
                        child: ElevatedButton(
                          onPressed: () {
                            userPrefernece.remove().then((value) {
                              Navigator.pushNamed(context, RoutesName.login);
                            });
                          },
                          child: AutoSizeText(
                            'Logout',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.navOpacity,
                            foregroundColor: Colors.white,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.2),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildEditableRow(
    String label,
    TextEditingController controller, {
    String? hintText,
    TextInputType? keyboardType,
    bool isEditable = true,
    String? errorMessage,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 2,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[700],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: isEditable
                  ? Container(
                      height: screenHeight * 0.055,
                      // width: screenWidth * 0.85,
                      decoration: BoxDecoration(
                        color: Color(0xffF2F5F6),
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: Color(0xffEAECED),
                          width: 1,
                        ),
                      ),
                      child: TextFormField(
                        controller: controller,
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(fontSize: 15),
                          fontWeight: FontWeight.w500,
                        ),
                        keyboardType: keyboardType,
                        decoration: InputDecoration(
                          hintText: hintText,
                          hintStyle: GoogleFonts.openSans(
                            color: Colors.grey, // Text color
                            fontSize: 15, // Font size
                            fontWeight: FontWeight.normal, // Font weight
                          ), // suffixIcon: Icon(Icons.keyboard_arrow_down),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.01,
                            horizontal: screenWidth * 0.03,
                          ),
                        ),
                      ),
                    )
                  : Flexible(
                      flex: 3,
                      child: Text(
                        controller.text,
                        textAlign: TextAlign.right,
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(fontSize: 15),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
            ),
          ],
        ),
        if (errorMessage != null && errorMessage.isNotEmpty) // Render error message only if not empty
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              errorMessage,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDropdownRow(String label, String? value, List<String> options, Function(String?) onChanged) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w400,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            height: screenHeight * 0.056,
            // width: screenWidth * 0.85,
            decoration: BoxDecoration(
              color: Color(0xffF2F5F6),
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: Color(0xffEAECED),
                width: 1,
              ),
            ),

            child: DropdownButtonFormField<String>(
              // hint: Text('Gender'),
              value: value,
              items: options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: onChanged,
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 7),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _yesNoDropdownRow(String label, String? value, List<String> options, Function(String?) onChanged, bool isEditable) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w400,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: isEditable
              ? Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    height: screenHeight * 0.058,
                    width: screenWidth * 0.25,
                    decoration: BoxDecoration(
                      color: Color(0xffF2F5F6),
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: Color(0xffEAECED),
                        width: 1,
                      ),
                    ),
                    child: DropdownButtonFormField<String>(
                      // hint: Text('Gender'),
                      value: value,
                      items: options.map((String option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: onChanged,
                      // onChanged: isEditable ? (value) => onChanged(value!) : null,

                      isExpanded: true,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 7),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                )
              : Flexible(
                  flex: 3,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "$value",
                      textAlign: TextAlign.right,
                      style: GoogleFonts.openSans(
                        textStyle: TextStyle(fontSize: 15),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  String camelCaseToWords(String text) {
    final RegExp exp = RegExp(r'(?<=[a-z])(?=[A-Z])');
    return text.split(exp).map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  List<Widget> _buildBankDetailsWidgets(Data profile) {
    if (profile.bankDetail == null) {
      return []; // Return an empty list if bankDetail is null
    }

    List<Widget> bankDetailsWidgets = [];

    // Account Type
    bankDetailsWidgets.add(_buildInfoRow("Account Type", profile.bankDetail!.accountType ?? "No info"));
    bankDetailsWidgets.add(
      Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
    );

    // Bank Name
    bankDetailsWidgets.add(_buildInfoRow("Bank Name", profile.bankDetail!.bankName ?? "No info"));
    bankDetailsWidgets.add(
      Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
    );

    // Account Name
    bankDetailsWidgets.add(_buildInfoRow("Account Name", profile.bankDetail!.accountName ?? "No info"));

    // Conditional display based on account type
    if (profile.bankDetail!.accountType == 'BANK_ACCOUNT' || profile.bankDetail!.accountType == 'BUILDING_SOCIETY') {
      bankDetailsWidgets.add(
        Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
      );
      // Account Number
      bankDetailsWidgets.add(_buildInfoRow("Account Number", profile.bankDetail!.accountNumber?.toString() ?? "No info"));
      bankDetailsWidgets.add(
        Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
      );

      // Bank Code
      bankDetailsWidgets.add(_buildInfoRow("Bank Code", profile.bankDetail!.bankCode ?? "No info"));

      // Building Society (only for BUILDING_SOCIETY account type)
      if (profile.bankDetail!.accountType == 'BUILDING_SOCIETY') {
        bankDetailsWidgets.add(
          Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
        );
        bankDetailsWidgets.add(_buildInfoRow("Building Society", profile.bankDetail!.buildingSocietyRollNumber ?? "No info"));
      }
    } else if (profile.bankDetail!.accountType == 'INTERNATIONAL_BANK_ACCOUNT') {
      bankDetailsWidgets.add(
        Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
      );
      // Recipient Address 1
      bankDetailsWidgets.add(_buildInfoRow("Recipient Address 1", profile.bankDetail!.recipientAddress1 ?? "No info"));
      bankDetailsWidgets.add(
        Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
      );

      // Recipient Address 2
      bankDetailsWidgets.add(_buildInfoRow("Recipient Address 2", profile.bankDetail!.recipientAddress2 ?? "No info"));
      bankDetailsWidgets.add(
        Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
      );

      // Recipient Address 3
      bankDetailsWidgets.add(_buildInfoRow("Recipient Address 3", profile.bankDetail!.recipientAddress3 ?? "No info"));
      bankDetailsWidgets.add(
        Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
      );

      // IBAN
      bankDetailsWidgets.add(_buildInfoRow("IBAN", profile.bankDetail!.iban ?? "No info"));
      bankDetailsWidgets.add(
        Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
      );

      // BIC/Swift
      bankDetailsWidgets.add(_buildInfoRow("BIC/Swift", profile.bankDetail!.bicSwiftCode ?? "No info"));
      bankDetailsWidgets.add(
        Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
      );

      // Payment ISO Country Code
      bankDetailsWidgets.add(_buildInfoRow("Payment ISO Country Code", profile.bankDetail!.paymentIsoCode ?? "No info"));
      bankDetailsWidgets.add(
        Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
      );

      // Credit ISO Currency Code
      bankDetailsWidgets.add(_buildInfoRow("Credit ISO Currency Code", profile.bankDetail!.creditIsoCode ?? "No info"));
    }

    return bankDetailsWidgets;
  }

  void _showFullNamePopup(BuildContext context, String fullName, Offset position) {
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
    final RelativeRect positionPopup = RelativeRect.fromRect(
      Rect.fromPoints(
        position,
        position.translate(0, 0),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: positionPopup,
      items: [
        PopupMenuItem(
          child: Container(
            // width: ,
            // height: 40,
            alignment: Alignment.center,
            child: Text(
              fullName,
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget LicenseSelectedList({
    required List<String> selectedLicenses,
    required ValueChanged<List<String>> onSelectionChanged,
    String? errorMessage,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                "Licence Types",
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[700],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                height: screenHeight * 0.058,
                width: screenWidth * 0.25,
                decoration: BoxDecoration(
                  color: Color(0xffF2F5F6),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: Color(0xffEAECED),
                    width: 1,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<String>(
                    hint: Text(
                      'Select types',
                      style: TextStyle(fontSize: 14, color: AppColors.navButtonColor),
                    ),
                    items: _licenseTypes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          camelCaseToWords(value),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        if (!selectedLicenses.contains(newValue)) {
                          selectedLicenses.add(newValue);
                          onSelectionChanged(selectedLicenses);
                        }
                      }
                    },
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 7),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 15.0,
          runSpacing: 1.0,
          children: selectedLicenses.map((type) {
            return Chip(
              label: Text(
                camelCaseToWords(type),
                style: const TextStyle(color: Colors.black),
              ),
              backgroundColor: AppColors.navOpacity.withOpacity(0.5),
              deleteIcon: Icon(
                Icons.cancel,
                color: AppColors.navButtonColor,
                size: 20,
              ),
              onDeleted: () {
                selectedLicenses.remove(type);
                onSelectionChanged(selectedLicenses);
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
        if (errorMessage != null && errorMessage.isNotEmpty) // Render error message only if not empty
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              errorMessage,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
      ],
    );
  }

  void _showFullLicensePopup(BuildContext context, String fullLicenseTypes, Offset position) {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
    final RelativeRect positionPopup = RelativeRect.fromRect(
      Rect.fromPoints(
        position,
        position.translate(0, 0),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: positionPopup,
      items: [
        PopupMenuItem(
          child: Container(
            width: screenWidth * 0.95,
            child: Center(
              child: Text(
                fullLicenseTypes,
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w400,
                color: Colors.grey[700],
              ),
            ),
          ),
          Flexible(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: screenWidth * 0.034,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowWithPopup(String label, String value, String? popupValue) {
    return GestureDetector(
      onTapUp: (details) {
        if (popupValue != null) {
          _showFullNamePopup(context, popupValue, details.globalPosition);
        }
      },
      child: _buildInfoRow(label, value),
    );
  }

  String capitalizeGender(String gender) {
    gender = gender.toLowerCase();
    if (gender == 'male') {
      return 'Male';
    } else if (gender == 'female') {
      return 'Female';
    }
    return 'Male';
  }

  Widget dateCalenderContainer({
    required TextEditingController controller,
    required String labelText,
    required TextInputType keyboardType,
    String? errorMessage,
  }) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                labelText,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[700],
                ),
              ),
            ),
            Flexible(
              flex: 3,
              child: Container(
                height: screenHeight * 0.055,
                width: screenWidth * 0.4,
                decoration: BoxDecoration(
                  color: Color(0xffF2F5F6),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: Color(0xffEAECED),
                    width: 1,
                  ),
                ),
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.datetime,
                  readOnly: true,
                  style: GoogleFonts.openSans(
                    color: Colors.black87, // Text color
                    fontSize: 15, // Font size
                    fontWeight: FontWeight.w600, // Font weight
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    hintText: labelText,
                    hintStyle: GoogleFonts.openSans(
                      color: Colors.grey.withOpacity(0.6),
                      fontSize: 12,
                    ),
                    suffixIcon: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.black87,
                      size: 20,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onTap: () async {
                    DateTime initialDate = DateTime.now();
                    if (controller.text.isNotEmpty) {
                      try {
                        initialDate = DateFormat('dd/MM/yyyy').parse(controller.text);
                      } catch (e) {
                        initialDate = DateTime.now();
                      }
                    }

                    DateTime? pickedDate = await showDatePicker(
                      initialEntryMode: DatePickerEntryMode.calendarOnly,
                      context: context,
                      initialDate: initialDate,
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
                      String formattedDate = "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                      controller.text = formattedDate;
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        if (errorMessage != null && errorMessage.isNotEmpty) // Render error message only if not empty
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Align(
              alignment: Alignment.centerLeft,
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

  final ImagePicker _imagePicker = ImagePicker();
  Future<void> _pickImage(ImageSource source) async {
    XFile? pickedImage = await _imagePicker.pickImage(source: source);

    if (pickedImage != null) {
      Uint8List imageData = await pickedImage.readAsBytes();
      String imageName = pickedImage.name;
      // Splitting the filename into name and extension parts
      List<String> fileNameParts = imageName.split('.');
      String imageExtension = fileNameParts.last;
      String imageNameShortened = imageName.length > 15 ? imageName.substring(0, 15) + "..." + imageExtension : imageName;

      setState(() {
        _selectedImage = imageData;
        _selectedImageName = imageNameShortened;
      });
    } else {
      print('No image selected');
    }
  }

  Widget ProfileImagePicker({
    required VoidCallback onTap,
    required String hintText,
    required String? selectedImageName,
    required double screenHeight,
    required double screenWidth,
    required Color navOpacity,
    required Color navButtonColor,
    required Color blackColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 2,
          child: Text(
            hintText,
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w400,
              color: Colors.grey[700],
            ),
          ),
        ),
        Flexible(
          flex: 3,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              height: screenHeight * 0.055,
              width: screenWidth * 0.4,
              decoration: BoxDecoration(
                color: Color(0xffF2F5F6),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: Color(0xffEAECED),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  selectedImageName != null ? selectedImageName.split('.').first + '.' + selectedImageName.split('.').last : "Choose image",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget ViewProfile({
    required VoidCallback onTap,
    required String? profilePick,
    required double screenHeight,
    required double screenWidth,
    required String? label,
  }) {
    return Row(
      children: [
        Flexible(
          flex: 2,
          child: Text(
            label!,
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w400,
              color: Colors.grey[700],
            ),
          ),
        ),
        Flexible(
          flex: 3,
          child: Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                height: screenHeight * 0.06,
                width: screenWidth * 0.12,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  image: profilePick != null && profilePick.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage('${AppUrl.staffDriver}/$profilePick'),
                          fit: BoxFit.cover,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: profilePick == null || profilePick.isEmpty
                    ? Icon(
                        Icons.person,
                        color: Colors.blueAccent,
                        size: screenHeight * 0.08,
                      )
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  _buildBankDropDownRow(String title, String selectedValue, List<String> options, Function(String?) onChanged) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 2,
          child: Text(
            title!,
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w400,
              color: Colors.grey[700],
            ),
          ),
        ),
        Flexible(
          flex: 3,
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
                height: screenHeight * 0.058,
                width: screenWidth * 0.5,
                decoration: BoxDecoration(
                  color: Color(0xffF2F5F6),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: Color(0xffEAECED),
                    width: 1,
                  ),
                ),
                child: DropdownButtonFormField<String>(
                  // hint: Text('Gender'),
                  value: bankTypeMapping.keys.firstWhere(
                    (key) => bankTypeMapping[key] == selectedValue,
                    orElse: () => "Bank Account",
                  ),
                  items: options.map((String option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      onChanged(bankTypeMapping[newValue]);
                    }
                  },
                  isExpanded: true,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 7),
                    border: InputBorder.none,
                  ),
                )),
          ),
        ),
      ],
    );
  }
}
