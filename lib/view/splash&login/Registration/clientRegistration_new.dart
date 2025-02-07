import 'dart:convert';
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/utils/routes/routes_name.dart';
import 'package:c9_app/utils/utils.dart';
import 'package:c9_app/view/splash&login/login_view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as https;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Modules/StaffModule/MODEL/staff_registrationModel/ConsultantNames.dart';

class ClientRegistrationNew extends StatefulWidget {
  const ClientRegistrationNew({Key? key}) : super(key: key);

  @override
  _ClientRegistrationNewState createState() => _ClientRegistrationNewState();
}

class _ClientRegistrationNewState extends State<ClientRegistrationNew> {
  ScrollController _scrollController = ScrollController();

  void _scrollToField(FocusNode focusNode) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (focusNode.hasFocus) {
        double offset = focusNode.offset.dy - MediaQuery.of(context).size.height * 0.3;
        _scrollController.animateTo(offset, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
      }
    });
  }

  bool isLoading=false;

  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _selectedImage;
  String? _selectedImageName;

  Future<void> _pickImage(ImageSource source) async {
    XFile? pickedImage = await _imagePicker.pickImage(source: source);

    if (pickedImage != null) {
      Uint8List imageData = await pickedImage.readAsBytes();
      String imageName = pickedImage.name;
      // Splitting the filename into name and extension parts
      List<String> fileNameParts = imageName.split('.');
      String imageExtension = fileNameParts.last;
      String imageNameShortened = imageName.length > 15
          ? imageName.substring(0, 15) + "..." + imageExtension
          : imageName;

      setState(() {
        _selectedImage = imageData;
        _selectedImageName = imageNameShortened;
      });
    } else {
      print('No image selected');
    }
  }

  void _selectStartTime(TimeOfDay newTime) {
    setState(() {
      startTime = newTime;
    });
  }

  void _selectEndTime(TimeOfDay newTime) {
    setState(() {
      endTime = newTime;
    });
  }
  @override
  void initState() {
    super.initState();
    startTime = TimeOfDay.now();
    endTime = TimeOfDay.now();
  }


  late TimeOfDay startTime;
  late TimeOfDay endTime;


  TextEditingController _nameController = TextEditingController();
  TextEditingController _companyNameController = TextEditingController();
  TextEditingController _CompanyregnumberController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();

  TextEditingController _address1Controller = TextEditingController();
  TextEditingController _address2Controller = TextEditingController();
  TextEditingController _townCityController = TextEditingController();
  TextEditingController _postCodeController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _reEnterpasswordController = TextEditingController();

  ValueNotifier<bool> _obsecurePassword = ValueNotifier<bool>(true);
  ValueNotifier<bool> _reobsecurePassword = ValueNotifier<bool>(true);
  ValueNotifier<bool> _isPasswordMatching = ValueNotifier<bool>(true);

  //image
  //Document
  TextEditingController _fundController = TextEditingController();
  TextEditingController _StartTimePickerController = TextEditingController();
  TextEditingController _EndTimePickerController = TextEditingController();
  TextEditingController _breaktimeController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  List<TextEditingController> _billingNameControllers = [TextEditingController()];
  List<TextEditingController> _billingEmailControllers = [TextEditingController()];
  TextEditingController accountOwnerNameController = TextEditingController();


  void _addMoreFields() {
    if (_billingNameControllers.length < 5) {
      setState(() {
        _billingNameControllers.add(TextEditingController());
        _billingEmailControllers.add(TextEditingController());
      });
    }
  }

  void _removeFields(int index) {
    setState(() {
      _billingNameControllers.removeAt(index);
      _billingEmailControllers.removeAt(index);
    });
  }


  FocusNode nameFocusNode = FocusNode();
  FocusNode companyNameFocusNode  = FocusNode();
  FocusNode  ComregnumberFocusNode= FocusNode();
  FocusNode  phoneFocusNode= FocusNode();
  FocusNode  address1FocusNode= FocusNode();
  FocusNode  address2FocusNode= FocusNode();
  FocusNode  townCityFocusNode= FocusNode();
  FocusNode  postCodeFocusNode= FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode repasswordFocusNode = FocusNode();

  FocusNode  fundFocusNode= FocusNode();
  FocusNode  dayStartFocusNode= FocusNode();
  FocusNode  dayEndFocusNode= FocusNode();
  FocusNode  breaktimeFocusNode= FocusNode();
  FocusNode  descriptionFocusNode= FocusNode();


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    _nameController.dispose();
    _companyNameController.dispose();
    _CompanyregnumberController.dispose();
    _phoneNumberController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _townCityController.dispose();
    _postCodeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _reEnterpasswordController.dispose();
    accountOwnerNameController.dispose();



    _fundController.dispose();
    _StartTimePickerController.dispose();
    _EndTimePickerController.dispose();
    _breaktimeController.dispose();
    _descriptionController.dispose();



    nameFocusNode.dispose();
    companyNameFocusNode.dispose();
    ComregnumberFocusNode.dispose();
    phoneFocusNode.dispose();
    address1FocusNode.dispose();
    address2FocusNode.dispose();
    townCityFocusNode.dispose();
    postCodeFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    repasswordFocusNode.dispose();



    fundFocusNode.dispose();
    dayStartFocusNode.dispose();
    dayEndFocusNode.dispose();
    breaktimeFocusNode.dispose();
    descriptionFocusNode.dispose();
    _obsecurePassword.dispose();
    _reobsecurePassword.dispose();

      for (var controller in _billingNameControllers) {
        controller.dispose();
      }
      for (var controller in _billingEmailControllers) {
        controller.dispose();
      }
  }

  List<ConsultantNames> accountOwnerNames = [];
  List<ConsultantNames> filteredOwnerNames = [];
  bool _isExpanded = false;


  Future<void> fetchConsultantNames() async {
    try {
      final response = await https.get(
          Uri.parse('${AppUrl.baseUrl}/api/app/staff-registration-dropdown'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          accountOwnerNames =
              data.map((item) => ConsultantNames.fromJson(item)).toList();
          filteredOwnerNames = accountOwnerNames;
        });
      } else {
        print("Failed to load consultant names");
      }
    } catch (error) {
      print("Error fetching data: $error");
    }
  }

  // Filter consultants based on user query
  void filterAccountOwnerNames(String query) {
    setState(() {
      filteredOwnerNames = query.isNotEmpty
          ? accountOwnerNames
          .where((consultant) =>
      consultant.name
          ?.toLowerCase()
          .contains(query.toLowerCase()) ??
          false)
          .toList()
          : accountOwnerNames;
    });
  }

  String _passwordValidationError = '';
  String _confirmPassValidationError = '';
  Map<int, String> _billingNameListError = {};
  Map<int, String> _billingEmailListError = {};
  Map<String, String> _validationErrors = {};

  Future<void> _clientSignUp() async {
    setState(() {
      isLoading = true;

    });
    _billingNameListError.clear();
    _billingEmailListError.clear();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';
    String _nameValidationError = '';
    String _companyNameValidationError = '';
    String _regNumberValidationError = '';


    String _phoneValidationError = '';
    String _addressLine1ValidationError = '';
    String _addressLine2ValidationError = '';
    String _townOrCityValidationError = '';
    String _postCodeValidationError = '';
    String _emailValidationError = '';

    _passwordValidationError = '';
    _confirmPassValidationError = '';
    try {
      final String apiUrl = '${AppUrl.baseUrl}/api/app/register';
      var request = https.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers.addAll({
        // 'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
      });
      request.fields['name'] = _nameController.text;
      request.fields['company_name'] = _companyNameController.text;
      request.fields['reg_number'] = _CompanyregnumberController.text;
      request.fields['phone'] = _phoneNumberController.text;
      request.fields['addressLine1'] = _address1Controller.text;
      request.fields['addressLine2'] = _address2Controller.text;
      request.fields['townOrCity'] = _townCityController.text;
      request.fields['postCode'] = _postCodeController.text;
      request.fields['funding_limit'] = _fundController.text;
      request.fields['email'] = _emailController.text;
      request.fields['password'] = _passwordController.text;
      request.fields['confirm_password'] = _reEnterpasswordController.text;
      request.fields['day_start_time'] = _StartTimePickerController.text;
      request.fields['day_end_time'] = _EndTimePickerController.text;
      request.fields['break_time'] = _breaktimeController.text;
      request.fields['description'] = _descriptionController.text;
      request.fields['consultant'] = accountOwnerNameController.text;
      if (_selectedImageName != null) {
        request.files.add(await https.MultipartFile.fromBytes(
          'image',
          _selectedImage!,
          filename: _selectedImageName!,
        ));
        print("Image added to request: $_selectedImageName");
      }
      for (int i = 0; i < _billingNameControllers.length; i++) {
        request.fields['contact_name[$i]'] = _billingNameControllers[i].text;
        request.fields['contact_email[$i]'] = _billingEmailControllers[i].text;
      }
      var response = await request.send();
      String responseBody = await response.stream.bytesToString();

      print('Failed to submit data. Status code: ${response.statusCode}');
      print('Response body: $responseBody');
      if (response.statusCode == 200) {
        print('Data submitted successfully');
        setState(() {
          isLoading = false;
        });
        Utils.flushBarSuccessMessageRegistration('Your account was created successfully, Admin will approve your account soon!', context);
        Future.delayed(Duration(seconds: 5), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginView(),
            ),
          );
        });
        print('_________________________________________________________');
      } else {
        final Map<String, dynamic> responseData = jsonDecode(await response.stream.bytesToString());
       print(responseData);
       print(responseBody);
        if (responseData.containsKey('errors')) {
          final Map<String, dynamic> errors = responseData['errors'];
          errors.forEach((field, messages) {
            final String errorMessage = messages.isNotEmpty ? messages.first : 'Unknown error';
            final contactNameRegExp = RegExp(r'^contact_name\.(\d+)$');
            final contactEmailRegExp = RegExp(r'^contact_email\.(\d+)$');

            // Handle contact name errors
            if (contactNameRegExp.hasMatch(field)) {
              final match = contactNameRegExp.firstMatch(field);
              if (match != null) {
                final index = int.parse(match.group(1)!);
                setState(() {
                  _billingNameListError[index] = errorMessage;
                });
              }
            }
            // Handle contact email errors
            else if (contactEmailRegExp.hasMatch(field)) {
              final match = contactEmailRegExp.firstMatch(field);
              if (match != null) {
                final index = int.parse(match.group(1)!);
                setState(() {
                  _billingEmailListError[index] = errorMessage;
                });
              }
            }
            // Handle other field errors (e.g., name, company_name, etc.)
            else {switch (field) {
              case 'name':
                _nameValidationError = errorMessage;
                _scrollToField(nameFocusNode);
                break;
              case 'company_name':
                _companyNameValidationError = errorMessage;
                _scrollToField(companyNameFocusNode);
                break;
              case 'reg_number':
                _regNumberValidationError = errorMessage;
                _scrollToField(ComregnumberFocusNode);
                break;
              case 'phone':
                _phoneValidationError = errorMessage;
                _scrollToField(phoneFocusNode);
                break;
              case 'addressLine1':
                _addressLine1ValidationError = errorMessage;
                _scrollToField(address1FocusNode);
                break;
              case 'addressLine2':
                _addressLine2ValidationError = errorMessage;
                _scrollToField(address2FocusNode);
                break;
              case 'townOrCity':
                _townOrCityValidationError = errorMessage;
                _scrollToField(townCityFocusNode);
                break;
              case 'postCode':
                _postCodeValidationError = errorMessage;
                _scrollToField(postCodeFocusNode);
                break;
              case 'email':
                _emailValidationError = errorMessage;
                _scrollToField(emailFocusNode);
                break;
              case 'password':
                _passwordValidationError = errorMessage;
                _scrollToField(passwordFocusNode);
                break;
              case 'confirm_password':
                _confirmPassValidationError = errorMessage;
                _scrollToField(repasswordFocusNode);
                break;
              // case 'contact_name':
              //   setState(() {
              //     for (int i = 0; i < _billingNameControllers.length; i++) {
              //       _billingNameListError[i] = errorMessage;
              //     }
              //   });
              //   break;
              // case 'contact_email':
              //   setState(() {
              //     for (int i = 0; i < _billingEmailControllers.length; i++) {
              //       _billingEmailListError[i] = errorMessage;
              //     }
              //   });
              //   break;
            }}
          });
          setState(() {
            _validationErrors = {
              'name': _nameValidationError,
              'company_name': _companyNameValidationError,
              'reg_number': _regNumberValidationError,
              'phone': _phoneValidationError,
              'addressLine1': _addressLine1ValidationError,
              'addressLine2': _addressLine2ValidationError,
              'townOrCity': _townOrCityValidationError,
              'postCode': _postCodeValidationError,
              'email': _emailValidationError,
              'password': _passwordValidationError,
              'confirm_password': _confirmPassValidationError,
              // 'contact_name': _billingNameListError.values.join(', '),
              // 'contact_email': _billingEmailListError.values.join(', '),
            };
          });

          final Map<String, double> fieldScrollPositions = {
            'name': 0.0,
            'company_name': 100.0,
            'reg_number': 200.0,
            'phone': 300.0,
            'addressLine1': 400.0,
            'addressLine2': 500.0,
            'townOrCity': 600.0,
            'postCode': 700.0,
            'email': 800.0,
            'password': 900.0,
            'confirm_password': 1000.0,

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

          print('Failed to submit data. Status code: ${response.statusCode}');
          print(response.reasonPhrase);
          setState(() {
            isLoading = false;
          });
          Utils.flushBarErrorMessage('Please fill in all required fields correctly.', context);
        } else {
          setState(() {
            isLoading = false;
          });
          Utils.flushBarErrorMessage('Please fill all the required field', context);
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Utils.flushBarErrorMessage('An error occurred during SignUp', context);
      print('Error during data submission: $e');
    }
  }




  @override
  Widget build(BuildContext context) {
    _scrollController = ScrollController();
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
    final screenHeight = MediaQuery.of(context).size.height *1;
    final screenWidth = MediaQuery.of(context).size.width *1;

    return WillPopScope(
      onWillPop: () async {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginView()));
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
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginView()));
                      },
                      child: HeaderRow(Icons.arrow_back)),
                  Text("Business Information",style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),),
                  InVisibleHeaderRow(Icons.arrow_back),
                ],
              ),
              SizedBox(height: screenHeight * 0.013,),


              SizedBox(height: screenHeight * 0.01,),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Business Information",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),)),
              SizedBox(height: screenHeight * .013,),

              Center(
                child: Container(
                  width:screenWidth*0.95 ,
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
                      ]
                  ),
                  child: Column(
                    children: [

                      //For Name
                      RequiredCustomContainer(
                        titleText: 'Full Name',
                        titleText2: "Enter Your Full Name",
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        focusNode: nameFocusNode,
                        focusCurrent: nameFocusNode,
                        focusNext: companyNameFocusNode,
                        errorMessage: _validationErrors.containsKey('name') ? _validationErrors['name'] : null,
                      ),


                      //Conpany Name
                      RequiredCustomContainer(
                        titleText: 'Business  Name',
                        titleText2: "Enter Your Business Name",
                        controller: _companyNameController,
                        keyboardType: TextInputType.name,
                        focusNode: companyNameFocusNode,
                        focusCurrent:companyNameFocusNode ,
                        focusNext:ComregnumberFocusNode ,
                        errorMessage: _validationErrors['company_name'],
                      ),

                      //Conpany Registration Number
                      RequiredCustomContainer(
                        titleText: 'Company Registration Number',
                        titleText2: "Enter Your Company Registration Number",
                        controller: _CompanyregnumberController,
                        keyboardType: TextInputType.text,
                        focusNode: ComregnumberFocusNode,
                        focusCurrent:ComregnumberFocusNode ,
                        focusNext:phoneFocusNode ,
                        errorMessage: _validationErrors['reg_number'],
                      ),


                      //Mobile
                      RequiredCustomContainer(
                        titleText: 'Contact Number',
                        titleText2: "Enter Your Phone Number",
                        controller: _phoneNumberController,
                        keyboardType: TextInputType.phone,
                        focusNode: phoneFocusNode,
                        focusCurrent:phoneFocusNode ,
                        focusNext:address1FocusNode ,
                        errorMessage: _validationErrors['phone'],
                      ),


                      //Address Line 1
                      RequiredCustomContainer(
                        titleText: 'Address Line 1',
                        titleText2: "Enter Your Address Line 1",
                        controller: _address1Controller,
                        keyboardType: TextInputType.streetAddress,
                        focusNode: address1FocusNode,
                        focusCurrent:address1FocusNode ,
                        focusNext: address2FocusNode,
                        errorMessage: _validationErrors['addressLine1'],
                      ),


                      //Address Line 2
                      RequiredCustomContainer(
                        titleText: 'Address Line 2',
                        titleText2: "Enter Your Address Line 2",
                        controller: _address2Controller,
                        keyboardType: TextInputType.streetAddress,
                        focusNode: address2FocusNode,
                        focusCurrent:address2FocusNode ,
                        focusNext: townCityFocusNode,
                        errorMessage: _validationErrors['addressLine2'],
                      ),


                      //Town/City
                      RequiredCustomContainer(
                        titleText: 'Town / City',
                        titleText2: "Enter Your Town/City",
                        controller: _townCityController,
                        keyboardType: TextInputType.streetAddress,
                        focusNode: townCityFocusNode,
                        focusCurrent:townCityFocusNode ,
                        focusNext: postCodeFocusNode,
                        errorMessage: _validationErrors['townOrCity'],
                      ),

                      //PostCode
                      RequiredCustomContainer(
                        titleText: 'Post Code',
                        titleText2: "Enter Your Post Code",
                        controller: _postCodeController,
                        keyboardType: TextInputType.number,
                        focusNode: postCodeFocusNode,
                        focusCurrent:postCodeFocusNode ,
                        focusNext: emailFocusNode,
                        errorMessage: _validationErrors['postCode'],
                      ),

                      //Email
                      RequiredCustomContainer(
                        titleText: 'Email',
                        titleText2: "Enter Your Email Address",
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        focusNode: emailFocusNode,
                        focusCurrent:emailFocusNode ,
                        focusNext:passwordFocusNode ,
                        errorMessage: _validationErrors['email'],
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
                              Text(" *",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red),)
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
                                hintText: "Enter Your Password",
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
                                Utils.fieldFocusChange(context, passwordFocusNode, repasswordFocusNode);
                              },
                              onChanged: (value) {
                                _checkPasswordMatch();
                              },
                            ),
                          );
                        },
                      ),
                      SizedBox(height: screenHeight * .005),
                      if (_passwordValidationError != null && _passwordValidationError.isNotEmpty) // Render error message only if not empty
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
                              Text("Re-enter Password", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              Text(" *",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red),)
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
                              focusNode: repasswordFocusNode,
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
                              onChanged: (value) {
                                _checkPasswordMatch();
                              },
                            ),
                          );
                        },
                      ),
                      SizedBox(height: screenHeight * .013),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_confirmPassValidationError != null && _confirmPassValidationError.isNotEmpty) // Render error message only if not empty
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  _confirmPassValidationError,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),

                          Padding(
                            padding: const EdgeInsets.only(right: 10.0,left: 10),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: ValueListenableBuilder<bool>(
                                valueListenable: _isPasswordMatching,
                                builder: (context, value, child) {
                                  if (_passwordController.text.isEmpty || _reEnterpasswordController.text.isEmpty) {
                                    return SizedBox(); // Empty sized box to not show anything
                                  }
                                  return Text(
                                    value ? "Password matched" : "Not matched",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: value ? Colors.green : Colors.red,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Search or Account Owner Name
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, bottom: 10),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Text(
                                  'Account Owner Name',
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
                                controller: accountOwnerNameController,
                                 onChanged: (value) {
                                  filterAccountOwnerNames(value);
                                  setState(() {
                                    _isExpanded = true;
                                  });
                                },
                                decoration: InputDecoration(
                                  prefixIcon:
                                  Icon(Icons.search, color: Colors.grey),
                                  border: InputBorder.none,
                                  hintText: "Search or Select Account Owner...",
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
                            if (_isExpanded && filteredOwnerNames.isNotEmpty)
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
                                      itemCount: filteredOwnerNames.length,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          title: Text(
                                            filteredOwnerNames[index].name ??
                                                '',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          onTap: () {
                                            setState(() {
                                              accountOwnerNameController.text =
                                                  filteredOwnerNames[index]
                                                      .name ??
                                                      '';
                                              filteredOwnerNames = [];
                                              _isExpanded = false;
                                            });
                                          },
                                        );
                                      }),
                                ),
                              ),
                          ]),
                      SizedBox(height: screenHeight * .005),




                      SizedBox(height: screenHeight * .013),


                      //Image
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0,bottom: 10),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Image",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),)),
                      ),
                      GestureDetector(
                        onTap: (){
                          _pickImage(ImageSource.gallery);
                        },
                        child: Container(
                            height: screenHeight*0.065,
                            width: screenWidth*0.90,
                            decoration: BoxDecoration(
                              color: AppColors.navOpacity.withOpacity(0.2),
                              border: Border.all(
                                color: AppColors.navButtonColor.withOpacity(0.4),
                                width: 0.4,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  // height: screenHeight*0.065,
                                  width: screenWidth*0.30,
                                  decoration: BoxDecoration(
                                    color: AppColors.navOpacity,
                                    border: Border.all(
                                      color: AppColors.navOpacity,
                                      width: 0.4,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Center(child: AutoSizeText("Choose image",style: TextStyle(fontSize: 15,color: AppColors.blackColor),)),
                                ),
                                Text(_selectedImageName ?? "No image selected...", style: TextStyle(fontSize: 12, color: AppColors.blackColor)),
                                // Text("No file selected...",style: TextStyle(fontSize: 15,color: AppColors.blackColor),),
                                SizedBox(),
                              ],
                            )
                        ),
                      ),
                      SizedBox(height: screenHeight * .013,),
                      //Funding Limite
                      NonRequiredCustomContainer(
                        titleText: 'Funding Limit',
                        titleText2: "Enter Your Funding Limit Amount",
                        controller: _fundController,
                        keyboardType: TextInputType.number,
                        focusNode: fundFocusNode,
                        focusCurrent:null ,
                        focusNext:null ,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.013,),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Day Time Set",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),)),
              SizedBox(height: screenHeight*0.013,),
              Container(
                width:screenWidth*0.95 ,
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
                    ]
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: AutoSizeText(
                              'Day Start Time',
                              maxLines: 1,
                              style: GoogleFonts.roboto(
                                textStyle: TextStyle(fontSize: 16),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            width: screenWidth*0.43,
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
                                readOnly: true,
                                controller: _StartTimePickerController,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                  hintText: "--:--:--",
                                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6),fontSize: 16,letterSpacing: 5),
                                  prefixIcon: Icon(Icons.more_time_outlined,color: Colors.black,),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                onTap: () async {
                                  TimeOfDay? newTime = await showTimePicker(
                                    context: context,
                                    initialTime: startTime,
                                    initialEntryMode: TimePickerEntryMode.input,
                                    builder: (BuildContext context, Widget? child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          timePickerTheme: TimePickerThemeData(
                                            backgroundColor: Colors.white, // Background color
                                            dayPeriodTextColor: Colors.blue, // Text color for AM/PM
                                            dayPeriodBorderSide: BorderSide(color: AppColors.navColor), // Border color for AM/PM
                                            dialHandColor: AppColors.navColor, // Color of the hour hand
                                            dialBackgroundColor: Colors.white,
                                          ),
                                          colorScheme: const ColorScheme.light(
                                            onPrimary: Colors.white,
                                            onBackground:  Colors.white,
                                            onSurface: Colors.black,//TextColor in Calender
                                            onSurfaceVariant: Colors.white,
                                            primary: AppColors.navColor ,// circle color
                                            brightness : Brightness.light,//Brightness
                                            surface : Colors.white,
                                            secondary: AppColors.navColor,
                                          ),
                                          datePickerTheme: const DatePickerThemeData(
                                            headerBackgroundColor: AppColors.navColor,//Header Background Color
                                            backgroundColor:  Colors.white,//Main Baground
                                            headerForegroundColor:  Colors.white,//Header Text Color
                                            surfaceTintColor:   Colors.white,//Main Background Neede
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
                                  if (newTime != null) {
                                    _selectStartTime(newTime);
                                    String formattedHour = newTime.hour.toString().padLeft(2, '0');
                                    String formattedMinute = newTime.minute.toString().padLeft(2, '0');
                                    // String formattedTime = "$formattedHour:$formattedMinute";
                                    String formattedTime = MaterialLocalizations.of(context).formatTimeOfDay(newTime, alwaysUse24HourFormat: false);

                                    setState(() {
                                      _StartTimePickerController.text = formattedTime;
                                    });
                                  }
                                },

                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: AutoSizeText(
                              'Day End Time',
                              maxLines: 1,
                              style: GoogleFonts.roboto(
                                textStyle: TextStyle(fontSize: 16),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            // height: screenHeight*0.065,
                            width: screenWidth*0.43,
                            decoration: BoxDecoration(
                              color: AppColors.navOpacity.withOpacity(0.2),
                              border: Border.all(
                                color: AppColors.navButtonColor.withOpacity(0.4),
                                width: 0.4,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child:Align(
                              alignment: Alignment.centerLeft,
                              child:TextFormField(
                                readOnly: true,
                                controller: _EndTimePickerController,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                  hintText: "--:--:--",
                                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6),fontSize: 16,letterSpacing: 5),
                                  prefixIcon: Icon(Icons.more_time_outlined,color: Colors.black,),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                onTap: () async {
                                  TimeOfDay? newTime = await showTimePicker(
                                    context: context,
                                    initialTime: endTime,
                                    initialEntryMode: TimePickerEntryMode.input,
                                    builder: (BuildContext context, Widget? child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          timePickerTheme: TimePickerThemeData(
                                            backgroundColor: Colors.white, // Background color
                                            dayPeriodTextColor: Colors.blue, // Text color for AM/PM
                                            dayPeriodBorderSide: BorderSide(color: AppColors.navColor), // Border color for AM/PM
                                            dialHandColor: AppColors.navColor, // Color of the hour hand
                                            // dialTextColor: Colors.purple, // Text color on the clock dial
                                            dialBackgroundColor: Colors.white,
                                          ),
                                          colorScheme: const ColorScheme.light(
                                            onPrimary: Colors.white,
                                            onBackground:  Colors.white,
                                            onSurface: Colors.black,//TextColor in Calender
                                            onSurfaceVariant: Colors.white,
                                            primary: AppColors.navColor ,// circle color
                                            brightness : Brightness.light,//Brightness
                                            surface : Colors.white,
                                            secondary: AppColors.navColor,
                                          ),
                                          datePickerTheme: const DatePickerThemeData(
                                            headerBackgroundColor: AppColors.navColor,//Header Background Color
                                            backgroundColor:  Colors.white,//Main Baground
                                            headerForegroundColor:  Colors.white,//Header Text Color
                                            surfaceTintColor:   Colors.white,//Main Background Needed
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
                                  if (newTime != null) {
                                    _selectEndTime(newTime);
                                    String formattedHour = newTime.hour.toString().padLeft(2, '0');
                                    String formattedMinute = newTime.minute.toString().padLeft(2, '0');
                                    // String formattedTime = "$formattedHour:$formattedMinute";
                                    String formattedTime = MaterialLocalizations.of(context).formatTimeOfDay(newTime, alwaysUse24HourFormat: false);

                                    setState(() {
                                      _EndTimePickerController.text = formattedTime;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),


              SizedBox(height: screenHeight * .013,),


              //Break Deduction (Par Day) Minutes
              NonRequiredCustomContainer(
                titleText: 'Break Deduction (Per Day) Minutes',
                titleText2: "Enter Your Break Deduction (Per Day) Minutes",
                controller: _breaktimeController,
                keyboardType: TextInputType.number,
                focusNode: breaktimeFocusNode,
                focusCurrent:breaktimeFocusNode,
                focusNext: descriptionFocusNode,
              ),

              //Details
              Padding(
                padding: const EdgeInsets.only(left: 10.0,bottom: 10),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Details",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),)),
              ),
              Container(
                height: screenHeight*0.15,
                width: screenWidth*0.90,
                decoration: BoxDecoration(
                  color: AppColors.navOpacity.withOpacity(0.2),
                  border: Border.all(
                    color: AppColors.navButtonColor.withOpacity(0.4),
                    width: 0.4,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextFormField(
                  controller: _descriptionController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  focusNode: descriptionFocusNode,
                  decoration: const InputDecoration(
                    hintText:"If you have multiple sites that need support, please list the site locations here and any other details you may wish to provide",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 5),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * .013,),
              Container(
                width:screenWidth*0.90,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Billing Contacts",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),

                        if (_billingNameControllers.length < 5)
                        GestureDetector(
                          onTap: _addMoreFields,
                          child: Container(
                            height: screenHeight * 0.04,
                            width: screenWidth * 0.2,
                            decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    offset: Offset(0, 2),
                                    blurRadius: 5,
                                    spreadRadius: 2,
                                  ),
                                ]),
                            child: Center(child: Text("Add More", style: TextStyle(color: Colors.white, fontSize: 14,fontWeight: FontWeight.bold),)),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight*0.013,),
                    Column(
                      children: [
                        ...List.generate(_billingNameControllers.length, (index) {
                          return  Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                        width: 0.4,
                                      color: AppColors.navColor,
                                    )
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          BillingContainer(
                                            titleText2: index > 0? 'Contact Name':'Primary Contact Name',
                                            widthSize: index > 0?  screenWidth*0.75:screenWidth*0.84,
                                            controller: _billingNameControllers[index],
                                            keyboardType: TextInputType.text,
                                            errorMessage: _billingNameListError[index] ??"",
                                          ),
                                          if (index > 0)
                                            GestureDetector(
                                                onTap: () {
                                                  _removeFields(index);
                                                },
                                                child: Icon(Icons.cancel_presentation,  color: Colors.red,)
                                             ),
                                        ],
                                      ),
                                      SizedBox(height: 10,),
                                      BillingContainer(
                                        widthSize: index > 0?  screenWidth*0.75:screenWidth*0.84,
                                        // titleText: 'Email (Primary Contact Email)',
                                        titleText2:  index > 0?'Contact Email':'Primary Contact Email',
                                        controller: _billingEmailControllers[index],
                                        keyboardType: TextInputType.emailAddress,
                                        errorMessage: _billingEmailListError[index] ??'',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: screenHeight * .013,),
                            ],
                          );

                        }),


                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * .013,),
              GestureDetector(
                onTap: () async {
                  _clientSignUp();
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
                    child:isLoading
                        ? SizedBox(
                        height:20,
                        width:20,
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

              SizedBox(height: screenHeight * .02,),
              InkWell(
                  onTap: (){
                    Navigator.pushNamed(context, RoutesName.login);
                  },
                  child: Text("Already  have an account? Login",style: TextStyle(color:Colors.blue),)),

              SizedBox(height: screenHeight * .01,),
            ],
          ),
        ),
      ),
    );}


  bool isValidEmail(String email) {
    final RegExp emailRegex =
    RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

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
      child: Icon(iconData,color: AppColors.navButtonColor,),
    );
  }
  Widget InVisibleHeaderRow(IconData iconData) {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return Container(
      height: screenHeight * 0.055,
      width: screenWidth * 0.12,
      child: Icon(iconData,color: Colors.transparent,),
    );
  }

  void _checkPasswordMatch() {
    _isPasswordMatching.value = _passwordController.text == _reEnterpasswordController.text;
  }

  Widget RequiredCustomContainer({
      required String titleText,
      required String titleText2,
      required TextEditingController controller,
      required TextInputType keyboardType,
      required FocusNode focusNode,
      FocusNode? focusCurrent,
      FocusNode? focusNext,
      String? errorMessage,

  }) {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      return Column(
      children: [
        SizedBox(height: screenHeight * .013),
        Padding(
          padding: const EdgeInsets.only(left: 10.0, bottom: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Text(titleText, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Text(" *", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
          ),
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
                contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                hintText: titleText2, // Set the placeholder text here
                hintStyle: TextStyle(color: Colors.grey),
              ),
              onFieldSubmitted: (value) {
                if (focusCurrent != null && focusNext != null) {
                  Utils.fieldFocusChange(context, focusCurrent, focusNext);
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



  Widget BillingContainer({
     String ? titleText,
    required String titleText2,
    required double widthSize,
    required TextEditingController controller,
    required TextInputType keyboardType,
    // required FocusNode focusNode,
    // FocusNode? focusCurrent,
    // FocusNode ?focusNext,
    String? errorMessage,
  }) {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          // height: screenHeight * 0.065,
          width: widthSize,
          // width: screenWidth*0.75,
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
              // focusNode: focusNode,

              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: titleText2,
                hintStyle: TextStyle(color: Colors.grey),
                contentPadding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 5),
              ),
              // onFieldSubmitted: (value) {
              //   if (focusCurrent != null && focusNext != null) {
              //     Utils.fieldFocusChange(context, focusCurrent, focusNext);
              //   }
              // },
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



  Widget NonRequiredCustomContainer({
    required String titleText,
    required String titleText2,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required FocusNode focusNode,
    FocusNode? focusCurrent,
    FocusNode ?focusNext,
  }) {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return Column(
      children: [
        SizedBox(height: screenHeight * .013,),
        // For TitleText
        Padding(
          padding: const EdgeInsets.only(left: 10.0,bottom: 10),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text(titleText,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),)),
        ),
        Container(
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
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              focusNode: focusNode,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: titleText2,
                hintStyle: TextStyle(color: Colors.grey),
                contentPadding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 5),
              ),
              onFieldSubmitted: (value) {
                if (focusCurrent != null && focusNext != null) {
                  Utils.fieldFocusChange(context, focusCurrent, focusNext);
                }
              },
            ),
          ),
        ),
        SizedBox(height: screenHeight * .013,),
      ],
    );
  }

}
