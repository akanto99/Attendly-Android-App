import 'dart:convert';
import 'dart:typed_data';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:c9_app/Modules/StaffModule/MODEL/staff_registrationModel/ConsultantNames.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/model/Registration/candidateStaffRole.dart';
import 'package:c9_app/view/splash&login/Registration/final_multistep/All_Steps/Widgets/customtext_with_formfield.dart';
import 'package:c9_app/view/splash&login/Registration/final_multistep/All_Steps/Widgets/datepicker_with_formField.dart';
import 'package:c9_app/view/splash&login/Registration/final_multistep/All_Steps/Widgets/image_with_formField.dart';
import 'package:c9_app/view/splash&login/Registration/final_multistep/All_Steps/Widgets/passwordText_with_formfield.dart';
import 'package:c9_app/view/splash&login/Registration/multiscreen/AllSection/personalSection.dart';
import 'package:c9_app/view/splash&login/login_view.dart';
import 'package:c9_app/view/widgets/customTextField.dart';
import 'package:c9_app/view/widgets/custom_Validator_formfield.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as https;
import '../../../../../utils/utils.dart';

class PersonalStep1 extends StatefulWidget {
  final ScrollController scrollController;
  final GlobalKey<FormState> formKey;
  final VoidCallback onStep1;
  final Function(String) onRoleChange;
  final Function(String) onDBSChanged;

  PersonalStep1({
    Key? key,
    required this.scrollController,
    required this.onStep1,
    required this.formKey,
    required this.onRoleChange,
    required this.onDBSChanged,
  }) : super(key: key);

  @override
  _PersonalStep1State createState() => _PersonalStep1State();
}

class _PersonalStep1State extends State<PersonalStep1> {
  ///Section---------------------------------------------1
  late TextEditingController firstnameController;
  late TextEditingController lastnameController;
  String? selectedGender;
  Uint8List? _selectedImageData;
  String? _selectedImageName;
  String? imageValidationError;
  late TextEditingController dobController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController reEnterpasswordController;
  ValueNotifier<bool> _obsecurePassword = ValueNotifier<bool>(true);
  ValueNotifier<bool> _reobsecurePassword = ValueNotifier<bool>(true);
  ValueNotifier<bool> _isPasswordMatching = ValueNotifier<bool>(true);
  void _checkPasswordMatch() {
    _isPasswordMatching.value = passwordController.text == reEnterpasswordController.text;
  }
  ///Section---------------------------------------------2
  late TextEditingController address1Controller;
  late TextEditingController address2Controller;
  late TextEditingController townCityController;
  late TextEditingController postCodeController;
  late TextEditingController phoneController;
  late TextEditingController alterphoneController;
  late TextEditingController emgNameController;
  late TextEditingController emgNumController;
  ///Section---------------------------------------------3
  List<Data> _roleTypes = [];
  String? _selectStaffRole;
  String? selectedCM;

  List<ConsultantNames> consultantNames = [];
  List<ConsultantNames> filteredConsultants = [];
  bool _isExpanded = false;
  FocusNode consultantFocusNode = FocusNode();
  late TextEditingController consultantController;

  late TextEditingController passportNumController;
  late TextEditingController nationalNumController;

  final List<String> _dropdownOptions = ['Yes', 'No'];
  String? selectedCitizenUk;
  String? selectedRightToWork;
  String? selectedOptOut;
  String? selectedDBS;
  final List<String> _conditionalOptions = ['Not Applicable', 'Basic DBS', 'Enhanced DBS'];
  String? selectedDBSCheckType;
  String? selectedMaritalStatus;
  String? selectedonCriminalConviction;
  late TextEditingController specifyController;
  late TextEditingController niNumberController;


  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    fetchStaffRoles();
    ///section-----------------------------------1
    firstnameController = TextEditingController();
    lastnameController = TextEditingController();
    selectedGender;
    _selectedImageData;
    imageValidationError = null;
    dobController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    reEnterpasswordController = TextEditingController();

    ///section-----------------------------------2
    address1Controller = TextEditingController();
    address2Controller = TextEditingController();
    townCityController = TextEditingController();
    postCodeController = TextEditingController();
    phoneController = TextEditingController();
    alterphoneController = TextEditingController();
    emgNameController = TextEditingController();
    emgNumController = TextEditingController();

    ///Section-----------------------------------3
  _selectStaffRole;
    selectedCM;
    consultantController = TextEditingController();
    fetchConsultantNames();
    consultantFocusNode.addListener(() {
      if (!consultantFocusNode.hasFocus) {
        setState(() {
          _isExpanded = false;
        });
      }
    });
    passportNumController= TextEditingController();
    nationalNumController= TextEditingController();
    selectedCitizenUk;
    selectedRightToWork;
    selectedOptOut;
    selectedDBS;
    selectedDBSCheckType;
    selectedMaritalStatus;
    selectedonCriminalConviction;
    specifyController = TextEditingController();

    _loadFormData();
  }

  Future<void> _loadFormData() async {
    final prefs = await SharedPreferences.getInstance();

    String? storedMaritalStatus = prefs.getString('maritalStatus');
    print("Loaded marital status before setState: $selectedMaritalStatus");
    setState(() {
      selectedMaritalStatus = storedMaritalStatus ?? '---Select One---';
    });


    setState(() {
      ///Personal Section-----------------------------------------------1
      firstnameController.text = prefs.getString('first_name') ?? '';
      lastnameController.text = prefs.getString('last_name') ?? '';
      _selectedImageName = prefs.getString('imageName');
      selectedGender = prefs.getString('gender') ?? '---Select One---';
      String? base64Image = prefs.getString('image');
      if (base64Image != null) {
        _selectedImageData = base64Decode(base64Image);
      }
      dobController.text = prefs.getString('dob') ?? '';
      emailController.text = prefs.getString('email') ?? '';
      _selectStaffRole = prefs.getString('role') ?? '---Select One---';

      ///Section------------------------------------------------------------2
      address1Controller.text = prefs.getString('addressLine1') ?? '';
      address2Controller.text = prefs.getString('addressLine2') ?? '';
      townCityController.text = prefs.getString('townorcity') ?? '';
      postCodeController.text = prefs.getString('postCode') ?? '';
      phoneController.text = prefs.getString('phone') ?? '';
      alterphoneController.text = prefs.getString('alt_phone') ?? '';
      emgNameController.text = prefs.getString('emergency_name') ?? '';
      emgNumController.text = prefs.getString('emergency_phone') ?? '';

      ///Section------------------------------------------------------------3
      selectedCM = prefs.getString('prefsMethod') ?? '---Select One---';
      consultantController.text = prefs.getString('consultant') ?? '';
      passportNumController.text = prefs.getString('passportNumber') ?? '';
      nationalNumController.text = prefs.getString('ni_number') ?? '';
      selectedCitizenUk = prefs.getString('CitizenUk');
      selectedRightToWork = prefs.getString('rightToWorkUK');
      selectedOptOut = prefs.getString('optOutOfPension');
      selectedDBS = prefs.getString('dbsCheck');
      selectedDBSCheckType = prefs.getString('DBSCheckType');
      selectedonCriminalConviction= prefs.getString('criminalConviction');
      specifyController.text = prefs.getString('specify') ?? '';
    });
  }
  Future<void> _saveFormData() async {
    final prefs = await SharedPreferences.getInstance();
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
    prefs.setString('alt_phone', alterphoneController.text);
    prefs.setString('emergency_name', emgNameController.text);
    prefs.setString('emergency_phone', emgNumController.text);

    ///Section-3
    if (_selectStaffRole != null) prefs.setString('role', _selectStaffRole!);
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
  void filterConsultants(String query) {
    setState(() {
      filteredConsultants = query.isNotEmpty
          ? consultantNames
          .where((consultant) => consultant.name?.toLowerCase().contains(query.toLowerCase()) ?? false)
          .toList()
          : consultantNames;
    });
  }


  Future<void> _postPersonalSection() async {
    print("-------------API Hit for Step--------------");
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

      /// Personal Section---------------------------------------1
      request.fields['first_name'] = firstnameController.text;
      request.fields['last_name'] = lastnameController.text;
      request.fields['gender'] = selectedGender ?? '';
      if (dobController.text.isNotEmpty) {
        request.fields['dob'] = DateFormat('dd/MM/yyyy').format(DateFormat('dd/MM/yyyy').parse(dobController.text));
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
      /// Personal Section---------------------------------------2
      request.fields['addressLine1'] = address1Controller.text;
      request.fields['addressLine2'] = address2Controller.text;
      request.fields['townorcity'] = townCityController.text;
      request.fields['postCode'] = postCodeController.text;
      request.fields['phone'] = phoneController.text;
      request.fields['alt_phone'] = alterphoneController.text;
      request.fields['emergency_name'] = emgNameController.text;
      request.fields['emergency_phone'] = emgNumController.text;

      /// Personal Section---------------------------------------3
      request.fields['role'] = _selectStaffRole ?? '';
      print("------------------------selected-----${_selectStaffRole}");
      request.fields['communication_method'] = selectedCM ?? '';
      request.fields['consultant'] = consultantController.text;
      request.fields['passportNumber'] = passportNumController.text;
      request.fields['ni_number'] = nationalNumController.text;
      // request.fields['medicalConditions'] = medicalController.text;
      request.fields['is_uk_citizen'] = selectedCitizenUk == 'Yes' ? '1' : '0';
      request.fields['rightToWorkUK'] = selectedRightToWork == 'Yes' ? '1' : '0';
      request.fields['dbsCheck'] = selectedDBS == 'Yes' ? '1' : '0';
      if(selectedDBS == 'Yes') {
        request.fields['dbs_check_type'] = selectedDBSCheckType == 'Yes' ? '1' : '0';
      }
      request.fields['optOutOfPension'] = selectedOptOut == 'Yes' ? '1' : '0';
      request.fields['marital_status'] = selectedMaritalStatus ?? '';
      request.fields['has_unspent_criminal_convictions'] = selectedonCriminalConviction == 'Yes' ? '1' : '0';
      if(selectedonCriminalConviction== 'Yes'){
        request.fields['unspent_criminal_convictions_details'] = specifyController.text;
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
      } else if (response.statusCode == 422) {
        // Parse the validation errors
        final responseData = jsonDecode(responseString) as Map<String, dynamic>;
        if (responseData.containsKey('errors')) {
          final validationErrors = responseData['errors'] as Map<String, dynamic>;
          Navigator.pop(context);
        }
        // Utils.flushBarErrorMessage('Validation error: $responseString', context);
      } else {
        Utils.flushBarErrorMessage('Error: $responseString', context);
      }
    } catch (e) {
      print("An error occurred: $e");
      Utils.flushBarErrorMessage('An error occurred: $e', context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return SingleChildScrollView(
      // controller: _scrollController,
      child: Form(
        key: widget.formKey,
        child: Column(children: [
          ///Personal Section-----------------------1
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
                CustomTextFieldWithFormField(
                  titleText: "Full Name",
                  requiredStar: "*",
                  placeholder: 'Enter your first name',
                  controller: firstnameController,
                  validator: (value) {
                    if (firstnameController.text == null || firstnameController.text.isEmpty) {
                      return 'First name is required';
                    }
                    if (firstnameController.text.length < 3) {
                      return 'First name must be at least 3 characters long.';
                    }
                    if (RegExp(r'^[^a-zA-Z]').hasMatch(firstnameController.text)) {
                      return 'First name cannot start with a space, special character, or number.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * .013,),
                CustomTextFieldWithFormField(
                  titleText: 'Last Name',
                  requiredStar: "*",
                  placeholder: 'Enter your last name',
                  controller: lastnameController,
                  focusNext: null,
                  validator: (value) {
                    if (lastnameController.text == null || lastnameController.text.isEmpty) {
                      return 'Last name is required';
                    }
                    if (lastnameController.text.length < 3) {
                      return 'Last name must be at least 3 characters long.';
                    }
                    if (RegExp(r'^[^a-zA-Z]').hasMatch(lastnameController.text)) {
                      return 'Last name cannot start with a space, special character, or number.';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: screenHeight * .013,
                ),
                _buildGenderDropdown(),
                SizedBox(
                  height: screenHeight * .013,
                ),
                CustomImagePickerWithFormField(
                  titleText: "Image",
                  requiredStar: "*",
                  chooseText: "Choose image",
                  imageFile:"No image chosen",
                  selectedImageName: _selectedImageName,
                  onTap: () async {
                    await _pickImage(ImageSource.gallery);
                  },
                  onImagePicked: (state) {
                    state.didChange(_selectedImageName);
                  },
                  validator: (value) {
                    if (_selectedImageData == null || _selectedImageData!.isEmpty) {
                      return 'Image is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * .013,),
                CustomDatePickerFormField(
                  title: "Date of Birth",
                  labelText: 'dd/mm/yyyy',
                  controller: dobController,
                  validator: (value) {
                    if (dobController.text == null || dobController.text.isEmpty) {
                      return 'Date of birth is required';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: screenHeight * .013,
                ),
                CustomTextFieldWithFormField(
                  titleText: 'Email',
                  requiredStar: "*",
                  placeholder: 'Enter your email address',
                  controller: emailController,
                  validator: (value) {
                    if (emailController.text == null || emailController.text.isEmpty || !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(emailController.text)) {
                      return 'A valid email is required.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * .013,),
                PasswordField(
                  controller: passwordController,
                  label: "Password",
                  obscurePasswordNotifier: _obsecurePassword,
                  keyboardType: TextInputType.text,
                    validator: (value) {
                          if (passwordController.text.isEmpty) {
                            return 'Password is required.';
                          }
                          if (passwordController.text.length < 8) {
                            return 'Password must be at least 8 characters.';
                          }
                          return null; // Valid input
                        },
                  onChanged: (value) {
                    _checkPasswordMatch();
                  },
                ),
                SizedBox(height: screenHeight * .013,),
                PasswordField(
                  controller: reEnterpasswordController,
                  label: "Re-Enter Password",
                  obscurePasswordNotifier: _reobsecurePassword,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (reEnterpasswordController.text.isEmpty) {
                      return 'Please re-enter your password.';
                    }
                    if (reEnterpasswordController.text.length < 8) {
                      return 'Password must be at least 8 characters long.';
                    }
                    if (reEnterpasswordController.text != passwordController.text) {
                      return 'Not match';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _checkPasswordMatch();
                  },
                ),
                SizedBox(height: screenHeight * .013,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: screenWidth*0.1,),
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _isPasswordMatching,
                        builder: (context, value, child) {
                          // Using `value` directly here
                          if (passwordController.text.isNotEmpty &&
                              reEnterpasswordController.text.isNotEmpty &&
                              passwordController.text == reEnterpasswordController.text) {
                            return Text(
                              "Password matched",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            );
                          }
                          return SizedBox.shrink(); // Return empty space if conditions aren't met
                        }
                          ),
                    ),
                  ],
                ),

              ],
            ),
          ),


          SizedBox(height: screenHeight * .013,),
          Container(
            height: 45,
            width: screenWidth*0.95,
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
                CustomTextFieldWithFormField(
                  titleText: 'Address Line 1',
                  requiredStar: "*",
                  placeholder: 'Enter your address line 1',
                  controller: address1Controller,
                  validator: (value) {
                    // Check if the field is empty or invalid
                    if (address1Controller.text == null || address1Controller.text.isEmpty) {
                      return 'Address Line 1 is required';
                    }
                    return null; // Valid input
                  },
                ),
                SizedBox(height: screenHeight * .013,),
                CustomTextFieldWithFormField(
                  titleText: 'Address Line 2',
                  requiredStar: "*",
                  placeholder: 'Enter your address line 2',
                  controller: address2Controller,
                  validator: (value) {
                    if (address2Controller.text == null || address2Controller.text.isEmpty) {
                      return 'Address Line 2 is required';
                    }
                    return null; // Valid input
                  },
                ),

                SizedBox(height: screenHeight * .013,),
                CustomTextFieldWithFormField(
                  titleText: 'Town/City',
                  placeholder: 'Enter your town city',
                  controller:townCityController,
                  validator: (value) {
                    if (townCityController.text == null || townCityController.text.isEmpty) {
                      return 'Town or City address must be required.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * .013,),
                CustomTextFieldWithFormField(
                  titleText: 'Post Code',
                  requiredStar: "*",
                  placeholder: 'Enter your post code',
                  controller: postCodeController,
                  validator: (value) {
                    if (postCodeController.text == null || postCodeController.text.isEmpty) {
                      return 'Post Code is required.';
                    } else if (postCodeController.text.length >=8) {
                      return 'Post Code must be less than or equal to 8 characters.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * .013,),
                CustomTextFieldWithFormField(
                  titleText: 'Phone Number',
                  requiredStar: "*",
                  placeholder: 'Enter your phone number',
                  controller: phoneController,
                  validator: (value) {
                    if (phoneController.text == null || phoneController.text.isEmpty || !RegExp(r'^(?:\+44|0)7\d{9}$').hasMatch(phoneController.text)) {
                      return 'Phone number must be a valid UK phone number';
                    }
                    return null; // Valid input
                  },
                ),
                SizedBox(height: screenHeight * .013,),
                CustomTextFieldWithFormField(
                  titleText: 'Alternative Phone Number',
                  requiredStar: "*",
                  placeholder: 'Enter your alternative phone number',
                  controller: alterphoneController,
                  validator: (value) {
                    if (alterphoneController.text == null || alterphoneController.text.isEmpty || !RegExp(r'^(?:\+44|0)7\d{9}$').hasMatch(alterphoneController.text)) {
                      return 'Alternative phone number must be a valid UK phone number';
                    }
                    return null; // Valid input
                  },
                ),
                SizedBox(height: screenHeight * .013,),
                CustomTextFieldWithFormField(
                  titleText: 'Emergency Contact Name',
                  requiredStar: "*",
                  placeholder: 'Enter your emergency contact name',
                  controller: emgNameController,
                  validator: (value) {
                    // Check if the field is empty or invalid
                    if (emgNameController.text == null || emgNameController.text.isEmpty) {
                      return 'Emergency contact name is required.';
                    } else if (emgNameController.text.length < 3) {
                      return 'Emergency contact name must be at least 3 characters long.';
                    }
                    return null; // Valid input
                  },
                ),
                SizedBox(height: screenHeight * .013,),
                CustomTextFieldWithFormField(
                  titleText: 'Emergency Contact Number',
                  requiredStar: "*",
                  placeholder: 'Enter your emergency contact number',
                  controller: emgNumController,
                  validator: (value) {
                    if (emgNumController.text == null || emgNumController.text.isEmpty || !RegExp(r'^(?:\+44|0)7\d{9}$').hasMatch(emgNumController.text)) {
                      return 'Emergency Contact number must be a valid UK phone number.';
                    }
                    return null; // Valid input
                  },
                ),
                SizedBox(height: screenHeight * .013,),
              ],
            ),
          ),


          SizedBox(height: screenHeight * .013),
          Container(
            height: 45,
            width: screenWidth*0.95,
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
                Column(
                  children: [
                    // SizedBox(height: screenHeight * .013),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        width: screenWidth * 0.90,
                        child: Row(
                          children: [
                            Text(
                              'Worker Role',
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(fontSize: 15),
                              fontWeight: FontWeight.bold,
                            )),
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
                        initialValue: _selectStaffRole ?? '---Select One---',
                        validator: (value) {
                          // Add your validation logic here
                          if (value == null || value.isEmpty || value == '---Select One---') {
                            return 'Worker role is required';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        builder: (FormFieldState<String> state) {
                          return Column(
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
                                    isExpanded: true,
                                    iconSize: 30.0,
                                    hint: Text(
                                      _selectStaffRole ?? '---Select One---'
                                    ),
                                    items: _roleTypes.map((Data role) {
                                      return DropdownMenuItem<String>(
                                        value: role.staffType,
                                        child: Text(
                                          role.staffType ?? ''
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
                        }),
                  ],
                ),
                SizedBox(height: screenHeight * .013,),
                // _buildMeritalDropdown(),
                _buildDropdown(
                  titleText: "Marital Status",
                  requiredStar: true,
                  initialValue: selectedMaritalStatus,
                  options: ['Single', 'Married', 'Divorced', 'Widowed', 'Separated'],
                  onSelectionChange: (value) {
                    setState(() {
                      selectedMaritalStatus = value;
                    });
                  },
                  sharedPrefsKey: 'maritalStatus',
                  validator: (value) {
                    if (value == null || value.isEmpty || value == '---Select One---') {
                      return 'Marital Status is required';
                    }
                    return null;
                  },
                ),

                SizedBox(height: screenHeight * .013,),
                _buildDropdown(
                  titleText: "Preferred Communication Method",
                  requiredStar: true,
                  initialValue: selectedCM,
                  options: ['Email', 'Phone'],
                  onSelectionChange: (value) {
                    setState(() {
                      selectedCM = value;
                    });
                  },
                  sharedPrefsKey: 'prefsMethod',
                  validator: (value) {
                    if (value == null || value.isEmpty || value == '---Select One---') {
                      return 'Preferred Communication Status is required';
                    }
                    return null;
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
                              'Consultant Name: (Optional)',
                        style: GoogleFonts.openSans(
                            textStyle: TextStyle(fontSize: 15),
                        fontWeight: FontWeight.bold,
                      )),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: screenHeight * 0.055,
                      width: screenWidth * 0.90,
                      decoration: BoxDecoration(
                        color: Color(0xffF2F5F6),
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(
                          color: Color(0xffEAECED),
                          width: 1,
                        ),
                      ),
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
                    if (_isExpanded && filteredConsultants.isNotEmpty)
                      Container(
                        height: screenHeight * 0.15,
                        width: screenWidth * 0.9,
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
                            shrinkWrap: true, // Prevents infinite height error
                            physics: NeverScrollableScrollPhysics(), // Prevents conflicts with parent scroll
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
                            },
                          ),
                        ),
                      ),
                SizedBox(height: screenHeight * .013,),

                SizedBox(height: screenHeight * .013,),
                CustomTextFieldWithFormField(
                  titleText: 'Passport Number',
                  requiredStar: "*",
                  placeholder: 'Enter your passport number',
                  controller: passportNumController,
                  validator: (value) {
                    final ukPassportRegex = RegExp(r'^[A-Z]{2}[0-9]{7}$');
                    if (passportNumController.text  == null || passportNumController.text .isEmpty) {
                      return 'Passport Number is required.';
                    } else if (!ukPassportRegex.hasMatch(passportNumController.text)) {
                      return 'Invalid passport number. It must start with 2 uppercase letters followed by 7 digits.';
                    }
                    return null; // Valid input
                  },
                ),
                SizedBox(
                  height: screenHeight * .013,
                ),
                CustomTextFieldWithFormField(
                  titleText: 'National Insurance Number',
                  requiredStar: "*",
                  placeholder: 'Enter your national insurance number',
                  controller: nationalNumController,
                  focusNext: null,
                  validator: (value) {
                    final niNumberRegex = RegExp(
                      r'^(?![DFIQUV]{2})(?![DFIQUV])[A-CEGHJ-NOPRSTW-Z]{2}\d{6}[A-D]$',
                    );
                    if (nationalNumController.text  == null || nationalNumController.text .isEmpty) {
                      return 'National Insurance number is required.';
                    } else if (!niNumberRegex.hasMatch(nationalNumController.text )) {
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
                  selectedOption: selectedCitizenUk ?? "---Select One---",
                  onChanged: (newValue) async {
                    setState(() {
                      selectedCitizenUk = newValue!;
                    });
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setString('CitizenUk', newValue!);

                  },
                ),
                SizedBox(height: screenHeight * .013,),
                DynamicDropdown(
                  title: "Do you have a Right to Work in the UK?",
                  options: _dropdownOptions,
                  selectedOption: selectedRightToWork ?? "---Select One---",
                  onChanged: (newValue) async {
                    setState(() {
                      selectedRightToWork = newValue!;
                    });
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setString('rightToWorkUK', newValue!);
                  },
                ),
                SizedBox(height: screenHeight * .013),

                DynamicDropdown(
                  title: "Do you want to opt out of the Pension Scheme?",
                  options: _dropdownOptions,
                  selectedOption: selectedOptOut ?? "---Select One---",
                  onChanged: (newValue) async {
                    setState(() {
                      selectedOptOut = newValue!;
                    });
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setString('optOutOfPension', newValue!);
                  },
                ),
                SizedBox(height: screenHeight * .013),
                DynamicDropdown(
                  title: "Do you have a DBS or EDBS (if applicable for your role)?",
                  options: _dropdownOptions,
                  selectedOption: selectedDBS ?? "---Select One---",
                  onChanged: (newValue) async {
                    setState(() {
                      selectedDBS = newValue!;
                    });
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setString('dbsCheck', newValue!);
                    widget.onDBSChanged(newValue);
                  },
                ),
                // SizedBox(height: screenHeight * .013),

                if (selectedDBS == 'Yes') ...[
                  SizedBox(height: screenHeight * .013,),
                  ConditionalDropdown(
                    title: "DBS Check Type",
                    options: _conditionalOptions,
                    selectedOption: _conditionalOptions.contains(selectedDBSCheckType) ? selectedDBSCheckType : null,
                    onChanged: (newValue) async {
                      setState(() {
                        selectedDBSCheckType = newValue;
                      });
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setString('dbsCheckType', newValue!);
                    },
                    validator: (value) {
                      if (selectedDBS == 'Yes' && (value == null || value.isEmpty)) {
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
                  selectedOption: selectedonCriminalConviction ?? "---Select One---",
                  onChanged: (newValue) async {
                    setState(() {
                      selectedonCriminalConviction = newValue!;
                    });
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setString('criminalConviction', newValue!);
                  },
                ),
                SizedBox(height: screenHeight * .013),

                if (selectedonCriminalConviction == 'Yes') ...[
                  // SizedBox(height: screenHeight * .013),
                  Container(
                    width: screenWidth * 0.90,
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
                      if (selectedonCriminalConviction == 'Yes' && (value == null || value.isEmpty)) {
                        return 'Please enter details of unspent criminal convictions';
                      }
                      return null; // No error
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    initialValue: specifyController.text,
                    builder: (FormFieldState<String> state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: screenHeight * 0.15,
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
                            child: TextFormField(
                              controller: specifyController,
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
                  SizedBox(height: screenHeight * .013),
                ],
              ],
            ),
          ),

          SizedBox(height: screenHeight * .02,),

          GestureDetector(
            onTap: ()async{
              _saveFormData();
              if (widget.formKey.currentState?.validate() ?? false ) {
                widget.onStep1();
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
          SizedBox(height: screenHeight * .1,),
        ]),
      ),
    );
  }

  final ImagePicker _imagePicker = ImagePicker();
  Future<void> _pickImage(ImageSource source) async {
    XFile? pickedImage = await _imagePicker.pickImage(source: source);

    if (pickedImage != null) {
      Uint8List imageData = await pickedImage.readAsBytes();
      String imageName = pickedImage.name;
      List<String> fileNameParts = imageName.split('.');
      String imageExtension = fileNameParts.last;
      String imageNameShortened = imageName.length > 15 ? imageName.substring(0, 15) + "..." + imageExtension : imageName;

      // Save image as base64 string
      String base64Image = base64Encode(imageData);

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('image', base64Image);
      prefs.setString('imageName', imageNameShortened);

      setState(() {
        _selectedImageData = imageData;
        _selectedImageName = imageNameShortened;
      });
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
          width: screenWidth * 0.90,
          child: Row(
            children: [
              Text('Gender ',
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(fontSize: 15),
                    fontWeight: FontWeight.bold,
                  )),
              const Text(
                '*',
                style: TextStyle(color: Colors.red, fontSize: 15),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        FormField<String>(
          initialValue: selectedGender ?? '---Select One---',
          validator: (value) {
            if (value == null || value.isEmpty || value == '---Select One---') {
              return 'Gender is required';
            }
            return null;
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
          builder: (FormFieldState<String> state) {
            return Column(
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
                          selectedGender = newValue;
                        });
                        final prefs = await SharedPreferences.getInstance();
                        if (newValue != null) {
                          await prefs.setString('gender', newValue);
                        }
                        state.didChange(newValue);
                      },
                    ),
                  ),
                ),
                if (state.hasError)
                  Container(
                    width: screenWidth * 0.95,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3.0, left: 10),
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

  // Widget _buildMeritalDropdown() {
  //   double screenWidth = MediaQuery.of(context).size.width;
  //   double screenHeight = MediaQuery.of(context).size.height;
  //   return Column(
  //
  //     children: [
  //       Container(
  //         width: screenWidth * 0.90,
  //         child: Row(
  //           children: [
  //             const Text(
  //               'Marital Status ',
  //               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
  //             ),
  //             const Text(
  //               '*',
  //               style: TextStyle(color: Colors.red, fontSize: 16),
  //             ),
  //           ],
  //         ),
  //       ),
  //       const SizedBox(height: 8),
  //       FormField<String>(
  //         initialValue: selectedMaritalStatus ?? '---Select One---',
  //         validator: (value) {
  //           if (value == null || value.isEmpty || value == '---Select One---') {
  //             return 'Marital status is required';
  //           }
  //           return null; // No error if gender is selected
  //         },
  //         autovalidateMode: AutovalidateMode.onUserInteraction,
  //         builder: (FormFieldState<String> state) {
  //           return Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Container(
  //                 height: screenHeight * 0.055,
  //                 width: screenWidth * 0.90,
  //                 padding: const EdgeInsets.symmetric(horizontal: 15.0),
  //                 decoration: BoxDecoration(
  //                   color: Color(0xffF2F5F6),
  //                   borderRadius: BorderRadius.circular(5.0),
  //                   border: Border.all(
  //                     color: Color(0xffEAECED),
  //                     width: 1,
  //                   ),
  //                 ),
  //                 child: DropdownButtonHideUnderline(
  //                   child: DropdownButton<String>(
  //                     isExpanded: true,
  //                     iconSize: 30.0,
  //                     value: selectedMaritalStatus == '---Select One---' ? null : selectedMaritalStatus,
  //                     hint:  Text('---Select One---'),
  //                     items: ['Single', 'Married', 'Divorced', 'Widowed', 'Separated'].map((marriedchange) {
  //                       return DropdownMenuItem(
  //                         value: marriedchange,
  //                         child: Text(marriedchange),
  //                       );
  //                     }).toList(),
  //                     onChanged: (String? newValue) async {
  //                       setState(() {
  //                         selectedMaritalStatus = newValue;
  //                       });
  //                       if (newValue != null) {
  //                         final prefs = await SharedPreferences.getInstance();
  //                         await prefs.setString('maritalStatus', newValue);
  //                         print("Saved marital status: $newValue");
  //                       }
  //                       state.didChange(newValue);
  //                     },
  //                   ),
  //                 ),
  //               ),
  //               if (state.hasError)
  //                 Padding(
  //                   padding: const EdgeInsets.only(top: 4.0,left: 12),
  //                   child: Text(
  //                     state.errorText ?? '',
  //                     style: const TextStyle(
  //                       color: Colors.red,
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: 12,
  //                     ),
  //                   ),
  //                 ),
  //             ],
  //           );
  //         },
  //       ),
  //     ],
  //   );
  // }
  Widget _buildDropdown({
    required String titleText,
    required bool requiredStar,
    required String? initialValue,
    required List<String> options,
    required Function(String?) onSelectionChange,
    required String sharedPrefsKey,
    String? Function(String?)? validator, // Validator function added
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Container(
          width: screenWidth * 0.90,
          child: Row(
            children: [
              Text(
                titleText,
              style: GoogleFonts.openSans(
              textStyle: TextStyle(fontSize: 15),
      fontWeight: FontWeight.bold,
    )),
              if (requiredStar)
                Text(
                  '*',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        FormField<String>(
          initialValue: initialValue ?? '---Select One---',
          validator: validator, // Validator now used here
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
                      isExpanded: true,
                      iconSize: 30.0,
                      value: initialValue == '---Select One---' ? null : initialValue,
                      hint: Text('---Select One---'),
                      items: options.map((String option) {
                        return DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: (String? newValue) async {
                        if (newValue != null) {
                          onSelectionChange(newValue);
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString(sharedPrefsKey, newValue);
                          print("Saved $titleText: $newValue");
                        }
                        state.didChange(newValue);
                      },
                    ),
                  ),
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, left: 12),
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

  Widget DynamicDropdown({
    required String title,
    required List<String> options,
    required String? selectedOption,
    required ValueChanged<String?> onChanged,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      // crossAxisAlignment: CrossAxisAlignment.start,
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
          initialValue: selectedOption ?? '---Select One---',
          validator: (value) {
            if (value == null || value == '---Select One---') {
              return 'Please select an option';
            }
            return null;
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
          builder: (FormFieldState<String> state) {
            return Column(
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
                      isExpanded: true,
                      iconSize: 30.0,
                      value: selectedOption == '---Select One---' ? null : selectedOption,
                      hint: Text('---Select One---'),
                      onChanged: (newValue) {
                        state.didChange(newValue);
                        onChanged(newValue);
                      },
                      items: options.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                if (state.hasError)
                  Container(
                    width: screenWidth * 0.90,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0, left: 10),
                      child: Text(
                        state.errorText!,
                        style: TextStyle(color: Colors.red,  fontWeight: FontWeight.bold,
                            fontSize: 12),
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

  int subCurrentStep = 0;
  bool validateCurrentStep() {
    final form = widget.formKey.currentState;
    if (form != null && form.validate()) {
      return true;
    }
    return false;
  }
}
