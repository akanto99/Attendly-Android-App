import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:c9_app/Modules/ClientModule/pages/noInternetConnectionWidget.dart';
import 'package:c9_app/Modules/StaffModule/Assignment/assignment_Action/WeekDataByStaff/weekdataStaffs_new.dart';
import 'package:c9_app/Modules/StaffModule/DashBoard/staff_navigationScreen.dart';
import 'package:c9_app/Modules/StaffModule/MODEL/assignmentModel/assignmentClientModelClass.dart';
import 'package:c9_app/Modules/StaffModule/MODEL/assignmentModel/view_departmentModel.dart';
import 'package:c9_app/Modules/StaffModule/fullViewImageStaff.dart';
import 'package:c9_app/loadingScreen.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/utils/routes/routes_name.dart';
import 'package:c9_app/utils/utils.dart';
import 'package:c9_app/view/widgets/error_logout.dart';
import 'package:c9_app/view/widgets/header_widgets.dart';
import 'package:c9_app/view_model/services/rolebasedmodel/user_view_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as https;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StaffAssignmentNew extends StatefulWidget {
  const StaffAssignmentNew({Key? key}) : super(key: key);

  @override
  State<StaffAssignmentNew> createState() => _StaffAssignmentNewState();
}

class _StaffAssignmentNewState extends State<StaffAssignmentNew> with WidgetsBindingObserver {
  late Future<AssignMentClientModel?> _showAssignList;
  late int currentPage;
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool _showNoInternetConnectionMessage = false;

  ///NEw Added
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    currentPage = 1;
    _showAssignList = AssignClientList(currentPage);
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

  ///NEw Added
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription.cancel(); // Cancel subscription

    super.dispose();
  }

  ///NEw Added
  @override
  didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _refreshData(forceRefresh: true);
    }
    super.didChangeAppLifecycleState(state);
  }

  ///NEw Added
  Future<void> _refreshData({bool forceRefresh = false}) async {
    if (forceRefresh) {
      APICacheManager().deleteCache('Clients List');
    }
    var freshData = await AssignClientList(currentPage);

    if (freshData != null) {
      setState(() {
        _showAssignList = Future.value(freshData);
      });
      APICacheDBModel cacheDBModel = APICacheDBModel(key: 'Clients List', syncData: jsonEncode(freshData.toJson()));
      await APICacheManager().addCacheData(cacheDBModel);
    } else {
      setState(() {
        _showNoInternetConnectionMessage = true;
      });
    }
  }

  ///NEw Added
  Future<AssignMentClientModel?> AssignClientList(int page) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    bool hasInternet = await _hasInternetConnection();

    if (connectivityResult == ConnectivityResult.none || !hasInternet) {
      // No internet connection
      setState(() {
        _showNoInternetConnectionMessage = true;
      });
      return null;
    } else {
      var isCachedExist = await APICacheManager().isAPICacheKeyExist('Clients List');

      if (!isCachedExist) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String _token = prefs.getString('token') ?? '';

        final String apiUrl = '${AppUrl.baseUrl}/api/app/active/staff/index?page=$page';
        final response = await https.get(Uri.parse(apiUrl), headers: {
          'Authorization': 'Bearer $_token',
        });
        await APICacheManager().deleteCache('Clients List');
        if (response.statusCode == 200) {
          APICacheDBModel cacheDBModel = new APICacheDBModel(key: 'Clients List', syncData: response.body);
          await APICacheManager().addCacheData(cacheDBModel);

          return assignMentClientModelFromJson(response.body);
        } else {
          throw Exception('Failed to load day rate index');
        }
      } else {
        var cacheData = await APICacheManager().getCacheData('Clients List');
        return assignMentClientModelFromJson(cacheData.syncData);
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
        body: GestureDetector(
          onTap: () {
            setState(() {
              _isSearching = false;
            });
          },
          child: RefreshIndicator(
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
      ),
    );
  }

  Widget body() {
    final userPrefernece = Provider.of<UserViewModel>(context);
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Center(
        child: FutureBuilder<AssignMentClientModel?>(
          future: _showAssignList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: screenHeight * 0.9,
                width: screenWidth,
                color: AppColors.whiteColor,
                child: LoadingScreen(),
              );
            } else if (snapshot.hasError) {
              // return Text('${snapshot.error}');
              return ErrorLogOutScreen(
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
            } else {
              final assignClientLists = snapshot.data?.data?.data;
              final totalPages = snapshot.data?.data?.lastPage;
              if (assignClientLists != null && assignClientLists.isNotEmpty) {
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
                        SizedBox(
                          height: screenHeight * 0.013,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context, MaterialPageRoute(builder: (context) => StaffCurveNabBar()));
                                  },
                                  child: HeaderRow(Icons.arrow_back)),
                            ),

                            Text(
                              "Assignments",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                                            hintText: 'Company name or email',
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
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: assignClientLists.length,
                          itemBuilder: (context, index) {
                            final companyName = assignClientLists[index].clients?.companyName ?? "";
                            final staffemail = assignClientLists[index].clients?.email ?? "";
                            final staffPhone = assignClientLists[index].clients?.phone ?? "";
                            final image = assignClientLists[index].clients?.image ?? "";
                            final assignmentID = assignClientLists[index].assignmentNumber ?? "";
                            final breakTimes = assignClientLists[index].clients?.breakTime ?? "";
                            final assignmentStartDate = assignClientLists[index].assignStartDate ?? "";
                            final assignmentEndDate = assignClientLists[index].assignEndDate ?? "";
                            final Datum data = assignClientLists[index];
                            final Datum deptSlug = assignClientLists[index];

                            // Check if either companyName or staffemail matches the search query
                            final isMatch = companyName.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                                staffemail.toLowerCase().contains(_searchController.text.toLowerCase());

                            // Decode the calculationMethod JSON string safely
                            final calculationMethodJson = assignClientLists[index].calculationMethod ?? "[]";
                            List<String> calculationMethods = [];
                            try {
                              calculationMethods = List<String>.from(json.decode(calculationMethodJson));
                            } catch (e) {
                              // Handle the error if JSON parsing fails
                              calculationMethods = [];
                            }

                            // Transform calculationMethods list
                            List<String> transformedMethods = calculationMethods.map((method) {
                              switch (method) {
                                case 'Manual_Calculation':
                                  return 'Manu';
                                case 'One_tap_Calculation':
                                  return 'One';
                                case 'Period_Calculation':
                                  return 'Pero';
                                default:
                                  return method;
                              }
                            }).toList();

                            // Only display the item if it matches the search query
                            if (_searchController.text.isEmpty || isMatch) {
                              return Column(
                                children: [
                                  SizedBox(
                                    height: screenHeight * 0.013,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      final DateTime? startDate = DateTime.tryParse(assignmentStartDate);
                                      final DateTime? endDate = DateTime.tryParse(assignmentEndDate);
                                      final DateTime currentDate = DateTime.now();
                                      if (startDate != null && endDate != null) {
                                        if (currentDate.isBefore(startDate)) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                            duration: Duration(seconds: 2),
                                            content: Text(
                                              'The assignment has not started yet!',
                                              style: TextStyle(
                                                  fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),
                                            ),
                                            backgroundColor: Colors.redAccent,
                                          ));
                                        } else if (currentDate.isAfter(endDate)) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                            duration: Duration(seconds: 2),
                                            content: Text(
                                              'The assignment has already expired!',
                                              style: TextStyle(
                                                  fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),
                                            ),
                                            backgroundColor: Colors.redAccent,
                                          ));
                                        } else {
                                          final selectedSlug = '${data.slug}';
                                          final selectedClientSlug = '${data.clientSlug}';
                                          final selectedStartTime = '${data.startTime}';
                                          final selectedEndTime = '${data.endTime}';
                                          final selectedEmail = '$staffemail';
                                          final selectedCompany = '$companyName';
                                          final selectedImage = '$image';
                                          final selectedAssignStartDate = '$assignmentStartDate';
                                          final selectedAssignEndDate = '$assignmentEndDate';

                                          // final selectedMethods = transformedMethods;
                                          final selectedBreak = breakTimes;

                                          print('Received data from IndividualView:${data.slug}');
                                          print('Received data from IndividualView:${data.clients?.companyName}');
                                          print('Received data from IndividualView:$staffemail');
                                          print('Received data from IndividualView:$companyName');
                                          print('Received data from IndividualView:$image');
                                          // print('Received data from IndividualView: $selectedMethods');
                                          print('breakTimes: $selectedBreak');

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => WeekDataStaffNew(
                                                slug: selectedSlug,
                                                clientslug: selectedClientSlug,
                                                StartTime: selectedStartTime,
                                                EndTime: selectedEndTime,
                                                email: selectedEmail,
                                                companyName: selectedCompany,
                                                images: selectedImage,
                                                // methods: selectedMethods,
                                                breakTimes: selectedBreak,
                                                assignStartDate: selectedAssignStartDate,
                                                assignEndDate: selectedAssignEndDate,
                                              ),
                                            ),
                                          ).then((value) {
                                            if (value != null) {
                                              print('Received data from IndividualView: $value');
                                            }
                                          });
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          duration: Duration(seconds: 2),
                                          content: Text(
                                            'Assignment dates are not available!',
                                            style: TextStyle(
                                                fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),
                                          ),
                                          backgroundColor: Colors.redAccent,
                                        ));
                                      }
                                    },
                                    child: Container(
                                      width: screenWidth * 0.95,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Color(0xffFAFAFA),
                                      ),
                                      child: Column(
                                        children: [
                                          // Text(assignmentStartDate),
                                          // Text(assignmentEndDate),
                                          SizedBox(
                                            height: screenHeight * 0.013,
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => FullScreenImageStaff(
                                                              imageUrl: "${AppUrl.staffUsers}/$image"),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      height: screenHeight * 0.08,
                                                      width: screenWidth * 0.12,
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                            image: image.isNotEmpty
                                                                ? NetworkImage(
                                                                    "${AppUrl.staffUsers}/$image",
                                                                  )
                                                                : AssetImage('images/default_image.png')
                                                                    as ImageProvider,
                                                            fit: BoxFit.cover),
                                                        color: AppColors.navOpacity,
                                                        shape: BoxShape.circle,
                                                        // color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: screenWidth * 0.023,
                                                  ),
                                                  Container(
                                                    width: screenWidth * 0.40,
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        AutoSizeText(
                                                          companyName,
                                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                          minFontSize: 8,
                                                          maxFontSize: 16,
                                                        ),
                                                        Text(staffemail,
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                            )),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  _showModalBottomSheet(data.deptSlug);
                                                },
                                                child: Container(
                                                  height: screenHeight * 0.04,
                                                  width: screenWidth * 0.30,
                                                  decoration: BoxDecoration(
                                                      color: AppColors.navOpacity,
                                                      borderRadius: BorderRadius.circular(8)),
                                                  child: Center(
                                                      child: AutoSizeText(
                                                    assignmentID,
                                                    minFontSize: 8,
                                                  )),
                                                ),
                                              ),
                                              SizedBox(
                                                width: screenWidth * 0.013,
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  if (data.deptSlug != null) {
                                                    _showModalBottomSheet(data.deptSlug);
                                                  } else {
                                                    Utils.toastMessage("No Department Available");
                                                  }
                                                },
                                                child: data.deptSlug != null
                                                    ? SvgPicture.asset(
                                                        'images/staff/dep.svg',
                                                        color: Colors.blueAccent,
                                                      )
                                                    : SvgPicture.asset(
                                                        'images/staff/dep.svg',
                                                        color: Colors.red,
                                                      ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: screenHeight * 0.013,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // SizedBox(
                                  //   height: screenHeight * 0.013,
                                  // ),
                                ],
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),
                      ],
                    ));
              } else {
                return Column(
                  children: [
                    SizedBox(
                      height: screenHeight * 0.013,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Assignments",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Align(
                      alignment: Alignment(0.0, -0.2), // Move content slightly higher
                      child: Container(
                        height: screenHeight * 0.75,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.assignment_outlined,
                                color: Colors.grey,
                                size: screenWidth * 0.15, // Responsive icon size
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Text(
                                'No Assignments Available',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.05, // Responsive text size
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.navColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Text(
                                'You currently have no pending assignments.',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  color: AppColors.navColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
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
    );
  }

  void _showModalBottomSheet(String? deptSlug) async {
    try {
      final viewDepartmentModel = await fetchDepartmentDetails(deptSlug!);

      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          final screenHeight = MediaQuery.of(context).size.height * 0.1;
          final screenWidth = MediaQuery.of(context).size.width * 1;
          final departmentDetails = viewDepartmentModel.data;
          final Height = MediaQuery.of(context).size.height * 1;
          final Width = MediaQuery.of(context).size.width * 1;
          return FractionallySizedBox(
            widthFactor: screenWidth,
            child: Container(
              width: screenWidth,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: Height * 0.07,
                      width: Width,
                      decoration: BoxDecoration(
                        color: AppColors.navButtonColor,
                        // Colors.deepOrangeAccent,
                        borderRadius:
                            BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
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
                            height: Height * 0.013,
                          ),
                          Container(
                            height: screenHeight * 0.06,
                            width: screenWidth * 0.1,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.grey.shade300,
                              ),
                              color: Colors.grey.shade300,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.007),
                          AutoSizeText(
                            'Department Details',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // SizedBox(
                    //   height: Height * 0.013,
                    // ),
                    Center(
                      child: Container(
                        width: screenWidth,
                        color: Colors.white,
                        child: Column(
                          children: [
                            SizedBox(
                              height: Height * 0.013,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  height: Height * 0.09,
                                  width: Width * 0.20,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5.0),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.system_security_update_good_rounded,
                                        color: Colors.deepPurpleAccent,
                                        size: MediaQuery.of(context).size.height * 0.05,
                                      ),
                                      AutoSizeText(
                                        "Department",
                                        style: TextStyle(fontSize: 10),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  height: Height * 0.09,
                                  width: Width * 0.75,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                      padding: const EdgeInsets.only(left: 25.0),
                                      child: Center(child: Text("${departmentDetails?.deptName ?? "no info"}"))),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: Height * 0.013,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  height: Height * 0.09,
                                  width: Width * 0.20,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5.0),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: Colors.blueAccent,
                                        size: MediaQuery.of(context).size.height * 0.05,
                                      ),
                                      AutoSizeText(
                                        "Location",
                                        style: TextStyle(fontSize: 10),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  height: Height * 0.09,
                                  width: Width * 0.75,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                      padding: const EdgeInsets.only(left: 25.0),
                                      child: Center(
                                          child: Text(
                                        "${departmentDetails?.location ?? "no info"}",
                                        style: TextStyle(color: Colors.black),
                                      ))),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: Height * 0.013,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  height: Height * 0.09,
                                  width: Width * 0.20,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5.0),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.real_estate_agent,
                                        color: Colors.deepOrangeAccent,
                                        size: MediaQuery.of(context).size.height * 0.05,
                                      ),
                                      AutoSizeText(
                                        "Responsibilities",
                                        minFontSize: 9,
                                        style: TextStyle(fontSize: 10),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  constraints: BoxConstraints(
                                    minHeight: Height * 0.09,
                                  ),
                                  // height: Height*0.09,
                                  width: Width * 0.75,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: Center(
                                        child: Text(
                                      _removeHtmlTags(
                                        "${departmentDetails?.details ?? "no info"}",
                                      ),
                                      textAlign: TextAlign.center,
                                    )),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: Height * 0.013,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // SizedBox(
                    //   height: Height * 0.013,
                    // ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      print('Error fetching department details: $e');
      // Handle error
    }
  }

  String _removeHtmlTags(String htmlString) {
    final document = parse(htmlString);
    return parse(document.body!.text).documentElement!.text;
  }

  Future<ViewDepartmentModel> fetchDepartmentDetails(String deptSlug) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';

    final String apiUrl = '${AppUrl.baseUrl}/api/app/assign/view/$deptSlug';
    final response = await https.get(Uri.parse(apiUrl), headers: {
      'Authorization': 'Bearer $_token',
    });

    if (response.statusCode == 200) {
      return viewDepartmentModelFromJson(response.body);
    } else {
      throw Exception('Failed to load department details');
    }
  }

  Widget singleContainer(String heading, String text) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: TextStyle(fontSize: 16, color: Colors.blueAccent),
        ),
        Container(
            height: screenHeight * 0.04,
            width: screenWidth * 0.98,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(child: Text(text))),
      ],
    );
  }
}
