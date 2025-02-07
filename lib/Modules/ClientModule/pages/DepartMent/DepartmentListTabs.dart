import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:c9_app/Modules/ClientModule/client_screen.dart';
import 'package:c9_app/Modules/ClientModule/model/DepartmentModel/departmentindexModel.dart';
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
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../utils/utils.dart';

class DepartMentTabScreenNew extends StatefulWidget {
  const DepartMentTabScreenNew({super.key});

  @override
  State<DepartMentTabScreenNew> createState() => _DepartMentTabScreenNewState();
}

class _DepartMentTabScreenNewState extends State<DepartMentTabScreenNew> with WidgetsBindingObserver {
  late Future<DepartmentIndexModel?> _showListData;

  bool _showNoInternetConnectionMessage = false;

  /// Department
  late Future<DepartmentIndexModel?> _showDepartmentListData;
  DepartmentIndexModel? _cachedData; // Store fetched data

  /// Add Department
  TextEditingController _depName = TextEditingController();
  TextEditingController _location = TextEditingController();
  TextEditingController _details = TextEditingController();
  Map<String, String> _validationErrors = {};
  String _responsibilitiesValidationError = '';
  String _deptNameValidationError = '';
  String _LocationValidationError = '';

  bool isLoading = false;

  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    /// Root API
    _showListData = fetchDepIndex();

    /// Department List
    _showDepartmentListData = _fetchDptList();

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
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription.cancel(); // Cancel subscription
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshData().then((_) {
        setState(() {});
      });
      // _refreshData(forceRefresh: true);
    }
    super.didChangeAppLifecycleState(state);
  }

  /// Need To modified with All The API
  Future<void> _refreshData({bool forceRefresh = false}) async {
    if (forceRefresh) {
      APICacheManager().deleteCache('Department Tab');
      APICacheManager().deleteCache('Department List');
      // APICacheManager().deleteCache('Add Department');
      _cachedData = null; // Clear cached data on force refresh
    }

    final results = await Future.wait([
      fetchDepIndex(),
      _fetchDptList(),
    ]);

    if (results.contains(null)) {
      setState(() {
        _showNoInternetConnectionMessage = true;
      });
    } else {
      setState(() {
        _showNoInternetConnectionMessage = false;

        _showListData = Future.value(results[0] as FutureOr<DepartmentIndexModel>?);
        _showDepartmentListData = Future.value(results[1] as FutureOr<DepartmentIndexModel>?);

        /// Arefin
        _cachedData = results[1] as DepartmentIndexModel;
      });

      APICacheDBModel cacheDBModel = APICacheDBModel(
        key: 'Department Tab',
        syncData: jsonEncode((results[0] as DepartmentIndexModel).toJson()),
      );

      await APICacheManager().addCacheData(APICacheDBModel(
        key: 'Department List',
        syncData: jsonEncode((results[1] as DepartmentIndexModel).toJson()),
        // syncData: jsonEncode(freshData.toJson()),
      ));
      await APICacheManager().addCacheData(cacheDBModel);
    }
  }

  ///Root API For Department Tap
  Future<DepartmentIndexModel?> fetchDepIndex() async {
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
      var isCacheExist = await APICacheManager().isAPICacheKeyExist('Department Tab');
      if (!isCacheExist) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String _token = prefs.getString('token') ?? '';

        final String apiUrl = '${AppUrl.baseUrl}/api/app/department/index';
        final response = await https.get(Uri.parse(apiUrl), headers: {
          'Authorization': 'Bearer $_token',
        });
        print('URL: HIT_fetchDepIndex() from DepartmentListTabs.dart');
        if (response.statusCode == 200) {
          ///New Added
          APICacheDBModel cacheDBModel = new APICacheDBModel(key: 'Department Tab', syncData: response.body);
          await APICacheManager().addCacheData(cacheDBModel);

          return departmentIndexModelFromJson(response.body);
        } else {
          throw Exception('Failed to load day rate index');
        }
      } else {
        ///New Added
        var cacheData = await APICacheManager().getCacheData('Department Tab');
        print('CACHE: HIT_fetchDepIndex() from DepartmentListTabs.dart'); //Check Terminal
        return departmentIndexModelFromJson(cacheData.syncData);
      }
    }
  }

  /// Department List API
  // Store the data with Caching
  Future<DepartmentIndexModel> _fetchDptList() async {
    if (_cachedData != null) {
      print('Using cached data');
      return _cachedData!; // Return cached data if available
    }
    var freshDepListData = await fetchDepListIndex();
    _cachedData = freshDepListData; // Store fetched data in cache
    return freshDepListData;
  }

  // Call the API and Caching
  Future<DepartmentIndexModel> fetchDepListIndex() async {
    var isCachedExist = await APICacheManager().isAPICacheKeyExist('Department List');

    if (!isCachedExist) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String _token = prefs.getString('token') ?? '';

      final String apiUrl = '${AppUrl.baseUrl}/api/app/department/index';
      final response = await https.get(Uri.parse(apiUrl), headers: {
        'Authorization': 'Bearer $_token',
      });
      print('URL: HIT_fetchDepIndex() From department.dart');

      if (response.statusCode == 200) {
        APICacheDBModel cacheDBModel = new APICacheDBModel(key: 'Department List', syncData: response.body);
        await APICacheManager().addCacheData(cacheDBModel);

        print('Cached Data Added Sucessfully from fetchDepIndex()');
        return departmentIndexModelFromJson(response.body);
      } else {
        throw Exception('Failed to load day rate index');
      }
    } else {
      var cacheData = await APICacheManager().getCacheData('Department List');
      print('CACHE: HIT_fetchDepIndex() from department.dart');

      return departmentIndexModelFromJson(cacheData.syncData);
    }
  }

  // Delete Individual List (Department List)
  Future<void> deleteDeptIndex(String Slug) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';

    final String apiUrl = '${AppUrl.baseUrl}/api/app/department/delete/$Slug';
    final response = await https.get(Uri.parse(apiUrl), headers: {
      'Authorization': 'Bearer $_token',
    });

    if (response.statusCode == 200) {
      APICacheManager().deleteCache('Department List'); //delete previous cached Data
      _cachedData = null; // Clear cached data after deletion
      _refreshData(forceRefresh: true);

      print('Staff $Slug deleted successfully');
    } else {
      throw Exception('Failed to delete Dept Index: $Slug');
    }
  }

  Future<void> showConfirmationDialog(BuildContext context, Function() onConfirmed) async {
    double screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;

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
                Text('Are you sure you want to delete this department?'),
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
                // color:  AppColors.navButtonColor,
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
                // color:  AppColors.navOpacity,
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

  /// Add Department API
  // Add Department
  Future<void> _PostDept() async {
    setState(() {
      isLoading = true; // Set loading state to true
    });
    _deptNameValidationError = '';
    _LocationValidationError = '';
    _responsibilitiesValidationError = '';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';

    try {
      String apiUrl = '${AppUrl.baseUrl}/api/app/department/store';
      var request = https.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers.addAll({
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
      });

      request.fields['dept_name'] = _depName.text.toString();
      request.fields['location'] = _location.text.toString();
      request.fields['details'] = _details.text.toString();

      var response = await request.send();

      if (response.statusCode == 200) {
        print('Registration Successful');
        // setState(() {
        //   isLoading = false; // Set loading state to false after successful request
        // });
        _depName.clear();
        _location.clear();
        _details.clear();
        Utils.flushBarSuccessMessage("Data Submit Successfully", context);

        /// NEw Arefin
        await _refreshData(forceRefresh: true);
        setState(() {
          isLoading = false; // Set loading state to false after successful request
        });
      } else if (response.statusCode == 422) {
        // Parse and handle validation error response
        final Map<String, dynamic> responseData = jsonDecode(await response.stream.bytesToString());
        if (responseData.containsKey('errors')) {
          final Map<String, dynamic> errors = responseData['errors'];
          errors.forEach((field, messages) {
            final String errorMessage = messages.isNotEmpty ? messages.first : 'Unknown error';
            switch (field) {
              case 'dept_name':
                _deptNameValidationError = errorMessage;
                break;
              case 'location':
                _LocationValidationError = errorMessage;
                break;
              case 'details':
                _responsibilitiesValidationError = errorMessage;
                break;
            }
          });
          // Show error messages to the user
          setState(() {
            _validationErrors = {
              'dept_name': _deptNameValidationError,
              'location': _LocationValidationError,
              'details': _responsibilitiesValidationError,
            };
            isLoading = false;
          });
          String errorMessage = responseData['message'] ?? 'Failed';
          Utils.flushBarErrorMessage(errorMessage, context);
        } else {
          final Map<String, dynamic> responseData = jsonDecode(await response.stream.bytesToString());
          String errorMessage = responseData['message'] ?? 'Failed';
          Utils.flushBarErrorMessage(errorMessage, context);
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed to register. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error during registration: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userPrefernece = Provider.of<UserViewModel>(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: _showNoInternetConnectionMessage ? Colors.red : AppColors.navColor,
    ));

    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return FutureBuilder<DepartmentIndexModel?>(
      future: _showListData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: screenHeight * 0.9,
            width: screenWidth,
            color: AppColors.whiteColor,
            child: Center(child: LoadingScreen()),
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
        height: MediaQuery.of(context).size.height * .82,
        width: MediaQuery.of(context).size.width,
        child: _tabSection(context),
      ),
    ]));
  }

  _tabSection(BuildContext context) {

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
                      "Department List",
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
                        'Add Department',
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
                /** Department **/
                SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        Center(
                          child: FutureBuilder<DepartmentIndexModel?>(
                            future: _showDepartmentListData,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Container(
                                  height: screenHeight * 0.72,
                                  width: screenWidth,
                                  color: AppColors.whiteColor,
                                  child: Center(child: LoadingScreen()),
                                );
                              } else if (snapshot.hasError) {
                                return  Center(child: Text(""),);
                                // return Center(child: Text('Error: ${snapshot.error}'));
                              } else {
                                final deptIndex = snapshot.data?.data?.data;

                                if (deptIndex != null && deptIndex.isNotEmpty) {
                                  return Column(
                                    children: [
                                      // SizedBox(height: screenHeight * 0.013,),
                                      // Align(alignment: Alignment.centerLeft,
                                      //     child: Text("Create New Department",
                                      //       style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),)),
                                      // SizedBox(height: screenHeight * 0.013,),
                                      // Row(
                                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      //   children: [
                                      //     InkWell(
                                      //       onTap: (){
                                      //         Navigator.push(context, MaterialPageRoute(builder: (context)=>ADDdepartent()));
                                      //       },
                                      //       child: Container(
                                      //         height: screenHeight * 0.055,
                                      //         width: screenWidth * 0.45,
                                      //         decoration: BoxDecoration(
                                      //             borderRadius: BorderRadius.circular(10),
                                      //             border: Border.all(
                                      //               width: 0.2,
                                      //               color: AppColors.navButtonColor,
                                      //               // Color(0xff078C79)
                                      //             )
                                      //         ),
                                      //         child: Center(child: Text("Add Department", style: TextStyle(
                                      //             fontSize: 20,
                                      //             fontWeight: FontWeight.w500,
                                      //             letterSpacing: 1),)),
                                      //       ),
                                      //     ),
                                      //
                                      //     InkWell(
                                      //       onTap: (){
                                      //         Navigator.push(context, MaterialPageRoute(builder: (context)=>DepartMent()));
                                      //       },
                                      //       child: Container(
                                      //         height: screenHeight * 0.055,
                                      //         width: screenWidth * 0.45,
                                      //         decoration: BoxDecoration(
                                      //             color: AppColors.navButtonColor,
                                      //             // Color(0xff078C79).withOpacity(0.8),
                                      //             borderRadius: BorderRadius.circular(10),
                                      //             border: Border.all(
                                      //               width: 0.2,
                                      //               color:  AppColors.navButtonColor,
                                      //             )
                                      //         ),
                                      //         child: Center(child: Text("Department List", style: TextStyle(
                                      //             fontSize: 20,
                                      //             fontWeight: FontWeight.bold,
                                      //             color: AppColors.whiteColor,
                                      //             letterSpacing: 1),)),
                                      //       ),
                                      //     ),
                                      //   ],
                                      // ),
                                      // SizedBox(height: screenHeight * 0.013,),

                                      Container(
                                        width: screenWidth * 0.95,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(5),
                                            topRight: Radius.circular(5),
                                          ),
                                        ),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics: NeverScrollableScrollPhysics(),
                                          itemCount: deptIndex.length,
                                          itemBuilder: (context, index) {
                                            String DepName = deptIndex[index].deptName ?? "";
                                            if (DepName.isNotEmpty) {
                                              DepName = DepName[0].toUpperCase() + DepName.substring(1).toLowerCase();
                                            }

                                            String location = (deptIndex[index].location ?? "");
                                            if (location.isNotEmpty) {
                                              location =
                                                  location[0].toUpperCase() + location.substring(1).toLowerCase();
                                            }

                                            String responsi = deptIndex[index].details ?? "";
                                            if (responsi.isNotEmpty) {
                                              responsi =
                                                  responsi[0].toUpperCase() + responsi.substring(1).toLowerCase();
                                            }
                                            final textScreenWidth = MediaQuery.of(context).size.width;

                                            int responsiMaxLength = textScreenWidth > 600
                                                ? 20
                                                : 5; // Show more characters on larger screens

                                            final slug = deptIndex[index].slug;

                                            // if (responsi.length > 15) {
                                            //   responsi = '${responsi.substring(0, 15)}...';
                                            // }
                                            if (responsi.length > responsiMaxLength) {
                                              responsi = '${responsi.substring(0, responsiMaxLength)}...';
                                            }

                                            if (DepName.length > 15) {
                                              DepName = '${DepName.substring(0, 15)}...';
                                            }

                                            if (location.length > 18) {
                                              location = '${location.substring(0, 18)}';
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
                                                                  "Department Name",
                                                                  style: TextStyle(
                                                                      fontSize: 18, fontWeight: FontWeight.bold),
                                                                ),
                                                                Text(
                                                                  "$DepName",
                                                                  style: TextStyle(
                                                                      fontSize: 14, fontWeight: FontWeight.w400),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Icon(Icons.location_on),
                                                                SizedBox(
                                                                  width: screenWidth * 0.013,
                                                                ),
                                                                Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Text(
                                                                      "Location",
                                                                      style: TextStyle(
                                                                          fontSize: 18, fontWeight: FontWeight.bold),
                                                                    ),
                                                                    Text(
                                                                      "$location",
                                                                      style: TextStyle(
                                                                          fontSize: 14, fontWeight: FontWeight.w400),
                                                                    ),
                                                                  ],
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
                                                            GestureDetector(
                                                              onTapUp: (details) {
                                                                String? responsi = deptIndex[index].details;
                                                                if (responsi != null) {
                                                                  _showFullNamePopup(
                                                                      context, responsi, details.globalPosition);
                                                                }
                                                              },
                                                              child: Container(
                                                                height: screenHeight * 0.07,
                                                                width: screenWidth * 0.5,
                                                                child: Row(
                                                                  children: [
                                                                    Text(
                                                                      "Responsibilities",
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
                                                                      _removeHtmlTags("$responsi"),
                                                                      style: TextStyle(
                                                                          fontSize: 16,
                                                                          fontWeight: FontWeight.w500,
                                                                          color: AppColors.blackColor.withOpacity(0.6)),
                                                                      // Limit to one line on smaller screens
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
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
                                                                GestureDetector(
                                                                  onTap: () async {
                                                                    //  Utils.showDialogLoading(context);
                                                                    // await deleteDeptIndex(slug!);
                                                                    // Navigator.pop(context);
                                                                    showConfirmationDialog(context, () async {
                                                                      Utils.showDialogLoading(context);
                                                                      await deleteDeptIndex(slug!);
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
                                                                      "Delete",
                                                                      style: TextStyle(color: Colors.white),
                                                                    )),
                                                                  ),
                                                                )
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
                                      ),
                                      SizedBox(height: screenHeight * 0.1),
                                    ],
                                  );
                                } else {
                                  return Column(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: screenWidth * 0.1), // Add padding for responsiveness
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
                                                'No Departments Available',
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
                                                'Please add a new department to proceed.',
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

                /** Add Department**/
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Create New Department",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                            )),
                        SizedBox(
                          height: screenHeight * 0.013,
                        ),
                        SingleHeader(
                          context: context,
                          text: 'Department Name',
                          HintText: "Enter Department Name",
                          controllers: _depName,
                          keyboard: TextInputType.text,
                          iconData: Icons.account_balance_wallet_outlined,
                        ),
                        if (_deptNameValidationError.isNotEmpty)
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              _deptNameValidationError,
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
                        SingleHeader(
                          text: 'Location',
                          HintText: "Enter Location",
                          context: context,
                          controllers: _location,
                          keyboard: TextInputType.text,
                          iconData: Icons.location_on,
                        ),
                        if (_LocationValidationError.isNotEmpty)
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              _LocationValidationError,
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
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Responsibility",
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                                )),
                            Text(
                              ' *',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: screenHeight * 0.013,
                        ),
                        Container(
                          height: screenHeight * 0.15,
                          width: screenWidth * 0.95,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.navButtonColor, width: 0.4),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: TextFormField(
                            controller: _details,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              prefixIcon: Icon(
                                Icons.edit,
                                size: 20,
                              ),
                              border: InputBorder.none,
                              hintText: "Enter Responsibilities",
                              hintStyle: TextStyle(fontSize: 14),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                        if (_responsibilitiesValidationError.isNotEmpty)
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              _responsibilitiesValidationError,
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
                            await _PostDept();
                          },
                          child: Container(
                            height: screenHeight * 0.055,
                            width: screenWidth * 0.4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColors.navButtonColor,
                              // Colors.black,
                              // Color(0xff078C79),
                              border: Border.all(
                                width: 0.2,
                                color: AppColors.greyOpacity,
                                // Color(0xff078C79),
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
                        SizedBox(height: screenHeight * 0.1),
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

  ///Department Widgets

  String _removeHtmlTags(String htmlString) {
    final document = parse(htmlString);
    return parse(document.body!.text).documentElement!.text;
  }

  void _showFullNamePopup(BuildContext context, String fullName, Offset position) {
    // Capitalize the first letter of the name
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
            alignment: Alignment.center,
            child: Text(
              _removeHtmlTags(fullName),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Add Department
  Widget SingleHeader({
    String? text,
    required BuildContext context,
    required TextEditingController controllers,
    required TextInputType keyboard,
    IconData? iconData,
    String? HintText,
  }) {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (text != null) // Only add the Text widget if text is provided
              AutoSizeText(
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
          height: screenHeight * 0.013,
        ),
        Container(
          // height: screenHeight * 0.065,
          width: screenWidth * 0.95,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.navButtonColor, width: 0.4),
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextFormField(
            controller: controllers,
            keyboardType: keyboard,
            // textAlign: TextAlign.left,
            decoration: InputDecoration(
              prefixIcon: Icon(
                iconData,
                size: 20,
              ),
              border: InputBorder.none,
              hintText: HintText,
              hintStyle: TextStyle(fontSize: 14),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
