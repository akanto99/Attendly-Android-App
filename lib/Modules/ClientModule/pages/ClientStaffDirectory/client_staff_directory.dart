import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:c9_app/Modules/ClientModule/model/ProfileModel/clientProfileApiModel.dart';
import 'package:c9_app/Modules/ClientModule/pages/Profile_&_Setting/client_Profile.dart';
import 'package:c9_app/Modules/ClientModule/pages/noInternetConnectionWidget.dart';
import 'package:c9_app/loadingScreen.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/utils/routes/routes_name.dart';
import 'package:c9_app/view/widgets/error_logout.dart';
import 'package:c9_app/view_model/services/rolebasedmodel/user_view_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as https;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';

import '../../model/clientDirectoryModel/calculationModels/Active_InActive/ActiveClientModel.dart';
import '../../model/clientDirectoryModel/calculationModels/Active_InActive/inActiveClientModel.dart' as inActive;
import '../Calendar/calendar.dart';
import '../Client_Document/ViewFolder.dart';
import '../FullImageView.dart';
import 'calculations/BulkAction/bulkapproved_showlist.dart';
import 'calculations/WeekDataByClient/weekdataclients_new.dart';

String capitalizeFirstLetter(String? text) {
  if (text == null || text.isEmpty) return '';
  return text[0].toUpperCase() + text.substring(1);
}

class ClientStaffDirectory extends StatefulWidget {
  const ClientStaffDirectory({super.key});

  @override
  State<ClientStaffDirectory> createState() => _ClientStaffDirectoryState();
}

class _ClientStaffDirectoryState extends State<ClientStaffDirectory> with WidgetsBindingObserver {
  late Future<ClientProfileApiModel?> _userProfileFuture;
  bool _showNoInternetConnectionMessage = false;

  ///For Active Staff
  late Future<ActiveClientStaffModel?> _showActiveList;
  String selectedDepartmentName = 'Select';
  late String selectedDepartmentID;
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<String> _selectedLicenseTypes = [];

  ///For Previous staff
  late Future<inActive.InActiveClientModel?> _showInactiveList;

  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  /// New Added by Himu
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _setGreeting();
    _getCurrentDate();

    _userProfileFuture = fetchData();

    ///For Active Staff
    _showActiveList = fetchActiveClient();

    ///Fpr Inactive staff
    _showInactiveList = fetchInactiveClient();

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
      bool hasInternet = await _hasInternetConnection(); // Check internet access

      if (result != ConnectivityResult.none && hasInternet && _showNoInternetConnectionMessage) {
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
    if (state == AppLifecycleState.paused) {
      _refreshDataIfNeeded();

      // _refreshData(forceRefresh: true).then((_) {
      //   setState(() {});
      // });
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> _refreshDataIfNeeded() async {
    bool hasInternet = await _hasInternetConnection();

    if (hasInternet) {
      await _refreshData(forceRefresh: false); // Refresh data without forcing cache deletion
    } else {
      // Optionally handle the case where there's no internet connection
      setState(() {
        _showNoInternetConnectionMessage = true;
      });
    }
  }

  String greeting = "";
  // String name = "Sajjat";
  String currentDate = "";
  String currentTime = "";

  void _getCurrentDate() {
    currentDate = DateFormat('dd MMMM yyyy').format(DateTime.now());
  }

  void _setGreeting() {
    DateTime now = DateTime.now();
    int hour = now.hour;

    if (hour >= 5 && hour < 12) {
      greeting = "Good Morning";
    } else if (hour >= 12 && hour < 17) {
      greeting = "Good Afternoon";
    } else if (hour >= 17 && hour < 21) {
      greeting = "Good Evening";
    } else {
      greeting = "Good Night";
    }
  }

  Future<void> _refreshData({bool forceRefresh = false}) async {
    if (forceRefresh) {
      // Always delete the existing cache before fetching new data
      await APICacheManager().deleteCache('Client DashBoard'); // Ensure cache is deleted

      // Always delete the existing cache before fetching new data
      await APICacheManager().deleteCache('Active Client'); // Ensure cache is deleted
      await APICacheManager().deleteCache('Previous Client'); // Ensure cache is deleted
    }
    final results = await Future.wait([fetchData(), fetchActiveClient(), fetchInactiveClient()]);

    if (results.contains(null)) {
      setState(() {
        _showNoInternetConnectionMessage = true;
      });
    } else {
      setState(() {
        _showNoInternetConnectionMessage = false; // Data fetched successfully

        _userProfileFuture = Future.value(results[0] as FutureOr<ClientProfileApiModel>?);
        _showActiveList = Future.value(results[1] as FutureOr<ActiveClientStaffModel>?);
        _showInactiveList = Future.value(results[2] as FutureOr<inActive.InActiveClientModel>?);
      });

      // Cache the fetched data
      APICacheDBModel cacheDBModel = APICacheDBModel(
        key: 'Client DashBoard',
        syncData: jsonEncode((results[0] as ClientProfileApiModel).toJson()),
        // syncData: jsonEncode(freshData.toJson()),
      );
      await APICacheManager().addCacheData(APICacheDBModel(
        key: 'Active Client',
        syncData: jsonEncode((results[1] as ActiveClientStaffModel).toJson()),
      ));

      await APICacheManager().addCacheData(APICacheDBModel(
        key: 'Previous Client',
        syncData: jsonEncode((results[2] as inActive.InActiveClientModel).toJson()),
      ));

      await APICacheManager().addCacheData(cacheDBModel);
    }
  }

  ///For Active Staff
  Future<void> AssignDept(String departmentName, String slug) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';

    final url = Uri.parse('${AppUrl.baseUrl}/api/app/assign/department/$slug'); // Update URL with the slug

    final response = await https.post(
      url,
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'dept_slug': departmentName,
      }),
    );

    if (response.statusCode == 200) {
      // Data updated successfully, now refresh the relevant data
      await _refreshData(forceRefresh: true); // Force a refresh from the server

      setState(() {});

      // If the data is submitted successfully
      print('Data submitted successfully: ${response.body}');
      print('Slugs-----: $slug');
      print('Department slug id-----: $selectedDepartmentID');
      print('Dept Name-----: $selectedDepartmentName');
      print('Post deps Slug: $departmentName');
    } else {
      print('Failed to post Data: ${response.body}');
      print('Slugs-----: $slug');
      print('Department slug id-----: $selectedDepartmentID');
      print('Dept Name-----: $selectedDepartmentName');
      print('Post deps Slug: $departmentName');
    }
  }

  ///For Active Staff
  Future<void> PostDropDownData(String slug, List<String> selectedMethods) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';

    final url = Uri.parse('${AppUrl.baseUrl}/api/app/calculation/method/$slug');

    final response = await https.post(
      url,
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'calculation_method': selectedMethods,
      }),
    );

    if (response.statusCode == 200) {
      // Data updated successfully, now refresh the relevant data
      await _refreshData(forceRefresh: true); // Force a refresh from the server

      setState(() {});
    } else {
      print('Failed to post Data: ${response.body}');
    }
  }

  ///For Active Staff

  Future<ActiveClientStaffModel?> fetchActiveClient() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      // No internet connection
      setState(() {
        _showNoInternetConnectionMessage = true;
      });
      return null;
    } else {
      var isCacheExist = await APICacheManager().isAPICacheKeyExist('Active Client');
      if (!isCacheExist) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String _token = prefs.getString('token') ?? '';

        final String apiUrl = '${AppUrl.baseUrl}/api/app/index';
        final response = await https.get(Uri.parse(apiUrl), headers: {
          'Authorization': 'Bearer $_token',
        });

        print('URL: HIT_fetchActiveClient() From active.dart');

        if (response.statusCode == 200) {
          APICacheDBModel cacheDBModel = new APICacheDBModel(key: 'Active Client', syncData: response.body);
          await APICacheManager().addCacheData(cacheDBModel);
          print('Cached Data Added Successfully From fetchActiveClient()');
          return activeClientStaffModelFromJson(response.body);
        } else {
          throw Exception('Failed to load day rate index');
        }
      } else {
        var cacheData = await APICacheManager().getCacheData('Active Client');
        print('CACHE: HIT_fetchActiveClient() From active.dart');

        return activeClientStaffModelFromJson(cacheData.syncData);
      }
    }
  }

  ///For InActive Staff
  Future<inActive.InActiveClientModel?> fetchInactiveClient() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      // No internet connection
      setState(() {
        _showNoInternetConnectionMessage = true;
      });
      return null;
    } else {
      var isCacheExist = await APICacheManager().isAPICacheKeyExist('Previous Client');
      if (!isCacheExist) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String _token = prefs.getString('token') ?? '';

        final String apiUrl = '${AppUrl.baseUrl}/api/app/previous/staff';
        final response = await https.get(Uri.parse(apiUrl), headers: {
          'Authorization': 'Bearer $_token',
        });
        print('URL: HIT_fetchInActiveClient() From previous.dart');

        if (response.statusCode == 200) {
          APICacheDBModel cacheDBModel = new APICacheDBModel(key: 'Previous Client', syncData: response.body);
          await APICacheManager().addCacheData(cacheDBModel);

          return inActive.inActiveClientModelFromJson(response.body);
        } else {
          throw Exception('Failed to load day rate index');
        }
      } else {
        var cacheData = await APICacheManager().getCacheData('Previous Client');
        print('CACHE: HIT_fetchInActiveClient() From previous.dart');
        return inActive.inActiveClientModelFromJson(cacheData.syncData);
      }
    }
  }

  ///For Client DashBoard
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
      // Clear cache when a new user logs in
      var isCacheExist = await APICacheManager().isAPICacheKeyExist('Client DashBoard');

      if (!isCacheExist) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String _token = prefs.getString('token') ?? '';

        final String apiUrl = '${AppUrl.baseUrl}/api/app/staff/profile';
        final response = await https.get(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $_token',
          },
        );
        print('URL: HIT_fetchData() From client_staff-directory.dart');

        await APICacheManager().deleteCache('Client DashBoard'); // Ensure cache is deleted

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          if (responseData == null) {
            throw Exception('Response data is null');
          }

          ///New Added
          APICacheDBModel cacheDBModel = new APICacheDBModel(key: 'Client DashBoard', syncData: response.body);
          await APICacheManager().addCacheData(cacheDBModel);

          return ClientProfileApiModel.fromJson(responseData);
        } else {
          throw Exception('Failed to fetch user data. Status code: ${response.statusCode}');
        }
      } else {
        ///New Added
        var cacheData = await APICacheManager().getCacheData('Client DashBoard');
        final Map<String, dynamic> cachedResponseData = json.decode(cacheData.syncData);

        print('CACHE: HIT_fetchData() From client_staff-directory.dart'); //Check Terminal

        if (cachedResponseData == null) {
          throw Exception('Cached response data is null');
        }
        return ClientProfileApiModel.fromJson(cachedResponseData);
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
        body: UpgradeAlert(
          canDismissDialog: false,
          showLater: false,
          showIgnore: false,
          showReleaseNotes: false,
          upgrader: Upgrader(),
          child: RefreshIndicator(
            onRefresh: () => _refreshData(forceRefresh: true),
            child: _showNoInternetConnectionMessage
                ? NoInternetConnection()
                : ListView(
                    padding: EdgeInsets.zero, // Remove default padding

                    children: [
                      body(),
                    ],

                    // child: ResPonsiveUi(
                    //         mobile: body(),
                    //         desktop: body(),
                    //         tablet: body(),
                    //       ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget body() {
    final userPrefernece = Provider.of<UserViewModel>(context);
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: screenHeight * 0.013,
          ),
          FutureBuilder<ClientProfileApiModel?>(
            future: _userProfileFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: screenHeight * .9,
                  width: screenWidth,
                  color: AppColors.whiteColor,
                  child: Center(child: LoadingScreen()),
                );
              } else if (snapshot.hasError) {
                return Column(
                  children: [
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                    ErrorLogOutScreen(
                      screenHeight: screenHeight,
                      screenWidth: screenWidth,
                      errorMessage: 'Oops! Something went wrong.',
                      subMessage: 'Try logging out and back in.',
                      icon: CupertinoIcons.exclamationmark_circle,
                      buttonText: 'Logout',
                      onButtonPressed: () {
                        userPrefernece.remove().then((value) {
                          Navigator.pushNamed(context, RoutesName.login);
                        });
                      },
                    ),
                  ],
                );
              } else if (!snapshot.hasData) {
                return Center(child: Text('No user data found.'));
              } else {
                final ClientProfileApiModel profileData = snapshot.data!;
                final Data? profile = profileData.data;
                final String? profilePick = profileData.data?.image;
                final String? profileName = profileData.data?.name;
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: screenWidth * 0.03,
                            ),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "$greeting, ",
                                      // minFontSize: 8,
                                      // maxFontSize: 24,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 1,
                                          color: AppColors.navColor),
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: AutoSizeText(
                                        "${capitalizeFirstLetter(profileName?.split(' ').first)}",
                                        style: TextStyle(
                                            fontSize: 22, fontWeight: FontWeight.w500, color: AppColors.navColor),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 4,
                                        ),
                                        Text("$currentDate"
                                            // ,style: TextStyle(
                                            //   fontSize: 17,
                                            //   fontWeight: FontWeight.w500,
                                            //   color: Colors.black.withOpacity(0.8)),
                                            ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              width: screenWidth * 0.013,
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ClientProfile()));
                            },
                            child: Container(
                              height: screenHeight * 0.08,
                              width: screenWidth * 0.13,
                              decoration: BoxDecoration(
                                  color: AppColors.navOpacity,
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: AssetImage("images/c9LogoLatest.png"), fit: BoxFit.cover)),
                            ),
                          ),


                        ),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
          SizedBox(height: screenHeight * 0.023),
          Container(
            height: MediaQuery.of(context).size.height * .8,
            width: MediaQuery.of(context).size.width,
            child: _tabSection(context),
          ),
        ],
      ),
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

            /// Background
            color: Colors.white,
            child: TabBar(
              dividerColor: Colors.transparent,
              indicatorColor: AppColors.navOpacity,
              tabs: [
                Container(
                  width: screenWidth * 0.475,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.navButtonColor,
                  ),
                  child: Tab(
                    child: Text(
                      'Active Worker',
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
                Container(
                  width: screenWidth * 0.475,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.navButtonColor,
                  ),
                  child: Center(
                    child: Tab(
                      child: Text(
                        'Previous Worker',
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
                /// ActiveStaff(),
                SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Center(
                    child: Container(
                      width: screenWidth,
                      child: Column(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: screenHeight * 0.013,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: screenHeight * 0.055,
                                width: screenWidth * 0.15,
                                child: Icon(
                                  Icons.home,
                                  color: Colors.transparent,
                                ),
                              ),
                              Text(
                                "Active Worker",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                              ),
                              //Serachbar from this api function AssignClientList
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isSearching = !_isSearching;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  height: screenHeight * 0.055,
                                  width: _isSearching ? screenWidth * 0.5 : screenWidth * 0.15,
                                  decoration: BoxDecoration(
                                    color: AppColors.whiteColor, //Search background
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        offset: Offset(0, 2),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      bottomLeft: Radius.circular(20),
                                    ),
                                    border: Border.all(width: 0.4, color: AppColors.navColor // border background
                                        ),
                                  ),
                                  child: _isSearching
                                      ? Align(
                                          alignment: Alignment.centerLeft,
                                          child: TextFormField(
                                            controller: _searchController,
                                            textAlign: TextAlign.center,
                                            decoration: InputDecoration(
                                              hintText: 'Worker name or email',
                                              border: InputBorder.none,
                                            ),
                                            onChanged: (value) {
                                              setState(() {});
                                            },
                                          ),
                                        )
                                      : Icon(
                                          Icons.search,
                                          color: AppColors.navButtonColor,
                                        ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: screenHeight * 0.013,
                          ),
                          Center(
                            child: FutureBuilder<ActiveClientStaffModel?>(
                              future: _showActiveList,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Container(
                                    height: screenHeight * 0.55,
                                    width: screenWidth,
                                    color: AppColors.whiteColor,
                                    child: LoadingScreen(),
                                  );
                                } else if (snapshot.hasError) {
                                  return ErrorLogOutScreen(
                                    screenHeight: screenHeight * 0.8,
                                    screenWidth: screenWidth,
                                    errorMessage: 'Oops! Something went wrong.',
                                    subMessage: 'Try logging out and back in.',
                                    icon: CupertinoIcons.exclamationmark_circle,
                                    buttonText: 'Logout',
                                    onButtonPressed: () {
                                      userPrefernece.remove().then((value) {
                                        Navigator.pushNamed(context, RoutesName.login);
                                      });
                                    },
                                  );
                                  // return Center(child: Text('Error: ${snapshot.error}'));
                                } else {
                                  final ActiveClient = snapshot.data?.data;
                                  final DepartMents = snapshot.data?.the0;

                                  if (ActiveClient != null && ActiveClient.isNotEmpty) {
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: ActiveClient.length,
                                      itemBuilder: (context, index) {
                                        final email = ActiveClient[index].drivers?.email ?? "no info";
                                        final slug = ActiveClient[index].slug;
                                        final Driverslug = ActiveClient[index].driverSlug;
                                        final assignId = ActiveClient[index].assignmentNumber ?? "";
                                        final phone = ActiveClient[index].drivers?.phone ?? "no info";
                                        final gender = ActiveClient[index].drivers?.gender ?? "no info";
                                        final roleType = ActiveClient[index].drivers?.roleType ?? "no info";
                                        final dep = ActiveClient[index].deptSlug ?? "no info";
                                        final doc = ActiveClient[index].drivers?.file ?? "no info";
                                        final image = ActiveClient[index].drivers?.image ?? "no info";
                                        final breakTimes = ActiveClient[index].clients?.breakTime ?? "";
                                        final calculationMethodJson = ActiveClient[index].calculationMethod ?? "[]";
                                        final assignmentStartDate = ActiveClient[index].assignStartDate ?? "";
                                        final assignmentEndDate = ActiveClient[index].assignEndDate ?? "";
                                        final firstName = ActiveClient[index].drivers?.firstName?.toLowerCase() ?? "";
                                        final lastName = ActiveClient[index].drivers?.lastName?.toLowerCase() ?? "";
                                        final titleFirstName = ActiveClient[index].drivers?.firstName ?? "";
                                        final titleLastName = ActiveClient[index].drivers?.lastName ?? "";

                                        final fullName = "$titleFirstName $titleLastName";
                                        final limitedName = fullName.split(' ').take(2).join(' ');

                                        final truncatedEmail =
                                            email.length > 20 ? email.substring(0, 20) + "..." : email;

                                        // Get the first name and last name from the search query
                                        final searchQuery = _searchController.text.trim().toLowerCase();
                                        final List<String> searchParts = searchQuery.split(" ");
                                        String searchFirstName = searchParts.isNotEmpty ? searchParts[0] : "";
                                        String searchLastName =
                                            searchParts.length > 1 ? searchParts.sublist(1).join(" ") : "";

                                        // Check if either the first name or the last name contains the search query
                                        final firstNameMatches = firstName.trim().toLowerCase().contains(searchFirstName);
                                        final lastNameMatches = lastName.trim().toLowerCase().contains(searchLastName);

                                        final isMatch = firstName.contains(_searchController.text.toLowerCase()) ||
                                            lastName.contains(_searchController.text.toLowerCase()) ||
                                            firstNameMatches && lastNameMatches ||
                                            email.contains(_searchController.text.toLowerCase());

                                        List<String> calculationMethods = [];
                                        try {
                                          calculationMethods = List<String>.from(json.decode(calculationMethodJson));
                                        } catch (e) {
                                          // Handle the error if JSON parsing fails
                                          calculationMethods = [];
                                        }

                                        // Only display the item if it matches the search query
                                        if (_searchController.text.isEmpty || isMatch) {
                                          return Column(
                                            children: [
                                              Container(
                                                width: screenWidth * 0.90,
                                                decoration: BoxDecoration(
                                                  /// Active Staff Color
                                                  color: AppColors.whiteColor,
                                                  borderRadius: BorderRadius.circular(10), // Border radius
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey.withOpacity(0.2),
                                                      offset: Offset(0, 0),
                                                      blurRadius: 5,
                                                      spreadRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                  children: [
                                                    SizedBox(
                                                      height: screenHeight * 0.0013,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          left: 10.0, right: 10, top: 5, bottom: 5),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              GestureDetector(
                                                                onTap: () {
                                                                  Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (context) => FullScreenImage(
                                                                          imageUrl: '${AppUrl.clientDrivers}/$image'),
                                                                    ),
                                                                  );
                                                                },
                                                                child: Container(
                                                                  height: screenHeight * 0.05,
                                                                  width: screenWidth * 0.1,
                                                                  decoration: BoxDecoration(
                                                                    color: AppColors.navOpacity,
                                                                    shape: BoxShape.circle,
                                                                  ),
                                                                  child: Container(
                                                                    decoration: BoxDecoration(
                                                                      shape: BoxShape.circle,
                                                                      image: DecorationImage(
                                                                        image: NetworkImage(
                                                                          '${AppUrl.clientDrivers}/$image',
                                                                        ),
                                                                        fit: BoxFit
                                                                            .cover, // Adjust this to fit your needs
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: screenWidth * 0.03,
                                                              ),
                                                              Container(
                                                                height: screenHeight * 0.04,
                                                                width: screenWidth * 0.35,
                                                                child: AutoSizeText("$limitedName",
                                                                    minFontSize: 5,
                                                                    maxFontSize: 20,
                                                                    style: TextStyle(
                                                                      fontSize: 20,
                                                                      fontWeight: FontWeight.w600,
                                                                    )),
                                                              ),
                                                            ],
                                                          ),
                                                          Container(
                                                            height: screenHeight * 0.04,
                                                            width: screenWidth * 0.32,
                                                            decoration: BoxDecoration(
                                                              // color: AppColors.navOpacity,  // Active user ID background color
                                                              color: AppColors.navOpacity, // Active user ID background color
                                                              borderRadius: BorderRadius.circular(8),
                                                            ),
                                                            child: Center(
                                                                child: AutoSizeText(
                                                              assignId, minFontSize: 5, maxFontSize: 16,
                                                            )),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 10.0, right: 10),
                                                      child: Column(
                                                        children: [
                                                          SizedBox(
                                                            height: screenHeight * 0.007,
                                                          ),
                                                          RowData("Email", truncatedEmail),
                                                          SizedBox(
                                                            height: screenHeight * 0.013,
                                                          ),
                                                          RowData("Phone", phone),
                                                          SizedBox(
                                                            height: screenHeight * 0.013,
                                                          ),
                                                          RowData("Gender", gender),
                                                          SizedBox(
                                                            height: screenHeight * 0.013,
                                                          ),
                                                          RowData("Role", roleType),
                                                          SizedBox(
                                                            height: screenHeight * 0.013,
                                                          ),
                                                          // RowDept("Department", dep, DepartMents!, slug!),
                                                          // SizedBox(height: screenHeight * 0.013,),
                                                          GestureDetector(
                                                            onTap: () {
                                                              List<String> availableMethods = [];
                                                              List<String> allMethods = [
                                                                'Manual_Calculation',
                                                                'One_tap_Calculation',
                                                                'Period_Calculation'
                                                              ];

                                                              // Filter out the already selected methods from all methods
                                                              availableMethods = allMethods
                                                                  .where(
                                                                      (method) => !calculationMethods.contains(method))
                                                                  .toList();

                                                              showDialog(
                                                                context: context,
                                                                barrierDismissible: false,
                                                                builder: (BuildContextcontext) {
                                                                  return StatefulBuilder(
                                                                    builder: (context, setState) {
                                                                      return AlertDialog(
                                                                        // Dialog Box background color
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
                                                                        content: Container(
                                                                          width: MediaQuery.of(context).size.width,
                                                                          decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(10),
                                                                            color: Colors.white,
                                                                            // border: Border.all(
                                                                            //     width: 0.5,
                                                                            //     color: AppColors.navButtonColor
                                                                            // ),
                                                                          ),
                                                                          child: SingleChildScrollView(
                                                                            child: Column(
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              children: [
                                                                                Text('Selected Methods',
                                                                                    style: TextStyle(
                                                                                        fontSize: 18,
                                                                                        color: AppColors.blackColor)),
                                                                                ...calculationMethods.map((method) {
                                                                                  return CheckboxListTile(
                                                                                    title: Text(
                                                                                      replaceUnderscoreWithSpace(
                                                                                          method),
                                                                                      style: TextStyle(
                                                                                          color: AppColors.navColor),
                                                                                    ),
                                                                                    value: true,
                                                                                    activeColor: AppColors
                                                                                        .navColor, // Color when checked
                                                                                    checkColor: Colors.white,
                                                                                    onChanged: (bool? value) {
                                                                                      if (value == false) {
                                                                                        setState(() {
                                                                                          calculationMethods
                                                                                              .remove(method);
                                                                                          availableMethods.add(method);
                                                                                        });
                                                                                      }
                                                                                    },
                                                                                  );
                                                                                }).toList(),
                                                                                if (availableMethods.isNotEmpty)
                                                                                  Divider(
                                                                                    color: AppColors.navOpacity,
                                                                                  ),
                                                                                if (availableMethods.isNotEmpty)
                                                                                  Text('Available Methods',
                                                                                      style: TextStyle(
                                                                                          fontSize: 18,
                                                                                          color: AppColors.blackColor)),
                                                                                ...availableMethods.map((method) {
                                                                                  return CheckboxListTile(
                                                                                    title: Text(
                                                                                      replaceUnderscoreWithSpace(
                                                                                          method),
                                                                                      style: TextStyle(
                                                                                          color: Colors.green),
                                                                                    ),
                                                                                    value: _selectedLicenseTypes
                                                                                        .contains(method),
                                                                                    onChanged: (bool? value) {
                                                                                      setState(() {
                                                                                        if (value != null) {
                                                                                          if (value) {
                                                                                            _selectedLicenseTypes
                                                                                                .add(method);
                                                                                          } else {
                                                                                            _selectedLicenseTypes
                                                                                                .remove(method);
                                                                                          }
                                                                                        }
                                                                                      });
                                                                                    },
                                                                                  );
                                                                                }).toList(),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        actions: <Widget>[
                                                                          InkWell(
                                                                            onTap: () {
                                                                              setState(() {
                                                                                _selectedLicenseTypes.clear();
                                                                              });
                                                                              Navigator.pop(context);
                                                                            },
                                                                            child: Container(
                                                                              width: screenWidth * 0.2,
                                                                              padding: EdgeInsets.symmetric(
                                                                                  vertical: screenHeight * 0.011,
                                                                                  horizontal: screenWidth * 0.011),
                                                                              decoration: BoxDecoration(
                                                                                color: AppColors.navButtonColor,
                                                                                borderRadius: BorderRadius.circular(15),
                                                                              ),
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.all(5.0),
                                                                                child: Center(
                                                                                  child: Text(
                                                                                    'Close',
                                                                                    style: TextStyle(
                                                                                      color: Colors.white,
                                                                                      fontSize: 15,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      letterSpacing: 1,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          InkWell(
                                                                            onTap: () {
                                                                              setState(() {
                                                                                calculationMethods
                                                                                    .addAll(_selectedLicenseTypes);
                                                                                availableMethods.removeWhere((method) =>
                                                                                    _selectedLicenseTypes
                                                                                        .contains(method));
                                                                                PostDropDownData(
                                                                                    slug!, calculationMethods);
                                                                                _selectedLicenseTypes.clear();
                                                                              });
                                                                              Navigator.pop(context);
                                                                            },
                                                                            child: Container(
                                                                              width: screenWidth * 0.3,
                                                                              padding: EdgeInsets.symmetric(
                                                                                vertical: screenHeight * 0.011,
                                                                              ),
                                                                              decoration: BoxDecoration(
                                                                                color: AppColors.navOpacity,
                                                                                borderRadius: BorderRadius.circular(15),
                                                                              ),
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.all(5.0),
                                                                                child: Center(
                                                                                  child: Text(
                                                                                    'Save Changes',
                                                                                    style: TextStyle(
                                                                                      color: Colors.black,
                                                                                      fontSize: 15,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      letterSpacing: 1,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      );
                                                                    },
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            child: Container(
                                                              width: screenWidth * 0.90,
                                                              child: Row(
                                                                children: [
                                                                  Container(
                                                                    height: screenHeight * 0.06,
                                                                    width: screenWidth * 0.25,
                                                                    child: Align(
                                                                      alignment: Alignment.centerLeft,
                                                                      child: AutoSizeText(
                                                                        "Default Timesheet",
                                                                        style: TextStyle(
                                                                          fontSize: 20,
                                                                          fontWeight: FontWeight.w400,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: screenWidth * 0.023,
                                                                  ),
                                                                  Container(
                                                                    height: screenHeight * 0.03,
                                                                    width: 1,
                                                                    color: Colors.grey,
                                                                  ),
                                                                  SizedBox(
                                                                    width: screenWidth * 0.023,
                                                                  ),
                                                                  Align(
                                                                    alignment: Alignment.centerLeft,
                                                                    child: calculationMethods.isEmpty
                                                                        ? Container(
                                                                            height: screenHeight * 0.03,
                                                                            width: screenWidth * 0.5,
                                                                            color: Colors.white,
                                                                            child: Row(
                                                                              children: [
                                                                                Align(
                                                                                    alignment: Alignment.centerLeft,
                                                                                    child: AutoSizeText(
                                                                                      "empty",
                                                                                      style: TextStyle(
                                                                                          fontSize: 18,
                                                                                          color: AppColors.blackColor
                                                                                              .withOpacity(0.6)),
                                                                                    )),
                                                                                SizedBox(
                                                                                  width: screenWidth * 0.029,
                                                                                ),
                                                                                Icon(Icons.tab_unselected),
                                                                              ],
                                                                            ))
                                                                        : Container(
                                                                            // height: screenHeight * (0.03* calculationMethods.length),
                                                                            width: screenWidth * 0.5,
                                                                            // color: Colors.green,
                                                                            child: Row(
                                                                              children: [
                                                                                Column(
                                                                                  crossAxisAlignment:
                                                                                      CrossAxisAlignment.start,
                                                                                  mainAxisAlignment:
                                                                                      MainAxisAlignment.center,
                                                                                  children: calculationMethods
                                                                                      .map((method) => AutoSizeText(
                                                                                            replaceUnderscoreWithSpace(
                                                                                                method),
                                                                                            style: TextStyle(
                                                                                              fontSize: 15,
                                                                                              color: AppColors
                                                                                                  .blackColor
                                                                                                  .withOpacity(0.6),
                                                                                            ),
                                                                                          ))
                                                                                      .toList(),
                                                                                ),
                                                                                SizedBox(
                                                                                  width: screenWidth * 0.02,
                                                                                ),
                                                                                Icon(
                                                                                  Icons.settings_applications_sharp,
                                                                                  color: AppColors.navColor,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: screenHeight * 0.013,
                                                          ),

                                                          SizedBox(
                                                            height: screenHeight * 0.01,
                                                          ),
                                                          _rateDetails(ActiveClient[index]),
                                                          SizedBox(
                                                            height: screenHeight * 0.013,
                                                          ),

                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              InkWell(
                                                                onTap: () {
                                                                  // Convert assignmentStartDate and assignmentEndDate to DateTime
                                                                  final DateTime? startDate =
                                                                      DateTime.tryParse(assignmentStartDate);
                                                                  final DateTime? endDate =
                                                                      DateTime.tryParse(assignmentEndDate);

                                                                  // Get the current date
                                                                  final DateTime currentDate = DateTime.now();

                                                                  // Check the conditions for navigating
                                                                  if (startDate != null && endDate != null) {
                                                                    if (currentDate.isBefore(startDate)) {
                                                                      ScaffoldMessenger.of(context)
                                                                          .showSnackBar(SnackBar(
                                                                        duration: Duration(seconds: 2),
                                                                        content: Text(
                                                                          'The assignment has not started yet!',
                                                                          style: TextStyle(
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.w400,
                                                                              color: Colors.white),
                                                                        ),
                                                                        backgroundColor: Colors.redAccent,
                                                                      ));
                                                                    } else if (currentDate.isAfter(endDate)) {
                                                                      ScaffoldMessenger.of(context)
                                                                          .showSnackBar(SnackBar(
                                                                        duration: Duration(seconds: 2),
                                                                        content: Text(
                                                                          'The assignment has already expired!',
                                                                          style: TextStyle(
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.w400,
                                                                              color: Colors.white),
                                                                        ),
                                                                        backgroundColor: Colors.redAccent,
                                                                      ));
                                                                    } else {
                                                                      final driversSlug =
                                                                          ActiveClient[index].driverSlug;
                                                                      final selectedEmail =
                                                                          ActiveClient[index].clients?.email;
                                                                      final selectedCompany =
                                                                          ActiveClient[index].clients?.companyName;
                                                                      final selectedImage =
                                                                          ActiveClient[index].clients?.image;
                                                                      final selectedStatus =
                                                                          ActiveClient[index].clients?.status;

                                                                      Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (context) => BulkApproveshowlist(
                                                                            driversSlug: driversSlug,
                                                                            email: selectedEmail,
                                                                            companyName: selectedCompany,
                                                                            images: selectedImage,
                                                                            status: selectedStatus,
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }
                                                                  } else {
                                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                      duration: Duration(seconds: 2),
                                                                      content: Text(
                                                                        'Assignment dates are not available!',
                                                                        style: TextStyle(
                                                                            fontSize: 16,
                                                                            fontWeight: FontWeight.w400,
                                                                            color: Colors.white),
                                                                      ),
                                                                      backgroundColor: Colors.redAccent,
                                                                    ));
                                                                  }
                                                                },
                                                                child: Container(
                                                                  height: screenHeight * 0.04,
                                                                  width: screenWidth * 0.27,
                                                                  decoration: BoxDecoration(
                                                                    color: AppColors.navButtonColor,
                                                                    borderRadius: BorderRadius.circular(5),
                                                                  ),
                                                                  child: Center(
                                                                    child: Text(
                                                                      "Bulk Actions",
                                                                      style: TextStyle(
                                                                          color: Colors.white,
                                                                          fontWeight: FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),

                                                          SizedBox(
                                                            height: screenHeight * 0.013,
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ), // Replace YourChildWidget with your actual widget
                                              ),
                                              SizedBox(
                                                height: screenHeight * 0.03,
                                              ),
                                            ],
                                          );
                                        } else {
                                          return Container();
                                        }
                                      },
                                    );
                                  } else {
                                    return Center(
                                      child: Align(
                                        alignment: Alignment(
                                            0.0, -0.3), // Adjust the vertical position (-1.0 is top, 1.0 is bottom)
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                                          height: screenHeight * 0.7,
                                          width: screenWidth,
                                          color: AppColors.whiteColor,
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.group, // Icon to represent staff
                                                  color: AppColors.navColor,
                                                  size: screenWidth * 0.12,
                                                ),
                                                SizedBox(
                                                  height: screenHeight * 0.02,
                                                ),
                                                Text(
                                                  'No Active Worker Available',
                                                  style: TextStyle(
                                                    fontSize: screenWidth * 0.045,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.navColor,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                SizedBox(
                                                  height: screenHeight * 0.01,
                                                ),
                                                Text(
                                                  'Please assign Worker or check their status.',
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
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                /** Previous Staff **/
                SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Center(
                    child: Container(
                      width: screenWidth,
                      child: Column(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: screenHeight * 0.013,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: screenHeight * 0.055,
                                width: screenWidth * 0.15,
                                child: Icon(
                                  Icons.home,
                                  color: Colors.transparent,
                                ),
                              ),
                              Text(
                                "Previous Worker",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                              ),
                              //Serachbar from this api function AssignClientList
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isSearching = !_isSearching;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  height: screenHeight * 0.055,
                                  width: _isSearching ? screenWidth * 0.5 : screenWidth * 0.15,
                                  decoration: BoxDecoration(
                                    color: AppColors.whiteColor,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        offset: Offset(0, 2),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      bottomLeft: Radius.circular(20),
                                    ),
                                    border: Border.all(width: 0.4, color: AppColors.navColor),
                                  ),
                                  child: _isSearching
                                      ? Align(
                                          alignment: Alignment.centerLeft,
                                          child: TextFormField(
                                            controller: _searchController,
                                            textAlign: TextAlign.center,
                                            decoration: InputDecoration(
                                              hintText: 'Worker name or email',
                                              border: InputBorder.none,
                                            ),
                                            onChanged: (value) {
                                              setState(() {});
                                            },
                                          ),
                                        )
                                      : Icon(
                                          Icons.search,
                                          color: AppColors.navButtonColor,
                                        ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: screenHeight * 0.013,
                          ),
                          Center(
                            child: FutureBuilder<inActive.InActiveClientModel?>(
                              future: _showInactiveList,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Container(
                                    height: screenHeight * 0.55,
                                    width: screenWidth,
                                    color: AppColors.whiteColor,
                                    child: LoadingScreen(),
                                  );
                                } else if (snapshot.hasError) {
                                  return ErrorLogOutScreen(
                                    screenHeight: screenHeight * 0.8,
                                    screenWidth: screenWidth,
                                    errorMessage: 'Oops! Something went wrong.',
                                    subMessage: 'Try logging out and back in.',
                                    icon: CupertinoIcons.exclamationmark_circle,
                                    buttonText: 'Logout',
                                    onButtonPressed: () {
                                      userPrefernece.remove().then((value) {
                                        Navigator.pushNamed(context, RoutesName.login);
                                      });
                                    },
                                  );
                                  // return Center(child: Text('Error: ${snapshot.error}'));
                                } else {
                                  final InActiveClient = snapshot.data?.data;

                                  if (InActiveClient != null && InActiveClient.isNotEmpty) {
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: InActiveClient.length,
                                      itemBuilder: (context, index) {
                                        // final Firstname = InActiveClient[index].drivers?.firstName?? "no";
                                        // final Lastname = InActiveClient[index].drivers?.lastName?? "no";
                                        final Firstname = InActiveClient[index].drivers?.firstName?.toLowerCase() ?? "";
                                        final Lastname = InActiveClient[index].drivers?.lastName?.toLowerCase() ?? "";
                                        final email = InActiveClient[index].drivers?.email ?? "no info";
                                        final phone = InActiveClient[index].drivers?.phone ?? "no info";
                                        final gender = InActiveClient[index].drivers?.gender ?? "no info";
                                        final staff = InActiveClient[index].drivers?.driverType ?? "no info";
                                        final image = InActiveClient[index].drivers?.image ?? "";
                                        final assignNumber = InActiveClient[index].AssignmentNumber ?? "";
                                        // final slug = InActiveClient[index].slug;
                                        final titleFirstName = InActiveClient[index].drivers?.firstName ?? "";
                                        final titleLastName = InActiveClient[index].drivers?.lastName ?? "";

                                        final fullName = "$titleFirstName $titleLastName";
                                        final limitedName = fullName.split(' ').take(2).join(' ');
                                        // Get the first name and last name from the search query
                                        final searchQuery = _searchController.text.trim().toLowerCase();
                                        final List<String> searchParts = searchQuery.split(" ");
                                        String searchFirstName = searchParts.isNotEmpty ? searchParts[0] : "";
                                        String searchLastName =
                                            searchParts.length > 1 ? searchParts.sublist(1).join(" ") : "";

                                        // Check if either the first name or the last name contains the search query
                                        final firstNameMatches =
                                            Firstname.trim().toLowerCase().contains(searchFirstName);
                                        final lastNameMatches = Lastname.trim().toLowerCase().contains(searchLastName);

                                        final isMatch = Firstname.contains(_searchController.text.toLowerCase()) ||
                                            Lastname.contains(_searchController.text.toLowerCase()) ||
                                            firstNameMatches && lastNameMatches ||
                                            email.contains(_searchController.text.toLowerCase());

                                        if (_searchController.text.isEmpty || isMatch) {
                                          return Column(
                                            children: [
                                              Container(
                                                width: screenWidth * 0.90,
                                                decoration: BoxDecoration(
                                                  color: AppColors.whiteColor,
                                                  borderRadius: BorderRadius.circular(10), // Border radius
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: AppColors.greyOpacity,
                                                      offset: Offset(0, 2),
                                                      blurRadius: 5,
                                                      spreadRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                  children: [
                                                    SizedBox(
                                                      height: screenHeight * 0.007,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 10.0, right: 10),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              GestureDetector(
                                                                onTap: () {
                                                                  Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (context) => FullScreenImage(
                                                                          imageUrl:
                                                                              '${AppUrl.baseUrl}/backend/logo/$image'),
                                                                    ),
                                                                  );
                                                                },
                                                                child: Container(
                                                                  height: screenHeight * 0.05,
                                                                  width: screenWidth * 0.1,
                                                                  decoration: BoxDecoration(
                                                                    color: AppColors.navOpacity,
                                                                    shape: BoxShape.circle,
                                                                  ),
                                                                  child: Container(
                                                                    decoration: BoxDecoration(
                                                                      shape: BoxShape.circle,
                                                                      image: DecorationImage(
                                                                        image: NetworkImage(
                                                                          '${AppUrl.baseUrl}/backend/logo/$image',
                                                                        ),
                                                                        fit: BoxFit
                                                                            .cover, // Adjust this to fit your needs
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: screenWidth * 0.03,
                                                              ),
                                                              Container(
                                                                height: screenHeight * 0.04,
                                                                width: screenWidth * 0.35,
                                                                child: AutoSizeText("$limitedName",
                                                                    minFontSize: 5,
                                                                    maxFontSize: 20,
                                                                    style: TextStyle(
                                                                      fontSize: 20,
                                                                      fontWeight: FontWeight.w600,
                                                                    )),
                                                              ),
                                                            ],
                                                          ),
                                                          Container(
                                                            height: screenHeight * 0.04,
                                                            width: screenWidth * 0.32,
                                                            decoration: BoxDecoration(
                                                                color: AppColors.navOpacity,
                                                                borderRadius: BorderRadius.circular(8)),
                                                            child: Center(
                                                              child: AutoSizeText(
                                                                '$assignNumber',
                                                                minFontSize: 5,
                                                                maxFontSize: 16,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: screenHeight * 0.007,
                                                    ),
                                                    RowData("Name", '$Firstname $Lastname'),
                                                    SizedBox(
                                                      height: screenHeight * 0.013,
                                                    ),
                                                    RowData("Email", email),
                                                    SizedBox(
                                                      height: screenHeight * 0.013,
                                                    ),
                                                    RowData("Phone", phone),
                                                    SizedBox(
                                                      height: screenHeight * 0.013,
                                                    ),
                                                    RowData(
                                                      "Gender",
                                                      gender,
                                                    ),
                                                    SizedBox(
                                                      height: screenHeight * 0.013,
                                                    ),
                                                    RowData("Staff", staff),
                                                    SizedBox(
                                                      height: screenHeight * 0.01,
                                                    ),
                                                  ],
                                                ), // Replace YourChildWidget with your actual widget
                                              ),
                                              SizedBox(
                                                height: screenHeight * 0.023,
                                              ),
                                            ],
                                          );
                                        } else {
                                          return Container();
                                        }
                                      },
                                    );
                                  } else {
                                    return Center(
                                      child: Align(
                                        alignment: Alignment(
                                            0.0, -0.3), // Adjust the vertical position (-1.0 is top, 1.0 is bottom)
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                                          height: screenHeight * 0.7,
                                          width: screenWidth,
                                          color: AppColors.whiteColor,
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.person_off, // Icon to represent staff
                                                  color: AppColors.navColor,
                                                  size: screenWidth * 0.12,
                                                ),
                                                SizedBox(
                                                  height: screenHeight * 0.02,
                                                ),
                                                Text(
                                                  'No Previous Worker Available',
                                                  style: TextStyle(
                                                    fontSize: screenWidth * 0.045,
                                                    color: AppColors.navColor,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                SizedBox(
                                                  height: screenHeight * 0.01,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.1,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  String replaceUnderscoreWithSpace(String input) {
    return input.replaceAll('_', ' ');
  }

  String getDepartmentName(String deptSlug, List<The0> departments) {
    final department = departments.firstWhere((dept) => dept.slug == deptSlug, orElse: () => The0());
    return department.deptName ?? "Unknown Department";
  }

  Widget RowData(String text, String text2) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return Container(
      width: screenWidth * 0.90,
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              height: screenHeight * 0.03,
              width: screenWidth * 0.25,
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: AutoSizeText(
                    text,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                  ))),
          SizedBox(
            width: screenWidth * 0.023,
          ),
          Container(
            height: screenHeight * 0.03,
            width: 1,
            color: Colors.grey,
          ),
          SizedBox(
            width: screenWidth * 0.023,
          ),
          Expanded(
            flex: 1,
            child: Container(
                height: screenHeight * 0.03,
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: AutoSizeText(
                      text2,
                      style: TextStyle(fontSize: 18, color: AppColors.blackColor.withOpacity(0.6)),
                    ))),
          ),
        ],
      ),
    );
  }

  Widget RowDept(String text, String text2, List<The0> departments, String slug) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final correspondingName = getDepartmentName(text2, departments);
    List<String?> departmentNames = departments.map((department) => department.deptName).toList();
    List<String?> departmentIDs = departments.map((department) => department.slug).toList();
    departmentNames = departmentNames.toSet().toList();
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
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
                    borderRadius: BorderRadius.circular(5),
                  ),
                  title: Text(
                    'Select Department',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  content: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                      border: Border.all(width: 0.5, color: AppColors.navButtonColor),
                    ),
                    child: DropdownButton<String>(
                      hint: Padding(
                        padding: const EdgeInsets.only(left: 13.0),
                        child: Text("Select"),
                      ),
                      value: selectedDepartmentName,
                      onChanged: (newValue) {
                        setState(() {
                          selectedDepartmentName = newValue!;
                          // Update selectedDepartmentID based on selectedDepartmentName
                          selectedDepartmentID = departmentIDs[departmentNames.indexOf(newValue)]!;
                        });
                      },
                      items: <DropdownMenuItem<String>>[
                        DropdownMenuItem<String>(
                          value: 'Select',
                          child: Padding(
                            padding: const EdgeInsets.only(left: 13.0),
                            child: Text("Select"),
                          ),
                        ),
                        ...departmentNames.map((DeptName) {
                          return DropdownMenuItem<String>(
                            value: DeptName!,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 13.0),
                              child: Text(
                                DeptName,
                              ),
                            ),
                          );
                        }),
                      ],
                      icon: SizedBox(),
                      underline: Container(),
                    ),
                  ),
                  actions: <Widget>[
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
                          color: AppColors.navButtonColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Center(
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        AssignDept(selectedDepartmentID.toString(), slug);
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
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Center(
                            child: Text(
                              'Submit',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
      child: Container(
        width: screenWidth * 0.90,
        child: Row(
          children: [
            Container(
              height: screenHeight * 0.03,
              width: screenWidth * 0.25,
              child: Align(
                alignment: Alignment.centerLeft,
                child: AutoSizeText(text,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    )),
              ),
            ),
            SizedBox(
              width: screenWidth * 0.023,
            ),
            Container(
              height: screenHeight * 0.03,
              width: 1,
              color: Colors.grey,
            ),
            SizedBox(
              width: screenWidth * 0.023,
            ),
            Container(
              height: screenHeight * 0.03,
              child: Align(
                alignment: Alignment.centerLeft,
                child: AutoSizeText(correspondingName,
                    style: TextStyle(fontSize: 18, color: AppColors.blackColor.withOpacity(0.6))),
              ),
            ),
            SizedBox(
              width: screenWidth * 0.023,
            ),
            Icon(
              Icons.assistant_direction,
              color: Colors.grey,
            )
          ],
        ),
      ),
    );
  }

  Widget _rateDetails(Datum data) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    DateTime? assignmentStartDate;
    DateTime? assignmentEndDate;

    // Safely parse nullable dates
    if (data.assignStartDate != null && data.assignStartDate!.isNotEmpty) {
      assignmentStartDate = dateFormat.parse(data.assignStartDate!);
    }

    if (data.assignEndDate != null && data.assignEndDate!.isNotEmpty) {
      assignmentEndDate = dateFormat.parse(data.assignEndDate!);
    }

    final DateTime currentDate = DateTime.now();

    return Container(
      width: screenWidth * 0.90,
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Timesheets Button
          Expanded(
            // Use Expanded for responsiveness
            child: InkWell(
              onTap: () {
                if (assignmentStartDate != null && assignmentEndDate != null) {
                  if (currentDate.isBefore(assignmentStartDate)) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      duration: Duration(seconds: 2),
                      content: Text(
                        'The assignment has not started yet!',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),
                      ),
                      backgroundColor: Colors.redAccent,
                    ));
                  } else if (currentDate.isAfter(assignmentEndDate)) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      duration: Duration(seconds: 2),
                      content: Text(
                        'The assignment has already expired!',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),
                      ),
                      backgroundColor: Colors.redAccent,
                    ));
                  } else {
                    final selectedSlug = '${data.slug}';
                    final selectedStartTime = '${data.startTime}';
                    final selectedEndTime = '${data.endTime}';
                    final selectedDriverSlug = '${data.driverSlug}';
                    final selectedEmail = '${data.clients?.email}';
                    final selectedCompany = '${data.clients?.companyName}';
                    final selectedImage = '${data.clients?.image}';
                    final selectedBreak = '${data.clients?.breakTime}';
                    final selectedAssignStartDate = '$assignmentStartDate';
                    final selectedAssignEndDate = '$assignmentEndDate';

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WeekDataClientListNew(
                          slug: selectedSlug,
                          stTime: selectedStartTime,
                          enTime: selectedEndTime,
                          driverSlug: selectedDriverSlug,
                          email: selectedEmail,
                          companyName: selectedCompany,
                          images: selectedImage,
                          breakTimes: selectedBreak,
                          assignStartDate: selectedAssignStartDate,
                          assignEndDate: selectedAssignEndDate,
                        ),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    duration: Duration(seconds: 2),
                    content: Text(
                      'Assignment dates are not available!',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),
                    ),
                    backgroundColor: Colors.redAccent,
                  ));
                }
              },
              child: Container(
                height: screenHeight * 0.04,
                decoration: BoxDecoration(
                  color: AppColors.navButtonColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Text(
                    "Timesheets",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(width: screenWidth * 0.023),

          // Availability Button
          Expanded(
            // Use Expanded for responsiveness
            child: InkWell(
              onTap: () {
                final selectedID = '${data.drivers?.id}';
                print('Received data from IndividualView:${data.id}');

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClientCalendar(id: selectedID),
                  ),
                ).then((value) {
                  if (value != null) {
                    print('Received data from IndividualView: $value');
                  }
                });
              },
              child: Container(
                height: screenHeight * 0.04,
                decoration: BoxDecoration(
                  color: AppColors.navButtonColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                    child: Text("Availability", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              ),
            ),
          ),

          SizedBox(width: screenWidth * 0.023),

          // Files Button
          Expanded(
            // Use Expanded for responsiveness
            child: GestureDetector(
              onTap: () {
                final selectedSlug = data.driverSlug!;
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => UploadFileClientfNew(slug: selectedSlug)));
                print("File View Slug - $selectedSlug");
              },
              child: Container(
                height: screenHeight * 0.04,
                decoration: BoxDecoration(
                  color: AppColors.navButtonColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(child: Text("Files", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
