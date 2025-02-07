import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:c9_app/Modules/ClientModule/client_screen.dart';
import 'package:c9_app/Modules/ClientModule/model/ProfileModel/clientProfileApiModel.dart';
import 'package:c9_app/Modules/ClientModule/pages/Profile_&_Setting/client_Profile.dart';
import 'package:c9_app/Modules/ClientModule/pages/noInternetConnectionWidget.dart';
import 'package:c9_app/loadingScreen.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/view/widgets/header_widgets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as https;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../utils/utils.dart';




class UpdateProfileClient extends StatefulWidget { const UpdateProfileClient({super.key});

  @override
  State<UpdateProfileClient> createState() => _UpdateProfileClientState();
}

class _UpdateProfileClientState extends State<UpdateProfileClient>with WidgetsBindingObserver{
  late TimeOfDay startTime;
  late TimeOfDay endTime;

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
  bool _showNoInternetConnectionMessage = false;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;


  @override
  void initState() {
    super.initState();
    _userProfileFuture = fetchData();
    startTime = TimeOfDay.now();
    endTime = TimeOfDay.now();
    _startTimeValidationError = '';
    _endTimeValidationError = '';
    _refreshData();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result)async{
      bool hasInternet = await _hasInternetConnection();
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
  void dispose(){
    WidgetsBinding.instance.removeObserver(this); // Remove the observer
    _connectivitySubscription.cancel(); // Cancel subscription

    super.dispose();

    for (var controller in _billingNameControllers) {
      controller.dispose();
    }
    for (var controller in _billingEmailControllers) {
      controller.dispose();
    }
  }

  /// NEw Added By himu
  Future<void> _refreshData() async{

    await APICacheManager()
        .deleteCache('Client Profile');

    await fetchData();
    setState(() {});

    // setState(() {
    //   _userProfileFuture = fetchData();
    //   // print("Pull down");
    // });
  }

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
    }else {
      print('No image selected');
    }
  }
  bool isLoading=false;


  String? selectedValue;
  late Future<ClientProfileApiModel?> _userProfileFuture;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _companyNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _registrationController = TextEditingController();
  TextEditingController _address1Controller = TextEditingController();
  TextEditingController _address2Controller = TextEditingController();
  TextEditingController _townOrCityController = TextEditingController();
  TextEditingController _postCodeController = TextEditingController();
  TextEditingController _breakController = TextEditingController();
  TextEditingController _StartTimePickerController = TextEditingController();
  TextEditingController _EndTimePickerController = TextEditingController();

  List<TextEditingController> _billingContactIdControllers = [TextEditingController()];
  List<TextEditingController> _billingNameControllers = [TextEditingController()];
  List<TextEditingController> _billingEmailControllers = [TextEditingController()];

  void _addMoreFields() {
    if (_billingNameControllers.length < 5) {
      setState(() {
        _billingNameControllers.add(TextEditingController());
        _billingEmailControllers.add(TextEditingController());
      });
    }
  }

  // void _removeFields(int index) {
  //   setState(() {
  //     _billingNameControllers.removeAt(index);
  //     _billingEmailControllers.removeAt(index);
  //     _billingContactIdControllers.removeAt(index);
  //   });
  // }

  void _removeFields(int index) {
    setState(() {
      // Remove data from all lists based on the index
      if (index < _billingNameControllers.length) {
        _billingNameControllers.removeAt(index);
      }
      if (index < _billingEmailControllers.length) {
        _billingEmailControllers.removeAt(index);
      }
      if (index < _billingContactIdControllers.length) {
        _billingContactIdControllers.removeAt(index);
      }
    });
  }

  String _startTimeValidationError = '';
  String _endTimeValidationError = '';
  Map<int, String> _billingNameListError = {};
  Map<int, String> _billingEmailListError = {};
  Map<String, String> _validationErrors = {};


  Future<ClientProfileApiModel?> fetchData() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    bool hasInternet = await _hasInternetConnection();

    if (connectivityResult == ConnectivityResult.none || !hasInternet) {
      // No internet connection
      setState(() {
        _showNoInternetConnectionMessage = true;
      });
      return null;
    } else {
      await APICacheManager().deleteCache('Client Profile');

      var isCacheExist = await APICacheManager().isAPICacheKeyExist('Client Profile');

      if(!isCacheExist){
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String _token = prefs.getString('token') ?? '';

        final String apiUrl = '${AppUrl.baseUrl}/api/app/staff/profile';
        final response = await https.get(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $_token',
          },
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);


          // Cache the fetched data
          APICacheDBModel cacheDBModel = APICacheDBModel(key: 'Client Profile', syncData: response.body);
          await APICacheManager().addCacheData(cacheDBModel);

          final ClientProfileApiModel profileViewset = ClientProfileApiModel.fromJson(responseData);

          // Initialize billing controllers
          List<TextEditingController> newBillingNameControllers = [];
          List<TextEditingController> newBillingEmailControllers = [];
          List<TextEditingController> newBillingContactIdControllers = [];

          if (profileViewset.data?.xeroContacts != null) {
            for (var contact in profileViewset.data!.xeroContacts!) {
              newBillingNameControllers.add(TextEditingController(text: contact.name));
              newBillingEmailControllers.add(TextEditingController(text: contact.emailAddress));
              newBillingContactIdControllers.add(TextEditingController(text: contact.contactId));
            }
          }

          setState(() {
            _nameController.text = profileViewset.data?.name ?? '';
            _companyNameController.text = profileViewset.data?.companyName ?? '';
            _emailController.text = profileViewset.data?.email ?? '';
            _phoneController.text = profileViewset.data?.phone ?? '';

            _registrationController.text = profileViewset.data?.regNumber ?? '';
            _address1Controller.text = profileViewset.data?.addressLine1 ?? '';
            _address2Controller.text = profileViewset.data?.addressLine2 ?? '';

            _townOrCityController.text = profileViewset.data?.city ?? '';
            _postCodeController.text = profileViewset.data?.postCode ?? '';

            _StartTimePickerController.text = profileViewset.data?.dayStartTime ?? '00:00';
            _EndTimePickerController.text = profileViewset.data?.dayEndTime ?? '23:59';

            double breakTime = double.parse(profileViewset.data!.breakTime ?? '0') * 60;
            _breakController.text = breakTime.toStringAsFixed(2);

            // Update billing contact controllers
            _billingNameControllers = newBillingNameControllers;
            _billingEmailControllers = newBillingEmailControllers;
            _billingContactIdControllers = newBillingContactIdControllers;
          });
          print('Address Line 1: ${_address1Controller.text}');
          print('Address Line 2: ${_address2Controller.text}');

          return profileViewset;
        } else {
          throw Exception('Failed to fetch user data. Status code: ${response.statusCode}');
        }
      }else{
        // Fetch data from cache
        var cacheData = await APICacheManager().getCacheData('Client Profile');
        final Map<String, dynamic> cachedResponseData =
        json.decode(cacheData.syncData);

        if (cachedResponseData == null) {
          throw Exception('Cached response data is null');
        }

        final ClientProfileApiModel profileViewset = ClientProfileApiModel.fromJson(cachedResponseData);
        // Initialize billing controllers
        List<TextEditingController> newBillingNameControllers = [];
        List<TextEditingController> newBillingEmailControllers = [];
        List<TextEditingController> newBillingContactIdControllers = [];

        if (profileViewset.data?.xeroContacts != null) {
          for (var contact in profileViewset.data!.xeroContacts!) {
            newBillingNameControllers.add(TextEditingController(text: contact.name));
            newBillingEmailControllers.add(TextEditingController(text: contact.emailAddress));
            newBillingContactIdControllers.add(TextEditingController(text: contact.contactId));
          }
        }
        setState(() {
          _nameController.text = profileViewset.data?.name ?? '';
          _companyNameController.text = profileViewset.data?.companyName ?? '';
          _emailController.text = profileViewset.data?.email ?? '';
          _phoneController.text = profileViewset.data?.phone ?? '';

          _registrationController.text = profileViewset.data?.regNumber ?? '';
          _address1Controller.text = profileViewset.data?.addressLine1 ?? '';
          _address2Controller.text = profileViewset.data?.addressLine2 ?? '';

          _townOrCityController.text = profileViewset.data?.city ?? '';
          _postCodeController.text = profileViewset.data?.postCode ?? '';

          _StartTimePickerController.text = profileViewset.data?.dayStartTime ?? '00:00';
          _EndTimePickerController.text = profileViewset.data?.dayEndTime ?? '23:59';

          double breakTime = double.parse(profileViewset.data!.breakTime ?? '0') * 60;
          _breakController.text = breakTime.toStringAsFixed(2);

          // Update billing contact controllers
          _billingNameControllers = newBillingNameControllers;
          _billingEmailControllers = newBillingEmailControllers;
          _billingContactIdControllers = newBillingContactIdControllers;
        });

        return ClientProfileApiModel.fromJson(cachedResponseData);

      }
    }
  }



  void _updateProfile() async {
    setState(() {
      isLoading = true;
    });

    String _fullValidationError = '';
    String _companyValidationError = '';
    String _registrationValidationError = '';
    String _phoneValidationError = '';
    String _addressLine1ValidationError = '';
    String _addressLine2ValidationError = '';
    String _townOrCityValidationError = '';
    String _postCodeValidationError = '';
    String _breakValidationError = '';
    String _startTimeValidationError = '';
    String _endTimeValidationError = '';

    try {

      var connectivityResult = await (Connectivity().checkConnectivity());
      bool hasInternet = await _hasInternetConnection();

      if (connectivityResult == ConnectivityResult.none || !hasInternet) {
        // No internet connection
        setState(() {
          _showNoInternetConnectionMessage = true;
          isLoading = false; // Stop loading indicator
        });
        // Utils.flushBarErrorMessage('No internet connection', context);
        return; // Exit the function
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String _token = prefs.getString('token') ?? '';
      final String apiUrl = '${AppUrl.baseUrl}/api/app/profile/update';
      https.MultipartRequest request = https.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers.addAll({
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
      });
      request.fields['name'] = _nameController.text.toString();
      request.fields['company_name'] = _companyNameController.text.toString();
      request.fields['phone'] = _phoneController.text.toString();
      request.fields['reg_number'] = _registrationController.text.toString();
      request.fields['email'] = _emailController.text.toString();
      request.fields['addressLine1'] = _address1Controller.text.toString();
      request.fields['addressLine2'] = _address2Controller.text.toString();
      request.fields['townOrCity'] = _townOrCityController.text.toString();
      request.fields['postCode'] = _postCodeController.text.toString();
      request.fields['break_time'] = _breakController.text.toString();
      request.fields['day_start_time'] = _StartTimePickerController.text;
      request.fields['day_end_time'] = _EndTimePickerController.text;

      for (int i = 0; i < _billingNameControllers.length; i++) {
        request.fields['contact_name[$i]'] = _billingNameControllers[i].text;
        request.fields['contact_email[$i]'] = _billingEmailControllers[i].text;

        // Only add contact_id if it exists
        if (i < _billingContactIdControllers.length && _billingContactIdControllers[i].text.isNotEmpty) {
          request.fields['contact_id[$i]'] = _billingContactIdControllers[i].text;
        }

        // Debugging print statements
        print('Contact Name: ${_billingNameControllers[i].text}');
        print('Contact Email: ${_billingEmailControllers[i].text}');
        if (i < _billingContactIdControllers.length) {
          print('Contact ID: ${_billingContactIdControllers[i].text}');
        } else {
          print('Contact ID: New contact, no ID available');
        }
      }


      // Add image file
      if (_selectedImage != null) {
        request.files.add(https.MultipartFile.fromBytes(
          'image',
          _selectedImage!,
          filename: _selectedImageName!,
        ));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      // final responseData = jsonDecode(responseBody);
      final Map<String, dynamic> responseData = json.decode(responseBody);


      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');



      if (response.statusCode == 200) {
        print('Update Successful');
        print('Response body: $responseBody');
        print('Full response after update: $responseData');

        await APICacheManager().deleteCache('Client Profile');
        await _refreshData(); // This will fetch will update the UI

        setState(() {
          isLoading = false;
        });
        String successMessage = responseData['message'] ?? 'Successfully';
        Utils.flushBarSuccessMessage(successMessage, context);
        Future.delayed(Duration(seconds: 2), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClientProfile(),
            ),
          );
        });
      } else {
        // Handle validation error response
        if (responseData.containsKey('errors')) {
          final Map<String, dynamic> errors = responseData['errors'];
          errors.forEach((field, messages) {
            final String errorMessage = messages.isNotEmpty ? messages.first : 'Unknown error';
            switch (field) {
              case 'name':
                _fullValidationError = errorMessage;
                break;
              case 'company_name':
                _companyValidationError = errorMessage;
                break;
              case 'phone':
                _phoneValidationError = errorMessage;
                break;
              case 'reg_number':
                _registrationValidationError = errorMessage;
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
              case 'break_time':
                _breakValidationError = errorMessage;
                break;
              case 'day_start_time':
                _startTimeValidationError = errorMessage;
                break;
              case 'day_end_time':
                _endTimeValidationError = errorMessage;
                break;
            }
          });

          setState(() {
            _validationErrors = {
              'name': _fullValidationError,
              'company_name': _companyValidationError,
              'phone': _phoneValidationError,
              'reg_number': _registrationValidationError,
              'addressLine1': _addressLine1ValidationError,
              'addressLine2': _addressLine2ValidationError,
              'townOrCity': _townOrCityValidationError,
              'postCode': _postCodeValidationError,
              'break_time': _breakValidationError,
              'day_start_time': _startTimeValidationError,
              'day_end_time': _endTimeValidationError,
            };
            isLoading = false;
          });
          String errorMessage = responseData['message'] ?? 'Update failed';
          Utils.flushBarErrorMessage(errorMessage, context);
        } else {
          String errorMessage = responseData['message'] ?? 'Failed to update profile';
          Utils.flushBarErrorMessage(errorMessage, context);
          setState(() {
            isLoading = false;
          });
        }
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
          toolbarHeight: 70,
          title:  Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                  onTap: (){
                    // Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ClientProfile()));

                  },
                  child: HeaderRow(Icons.arrow_back)),
              Text("Update",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
              GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ClientCurveNabBar()));
                  },
                  child: HeaderRow(Icons.home)),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: _showNoInternetConnectionMessage ? NoInternetConnection(): ResPonsiveUi(
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
            child: FutureBuilder<ClientProfileApiModel?>(
              future: _userProfileFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: screenHeight *0.85,
                    width: screenWidth,
                    color: AppColors.whiteColor,
                    child: LoadingScreen(),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text(''));
                  // return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return Center(child: Text('No user data found.'));
                } else {
                  final ClientProfileApiModel userData = snapshot.data!;
                  final String? profilePick = userData.data?.image;



                  return Container(
                    width: screenWidth * 0.95,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            offset: Offset(0, 2),
                            blurRadius: 5,
                            spreadRadius: 2,
                          ),
                        ]),
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.013,),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                "Personal Information",
                                style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),)
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.013,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              height: screenHeight*0.18,
                              width: screenWidth * 0.3,
                              decoration: BoxDecoration(
                                color: profilePick != null && profilePick.isNotEmpty ? Colors.transparent : AppColors.navOpacity,
                                image: DecorationImage(
                                    image: NetworkImage('${AppUrl.clientUsers}/$profilePick'),
                                    fit: BoxFit.cover

                                ),
                                border: Border.all(
                                  color: AppColors.navOpacity,
                                ),
                              ),
                            ),
                            Column(

                              children: [

                                FirstContainer(controller: _nameController, labelText: "Full Name", keyboardType: TextInputType.name,   errorMessage: _validationErrors['name'],),
                                SizedBox(height: screenHeight * 0.013,),

                                FirstContainer(controller: _phoneController, labelText: "Phone number", keyboardType: TextInputType.name,   errorMessage: _validationErrors['phone'],),

                              ],
                            )
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.013,),
                        GestureDetector(
                          onTap: (){
                            _pickImage(ImageSource.gallery);
                          },
                          child: Container(
                              height: screenHeight*0.065,
                              width: screenWidth*0.91,
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
                                    height: screenHeight*0.065,
                                    width: screenWidth*0.30,
                                    decoration: BoxDecoration(
                                      color: AppColors.navOpacity,
                                      border: Border.all(
                                        color: AppColors.navOpacity,
                                        width: 0.4,
                                      ),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: Center(child: Text("Choose Image",style: TextStyle(fontSize: 15,color: AppColors.blackColor),)),
                                  ),
                                  Text(_selectedImageName != null ?  _selectedImageName!.split('.').first + '.' + _selectedImageName!.split('.').last
                                      : "No image selected...", style: TextStyle(fontSize: 15, color: AppColors.blackColor)),
                                  // Text("No file selected...",style: TextStyle(fontSize: 15,color: AppColors.blackColor),),
                                  SizedBox(),

                                ],
                              )
                          ),
                        ),


                        //For CLient Name

                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //   children: [
                        //     singleContainer(controller: _phoneController, labelText: "Phone number", keyboardType: TextInputType.name,errorMessage: _validationErrors['phone'],),
                        //     //   doubleContainer(controller: _genderController, labelText: "gender", keyboardType: TextInputType.name, prefixIcon: Icon(Icons.male)),
                        //   ],
                        // ),
                        SizedBox(height: screenHeight * 0.013,),
                        Container(
                          // height: screenHeight*0.065,
                          width: screenWidth * 0.91,
                          decoration: BoxDecoration(
                            // border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                              color: AppColors.navOpacity
                          ),
                          child:  Align(
                            alignment: Alignment.centerLeft,
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 16,vertical: 5),
                                labelText: "email",
                                // prefixIcon: Icon(Icons.mark_email_unread_outlined),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: AppColors.navButtonColor.withOpacity(0.4),),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                              ),
                              readOnly: true,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.013,),
                        singleContainer(controller: _address1Controller, labelText: "Address 1", keyboardType: TextInputType.streetAddress,  errorMessage: _validationErrors['addressLine1'],),
                        SizedBox(height: screenHeight * 0.013,),
                        singleContainer(controller: _address2Controller, labelText: "Address 2", keyboardType: TextInputType.streetAddress, errorMessage: _validationErrors['addressLine2'],),
                        SizedBox(height: screenHeight * 0.013,),
                        singleContainer(controller: _townOrCityController, labelText: "Town/City", keyboardType: TextInputType.streetAddress, errorMessage: _validationErrors['townOrCity'],),
                        SizedBox(height: screenHeight * 0.013,),
                        singleContainer(controller: _postCodeController, labelText: "Post Code", keyboardType: TextInputType.number, errorMessage: _validationErrors['postCode'],),
                        SizedBox(height: screenHeight * 0.013,),
                        singleContainer(controller: _breakController, labelText: "Break Deduction ", keyboardType: TextInputType.number, errorMessage: _validationErrors['break_time'],),
                        SizedBox(height: screenHeight*0.013,),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                "Business Information",
                                style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),)
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.013,),
                         singleContainer(controller: _companyNameController, labelText: "Business Name", keyboardType: TextInputType.name,    errorMessage: _validationErrors['company_name'],readOnly: true),
                        SizedBox(height: screenHeight * 0.013,),
                        singleContainer(controller: _registrationController, labelText: "Business Registration Number", keyboardType: TextInputType.name,errorMessage: _validationErrors['reg_number'], readOnly: true),
                        SizedBox(height: screenHeight * 0.013,),
                        Container(
                          width:screenWidth*0.91 ,
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
                                          textStyle: TextStyle(fontSize: 18),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      // height: screenHeight*0.065,
                                      width: screenWidth*0.40,
                                      decoration: BoxDecoration(
                                        color:AppColors.navOpacity.withOpacity(0.4),
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
                                            contentPadding: EdgeInsets.symmetric(horizontal: 16,vertical: 5),
                                            hintText: "--:--:--",
                                            hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6),fontSize: 18,letterSpacing: 5),
                                            prefixIcon: Icon(Icons.more_time_outlined,color: Colors.black,),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                          onTap: () async {
                                            TimeOfDay startTime = TimeOfDay(hour: 0, minute: 0); // Default to midnight if parsing fails
                                            if (_StartTimePickerController.text.isNotEmpty) {
                                              List<String> timeParts = _StartTimePickerController.text.split(":");
                                              int hour = int.parse(timeParts[0]);
                                              int minute = int.parse(timeParts[1]);
                                              startTime = TimeOfDay(hour: hour, minute: minute);
                                            }
                                            TimeOfDay? newTime = await showTimePicker(
                                              context: context,
                                              initialTime: startTime, // Use parsed time from controller
                                              initialEntryMode: TimePickerEntryMode.input,
                                              builder: (BuildContext context, Widget? child) {
                                                return Theme(
                                                  data: Theme.of(context).copyWith(
                                                    timePickerTheme: TimePickerThemeData(
                                                      backgroundColor: Colors.white,
                                                      dayPeriodTextColor: Colors.blue,
                                                      dayPeriodBorderSide: BorderSide(color: AppColors.navColor),
                                                      dialHandColor: AppColors.navColor,
                                                      dialBackgroundColor: Colors.white,
                                                    ),
                                                    colorScheme: const ColorScheme.light(
                                                      onPrimary: Colors.white,
                                                      onBackground: Colors.white,
                                                      onSurface: Colors.black,
                                                      primary: AppColors.navColor,
                                                      brightness: Brightness.light,
                                                      surface: Colors.white,
                                                      secondary: AppColors.navColor,
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

                                            if (newTime != null) {
                                              _selectStartTime(newTime);
                                              String formattedHour = newTime.hour.toString().padLeft(2, '0');
                                              String formattedMinute = newTime.minute.toString().padLeft(2, '0');
                                              String formattedTime = "$formattedHour:$formattedMinute";
                                              setState(() {
                                                _StartTimePickerController.text = formattedTime;
                                              });
                                            }
                                          },

                                        ),
                                      ),
                                    ),
                                    if (
                                    _startTimeValidationError != null &&
                                        _startTimeValidationError.isNotEmpty) // Render error message only if not empty
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10.0),
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            _startTimeValidationError,
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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10.0),
                                      child: AutoSizeText(
                                        'Day End Time',
                                        maxLines: 1,
                                        style: GoogleFonts.roboto(
                                          textStyle: TextStyle(fontSize: 18),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      // height: screenHeight*0.065,
                                      width: screenWidth*0.40,
                                      decoration: BoxDecoration(
                                        color:AppColors.navOpacity.withOpacity(0.4),
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
                                            contentPadding: EdgeInsets.symmetric(horizontal: 16,vertical: 5),
                                            hintText: "--:--:--",
                                            hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6),fontSize: 18,letterSpacing: 5),
                                            prefixIcon: Icon(Icons.more_time_outlined,color: Colors.black,),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                          onTap: () async {
                                            TimeOfDay endTime = TimeOfDay(hour: 23, minute: 59);
                                            if (_EndTimePickerController.text.isNotEmpty) {
                                              List<String> timeParts = _EndTimePickerController.text.split(":");
                                              int hour = int.parse(timeParts[0]);
                                              int minute = int.parse(timeParts[1]);
                                              endTime = TimeOfDay(hour: hour, minute: minute);
                                            }
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
                                              String formattedTime = "$formattedHour:$formattedMinute";
                                              setState(() {
                                                _EndTimePickerController.text = formattedTime;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                    if (_endTimeValidationError != null && _endTimeValidationError.isNotEmpty) // Render error message only if not empty
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10.0),
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            _endTimeValidationError,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
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
                                ]),
                            child: Center(
                              child:isLoading
                                  ? SizedBox(
                                  height:20,
                                  width:20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  )) // Show loading indicator if _isLoading is true
                                  : AutoSizeText(
                                "Update",
                                style: TextStyle(color: Colors.white, fontSize: 18),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: screenHeight * .02,
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
          SizedBox(height: screenHeight * 0.02,),
        ],
      ),
    );
  }

  Widget singleContainer({
    required TextEditingController controller,
    required String labelText,
    required TextInputType keyboardType,
    // required Icon prefixIcon,
    String? errorMessage,
    bool? readOnly, // Optional parameter for read-only mode

  }) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          // height: screenHeight*0.07,
          width: screenWidth * 0.91,
          decoration: BoxDecoration(
            // border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child:  Align(
            alignment: Alignment.centerLeft,
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              readOnly: readOnly ?? false, // Set to true if readOnly is passed, otherwise false
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16,vertical: 5),
                labelText: labelText,
                // prefixIcon: prefixIcon,
                fillColor: (readOnly ?? false) ? AppColors.navOpacity : Colors.white, // Gray background if read-only
                filled: true, // Enable filling of the background color
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.navButtonColor.withOpacity(0.4),),
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


  Widget doubleContainer({
    required TextEditingController controller,
    required String labelText,
    required TextInputType keyboardType,
    required Icon prefixIcon,
  }) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return Container(
      // height: screenHeight*0.065,
      width: screenWidth * 0.45,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          // focusNode: controller,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
            labelText: labelText,
            prefixIcon: prefixIcon,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
  Widget FirstContainer({
    required TextEditingController controller,
    required String labelText,
    required TextInputType keyboardType,
    String? errorMessage,
  }) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          // height: screenHeight*0.065,
          width: screenWidth * 0.6,
          decoration: BoxDecoration(
            // border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child:  Align(
            alignment: Alignment.centerLeft,
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              // focusNode: controller,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16,vertical: 5),
                labelText: labelText,
                // prefixIcon: prefixIcon,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.navButtonColor.withOpacity(0.4),),
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
  }) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;

    return Container(
      height: screenHeight*0.065,
      width: screenWidth * 0.91,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5),
      ),
      child:  Align(
        alignment: Alignment.centerLeft,
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
            labelText: labelText,
            suffixIcon: IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );

                if (pickedDate != null) {
                  String formattedDate = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day}";
                  controller.text = formattedDate;
                }
              },
            ),
          ),
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );

            if (pickedDate != null) {
              String formattedDate = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day}";
              controller.text = formattedDate;
            }
          },
        ),
      ),
    );
  }

  Widget ExpiryCalenderContainer({
    required TextEditingController controller,
    required String labelText,
    required TextInputType keyboardType,
  }) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;

    return Container(
      height: screenHeight*0.05,
      width: screenWidth * 0.91,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
          labelText: labelText,
          suffixIcon: IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () async {
              DateTime currentDate = DateTime.now();
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: currentDate,
                firstDate: currentDate,
                lastDate: DateTime(2101),
              );

              if (pickedDate != null) {
                String formattedDate =
                    "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                controller.text = formattedDate;
              }
            },
          ),
        ),
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

}