import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:c9_app/Modules/ClientModule/client_screen.dart';
import 'package:c9_app/Modules/ClientModule/model/RequestIndexModel/requestIndexModel.dart';
import 'package:c9_app/Modules/ClientModule/pages/noInternetConnectionWidget.dart';
import 'package:c9_app/loadingScreen.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/utils/routes/routes_name.dart';
import 'package:c9_app/view/widgets/error_logout.dart';
import 'package:c9_app/view_model/services/rolebasedmodel/user_view_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as https;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/RequestIndexModel/RequestWorkerType.dart';
import '../../../../utils/utils.dart';

class RequestTabScreenNew extends StatefulWidget {
  const RequestTabScreenNew({super.key});

  @override
  State<RequestTabScreenNew> createState() => _RequestTabScreenNewState();
}

class _RequestTabScreenNewState extends State<RequestTabScreenNew> with WidgetsBindingObserver {
  late Future<RequestIndexModel?> _showListData;

  /// Request List Credentials
  late Future<RequestIndexModel?> _showReqListData;
  RequestIndexModel? _cachedData;

  /// Add Request Credentials
  TextEditingController _reqNum = TextEditingController();
  TextEditingController _DatePickerController = TextEditingController();
  TextEditingController _staffType = TextEditingController();

  String? _selectedJobType;
  List<String> jobTypes = [];

  Map<String, String> _validationErrors = {};
  String _numberValidationError = '';
  String _dateValidationError = '';
  String _jobTypeValidationError = '';
  String _typeOFValidationError = '';
  bool isLoading = false;

  /// Show  No Internet Flag
  bool _showNoInternetConnectionMessage = false;

  /// Check Users network Connectivity
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _showListData = fetchReqListIndex();
    _showReqListData = _fetchReqList();
    _fetchJobTypes();

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
      bool hasInternet = await _hasInternetConnection(); // Check internet access

      if (result != ConnectivityResult.none && _showNoInternetConnectionMessage && hasInternet) {
        _refreshData(forceRefresh: true).then((_) {
          setState(() {});
        });
      }
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
    _connectivitySubscription.cancel(); // Cancel subscription
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshData().then((_) {
        setState(() {});
      });
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> _refreshData({bool forceRefresh = false}) async {
    if (forceRefresh) {
      APICacheManager().deleteCache('Request List');
      APICacheManager().deleteCache('Request Tab');
      _cachedData = null; // Clear cached data on force refresh
    }

    final results = await Future.wait([
      fetchReqIndex(),
      // fetchReqListIndex(),
      _fetchReqList(),
    ]);

    if (results.contains(null)) {
      setState(() {
        _showNoInternetConnectionMessage = true;
      });
    } else {
      setState(() {
        _showNoInternetConnectionMessage = false;
        _showListData = Future.value(results[0] as FutureOr<RequestIndexModel>?);
        _showReqListData = Future.value(results[1] as FutureOr<RequestIndexModel>?);

        /// New Arefin
        _cachedData = results[1] as RequestIndexModel;
      });

      APICacheDBModel cacheDBModel =
          APICacheDBModel(key: 'Request Tab', syncData: jsonEncode((results[0] as RequestIndexModel).toJson()));
      await APICacheManager().addCacheData(
          APICacheDBModel(key: 'Request List', syncData: jsonEncode((results[1] as RequestIndexModel).toJson())));
      await APICacheManager().addCacheData(cacheDBModel);
    }
  }

  /// ROOT
  Future<RequestIndexModel?> fetchReqIndex() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    bool hasInernet = await _hasInternetConnection();
    if (connectivityResult == ConnectivityResult.none || !hasInernet) {
      // No internet connection
      setState(() {
        _showNoInternetConnectionMessage = true;
      });
      return null;
    } else {
      ///New Added
      var isCacheExist = await APICacheManager().isAPICacheKeyExist('Request Tab');
      if (!isCacheExist) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String _token = prefs.getString('token') ?? '';
        final String apiUrl = '${AppUrl.baseUrl}/api/app/request/index';
        final response = await https.get(Uri.parse(apiUrl), headers: {
          'Authorization': 'Bearer $_token',
        });
        if (response.statusCode == 200) {
          ///New Added
          APICacheDBModel cacheDBModel = new APICacheDBModel(key: 'Request Tab', syncData: response.body);
          await APICacheManager().addCacheData(cacheDBModel);

          return requestIndexModelFromJson(response.body);
        } else {
          throw Exception('Failed to load day rate index');
        }
      } else {
        var cacheData = await APICacheManager().getCacheData('Request Tab');
        return requestIndexModelFromJson(cacheData.syncData);
      }
    }
  }

  /// ADD REQUEST
  Future<void> _PostRequest() async {
    setState(() {
      isLoading = true;
    });
    _numberValidationError = '';
    _dateValidationError = '';
    _jobTypeValidationError = '';
    _typeOFValidationError = '';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';

    try {
      String apiUrl = '${AppUrl.baseUrl}/api/app/request/store';
      var request = https.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers.addAll({
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
      });

      request.fields['number_of_staff'] = _reqNum.text.toString();
      request.fields['date'] = _DatePickerController.text.toString();
      request.fields['job_type'] = _selectedJobType.toString();
      request.fields['types_of_staff'] = _staffType.text.toString();

      var response = await request.send();

      if (response.statusCode == 200) {
        print('Registration Successful');
        // setState(() {
        //   isLoading = false;
        // });
        _reqNum.clear();
        _selectedJobType = null;
        _staffType.clear();
        _DatePickerController.clear();
        Utils.flushBarSuccessMessage("Data Submit Successfully", context);

        /// New Arefin
        await _refreshData(forceRefresh: true);
        setState(() {
          isLoading = false; // Set loading state to false after successful request
        });
      } else if (response.statusCode == 422) {
        // Parse and handle validation error response
        final Map<String, dynamic> responseData = jsonDecode(await response.stream.bytesToString());
        print(responseData);
        if (responseData.containsKey('errors')) {
          final Map<String, dynamic> errors = responseData['errors'];
          errors.forEach((field, messages) {
            final String errorMessage = messages.isNotEmpty ? messages.first : 'Unknown error';
            switch (field) {
              case 'number_of_staff':
                _numberValidationError = errorMessage;
                break;
              case 'date':
                _dateValidationError = errorMessage;
                break;
              case 'job_type':
                _jobTypeValidationError = errorMessage;
                break;
              case 'types_of_staff':
                _typeOFValidationError = errorMessage;
                break;
            }
          });
          // Show error messages to the user
          setState(() {
            _validationErrors = {
              'number_of_staff': _numberValidationError,
              'date': _dateValidationError,
              'job_type': _jobTypeValidationError,
              'types_of_staff': _typeOFValidationError,
            };
            isLoading = false;
          });
          String errorMessage = responseData['message'] ?? 'Failed';
          Utils.flushBarErrorMessage(errorMessage, context);
        }
      } else {
        final Map<String, dynamic> responseData = jsonDecode(await response.stream.bytesToString());
        String errorMessage = responseData['message'] ?? 'Failed';
        Utils.flushBarErrorMessage(errorMessage, context);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error during registration: $e');
    }
  }

  /// REQUEST LIST
  Future<RequestIndexModel> _fetchReqList() async {
    if (_cachedData != null) {
      print('Using cached data');
      return _cachedData!; // Return cached data if available
    }
    var freshReqListData = await fetchReqListIndex();
    _cachedData = freshReqListData; // Store fetched data in cache
    return freshReqListData;
  }

  Future<void> _fetchJobTypes() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token') ?? '';

      String apiUrl = '${AppUrl.baseUrl}/api/app/worker/role';

      final response = await https.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final requestWorkerType = RequestWorkerType.fromJson(jsonResponse);

        setState(() {
          jobTypes = requestWorkerType.data?.map((data) => data.staffType ?? '').toList() ?? [];
        });
      } else {
        print("Failed to load job types: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching job types: $e");
    }
  }

  Future<RequestIndexModel> fetchReqListIndex() async {
    var isCachedExist = await APICacheManager().isAPICacheKeyExist('Request List');
    if (!isCachedExist) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String _token = prefs.getString('token') ?? '';
      final String apiUrl = '${AppUrl.baseUrl}/api/app/request/index';
      final response = await https.get(Uri.parse(apiUrl), headers: {
        'Authorization': 'Bearer $_token',
      });
      if (response.statusCode == 200) {
        APICacheDBModel cacheDBModel = new APICacheDBModel(key: 'Request List', syncData: response.body);
        await APICacheManager().addCacheData(cacheDBModel);

        return requestIndexModelFromJson(response.body);
      } else {
        throw Exception('Failed to load day rate index');
      }
    } else {
      var cacheData = await APICacheManager().getCacheData('Request List');
      return requestIndexModelFromJson(cacheData.syncData);
    }
  }

  Future<void> deleteDeptIndex(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';

    final String apiUrl = '${AppUrl.baseUrl}/api/app/request/cancel/$id';
    final response = await https.get(Uri.parse(apiUrl), headers: {
      'Authorization': 'Bearer $_token',
    });

    if (response.statusCode == 200) {
      // setState(() {
      //   _showListData = fetchReqListIndex();
      //   // _showListData = fetchDepIndex();
      // });
      APICacheManager().deleteCache('Request List'); //delete previous cached Data
      _cachedData = null; // Clear cached data after deletion
      _refreshData(forceRefresh: true);

      print('Staff $id deleted successfully');
    } else {
      throw Exception('Failed to delete Dept Index: $id');
    }
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to cancel this request?'),
              ],
            ),
          ),
          actions: <Widget>[
            InkWell(
              onTap: () async {
                Navigator.of(context).pop();
                onConfirmed();
              },
              child: Container(
                width: screenWidth * 0.2,
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.011,
                ),
                decoration: BoxDecoration(
                  color: AppColors.navButtonColor,
                  borderRadius: BorderRadius.circular(15),
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
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                width: screenWidth * 0.2,
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.011,
                ),
                decoration: BoxDecoration(
                  color: AppColors.navOpacity,
                  borderRadius: BorderRadius.circular(15),
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userPrefernece = Provider.of<UserViewModel>(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: _showNoInternetConnectionMessage ? Colors.red : AppColors.navColor,
    ));

    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return Container(
      height: screenHeight,
      child: FutureBuilder<RequestIndexModel?>(
        future: _showListData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: screenHeight * 0.9,
              width: screenWidth,
              color: AppColors.whiteColor,
              child: LoadingScreen(),
            );
          } else if (snapshot.hasError) {
            return Column(
              children: [
                SizedBox(height: screenHeight* 0.2,),
                Expanded(
                  child: ErrorLogOutScreen(
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    errorMessage: 'Oops! Something went wrong.',
                    subMessage: 'Try logging out and back in.',
                    icon: CupertinoIcons.exclamationmark_circle,
                  
                    buttonText: 'Logout',
                    onButtonPressed: () {
                      userPrefernece.remove().then((value){
                        Navigator.pushNamed(context, RoutesName.login);
                      });
                    },
                  ),
                ),
              ],
            );
            // return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return SafeArea(
              child: Scaffold(
                backgroundColor: Colors.white,
                body: _showNoInternetConnectionMessage
                    ? NoInternetConnection()
                    : RefreshIndicator(
                        onRefresh: () => _refreshData(forceRefresh: true),
                        child: SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: ResPonsiveUi(
                            mobile: body(),
                            desktop: body(),
                            tablet: body(),
                          ),
                        ),
                      ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget body() {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;

    return SingleChildScrollView(
      child: Column(children: [
        SizedBox(
          height: screenHeight * 0.013,
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.84,
          width: MediaQuery.of(context).size.width,
          child: _tabSection(context),
        ),
      ]),
    );
  }

  _tabSection(BuildContext context) {
    final userPrefernece = Provider.of<UserViewModel>(context);
    double screenHeight = MediaQuery.of(context).size.height * 1;
    double screenWidth = MediaQuery.of(context).size.width * 1;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            width: screenWidth,
            color: Colors.white,
            child: TabBar(
              dividerColor: AppColors.whiteColor,
              indicatorColor: AppColors.navOpacity,
              tabs: [
                Container(
                  height: screenHeight * 0.055,
                  width: screenWidth * 0.475,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        width: 0.2,
                        color: AppColors.navButtonColor,
                        // Color(0xff078C79)
                      )),
                  child: Tab(
                    child: Text(
                      "Request List",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: screenHeight * 0.055,
                  width: screenWidth * 0.475,
                  decoration: BoxDecoration(
                      color: AppColors.navButtonColor,
                      // Color(0xff078C79).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        width: 0.2,
                        color: AppColors.navButtonColor,
                      )),
                  child: Center(
                    child: Tab(
                      child: Text(
                        'Add Request',
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                /** Request Staff **/
                SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        Center(
                          child: FutureBuilder<RequestIndexModel?>(
                            future: _showListData,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Container(
                                  height: screenHeight * 0.72,
                                  width: screenWidth,
                                  color: AppColors.whiteColor,
                                  child: LoadingScreen(),
                                );
                              } else if (snapshot.hasError) {
                                return  ErrorLogOutScreen(
                                  screenHeight: screenHeight,
                                  screenWidth: screenWidth,
                                  errorMessage: 'Oops! Something went wrong.',
                                  subMessage: 'Try logging out and back in.',
                                  icon: CupertinoIcons.exclamationmark_circle,

                                  buttonText: 'Logout',
                                  onButtonPressed: () {
                                    userPrefernece.remove().then((value){
                                      Navigator.pushNamed(context, RoutesName.login);
                                    });
                                  },
                                );
                                // return Center(child: Text('Error: ${snapshot.error}'));
                              } else {
                                final reqIndex = snapshot.data?.data?.data;

                                if (reqIndex != null && reqIndex.isNotEmpty) {
                                  return Column(
                                    children: [
                                      Container(
                                        width: screenWidth * 0.95,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: Column(
                                          children: [
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics: NeverScrollableScrollPhysics(),
                                              itemCount: reqIndex.length,
                                              itemBuilder: (context, index) {
                                                final number = reqIndex[index].numberOfStaff ?? "";
                                                String type = reqIndex[index].typesOfStaff ?? "";
                                                final status = reqIndex[index].status ?? "";
                                                int id = reqIndex[index].id;
                                                Widget statusWidget;

                                                if (type.length > 15) {
                                                  type = '${type.substring(0, 15)}...';
                                                }

                                                if (status == "Cancel") {
                                                  statusWidget = Text(
                                                    "Cancelled",
                                                    style: TextStyle(color: Colors.red),
                                                  );
                                                } else if (status == "Pending") {
                                                  statusWidget = GestureDetector(
                                                    onTap: () async {
                                                      //  Utils.showDialogLoading(context);
                                                      // await deleteDeptIndex(id);
                                                      //  Navigator.pop(context);
                                                      showConfirmationDialog(context, () async {
                                                        Utils.showDialogLoading(context);
                                                        await deleteDeptIndex(id);
                                                        Navigator.pop(context);
                                                      });
                                                    },
                                                    child: Container(
                                                      height: screenHeight * 0.04,
                                                      width: screenWidth * 0.2,
                                                      decoration: BoxDecoration(
                                                          color: AppColors.navButtonColor,
                                                          borderRadius: BorderRadius.circular(5)),
                                                      child: Center(
                                                          child: Text(
                                                        "Cancel",
                                                        style: TextStyle(color: Colors.white),
                                                      )),
                                                    ),
                                                  );
                                                } else if (status == "Approve") {
                                                  statusWidget =
                                                      Text("Approved", style: TextStyle(color: Colors.green));
                                                } else {
                                                  statusWidget = Text("Unknown Status");
                                                }
                                                return Column(
                                                  children: [
                                                    SizedBox(
                                                      height: screenHeight * 0.013,
                                                    ),
                                                    Container(
                                                      width: screenWidth * 0.95,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(10),
                                                        color: Color(0xffFAFAFA),
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(10.0),
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Text(
                                                                      "Type of Worker",
                                                                      style: TextStyle(
                                                                          fontSize: 18, fontWeight: FontWeight.bold),
                                                                    ),
                                                                    GestureDetector(
                                                                        onTapUp: (details) {
                                                                          String? responsi =
                                                                              reqIndex[index].typesOfStaff;
                                                                          if (responsi != null) {
                                                                            _showFullNamePopup(context, responsi,
                                                                                details.globalPosition);
                                                                          }
                                                                        },
                                                                        child: Text(
                                                                          "$type",
                                                                          style: TextStyle(
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.w400),
                                                                        )),
                                                                  ],
                                                                ),
                                                                Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Text(
                                                                      "Number of Worker",
                                                                      style: TextStyle(
                                                                          fontSize: 18, fontWeight: FontWeight.bold),
                                                                    ),
                                                                    Text(
                                                                      "$number",
                                                                      style: TextStyle(
                                                                          fontSize: 14, fontWeight: FontWeight.w400),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height: screenHeight * 0.013,
                                                            ),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      "Status",
                                                                      style: TextStyle(
                                                                          fontSize: 16, fontWeight: FontWeight.w500),
                                                                    ),
                                                                    SizedBox(
                                                                      width: screenWidth * 0.02,
                                                                    ),
                                                                    Container(
                                                                      height: screenHeight * 0.035,
                                                                      width: screenWidth * 0.002,
                                                                      color: Colors.grey,
                                                                    ),
                                                                    SizedBox(
                                                                      width: screenWidth * 0.02,
                                                                    ),
                                                                    Text(
                                                                      "$status",
                                                                      style: TextStyle(
                                                                          fontSize: 16,
                                                                          fontWeight: FontWeight.w500,
                                                                          color: AppColors.blackColor.withOpacity(0.6)),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      "Action",
                                                                      style: TextStyle(
                                                                          fontSize: 16, fontWeight: FontWeight.w500),
                                                                    ),
                                                                    SizedBox(
                                                                      width: screenWidth * 0.02,
                                                                    ),
                                                                    Container(
                                                                      height: screenHeight * 0.035,
                                                                      width: screenWidth * 0.002,
                                                                      color: Colors.grey,
                                                                    ),
                                                                    SizedBox(
                                                                      width: screenWidth * 0.02,
                                                                    ),
                                                                    statusWidget,
                                                                  ],
                                                                ),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.2),
                                    ],
                                  );
                                } else {
                                  return Column(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                                        height: screenHeight * 0.7,
                                        width: screenWidth,
                                        color: AppColors.whiteColor,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                color: AppColors.navColor,
                                                size: screenWidth * 0.12,
                                              ),
                                              SizedBox(
                                                height: screenHeight * 0.02,
                                              ),
                                              Text(
                                                'No Requests Available',
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
                                                'Please add a new request to proceed.',
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
                  ),
                ),

                /** Add Request Staff **/
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Create New Request",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                            )),
                        SizedBox(
                          height: screenHeight * 0.013,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SingleHeader(
                                context: context,
                                labelText: 'How Many Worker Members Do You Require?',
                                text: 'Number Of Worker',
                                controllers: _reqNum,
                                keyboard: TextInputType.text,
                                iconData: Icons.account_balance_wallet_outlined),
                            if (_numberValidationError.isNotEmpty)
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  _numberValidationError,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),

                            SizedBox(
                              height: screenHeight * 0.013,
                            ),

                            Row(
                              children: [
                                Text(
                                  'Date',
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  ' *',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: screenHeight * 0.005,
                            ),
                            Container(
                              // height: screenHeight * 0.065,
                              width: screenWidth * 0.95,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.navButtonColor,
                                  width: 0.4,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: TextFormField(
                                controller: _DatePickerController,
                                keyboardType: TextInputType.datetime,
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(fontSize: 14),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  hintText: 'DD-MM-YYYY',
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  prefixIcon: Icon(
                                    Icons.calendar_today,
                                    size: 20,
                                  ),
                                ),
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                    initialEntryMode:
                                        DatePickerEntryMode.calendar, // Set the initial entry mode to calendar
                                  );

                                  if (pickedDate != null) {
                                    String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);

                                    setState(() {
                                      //   _DatePickerController.text = pickedDate.toString().split(' ')[0]; // Only show the date part
                                      _DatePickerController.text = formattedDate;
                                    });
                                  }
                                },
                              ),
                            ),
                            if (_dateValidationError.isNotEmpty)
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  _dateValidationError,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            SizedBox(
                              height: screenHeight * 0.013,
                            ),
                            // RowHeader(labelText: 'Part time Or Full time',text: 'Staff Job Type', context: context, controllers: _jobType, keyboard: TextInputType.text, iconData: Icons.location_on,), // Provide the desired icon),

                            Row(
                              children: [
                                Text(
                                  "Worker Job Type",
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  ' *',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: screenHeight * 0.005,
                            ),
                            Container(
                              width: screenWidth * 0.95,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.navButtonColor,
                                  width: 0.4,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  // iconEnabledColor: AppColors.navButtonColor,
                                  iconSize: 30.0,
                                  value: _selectedJobType,
                                  items: jobTypes.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedJobType = newValue!;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(fontSize: 14),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.person_search_rounded,
                                      size: 20,
                                    ),
                                    hintText: 'Select Job Type',
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                            if (_jobTypeValidationError.isNotEmpty)
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  _jobTypeValidationError,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(
                          height: screenHeight * 0.013,
                        ),
                        Row(
                          children: [
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Type Of Worker",
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                                )),
                            Text(
                              ' *',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: screenHeight * 0.005,
                        ),
                        Container(
                          height: screenHeight * 0.2,
                          width: screenWidth * 0.95,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.navButtonColor,
                              width: 0.4,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: TextFormField(
                            controller: _staffType,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintStyle: TextStyle(fontSize: 14),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              hintText: "Please Enter Your Specific Requirements",
                              prefixIcon: Icon(
                                Icons.edit,
                                size: 20,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                        if (_typeOFValidationError.isNotEmpty)
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              _typeOFValidationError,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        SizedBox(
                          height: screenHeight * 0.013,
                        ),
                        InkWell(
                          onTap: () async {
                            await _PostRequest();
                          },
                          child: Container(
                            height: screenHeight * 0.055,
                            width: screenWidth * 0.4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColors.navButtonColor,
                              border: Border.all(
                                width: 0.2,
                                color: AppColors.greyOpacity,
                              ),
                            ),
                            child: Center(
                              child: isLoading
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      )) // Show loading indicator if isLoading is true
                                  : Text(
                                      "Submit",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.2),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget HeaderRow(IconData iconData) {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return Container(
      height: screenHeight * 0.055,
      width: screenWidth * 0.12,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.greyOpacity,
            offset: Offset(0, 2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        iconData,
        color: AppColors.navColor,
      ),
    );
  }

  String _removeHtmlTags(String htmlString) {
    final document = parse(htmlString);
    return parse(document.body!.text).documentElement!.text;
  }

  void _showFullNamePopup(BuildContext context, String fullName, Offset position) {
    if (fullName.isNotEmpty) {
      fullName = fullName[0].toUpperCase() + fullName.substring(1).toLowerCase();
    }
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
    final RelativeRect positionPopup = RelativeRect.fromRect(
      Rect.fromPoints(
        position,
        position.translate(0, 0),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: positionPopup,
      items: [
        PopupMenuItem(
          child: Container(
            // width: ,
            // height: 40,
            alignment: Alignment.center,
            child: Text(
              _removeHtmlTags(fullName),
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget SingleHeader({
    String? text,
    required BuildContext context,
    required TextEditingController controllers,
    required TextInputType keyboard,
    IconData? iconData,
    required String labelText, // Corrected parameter name
  }) {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (text != null) // Only add the Text widget if text is provided
              Text(
                text,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              ),
            Text(
              ' *',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ],
        ),
        SizedBox(
          height: screenHeight * 0.005,
        ),
        Container(
          // height: screenHeight * 0.065,
          width: screenWidth * 0.95,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.navButtonColor,
              width: 0.4,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextFormField(
            controller: controllers,
            keyboardType: keyboard,
            textAlign: TextAlign.left,
            decoration: InputDecoration(
              hintStyle: TextStyle(fontSize: 14),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              prefixIcon: Icon(
                iconData,
                size: 20,
              ),
              hintText: labelText, // Corrected parameter name
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
