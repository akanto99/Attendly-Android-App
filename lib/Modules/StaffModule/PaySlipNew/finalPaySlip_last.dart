import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:c9_app/Modules/ClientModule/pages/noInternetConnectionWidget.dart';
import 'package:c9_app/Modules/StaffModule/DashBoard/staff_navigationScreen.dart';
import 'package:c9_app/Modules/StaffModule/PaySlipNew/PaySlipModelNew.dart';
import 'package:c9_app/loadingScreen.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/utils/utils.dart';
import 'package:c9_app/view/widgets/header_widgets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as https;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FinalPaySlipLast extends StatefulWidget {
  final String userId;
  const FinalPaySlipLast({Key? key, required this.userId}) : super(key: key);

  @override
  State<FinalPaySlipLast> createState() => _FinalPaySlipLastState();
}

class _FinalPaySlipLastState extends State<FinalPaySlipLast>
    with WidgetsBindingObserver {
  TextEditingController _peopleController = TextEditingController();
  TextEditingController _FromController = TextEditingController();
  TextEditingController _ToController = TextEditingController();
  bool _showList = true;

  late Future<List<PaySlipListModel>> _showPaySlipList;
  final Dio _dio = Dio();

  bool _showNoInternetConnectionMessage = false;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _showPaySlipList = _getPaySlipList();
    _requestPermissions();

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
    _connectivitySubscription.cancel();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _refreshData(forceRefresh: true);
    }
    super.didChangeAppLifecycleState(state);
  }

  /// Updated Function By HIMU
  Future<void> _refreshData({bool forceRefresh = false}) async {
    if (forceRefresh) {
      // Always delete the existing cache before fetching new data
      await APICacheManager().deleteCache('Payslip'); // Ensure cache is deleted
    }
    var freshData = await _getPaySlipList(); // Fetch fresh data from API

    if (freshData != null) {
      setState(() {
        _showPaySlipList = Future.value(freshData);
      });
      // Cache the fetched data
      APICacheDBModel cacheDBModel = APICacheDBModel(
        key: 'Payslip',
        syncData: jsonEncode(freshData),
      );
      await APICacheManager().addCacheData(cacheDBModel);
    } else {
      _showNoInternetConnectionMessage = true;
    }
  }

  Future<List<PaySlipListModel>> _getPaySlipList() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    bool hasInternet = await _hasInternetConnection();

    if (connectivityResult == ConnectivityResult.none || !hasInternet) {
      // No internet connection
      setState(() {
        _showNoInternetConnectionMessage = true;
      });
      return [];
    } else {
      var isCachedExist = await APICacheManager().isAPICacheKeyExist('Payslip');
      if (!isCachedExist) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String _token = prefs.getString('token') ?? '';
        String people = _peopleController.text;
        String fromDate = _FromController.text;
        String toDate = _ToController.text;
        final String apiUrl =
            '${AppUrl.baseUrl}/api/app/my-digital-accounts/payslip/history?peopleId=$people&payDateFrom=$fromDate&payDateTo=$toDate';
        print("A");
        print("AppUrl $apiUrl");
        final response = await https.get(Uri.parse(apiUrl), headers: {
          'Authorization': 'Bearer $_token',
        });

        if (response.statusCode == 200) {
          List<dynamic> responseData = json.decode(response.body);
          List<PaySlipListModel> paySlipList = responseData
              .map((data) => PaySlipListModel.fromJson(data))
              .toList();
          print("AppUrl $apiUrl");

          // Cache the fetched payslip list
          APICacheDBModel cacheDBModel = APICacheDBModel(
            key: 'Payslip',
            syncData: jsonEncode(
                paySlipList), // You might need to adjust how you encode the list
          );
          await APICacheManager().addCacheData(cacheDBModel);
          print('Cached Payslip List Added Successfully');

          return paySlipList;
        } else {
          return [];
          // throw Exception('Failed to load');
        }
      } else {
        // Retrieve from cache
        var cachedData = await APICacheManager().getCacheData('Payslip');
        print('CACHE: HIT_getPaySlipList()');
        List<dynamic> cachedResponseData = json.decode(cachedData.syncData);
        List<PaySlipListModel> cachedPaySlipList = cachedResponseData
            .map((data) => PaySlipListModel.fromJson(data))
            .toList();
        return cachedPaySlipList;
      }
    }
  }

  Future<void> downloadFile(int id, String pd) async {
    Utils.showDialogLoading(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';

    // final String fileUrl = '${AppUrl.baseUrl}/api/app/my-digital-accounts/payslip/download';
    final String fileUrl =
        '${AppUrl.baseUrl}/api/app/my-digital-accounts/payslip/download?peopleId=$id&payDate=$pd';
    print("New fileUrl $fileUrl");

    try {
      await _requestPermissions();

      final Directory? downloadsDirectory = await getDownloadsDirectory();
      final String savePath = '${downloadsDirectory?.path}.pdf';
      print("Save Path: $savePath");

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
        print("New fileUrl $fileUrl");
        _openFile(savePath);
      } else {
        print('Failed to download file. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error downloading file: $error');
    } finally {
      Navigator.of(context).pop();
    }
  }

  Future<void> _requestPermissions() async {
    PermissionStatus status = await Permission.storage.request();
    if (!status.isGranted) {
      print('Storage permission denied');
    }
  }

  void _openFile(String filePath) {
    OpenFile.open(filePath);
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
        appBar: AppBar(
          automaticallyImplyLeading: false,
          surfaceTintColor: Colors.white,
          toolbarHeight: 80,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: HeaderRow(Icons.arrow_back)),
              Text(
                "Payslips",
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
        body: RefreshIndicator(
          onRefresh: () => _refreshData(forceRefresh: true),
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
          // Text('Widgets- ${widget.userId} ', style: TextStyle(fontSize: 16),),

          if (_showList)
            FutureBuilder<List<PaySlipListModel>>(
              future: _showPaySlipList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: screenHeight * 0.8,
                    width: screenWidth,
                    color: AppColors.whiteColor,
                    child: LoadingScreen(),
                  );
                } else if (snapshot.hasError) {
                  return Text("");
                  // Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final assignClientLists = snapshot.data;

                  // if (assignClientLists!.isEmpty) {
                  //   return Container(
                  //     height: screenHeight * 0.75,
                  //     width: screenWidth,
                  //     color: AppColors.whiteColor,
                  //     child: Center(
                  //       child: Padding(
                  //         padding: const EdgeInsets.all(20.0),
                  //         child: Column(
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           children: [
                  //             Icon(Icons.data_exploration_outlined,
                  //                 size: 50,
                  //                 color:
                  //                     AppColors.navButtonColor), // Warning icon
                  //             SizedBox(height: 10),
                  //             Text(
                  //               'No Data Available',
                  //               style: TextStyle(
                  //                   fontSize: 24,
                  //                   fontWeight: FontWeight.bold,
                  //                   color: AppColors.navColor),
                  //             ),
                  //             SizedBox(height: 10),
                  //             Text(
                  //               'It seems there is no data to display at this moment.',
                  //               textAlign: TextAlign.center,
                  //               style: TextStyle(
                  //                   fontSize: 16, color: Colors.grey[600]),
                  //             ),
                  //             SizedBox(height: 20),
                  //             ElevatedButton(
                  //               onPressed: () {
                  //                 _refreshData(
                  //                     forceRefresh:
                  //                         true); // Retry fetching data
                  //               },
                  //               child: Text(
                  //                 'Try again',
                  //                 style: TextStyle(color: Colors.black38),
                  //               ),
                  //               style: ElevatedButton.styleFrom(
                  //                   backgroundColor: AppColors.navOpacity),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //   );
                  // } else
                  if (assignClientLists != null &&
                      assignClientLists.isNotEmpty) {
                    return Container(
                      width: screenWidth,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5),
                        ),
                      ),
                      child: Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: assignClientLists.length,
                            itemBuilder: (context, index) {
                              PaySlipListModel paySlip =
                                  assignClientLists[index];
                              return Column(
                                children: [
                                  Container(
                                    width: screenWidth * 0.95,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: screenHeight * 0.008,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Container(
                                              height: screenHeight * 0.06,
                                              width: screenWidth * 0.56,
                                              // color: Colors.yellow,
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Center(
                                                    child: Text(
                                                      "Agency",
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ),
                                                  Center(
                                                    child: Text(
                                                      " ${paySlip.agency}",
                                                      style: TextStyle(
                                                          color: AppColors
                                                              .blackColor
                                                              .withOpacity(0.5),
                                                          fontSize: 14),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                downloadFile(paySlip.peopleId,
                                                    "${paySlip.payDate}");
                                                Utils.toastMessage(
                                                    "Clicked. Please Wait");
                                              },
                                              child: Container(
                                                height: screenHeight * 0.045,
                                                width: screenWidth * 0.3,
                                                decoration: BoxDecoration(
                                                    color: AppColors
                                                        .navButtonColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.2),
                                                        offset: Offset(0, 2),
                                                        blurRadius: 5,
                                                        spreadRadius: 2,
                                                      ),
                                                    ]),
                                                child: Center(
                                                  child: Text(
                                                    "Download",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: screenHeight * 0.013,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            // CusConatiner("People Id", "${paySlip.peopleId}"),
                                            CusConatiner("Payroll Id",
                                                "${paySlip.payrollId}"),
                                            CusConatiner("Pay Date",
                                                "${paySlip.payDate}"),
                                          ],
                                        ),
                                        SizedBox(
                                          height: screenHeight * 0.013,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            CusConatiner("Tax Week",
                                                "${paySlip.taxWeek}"),
                                            CusConatiner(
                                              "Total",
                                              paySlip.total != null
                                                  ? (paySlip.total is double
                                                      ? "${(double.tryParse(paySlip.total ?? '') ?? 0.0).toStringAsFixed(2)}"
                                                      : paySlip.total!
                                                          .toString())
                                                  : '00',
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: screenHeight * 0.019,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.013,
                                  ),
                                ],
                              );
                            },
                          ),
                          SizedBox(
                            height: screenHeight * 0.013,
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Container(
                      height: screenHeight * 0.75,
                      width: screenWidth,
                      color: AppColors.whiteColor,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.data_exploration_outlined,
                                  size: 40,
                                  color:
                                      AppColors.navButtonColor), // Warning icon
                              SizedBox(height: 10),
                              Text(
                                'No Data Available',
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.navColor),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'It seems there is no data to display at this moment.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[600]),
                              ),
                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  _refreshData(
                                      forceRefresh:
                                          true); // Retry fetching data
                                },
                                child: Text(
                                  'Try again',
                                  style: TextStyle(color: Colors.black38),
                                ),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.navOpacity),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );

                    // Container(
                    //   height: screenHeight * 0.7,
                    //   width: screenWidth,
                    //   color: AppColors.blackColor,
                    //   child: Center(child: Text('No data found.')));
                  }
                }
              },
            ),
        ],
      ),
    );
  }

  // GestureDetector(
  //   onTap:(){
  //     downloadFile(paySlip.peopleId, "${paySlip.payDate}");
  //     Utils.toastMessage("Clicked. Please Wait");
  //   },
  //   child:  Container(
  //     height: screenHeight * 0.045,
  //     width: screenWidth * 0.3,
  //     decoration: BoxDecoration(
  //         color: AppColors.navButtonColor,
  //         borderRadius: BorderRadius.circular(10),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.grey.withOpacity(0.2),
  //             offset: Offset(0, 2),
  //             blurRadius: 5,
  //             spreadRadius: 2,
  //           ),
  //         ]),
  //     child: Center(
  //       child: Text(
  //         "Download",
  //         style:
  //         TextStyle(color: Colors.white, fontSize: 14),
  //       ),
  //     ),
  //   ),
  // ),
  Widget buildDateContainer(
      String labelText, TextEditingController controller) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return Container(
      height: screenHeight * 0.06,
      width: screenWidth * 0.45,
      decoration: BoxDecoration(
        color: AppColors.navOpacity.withOpacity(0.2),
        border: Border.all(
          color: AppColors.navButtonColor.withOpacity(0.4),
          width: 0.4,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.datetime,
        readOnly: true,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          hintText: labelText,
          hintStyle: TextStyle(
              color: AppColors.blackColor.withOpacity(0.5), fontSize: 15),
          suffixIcon: Container(
            height: screenHeight * 0.06,
            width: screenWidth * 0.08,
            color: Color(0xffFFF3E5),
            child: Icon(
              Icons.calendar_month_outlined,
              color: Colors.black,
            ),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
        ),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1950),
            lastDate: DateTime(2101),
          );
          if (pickedDate != null) {
            setState(() {
              controller.text = pickedDate.toString().substring(0, 10);
            });
          }
        },
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _peopleController.clear();
      _FromController.clear();
      _ToController.clear();
      _showPaySlipList = _getPaySlipList();
      _showList = true;
    });
  }

  void _submitSearch() {
    if (_peopleController.text.isEmpty) {
      Utils.flushBarErrorMessage("People id is empty.", context);
    } else if (_FromController.text.isEmpty) {
      Utils.flushBarErrorMessage("From date is empty.", context);
    } else if (_ToController.text.isEmpty) {
      Utils.flushBarErrorMessage("To date is empty.", context);
    } else {
      setState(() {
        _showList = true;
        _showPaySlipList = _getPaySlipList();
      });
    }
  }

  Widget CusConatiner(String title, String Tvalue) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return Container(
      // height: screenHeight * 0.055,
      width: screenWidth * 0.43,
      decoration: BoxDecoration(
          color: AppColors.navOpacity.withOpacity(0.2),
          // color: Colors.green,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 0.2,
            color: AppColors.navButtonColor,
            // Color(0xff078C79)
          )),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, top: 5.0, bottom: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              Tvalue,
              style: TextStyle(
                  color: AppColors.blackColor.withOpacity(0.5), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
