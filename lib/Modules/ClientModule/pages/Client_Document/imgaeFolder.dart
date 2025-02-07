import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:c9_app/Modules/ClientModule/client_screen.dart';
import 'package:c9_app/Modules/ClientModule/pages/Client_Document/ViewFolder.dart';
import 'package:c9_app/Modules/ClientModule/pages/noInternetConnectionWidget.dart';
import 'package:c9_app/Modules/StaffModule/MODEL/profilemodelStaff/staffList_File.dart';
import 'package:c9_app/loadingScreen.dart';
import 'package:c9_app/provider/PermisionProvider.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/utils/utils.dart';
import 'package:c9_app/view/widgets/header_widgets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as https;

class ClientImageFolder extends StatefulWidget {
  final String slug;
  const ClientImageFolder({Key? key, required this.slug}) : super(key: key);

  @override
  State<ClientImageFolder> createState() => _ClientImageFolderState();
}

class _ClientImageFolderState extends State<ClientImageFolder> with WidgetsBindingObserver {
  late Future<StaffFileListView?> _userFilelistFuture;

  bool _showNoInternetConnectionMessage = false;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _userFilelistFuture = fetchFile();
    _requestPermissions();

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
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
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove the observer

    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<StaffFileListView?> fetchFile() async {
    // first check user's network connectivity
    var connectivityResult = await (Connectivity().checkConnectivity());
    bool hasInternet = await _hasInternetConnection();

    if (connectivityResult == ConnectivityResult.none || !hasInternet) {
      // show No internet connection
      setState(() {
        _showNoInternetConnectionMessage = true;
      });
      return null;
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String _token = prefs.getString('token') ?? '';

      final String apiUrl = '${AppUrl.baseUrl}/api/app/staff/file/${widget.slug}';
      print(apiUrl);
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
        throw Exception('Failed to fetch user data. Status code: ${response.statusCode}');
      }
    }
  }

  Future<void> deleteFile(int id, String fileType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';

    final String apiUrl = '${AppUrl.baseUrl}/api/app/staff/file/delete/$id/$fileType';
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
  Future<void> downloadFile(String fileName) async {
    await _requestPermissions();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';

    final String fileUrl = '${AppUrl.baseUrl}/api/app/staff/file/download/$fileName';

    try {
      await _requestPermissions();

      final Directory? saveDir = await getExternalStorageDirectory();
      final String savePath = '${saveDir?.path}/$fileName';

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
        _openFile(savePath);
      } else {
        print('Failed to download file. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error downloading file: $error');
    }
  }

  Future<void> _requestPermissions() async {
    final permissionProvider = Provider.of<PermissionProvider>(context, listen: false);
    await permissionProvider.requestFileAndMediaPermission();
  }

  void _openFile(String filePath) {
    OpenFile.open(filePath);
  }

  List<Datum>? filterImageFiles(List<Datum>? filesList) {
    if (filesList == null) return null;
    return filesList.where((file) {
      final fileName = file.fileName!.toLowerCase();
      return fileName.endsWith('.jpg') ||
          fileName.endsWith('.jpeg') ||
          fileName.endsWith('.png') ||
          fileName.endsWith('.webp');
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: _showNoInternetConnectionMessage ? Colors.red : AppColors.navColor,
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

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: screenHeight * 0.013),
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
                            builder: (context) => UploadFileClientfNew(
                                  slug: widget.slug,
                                )));
                  },
                  child: HeaderRow(Icons.arrow_back),
                ),
                Text(
                  "Documents",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ClientCurveNabBar()));
                  },
                  child: HeaderRow(Icons.home),
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.013),
          Center(
            child: FutureBuilder<StaffFileListView?>(
              future: _userFilelistFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: screenHeight * 0.8,
                    width: screenWidth,
                    color: AppColors.whiteColor,
                    child: LoadingScreen(),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text(''));
                  // return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final filesList = snapshot.data?.data;

                  // Filter only image files
                  final imageFilesList = filterImageFiles(filesList);

                  if (imageFilesList != null && imageFilesList.isNotEmpty) {
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: screenWidth < 600 ? 4 : 6,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                      ),
                      shrinkWrap: true,
                      itemCount: imageFilesList.length,
                      itemBuilder: (context, index) {
                        final fileName = imageFilesList[index].fileName;
                        final viewUrl = imageFilesList[index].viewUrl;
                        final fileId = imageFilesList[index].id;
                        final fileType = imageFilesList[index].fileType;
                        return GestureDetector(
                          onTap: () {
                            downloadFile(fileName!);
                            Utils.toastMessage("Clicked. Please Wait");
                          },
                          child: Card(
                            color: Colors.white,
                            elevation: 0.3,
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          '$viewUrl',
                                        ),
                                        fit: BoxFit.cover,
                                      )),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                    onPressed: () async {
                                      // deleteFile(fileId);
                                      showConfirmationDialog(context, () async {
                                        Utils.showDialogLoading(context);
                                        await deleteFile(fileId!, fileType!);
                                        Navigator.pop(context);
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return Column(
                      children: [
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: screenWidth * 0.1), // Add padding for responsiveness
                          height: screenHeight * 0.7,
                          width: screenWidth,
                          color: AppColors.whiteColor,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image,
                                  color: AppColors.navColor,
                                  size: screenWidth * 0.12,
                                ),
                                SizedBox(
                                  height: screenHeight * 0.02,
                                ),
                                Text('No Image Available.',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.045,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.navColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height: screenHeight * 0.01, // Additional spacing using screen height
                                ),
                                Text(
                                  'Please add a new image to proceed.',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.035,
                                    color: AppColors.navColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> showConfirmationDialog(BuildContext context, Function() onConfirmed) async {
    double screenWidth = MediaQuery.of(context).size.width * 1;
    double screenHeight = MediaQuery.of(context).size.height * 1;
    return showDialog<void>(
      context: context,
      // barrierDismissible: false, // Dialog cannot be dismissed by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.02,
            vertical: screenHeight * 0.02,
          ),
          insetPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.1,
            vertical: screenHeight * 0.2,
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: SizedBox(
            width: screenWidth * 0.6,
            child: Text(
              'Are you sure you want to delete this image?',
              style: TextStyle(fontSize: 16),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () async {
                    Navigator.of(context).pop();
                    onConfirmed();
                  },
                  child: Container(
                    width: screenWidth * 0.3,
                    decoration: BoxDecoration(
                      color: AppColors.navButtonColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.015,
                    ),
                    child: Center(
                      child: Text(
                        'Yes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.05),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: screenWidth * 0.3,
                    decoration: BoxDecoration(
                      color: AppColors.navOpacity,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.015,
                    ),
                    child: Center(
                      child: Text(
                        'No',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
