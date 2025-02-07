import 'dart:convert';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/view/widgets/customTextField.dart';
import 'package:c9_app/view/widgets/date_pickerContainer.dart';
import 'package:c9_app/view/widgets/dropdown_yesno.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as https;
import '../../../../../utils/utils.dart';

class BankStep2 extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final VoidCallback onFinish;
  final VoidCallback onPrevious;
  final Function(List<String>) onLicenseTypesChange;
  final TextEditingController liNumberController;
  final TextEditingController anyEndorsmentController;
  final TextEditingController cpcNumController;
  final TextEditingController techoNumberController;
  final TextEditingController expiryController;
  final String selectedRole;
  final Function(String) onUKDrivingChange;
  final Function(String) onUKHoldChange;
  final Function(String) onUKPenaltyChange;
  final Function(String) onValidCPCChange;
  final Function(String) onValidTachoChange;
  final TextEditingController dlNumberController;
  final TextEditingController dlIssueController;
  final TextEditingController dlCategoryController;
  final TextEditingController dlCheckController;

  BankStep2({
    required this.formKey,
    required this.onFinish,
    required this.onPrevious,
    required this.onLicenseTypesChange,
    required this.liNumberController,
    required this.anyEndorsmentController,
    required this.cpcNumController,
    required this.techoNumberController,
    required this.expiryController,
    required this.selectedRole,
    required this.onUKDrivingChange,
    required this.onUKHoldChange,
    required this.onUKPenaltyChange,
    required this.onValidCPCChange,
    required this.onValidTachoChange,
    required this.dlNumberController,
    required this.dlIssueController,
    required this.dlCategoryController,
    required this.dlCheckController,
    Key? key,
  }) : super(key: key);

  @override
  _BankStep2State createState() => _BankStep2State();
}

class _BankStep2State extends State<BankStep2> {
  final PageController _pageController = PageController();
  int subCurrentStep = 0;
  final List<GlobalKey<FormState>> _formKeys = List.generate(3, (_) => GlobalKey<FormState>());

  late TextEditingController documentsController;
  String? liValidationError;
  String? licenseTypesValidationError;
  String? anyEndorsmentValidationError;
  String? cpcNumValidationError;
  String? techoNumberValidationError;

  String? dlNumberValidationError;
  String? dlIssueValidationError;
  String? dlCategoryValidationError;
  String? dlCheckValidationError;

  String? expiryValidationError;

  List<String> _selectedLicenseTypes = [];
  final List<String> _licenseTypes = ['Class B', 'Class C', 'Class D', 'Class D1', 'Class E'];
  final Map<String, String> licenseTypeMap = {
    'Class B': 'classB',
    'Class C': 'classC',
    'Class D': 'classD',
    'Class D1': 'classD1',
    'Class E': 'classE',
  };

  final List<String> _dropdownOptions = ['Yes', 'No'];
  String? _selectedOption1;
  String? _selectedOption2 ;
  String? _selectedOption3 ;
  String? _selectedOption4 ;
  String? _selectedOption5 ;
  Map<String, dynamic> _formData = {
    'uk_driving_experience': 0,
    'valid_uk_driving_license': 0,
    'penalty_points': 0,
    'noCpcCard': 0,
    'noTachoCard': 0,
  };

  Future<bool> _postBankData(int subCurrentStep) async {
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

      if (subCurrentStep == 0) {
        print('Print for 0:$subCurrentStep');
        List<String> postedLicenseTypes = [];
        for (int i = 0; i < _selectedLicenseTypes.length; i++) {
          String postedValue = licenseTypeMap[_selectedLicenseTypes[i]] ?? '';
          if (postedValue.isNotEmpty) {
            request.fields['licenceTypes[$i]'] = postedValue;
            postedLicenseTypes.add(postedValue);
          }
        }
        print('Licence Types:------------- $postedLicenseTypes');
        request.fields['licenceNumber'] = widget.liNumberController.text;
        request.fields['licenceEndorsements'] = widget.anyEndorsmentController.text;
        request.fields['cpcNumber'] = widget.cpcNumController.text;
        request.fields['tachoNumber'] = widget.techoNumberController.text;
        request.fields['uk_driving_experience'] = _selectedOption1 == 'Yes' ? '1' : '0';
        request.fields['valid_uk_driving_license'] = _selectedOption2 == 'Yes' ? '1' : '0';
        request.fields['penalty_points'] = _selectedOption3 == 'Yes' ? '1' : '0';
        request.fields['driving_license_number'] = widget.dlNumberController.text;
        request.fields['driving_license_issue_date'] = widget.dlIssueController.text;
        request.fields['driving_license_category'] = widget.dlCategoryController.text;
        request.fields['driving_license_check_code'] = widget.dlCheckController.text;
      } else if (subCurrentStep == 1) {
        request.fields['dbsExpiry'] = widget.expiryController.text;
        print('Print for 1:$subCurrentStep');
      } else if (subCurrentStep == 2) {
        print('Print for 3:$subCurrentStep');
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
        print("API Request Successful for Step $subCurrentStep");
        Utils.flushBarSuccessMessage('Data submitted successfully', context);
        return true; // Success
      } else if (response.statusCode == 422) {
        // Parse the validation errors
        final responseData = jsonDecode(responseString) as Map<String, dynamic>;
        if (responseData.containsKey('errors')) {
          final validationErrors = responseData['errors'] as Map<String, dynamic>;
          Navigator.pop(context);
          setState(() {
            if (subCurrentStep == 0) {
              print('Print validation for 0:$subCurrentStep');
              licenseTypesValidationError = validationErrors['licenceTypes']?.join(', ');
              liValidationError = validationErrors['licenceNumber']?.join(', ');
              anyEndorsmentValidationError = validationErrors['licenceNumber']?.join(', ');
              cpcNumValidationError = validationErrors['licenceNumber']?.join(', ');
              techoNumberValidationError = validationErrors['licenceNumber']?.join(', ');

              dlNumberValidationError = validationErrors['driving_license_number']?.join(', ');
              dlIssueValidationError = validationErrors['driving_license_issue_date']?.join(', ');
              dlCategoryValidationError = validationErrors['driving_license_category']?.join(', ');
              dlCheckValidationError = validationErrors['driving_license_check_code']?.join(', ');
              int errorCount = [
                licenseTypesValidationError,
                liValidationError,
                anyEndorsmentValidationError,
                cpcNumValidationError,
                techoNumberValidationError,
                dlNumberValidationError,
                dlIssueValidationError,
                dlCategoryValidationError,
                dlCheckValidationError
              ].where((error) => error != null && error.isNotEmpty).length;
              if (errorCount == 0) {
                // Utils.flushBarSuccessMessage('All fields are valid!', context);
              } else {
                Utils.flushBarErrorMessage('Please fill in all the required fields', context,);
              }
            } else if (subCurrentStep == 1) {
              expiryValidationError = validationErrors['dbsExpiry']?.join(', ');
              print('Print validation for 1:$subCurrentStep');
            } else if (subCurrentStep == 2) {
              print('Print validation for 3:$subCurrentStep');
            }
          });
        }
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
  Future<void> _loadFormData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      documentsController.text = prefs.getString('document') ?? '';
      String? encodedList = prefs.getString('selectedLicenseTypes');
      if (encodedList != null) {
        _selectedLicenseTypes = List<String>.from(jsonDecode(encodedList));
      } else {
        _selectedLicenseTypes = [];
      }
      print("Loaded selectedLicenseTypes: $_selectedLicenseTypes");
      _selectedOption1 = prefs.getString('UKDriving');
      _selectedOption2 = prefs.getString('UKHold');
      _selectedOption3 = prefs.getString('UKPenalty');
    });
  }
  Future<void> _saveFormData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('document', documentsController.text);
    prefs.setString('selectedLicenseTypes', jsonEncode(_selectedLicenseTypes));
  }


  @override
  void initState() {
    super.initState();
    documentsController = TextEditingController();
    _loadFormData();
    if (widget.selectedRole.toLowerCase().contains('driver')) {
      subCurrentStep = 0; // Start from step 0 for drivers
    } else {
      subCurrentStep = 1; // Start from step 1 for other roles
    }

    liValidationError = null;
    anyEndorsmentValidationError = null;
    cpcNumValidationError = null;
    techoNumberValidationError = null;
    dlNumberValidationError = null;
    dlIssueValidationError = null;
    dlCategoryValidationError = null;
    dlCheckValidationError = null;
    expiryValidationError = null;
    widget.liNumberController.addListener(() {
      setState(() {}); // Trigger rebuild when License Number changes
    });
  }
  @override
  void dispose() {
    widget.liNumberController.removeListener(() {});
    super.dispose();
  }

  Widget _buildTabButton(String label, int index, {required bool isEnabled}) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return GestureDetector(
      onTap: isEnabled
          ? () {
        if (index < subCurrentStep) {
          // Allow going back to previous steps without validation
          _goToPage(index);
        } else if (index == 1 && widget.liNumberController.text.isNotEmpty) {
          // Allow navigation from index 0 to index 1 if liNumberController is filled
          _goToPage(1);
        } else if (index == 2 &&
            widget.liNumberController.text.isNotEmpty &&
            widget.expiryController.text.isNotEmpty) {
          // Allow navigation from index 0 to index 2 if both fields are filled
          _goToPage(2);
        } else if (index == 2 && widget.expiryController.text.isNotEmpty) {
          // Allow navigation from index 1 to index 2 if expiryController is filled
          _goToPage(2);
        }
      }
          : null, // Disable tap action
      child: Container(
        height: screenHeight*0.05,
        width: screenWidth*0.31,
        decoration: BoxDecoration(
          color: subCurrentStep == index
          // ? Color(0xff487eb0)
              ?  AppColors.navColor
              : isEnabled
          // ? AppColors.greyOpacity
              ?Color(0xff487eb0)
              : Colors.white, // Disabled color
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: subCurrentStep == index
                  ? AppColors.whiteColor
                  : isEnabled
                  ? AppColors.whiteColor
              // ? AppColors.blackColor
                  : Colors.black38, // Disabled text color
            ),
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return Column(
      children: [

        SizedBox(height: 10),
        // Text(widget.selectedRole),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Driving Information tab
            _buildTabButton(
              'Driving Information',
              0,
              isEnabled: widget.selectedRole.toLowerCase().contains("driver"), // Disable if this is not "Driver"
            ),
            // Expiry & Licences tab
            _buildTabButton(
              'Expiry & Licences',
              1,
              isEnabled: true, // Always enabled
            ),
            // Documents tab
            _buildTabButton(
              'Documents',
              2,
              isEnabled: true, // Always enabled
            ),
          ],
        ),

        const SizedBox(height: 10),
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: !widget.selectedRole.toLowerCase().contains("driver")
                ? [
              _buildExpiryLicencesSection(),
              _buildDocumentsSection(),
            ]
                : [
              _buildDrivingInfoSection(),
              _buildExpiryLicencesSection(),
              _buildDocumentsSection(),
            ],
          ),
        ),

        Container(
          width: screenWidth * 0.95,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (subCurrentStep > 0 && (widget.selectedRole.toLowerCase().contains("driver") || subCurrentStep == 2))
                InkWell(
                  onTap: _goPreviousStep,
                  child: ButtonContainer(
                    "Go Back",
                    AppColors.navOpacity,
                    Colors.black,
                  ),
                ),
              if (subCurrentStep == 0 || (!widget.selectedRole.toLowerCase().contains("driver") && subCurrentStep == 1))
                InkWell(
                  onTap: widget.onPrevious,
                  child: ButtonContainer(
                    "Back",
                    AppColors.navOpacity,
                    Colors.black,
                  ),
                ),
              if (subCurrentStep < 2)
                InkWell(
                  onTap: continueButton,
                  child: ButtonContainer(
                    "Continue",
                    AppColors.navButtonColor,
                    Colors.white,
                  ),
                ),
              if (subCurrentStep == 2)
                InkWell(
                  onTap: () {
                    if (validateCurrentStep()) {
                      widget.onFinish();
                      _saveFormData();
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

  Widget _buildDrivingInfoSection() {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return SingleChildScrollView(
      controller: _scrollController,
      child: Form(
        key: _formKeys[0],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Text("${widget.selectedRole}"),
            // SizedBox(height: screenHeight * .013),

            ConditionalDropdown(
              title: "Do you hold a valid UK driving license?",
              options: _dropdownOptions,
              selectedOption: _selectedOption2,
              onChanged: (newValue) async {
                setState(() {
                  _selectedOption2 = newValue!;
                  _formData['valid_uk_driving_license'] = newValue == 'Yes' ? 1 : 0;
                });

                // Post the selected value
                final valueToPost = newValue == 'Yes' ? 1 : 0;
                if (newValue != null) {
                  print("Value to post: $valueToPost");
                }
                final prefs = await SharedPreferences.getInstance();
                prefs.setString('UKHold', newValue!);
                widget.onUKHoldChange(newValue);
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select an option.';
                }
                return null;
              },
            ),
            if(_selectedOption2=="Yes")...[
                SizedBox(height: screenHeight * .013,),
                ConditionalDropdown(
                  title:"Do you have UK driving experience?",
                  options: _dropdownOptions,
                  selectedOption: _selectedOption1,
                  onChanged: (newValue) async {
                    setState(() {
                      _selectedOption1 = newValue!;
                      _formData['uk_driving_experience'] = newValue == 'Yes' ? 1 : 0;
                    });

                    // Post the selected value
                    final valueToPost = newValue == 'Yes' ? 1 : 0;
                    if (newValue != null) {
                      print("Value to post: $valueToPost");
                    }
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setString('UKDriving', newValue!);
                    widget.onUKDrivingChange(newValue);
                  },
                  validator: (value) {
                    if (_selectedOption2=="Yes" && value == null) {
                      return 'Please select an option.';
                    }
                    return null;
                  },
                ),


              if(_selectedOption1=="Yes")...[
                SizedBox(height: screenHeight * .013,),
                CustomTextField(
                  titleText: 'License Number',
                  requiredStar: '*',
                  placeholder: 'Enter your license number',
                  controller: widget.liNumberController,
                  errorMessage: liValidationError,
                  validator: (value) {
                    // Check if the field is empty or invalid
                    if (_selectedOption2 == "Yes" && _selectedOption1 == "Yes" && (value == null || value.isEmpty)) {
                      return 'License Number is required.';
                    } else if (_selectedOption2 == "Yes" && _selectedOption1 == "Yes" && value!.length < 16) {
                      return 'License Number must be at least 16 characters.';
                    }
                    return null; // Valid input
                  },

                ),
              ],

              if (widget.liNumberController.text.isNotEmpty)...[
                SizedBox(height: screenHeight * .013),
                ConditionalDropdown(
                  title: "Do you have penalty points on your license?",
                  options: _dropdownOptions,
                  selectedOption: _selectedOption3,
                  onChanged: (newValue) async {
                    setState(() {
                      _selectedOption3 = newValue!;
                      _formData['penalty_points'] = newValue == 'Yes' ? 1 : 0;
                    });
                    final valueToPost = newValue == 'Yes' ? 1 : 0;
                    if (newValue != null) {
                      print("Value to post: $valueToPost");
                    }
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setString('UKPenalty', newValue!);
                    widget.onUKPenaltyChange(newValue);
                  },
                  validator: (value) {
                    if (_selectedOption2=="Yes" && _selectedOption1=="Yes"&& widget.liNumberController.text.isNotEmpty && value == null) {
                      return 'Please select an option.';
                    }
                    return null;
                  },
                ),

                SizedBox(height: screenHeight * .013),
                buildDateContainer(
                  Textlabel: "Date of issue of the driving license.",
                  requiredStar:"",
                  labelText: 'dd/mm/yyyy',
                  controller: widget.dlIssueController,
                  validator: (value) {
                    if (_selectedOption2 == "Yes" &&
                        _selectedOption1 == "Yes" &&
                        widget.liNumberController.text.isNotEmpty &&
                        (value == null || value.isEmpty)) {
                      return 'Date of birth is required';
                    }
                    return null;
                  },

                ),
                SizedBox(height: screenHeight * .013),
                CustomTextField(
                  titleText: 'Check code for driving license.',
                  requiredStar: '*',
                  placeholder: 'Enter your code',
                  controller: widget.dlCheckController,
                  errorMessage: dlCheckValidationError,
                  validator: (value) {
                    // Check if the field is empty or invalid
                    if (_selectedOption2 == "Yes" &&
                        _selectedOption1 == "Yes" &&
                        widget.liNumberController.text.isNotEmpty &&
                        (value == null || value.isEmpty)) {
                      return 'Code Number is required.';
                    }
                    return null; // Valid input
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
                          'Licence Type ',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '(choose one or multiple types)',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          " *",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                        )
                      ],
                    ),
                  ),
                ),
                FormField<List<String>>(
                  initialValue: _selectedLicenseTypes,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (_selectedOption2 == "Yes" &&
                        _selectedOption1 == "Yes" &&
                        widget.liNumberController.text.isNotEmpty &&
                        (value == null || value.isEmpty)) {
                      return "Please select at least one license type.";
                    }
                    return null; // Valid input
                  },

                  builder: (FormFieldState<List<String>> field) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: screenHeight * 0.065,
                          width: screenWidth * 0.95,
                          decoration: BoxDecoration(
                            color: AppColors.navOpacity.withOpacity(0.2),
                            border: Border.all(
                              color: AppColors.navButtonColor.withOpacity(0.4),
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
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Center(
                                  child: Text(
                                    "Choose types",
                                    style: TextStyle(fontSize: 15, color: AppColors.blackColor),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: screenHeight * 0.065,
                                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      iconEnabledColor: AppColors.navButtonColor,
                                      iconSize: 30.0,
                                      hint: Text(
                                        'Select Licence Type',
                                        style: TextStyle(fontSize: 14, color: AppColors.navButtonColor),
                                      ),
                                      items: _licenseTypes.map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value, style: TextStyle(fontSize: 14)),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) async {
                                        if (newValue != null && !_selectedLicenseTypes.contains(newValue)) {
                                          setState(() {
                                            _selectedLicenseTypes.add(newValue);
                                          });
                                          field.didChange(List.from(_selectedLicenseTypes)); // Update field state
                                        }
                                        final prefs = await SharedPreferences.getInstance();
                                        prefs.setString('selectedLicenseTypes', newValue!);
                                        widget.onLicenseTypesChange(_selectedLicenseTypes);
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
                              label: Text(type, style: TextStyle(color: Colors.black)),
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
                                field.didChange(List.from(_selectedLicenseTypes)); // Update field state
                                widget.onLicenseTypesChange(_selectedLicenseTypes);
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
                        if (field.hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              field.errorText!,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),

                SizedBox(height: screenHeight * .013,),
                CustomTextField(
                  titleText: 'Any points/endorsements on your licence?',
                  requiredStar: '*',
                  placeholder: 'Type licence points/endorsements.',
                  controller: widget.anyEndorsmentController,
                  errorMessage: anyEndorsmentValidationError,
                  validator: (value) {
                    // Check if the field is empty or invalid
                    if (_selectedOption2 == "Yes" &&
                        _selectedOption1 == "Yes" &&
                        widget.liNumberController.text.isNotEmpty &&
                        (value == null || value.isEmpty)) {
                      return 'Any points/endorsements on licence is required.';
                    }
                    return null; // Valid input
                  },
                ),
              ],
            ],

            SizedBox(height: screenHeight * .013),
            ConditionalDropdown(
              title: "Are you a valid CPC holder?",
              options: _dropdownOptions,
              selectedOption: _selectedOption4,
              onChanged: (newValue) async {
                setState(() {
                  _selectedOption4 = newValue!;
                  _formData['noCpcCard'] = newValue == 'Yes' ? 1 : 0;
                });
                final valueToPost = newValue == 'Yes' ? 1 : 0;
                if (newValue != null) {
                  print("Value to post: $valueToPost");
                }
                final prefs = await SharedPreferences.getInstance();
                prefs.setString('noCpcCard', newValue!);
                widget.onValidCPCChange(newValue);
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select an option.';
                }
                return null;
              },
            ),


            if(_selectedOption4=="Yes")...[
              SizedBox(height: screenHeight * .013),
              CustomTextField(
                titleText: 'CPC Number',
                requiredStar: '*',
                placeholder: 'Enter your cpc number',
                controller: widget.cpcNumController,
                errorMessage: cpcNumValidationError,
                validator: (value) {
                  // Check if the field is empty or invalid
                  if (_selectedOption4=="Yes" && (value == null || value.isEmpty)) {
                    return 'CPC Number  is requireds.';
                  } else if (_selectedOption4=="Yes" && (value!.length < 8)) {
                    return 'CPC Number is minimum 8 characters.';
                  }
                  return null; // Valid input
                },
              ),
            ],

            SizedBox(height: screenHeight * .013),
            ConditionalDropdown(
              title: "Are you a valid TACHO holder?",
              options: _dropdownOptions,
              selectedOption: _selectedOption5,
              onChanged: (newValue) async {
                setState(() {
                  _selectedOption5 = newValue!;
                  _formData['noTachoCard'] = newValue == 'Yes' ? 1 : 0;
                });
                final valueToPost = newValue == 'Yes' ? 1 : 0;
                if (newValue != null) {
                  print("Value to post: $valueToPost");
                }
                final prefs = await SharedPreferences.getInstance();
                prefs.setString('noTachoCard', newValue!);
                widget.onValidTachoChange(newValue);
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select an option.';
                }
                return null;
              },
            ),
            if(_selectedOption5=="Yes")...[SizedBox(height: screenHeight * .013),
              CustomTextField(
                titleText: 'Tacho Number',
                requiredStar: '*',
                placeholder: 'Enter your tacho number',
                controller: widget.techoNumberController,
                errorMessage: techoNumberValidationError,
                validator: (value) {
                  // Check if the field is empty or invalid
                  if (_selectedOption5=="Yes" && (value == null || value.isEmpty)) {
                    return 'Tacho Number  is requireds.';
                  } else if ( _selectedOption5=="Yes" && (value!.length < 16)) {
                    return 'Tacho Number is minimum 16 characters.';
                  }
                  return null; // Valid input
                },
              ),
            ],




            SizedBox(height: screenHeight * .013),
            CustomTextField(
                titleText: 'Driving license number.',
                // requiredStar: '*',
                placeholder: 'Enter your driving license number',
                controller: widget.dlNumberController,
                errorMessage: dlNumberValidationError,
                validator: (value) {
                  // Check if the field is empty or invalid
                  if (value == null || value.isEmpty) {
                    return 'Driving license number  is requireds.';
                  }
                  return null; // Valid input
                },
                ),

            SizedBox(height: screenHeight * .013),
            CustomTextField(
                titleText: 'Driving license category (HGV 1, HGV 2, etc.)',
                // requiredStar: '*',
                placeholder: 'Enter your driving license category ',
                controller: widget.dlCategoryController,
                errorMessage: dlCategoryValidationError,
                validator: (value) {
                  // Check if the field is empty or invalid
                  if (value == null || value.isEmpty) {
                    return 'Driving license category is requireds.';
                  }
                  return null; // Valid input
                },
                ),

            SizedBox(height: screenHeight * .1),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiryLicencesSection() {
    return Form(
      key: _formKeys[1],
      child: Column(
        children: [
          Text("${widget.selectedRole}"),
          _buildCustomContainer(
            titleText: 'Expiry Number',
            placeholder: 'Enter your license number',
            controller: widget.expiryController,
            errorMessage: expiryValidationError,
            onChanged: (value) {
              setState(() {
                if (value.isEmpty) {
                  expiryValidationError = 'First name is required and must be at least 3 characters long.';
                } else if (value.length < 3) {
                  expiryValidationError = 'First name must be at least 3 characters long.';
                } else {
                  expiryValidationError = null;
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection() {
    return Form(
      key: _formKeys[2],
      child: TextFormField(
        controller: documentsController,
        decoration: const InputDecoration(labelText: 'Documents'),
        // validator: (value) =>
        // value == null || value.isEmpty ? 'Please enter document details' : null,
      ),
    );
  }




  void continueButton() async {
    FocusScope.of(context).unfocus();
    _saveFormData();
    if (_formKeys[subCurrentStep].currentState != null) {
      if (_formKeys[subCurrentStep].currentState!.validate()) {
        _formKeys[subCurrentStep].currentState!.save();
        // _saveFormData();

        bool isSuccess = false;

        // Call _postBankData for the current step
        if (subCurrentStep == 0) {
          print("Step 0: Personal Information");
          await _postBankData(0);

          if (licenseTypesValidationError == null &&
              liValidationError == null &&
              anyEndorsmentValidationError == null &&
              cpcNumValidationError == null &&
              techoNumberValidationError == null &&
              dlNumberValidationError == null &&
              dlIssueValidationError == null &&
              dlCategoryValidationError == null &&
              dlCheckValidationError == null) {
            _goToPage(subCurrentStep + 1);
          }
        } else if (subCurrentStep == 1) {
          print("Sub Step 2");
          isSuccess = await _postBankData(1);
          if (expiryValidationError == null) {
            _goToPage(subCurrentStep + 1);
          }
        } else if (subCurrentStep == 2) {
          print("Step 2: Contact Information");
          await _postBankData(2);
        }
      }
      // else if (subCurrentStep == 0) {
      //   // Collect validation errors for each field
      //   print("Form validation failed for the following fields:");
      //   List<String> failedFields = [];
      //
      //   if (widget.liNumberController.text.isEmpty ||
      //       widget.liNumberController.text.length < 16 ) {
      //     print('liNumberController validation failed');
      //     failedFields.add('liNumberController');
      //   }
      //
      //   if (widget.anyEndorsmentController.text.isEmpty) {
      //     print('anyEndorsmentController validation failed');
      //     failedFields.add('anyEndorsmentController');
      //   }
      //   if (widget.cpcNumController.text.isEmpty) {
      //     print('cpcNumController validation failed');
      //     failedFields.add('cpcNumController');
      //   }
      //   if (widget.techoNumberController.text.isEmpty || widget.techoNumberController.text.length < 16) {
      //     print('techoNumberController validation failed');
      //     failedFields.add('techoNumberController');
      //   }
      //   if (widget.dlNumberController.text.isEmpty) {
      //     print('dlNumberController validation failed');
      //     failedFields.add('dlNumberController');
      //   }
      //   if (widget.dlIssueController.text.isEmpty) {
      //     print('dlIssueController validation failed');
      //     failedFields.add('dlIssueController');
      //   }
      //   if (widget.dlCategoryController.text.isEmpty) {
      //     print('dlCategoryController validation failed');
      //     failedFields.add('dlCategoryController');
      //   }
      //   if (widget.dlCheckController.text.isEmpty) {
      //     print('dlCheckController validation failed');
      //     failedFields.add('dlCheckController');
      //   }
      //
      //   // Scroll to the first validation error field
      //   if (failedFields.isNotEmpty) {
      //     String firstFailedField = failedFields.first;
      //     scrolledtoField(firstFailedField); // Scroll to the first field in the failed list
      //   }
      // }
    }
  }
  void scrolledtoField(String field) {
    switch (field) {
      case 'liNumberController':
        _scrollToField(0);
        break;
      case 'anyEndorsmentController':
        _scrollToField(1);
        break;
      case 'cpcNumController':
        _scrollToField(2);
        break;
      case 'techoNumberController':
        _scrollToField(3);
        break;
      case 'dlNumberController':
        _scrollToField(4);
        break;
      case 'dlIssueController':
        _scrollToField(5);
        break;
      case 'dlCategoryController':
        _scrollToField(6);
        break;
      case 'dlCheckController':
        _scrollToField(7);
        break;
      default:
        break;
    }
  }
  ScrollController _scrollController = ScrollController();
  void _scrollToField(int index) {
    _scrollController.animateTo(
      index * 100.0, // Adjust this multiplier based on your layout
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  void _goPreviousStep() {
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
  Widget ButtonContainer(String? label, Color color1, Color color2) {
    return Container(
      height: 40,
      width: 90,
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
  _buildCustomContainer({
    required String titleText,
    required String placeholder,
    required TextEditingController controller,
    String? errorMessage,
    required Function(String) onChanged,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$titleText ',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              '*',
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: screenWidth * 0.90,
          decoration: BoxDecoration(
            color: AppColors.navOpacity.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: AppColors.navButtonColor.withOpacity(0.4),
                    width: 0.5,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
              ),
              onChanged: onChanged,
            ),
          ),
        ),
        // Show error message only if there is an error
        if (errorMessage != null && errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 10.0, top: 4.0),
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
  Widget buildDateContainer({
    required String Textlabel,
    required String ?requiredStar,
    required String labelText,
    required TextEditingController controller,
    required String? Function(String?) validator,
    // required Function(String?) onDateChanged,
  }) {
    final screenWidth = MediaQuery.of(context).size.width * 1;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Container(
            width: screenWidth * 0.95,
            child: Row(
              children: [
                Text(Textlabel,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(requiredStar??"",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                )
              ],
            ),
          ),
        ),
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
}
