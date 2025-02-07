import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:c9_app/Modules/ClientModule/pages/noInternetConnectionWidget.dart';
import 'package:c9_app/Modules/StaffModule/DashBoard/staff_navigationScreen.dart';
import 'package:c9_app/Modules/StaffModule/MODEL/staff_registrationModel/StaffRole.dart' as staff;
import 'package:c9_app/Modules/StaffModule/Profile/staff_profilev2.dart';
import 'package:c9_app/loadingScreen.dart';
import 'package:c9_app/model/profileModel/profileapi_model.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/view/widgets/checkBox_FilePicker_Widgets.dart';
import 'package:c9_app/view/widgets/file_picker_widgets.dart';
import 'package:c9_app/view/widgets/header_widgets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as https;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/utils.dart';
import '../MODEL/staff_registrationModel/ConsultantNames.dart';

class UpdateProfileV2 extends StatefulWidget {
  const UpdateProfileV2({super.key});

  @override
  State<UpdateProfileV2> createState() => _UpdateProfileV2State();
}

class _UpdateProfileV2State extends State<UpdateProfileV2> with WidgetsBindingObserver {
  String? _selectedGender;
  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _selectedImage;
  String? _selectedImageName;

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

  bool _isPassportUploaded = false;
  bool _isCPCUploaded = false;
  bool _isTachoUploaded = false;

  List<staff.Data> _roleTypes = [];
  String? _selectedRole;


  List<ConsultantNames> consultantNames = [];
  List<ConsultantNames> filteredConsultants = [];
  bool _isExpanded = false;

  final ValueNotifier<bool> _isCPCCheckBoxSelected = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isTachoCheckBoxSelected = ValueNotifier<bool>(false);

  String? _passportValidationError = '';
  String? _upCPCValidationError = '';
  String? _upTachoValidationError = '';

  void _updatePassportValidationError(String? message) {
    setState(() {
      _passportValidationError = message;
    });
  }

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

  Future<void> _pickImage(ImageSource source) async {
    XFile? pickedImage = await _imagePicker.pickImage(source: source);

    if (pickedImage != null) {
      Uint8List imageData = await pickedImage.readAsBytes();
      String imageName = pickedImage.name;
      // Splitting the filename into name and extension parts
      List<String> fileNameParts = imageName.split('.');
      String imageExtension = fileNameParts.last;
      String imageNameShortened =
      imageName.length > 15 ? imageName.substring(0, 15) + "..." + imageExtension : imageName;

      setState(() {
        _selectedImage = imageData;
        _selectedImageName = imageNameShortened;
      });
    } else {
      print('No image selected');
    }
  }

  bool isLoading = false;
  String? selectedValue;
  late Future<ProfileApiModel?> _userProfileFuture;
  List<String> _selectedLicenseTypes = [];
  final List<String> _licenseTypes = ['classB', 'classC', 'classD', 'classD1', 'classE'];
  // List<String> _maritalStatuses = [];
  // final List<String> _maritalStatusOptions = [
  //   'Single',
  //   'Married',
  //   'Divorced',
  //   'Widowed',
  //   'Separated',
  // ];
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _address1Controller = TextEditingController();
  TextEditingController _address2Controller = TextEditingController();
  TextEditingController _townOrCityController = TextEditingController();
  TextEditingController _postCodeController = TextEditingController();
  TextEditingController _licEndorsementController = TextEditingController();
  TextEditingController _medicalConditionController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  TextEditingController _dbsExpiryController = TextEditingController();
  TextEditingController _idController = TextEditingController();
  TextEditingController _ninController = TextEditingController();
  TextEditingController _licNumberController = TextEditingController();
  TextEditingController _licExpiryController = TextEditingController();
  TextEditingController _cpcNumberController = TextEditingController();
  TextEditingController _cpcExpiryController = TextEditingController();
  TextEditingController _tachoExpiryController = TextEditingController();
  TextEditingController _techoDropFileController = TextEditingController();
  TextEditingController _techoNumberFileController = TextEditingController();
  TextEditingController _roleTypeController = TextEditingController();
  TextEditingController _passportNumberController = TextEditingController();

  TextEditingController _drivingLicenseNumberController = TextEditingController();
  TextEditingController _dateofIssueDrivingController = TextEditingController();
  TextEditingController _drivingLicensecategoryController = TextEditingController();
  TextEditingController _checkCodeDrivingLicenseController = TextEditingController();
  TextEditingController _detailMedicalConditionController = TextEditingController();
  TextEditingController _detailOfMedicationController = TextEditingController();
  TextEditingController _lasteyeController = TextEditingController();
  TextEditingController _reasonForDismissalController = TextEditingController();
  TextEditingController _reasondatesForDrivingRolesController = TextEditingController();

  FocusNode drivingLicenseFocus = FocusNode();
  FocusNode drivingLicensecategoryFocus = FocusNode();
  FocusNode checkCodeDrivingLicenseFocus = FocusNode();
  FocusNode detailOfMedacationFocus = FocusNode();
  FocusNode lastEyeFocus = FocusNode();
  FocusNode reasonForDismissalFocus = FocusNode();
  FocusNode reasondatesForDrivingRolesFocus = FocusNode();

  TextEditingController materialStatusController = TextEditingController();
  TextEditingController citizenOfUkController = TextEditingController();
  TextEditingController authorizedToWorkInUKController = TextEditingController();
  TextEditingController anyUnspentCriminalConvictionsController = TextEditingController();
  TextEditingController pleaseSpecifyController = TextEditingController();

  // FocusNode consultantFocusNode = FocusNode();
  // TextEditingController consultantController = TextEditingController();

  bool _showNoInternetConnectionMessage = false;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _userProfileFuture = fetchData();
    // fetchConsultantNames();
    fetchStaffRoles();
    _selectedRole = _roleTypeController.text;
    // consultantFocusNode.addListener(() {
    //   if (!consultantFocusNode.hasFocus) {
    //     setState(() {
    //       _isExpanded = false;
    //     });
    //   }
    // });
    _licNumberController.addListener(() {
      setState(() {}); // Trigger UI update on text change
    });
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
      bool hasInternet = await _hasInternetConnection();
      setState(() {
        _showNoInternetConnectionMessage = (result == ConnectivityResult.none || !hasInternet);
      });
    });

    // _refreshData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription.cancel();
    super.dispose();
    // consultantFocusNode.dispose();
    // consultantController.dispose();
    drivingLicenseFocus.dispose();
    drivingLicensecategoryFocus.dispose();
    checkCodeDrivingLicenseFocus.dispose();
    detailOfMedacationFocus.dispose();
    lastEyeFocus.dispose();
    reasonForDismissalFocus.dispose();
    reasondatesForDrivingRolesFocus.dispose();
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<void> _refreshData() async {
    await APICacheManager().deleteCache('Staff Profile');

    await fetchData();
    setState(() {});

    // setState(() {
    //   _userProfileFuture = fetchData();
    //   print("Pull down");
    // });
  }



  String? _selectedOption1 = 'No';
  String? _selectedOption2 = 'No';
  String? _selectedOption3 = 'No';

  String? _selected1 = 'No';
  String? _selected2 = 'No';
  String? _selected3 = 'No';
  String? _selected4 = 'No';
  String? _selected5 = 'No';
  String? _selected6 = 'No';
  String? _selected7 = 'No';
  String? _selected8 = 'No';
  String? _selected9 = 'No';
  String? _selected10 = 'No';
  String? _selected11 = 'No';
  String? _selected12 = 'No';
  String? _selected13 = 'No';

  String _licenseTypeValidationError = '';
  String _tachNumberValidationError = '';
  final List<String> _dropdownOptions = ['Yes', 'No'] ;

  String capitalizeGender(String gender) {
    gender = gender.toLowerCase();
    if (gender == 'male') {
      return 'Male';
    } else if (gender == 'female') {
      return 'Female';
    }
    return 'Male';
  }

  /// Updated
  Future<ProfileApiModel?> fetchData() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    bool hasInternet = await _hasInternetConnection();
    if (connectivityResult == ConnectivityResult.none || !hasInternet) {
      // No internet connection
      setState(() {
        _showNoInternetConnectionMessage = true;
      });
      return null;
    } else {
      // Clear cache when a new user logs in
      await APICacheManager().deleteCache('Staff Profile');

      var isCacheExist = await APICacheManager().isAPICacheKeyExist('Staff Profile');

      if (!isCacheExist) {
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

          // Cache the fetched data
          APICacheDBModel cacheDBModel = APICacheDBModel(key: 'Staff Profile', syncData: response.body);
          await APICacheManager().addCacheData(cacheDBModel);

          final ProfileApiModel profileViewset = ProfileApiModel.fromJson(responseData);
          setState(() {
            _firstNameController.text = profileViewset.data.firstName ?? '';
            _lastNameameController.text = profileViewset.data.lastName ?? '';
            _emailController.text = profileViewset.data.email ?? '';
            _phoneController.text = profileViewset.data.phone ?? '';
            _address1Controller.text = profileViewset.data.addressLine1 ?? '';
            _address2Controller.text = profileViewset.data.addressLine2 ?? '';
            _townOrCityController.text = profileViewset.data.city ?? '';
            _postCodeController.text = profileViewset.data.postCode ?? '';

            // _roleTypeController.text=profileViewset.data.roleType ?? '';
            // Set _selectedRole to the fetched role if it matches a valid role in _roleTypes
            if (_roleTypes.isNotEmpty && _roleTypes.any((role) => role.staffType == profileViewset.data.roleType)) {
              _selectedRole = profileViewset.data.roleType;
            } else {
              _selectedRole = null; // Set a default or fallback value
            }

            _passportNumberController.text = profileViewset.data.passportNumber ?? '';

            _licEndorsementController.text = profileViewset.data.licenceEndorsement ?? '';
            _medicalConditionController.text = profileViewset.data.medicalCondition ?? '';
            // _selectedGender =
            //     profileViewset.data.gender?.toLowerCase() ?? 'Male';
            _selectedGender = profileViewset.data.gender?.isNotEmpty ?? false
                ? capitalizeGender(profileViewset.data.gender!)
                : 'Male';

            // _dobController.text = profileViewset.data.dob ?? '';
            if (profileViewset.data.dob != null) {
              DateTime dob = DateTime.parse(profileViewset.data.dob!);
              _dobController.text =
              "${dob.day.toString().padLeft(2, '0')}/${dob.month.toString().padLeft(2, '0')}/${dob.year}";
            }
            // _licExpiryController.text = profileViewset.data.licenceExpiry ?? '';
            if (profileViewset.data.licenceExpiry != null) {
              DateTime licExp = DateTime.parse(profileViewset.data.licenceExpiry!);
              _licExpiryController.text =
              "${licExp.day.toString().padLeft(2, '0')}/${licExp.month.toString().padLeft(2, '0')}/${licExp.year}";
            }
            if (profileViewset.data.tachoExpiry != null) {
              DateTime tachoExp = DateTime.parse(profileViewset.data.tachoExpiry!);
              _tachoExpiryController.text =
              '${tachoExp.day.toString().padLeft(2, '0')}/${tachoExp.month.toString().padLeft(2, '0')}/${tachoExp.year}';
            }

            if (profileViewset.data.dbsExpiry != null) {
              DateTime dbsExp = DateTime.parse(profileViewset.data.dbsExpiry!);
              _dbsExpiryController.text =
              '${dbsExp.day.toString().padLeft(2, '0')}/${dbsExp.month.toString().padLeft(2, '0')}/${dbsExp.year}';
            }

            _idController.text = profileViewset.data.driverId.toString();
            _ninController.text = profileViewset.data.niNumber ?? '';
            _licNumberController.text = profileViewset.data.licenceNumber ?? '';

            _cpcNumberController.text = profileViewset.data.cpcNumber ?? '';
            _passportNumberController.text = profileViewset.data.passportNumber ?? '';
            // _cpcExpiryController.text = profileViewset.data.cpcExpiry ?? '';
            if (profileViewset.data.cpcExpiry != null) {
              DateTime cpcExp = DateTime.parse(profileViewset.data.cpcExpiry!);
              _cpcExpiryController.text =
              "${cpcExp.day.toString().padLeft(2, '0')}/${cpcExp.month.toString().padLeft(2, '0')}/${cpcExp.year}";
            }
            _techoNumberFileController.text = profileViewset.data.tachoNumber ?? '';
            _selectedOption1 = profileViewset.data.rightToWorkUk == 1 ? 'Yes' : 'No';
            _selectedOption2 = profileViewset.data.dbsCheck == 1 ? 'Yes' : 'No';
            _selectedOption3 = profileViewset.data.optOutOfPension == 1 ? 'Yes' : 'No';
            _selectedLicenseTypes = List<String>.from(profileViewset.data.licenceType ?? []);


            /// new fields

            // _selected11 = profileViewset.data.isUkCitizen == 1 ? 'Yes' : 'No';
            //  _selected12 = profileViewset.data.hasUnspentCriminalConvictions == 1 ? 'Yes' : 'No';
            //  _selected13 = profileViewset.data.isAuthorizedToWorkInUk == 1 ? 'Yes' : 'No';

            pleaseSpecifyController.text = profileViewset.data.unspentCriminalConvictionsDetails ?? '';

            _selected1 = profileViewset.data.ukDrivingExperience == 1 ? 'Yes' : 'No';
            _selected2 = profileViewset.data.validUkDrivingLicense == 1 ? 'Yes' : 'No';
            _selected3 = profileViewset.data.penaltyPoints == 1 ? 'Yes' : 'No';
            _selected4 = profileViewset.data.physicalIncapabilities == 1 ? 'Yes' : 'No';
            _selected5 = profileViewset.data.ongoingMedicalConditions == 1 ? 'Yes' : 'No';
            _selected6 = profileViewset.data.takingMedication == 1 ? 'Yes' : 'No';
            _selected7 = profileViewset.data.drugOrAlcoholIssues == 1 ? 'Yes' : 'No';
            _selected8 = profileViewset.data.wearsGlasses == 1 ? 'Yes' : 'No';
            _selected9 = profileViewset.data.dismissedForMedicalReasons == 1 ? 'Yes' : 'No';
            _selected10 = profileViewset.data.medicalConditionDetails == 1 ? 'Yes' : 'No';
            _selected11 = profileViewset.data.isUkCitizen == 1 ? 'Yes' : 'No';
            _selected12 = profileViewset.data.hasUnspentCriminalConvictions == 1 ? 'Yes' : 'No';
            _selected13 = profileViewset.data.isAuthorizedToWorkInUk == 1 ? 'Yes' : 'No';

            _drivingLicenseNumberController.text = profileViewset.data.drivingLicenseNumber ?? '';
            _drivingLicensecategoryController.text = profileViewset.data.drivingLicenseCategory ?? '';
            _checkCodeDrivingLicenseController.text = profileViewset.data.drivingLicenseCheckCode ?? '';

            if (profileViewset.data.drivingLicenseIssueDate != null) {
              try {
                DateTime drivingIssueDate = DateTime.parse(profileViewset.data.drivingLicenseIssueDate!);
                _dateofIssueDrivingController.text =
                '${drivingIssueDate.day.toString().padLeft(2, '0')}/${drivingIssueDate.month.toString().padLeft(2, '0')}/${drivingIssueDate.year}';
              } catch (e) {
                // Handle invalid date format or parsing errors
                print('Error parsing driving license issue date: $e');
              }
            }


            _detailOfMedicationController.text = profileViewset.data.medicationDetails ?? '';
            _reasonForDismissalController.text = profileViewset.data.dismissalReason ?? '';
            _reasondatesForDrivingRolesController.text = profileViewset.data.drivingDismissalDetails ?? '';


            if (profileViewset.data.lastEyeTest != null) {
              try {
                DateTime lastEyeDate = DateTime.parse(profileViewset.data.lastEyeTest!);
                _lasteyeController.text =
                '${lastEyeDate.day.toString().padLeft(2, '0')}/${lastEyeDate.month.toString().padLeft(2, '0')}/${lastEyeDate.year}';
              } catch (e) {
                // Handle invalid date format or parsing errors
                print('Error parsing last eye test date: $e');
              }
            }
          });

          return profileViewset;
        } else {
          throw Exception('Failed to fetch user data. Status code: ${response.statusCode}');
        }
      } else {
        // Fetch data from cache
        var cacheData = await APICacheManager().getCacheData('Staff Profile');
        final Map<String, dynamic> cachedResponseData = json.decode(cacheData.syncData);

        if (cachedResponseData == null) {
          throw Exception('Cached response data is null');
        }

        final ProfileApiModel profileViewset = ProfileApiModel.fromJson(cachedResponseData);
        setState(() {
          _firstNameController.text = profileViewset.data.firstName ?? '';
          _lastNameameController.text = profileViewset.data.lastName ?? '';
          _emailController.text = profileViewset.data.email ?? '';
          _phoneController.text = profileViewset.data.phone ?? '';
          _address1Controller.text = profileViewset.data.addressLine1 ?? '';
          _address2Controller.text = profileViewset.data.addressLine2 ?? '';
          _townOrCityController.text = profileViewset.data.city ?? '';
          _postCodeController.text = profileViewset.data.postCode ?? '';
          _licEndorsementController.text = profileViewset.data.licenceEndorsement ?? '';
          _medicalConditionController.text = profileViewset.data.medicalCondition ?? '';
          // _selectedGender = profileViewset.data.gender?.toLowerCase() ?? 'Male';
          _selectedGender =
          profileViewset.data.gender?.isNotEmpty ?? false ? capitalizeGender(profileViewset.data.gender!) : 'Male';
          // _selectedGender = profileViewset.data.gender ?? 'male';
          // _dobController.text = profileViewset.data.dob ?? '';
          if (profileViewset.data.dob != null) {
            DateTime dob = DateTime.parse(profileViewset.data.dob!);
            _dobController.text =
            "${dob.day.toString().padLeft(2, '0')}/${dob.month.toString().padLeft(2, '0')}/${dob.year}";
          }

          // _licExpiryController.text = profileViewset.data.licenceExpiry ?? '';
          if (profileViewset.data.licenceExpiry != null) {
            DateTime licExp = DateTime.parse(profileViewset.data.licenceExpiry!);
            _licExpiryController.text =
            "${licExp.day.toString().padLeft(2, '0')}/${licExp.month.toString().padLeft(2, '0')}/${licExp.year}";
          }

          if (profileViewset.data.tachoExpiry != null) {
            DateTime tachoExp = DateTime.parse(profileViewset.data.tachoExpiry!);
            _tachoExpiryController.text =
            '${tachoExp.day.toString().padLeft(2, '0')}/${tachoExp.month.toString().padLeft(2, '0')}/${tachoExp.year}';
          }

          if (profileViewset.data.dbsExpiry != null) {
            DateTime dbsExp = DateTime.parse(profileViewset.data.dbsExpiry!);
            _dbsExpiryController.text =
            '${dbsExp.day.toString().padLeft(2, '0')}-${dbsExp.month.toString().padLeft(2, '0')}-${dbsExp.year}';
          }

          _idController.text = profileViewset.data.driverId.toString();
          // _roleTypeController.text = profileViewset.data.roleType ?? '';
          if (_roleTypes.isNotEmpty && _roleTypes.any((role) => role.staffType == profileViewset.data.roleType)) {
            _selectedRole = profileViewset.data.roleType;
          } else {
            _selectedRole = null; // Set a default or fallback value
          }
          _passportNumberController.text = profileViewset.data.passportNumber ?? '';
          _ninController.text = profileViewset.data.niNumber ?? '';
          _licNumberController.text = profileViewset.data.licenceNumber ?? '';
          _cpcNumberController.text = profileViewset.data.cpcNumber ?? '';
          // _cpcExpiryController.text = profileViewset.data.cpcExpiry ?? '';
          if (profileViewset.data.cpcExpiry != null) {
            DateTime cpcExp = DateTime.parse(profileViewset.data.cpcExpiry!);
            _cpcExpiryController.text =
            "${cpcExp.day.toString().padLeft(2, '0')}/${cpcExp.month.toString().padLeft(2, '0')}/${cpcExp.year}";
          }
          _techoNumberFileController.text = profileViewset.data.tachoNumber ?? '';
          _selectedOption1 = profileViewset.data.rightToWorkUk == 1 ? 'Yes' : 'No';
          _selectedOption2 = profileViewset.data.dbsCheck == 1 ? 'Yes' : 'No';
          _selectedOption3 = profileViewset.data.optOutOfPension == 1 ? 'Yes' : 'No';
          _selectedLicenseTypes = List<String>.from(profileViewset.data.licenceType ?? []);

          _selected1 = profileViewset.data.ukDrivingExperience == 1 ? 'Yes' : 'No';
          _selected2 = profileViewset.data.validUkDrivingLicense == 1 ? 'Yes' : 'No';
          _selected3 = profileViewset.data.penaltyPoints == 1 ? 'Yes' : 'No';

          ///new fields

          _selected11 = profileViewset.data.isUkCitizen == 1 ? 'Yes' : 'No';
          _selected12 = profileViewset.data.hasUnspentCriminalConvictions == 1 ? 'Yes' : 'No';
          _selected13 = profileViewset.data.isAuthorizedToWorkInUk == 1 ? 'Yes' : 'No';
          // materialStatusController.text = profileViewset.data.maritalStatus ?? '';
          // _maritalStatuses = List<String>.from(profileViewset.data.maritalStatus ?? []);

          pleaseSpecifyController.text = profileViewset.data.unspentCriminalConvictionsDetails ?? '';

          _drivingLicenseNumberController.text = profileViewset.data.drivingLicenseNumber ?? '';
          _drivingLicensecategoryController.text = profileViewset.data.drivingLicenseCategory ?? '';
          _checkCodeDrivingLicenseController.text = profileViewset.data.drivingLicenseCheckCode ?? '';

          if (profileViewset.data.drivingLicenseIssueDate != null) {
            DateTime drivingissueDate = DateTime.parse(profileViewset.data.drivingLicenseIssueDate!);
            _dateofIssueDrivingController.text =
            '${drivingissueDate.day.toString().padLeft(2, '0')}/${drivingissueDate.month.toString().padLeft(2, '0')}/${drivingissueDate.year.toString()}';
          }


          _selected4 = profileViewset.data.physicalIncapabilities == 1 ? 'Yes' : 'No';
          _selected5 = profileViewset.data.ongoingMedicalConditions == 1 ? 'Yes' : 'No';
          _selected6 = profileViewset.data.takingMedication == 1 ? 'Yes' : 'No';
          _selected7 = profileViewset.data.drugOrAlcoholIssues == 1 ? 'Yes' : 'No';
          _selected8 = profileViewset.data.wearsGlasses == 1 ? 'Yes' : 'No';
          _selected9 = profileViewset.data.dismissedForMedicalReasons == 1 ? 'Yes' : 'No';
          _selected10 = profileViewset.data.medicalConditionDetails == 1 ? 'Yes' : 'No';

          _detailOfMedicationController.text = profileViewset.data.medicationDetails ?? '';
          _reasonForDismissalController.text = profileViewset.data.dismissalReason ?? '';
          _reasondatesForDrivingRolesController.text = profileViewset.data.drivingDismissalDetails ?? '';

          if (profileViewset.data.lastEyeTest != null) {
            DateTime lastEyeDates = DateTime.parse(profileViewset.data.lastEyeTest!);
            _lasteyeController.text =
            '${lastEyeDates.day.toString().padLeft(2, '0')}-${lastEyeDates.month.toString().padLeft(2, '0')}-${lastEyeDates.year.toString()}';
          }
        });

        return ProfileApiModel.fromJson(cachedResponseData);
      }
    }
  }

  String _cpcNumberValidationError = '';
  String _cpcExpiryValidationError = '';
  String _tachoExpiryValidationError = '';
  String _medicalValidationError = '';
  Map<String, String> _validationErrors = {};

  /// Updated
  void _updateProfile() async {
    print("Posting role: $_selectedRole");
    setState(() {
      isLoading = true;
    });
    String _roleTypeValidationError = '';

    /// New validation fields
    String _ukDrivingExperienceError = '';
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

    // Initialize validation error variables
    String _firstValidationError = '';
    String _lastValidationError = '';
    String _emailValidationError = '';
    String _phoneValidationError = '';
    String _addressLine1ValidationError = '';
    String _addressLine2ValidationError = '';
    String _townOrCityValidationError = '';
    String _postCodeValidationError = '';
    String _dobValidationError = '';
    String _dbsExpiryValidationError = '';
    String _niValidationError = '';
    String _licExpiryValidationError = '';
    String _licenceEndorValidationError = '';
    String _passportNumberValidationError = '';
    _licenseTypeValidationError = '';
    String _licNumValidationError = '';
    _cpcNumberValidationError = '';
    _cpcExpiryValidationError = '';
    _tachNumberValidationError = '';
    _medicalValidationError = '';

    _passportValidationError = '';
    _upCPCValidationError = '';
    _upTachoValidationError = '';
    String _drivingLicenceValidationError = '';
    String _proofOfAddressValidationError = '';

    // final Map<String, String> maritalTypeMap = {
    //   'Single': 'single',
    //   'Married': 'married',
    //   'Divorced': 'divorced',
    //   'Widowed': 'widowed',
    //   'Separated': 'separated',
    // };
    //
    // if(_maritalStatuses.isEmpty || !maritalTypeMap.values.contains(_maritalStatuses[0])){
    //   _materialStatusError = 'Marital status is required .';
    // }

    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      bool hasInternet = await _hasInternetConnection();

      if (connectivityResult == ConnectivityResult.none || !hasInternet) {
        // No internet connection
        setState(() {
          _showNoInternetConnectionMessage = true;
          isLoading = false; // Stop loading indicator
        });
        return; // Exit the function
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String _token = prefs.getString('token') ?? '';
      final String apiUrl = '${AppUrl.baseUrl}/api/app/staff/profile/update';
      var request = https.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers.addAll({
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
      });
      // Add fields to the request
      request.fields['first_name'] = _firstNameController.text.toString();
      request.fields['last_name'] = _lastNameameController.text.toString();
      request.fields['phone'] = _phoneController.text.toString();
      request.fields['gender'] = _selectedGender ?? "";
      request.fields['email'] = _emailController.text.toString();
      request.fields['addressLine1'] = _address1Controller.text.toString();
      request.fields['addressLine2'] = _address2Controller.text.toString();
      request.fields['townOrCity'] = _townOrCityController.text.toString();
      request.fields['postCode'] = _postCodeController.text.toString();
      request.fields['medicalConditions'] = _medicalConditionController.text.toString();

      // request.fields['consultant'] = consultantController.text;

      request.fields['rightToWorkUK'] = _selectedOption1 == 'Yes' ? '1' : '0';
      request.fields['dbsCheck'] = _selectedOption2 == 'Yes' ? '1' : '0';
      request.fields['optOutOfPension'] = _selectedOption3 == 'Yes' ? '1' : '0';
      // request.fields['dob'] = _dobController.text.toString();
      String dobText = _dobController.text;
      if (dobText.isNotEmpty) {
        List<String> dobParts = dobText.split('/');
        if (dobParts.length == 3) {
          String dobForSubmission = "${dobParts[0]}/${dobParts[1]}/${dobParts[2]}";
          print("--------------");
          print(dobForSubmission);
          request.fields['dob'] = dobForSubmission;
        }
      }

      // request.fields['licenceExpiry'] = _licExpiryController.text.toString();

      request.fields['ni_number'] = _ninController.text.toString();
      // request.fields['role'] = _roleTypeController.text.toString();
      request.fields['role'] = _selectedRole.toString();

      request.fields['passportNumber'] = _passportNumberController.text.toString();
      if (_selectedImage != null) {
        request.files.add(await https.MultipartFile.fromBytes(
          'image',
          _selectedImage!,
          filename: _selectedImageName!,
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
        print("Passport Image------ $_selectedFile1");
      } else if (_isPassportUploaded) {
        request.fields['noPassport'] = "on";
        print("Passport Else If Executes----------");
      }

      request.fields['dbsExpiry'] = _dbsExpiryController.text.toString();
      String dbsExpText = _dbsExpiryController.text;
      if (dbsExpText.isNotEmpty) {
        List<String> dbsExpParts = dbsExpText.split('-');
        if (dbsExpParts.length == 3) {
          String dbsExpSubmission = "${dbsExpParts[2]}-${dbsExpParts[1]}-${dbsExpParts[0]}";
          request.fields['dbsExpiry'] = dbsExpSubmission;
        }
      }

      /// Fitness Fields
      request.fields['is_uk_citizen'] = _selected11 == 'Yes' ? '1' : '0';
      request.fields['has_unspent_criminal_convictions'] = _selected12 == 'Yes' ? '1' : '0';
      request.fields['is_authorized_to_work_in_uk'] = _selected13 == 'Yes' ? '1' : '0';
      // request.fields['marital_status'] = materialStatusController.text
      // if(_maritalStatuses.isEmpty ||_maritalStatusOptions[0].isEmpty){
      //   _materialStatusError = 'Marital status is required.';
      //   request.fields['marital_status'] = ''; // Ensure this field is sent
      //
      // } else {
      //   request.fields['marital_status'] = maritalTypeMap[_maritalStatuses[0]] ?? ''; // Send correct account type
      // }

      if (_selected12 == 'Yes') {
        print("has_unspent_criminal_convictions ----$_selected12");
        request.fields['unspent_criminal_convictions_details'] = pleaseSpecifyController.text;
      }

      request.fields['physical_incapabilities'] = _selected4 == 'Yes' ? '1' : '0';
      request.fields['ongoing_medical_conditions'] = _selected5 == 'Yes' ? '1' : '0';
      request.fields['taking_medication'] = _selected6 == 'Yes' ? '1' : '0';
      request.fields['drug_or_alcohol_issues'] = _selected7 == 'Yes' ? '1' : '0';
      request.fields['wears_glasses'] = _selected8 == 'Yes' ? '1' : '0';
      request.fields['dismissed_for_medical_reasons'] = _selected9 == 'Yes' ? '1' : '0';
      request.fields['dismissed_from_driving_roles'] = _selected10 == 'Yes' ? '1' : '0';
      if (_selected10 == 'Yes'){
        request.fields['driving_dismissal_details'] = _reasondatesForDrivingRolesController.text;
      }

      request.fields['medical_condition_details'] = _detailMedicalConditionController.text;
      request.fields['medication_details'] = _detailOfMedicationController.text;
      request.fields['dismissal_reason'] = _reasonForDismissalController.text;


      if (_lasteyeController.text.isNotEmpty) {
        request.fields['last_eye_test'] =
            DateFormat('dd/MM/yyyy').format(DateFormat('dd/MM/yyyy').parse(_lasteyeController.text.toString()));
      }

      // request.fields['last_eye_test'] = _lasteyeController.text.toString();
      // String lasteye = _lasteyeController.text;
      // if (lasteye.isNotEmpty) {
      //   List<String> lastEyePart = lasteye.split('-');
      //   if (lastEyePart.length == 3) {
      //     String lastEyesubmission = "${lastEyePart[2]}-${lastEyePart[1]}-${lastEyePart[0]}";
      //     request.fields['last_eye_test'] = lastEyesubmission;
      //   }
      // }

      /// Role Types Section Ended
      if (_selectedRole?.toLowerCase().contains('driver') ?? false) {
        // request.fields['licenceNumber'] = _licNumberController.text.toString();
        // String licexpiryText = _licExpiryController.text;
        // if (licexpiryText.isNotEmpty) {
        //   List<String> licExpParts = licexpiryText.split('-');
        //   if (licExpParts.length == 3) {
        //     String licEXPForSubmission = "${licExpParts[2]}-${licExpParts[1]}-${licExpParts[0]}";
        //     request.fields['licenceExpiry'] = licEXPForSubmission;
        //   }
        // }

        bool isCheckboxSelected = _isCPCCheckBoxSelected.value;
        if (!isCheckboxSelected) {
          request.fields['cpcNumber'] = _cpcNumberController.text.toString();

          String cpcExpText = _cpcExpiryController.text;
          if (cpcExpText.isNotEmpty) {
            List<String> cpcExpParts = cpcExpText.split('/');
            if (cpcExpParts.length == 3) {
              String cpcExpSubmission = "${cpcExpParts[0]}/${cpcExpParts[1]}/${cpcExpParts[2]}";
              request.fields['cpcExpiry'] = cpcExpSubmission;
            }
          }
        } else {
          request.fields['noCpcCard'] = "on";
        }

        bool isTechoCheckboxSelected = _isTachoCheckBoxSelected.value;
        if (!isTechoCheckboxSelected) {
          request.fields['tachoNumber'] = _techoNumberFileController.text.toString();

          String tachoExpText = _tachoExpiryController.text;
          if (tachoExpText.isNotEmpty) {
            List<String> tachoExpTextParts = tachoExpText.split('/');
            if (tachoExpTextParts.length == 3) {
              String tachoExpSubmission = "${tachoExpTextParts[0]}/${tachoExpTextParts[1]}/${tachoExpTextParts[2]}";
              request.fields['tachoExpiry'] = tachoExpSubmission;
            }
          }
        } else {
          request.fields['noTachoCard'] = "on";
        }

        for (int i = 0; i < _selectedLicenseTypes.length; i++) {
          request.fields['licenceTypes[$i]'] = _selectedLicenseTypes[i];
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

        ///Conditional issue here 1
        ///uk_driving_experience
        /// penalty_points
        ///   if (_selected2 == 'Yes'){}
        request.fields['valid_uk_driving_license'] = _selected2 == 'Yes' ? '1' : '0';
        print("valid_uk_driving_license ----$_selected2");
        // request.fields['uk_driving_experience'] = _selected1 == 'Yes' ? '1' : '0';
        // request.fields['penalty_points'] = _selected3 == 'Yes' ? '1' : '0';
        if (_selected2 == 'Yes'){
          request.fields['uk_driving_experience'] = _selected1 == 'Yes' ? '1' : '0';
          print("uk_driving_experience ----$_selected1");
        }else{
          request.fields['uk_driving_experience'] ='0';
        }
        // request.fields['licenceNumber'] = _licNumberController.text.toString();
        if ( _selected2 == 'Yes' && _selected1 == 'Yes'){
          request.fields['licenceNumber'] = _licNumberController.text.toString();
        }
        //
        if ( _selected2 == 'Yes' && _selected1 == 'Yes' && _licNumberController.text.isNotEmpty){
          String licexpiryText = _licExpiryController.text;
          if (licexpiryText.isNotEmpty) {
            List<String> licExpParts = licexpiryText.split('/');
            if (licExpParts.length == 3) {
              String licEXPForSubmission = "${licExpParts[0]}/${licExpParts[1]}/${licExpParts[2]}";
              request.fields['licenceExpiry'] = licEXPForSubmission;
            }
          }
          request.fields['licenceEndorsements'] = _licEndorsementController.text.toString();
          if (_selectedStaffFile != null) {
            request.files.add(await https.MultipartFile.fromBytes(
              'drivingLicence',
              _selectedStaffFile!,
              filename: _selectedStaffFileName!,
            ));
            print('Driving License Image Added');
          }
          request.fields['penalty_points'] = _selected3 == 'Yes' ? '1' : '0';

          if (_dateofIssueDrivingController.text.isNotEmpty) {
            request.fields['driving_license_issue_date'] = DateFormat('dd/MM/yyyy')
                .format(DateFormat('dd/MM/yyyy').parse(_dateofIssueDrivingController.text.toString()));
          }
          request.fields['driving_license_category'] = _drivingLicensecategoryController.text.toString();
          request.fields['driving_license_check_code'] = _checkCodeDrivingLicenseController.text.toString();
          request.fields['driving_license_number'] = _drivingLicenseNumberController.text.toString();
        }




        ///Condition lagate hobe issue here -----2




      }

      /// Role Types Section Ended

      final response = await request.send();

      final responseBody = await response.stream.bytesToString();
      final responseData = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        // Clear the cache
        await APICacheManager().deleteCache('Staff Profile');
        await _refreshData(); // This will fetch will update the UI
        print(response);
        print(responseData);
        print(_selectedRole);
        setState(() {
          isLoading = false;
        });
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
              case 'licenceExpiry':
                _licExpiryValidationError = errorMessage;
                break;
              case 'dbsExpiry':
                _dbsExpiryValidationError = errorMessage;
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
              case 'tachoExpiry':
                _tachoExpiryValidationError = errorMessage;
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
              case 'cpc':
                _upCPCValidationError = errorMessage ?? '';
                break;
              case 'tacho':
                _upTachoValidationError = errorMessage ?? '';
                break;
              case 'passportNumber':
                _passportNumberValidationError = errorMessage;
                break;

              case 'roleType':
                _roleTypeValidationError = errorMessage;
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
              // _materialStatusError = errorMessage;.
                _validationErrors['marital_status'] = errorMessage;

                break;

              case 'unspent_criminal_convictions_details':
                _pleaseSpecifyError = errorMessage;
                break;

              case 'uk_driving_experience':
                _ukDrivingExperienceError = errorMessage;
                break;

              case 'valid_uk_driving_license':
                _validUKDrivingExperienceError = errorMessage;
                break;
              case 'penalty_points':
                _panaltyPointsError = errorMessage;
                break;

              case 'driving_license_number':
                _drivingLicenseNumberError = errorMessage;
                break;

              case 'driving_license_category':
                _drivingLicenseCategoryError = errorMessage;
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

          setState(() {
            _validationErrors = {
              'first_name': _firstValidationError,
              'last_name': _lastValidationError,
              'email': _emailValidationError,
              'addressLine1': _addressLine1ValidationError,
              'addressLine2': _addressLine2ValidationError,
              'townOrCity': _townOrCityValidationError,
              'postCode': _postCodeValidationError,
              'dob': _dobValidationError,
              'dbsExpiry': _dbsExpiryValidationError,
              'ni_number': _niValidationError,
              'phone': _phoneValidationError,
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
              'cpc': _upCPCValidationError ?? '',
              'tacho': _upTachoValidationError ?? '',
              'proofOfAddress': _proofOfAddressValidationError,
              'roleType': _roleTypeValidationError,
              'passportNumber': _passportNumberValidationError,

              /// NEw Fields

              'is_uk_citizen': _citizenOfUkError,
              'is_authorized_to_work_in_uk': _authorizedToWorkInUKError,
              'has_unspent_criminal_convictions': _anyUnspentCriminalConvictionsError,
              'marital_status': _materialStatusError,
              'unspent_criminal_convictions_details': _pleaseSpecifyError,

              'uk_driving_experience': _ukDrivingExperienceError,
              'valid_uk_driving_license': _validUKDrivingExperienceError,
              'penalty_points': _panaltyPointsError,
              'driving_license_number': _drivingLicenseNumberError,
              'driving_license_category': _drivingLicenseCategoryError,
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
          String errorMessage = responseData['message'] ?? 'Update failed';
          Utils.flushBarErrorMessage(errorMessage, context);
          print(responseData);
        }
      } else {
        String errorMessage = responseData['message'] ?? 'Update failed';
        Utils.flushBarErrorMessage(errorMessage, context);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error during data submission: $e');
      if (isLoading) {
        setState(() {
          isLoading = false;
        });
        Utils.flushBarErrorMessage('An error occurred during profile update', context);
      }
    }
  }

  Future<void> fetchStaffRoles() async {
    try {
      final response = await https.get(Uri.parse('${AppUrl.baseUrl}/api/app/role/type'));

      if (response.statusCode == 200) {
        staff.StaffRole staffRoles = staff.StaffRole.fromJson(json.decode(response.body));

        setState(() {
          _roleTypes = staffRoles.data ?? [];

          // Ensure _selectedRole matches the initial controller text if it's in the list
          if (_roleTypes.isNotEmpty && _roleTypes.any((role) => role.staffType == _selectedRole)) {
            // _selectedRole is already correctly set, no need to update it again.
          }
        });
      } else {
        throw Exception('Failed to load worker roles');
      }
    } catch (e) {
      print("Error fetching roles: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: _showNoInternetConnectionMessage ? Colors.red : AppColors.navColor,
    ));
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          surfaceTintColor: Colors.white,
          toolbarHeight: 80,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                  onTap: () {
                    // Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => StaffProfile()));
                  },
                  child: HeaderRow(Icons.arrow_back)),
              Text(
                "Update",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => StaffCurveNabBar()));
                  },
                  child: HeaderRow(Icons.home)),
            ],
          ),
        ),
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
    );
  }

  Widget body() {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          Center(
            child: FutureBuilder<ProfileApiModel?>(
              future: _userProfileFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: screenHeight * 0.85,
                    width: screenWidth,
                    color: AppColors.whiteColor,
                    child: LoadingScreen(),
                  );
                } else if (snapshot.hasError) {
                  return Text("");
                  // return Text("${snapshot.error}");
                } else if (!snapshot.hasData) {
                  return Center(child: Text('No user data found.'));
                } else {
                  final ProfileApiModel userData = snapshot.data!;
                  final String? profilePick = userData.data.image;

                  final Data profile = userData.data;

                  String camelCaseToWords(String text) {
                    if (text == null || text.isEmpty) return '';
                    final buffer = StringBuffer();
                    buffer.write(text[0].toUpperCase()); // Capitalize the first letter
                    for (int i = 1; i < text.length; i++) {
                      if (text[i].toUpperCase() == text[i]) {
                        buffer.write(' ');
                      }
                      buffer.write(text[i]);
                    }
                    return buffer.toString();
                  }

                  return Container(
                    width: screenWidth * 0.95,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        offset: Offset(0, 2),
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ]),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                height: screenHeight * 0.18,
                                width: screenWidth * 0.3,
                                decoration: BoxDecoration(
                                  color: profilePick != null && profilePick.isNotEmpty
                                      ? Colors.transparent
                                      : AppColors.navOpacity,
                                  image: DecorationImage(
                                      image: NetworkImage('${AppUrl.staffDriver}/$profilePick'), fit: BoxFit.cover),
                                  border: Border.all(
                                    color: AppColors.navOpacity,
                                  ),
                                  // color: Colors.red
                                ),
                              ),
                              Column(
                                children: [
                                  FirstContainer(
                                    controller: _firstNameController,
                                    labelText: "First name",
                                    keyboardType: TextInputType.name,
                                    errorMessage: _validationErrors['first_name'],
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.013,
                                  ),
                                  FirstContainer(
                                    controller: _lastNameameController,
                                    labelText: "Last name",
                                    keyboardType: TextInputType.name,
                                    errorMessage: _validationErrors['last_name'],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: screenHeight * 0.013,
                        ),
                        GestureDetector(
                          onTap: () {
                            _pickImage(ImageSource.gallery);
                          },
                          child: Container(
                              height: screenHeight * 0.06,
                              width: screenWidth * 0.915,
                              decoration: BoxDecoration(
                                color: AppColors.navOpacity.withOpacity(0.2),
                                border: Border.all(
                                  color: AppColors.navButtonColor.withOpacity(0.4),
                                  width: 0.4,
                                ),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    height: screenHeight * 0.06,
                                    width: screenWidth * 0.30,
                                    decoration: BoxDecoration(
                                      color: AppColors.navOpacity,
                                      border: Border.all(
                                        color: AppColors.navOpacity,
                                        width: 0.4,
                                      ),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: Center(
                                        child: Text(
                                          "Choose image",
                                          style: TextStyle(fontSize: 15, color: AppColors.blackColor),
                                        )),
                                  ),
                                  Text(
                                      _selectedImageName != null
                                          ? _selectedImageName!.split('.').first +
                                          '.' +
                                          _selectedImageName!.split('.').last
                                          : "No image selected...",
                                      style: TextStyle(fontSize: 15, color: AppColors.blackColor)),
                                  // Text("No file selected...",style: TextStyle(fontSize: 15,color: AppColors.blackColor),),
                                  SizedBox(),
                                ],
                              )),
                        ),

                        //For CLient Name
                        SizedBox(
                          height: screenHeight * 0.013,
                        ),

                        singleContainer(
                          controller: _phoneController,
                          labelText: "Phone number",
                          keyboardType: TextInputType.name,
                          errorMessage: _validationErrors['phone'],
                        ),
                        SizedBox(
                          height: screenHeight * 0.013,
                        ),
                        Column(
                          children: [
                            Container(
                              height: screenHeight * 0.06,
                              width: screenWidth * 0.915,
                              decoration: BoxDecoration(
                                // border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(5),
                                // color: AppColors.navOpacity,
                                border: Border.all(
                                  color: AppColors.navButtonColor.withOpacity(0.4),
                                  width: 1,
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: screenWidth * 0.02,
                                    right: screenWidth * 0.04,
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    hint: Text('Gender'),
                                    value: _selectedGender,
                                    // value: _selectedGender ?? 'male',
                                    items: ['Male', 'Female'].map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                        // child: Text(value == 'male' ? value : camelCaseToWords(value)),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedGender = newValue;
                                        // _selectedGender = newValue == 'male' ? null : newValue;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 0),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // if (_selectedGender == null || (_selectedGender != null && _selectedGender!.isEmpty))
                            if (_selectedGender == null)
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    "The Gender is required.",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(
                          height: screenHeight * 0.013,
                        ),
                        Container(
                          height: screenHeight * 0.06,
                          width: screenWidth * 0.915,
                          decoration: BoxDecoration(
                            // border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                              color: AppColors.navOpacity),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                                labelText: "Email",
                                // prefixIcon: Icon(Icons.mark_email_unread_outlined),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.navButtonColor.withOpacity(0.4),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                              ),
                              readOnly: true,
                            ),
                          ),
                        ),

                        // singleContainer(controller: _emailController, labelText: "email", keyboardType: TextInputType.name, prefixIcon: Icon(Icons.mark_email_unread_outlined)),
                        SizedBox(
                          height: screenHeight * 0.013,
                        ),
                        singleContainer(
                          controller: _address1Controller,
                          labelText: "Address Line 1",
                          keyboardType: TextInputType.name,
                          errorMessage: _validationErrors['addressLine1'],
                        ),

                        SizedBox(
                          height: screenHeight * 0.013,
                        ),

                        singleContainer(
                          controller: _address2Controller,
                          labelText: "Address Line 2",
                          keyboardType: TextInputType.name,
                          errorMessage: _validationErrors['addressLine2'],
                        ),
                        SizedBox(
                          height: screenHeight * 0.013,
                        ),
                        singleContainer(
                          controller: _townOrCityController,
                          labelText: "Town/City",
                          keyboardType: TextInputType.name,
                          errorMessage: _validationErrors['townOrCity'],
                        ),
                        SizedBox(
                          height: screenHeight * 0.013,
                        ),
                        singleContainer(
                          controller: _postCodeController,
                          labelText: "Post Code",
                          keyboardType: TextInputType.name,
                          errorMessage: _validationErrors['postCode'],
                        ),

                        SizedBox(
                          height: screenHeight * 0.013,
                        ),
                        singleContainer(
                          controller: _medicalConditionController,
                          labelText: "Any Medical Condition",
                          keyboardType: TextInputType.name,
                          errorMessage: _validationErrors['medicalConditions'],
                        ),
                        SizedBox(
                          height: screenHeight * 0.013,
                        ),

                        // singleContainer(controller: _imageController, labelText: "image", keyboardType: TextInputType.name, prefixIcon: Icon(Icons.restaurant_menu_sharp)),

                        dateCalenderContainer(
                          controller: _dobController,
                          labelText: "Date of birth",
                          keyboardType: TextInputType.name,
                          errorMessage: _validationErrors['dob'],
                        ),
                        SizedBox(
                          height: screenHeight * 0.013,
                        ),

                        singleContainer(
                          controller: _ninController,
                          labelText: "National insurance number",
                          keyboardType: TextInputType.name,
                          errorMessage: _validationErrors['ni_number'],
                        ),


                        ///when selected role is driver
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Container(
                            // color: Colors.greenAccent,
                            child: Column(
                              children: [

                                DynamicDropdown(
                                  title: "Do you hold a valid UK driving licence?",
                                  options: _dropdownOptions,
                                  selectedOption: _selected2!, // Provide a fallback
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selected2 = newValue!;
                                      print(_selected2);
                                    });
                                  },
                                ),
                                SizedBox(height: screenHeight * .013,),

                                if (_selected2 == 'Yes') ...[
                                  DynamicDropdown(
                                    title: "Do you have UK driving experience?",
                                    options: _dropdownOptions,
                                    selectedOption: _selected1!,
                                    onChanged: (newValue) {
                                      setState(() {
                                        _selected1 = newValue!;
                                      });
                                    },
                                  ),
                                  SizedBox(height: screenHeight * .013,),
                                ],

                                if ( _selected2 == 'Yes' && _selected1 == 'Yes') ...[
                                  singleContainer(
                                    controller: _licNumberController,
                                    labelText: "Licence Number",
                                    keyboardType: TextInputType.name,
                                    errorMessage: _validationErrors['licenceNumber'],
                                  ),
                                  SizedBox(height: screenHeight * .013,),
                                ],
                                if ( _selected2 == 'Yes' && _selected1 == 'Yes' && _licNumberController.text.isNotEmpty)...[

                                  ExpiryCalenderContainer(
                                    controller: _licExpiryController,
                                    labelText: "Licence Expiry Date",
                                    keyboardType: TextInputType.name,
                                    errorMessage: _validationErrors['licenceExpiry'],
                                  ),
                                  SizedBox(height: screenHeight * .013,),
                                  singleContainer(
                                    controller: _licEndorsementController,
                                    labelText: "licence Endorsements",
                                    keyboardType: TextInputType.name,
                                    errorMessage: _validationErrors['licenceEndorsements'],
                                  ),
                                  SizedBox(height: screenHeight * .013,),

                                  dateCalenderContainer(
                                    labelText: 'Date of issue of the driving licence.',
                                    keyboardType: TextInputType.name,
                                    controller: _dateofIssueDrivingController,
                                    errorMessage: _validationErrors['driving_license_issue_date'],
                                  ),
                                  SizedBox(
                                    height: screenHeight * .013,
                                  ),
                                  singleContainer(
                                    labelText: 'Driving licence category (e.g., HGV 1, HGV 2).',
                                    controller: _drivingLicensecategoryController,
                                    keyboardType: TextInputType.name,
                                    errorMessage: _validationErrors['driving_license_category'],
                                  ),
                                  SizedBox(
                                    height: screenHeight * .013,
                                  ),
                                  singleContainer(
                                    labelText: 'Check code for driving licence.',
                                    controller: _checkCodeDrivingLicenseController,
                                    keyboardType: TextInputType.name,
                                    errorMessage: _validationErrors['driving_license_check_code'],
                                  ),
                                  SizedBox(height: screenHeight * .013,),
                                  FilePickerWidget(
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
                                    errorMessage: _validationErrors['drivingLicence'],
                                  ),
                                  SizedBox(height: screenHeight * .013,),
                                  DynamicDropdown(
                                    title: "Do you have penalty points on your licence?",
                                    options: _dropdownOptions,
                                    selectedOption: _selected3 ?? 'No', // Provide a fallback
                                    onChanged: (newValue) {
                                      setState(() {
                                        _selected3 = newValue!;
                                      });
                                    },
                                  ),


                                ]
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 0,left: 10,right: 10,),
                          child: Column(
                            children: [

                              DynamicDropdown(
                                title: "Are you a citizen of the UK?",
                                options: _dropdownOptions,
                                selectedOption: _selected11!,
                                onChanged: (newValue) {
                                  setState(() {
                                    _selected11 = newValue!;
                                  });
                                },
                              ),
                              SizedBox(
                                height: screenHeight * .009,
                              ),
                              DynamicDropdown(
                                title: "Do you have any unspent criminal convictions?",
                                options: _dropdownOptions,
                                selectedOption: _selected12!,
                                onChanged: (newValue) {
                                  setState(() {
                                    _selected12 = newValue!;
                                  });
                                },
                              ),
                              SizedBox(
                                height: screenHeight * .009,
                              ),
                              if (_selected12 == 'Yes')
                                SizedBox(
                                  height: screenHeight * .009,
                                ),
                              singleContainer(
                                  controller: pleaseSpecifyController,
                                  keyboardType: TextInputType.name,
                                  errorMessage: _validationErrors['unspent_criminal_convictions_details'],
                                  labelText: "Enter details of unspent criminal convictions"),
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
                                  });
                                },
                              ),
                              SizedBox(
                                height: screenHeight * .009,
                              ),
                            ],
                          ),
                        ),
                        // Container(
                        //   height: screenHeight * 0.06,
                        //   width: screenWidth * 0.915,
                        //   decoration: BoxDecoration(
                        //     // border: Border.all(color: Colors.grey),
                        //     borderRadius: BorderRadius.circular(5),
                        //     // color: AppColors.navOpacity,
                        //     border: Border.all(
                        //       color: AppColors.navButtonColor.withOpacity(0.4),
                        //       width: 1,
                        //     ),
                        //   ),
                        //   child: Align(
                        //     alignment: Alignment.centerLeft,
                        //     child: Padding(
                        //       padding: EdgeInsets.only(
                        //         left: screenWidth * 0.02,
                        //         right: screenWidth * 0.04,
                        //       ),
                        //       child: DropdownButtonFormField<String>(
                        //         hint: Text(
                        //           "Select Role",
                        //         ),
                        //         value: _selectedRole,
                        //         items: _roleTypes.map((role) {
                        //           return DropdownMenuItem<String>(
                        //             value: role.staffType,
                        //             child: Text(role.staffType ?? ""),
                        //           );
                        //         }).toList(),
                        //         onChanged: (String? newValue) {
                        //           setState(() {
                        //             _selectedRole = newValue ?? _selectedRole;
                        //             print("Selected Role:$_selectedRole");
                        //           });
                        //         },
                        //         decoration: InputDecoration(
                        //           contentPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 0),
                        //           border: InputBorder.none,
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // SizedBox(
                        //   height: screenHeight * 0.013,
                        // ),

                        /// if the Role consist driver
                        if (_selectedRole?.toLowerCase().contains('driver') ?? false) ...[

                          SizedBox(
                            height: screenHeight * 0.009,
                          ),

                          Container(
                            width: screenWidth * 0.9,
                            decoration: BoxDecoration(
                              color: AppColors.navOpacity.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(5.0),
                              border: Border.all(
                                color: AppColors.navButtonColor.withOpacity(0.4),
                                width: 0.4,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: screenHeight * 0.06,
                                  width: screenWidth * 0.90,
                                  decoration: BoxDecoration(
                                    color: AppColors.navOpacity.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: Expanded(
                                    child: Container(
                                      height: screenHeight * 0.065,
                                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          iconEnabledColor: AppColors.navButtonColor,
                                          iconSize: 30.0,
                                          hint: Text(
                                            'Select one or multiple licence types',
                                            style: TextStyle(fontSize: 14, color: AppColors.navButtonColor),
                                          ),
                                          items: _licenseTypes.map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(camelCaseToWords(value), style: TextStyle(fontSize: 14)),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              setState(() {
                                                if (!_selectedLicenseTypes.contains(newValue)) {
                                                  _selectedLicenseTypes.add(newValue);
                                                }
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5.0),
                                  child: Wrap(
                                    spacing: 8.0,
                                    runSpacing: 1.0,
                                    children: [
                                      // Show selected license types first
                                      ..._selectedLicenseTypes.map((type) {
                                        return Chip(
                                          label: Text(camelCaseToWords(type), style: TextStyle(color: Colors.black)),
                                          backgroundColor: AppColors.navOpacity.withOpacity(0.5),
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
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (_licenseTypeValidationError.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                              child: Text(
                                _licenseTypeValidationError,
                                style: TextStyle(color: Colors.red, fontSize: 12,fontWeight: FontWeight.bold),
                              ),
                            ),
                          // SizedBox(
                          //   height: screenHeight * 0.013,
                          // ),
                          //
                          // SizedBox(height: screenHeight * 0.013,),
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
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        " *",
                                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                                      )
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    ValueListenableBuilder(
                                      valueListenable: _isCPCCheckBoxSelected,
                                      builder: (context, value, child) {
                                        return Checkbox(
                                          value: value,
                                          onChanged: (newValue) {
                                            // _isCPCCheckBoxSelected.value = newValue!;
                                            setState(() {
                                              _isCPCCheckBoxSelected.value = newValue!;
                                              if (newValue!) {
                                                _cpcNumberController.text = '';
                                                _cpcExpiryController.text = '';
                                              }
                                            });
                                          },
                                        );
                                      },
                                    ),
                                    Text("I don't have one"),
                                  ],
                                )
                              ],
                            ),
                          ),
                          // CPC Number
                          ValueListenableBuilder(
                            valueListenable: _isCPCCheckBoxSelected,
                            builder: (context, value, child) {
                              return Column(
                                children: [
                                  CpcTestCustomContainer(
                                    titleText: 'CPC Number',
                                    titleText2: "Enter your CPC number",
                                    controller: _cpcNumberController,
                                    keyboardType: TextInputType.name,
                                    isEnabled: !value,
                                    fillColor: value ? Colors.grey[300]! : AppColors.whiteColor,
                                    labelText: 'CPC Number', // Provide the label text here
                                  ),
                                  if (!value && _cpcNumberValidationError.isNotEmpty)
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

                          ValueListenableBuilder(
                            valueListenable: _isCPCCheckBoxSelected,
                            builder: (context, value, child) {
                              return Column(
                                children: [
                                  CpcTestbuildDateContainer(
                                    'CPC Expiry',
                                    _cpcExpiryController,
                                    isEnabled: !value,
                                    fillColor: value ? Colors.grey[300]! : AppColors.whiteColor,
                                  ),
                                  if (!value && _cpcExpiryValidationError.isNotEmpty)
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
                          // SizedBox(height: screenHeight * 0.013,),

                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "TACHO CARD",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Row(
                                  children: [
                                    ValueListenableBuilder(
                                      valueListenable: _isTachoCheckBoxSelected,
                                      builder: (context, value, child) {
                                        return Checkbox(
                                          value: value,
                                          onChanged: (newValue) {
                                            _isTachoCheckBoxSelected.value = newValue!;

                                            setState(() {
                                              _isTachoCheckBoxSelected.value = newValue!;
                                              if (newValue!) {
                                                _techoNumberFileController.text = '';
                                              }
                                            });
                                          },
                                        );
                                      },
                                    ),
                                    Text("I don't have one"),
                                  ],
                                )
                              ],
                            ),
                          ),
                          // CPC Number
                          ValueListenableBuilder(
                            valueListenable: _isTachoCheckBoxSelected,
                            builder: (context, value, child) {
                              return Column(
                                children: [
                                  CpcTestCustomContainer(
                                    titleText: 'Tacho Number',
                                    titleText2: "Enter your Tacho number",
                                    controller: _techoNumberFileController,
                                    keyboardType: TextInputType.name,
                                    labelText: 'Tacho Number',
                                    isEnabled: !value,
                                    fillColor: value ? Colors.grey[300]! : AppColors.whiteColor,
                                  ),
                                  if (!value && _tachNumberValidationError.isNotEmpty)
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

                          ValueListenableBuilder(
                            valueListenable: _isTachoCheckBoxSelected,
                            builder: (context, value, child) {
                              return Column(
                                children: [
                                  CpcTestbuildDateContainer(
                                    'Tacho Expiry',
                                    _tachoExpiryController,
                                    isEnabled: !value,
                                    fillColor: value ? Colors.grey[300]! : AppColors.whiteColor,
                                  ),
                                  if (!value && _tachoExpiryValidationError.isNotEmpty)
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


                          SizedBox(height: screenHeight * .013,),
                          CheckFilePickerWidget(
                              title: "Upload CPC",
                              screenWidth: screenWidth,
                              screenHeight: screenHeight,
                              onFilePicked: (Uint8List? fileData, String? fileName) {
                                setState(() {
                                  _selectedFile2 = fileData;
                                  _selectedFileName2 = fileName; // Update the selected file name
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
                                print('CPC checkbox is checked: $_isCPCUploaded');
                                _updateCPCValidationError(null);
                              },
                              errorMessage: _validationErrors['cpc']),



                          SizedBox(height: screenHeight * .013),
                          CheckFilePickerWidget(
                              title: "Upload Tacho ",
                              screenWidth: screenWidth,
                              screenHeight: screenHeight,
                              onFilePicked: (Uint8List? fileData, String? fileName) {
                                setState(() {
                                  _selectedFile3 = fileData;
                                  _selectedFileName3 = fileName; // Update the selected file name
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
                                print('UploadTacho checkbox is checked: $_isTachoUploaded');
                                _updateTachoValidationError(null);
                              },
                              errorMessage: _validationErrors['tacho']),
                          SizedBox(
                            height: screenHeight * 0.013,
                          ),

                          /// New Driving Fields

                        ],

                        ///ROle
                      ],
                    ),
                  );
                }
              },
            ),
          ),
          SizedBox(
            height: screenHeight * .02,
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
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                  ),
                  DynamicDropdown(
                    title: "Do you have a Right to Work in the UK?",
                    options: _dropdownOptions,
                    selectedOption: _selectedOption1!,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedOption1 = newValue!;
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
                      });
                    },
                  ),
                  SizedBox(height: screenHeight * .013),
                  if (_selectedOption2 == 'Yes')
                    dateCalenderContainer(
                      controller: _dbsExpiryController,
                      labelText: "DBS Expiry",
                      keyboardType: TextInputType.name,
                      errorMessage: _validationErrors['dbsExpiry'],
                    ),
                  SizedBox(height: screenHeight * .013),
                  DynamicDropdown(
                    title: "Do you want to opt out of the Pension Scheme?",
                    options: _dropdownOptions,
                    selectedOption: _selectedOption3!,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedOption3 = newValue!;
                      });
                    },
                  ),
                  SizedBox(height: screenHeight * .013),
                ],
              ),
            ),
          ),
          SizedBox(
            height: screenHeight * .013,
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
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                  ),
                  DynamicDropdown(
                    title: "Do you have any physical incapabilities?",
                    options: _dropdownOptions,
                    selectedOption: _selected4!,
                    onChanged: (newValue) {
                      setState(() {
                        _selected4 = newValue!;
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
                      });
                    },
                  ),
                  SizedBox(height: screenHeight * .013),
                  if (_selected5 == 'Yes')
                    singleContainer(
                      labelText: 'Details of medical conditions, if any.',
                      controller: _detailMedicalConditionController,
                      keyboardType: TextInputType.name,
                      errorMessage: _validationErrors['medical_condition_details'],
                    ),
                  SizedBox(height: screenHeight * .013),
                  DynamicDropdown(
                    title: "Are you currently taking any medication?",
                    options: _dropdownOptions,
                    selectedOption: _selected6!,
                    onChanged: (newValue) {
                      setState(() {
                        _selected6 = newValue!;
                      });
                    },
                  ),
                  SizedBox(height: screenHeight * .013),
                  if (_selected6 == 'Yes')
                    singleContainer(
                      labelText: 'Details of medication, if any.',
                      controller: _detailOfMedicationController,
                      keyboardType: TextInputType.name,
                      errorMessage: _validationErrors['medication_details'],
                    ),
                  SizedBox(height: screenHeight * .013),
                  DynamicDropdown(
                    title: "Do you have ongoing issues with drugs or alcohol?",
                    options: _dropdownOptions,
                    selectedOption: _selected7!,
                    onChanged: (newValue) {
                      setState(() {
                        _selected7 = newValue!;
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
                      });
                    },
                  ),
                  SizedBox(height: screenHeight * .013),
                  dateCalenderContainer(
                    keyboardType: TextInputType.name,
                    labelText: 'When was your last eye test?',
                    controller: _lasteyeController,
                    errorMessage: _validationErrors['last_eye_test'],
                  ),
                  SizedBox(height: screenHeight * .013),
                  DynamicDropdown(
                    title: "Have you ever been dismissed for medical reasons?",
                    options: _dropdownOptions,
                    selectedOption: _selected9!,
                    onChanged: (newValue) {
                      setState(() {
                        _selected9 = newValue!;
                      });
                    },
                  ),
                  SizedBox(height: screenHeight * .013),
                  if (_selected9 == 'Yes')
                    singleContainer(
                      labelText: 'Reason for dismissal due to medical reasons.',
                      controller: _reasonForDismissalController,
                      keyboardType: TextInputType.name,
                      errorMessage: _validationErrors['dismissal_reason'],
                    ),
                  SizedBox(height: screenHeight * .013),
                  DynamicDropdown(
                    title: "Have you been dismissed from previous driving roles in the last 3 years?",
                    options: _dropdownOptions,
                    selectedOption:  _selected10!,
                    onChanged: (newValue) {
                      setState(() {
                        _selected10 = newValue!;
                      });
                    },
                  ),
                  SizedBox(height: screenHeight * .013),
                  if (_selected10 == 'Yes')
                    singleContainer(
                      labelText: 'Reasons/dates for dismissal from driving roles.',
                      controller: _reasondatesForDrivingRolesController,
                      keyboardType: TextInputType.name,
                      errorMessage: _validationErrors['driving_dismissal_details'],
                    ),
                ],
              ),
            ),
          ),

          SizedBox(
            height: screenHeight * .02,
          ),
          Container(
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
              Padding(
                padding: EdgeInsets.only(left: 10, top: 10),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Compliance Documents",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    )),
              ),
              SizedBox(
                height: screenHeight * .013,
              ),
              singleContainer(
                controller: _passportNumberController,
                labelText: "Passport Number",
                keyboardType: TextInputType.text,
                errorMessage: _validationErrors['passportNumber'],
              ),

              // CheckFilePickerWidget(
              //     title: "Upload Passport",
              //     screenWidth: screenWidth,
              //     screenHeight: screenHeight,
              //     onFilePicked: (Uint8List? fileData, String? fileName) {
              //       setState(() {
              //         _selectedFile1 = fileData;
              //         _selectedFileName1 = fileName;
              //       });
              //     },
              //     checkselectedFileName: _selectedFileName1,
              //     onCheckboxChanged: (bool? value) {
              //       setState(() {
              //         _isPassportUploaded = value ?? false;
              //         if (_isPassportUploaded) {
              //           _selectedFile1 = null;
              //           _selectedFileName1 = null;
              //         }
              //       });
              //       print(
              //           'Upload Passport checkbox is checked: $_isPassportUploaded');
              //       _updatePassportValidationError(null);
              //     },
              //     errorMessage: _validationErrors['passport']),
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
                  errorMessage: _validationErrors['passport']),

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
            height: screenHeight * .02,
          ),
          InkWell(
            onTap: () async {
              _updateProfile();
            },
            child: Container(
              height: screenHeight * 0.05,
              width: screenWidth * 0.4,
              decoration: BoxDecoration(
                color: AppColors.navButtonColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    offset: Offset(0, 2),
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: isLoading
                    ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    )) // Show loading indicator if _isLoading is true
                    : AutoSizeText(
                  "Update",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          SizedBox(
            height: screenHeight * .1,
          ),
        ],
      ),
    );
  }


  Widget singleContainer({
    required TextEditingController controller,
    required String labelText,
    required TextInputType keyboardType,
    String? errorMessage,
    void Function(String)? onChanged,
    // required Icon prefixIcon,
  }) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return Column(
      children: [
        Container(
          height: screenHeight * 0.06,
          width: screenWidth * 0.915,
          decoration: BoxDecoration(
            // border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              // focusNode: controller,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                labelText: labelText,
                // prefixIcon: prefixIcon,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.navButtonColor.withOpacity(0.4),
                  ),
                ),

                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              onChanged:onChanged,
            ),
          ),
        ),
        if (errorMessage != null && errorMessage.isNotEmpty) // Render error message only if not empty
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: screenWidth * 0.90,
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
          ),
      ],
    );
  }

  Widget doubleContainer({
    required TextEditingController controller,
    required String labelText,
    required TextInputType keyboardType,
    String? errorMessage,
    // required Icon prefixIcon,
  }) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: screenHeight * 0.06,
          width: screenWidth * 0.45,
          decoration: BoxDecoration(
            // border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              // focusNode: controller,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                labelText: labelText,
                // prefixIcon: prefixIcon,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.navButtonColor.withOpacity(0.4),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
          ),
        ),
        if (errorMessage != null && errorMessage.isNotEmpty) // Render error message only if not empty
          Text(
            errorMessage,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
      ],
    );
  }

  Widget FirstContainer({
    required TextEditingController controller,
    required String labelText,
    required TextInputType keyboardType,
    String? errorMessage,
    // required Icon prefixIcon,
  }) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: screenHeight * 0.06,
          width: screenWidth * 0.6,
          decoration: BoxDecoration(
            // border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              // focusNode: controller,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                labelText: labelText,
                // prefixIcon: prefixIcon,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.navButtonColor.withOpacity(0.4),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
          ),
        ),
        if (errorMessage != null && errorMessage.isNotEmpty) // Render error message only if not empty
          Text(
            errorMessage,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
      ],
    );
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
        Container(
          // height: screenHeight*0.065,
          width: screenWidth * 0.915,
          decoration: BoxDecoration(
            // border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              readOnly: true,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.navButtonColor.withOpacity(0.4),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                labelText: labelText,
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
                  String formattedDate =
                      "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                  controller.text = formattedDate;
                }
              },
            ),
          ),
        ),
        if (errorMessage != null && errorMessage.isNotEmpty) // Render error message only if not empty
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

  Widget ExpiryCalenderContainer({
    required TextEditingController controller,
    required String labelText,
    required TextInputType keyboardType,
    String? errorMessage,
  }) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;

    return Column(
      children: [
        Container(
          height: screenHeight * 0.06,
          width: screenWidth * 0.9,
          decoration: BoxDecoration(
            // border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              readOnly: true,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.navButtonColor.withOpacity(0.4),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                labelText: labelText,
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
                DateTime currentDate = DateTime.now();
                DateTime? pickedDate = await showDatePicker(
                  initialEntryMode: DatePickerEntryMode.calendarOnly,
                  context: context,
                  initialDate: initialDate,
                  firstDate: currentDate,
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
                  String formattedDate =
                      "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                  controller.text = formattedDate;
                }
                // if (pickedDate != null) {
                //   String formattedDate =
                //       "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day}";
                //   controller.text = formattedDate;
                // }
              },
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  DateTime selectedDate = DateTime.parse(value);
                  if (selectedDate.isBefore(DateTime.now())) {
                    return 'Please select a future date or today\'s date.';
                  }
                }
                return null;
              },
            ),
          ),
        ),
        if (errorMessage != null && errorMessage.isNotEmpty) // Render error message only if not empty
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: screenWidth * 0.90,
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
        Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
            )),
        SizedBox(height: screenHeight * 0.013),
        Container(
          height: screenHeight * 0.06,
          width: screenWidth * 0.915,
          decoration: BoxDecoration(
            color: AppColors.navOpacity.withOpacity(0.4),
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
                  color: AppColors.navOpacity,
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
      ],
    );
  }

  Widget CpcTestCustomContainer({
    required String titleText,
    required String titleText2,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required bool isEnabled,
    required Color fillColor,
    String? labelText, // Add this line
    // Widget? prefixIcon, // Add this line
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        // SizedBox(height: screenHeight * .013),

        Container(
          height: screenHeight * 0.06,
          width: screenWidth * 0.90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: isEnabled ? fillColor : Colors.grey.withOpacity(0.5),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              enabled: isEnabled,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.navButtonColor.withOpacity(0.4),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                border: InputBorder.none,
                labelText: labelText, // Use the labelText parameter here
                // prefixIcon: prefixIcon, // Use the prefixIcon parameter here
              ),
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
        borderRadius: BorderRadius.circular(5),
        color: isEnabled ? fillColor : Colors.grey.withOpacity(0.5),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.datetime,
        readOnly: true,
        enabled: isEnabled,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          labelText: labelText,
          // prefixIcon: Icon(
          //   Icons.calendar_month_outlined,
          //   color: Colors.black,
          // ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.navButtonColor.withOpacity(0.4),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
        onTap: isEnabled
            ? () async {
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
            firstDate: initialDate,
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
          // if (pickedDate != null) {
          //   setState(() {
          //     controller.text = pickedDate.toString().substring(0, 10);
          //   });
          // }
          if (pickedDate != null) {
            String formattedDate =
                "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
            controller.text = formattedDate;
          }
        }
            : null,
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
    String? placeholder, // New optional parameter for placeholder
    Function(String)? onChanged, // Callback to handle real-time validation
    Function(String)? onFieldSubmitted, // Callback for field submit (validation when moving to next)
  }) {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;

    return Column(
      children: [
        // For TitleText
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 10),
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
}

