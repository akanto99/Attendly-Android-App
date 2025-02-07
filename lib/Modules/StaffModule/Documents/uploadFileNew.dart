import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:c9_app/Modules/ClientModule/pages/noInternetConnectionWidget.dart';
import 'package:c9_app/Modules/StaffModule/DashBoard/staff_navigationScreen.dart';
import 'package:c9_app/Modules/StaffModule/Documents/documentFolder.dart';
import 'package:c9_app/Modules/StaffModule/Documents/imageFolder.dart';
import 'package:c9_app/Modules/StaffModule/MODEL/assignmentModel/assignmentClientModelClass.dart';
import 'package:c9_app/loadingScreen.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/view/widgets/file_picker_widgets.dart';
import 'package:c9_app/view/widgets/header_widgets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as https;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/utils.dart';

class UploadFileStaffNew extends StatefulWidget {
  const UploadFileStaffNew({super.key});

  @override
  State<UploadFileStaffNew> createState() => _UploadFileStaffNewState();
}

class _UploadFileStaffNewState extends State<UploadFileStaffNew>
    with WidgetsBindingObserver {
  bool _isuploading = false;

  final ImagePicker _imagePicker = ImagePicker();

  Uint8List? _selectedDrivingFile;
  String? _selectedDrivingName;

  Uint8List? _selectedPassportFile;
  String? _selectedPassportName;

  Uint8List? _selectedCPCFile;
  String? _selectedCPCName;

  Uint8List? _selectedTachoFile;
  String? _selectedTachoName;

  Uint8List? _selectedProofFile;
  String? _selectedProofName;

  bool _showNoInternetConnectionMessage = false;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  Map<String, String> _validationErrors = {};
  void _updateProfile() async {
    setState(() {
      _isuploading = true;
    });
    String _passportValidationError = '';
    String _upCPCValidationError = '';
    String _upTachoValidationError = '';
    String _drivingLicenceValidationError = '';
    String _proofOfAddressValidationError = '';

    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      bool hasInternet = await _hasInternetConnection();

      if (connectivityResult == ConnectivityResult.none || !hasInternet) {
        // No internet connection
        setState(() {
          _showNoInternetConnectionMessage = true;
          _isuploading = false; // Stop loading indicator
        });
        return; // Exit the function
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String _token = prefs.getString('token') ?? '';
      final String apiUrl =
          '${AppUrl.baseUrl}/api/app/staff/profile/doc/update';
      var request = https.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers.addAll({
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
      });

      if (_selectedDrivingFile != null) {
        request.files.add(await https.MultipartFile.fromBytes(
          'drivingLicence',
          _selectedDrivingFile!,
          filename: _selectedDrivingName!,
        ));
        print('Success 1');
      }

      if (_selectedPassportFile != null) {
        request.files.add(await https.MultipartFile.fromBytes(
          'passport',
          _selectedPassportFile!,
          filename: _selectedPassportName!,
        ));
        print('Success 2');
      }

      if (_selectedCPCFile != null) {
        request.files.add(await https.MultipartFile.fromBytes(
          'cpc',
          _selectedCPCFile!,
          filename: _selectedCPCName!,
        ));
        print('Success 3');
      }

      if (_selectedTachoFile != null) {
        request.files.add(await https.MultipartFile.fromBytes(
          'tacho',
          _selectedTachoFile!,
          filename: _selectedTachoName!,
        ));
        print('Success 4');
      }

      if (_selectedProofFile != null) {
        request.files.add(await https.MultipartFile.fromBytes(
          'proofOfAddress',
          _selectedProofFile!,
          filename: _selectedProofName!,
        ));
        print('Success 5');
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final responseData = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        print('Update Successful');
        print('Response body: $responseBody');
        setState(() {
          _isuploading = false;
        });

        String successMessage =
            responseData['message'] ?? 'Uploaded Successfully';
        Utils.flushBarSuccessMessage(successMessage, context);
        Future.delayed(Duration(seconds: 2), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StaffCurveNabBar(),
            ),
          );
        });
      } else if (response.statusCode == 422) {
        // Handle validation error response
        final Map<String, dynamic> responseData = jsonDecode(responseBody);
        if (responseData.containsKey('errors')) {
          final Map<String, dynamic> errors = responseData['errors'];
          errors.forEach((field, messages) {
            final String errorMessage =
                messages.isNotEmpty ? messages.first : 'Unknown error';
            switch (field) {
              case 'drivingLicence':
                _drivingLicenceValidationError = errorMessage;
                break;
              case 'proofOfAddress':
                _proofOfAddressValidationError = errorMessage;
                break;
              case 'passport':
                _passportValidationError = errorMessage;
                break;
              case 'cpc':
                _upCPCValidationError = errorMessage;
                break;
              case 'tacho':
                _upTachoValidationError = errorMessage;
                break;
            }
          });

          setState(() {
            _validationErrors = {
              'drivingLicence': _drivingLicenceValidationError,
              'passport': _passportValidationError,
              'cpc': _upCPCValidationError,
              'tacho': _upTachoValidationError,
              'proofOfAddress': _proofOfAddressValidationError,
            };
            _isuploading = false;
          });
          String errorMessage = responseData['message'] ?? 'failed';
          Utils.flushBarErrorMessage(errorMessage, context);
        }
      } else {
        String errorMessage = responseData['message'] ?? 'failed';
        Utils.flushBarErrorMessage(errorMessage, context);
        setState(() {
          _isuploading = false;
        });
      }
    } catch (e) {
      print('Error during data submission: $e');
      if (_isuploading) {
        setState(() {
          _isuploading = false;
        });
        Utils.flushBarErrorMessage(
            'An error occurred during File update', context);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestPermissions();
    fetchStaffRoles();
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      bool hasInternet = await _hasInternetConnection();
      setState(() {
        _showNoInternetConnectionMessage =
            (result == ConnectivityResult.none || !hasInternet);
      });
    });
  }
  String _roleTypes = "";
  Future<void> fetchStaffRoles() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String _token = prefs.getString('token') ?? '';
      final String apiUrl = '${AppUrl.baseUrl}/api/app/active/staff/index';
      final response = await https.get(Uri.parse(apiUrl), headers: {
        'Authorization': 'Bearer $_token',
      });
      if (response.statusCode == 200) {
        AssignMentClientModel staffRoles = AssignMentClientModel.fromJson(json.decode(response.body));

        setState(() {
          _roleTypes = staffRoles.roleType;
          print("Fetched roles: ${_roleTypes.length}");
        });
      } else {
        throw Exception('Failed to load worker roles');
      }
    } catch (e) {
      print("Error fetching roles: $e");
    }
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
    _connectivitySubscription.cancel();
    super.dispose();
  }

  List<String?> multiFileSelectionList = [];

  Future<void> postData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';

    try {
      if (multiFileSelectionList.isEmpty) {
        Utils.flushBarErrorMessage('File is empty', context);
        return;
      }

      String apiUrl = '${AppUrl.baseUrl}/api/app/staff/file/update';
      var request = https.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers.addAll({
        'Authorization': 'Bearer $_token',
      });

      for (int i = 0; i < multiFileSelectionList.length; i++) {
        if (multiFileSelectionList[i] != null) {
          String fileName = getFileNameFromPath(multiFileSelectionList[i]!);

          request.files.add(await https.MultipartFile.fromPath(
            'new_file_names[$i]',
            multiFileSelectionList[i]!,
            filename: fileName,
          ));
        }
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        print('Data submitted successfully');
        // Utils.flushBarSuccessMessage('Data Upload Successfully', context);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => UploadFileStaffNew()));
        setState(() {
          multiFileSelectionList.clear();
        });
        print(await response.stream.bytesToString());
      } else {
        print('Failed to submit data. Status code: ${response.statusCode}');
        print(response.reasonPhrase);
        print(multiFileSelectionList);
      }
    } catch (e) {
      print('Error during data submission: $e');
    }
  }

  Future<void> _requestPermissions() async {
    PermissionStatus status = await Permission.storage.request();
    if (!status.isGranted) {
      throw Exception('Permission denied for storage');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor:
          _showNoInternetConnectionMessage ? Colors.red : AppColors.navColor,
    ));
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _showNoInternetConnectionMessage
            ? NoInternetConnection()
            : ResPonsiveUi(
                mobile: body(),
                desktop: body(),
                tablet: body(),
              ),
      ),
    );
  }

  Widget body() {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;

    if (_roleTypes == "") {
      return Container(
        height: screenHeight * 0.9,
        width: screenWidth,
        color: AppColors.whiteColor,
        child: LoadingScreen(),
      );
    } else {
      return Container(
      height: screenHeight,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Text("Role Type-$_roleTypes"),
            SizedBox(
              height: screenHeight * 0.013,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => StaffCurveNabBar()));
                      },
                      child: HeaderRow(Icons.arrow_back)),
                  Text(
                    "Files",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => StaffCurveNabBar()));
                      },
                      child: HeaderRow(Icons.home)),
                ],
              ),
            ),
            SizedBox(
              height: screenHeight * 0.013,
            ),
            Column(
              children: [
                Container(
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
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            "Documents",
                            style: GoogleFonts.roboto(
                              textStyle: TextStyle(fontSize: 18),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ImageViewFolder()));
                                },
                                child: Container(
                                  height: screenHeight * 0.07,
                                  width: screenWidth * 0.40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 2,
                                        blurRadius: 3,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                      child: Text(
                                    "Images",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                  )),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              DocViewFolder()));
                                },
                                child: Container(
                                  height: screenHeight * 0.07,
                                  width: screenWidth * 0.40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 2,
                                        blurRadius: 3,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                      child: Text(
                                    "Doc files",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                  )),
                                ),
                              ),
                            ],
                          ),
                        )
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
                  child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Column(children: [
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Update Documents",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            )),
                        SizedBox(
                          height: screenHeight * .013,
                        ),
                        if (_roleTypes.toLowerCase().contains("driver"))...[
                          FilePickerWidget(
                            title: "Driving Licence",
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                            onFilePicked:
                                (Uint8List? fileData, String? fileName) {
                              setState(() {
                                _selectedDrivingFile = fileData;
                                _selectedDrivingName = fileName;
                              });
                            },
                            selectedFileName: _selectedDrivingName,
                            errorMessage: _validationErrors['drivingLicence'],
                          ),
                          SizedBox(
                            height: screenHeight * .013,
                          ),
                        ],

                        FilePickerWidget(
                            title: "Passport",
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                            onFilePicked:
                                (Uint8List? fileData, String? fileName) {
                              setState(() {
                                _selectedPassportFile = fileData;
                                _selectedPassportName = fileName;
                              });
                            },
                            selectedFileName: _selectedPassportName,
                            errorMessage: _validationErrors['passport']),
                        SizedBox(
                          height: screenHeight * .013,
                        ),
    if (_roleTypes.toLowerCase().contains("driver"))...[
      FilePickerWidget(
                            title: "CPC",
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                            onFilePicked:
                                (Uint8List? fileData, String? fileName) {
                              setState(() {
                                _selectedCPCFile = fileData;
                                _selectedCPCName = fileName;
                              });
                            },
                            selectedFileName: _selectedCPCName,
                            errorMessage: _validationErrors['cpc']),
                        SizedBox(
                          height: screenHeight * .013,
                        ),],

                        if (_roleTypes.toLowerCase().contains("driver"))...[ FilePickerWidget(

                            title: "Tacho ",
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                            onFilePicked:
                                (Uint8List? fileData, String? fileName) {
                              setState(() {
                                _selectedTachoFile = fileData;
                                _selectedTachoName = fileName;
                              });
                            },
                            selectedFileName: _selectedTachoName,
                            errorMessage: _validationErrors['tacho']),
                        SizedBox(
                          height: screenHeight * .013,
                        ),],
                        FilePickerWidget(
                          title: "Proof of Address",
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                          onFilePicked:
                              (Uint8List? fileData, String? fileName) {
                            setState(() {
                              _selectedProofFile = fileData;
                              _selectedProofName = fileName;
                            });
                          },
                          selectedFileName: _selectedProofName,
                          errorMessage: _validationErrors['proofOfAddress'],
                        ),
                        SizedBox(
                          height: screenHeight * .013,
                        ),
                      ])),
                ),
                SizedBox(
                  height: screenHeight * .013,
                ),
                InkWell(
                  onTap: () async {
                    _updateProfile();
                  },
                  child: Container(
                    height: screenHeight * 0.055,
                    width: screenWidth * 0.3,
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
                      child: _isuploading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              )) // Show loading indicator if _isLoading is true
                          : Text(
                              "Update",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.1,
                ),
              ],
            ),
          ],
        ),
      ),
    );}
  }

  Widget buildFilePickerRow(int index) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () async {
              String? pickedFile =
                  await FilePicker.platform.pickFiles().then((result) {
                if (result != null) {
                  return result.files.single.path;
                } else {
                  return null;
                }
              });

              if (pickedFile != null) {
                setState(() {
                  multiFileSelectionList[index] = pickedFile;
                });
              }
            },
            child: Container(
              height: screenHeight * 0.04,
              width: screenWidth * 0.35,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(width: 0.4, color: AppColors.navColor),
              ),
              child: Center(
                  child: Text(
                "click here",
                style: TextStyle(color: Colors.blue, fontSize: 16),
              )),
            ),
          ),
          if (multiFileSelectionList[index] != null)
            Text(
              shortenFileName(
                  getFileNameFromPath(multiFileSelectionList[index]!)),
            )
          else
            Text(
              "No file selected",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          IconButton(
            onPressed: () {
              setState(() {
                multiFileSelectionList.removeAt(index);
              });
            },
            icon: Icon(
              Icons.cancel,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  String shortenFileName(String filePath) {
    if (filePath.length <= 15) {
      return filePath;
    } else {
      String fileName = filePath.substring(filePath.lastIndexOf('/') + 1);
      String extension = fileName.split('.').last;
      String nameWithoutExtension =
          fileName.substring(0, fileName.lastIndexOf('.'));
      int maxLength = 15;
      if (nameWithoutExtension.length <= maxLength) {
        return '${nameWithoutExtension}...$extension';
      } else {
        return '${nameWithoutExtension.substring(0, maxLength)}...$extension';
      }
    }
  }

  void addFilePickerRow() {
    setState(() {
      multiFileSelectionList.add(null);
    });
  }

  String getFileNameFromPath(String path) {
    List<String> pathSegments = path.split('/');
    return pathSegments.last;
  }
}
