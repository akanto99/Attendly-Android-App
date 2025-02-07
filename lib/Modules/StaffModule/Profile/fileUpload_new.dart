import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:c9_app/Modules/StaffModule/DashBoard/staff_navigationScreen.dart';
import 'package:c9_app/Modules/StaffModule/MODEL/assignmentModel/assignmentClientModelClass.dart';
import 'package:c9_app/Modules/StaffModule/MODEL/profilemodelStaff/staffList_File.dart';
import 'package:c9_app/Modules/StaffModule/Profile/staff_profilev2.dart';
import 'package:c9_app/loadingScreen.dart';
import 'package:c9_app/provider/PermisionProvider.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/view/widgets/file_picker_widgets.dart';
import 'package:c9_app/view/widgets/header_widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as https;
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/utils.dart';

class FileUploadStaff extends StatefulWidget {
  const FileUploadStaff({super.key});

  @override
  State<FileUploadStaff> createState() => _FileUploadStaffState();
}

class _FileUploadStaffState extends State<FileUploadStaff> {
  late Future<StaffFileListView> _userFilelistFuture;
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

  Map<String, String> _validationErrors = {};


  void _updateProfile() async {
    setState(() {
      _isuploading = true;
    });
    String  _passportValidationError = '';
    String  _upCPCValidationError = '';
    String  _upTachoValidationError = '';
    String  _drivingLicenceValidationError = '';
    String  _proofOfAddressValidationError = '';

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String _token = prefs.getString('token') ?? '';
      final String apiUrl = '${AppUrl.baseUrl}/api/app/staff/profile/doc/update';
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

        String successMessage = responseData['message'] ?? 'Uploaded Successfully';
        Utils.flushBarSuccessMessage(successMessage, context);

        Future.delayed(Duration(seconds: 2), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StaffProfile(),
            ),
          );
        });
      } else if (response.statusCode == 422) {
        // Handle validation error response
        final Map<String, dynamic> responseData = jsonDecode(responseBody);
        if (responseData.containsKey('errors')) {
          final Map<String, dynamic> errors = responseData['errors'];
          errors.forEach((field, messages) {
            final String errorMessage = messages.isNotEmpty ? messages.first : 'Unknown error';
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
        Utils.flushBarErrorMessage('An error occurred during File update', context);
      }
    }
  }
  @override
  void initState() {
    super.initState();
    fetchStaffRoles();
    _userFilelistFuture = fetchFile();
    _requestPermissions();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _userFilelistFuture = fetchFile();
    });
  }
  Future<StaffFileListView> fetchFile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';

    final String apiUrl = '${AppUrl.baseUrl}/api/app/staff/file';
    final response = await https.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $_token',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData == null) {
        throw Exception('Response data is null');
      }

      return StaffFileListView.fromJson(responseData);
    } else {
      throw Exception(
          'Failed to fetch user data. Status code: ${response.statusCode}');
    }
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


  Future<void> deleteFile(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';

    final String apiUrl = '${AppUrl.baseUrl}/api/app/staff/file/delete/$id';
    final response = await https.get(Uri.parse(apiUrl), headers: {
      'Authorization': 'Bearer $_token',
    });
    if (response.statusCode == 200) {
      setState(() {
        _userFilelistFuture = fetchFile();
      });
      print('staff $id');
    } else {
      throw Exception('Failed to load client list');
    }
  }

  final Dio _dio = Dio();

  Future<void> downloadFile(String fileUrl, String fileName) async {
    await _requestPermissions();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';

    try {
      final Directory? saveDir = await getExternalStorageDirectory();
      final String savePath = '${saveDir?.path}/$fileName';

      print('Downloading file from: $fileUrl');
      print('Saving file to: $savePath');

      final Response response = await _dio.download(
        fileUrl,
        savePath,
        options: Options(headers: {
          'Authorization': 'Bearer $_token',
        }),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            print((received / total * 100).toStringAsFixed(0) + "%");
          }
        },
      );

      if (response.statusCode == 200) {
        print('Downloaded successfully');
        Utils.flushBarSuccessMessage('File Downloaded Successfully', context);
        _openFile(savePath);
      } else {
        print('Failed to download file. Status code: ${response.statusCode}');
        Utils.flushBarErrorMessage('Failed to download file', context);
      }
    } catch (error) {
      print('Error downloading file: $error');
      if (error is DioException && error.response?.statusCode == 404) {
        Utils.flushBarErrorMessage('File not found', context);
      } else {
        Utils.flushBarErrorMessage('Error downloading file', context);
      }
    }
  }


  Future<void> _requestPermissions() async {
    final permissionProvider = Provider.of<PermissionProvider>(context, listen: false);
    await permissionProvider.requestFileAndMediaPermission();
  }

  void _openFile(String filePath) {
    OpenFile.open(filePath);
  }

  String getFileImage(String fileName) {
    if (fileName.toLowerCase().contains('pdf') ||
        fileName.toLowerCase().contains('doc') ||
        fileName.toLowerCase().contains('docs') ||
        fileName.toLowerCase().contains('docm') ||
        fileName.toLowerCase().contains('word')) {
      return "images/staff/pdf.png"; // PDF/Word/Docs Icon
    } else if (fileName.toLowerCase().contains('png') ||
        fileName.toLowerCase().contains('jpg') ||
        fileName.toLowerCase().contains('jpeg') ||
        fileName.toLowerCase().contains('gif') ||
        fileName.toLowerCase().contains('tiff')) {
      return "images/staff/png.png"; // PNG/JPG/GIF/TIFF Image
    } else {
      return "images/staff/file.png"; // Default file icon for other types
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          surfaceTintColor: Colors.white,
          toolbarHeight: 70,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>StaffProfile()));
                  },
                  child: HeaderRow(Icons.arrow_back)),
              Text("Files",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
              GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>StaffCurveNabBar()));
                  },
                  child: HeaderRow(Icons.home)),
            ],
          ),),
        body:  RefreshIndicator(
          onRefresh: _refreshData,
          child: ResPonsiveUi(
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
    if (_roleTypes == "") {
      return Container(
        height: screenHeight * 0.9,
        width: screenWidth,
        color: AppColors.whiteColor,
        child: LoadingScreen(),
      );
    } else {
      return SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Center(
              child: FutureBuilder<StaffFileListView>(
                future: _userFilelistFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      height: screenHeight *0.75,
                      width: screenWidth,
                      color: AppColors.whiteColor,
                      child: LoadingScreen(),
                    );
                  } else if (snapshot.hasError) {
                    return Text("");
                    // return Text("${snapshot.error}");
                  } else {
                    final FilesList = snapshot.data?.data;

                    if (FilesList != null && FilesList.isNotEmpty) {
                      return Container(
                        width: screenWidth * 0.95,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5),
                          ),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10,bottom: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10.0,bottom: 20),
                                    child: Text(
                                      "Documents",style: GoogleFonts.roboto(
                                      textStyle: TextStyle(fontSize: 18),
                                      fontWeight: FontWeight.bold,
                                    ),),
                                  ),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      // Expanded(
                                      //   child: ListView.builder(
                                      //     shrinkWrap: true,
                                      //     physics: NeverScrollableScrollPhysics(),
                                      //     itemCount: FilesList.length,
                                      //     itemBuilder: (context, index) {
                                      //       final fileNames = FilesList[index].fileName??'';
                                      //       final downloadUrl = FilesList[index].downloadUrl??'';
                                      //       final ids = FilesList[index].id??'';
                                      //       return Card(
                                      //         color: Colors.white,
                                      //         elevation: 0.3,
                                      //         child: Padding(
                                      //           padding: const EdgeInsets.only (left: 10.0,right: 10,top: 10,bottom: 10),
                                      //           child: Row(
                                      //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      //             children: [
                                      //               Text(
                                      //                 fileNames != null && fileNames.length > 20
                                      //                     ? fileNames.substring(0, 20) + "..." + fileNames.substring(fileNames.lastIndexOf('.') + 1)
                                      //                     : fileNames ?? "",
                                      //               ),
                                      //               Row(
                                      //                 children: [
                                      //                   InkWell(
                                      //                     onTap:(){
                                      //                       Utils.toastMessage("Clicked. Please wait");
                                      //                       if (downloadUrl != null && fileNames != null) {
                                      //                         downloadFile(downloadUrl, fileNames);
                                      //                       } else {
                                      //                         Utils.flushBarErrorMessage('Download URL or file name is missing', context);
                                      //                       }
                                      //                     },
                                      //                     child: Icon(Icons.download_rounded,color: Colors.blue,),
                                      //                   ),
                                      //
                                      //                 ],
                                      //               )
                                      //             ],
                                      //           ),
                                      //         ),
                                      //       );
                                      //     },
                                      //   ),
                                      // ),
                                      Expanded(
                                        child: GridView.builder(
                                          shrinkWrap: true,
                                          physics: NeverScrollableScrollPhysics(),
                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount:screenWidth < 600 ? 4 : 5,
                                            crossAxisSpacing: 10,
                                            mainAxisSpacing: 10,
                                            childAspectRatio: 0.7,
                                          ),
                                          itemCount: FilesList.length,
                                          itemBuilder: (context, index) {
                                            final fileNames = FilesList[index].fileName ?? '';
                                            final downloadUrl = FilesList[index].downloadUrl ?? '';
                                            final ids = FilesList[index].id ?? '';

                                            return InkWell(
                                              onTap: () {
                                                Utils.toastMessage("Clicked. Please wait");
                                                if (downloadUrl.isNotEmpty && fileNames.isNotEmpty) {
                                                  downloadFile(downloadUrl, fileNames);
                                                } else {
                                                  Utils.flushBarErrorMessage('Download URL or file name is missing', context);
                                                }
                                              },
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Container(
                                                    // height: screenHeight * 0.08,
                                                    width: screenWidth * 0.15,
                                                    color: Colors.white,
                                                    child: Image.asset(getFileImage(fileNames), fit: BoxFit.contain),
                                                  ),
                                                  // SizedBox(height: 5),
                                                  Container(
                                                    width: screenWidth * 0.2,
                                                    child: Text(
                                                      fileNames ?? "",
                                                      maxLines: 3,
                                                      overflow: TextOverflow.ellipsis,
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(fontSize: 12),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),

                                    ],
                                  ),
                                ],
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
                                  child: Column(
                                      children: [
                                        Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "Update Documents",
                                              style: TextStyle(
                                                  fontSize: 18, fontWeight: FontWeight.w500),
                                            )),

                                  if (_roleTypes.toLowerCase().contains("driver"))...[
                                        SizedBox(height: screenHeight * .013,),
                                        FilePickerWidget(
                                          title: "Driving Licence",
                                          screenWidth: screenWidth,
                                          screenHeight: screenHeight,
                                          onFilePicked: (Uint8List? fileData, String? fileName) {
                                            setState(() {
                                              _selectedDrivingFile = fileData;
                                              _selectedDrivingName = fileName;
                                            });
                                          },
                                          selectedFileName: _selectedDrivingName,
                                          errorMessage: _validationErrors['drivingLicence'],
                                        ),],

                                        SizedBox(height: screenHeight * .013,),
                                        FilePickerWidget(
                                            title: "Passport",
                                            screenWidth: screenWidth,
                                            screenHeight: screenHeight,
                                            onFilePicked: (Uint8List? fileData, String? fileName) {
                                              setState(() {
                                                _selectedPassportFile = fileData;
                                                _selectedPassportName = fileName;
                                              });
                                            },
                                            selectedFileName: _selectedPassportName,
                                            errorMessage:   _validationErrors['passport']
                                        ),

                  if (_roleTypes.toLowerCase().contains("driver"))...[
                                        SizedBox(height: screenHeight * .013,),
                                        FilePickerWidget(
                                            title: "CPC",
                                            screenWidth: screenWidth,
                                            screenHeight: screenHeight,
                                            onFilePicked: (Uint8List? fileData, String? fileName) {
                                              setState(() {
                                                _selectedCPCFile = fileData;
                                                _selectedCPCName = fileName;
                                              });
                                            },
                                            selectedFileName: _selectedCPCName,
                                            errorMessage:   _validationErrors['cpc']
                                        ),
                                         ],


                  if (_roleTypes.toLowerCase().contains("driver"))...[
                                        SizedBox(height: screenHeight * .013,),
                                        FilePickerWidget(
                                            title: "Tacho ",
                                            screenWidth: screenWidth,
                                            screenHeight: screenHeight,
                                            onFilePicked: (Uint8List? fileData, String? fileName) {
                                              setState(() {
                                                _selectedTachoFile = fileData;
                                                _selectedTachoName = fileName;
                                              });
                                            },
                                            selectedFileName: _selectedTachoName,
                                            errorMessage:   _validationErrors['tacho']
                                        ),
                                          ],



                                        SizedBox(height: screenHeight * .013,),
                                        FilePickerWidget(
                                          title: "Proof of Address",
                                          screenWidth: screenWidth,
                                          screenHeight: screenHeight,
                                          onFilePicked: (Uint8List? fileData, String? fileName) {
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
                                  child:_isuploading
                                      ? SizedBox(
                                      height:20,
                                      width:20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      )) // Show loading indicator if _isLoading is true
                                      : Text(
                                    "Update",
                                    style: TextStyle(color: Colors.white, fontSize: 18,fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight* 0.1,),
                          ],
                        ),
                      );
                    } else {
                      return Column(
                        children: [
                          Container(
                              height:screenHeight*.8,
                              child: Center(child: Text('No file available.'))),
                        ],
                      );
                    }
                  }
                },
              ),
            ),
          ],),
      );
    }
  }
}
