import 'dart:convert';
import 'dart:typed_data';
import 'package:c9_app/Modules/StaffModule/MODEL/staff_registrationModel/ConsultantNames.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/model/Registration/candidateStaffRole.dart';
import 'package:c9_app/view/widgets/customTextField.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as https;

import '../../../../../utils/utils.dart';

class PersonalSection extends StatefulWidget {
  final ScrollController scrollController;
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
  String? firstNameValidationError;
  String? lastNameValidationError;
  final String? genderValidationError;
  String? dobValidationError;
  final String? imageValidationError;
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
  final String? roleValidationError;
  String? consultantValidationError;
  String? passportNumValidationError;
  String? nationalNumValidationError;
  String? medicalValidationError;
  final String? maritalStatusValidationError;
  String? specifyValidationError;

  late bool firstNameEditing;

  PersonalSection({
    Key? key,
    required this.scrollController,
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

    this.firstNameValidationError,
    this.lastNameValidationError,
    this.genderValidationError,
    this.imageValidationError,
    this.dobValidationError,
    this.emailValidationError,
    this.passwordValidationError,
    this.repasswordValidationError,
    this.addressLine1ValidationError,
    this.addressLine2ValidationError,
    this.townCityValidationError,
    this.postCodeValidationError,
    this.phoneValidationError,
    this.alterphoneValidationError,
    this.emgNameValidationError,
    this.emgNumValidationError,

    ///section-3
    this.roleValidationError,
    this.consultantValidationError,
    this.passportNumValidationError,
    this.nationalNumValidationError,
    this.medicalValidationError,
    this.maritalStatusValidationError,
    this.specifyValidationError,
    required this.firstNameEditing,
  }) : super(key: key);

  @override
  _PersonalSectionState createState() => _PersonalSectionState();
}

class _PersonalSectionState extends State<PersonalSection> {
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

  }


  // Function to load the saved gender from SharedPreferences
  _loadSavedGender() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedGender = prefs.getString('gender') ?? 'Select Gender';
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


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width * 1;
    double screenHeight = MediaQuery.of(context).size.height * 1;
    return WillPopScope(
      onWillPop: () async {
        // Hide the keyboard when the back button is pressed
        FocusScope.of(context).unfocus();
        return true; // Allow the back action
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            // controller: widget.scrollController,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Form(
                key: widget.formKey,
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus(); // Hide keyboard
                    print("Hide");
                  },
                  child: Column(
                    children: [
                      Container(
                        height: 40,
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: AppColors.navColor,
                        ),
                        child: Center(
                          child: Text(
                            "CRM",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: AppColors.whiteColor,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 10),
                      Container(
                        height: 45,
                        width: screenWidth,
                        padding: EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                          // borderRadius: BorderRadius.circular(10),
                          color: Color(0xff487eb0),
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
                      SizedBox(height: 10),
                    // CustomTextField(
                    //   titleText: 'First Name',
                    //   requiredStar: "*",
                    //   placeholder: 'Enter your first name',
                    //   controller: widget.firstnameController,
                    //   focusCurrent: firstnameFocusNode,
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return 'First name is required';
                    //     } else if (value.length < 3) {
                    //       return 'First name must be at least 3 characters long.';
                    //     }
                    //     if (widget.firstNameValidationError != null && widget.firstNameValidationError!.isNotEmpty) {
                    //       return widget.firstNameValidationError;
                    //     }
                    //     return null; // No validation error
                    //   },
                    //   onChanged: (value) {
                    //     setState(() {
                    //       widget.firstNameValidationError = ""; // Clear error on text change
                    //     });
                    //   },
                    //   // onFieldSubmitted: (value) {
                    //   //   if (widget.firstNameValidationError != null &&
                    //   //       widget.firstNameValidationError!.isNotEmpty) {
                    //   //     // Display the flush bar with the error message
                    //   //     Utils.flushBarErrorMessage(
                    //   //       widget.firstNameValidationError!,
                    //   //       context,
                    //   //     );
                    //   //   } else {
                    //   //     // Optionally, handle cases where no API error exists
                    //   //     setState(() {
                    //   //       // Simulate setting an API validation error for demonstration
                    //   //       widget.firstNameValidationError = "This name is invalid per API.";
                    //   //       Utils.flushBarErrorMessage(
                    //   //         widget.firstNameValidationError!,
                    //   //         context,
                    //   //       );
                    //   //     });
                    //   //   }
                    //   // },
                    // ),
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
                          // Check if the length is less than 3 characters
                          if (value.length < 3) {
                            return 'First name must be at least 3 characters long.';
                          }
                          return null; // Validation passed
                        },
                      ),

                      // if (widget.firstNameEditing == false)
                    //     Padding(
                    //       padding: const EdgeInsets.only(left: 10.0),
                    //       child: Text(
                    //         widget.firstNameValidationError!,
                    //         style: TextStyle(
                    //           fontSize: 12,
                    //           fontWeight: FontWeight.bold,
                    //           color: Colors.red,
                    //         ),
                    //       ),
                    //     )
                    //   else
                    //     Text("Hii"),


                      // Text("${widget.firstNameEditing}"),
                      SizedBox(height: 10),
                      CustomTextField(
                        titleText: 'Last Name',
                        requiredStar: "*",
                        placeholder: 'Enter your last name',
                        controller: widget.lastnameController,
                        errorMessage: widget.lastNameValidationError,
                        focusCurrent: lastnameFocusNode,
                        focusNext: null,
                        validator: (value) {
                          // Check if the field is empty or invalid
                          if (value == null || value.isEmpty) {
                            return 'Last name is required';
                          } else if (value.length < 3) {
                            return 'Last name must be at least 3 characters long.';
                          }
                          // if (widget.lastNameValidationError != null && widget.lastNameValidationError!.isNotEmpty) {
                          //   return widget.lastNameValidationError;
                          // }
                          return null; // Valid input
                        },
                        // onChanged: (value) {
                        //   setState(() {
                        //     widget.lastNameValidationError = "";
                        //   });
                        // },
                      ),

                      const SizedBox(height: 10),
                      _buildGenderDropdown(),
                      const SizedBox(height: 10),
                      _selectedImageData != null
                          ? GestureDetector(
                              onTap: () {
                                // Navigate to a new screen with the full image
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FullImageScreen(imageData: _selectedImageData!),
                                  ),
                                );
                              },
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.transparent,
                                child: ClipOval(
                                  child: Image.memory(
                                    _selectedImageData!,
                                    fit: BoxFit.cover, // To make the image cover the circle
                                  ),
                                ),
                              ),
                            )
                          : SizedBox.shrink(),

                      // const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
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
                                  height: screenHeight * 0.065,
                                  width: screenWidth * 0.95,
                                  decoration: BoxDecoration(
                                    color: AppColors.navOpacity.withOpacity(0.2),
                                    border: Border.all(
                                      color: state.hasError
                                          ? Colors.red // Red border if validation fails
                                          : AppColors.navButtonColor.withOpacity(0.4),
                                      width: 0.4,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Choose image",
                                            style: TextStyle(fontSize: 15, color: Colors.black),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        _selectedImageName ?? "No image chosen",
                                        style: TextStyle(fontSize: 12, color: Colors.black),
                                      ),
                                      SizedBox(),
                                    ],
                                  ),
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
                      ),


                      if (widget.imageValidationError != null &&
                          widget.imageValidationError!.isNotEmpty) // Render error message only if not empty
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              widget.imageValidationError!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 10),
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
                      // buildDateContainer(
                      //   labelText: '--:--:--',
                      //   controller: widget.dobController,
                      //   errorMessage: widget.dobValidationError,
                      // ),
                      buildDateContainer(
                        labelText: '--:--:--',
                        controller: widget.dobController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Date of birth is required';
                          }
                          // if (widget.dobValidationError != null && widget.dobValidationError!.isNotEmpty) {
                          //   return widget.dobValidationError;
                          // }
                          return null;
                        },
                        // onDateChanged: (value) {
                        //   setState(() {
                        //     widget.dobValidationError = ""; // Clear the error message
                        //   });
                        // },
                      ),

                      SizedBox(height: 10),
                      CustomTextField(
                        titleText: 'Email',
                        requiredStar: "*",
                        placeholder: 'Enter your email address',
                        controller: widget.emailController,
                        errorMessage: widget.emailValidationError,
                        focusCurrent: emailFocusNode,
                        focusNext: passwordFocusNode,
                        validator: (value) {
                          // Check if the field is empty or invalid
                          if (value == null || value.isEmpty || !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
                            return 'A valid email is required.';
                          }
                          // if (widget.emailValidationError != null && widget.emailValidationError!.isNotEmpty) {
                          //   return widget.emailValidationError;
                          // }
                          return null; // Valid input
                        },
                        // onChanged: (value) {
                        //   setState(() {
                        //     widget.emailValidationError = "";
                        //   });
                        // },
                      ),
                      SizedBox(height: 10),

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
                                    color: Colors.red,
                                    width: 0.4,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
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
                                // if (widget.passwordValidationError != null && widget.passwordValidationError!.isNotEmpty) {
                                //   return widget.passwordValidationError;
                                // }
                                return null; // Valid input
                              },
                              onChanged: (value) {
                                // setState(() {
                                //   widget.passwordValidationError = ''; // Clear validation error on change
                                // });
                                _checkPasswordMatch(); // Additional password validation logic
                              },
                            ),
                          );
                        },
                      ),
                      SizedBox(height: screenHeight * .001),
                      if (widget.passwordValidationError != null && widget.passwordValidationError!.isNotEmpty)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              widget.passwordValidationError!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                              // maxLines: 1, // Ensure single-line error message
                              // overflow: TextOverflow.ellipsis, // Handle longer text gracefully
                            ),
                          ),
                        ),

                      SizedBox(height: screenHeight * .013),
                      // Re-Enter Password
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
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
                                    color: Colors.red,
                                    width: 0.4,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
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
                                // if (widget.repasswordValidationError != null &&
                                //     widget.repasswordValidationError!.isNotEmpty) {
                                //   return widget.repasswordValidationError;
                                // }
                                return null; // Valid input
                              },
                              onChanged: (value) {
                                // setState(() {
                                //   widget.repasswordValidationError = '';
                                // });
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
                              if (widget.repasswordValidationError != null && widget.repasswordValidationError!.isNotEmpty)
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      widget.repasswordValidationError!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                      // maxLines: 1, // Ensure single-line error message
                                      // overflow: TextOverflow.ellipsis, // Handle longer text gracefully
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
                                        if (widget.passwordController.text.isNotEmpty &&
                                            widget.reEnterpasswordController.text.isNotEmpty)
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
                      SizedBox(height: screenHeight * .013),
                      Container(
                        height: 45,
                        width: screenWidth,
                        padding: EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                          // borderRadius: BorderRadius.circular(10),
                          color: Color(0xff487eb0),
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

                      SizedBox(height: 10),
                      CustomTextField(
                        titleText: 'Address Line 1',
                        requiredStar: "*",
                        placeholder: 'Enter your address line 1',
                        controller: widget.address1Controller,
                        errorMessage: widget.addressLine1ValidationError,
                        focusCurrent: address1FocusNode,
                        focusNext: address2FocusNode,
                        validator: (value) {
                          // Check if the field is empty or invalid
                          if (value == null || value.isEmpty) {
                            return 'Address Line 1 is required';
                          }
                          // if (widget.addressLine1ValidationError != null &&
                          //     widget.addressLine1ValidationError!.isNotEmpty) {
                          //   return widget.addressLine1ValidationError;
                          // }
                          return null; // Valid input
                        },
                        // onChanged: (value) {
                        //   setState(() {
                        //     widget.addressLine1ValidationError = "";
                        //   });
                        // },
                      ),
                      SizedBox(height: 10),
                      CustomTextField(
                        titleText: 'Address Line 2',
                        requiredStar: "*",
                        placeholder: 'Enter your address line 2',
                        controller: widget.address2Controller,
                        errorMessage: widget.addressLine2ValidationError,
                        focusCurrent: address2FocusNode,
                        focusNext: townCityFocusNode,
                        validator: (value) {
                          // Check if the field is empty or invalid
                          if (value == null || value.isEmpty) {
                            return 'Address Line 2 is required';
                          }
                          // if (widget.addressLine2ValidationError != null &&
                          //     widget.addressLine2ValidationError!.isNotEmpty) {
                          //   return widget.addressLine2ValidationError;
                          // }
                          return null; // Valid input
                        },
                        // onChanged: (value) {
                        //   setState(() {
                        //     widget.addressLine2ValidationError = "";
                        //   });
                        // },
                      ),

                      SizedBox(height: 10),
                      CustomTextField(
                        titleText: 'Town/City',
                        placeholder: 'Enter your town city',
                        controller: widget.townCityController,
                        errorMessage: widget.townCityValidationError,
                        focusCurrent: townCityFocusNode,
                        focusNext: postCodeFocusNode,
                        validator: (value) {
                          // Check if the field is empty or invalid
                          if (value == null || value.isEmpty) {
                            return 'Town or City address must be required.';
                          }
                          // if (widget.townCityValidationError != null && widget.townCityValidationError!.isNotEmpty) {
                          //   return widget.townCityValidationError;
                          // }
                          return null; // Valid input
                        },
                        // onChanged: (value) {
                        //   setState(() {
                        //     widget.townCityValidationError = "";
                        //   });
                        // },
                      ),
                      SizedBox(height: 10),
                      CustomTextField(
                        titleText: 'Post Code',
                        requiredStar: "*",
                        placeholder: 'Enter your post code',
                        controller: widget.postCodeController,
                        errorMessage: widget.postCodeValidationError,
                        focusCurrent: postCodeFocusNode,
                        focusNext: phoneFocusNode,
                        validator: (value) {
                          // Check if the field is empty or invalid
                          if (value == null || value.isEmpty) {
                            return 'Post Code is required.';
                          } else if (value.length > 8) {
                            return 'Post Code must be less than or equal to 8 characters.';
                          }
                          // if (widget.postCodeValidationError != null && widget.postCodeValidationError!.isNotEmpty) {
                          //   return widget.postCodeValidationError;
                          // }
                          return null; // Valid input
                        },
                        // onChanged: (value) {
                        //   setState(() {
                        //     widget.postCodeValidationError = "";
                        //   });
                        // },
                      ),
                      SizedBox(height: 10),
                      CustomTextField(
                        titleText: 'Phone Number',
                        requiredStar: "*",
                        placeholder: 'Enter your phone number',
                        controller: widget.phoneController,
                        errorMessage: widget.phoneValidationError,
                        focusCurrent: phoneFocusNode,
                        focusNext: alterPhoneFocusNode,
                        validator: (value) {
                          // Check if the field is empty or invalid
                          if (value == null || value.isEmpty || !RegExp(r'^(?:\+44|0)7\d{9}$').hasMatch(value)) {
                            return 'Phone number must be a valid UK phone number';
                          }
                          // if (widget.phoneValidationError != null && widget.phoneValidationError!.isNotEmpty) {
                          //   return widget.phoneValidationError;
                          // }
                          return null; // Valid input
                        },
                        // onChanged: (value) {
                        //   setState(() {
                        //     widget.phoneValidationError = "";
                        //   });
                        // },
                      ),
                      SizedBox(height: 10),
                      CustomTextField(
                        titleText: 'Alternative Phone Number',
                        requiredStar: "*",
                        placeholder: 'Enter your alternative phone number',
                        controller: widget.alterphoneController,
                        errorMessage: widget.alterphoneValidationError,
                        focusCurrent: alterPhoneFocusNode,
                        focusNext: emgNameFocusNode,
                        validator: (value) {
                          // Check if the field is empty or invalid
                          if (value == null || value.isEmpty || !RegExp(r'^(?:\+44|0)7\d{9}$').hasMatch(value)) {
                            return 'Alternative phone number must be a valid UK phone number';
                          }
                          // if (widget.alterphoneValidationError != null && widget.alterphoneValidationError!.isNotEmpty) {
                          //   return widget.alterphoneValidationError;
                          // }
                          return null; // Valid input
                        },
                        // onChanged: (value) {
                        //   setState(() {
                        //     widget.alterphoneValidationError = "";
                        //   });
                        // },
                      ),
                      SizedBox(height: 10),
                      CustomTextField(
                        titleText: 'Emergency Contact Name',
                        requiredStar: "*",
                        placeholder: 'Enter your emergency contact name',
                        controller: widget.emgNameController,
                        errorMessage: widget.emgNameValidationError,
                        focusCurrent: emgNameFocusNode,
                        focusNext: emgNumFocusNode,
                        validator: (value) {
                          // Check if the field is empty or invalid
                          if (value == null || value.isEmpty) {
                            return 'Emergency contact name is required.';
                          } else if (value.length < 3) {
                            return 'Emergency contact name must be at least 3 characters long.';
                          }
                          // if (widget.emgNameValidationError != null && widget.emgNameValidationError!.isNotEmpty) {
                          //   return widget.emgNameValidationError;
                          // }
                          return null; // Valid input
                        },
                        // onChanged: (value) {
                        //   setState(() {
                        //     widget.emgNameValidationError = "";
                        //   });
                        // },
                      ),
                      SizedBox(height: 10),
                      CustomTextField(
                        titleText: 'Emergency Contact Number',
                        requiredStar: "*",
                        placeholder: 'Enter your emergency contact number',
                        controller: widget.emgNumController,
                        errorMessage: widget.emgNumValidationError,
                        focusCurrent: emgNumFocusNode,
                        focusNext: null,
                        validator: (value) {
                          if (value == null || value.isEmpty || !RegExp(r'^(?:\+44|0)7\d{9}$').hasMatch(value)) {
                            return 'Emergency Contact number must be a valid UK phone number.';
                          }
                          // if (widget.emgNumValidationError != null && widget.emgNumValidationError!.isNotEmpty) {
                          //   return widget.emgNumValidationError;
                          // }
                          return null; // Valid input
                        },
                        // onChanged: (value) {
                        //   setState(() {
                        //     widget.emgNumValidationError = "";
                        //   });
                        // },
                      ),
                      SizedBox(
                        height: screenHeight * .023,
                      ),
                      Container(
                        height: 45,
                        width: screenWidth,
                        padding: EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                          // borderRadius: BorderRadius.circular(10),
                          color: Color(0xff487eb0),
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
                      SizedBox(
                        height: screenHeight * .013,
                      ),
                      // SizedBox(height: 10),
                      Column(
                        children: [
                          // SizedBox(height: screenHeight * .013),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
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
                                  height: screenHeight * 0.065,
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
                            }
                          // if (widget.roleValidationError != null &&
                          //     widget.roleValidationError!.isNotEmpty) // Render error message only if not empty
                          //   Padding(
                          //     padding: const EdgeInsets.only(left: 10.0),
                          //     child: Align(
                          //       alignment: Alignment.topLeft,
                          //       child: Text(
                          //         widget.roleValidationError!,
                          //         style: TextStyle(
                          //           fontSize: 12,
                          //           fontWeight: FontWeight.bold,
                          //           color: Colors.red,
                          //         ),
                          //       ),
                          //     ),
                          //   ),

                      ),
                      SizedBox(height: screenHeight * .013,),
                          _buildMeritalDropdown(),
                      SizedBox(height: screenHeight * .013,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
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
                          const SizedBox(height: 8),
                          Container(
                              height: screenHeight * 0.065,
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
                      SizedBox(
                        height: screenHeight * .013,
                      ),
                      // Search or Consultant Name
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
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

                      SizedBox(
                        height: screenHeight * .013,
                      ),
                      CustomTextField(
                        titleText: 'Passport Number',
                        requiredStar: "*",
                        placeholder: 'Enter your passport number',
                        controller: widget.passportNumController,
                        errorMessage: widget.passportNumValidationError,
                        focusCurrent: passNumFocusNode,
                        focusNext: niNumFocusNode,
                        validator: (value) {
                          final ukPassportRegex = RegExp(r'^[A-Z]{2}[0-9]{7}$');
                          if (value == null || value.isEmpty) {
                            return 'Passport Number is required.';
                          } else if (!ukPassportRegex.hasMatch(value)) {
                            return 'Invalid passport number. It must start with 2 uppercase letters followed by 7 digits.';
                          }
                          // if (widget.passportNumValidationError != null && widget.passportNumValidationError!.isNotEmpty) {
                          //   return widget.passportNumValidationError;
                          // }
                          return null; // Valid input
                        },
                        onChanged: (value) {
                          setState(() {
                            widget.passportNumValidationError = "";
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
                        errorMessage: widget.nationalNumValidationError,
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
                          // if (widget.nationalNumValidationError != null && widget.nationalNumValidationError!.isNotEmpty) {
                          //   return widget.nationalNumValidationError;
                          // }
                          return null; // Valid input
                        },
                        onChanged: (value) {
                          setState(() {
                            widget.nationalNumValidationError = "";
                          });
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
                          SizedBox(height: screenHeight * .013),

                          if (_selectedOption3 == 'Yes') ...[
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
                            // Container(
                            //   padding: const EdgeInsets.symmetric(horizontal: 15.0),
                            //   decoration: BoxDecoration(
                            //     color: Colors.white,
                            //     borderRadius: BorderRadius.circular(8.0),
                            //     border: Border.all(
                            //       color: Colors.grey.withOpacity(0.4),
                            //       width: 0.4,
                            //     ),
                            //   ),
                            //   child: DropdownButton<String>(
                            //     isExpanded: true,
                            //     value: _conditionalOptions.contains(_selectedDbsOptions) ? _selectedDbsOptions : null,
                            //     hint: const Text('---Select One---'),
                            //     items: _conditionalOptions.map((option) {
                            //       return DropdownMenuItem(
                            //         value: option,
                            //         child: Text(option),
                            //       );
                            //     }).toList(),
                            //     onChanged: (newValue) async {
                            //       setState(() {
                            //         _selectedDbsOptions = newValue;
                            //       });
                            //       final prefs = await SharedPreferences.getInstance();
                            //       prefs.setString('dbsCheckType', newValue!);
                            //       widget.onDBSCheckTypeChange(newValue);
                            //     },
                            //   ),
                            // )

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
                          SizedBox(height: screenHeight * .013),

                        if (_selectedOption4 == 'Yes') ...[
                         Align(
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
                         SizedBox(height: screenHeight * .013),
                          FormField<String>(
                              validator: (value) {
                                if (_selectedOption4 == 'Yes' && (value == null || value.isEmpty)) {
                                  print("1");
                                  return 'Please enter details of unspent criminal convictions';
                                }
                                return null;
                              },
                              autovalidateMode: AutovalidateMode.onUserInteraction,
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
                         );}),
                       ],
                      SizedBox(height: screenHeight * .013),
                    ],
                  ),
        ]
              ),
            ),
          ),
        ),
      ),
    ))
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
  // Future<void> _pickImage(ImageSource source) async {
  //   XFile? pickedImage = await _imagePicker.pickImage(source: source);
  //
  //   if (pickedImage != null) {
  //     Uint8List imageData = await pickedImage.readAsBytes();
  //     String imageName = pickedImage.name;
  //     List<String> fileNameParts = imageName.split('.');
  //     String imageExtension = fileNameParts.last;
  //     String imageNameShortened =
  //         imageName.length > 15 ? imageName.substring(0, 15) + "..." + imageExtension : imageName;
  //
  //     // Save image as base64 string
  //     String base64Image = base64Encode(imageData);
  //
  //     final prefs = await SharedPreferences.getInstance();
  //     prefs.setString('image', base64Image);
  //     prefs.setString('imageName', imageNameShortened);
  //
  //     onImageChange(imageData, imageNameShortened);
  //   } else {
  //     print('No image selected');
  //   }
  // }

  // Widget _buildGenderDropdown() {
  //   double screenWidth = MediaQuery.of(context).size.width * 1;
  //   double screenHeight = MediaQuery.of(context).size.height * 1;
  //   return Column(
  //     children: [
  //       Row(
  //         children: [
  //           const Text(
  //             'Gender ',
  //             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
  //           ),
  //           const Text(
  //             '*',
  //             style: TextStyle(color: Colors.red, fontSize: 16),
  //           ),
  //         ],
  //       ),
  //       const SizedBox(height: 8),
  //       Container(
  //           height: screenHeight * 0.065,
  //           width: screenWidth * 0.95,
  //           padding: EdgeInsets.symmetric(horizontal: 15.0),
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.circular(8.0),
  //             border: Border.all(color: Colors.grey.withOpacity(0.4), width: 0.4),
  //           ),
  //           child: DropdownButtonHideUnderline(
  //             child: DropdownButton<String>(
  //               isExpanded: true,
  //               // iconEnabledColor: Colors.grey,
  //               iconSize: 30.0,
  //               value: selectedGender == 'Select Gender' ? null : selectedGender,
  //               hint: const Text('Select Gender'),
  //               items: ['Male', 'Female', 'Other'].map((gender) {
  //                 return DropdownMenuItem(
  //                   value: gender,
  //                   child: Text(gender),
  //                 );
  //               }).toList(),
  //               onChanged: (String? newValue) async {
  //                 setState(() {
  //                   selectedGender = newValue;
  //                 });
  //                 // Save selected gender to SharedPreferences
  //                 final prefs = await SharedPreferences.getInstance();
  //                 prefs.setString('gender', newValue!);
  //                 widget.onGenderChange(newValue);
  //               },
  //             ),
  //           )),
  //       if (widget.genderValidationError != null && widget.genderValidationError!.isNotEmpty)
  //         Padding(
  //           padding: const EdgeInsets.only(top: 4.0),
  //           child: Text(
  //             widget.genderValidationError!,
  //             style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
  //           ),
  //         ),
  //     ],
  //   );
  // }
  Widget _buildGenderDropdown() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
        const SizedBox(height: 8),
        FormField<String>(
          initialValue: selectedGender ?? 'Select Gender', // Set the initial value properly
          validator: (value) {
            // If the gender is not selected or is 'Select Gender', trigger the validation error
            if (value == null || value.isEmpty || value == 'Select Gender') {
              return 'Gender is required';
            }
            return null; // No error if gender is selected
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
          builder: (FormFieldState<String> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: screenHeight * 0.065,
                  width: screenWidth * 0.95,
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: state.hasError ? Colors.red : Colors.grey.withOpacity(0.4),
                      width: 0.4,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      iconSize: 30.0,
                      value: selectedGender == 'Select Gender' ? null : selectedGender,
                      hint: const Text('Select Gender'),
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
        ),
      ],
    );
  }

  Widget _buildMeritalDropdown() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
                  height: screenHeight * 0.065,
                  width: screenWidth * 0.95,
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: state.hasError ? Colors.red : Colors.grey.withOpacity(0.4),
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



  // Widget buildDateContainer({
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
  //         width: screenWidth * 0.95,
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
  //                       headerBackgroundColor: AppColors.navColor, //Header Background Color
  //
  //                       backgroundColor: Colors.white, //Main Baground
  //
  //                       headerForegroundColor: Colors.white, //Header Text Color
  //                       surfaceTintColor: Colors.white, //Main Background Needed
  //                     ),
  //                     textButtonTheme: TextButtonThemeData(
  //                       style: TextButton.styleFrom(
  //                         foregroundColor: AppColors.navButtonColor, //Cancel Ok  button text color
  //                       ),
  //                     ),
  //                   ),
  //                   child: child!,
  //                 );
  //               },
  //             );
  //             if (pickedDate != null) {
  //               String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
  //               setState(() {
  //                 controller.text = formattedDate;
  //               });
  //             }
  //           },
  //         ),
  //       ),
  //       if (errorMessage != null && errorMessage.isNotEmpty)
  //         Padding(
  //           padding: const EdgeInsets.only(top: 4),
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
                  widget.dobValidationError = ""; // Clear the validation error
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
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
        SizedBox(height: screenHeight * 0.013),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
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
        ),
      ],
    );
  }

}

class FullImageScreen extends StatelessWidget {
  final Uint8List imageData;

  FullImageScreen({required this.imageData});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Image.memory(
            imageData,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
