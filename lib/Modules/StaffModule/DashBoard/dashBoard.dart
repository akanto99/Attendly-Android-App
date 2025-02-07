import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:c9_app/Modules/ClientModule/pages/noInternetConnectionWidget.dart';
import 'package:c9_app/Modules/StaffModule/Assignment/assignment_Action/WeekDataByStaff/weekdataStaffs_new.dart';
import 'package:c9_app/Modules/StaffModule/Assignment/assignments.dart';
import 'package:c9_app/Modules/StaffModule/Documents/uploadFileNew.dart';
import 'package:c9_app/Modules/StaffModule/MODEL/assignmentModel/assignmentClientModelClass.dart';
import 'package:c9_app/Modules/StaffModule/PaySlipNew/finalPaySlip_last.dart';
import 'package:c9_app/Modules/StaffModule/Reports/anotherClaender.dart';
import 'package:c9_app/loadingScreen.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/utils/routes/routes_name.dart';
import 'package:c9_app/utils/utils.dart';
import 'package:c9_app/view_model/services/rolebasedmodel/user_view_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as https;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../view/widgets/error_logout.dart';
import '../Profile/staff_profilev2.dart';

class StaffDashBoars extends StatefulWidget {
  const StaffDashBoars({Key? key}) : super(key: key);

  @override
  State<StaffDashBoars> createState() => _StaffDashBoarsState();
}

class _StaffDashBoarsState extends State<StaffDashBoars> with WidgetsBindingObserver {
  late Future<AssignMentClientModel?> _showAssignList;

  String greeting = "";
  String currentDate = "";
  String currentTime = "";
  List<String> clientNames = [];

  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool _showNoInternetConnectionMessage = false;

  late StreamSubscription<ConnectivityResult> _streamSubscription;
  bool isConnected = true;

  final ValueNotifier<double> scaleNotifier = ValueNotifier(1.0);
  final ValueNotifier<double> scaleNotifier2 = ValueNotifier(1.0);
  final ValueNotifier<double> scaleNotifier3 = ValueNotifier(1.0);
  final ValueNotifier<double> scaleNotifier4 = ValueNotifier(1.0);
  final ValueNotifier<double> scaleNotifier5 = ValueNotifier(1.0);
  final ValueNotifier<double> scaleNotifier6 = ValueNotifier(1.0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _showAssignList = AssignClientList();
    _fetchClientData();

    _setGreeting();
    _getCurrentDate();

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
      bool hasInternet = await _hasInternetConnection(); // Check internet access

      if (result != ConnectivityResult.none && hasInternet && _showNoInternetConnectionMessage) {
        print("Connectivity result: $result");
        print("Has internet: $hasInternet");
        print("No internet screen shown: $_showNoInternetConnectionMessage");

        _reloadData(forceRefresh: true).then((_) {
          setState(() {});
        });
      }

      setState(() {
        _showNoInternetConnectionMessage = (result == ConnectivityResult.none || !hasInternet);
      });

      if (!_showNoInternetConnectionMessage) {
        await _reloadData(forceRefresh: true);
      }
    });
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com').timeout(const Duration(milliseconds: 200));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (_) {
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
  didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _connectivitySubscription.resume();
      _reloadData(forceRefresh: true);
    } else if (state == AppLifecycleState.paused) {
      _connectivitySubscription.pause();
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> _reloadData({bool forceRefresh = false}) async {
    if(forceRefresh){
      try {
        var freshData = await AssignClientList();
        if (freshData != null) {
          setState(() {
            _showAssignList = Future.value(freshData);
            _showNoInternetConnectionMessage = false;
          });
        } else {
          throw Exception('Failed to fetch data');
        }
      } catch (e) {
        setState(() {
          _showNoInternetConnectionMessage = true;
        });
      }
    }

  }

  Future<void> _fetchClientData() async {
    try {
      AssignMentClientModel? assignMentClientModel = await AssignClientList();
      setState(() {
        clientNames = assignMentClientModel?.data?.data?.map((datum) => datum.clients?.companyName).toList()?.cast<String>() ?? [];
      });
    } catch (e) {
      // Handle error
      print("Error fetching client data: $e");
    }
  }


  Future<AssignMentClientModel?> AssignClientList() async {
    /// DON'T REMOVE THIS CODE
    // var connectivityResult = await (Connectivity().checkConnectivity());
    // bool hasInternet = await _hasInternetConnection();
    //
    // if (connectivityResult == ConnectivityResult.none || !hasInternet) {
    //   setState(() {
    //     _showNoInternetConnectionMessage = true;
    //   });
    //   return null;
    // } else {
    //   SharedPreferences prefs = await SharedPreferences.getInstance();
    //   String _token = prefs.getString('token') ?? '';
    //
    //   final String apiUrl = '${AppUrl.baseUrl}/api/app/active/staff/index';
    //   final response = await https.get(Uri.parse(apiUrl), headers: {
    //     'Authorization': 'Bearer $_token',
    //   });
    //   print('URL: HIT');
    //   if (response.statusCode == 200) {
    //     return assignMentClientModelFromJson(response.body);
    //   } else {
    //     throw Exception('Failed to load day rate index');
    //   }
    // }

    try{

      var connectivityResult = await (Connectivity().checkConnectivity());
      bool hasInternet = await _hasInternetConnection();

      if (connectivityResult == ConnectivityResult.none || !hasInternet) {
        setState(() {
          _showNoInternetConnectionMessage = true;
        });
        return null;
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String _token = prefs.getString('token') ?? '';

        if (_token.isEmpty) {
          throw Exception("No authentication token found");
        }

        final String apiUrl = '${AppUrl.baseUrl}/api/app/active/staff/index';
        final response = await https.get(Uri.parse(apiUrl), headers: {
          'Authorization': 'Bearer $_token',
        });

        print('API Response Status: ${response.statusCode}');
        print('API Response Body: ${response.body}');
        print('URL: HIT');
        if (response.statusCode == 200) {
          return assignMentClientModelFromJson(response.body);
        }else if (response.statusCode == 401) {
          throw Exception('Unauthorized: Invalid session');
        } else {
          throw Exception('Failed to load day rate index');
        }
      }

    } catch(e){
      print("API Error: $e");
      return null;
    }
  }

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

  String cleanCompanyName(String companyName) {
    RegExp limitedRegex = RegExp(
      r'\b(?:LTD|Ltd|ltd|LTD\.|Ltd\.|ltd\.|Limited|limited|LIMITED|Limited\.|limited\.|LIMITED\.)\b',
      caseSensitive: false, // Makes it case insensitive
    );
    return companyName.replaceAll(limitedRegex, '').trim();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  void _sendEmail() async {
    String email = 'support@c9-recruitment.com';
    final Uri mailUrl = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Example Subject&body=Example Body',
    );

    if (await canLaunchUrl(mailUrl)) {
      await launchUrl(mailUrl);
    } else {
      print('Error');
      throw "Could not launch email client";
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: _showNoInternetConnectionMessage ? Colors.red : AppColors.navColor,
    ));
    return UpgradeAlert(
      canDismissDialog: false,
      showLater: false,
      showIgnore: false,
      showReleaseNotes: false,
      upgrader: Upgrader(),
      child: SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            body: RefreshIndicator(
              onRefresh:() => _reloadData(forceRefresh: true),
              child: _showNoInternetConnectionMessage
                  ? NoInternetConnection()
                  : ResPonsiveUi(
                    mobile: body(),
                    desktop: body(),
                    tablet: body(),
                  ),
            )),
      ),
    );
  }

  Widget body() {
    final userPrefernece = Provider.of<UserViewModel>(context);
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;

    return Container(
       height: screenHeight,
      color: Color(0xffe2ebf6),
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
            // return Text("${snapshot.error}");
            return ErrorLogOutScreen(
              screenHeight: screenHeight * 0.94,
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

          } else {
            final assignClientLists = snapshot.data?.data?.data;
            final totalPages = snapshot.data?.data?.lastPage;
            final name = snapshot.data?.name;
            final id = snapshot.data?.id;
            final peopleid = snapshot.data?.peopleId;
            final roleType = snapshot.data?.roleType;
            final image = snapshot.data?.image;
            if (assignClientLists != null && assignClientLists.isNotEmpty) {
              List<ValueNotifier<double>> scaleNotifiers = List.generate(assignClientLists.length, (index) => ValueNotifier(1.0));
              return SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF2c3e50), Color(0xFF1a252f)], // Gradient colors
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      height: screenHeight * 0.11,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              // height: screenHeight * 0.07,
                              height: screenHeight * 0.065,

                              width: screenWidth * 0.14,
                              decoration: BoxDecoration(
                                image: DecorationImage(image: AssetImage("images/c9LogoLatest.png"), fit: BoxFit.cover),
                                color: AppColors.navOpacity,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(10),

                                // color: Colors.red
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    // "$greeting ",
                                    "C9 Recruitment",
                                    style: TextStyle(
                                      // fontSize: 16,
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.whiteColor,
                                    ),
                                  ),
                                  Text(
                                    // "${name?.split(' ').first}",
                                    "${name}",
                                    style: TextStyle(
                                      // fontSize: 14,
                                      fontSize: screenWidth * 0.035,

                                      fontWeight: FontWeight.w500,
                                      color: AppColors.whiteColor,
                                    ),
                                  ),
                                  Text(
                                    "$currentDate",
                                    style: TextStyle(
                                      // fontSize: 12,
                                      fontSize: screenWidth * 0.03,

                                      fontWeight: FontWeight.w400,
                                      color: AppColors.whiteColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: screenHeight * 0.55,
                      width: screenWidth,
                      decoration: BoxDecoration(
                        color: Color(0xffFAFAFA).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white,
                            spreadRadius: 2,
                            blurRadius: 3,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  scaleNotifier.value = 0.94;
                                  Future.delayed(Duration(milliseconds: 200), () {
                                    scaleNotifier.value = 0.99;
                                  });
                                  if (assignClientLists == null || assignClientLists.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Timesheets are empty'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  } else if (assignClientLists.length == 1) {
                                    // Navigate directly to the screen if only one item is found
                                    final selectedData = assignClientLists.first;

                                    final selectedSlug = '${selectedData.slug}';
                                    final selectedClientslug = '${selectedData.clientSlug}';
                                    final selectedStartTime = '${selectedData.startTime}';
                                    final selectedEndTime = '${selectedData.endTime}';
                                    final selectedEmail = '${selectedData.clients?.email ?? ''}';
                                    final selectedCompany = '${selectedData.clients?.companyName ?? ''}';
                                    final selectedImage = '${selectedData.clients?.image ?? ''}';
                                    final selectedBreaks = selectedData.clients?.breakTime ?? '';
                                    final selectedAssignStartDate = '${selectedData.assignStartDate ?? ''}';
                                    final selectedAssignEndDate = '${selectedData.assignEndDate ?? ''}';

                                    Future.delayed(const Duration(milliseconds: 250), () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => WeekDataStaffNew(
                                            slug: selectedSlug,
                                            clientslug: selectedClientslug,
                                            StartTime: selectedStartTime,
                                            EndTime: selectedEndTime,
                                            email: selectedEmail,
                                            companyName: selectedCompany,
                                            images: selectedImage,
                                            breakTimes: selectedBreaks,
                                            assignStartDate: selectedAssignStartDate,
                                            assignEndDate: selectedAssignEndDate,
                                          ),
                                        ),
                                      );
                                    });
                                  } else {
                                    Future.delayed(const Duration(milliseconds: 250), () {
                                      showDialog(
                                        context: context,
                                        barrierColor: Colors.grey,
                                        builder: (BuildContext context) {
                                          final screenWidth = MediaQuery.of(context).size.width;
                                          final screenHeight = MediaQuery.of(context).size.height;
                                          return AlertDialog(
                                            insetPadding: EdgeInsets.all(10),
                                            titlePadding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
                                            contentPadding: EdgeInsets.only(left: 0, right: 0, bottom: 0, top: 10),
                                            actionsPadding: EdgeInsets.only(left: 0, right: 0, bottom: 0, top: 0),
                                            backgroundColor: Colors.white,
                                            surfaceTintColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                            title: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Color(0xFF2C3E50), // #2c3e50
                                                    Color(0xFF1A252F), // #1a252f
                                                  ],
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                ),
                                                border: Border(
                                                  bottom: BorderSide(
                                                    color: Color(0xFF1A252F),
                                                    width: 2.0,
                                                  ),
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.1),
                                                    offset: Offset(0, 4),
                                                    blurRadius: 6,
                                                  ),
                                                ],
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(30),
                                                  topRight: Radius.circular(30),
                                                ),
                                              ),
                                              padding: EdgeInsets.all(screenWidth * 0.025),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Container(
                                                    height: screenHeight * 0.05,
                                                    width: screenWidth * 0.1,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        height: screenHeight * 0.035,
                                                        width: screenWidth * 0.08,
                                                        // color: Colors.red,
                                                        child: Image.asset(
                                                          "images/clock.png",
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      SizedBox(width: screenWidth * 0.025),
                                                      Text(
                                                        'Timesheets',
                                                        style: GoogleFonts.openSans(
                                                          // Replace with a similar font
                                                          fontSize: 20,
                                                          color: AppColors.whiteColor,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Container(
                                                      height: screenHeight * 0.025,
                                                      width: screenWidth * 0.07,
                                                      // color: Colors.red,
                                                      child: Align(
                                                          alignment: Alignment.topLeft,
                                                          child: Image.asset(
                                                            "images/cancel.png",
                                                            height: 10,
                                                            width: 10,
                                                          )),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            content: SingleChildScrollView(
                                              child: ConstrainedBox(
                                                constraints: BoxConstraints(
                                                  maxHeight: screenHeight,
                                                ),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.max,
                                                  children: assignClientLists?.asMap().entries.map((entry) {
                                                        final index = entry.key;
                                                        final selectedData = entry.value;
                                                        final image = selectedData.clients?.image ?? '';
                                                        final staffemail = selectedData.clients?.email ?? '';
                                                        final companyName = selectedData.clients?.companyName ?? '';
                                                        final calculationMethodJson = selectedData.calculationMethod ?? "[]";
                                                        final assignmentStartDate = assignClientLists[index].assignStartDate ?? "";
                                                        final assignmentEndDate = assignClientLists[index].assignEndDate ?? "";

                                                        List<String> calculationMethods = [];
                                                        try {
                                                          calculationMethods = List<String>.from(json.decode(calculationMethodJson));
                                                        } catch (e) {
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
                                                        return GestureDetector(
                                                          onTap: () {
                                                            final DateTime? startDate = DateTime.tryParse(assignmentStartDate);
                                                            final DateTime? endDate = DateTime.tryParse(assignmentEndDate);
                                                            final DateTime currentDate = DateTime.now();

                                                            // Trigger the scale animation
                                                            scaleNotifiers[index].value = 0.95;
                                                            Future.delayed(Duration(milliseconds: 200), () {
                                                              scaleNotifiers[index].value = 1.0;
                                                            });
                                                            if (startDate != null && endDate != null) {
                                                              if (currentDate.isBefore(startDate)) {
                                                                Utils.flushBarErrorMessage('The assignment has not started yet!', context);
                                                              } else if (currentDate.isAfter(endDate)) {
                                                                Utils.flushBarErrorMessage('The assignment has already expired!', context);
                                                              } else {
                                                                final selectedSlug = '${selectedData.slug}';
                                                                final selectedClientslug = '${selectedData.clientSlug}';
                                                                final selectedStartTime = '${selectedData.startTime}';
                                                                final selectedEndTime = '${selectedData.endTime}';
                                                                final selectedEmail = '$staffemail';
                                                                final selectedCompany = '$companyName';
                                                                final selectedImage = '$image';
                                                                final selectedMethods = transformedMethods;
                                                                final selectedBreaks = selectedData.clients?.breakTime ?? '';
                                                                final selectedAssignStartDate = '$assignmentStartDate';
                                                                final selectedAssignEndDate = '$assignmentEndDate';
                                                                Future.delayed(const Duration(milliseconds: 250), () {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder: (context) => WeekDataStaffNew(
                                                                          slug: selectedSlug,
                                                                          clientslug: selectedClientslug,
                                                                          StartTime: selectedStartTime,
                                                                          EndTime: selectedEndTime,
                                                                          email: selectedEmail,
                                                                          companyName: selectedCompany,
                                                                          images: selectedImage,
                                                                          breakTimes: selectedBreaks,
                                                                          assignStartDate: selectedAssignStartDate,
                                                                          assignEndDate: selectedAssignEndDate,
                                                                        ),
                                                                      )).then((value) {
                                                                    if (value != null) {
                                                                      print('Received data from IndividualView: $value');
                                                                    }
                                                                  });
                                                                });
                                                              }
                                                            } else {
                                                              Utils.flushBarErrorMessage('Assignment dates are not available!', context);
                                                            }
                                                          },
                                                          child: AnimatedBuilder(
                                                            animation: scaleNotifiers[index],
                                                            builder: (context, child) {
                                                              return Transform.scale(
                                                                scale: scaleNotifiers[index].value,
                                                                child: Column(
                                                                  children: [
                                                                    Padding(
                                                                      padding: EdgeInsets.only(left: screenWidth * 0.05, right: screenWidth * 0.05),
                                                                      child: Container(
                                                                        decoration: BoxDecoration(
                                                                          // color: Colors.red,
                                                                          gradient: LinearGradient(
                                                                            colors: [
                                                                              Color(0xFFF8F8F8), // Equivalent to #f8f8f8
                                                                              Color(0xFFFFFFFF), // Equivalent to #ffffff
                                                                            ],
                                                                            begin: Alignment.topLeft, // Mimics 145 degrees
                                                                            end: Alignment.bottomRight,
                                                                          ),
                                                                          borderRadius: BorderRadius.circular(20), // Rounded corners
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                              color: Colors.black.withOpacity(0.1),
                                                                              blurRadius: 10, // Shadow blur
                                                                              offset: Offset(0, 4), // Shadow offset
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        child: Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            Row(
                                                                              children: [
                                                                                Padding(
                                                                                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenWidth * 0.038),
                                                                                  child: Container(
                                                                                    height: screenHeight * 0.09,
                                                                                    width: screenWidth * 0.19,
                                                                                    decoration: BoxDecoration(
                                                                                      color: Colors.white, // Background color
                                                                                      borderRadius: BorderRadius.circular(15), // Dynamic border radius
                                                                                      boxShadow: [
                                                                                        BoxShadow(
                                                                                          color: Colors.black.withOpacity(0.1), // rgba(0, 0, 0, 0.1)
                                                                                          blurRadius: 6, // blur-radius: 6px
                                                                                          offset: Offset(0, 4), // 0px X offset, 4px Y offset
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    child: Padding(
                                                                                      padding: EdgeInsets.all(screenWidth * 0.026),
                                                                                      child: image.isNotEmpty
                                                                                          ? Image.network(
                                                                                              "${AppUrl.staffUsers}/$image",
                                                                                              fit: BoxFit.cover,
                                                                                            ) // Replace with your base URL
                                                                                          : Image.asset(
                                                                                              'images/company-image.png',
                                                                                              fit: BoxFit.cover,
                                                                                            ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Container(
                                                                                      width: screenWidth * 0.5,
                                                                                      child: Text(
                                                                                        selectedData.clients?.companyName ?? '',
                                                                                        style: GoogleFonts.openSans(
                                                                                          // Replace with a similar font
                                                                                          fontSize: 16,
                                                                                          color: Color(0xff334155),
                                                                                          fontWeight: FontWeight.w600,
                                                                                        ),
                                                                                        maxLines: 2,
                                                                                        softWrap: true,
                                                                                        overflow: TextOverflow.ellipsis,
                                                                                      ),
                                                                                    ),
                                                                                    Container(
                                                                                      width: screenWidth * 0.5,
                                                                                      child: Text(
                                                                                        "${selectedData.clients?.addressLine1 ?? ''},${selectedData.clients?.addressLine2 ?? ''}",
                                                                                        style: GoogleFonts.openSans(
                                                                                          // Replace with a similar font
                                                                                          fontSize: 12,
                                                                                          color: Color(0xff6b7280),
                                                                                          fontWeight: FontWeight.w600,
                                                                                        ),
                                                                                        maxLines: 2,
                                                                                        softWrap: true,
                                                                                        overflow: TextOverflow.ellipsis,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(height: screenHeight * 0.014),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        );
                                                      })?.toList() ??
                                                      [],
                                                ),
                                              ),
                                            ),
                                            actions: [showSupportServiceModal()],
                                          );
                                        },
                                      );
                                    });
                                  }
                                },
                                child: AnimatedBuilder(
                                  animation: scaleNotifier,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: scaleNotifier.value,
                                      child: CategoryContainers(
                                        context: context,
                                        text: "Timesheets",
                                        imagePath: "images/staff/clock.png",
                                        height: screenHeight * 0.07,
                                        width: screenWidth * 0.2,
                                        // Maincolor: Color(0xffFFF9F2),
                                        Maincolor: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              GestureDetector(
                                  onTap: () {
                                    scaleNotifier2.value = 0.94;
                                    Future.delayed(Duration(milliseconds: 200), () {
                                      scaleNotifier2.value = 0.99;
                                    });
                                    if (assignClientLists == null || assignClientLists.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Assignments are empty'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    } else if (assignClientLists.length == 1) {
                                      // Navigate directly to the screen if only one item is found
                                      final selectedData = assignClientLists.first;

                                      Future.delayed(const Duration(milliseconds: 250), () {
                                        final selectedSlug = '${selectedData.slug}';
                                        final selectedEmail = '${selectedData.clients?.email ?? ''}';
                                        final selectedCompany = '${selectedData.clients?.companyName ?? ''}';
                                        final selectedImage = '${selectedData.clients?.image ?? ''}';

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Assignments(
                                              slug: selectedSlug,
                                              email: selectedEmail,
                                              companyName: selectedCompany,
                                              images: selectedImage,
                                            ),
                                          ),
                                        ).then((value) {
                                          if (value != null) {
                                            print('Received data from IndividualView: $value');
                                          }
                                        });
                                      });
                                    }else {
                                      Future.delayed(const Duration(milliseconds: 250), () {
                                        showDialog(
                                          context: context,
                                          barrierColor: Colors.grey,
                                          builder: (BuildContext context) {
                                            final screenWidth = MediaQuery.of(context).size.width;
                                            final screenHeight = MediaQuery.of(context).size.height;
                                            return AlertDialog(
                                              insetPadding: EdgeInsets.all(10),
                                              titlePadding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
                                              contentPadding: EdgeInsets.only(left: 0, right: 0, bottom: 0, top: 10),
                                              actionsPadding: EdgeInsets.only(left: 0, right: 0, bottom: 0, top: 0),
                                              backgroundColor: Colors.white,
                                              surfaceTintColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(30),
                                              ),
                                              title: Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color(0xFF2C3E50), // #2c3e50
                                                      Color(0xFF1A252F), // #1a252f
                                                    ],
                                                    begin: Alignment.centerLeft,
                                                    end: Alignment.centerRight,
                                                  ),
                                                  border: Border(
                                                    bottom: BorderSide(
                                                      color: Color(0xFF1A252F), // #1a252f
                                                      width: 2.0, // Border width
                                                    ),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.1), // Shadow color with opacity
                                                      offset: Offset(0, 4), // X and Y offset for shadow
                                                      blurRadius: 6, // Blur radius
                                                    ),
                                                  ],
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(30),
                                                    topRight: Radius.circular(30),
                                                  ),
                                                ),
                                                padding: EdgeInsets.all(screenWidth * 0.025),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Container(
                                                      height: screenHeight * 0.05,
                                                      width: screenWidth * 0.1,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          height: screenHeight * 0.032,
                                                          width: screenWidth * 0.06,
                                                          // color: Colors.red,
                                                          child: SvgPicture.asset(
                                                            "images/staff/dashboard/dash5.svg",
                                                            fit: BoxFit.contain,
                                                          ),
                                                        ),
                                                        SizedBox(width: screenWidth * 0.025),
                                                        Text(
                                                          'Assignments',
                                                          style: GoogleFonts.openSans(
                                                            // Replace with a similar font
                                                            fontSize: 20,
                                                            color: AppColors.whiteColor,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Container(
                                                        height: screenHeight * 0.025,
                                                        width: screenWidth * 0.07,
                                                        // color: Colors.red,
                                                        child: Align(
                                                            alignment: Alignment.topLeft,
                                                            child: Image.asset(
                                                              "images/cancel.png",
                                                              height: 10,
                                                              width: 10,
                                                            )),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              content: SingleChildScrollView(
                                                child: ConstrainedBox(
                                                  constraints: BoxConstraints(
                                                    maxHeight: screenHeight,
                                                  ),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.max,
                                                    children: assignClientLists?.asMap().entries.map((entry) {
                                                          final index = entry.key;
                                                          final selectedData = entry.value;
                                                          final image = selectedData.clients?.image ?? '';
                                                          final id = selectedData.clients?.id;
                                                          final staffemail = selectedData.clients?.email ?? '';
                                                          final companyName = selectedData.clients?.companyName ?? '';
                                                          final assignmentStartDate = selectedData.assignStartDate ?? "";
                                                          final assignmentEndDate = selectedData.assignEndDate ?? "";
                                                          final calculationMethodJson = selectedData.calculationMethod ?? "[]";
                                                          List<String> calculationMethods = [];
                                                          try {
                                                            calculationMethods = List<String>.from(json.decode(calculationMethodJson));
                                                          } catch (e) {
                                                            calculationMethods = [];
                                                          }

                                                          return GestureDetector(
                                                            onTap: () {
                                                              final DateTime? startDate = DateTime.tryParse(assignmentStartDate);
                                                              final DateTime? endDate = DateTime.tryParse(assignmentEndDate);
                                                              final DateTime currentDate = DateTime.now();

                                                              // Trigger the scale animation
                                                              scaleNotifiers[index].value = 0.95;
                                                              Future.delayed(Duration(milliseconds: 200), () {
                                                                scaleNotifiers[index].value = 1.0;
                                                              });

                                                              if (startDate != null && endDate != null) {
                                                                if (currentDate.isBefore(startDate)) {
                                                                  Utils.flushBarErrorMessage('The assignment has not started yet!', context);
                                                                } else if (currentDate.isAfter(endDate)) {
                                                                  Utils.flushBarErrorMessage('The assignment has already expired!', context);
                                                                } else {
                                                                  // Navigate to the next screen after the animation completes
                                                                  Future.delayed(const Duration(milliseconds: 250), () {
                                                                    final selectedSlug = '${selectedData.slug}';
                                                                    final selectedEmail = '$staffemail';
                                                                    final selectedCompany = '$companyName';
                                                                    final selectedImage = '$image';

                                                                    Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder: (context) => Assignments(
                                                                          slug: selectedSlug,
                                                                          email: selectedEmail,
                                                                          companyName: selectedCompany,
                                                                          images: selectedImage,
                                                                        ),
                                                                      ),
                                                                    ).then((value) {
                                                                      if (value != null) {
                                                                        print('Received data from IndividualView: $value');
                                                                      }
                                                                    });
                                                                  });
                                                                }
                                                              } else {
                                                                Utils.flushBarErrorMessage('Assignment dates are not available!', context);
                                                              }
                                                            },
                                                            child: AnimatedBuilder(
                                                              animation: scaleNotifiers[index],
                                                              builder: (context, child) {
                                                                return Transform.scale(
                                                                  scale: scaleNotifiers[index].value,
                                                                  child: Column(
                                                                    children: [
                                                                      Padding(
                                                                        padding: EdgeInsets.only(left: screenWidth * 0.05, right: screenWidth * 0.05),
                                                                        child: Container(
                                                                          decoration: BoxDecoration(
                                                                            // color: Colors.red,
                                                                            gradient: LinearGradient(
                                                                              colors: [
                                                                                Color(0xFFF8F8F8), // Equivalent to #f8f8f8
                                                                                Color(0xFFFFFFFF), // Equivalent to #ffffff
                                                                              ],
                                                                              begin: Alignment.topLeft, // Mimics 145 degrees
                                                                              end: Alignment.bottomRight,
                                                                            ),
                                                                            borderRadius: BorderRadius.circular(20), // Rounded corners
                                                                            boxShadow: [
                                                                              BoxShadow(
                                                                                color: Colors.black.withOpacity(0.1),
                                                                                blurRadius: 10, // Shadow blur
                                                                                offset: Offset(0, 4), // Shadow offset
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          child: Column(
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              Row(
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenWidth * 0.038),
                                                                                    child: Container(
                                                                                      height: screenHeight * 0.09,
                                                                                      width: screenWidth * 0.19,
                                                                                      decoration: BoxDecoration(
                                                                                        color: Colors.white, // Background color
                                                                                        borderRadius: BorderRadius.circular(15), // Dynamic border radius
                                                                                        boxShadow: [
                                                                                          BoxShadow(
                                                                                            color: Colors.black.withOpacity(0.1), // rgba(0, 0, 0, 0.1)
                                                                                            blurRadius: 6, // blur-radius: 6px
                                                                                            offset: Offset(0, 4), // 0px X offset, 4px Y offset
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                      child: Padding(
                                                                                        padding: EdgeInsets.all(screenWidth * 0.026),
                                                                                        child: image.isNotEmpty
                                                                                            ? Image.network(
                                                                                                "${AppUrl.staffUsers}/$image",
                                                                                                fit: BoxFit.cover,
                                                                                              ) // Replace with your base URL
                                                                                            : Image.asset(
                                                                                                'images/company-image.png',
                                                                                                fit: BoxFit.cover,
                                                                                              ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Container(
                                                                                        width: screenWidth * 0.5,
                                                                                        child: Text(
                                                                                          selectedData.clients?.companyName ?? '',
                                                                                          style: GoogleFonts.openSans(
                                                                                            // Replace with a similar font
                                                                                            fontSize: 16,
                                                                                            color: Color(0xff334155),
                                                                                            fontWeight: FontWeight.w600,
                                                                                          ),
                                                                                          maxLines: 2,
                                                                                          softWrap: true,
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                        ),
                                                                                      ),
                                                                                      Container(
                                                                                        width: screenWidth * 0.5,
                                                                                        child: Text(
                                                                                          "${selectedData.clients?.addressLine1 ?? ''},${selectedData.clients?.addressLine2 ?? ''}",
                                                                                          style: GoogleFonts.openSans(
                                                                                            // Replace with a similar font
                                                                                            fontSize: 12,
                                                                                            color: Color(0xff6b7280),
                                                                                            fontWeight: FontWeight.w600,
                                                                                          ),
                                                                                          maxLines: 2,
                                                                                          softWrap: true,
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(height: screenHeight * 0.014),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          );
                                                        })?.toList() ??
                                                        [],
                                                  ),
                                                ),
                                              ),
                                              actions: [showSupportServiceModal()],
                                            );
                                          },
                                        );
                                      });
                                    }
                                  },
                                  child: AnimatedBuilder(
                                    animation: scaleNotifier2,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: scaleNotifier2.value,
                                        child: CategoryContainers(
                                          context: context,
                                          text: "Assignments",
                                          imagePath: "images/staff/to-do.png",
                                          height: screenHeight * 0.07,
                                          width: screenWidth * 0.2,
                                          Maincolor: Color(0xffF9FFFF),
                                        ),
                                      );
                                    },
                                  )),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.013),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    scaleNotifier3.value = 0.94;
                                    Future.delayed(Duration(milliseconds: 200), () {
                                      scaleNotifier3.value = 0.99;
                                    });
                                    Future.delayed(const Duration(milliseconds: 250), () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => UploadFileStaffNew()));
                                    });
                                  },
                                  child: AnimatedBuilder(
                                    animation: scaleNotifier3,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: scaleNotifier3.value,
                                        child: CategoryContainers(
                                          context: context,
                                          text: "Documents",
                                          imagePath: "images/staff/document.png",
                                          height: screenHeight * 0.07,
                                          width: screenWidth * 0.2,
                                          // Maincolor: Color(0xffF9FFFF),
                                          Maincolor: Colors.white,
                                        ),
                                      );
                                    },
                                  )),
                              GestureDetector(
                                onTap: () {
                                  scaleNotifier4.value = 0.94;
                                  Future.delayed(Duration(milliseconds: 200), () {
                                    scaleNotifier4.value = 0.99;
                                  });
                                  if (peopleid == null) {
                                    Utils.toastMessage("No PaySlip has been created yet");
                                    print("Not Ok: $peopleid");
                                  } else {
                                    final SelectedId = "$peopleid";
                                    print("Ok: $peopleid");

                                    // Navigator.push(context, MaterialPageRoute(builder: (context)=>PaySlip(userId: SelectedId,)));
                                    // Navigator.push(context, MaterialPageRoute(builder: (context)=>PaySlipNew(userId: SelectedId,)));
                                    // Navigator.push(context, MaterialPageRoute(builder: (context)=>FinalPaySlipNew(userId: SelectedId,)));
                                    Future.delayed(const Duration(milliseconds: 250), () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => FinalPaySlipLast(
                                                    userId: SelectedId,
                                                  )));
                                    });
                                    // Utils.toastMessage("Updating Soon. Working on it.");
                                  }
                                },
                                child: AnimatedBuilder(
                                  animation: scaleNotifier4,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: scaleNotifier4.value,
                                      child: CategoryContainers(
                                        context: context,
                                        text: "Payslips",
                                        imagePath: "images/staff/money.png",
                                        height: screenHeight * 0.07,
                                        width: screenWidth * 0.2,
                                        // Maincolor: Color(0xffFFF9F2),
                                        Maincolor: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.013),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  scaleNotifier5.value = 0.94;
                                  Future.delayed(Duration(milliseconds: 200), () {
                                    scaleNotifier5.value = 0.99;
                                  });
                                  final SelectedId = "$id";
                                  // Navigator.push(context, MaterialPageRoute(builder: (context)=>CalenderView()));
                                  Future.delayed(const Duration(milliseconds: 250), () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => AnotherTest(id: SelectedId)));
                                  });
                                  // Utils.toastMessage("Updating Soon. Working on it.");
                                },
                                child: AnimatedBuilder(
                                  animation: scaleNotifier5,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: scaleNotifier5.value,
                                      child: CategoryContainers1(
                                        context: context,
                                        text: "Availability",
                                        imagePath: "images/staff/calendar.png",
                                        height: screenHeight * 0.07,
                                        width: screenWidth * 0.2,
                                        Maincolor: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  scaleNotifier6.value = 0.94;
                                  Future.delayed(Duration(milliseconds: 200), () {
                                    scaleNotifier6.value = 0.99;
                                  });
                                  Future.delayed(const Duration(milliseconds: 250), () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => StaffProfile()));
                                  });
                                },
                                child: AnimatedBuilder(
                                  animation: scaleNotifier6,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: scaleNotifier6.value,
                                      child: CategoryContainers(
                                        context: context,
                                        text: "Profile",
                                        imagePath: "images/staff/user.png",
                                        height: screenHeight * 0.07,
                                        width: screenWidth * 0.2,
                                        Maincolor: Colors.white,
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
                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Container(
                        height: screenHeight * 0.22,
                        width: screenWidth,
                        color: Color(0xffe2ebf6),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Assignments",
                              style: GoogleFonts.openSans(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.010),
                            Container(
                              height: screenHeight * 0.11,
                              margin: EdgeInsets.only(left:10,right: 10),
                              // width: screenWidth,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemCount: clientNames.length,
                                itemBuilder: (context, index) {
                                  final assignClientList = snapshot.data?.data?.data ?? [];
                                  // final assignClientList = snapshot.data?.data?.data;
                                  final image = assignClientList?[index]?.clients?.image ?? "";

                                  return Row(
                                    children: [
                                      Container(
                                        width: screenWidth * 0.22,
                                        height: screenHeight * 0.105,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: image.isNotEmpty
                                                ? NetworkImage("${AppUrl.staffUsers}/$image")
                                                : AssetImage('images/default_image.png') as ImageProvider, // Fallback image
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),


                                      SizedBox(width: screenWidth*0.02,)
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),



                  ],
                ),
              );
            } else {
              return SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2c3e50), Color(0xFF1a252f)], // Gradient colors
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    height: screenHeight * 0.13,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Navigator.push(context, MaterialPageRoute(builder: (context) => StaffProfile()));
                            },
                            child: Container(
                              height: screenHeight * 0.07,
                              width: screenWidth * 0.14,
                              decoration: BoxDecoration(
                                image: DecorationImage(image:AssetImage("images/c9LogoLatest.png"), fit: BoxFit.cover),
                                color: AppColors.navOpacity,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(10),

                                // color: Colors.red
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  // "$greeting ",
                                  "C9 Recruitment",
                                  style: TextStyle(
                                    // fontSize: 16,
                                    fontSize: screenWidth * 0.04,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.whiteColor,
                                  ),
                                ),
                                Text(
                                  // "${name?.split(' ').first}",
                                  "${name}",
                                  style: TextStyle(
                                    // fontSize: 14,
                                    fontSize: screenWidth * 0.035,

                                    fontWeight: FontWeight.w500,
                                    color: AppColors.whiteColor,
                                  ),
                                ),
                                Text(
                                  "$currentDate",
                                  style: TextStyle(
                                    // fontSize: 12,
                                    fontSize: screenWidth * 0.03,

                                    fontWeight: FontWeight.w400,
                                    color: AppColors.whiteColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: screenHeight * 0.56,
                    width: screenWidth,
                    decoration: BoxDecoration(
                      color: Color(0xffFAFAFA).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white,
                          spreadRadius: 2,
                          blurRadius: 3,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                scaleNotifier.value = 0.94;
                                Future.delayed(Duration(milliseconds: 200), () {
                                  scaleNotifier.value = 0.99;
                                });
                                if (assignClientLists == null || assignClientLists.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Timesheets are empty'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                } else if (assignClientLists.length == 1) {
                                  // Navigate directly to the screen if only one item is found
                                  final selectedData = assignClientLists.first;

                                  final selectedSlug = '${selectedData.slug}';
                                  final selectedClientslug = '${selectedData.clientSlug}';
                                  final selectedStartTime = '${selectedData.startTime}';
                                  final selectedEndTime = '${selectedData.endTime}';
                                  final selectedEmail = '${selectedData.clients?.email ?? ''}';
                                  final selectedCompany = '${selectedData.clients?.companyName ?? ''}';
                                  final selectedImage = '${selectedData.clients?.image ?? ''}';
                                  final selectedBreaks = selectedData.clients?.breakTime ?? '';
                                  final selectedAssignStartDate = '${selectedData.assignStartDate ?? ''}';
                                  final selectedAssignEndDate = '${selectedData.assignEndDate ?? ''}';

                                  Future.delayed(const Duration(milliseconds: 250), () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => WeekDataStaffNew(
                                          slug: selectedSlug,
                                          clientslug: selectedClientslug,
                                          StartTime: selectedStartTime,
                                          EndTime: selectedEndTime,
                                          email: selectedEmail,
                                          companyName: selectedCompany,
                                          images: selectedImage,
                                          breakTimes: selectedBreaks,
                                          assignStartDate: selectedAssignStartDate,
                                          assignEndDate: selectedAssignEndDate,
                                        ),
                                      ),
                                    );
                                  });
                                }else {
                                  Future.delayed(const Duration(milliseconds: 250), () {
                                    showDialog(
                                      context: context,
                                      barrierColor: Colors.grey,
                                      builder: (BuildContext context) {
                                        final screenWidth = MediaQuery.of(context).size.width;
                                        final screenHeight = MediaQuery.of(context).size.height;
                                        return AlertDialog(
                                          insetPadding: EdgeInsets.all(10),
                                          titlePadding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
                                          contentPadding: EdgeInsets.only(left: 0, right: 0, bottom: 0, top: 10),
                                          actionsPadding: EdgeInsets.only(left: 0, right: 0, bottom: 0, top: 0),
                                          backgroundColor: Colors.white,
                                          surfaceTintColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                          title: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color(0xFF2C3E50), // #2c3e50
                                                  Color(0xFF1A252F), // #1a252f
                                                ],
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              ),
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Color(0xFF1A252F), // #1a252f
                                                  width: 2.0, // Border width
                                                ),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.1), // Shadow color with opacity
                                                  offset: Offset(0, 4), // X and Y offset for shadow
                                                  blurRadius: 6, // Blur radius
                                                ),
                                              ],
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(30),
                                                topRight: Radius.circular(30),
                                              ),
                                            ),
                                            padding: EdgeInsets.all(screenWidth * 0.025),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  height: screenHeight * 0.05,
                                                  width: screenWidth * 0.1,
                                                ),
                                                Row(
                                                  children: [
                                                    Container(
                                                      height: screenHeight * 0.035,
                                                      width: screenWidth * 0.08,
                                                      // color: Colors.red,
                                                      child: Image.asset(
                                                        "images/clock.png",
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    SizedBox(width: screenWidth * 0.025),
                                                    Text(
                                                      'Timesheets',
                                                      style: GoogleFonts.openSans(
                                                        // Replace with a similar font
                                                        fontSize: 20,
                                                        color: AppColors.whiteColor,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Container(
                                                    height: screenHeight * 0.025,
                                                    width: screenWidth * 0.07,
                                                    // color: Colors.red,
                                                    child: Align(
                                                        alignment: Alignment.topLeft,
                                                        child: Image.asset(
                                                          "images/cancel.png",
                                                          height: 10,
                                                          width: 10,
                                                        )),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          content: SingleChildScrollView(
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxHeight: screenHeight,
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.max,
                                                children: assignClientLists?.asMap().entries.map((entry) {
                                                      final index = entry.key;
                                                      final selectedData = entry.value;
                                                      final image = selectedData.clients?.image ?? '';
                                                      final staffemail = selectedData.clients?.email ?? '';
                                                      final companyName = selectedData.clients?.companyName ?? '';
                                                      final calculationMethodJson = selectedData.calculationMethod ?? "[]";
                                                      final assignmentStartDate = assignClientLists[index].assignStartDate ?? "";
                                                      final assignmentEndDate = assignClientLists[index].assignEndDate ?? "";

                                                      List<String> calculationMethods = [];
                                                      try {
                                                        calculationMethods = List<String>.from(json.decode(calculationMethodJson));
                                                      } catch (e) {
                                                        calculationMethods = [];
                                                      }
                                                      List<ValueNotifier<double>> scaleNotifiers = List.generate(assignClientLists.length, (index) => ValueNotifier(1.0));

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
                                                      return GestureDetector(
                                                        onTap: () {
                                                          final DateTime? startDate = DateTime.tryParse(assignmentStartDate);
                                                          final DateTime? endDate = DateTime.tryParse(assignmentEndDate);
                                                          final DateTime currentDate = DateTime.now();

                                                          // Trigger the scale animation
                                                          scaleNotifiers[index].value = 0.95;
                                                          Future.delayed(Duration(milliseconds: 200), () {
                                                            scaleNotifiers[index].value = 1.0;
                                                          });
                                                          if (startDate != null && endDate != null) {
                                                            if (currentDate.isBefore(startDate)) {
                                                              Utils.flushBarErrorMessage('The assignment has not started yet!', context);
                                                            } else if (currentDate.isAfter(endDate)) {
                                                              Utils.flushBarErrorMessage('The assignment has already expired!', context);
                                                            } else {
                                                              final selectedSlug = '${selectedData.slug}';
                                                              final selectedClientslug = '${selectedData.clientSlug}';
                                                              final selectedStartTime = '${selectedData.startTime}';
                                                              final selectedEndTime = '${selectedData.endTime}';
                                                              final selectedEmail = '$staffemail';
                                                              final selectedCompany = '$companyName';
                                                              final selectedImage = '$image';
                                                              final selectedMethods = transformedMethods;
                                                              final selectedBreaks = selectedData.clients?.breakTime ?? '';
                                                              final selectedAssignStartDate = '$assignmentStartDate';
                                                              final selectedAssignEndDate = '$assignmentEndDate';
                                                              Future.delayed(const Duration(milliseconds: 250), () {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (context) => WeekDataStaffNew(
                                                                        slug: selectedSlug,
                                                                        clientslug: selectedClientslug,
                                                                        StartTime: selectedStartTime,
                                                                        EndTime: selectedEndTime,
                                                                        email: selectedEmail,
                                                                        companyName: selectedCompany,
                                                                        images: selectedImage,
                                                                        breakTimes: selectedBreaks,
                                                                        assignStartDate: selectedAssignStartDate,
                                                                        assignEndDate: selectedAssignEndDate,
                                                                      ),
                                                                    )).then((value) {
                                                                  if (value != null) {
                                                                    print('Received data from IndividualView: $value');
                                                                  }
                                                                });
                                                              });
                                                            }
                                                          } else {
                                                            Utils.flushBarErrorMessage('Assignment dates are not available!', context);
                                                          }
                                                        },
                                                        child: AnimatedBuilder(
                                                          animation: scaleNotifiers[index],
                                                          builder: (context, child) {
                                                            return Transform.scale(
                                                              scale: scaleNotifiers[index].value,
                                                              child: Column(
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsets.only(left: screenWidth * 0.05, right: screenWidth * 0.05),
                                                                    child: Container(
                                                                      decoration: BoxDecoration(
                                                                        // color: Colors.red,
                                                                        gradient: LinearGradient(
                                                                          colors: [
                                                                            Color(0xFFF8F8F8),
                                                                            Color(0xFFFFFFFF),
                                                                          ],
                                                                          begin: Alignment.topLeft,
                                                                          end: Alignment.bottomRight,
                                                                        ),
                                                                        borderRadius: BorderRadius.circular(20),
                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                            color: Colors.black.withOpacity(0.1),
                                                                            blurRadius: 10, // Shadow blur
                                                                            offset: Offset(0, 4), // Shadow offset
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      child: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Row(
                                                                            children: [
                                                                              Padding(
                                                                                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenWidth * 0.038),
                                                                                child: Container(
                                                                                  height: screenHeight * 0.09,
                                                                                  width: screenWidth * 0.19,
                                                                                  decoration: BoxDecoration(
                                                                                    color: Colors.white, // Background color
                                                                                    borderRadius: BorderRadius.circular(15), // Dynamic border radius
                                                                                    boxShadow: [
                                                                                      BoxShadow(
                                                                                        color: Colors.black.withOpacity(0.1), // rgba(0, 0, 0, 0.1)
                                                                                        blurRadius: 6, // blur-radius: 6px
                                                                                        offset: Offset(0, 4), // 0px X offset, 4px Y offset
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  child: Padding(
                                                                                    padding: EdgeInsets.all(screenWidth * 0.026),
                                                                                    child: image.isNotEmpty
                                                                                        ? Image.network(
                                                                                            "${AppUrl.staffUsers}/$image",
                                                                                            fit: BoxFit.cover,
                                                                                          ) // Replace with your base URL
                                                                                        : Image.asset(
                                                                                            'images/company-image.png',
                                                                                            fit: BoxFit.cover,
                                                                                          ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Container(
                                                                                    width: screenWidth * 0.5,
                                                                                    child: Text(
                                                                                      selectedData.clients?.companyName ?? '',
                                                                                      style: GoogleFonts.openSans(
                                                                                        // Replace with a similar font
                                                                                        fontSize: 16,
                                                                                        color: Color(0xff334155),
                                                                                        fontWeight: FontWeight.w600,
                                                                                      ),
                                                                                      maxLines: 2,
                                                                                      softWrap: true,
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                    ),
                                                                                  ),
                                                                                  Container(
                                                                                    width: screenWidth * 0.5,
                                                                                    child: Text(
                                                                                      "${selectedData.clients?.addressLine1 ?? ''},${selectedData.clients?.addressLine2 ?? ''}",
                                                                                      style: GoogleFonts.openSans(
                                                                                        // Replace with a similar font
                                                                                        fontSize: 12,
                                                                                        color: Color(0xff6b7280),
                                                                                        fontWeight: FontWeight.w600,
                                                                                      ),
                                                                                      maxLines: 2,
                                                                                      softWrap: true,
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(height: screenHeight * 0.014),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      );
                                                    })?.toList() ??
                                                    [],
                                              ),
                                            ),
                                          ),
                                          actions: [showSupportServiceModal()],
                                        );
                                      },
                                    );
                                  });
                                }
                              },
                              child: AnimatedBuilder(
                                animation: scaleNotifier,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: scaleNotifier.value,
                                    child: CategoryContainers(
                                      context: context,
                                      text: "Timesheets",
                                      imagePath: "images/staff/clock.png",
                                      height: screenHeight * 0.07,
                                      width: screenWidth * 0.2,
                                      // Maincolor: Color(0xffFFF9F2),
                                      Maincolor: Colors.white,
                                    ),
                                  );
                                },
                              ),
                            ),
                            GestureDetector(
                                onTap: () {
                                  scaleNotifier2.value = 0.94;
                                  Future.delayed(Duration(milliseconds: 200), () {
                                    scaleNotifier2.value = 0.99;
                                  });
                                  if (assignClientLists == null || assignClientLists.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Assignments are empty'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }else if (assignClientLists.length == 1) {
                                    // Navigate directly to the screen if only one item is found
                                    final selectedData = assignClientLists.first;

                                    Future.delayed(const Duration(milliseconds: 250), () {
                                      final selectedSlug = '${selectedData.slug}';
                                      final selectedEmail = '${selectedData.clients?.email ?? ''}';
                                      final selectedCompany = '${selectedData.clients?.companyName ?? ''}';
                                      final selectedImage = '${selectedData.clients?.image ?? ''}';

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Assignments(
                                            slug: selectedSlug,
                                            email: selectedEmail,
                                            companyName: selectedCompany,
                                            images: selectedImage,
                                          ),
                                        ),
                                      ).then((value) {
                                        if (value != null) {
                                          print('Received data from IndividualView: $value');
                                        }
                                      });
                                    });
                                  } else {
                                    Future.delayed(const Duration(milliseconds: 250), () {
                                      showDialog(
                                        context: context,
                                        barrierColor: Colors.grey,
                                        builder: (BuildContext context) {
                                          final screenWidth = MediaQuery.of(context).size.width;
                                          final screenHeight = MediaQuery.of(context).size.height;
                                          return AlertDialog(
                                            insetPadding: EdgeInsets.all(10),
                                            titlePadding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
                                            contentPadding: EdgeInsets.only(left: 0, right: 0, bottom: 0, top: 10),
                                            actionsPadding: EdgeInsets.only(left: 0, right: 0, bottom: 0, top: 0),
                                            backgroundColor: Colors.white,
                                            surfaceTintColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                            title: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Color(0xFF2C3E50), // #2c3e50
                                                    Color(0xFF1A252F), // #1a252f
                                                  ],
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                ),
                                                border: Border(
                                                  bottom: BorderSide(
                                                    color: Color(0xFF1A252F), // #1a252f
                                                    width: 2.0, // Border width
                                                  ),
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.1), // Shadow color with opacity
                                                    offset: Offset(0, 4), // X and Y offset for shadow
                                                    blurRadius: 6, // Blur radius
                                                  ),
                                                ],
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(30),
                                                  topRight: Radius.circular(30),
                                                ),
                                              ),
                                              padding: EdgeInsets.all(screenWidth * 0.025),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Container(
                                                    height: screenHeight * 0.05,
                                                    width: screenWidth * 0.1,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        height: screenHeight * 0.032,
                                                        width: screenWidth * 0.06,
                                                        // color: Colors.red,
                                                        child: SvgPicture.asset(
                                                          "images/staff/dashboard/dash5.svg",
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                      SizedBox(width: screenWidth * 0.025),
                                                      Text(
                                                        'Assignments',
                                                        style: GoogleFonts.openSans(
                                                          // Replace with a similar font
                                                          fontSize: 20,
                                                          color: AppColors.whiteColor,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Container(
                                                      height: screenHeight * 0.025,
                                                      width: screenWidth * 0.07,
                                                      // color: Colors.red,
                                                      child: Align(
                                                          alignment: Alignment.topLeft,
                                                          child: Image.asset(
                                                            "images/cancel.png",
                                                            height: 10,
                                                            width: 10,
                                                          )),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            content: SingleChildScrollView(
                                              child: ConstrainedBox(
                                                constraints: BoxConstraints(
                                                  maxHeight: screenHeight,
                                                ),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.max,
                                                  children: assignClientLists?.asMap().entries.map((entry) {
                                                        final index = entry.key;
                                                        final selectedData = entry.value;
                                                        final image = selectedData.clients?.image ?? '';
                                                        final id = selectedData.clients?.id;
                                                        final staffemail = selectedData.clients?.email ?? '';
                                                        final companyName = selectedData.clients?.companyName ?? '';
                                                        final assignmentStartDate = selectedData.assignStartDate ?? "";
                                                        final assignmentEndDate = selectedData.assignEndDate ?? "";
                                                        final calculationMethodJson = selectedData.calculationMethod ?? "[]";
                                                        List<String> calculationMethods = [];
                                                        try {
                                                          calculationMethods = List<String>.from(json.decode(calculationMethodJson));
                                                        } catch (e) {
                                                          calculationMethods = [];
                                                        }
                                                        List<ValueNotifier<double>> scaleNotifiers = List.generate(assignClientLists.length, (index) => ValueNotifier(1.0));

                                                        return GestureDetector(
                                                          onTap: () {
                                                            final DateTime? startDate = DateTime.tryParse(assignmentStartDate);
                                                            final DateTime? endDate = DateTime.tryParse(assignmentEndDate);
                                                            final DateTime currentDate = DateTime.now();

                                                            // Trigger the scale animation
                                                            scaleNotifiers[index].value = 0.95;
                                                            Future.delayed(Duration(milliseconds: 200), () {
                                                              scaleNotifiers[index].value = 1.0;
                                                            });

                                                            if (startDate != null && endDate != null) {
                                                              if (currentDate.isBefore(startDate)) {
                                                                Utils.flushBarErrorMessage('The assignment has not started yet!', context);
                                                              } else if (currentDate.isAfter(endDate)) {
                                                                Utils.flushBarErrorMessage('The assignment has already expired!', context);
                                                              } else {
                                                                // Navigate to the next screen after the animation completes
                                                                Future.delayed(const Duration(milliseconds: 250), () {
                                                                  final selectedSlug = '${selectedData.slug}';
                                                                  final selectedEmail = '$staffemail';
                                                                  final selectedCompany = '$companyName';
                                                                  final selectedImage = '$image';

                                                                  Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (context) => Assignments(
                                                                        slug: selectedSlug,
                                                                        email: selectedEmail,
                                                                        companyName: selectedCompany,
                                                                        images: selectedImage,
                                                                      ),
                                                                    ),
                                                                  ).then((value) {
                                                                    if (value != null) {
                                                                      print('Received data from IndividualView: $value');
                                                                    }
                                                                  });
                                                                });
                                                              }
                                                            } else {
                                                              Utils.flushBarErrorMessage('Assignment dates are not available!', context);
                                                            }
                                                          },
                                                          child: AnimatedBuilder(
                                                            animation: scaleNotifiers[index],
                                                            builder: (context, child) {
                                                              return Transform.scale(
                                                                scale: scaleNotifiers[index].value,
                                                                child: Column(
                                                                  children: [
                                                                    Padding(
                                                                      padding: EdgeInsets.only(left: screenWidth * 0.05, right: screenWidth * 0.05),
                                                                      child: Container(
                                                                        decoration: BoxDecoration(
                                                                          // color: Colors.red,
                                                                          gradient: LinearGradient(
                                                                            colors: [
                                                                              Color(0xFFF8F8F8), // Equivalent to #f8f8f8
                                                                              Color(0xFFFFFFFF), // Equivalent to #ffffff
                                                                            ],
                                                                            begin: Alignment.topLeft, // Mimics 145 degrees
                                                                            end: Alignment.bottomRight,
                                                                          ),
                                                                          borderRadius: BorderRadius.circular(20), // Rounded corners
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                              color: Colors.black.withOpacity(0.1),
                                                                              blurRadius: 10, // Shadow blur
                                                                              offset: Offset(0, 4), // Shadow offset
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        child: Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            Row(
                                                                              children: [
                                                                                Padding(
                                                                                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenWidth * 0.038),
                                                                                  child: Container(
                                                                                    height: screenHeight * 0.09,
                                                                                    width: screenWidth * 0.19,
                                                                                    decoration: BoxDecoration(
                                                                                      color: Colors.white, // Background color
                                                                                      borderRadius: BorderRadius.circular(15), // Dynamic border radius
                                                                                      boxShadow: [
                                                                                        BoxShadow(
                                                                                          color: Colors.black.withOpacity(0.1), // rgba(0, 0, 0, 0.1)
                                                                                          blurRadius: 6, // blur-radius: 6px
                                                                                          offset: Offset(0, 4), // 0px X offset, 4px Y offset
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    child: Padding(
                                                                                      padding: EdgeInsets.all(screenWidth * 0.026),
                                                                                      child: image.isNotEmpty
                                                                                          ? Image.network(
                                                                                              "${AppUrl.staffUsers}/$image",
                                                                                              fit: BoxFit.cover,
                                                                                            ) // Replace with your base URL
                                                                                          : Image.asset(
                                                                                              'images/company-image.png',
                                                                                              fit: BoxFit.cover,
                                                                                            ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Container(
                                                                                      width: screenWidth * 0.5,
                                                                                      child: Text(
                                                                                        selectedData.clients?.companyName ?? '',
                                                                                        style: GoogleFonts.openSans(
                                                                                          // Replace with a similar font
                                                                                          fontSize: 16,
                                                                                          color: Color(0xff334155),
                                                                                          fontWeight: FontWeight.w600,
                                                                                        ),
                                                                                        maxLines: 2,
                                                                                        softWrap: true,
                                                                                        overflow: TextOverflow.ellipsis,
                                                                                      ),
                                                                                    ),
                                                                                    Container(
                                                                                      width: screenWidth * 0.5,
                                                                                      child: Text(
                                                                                        "${selectedData.clients?.addressLine1 ?? ''},${selectedData.clients?.addressLine2 ?? ''}",
                                                                                        style: GoogleFonts.openSans(
                                                                                          // Replace with a similar font
                                                                                          fontSize: 12,
                                                                                          color: Color(0xff6b7280),
                                                                                          fontWeight: FontWeight.w600,
                                                                                        ),
                                                                                        maxLines: 2,
                                                                                        softWrap: true,
                                                                                        overflow: TextOverflow.ellipsis,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(height: screenHeight * 0.014),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        );
                                                      })?.toList() ??
                                                      [],
                                                ),
                                              ),
                                            ),
                                            actions: [showSupportServiceModal()],
                                          );
                                        },
                                      );
                                    });
                                  }
                                },
                                child: AnimatedBuilder(
                                  animation: scaleNotifier2,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: scaleNotifier2.value,
                                      child: CategoryContainers(
                                        context: context,
                                        text: "Assignments",
                                        imagePath: "images/staff/to-do.png",
                                        height: screenHeight * 0.07,
                                        width: screenWidth * 0.2,
                                        Maincolor: Color(0xffF9FFFF),
                                      ),
                                    );
                                  },
                                )),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.013),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                                onTap: () {
                                  scaleNotifier3.value = 0.94;
                                  Future.delayed(Duration(milliseconds: 200), () {
                                    scaleNotifier3.value = 0.99;
                                  });
                                  Future.delayed(const Duration(milliseconds: 250), () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => UploadFileStaffNew()));
                                  });
                                },
                                child: AnimatedBuilder(
                                  animation: scaleNotifier3,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: scaleNotifier3.value,
                                      child: CategoryContainers(
                                        context: context,
                                        text: "Documents",
                                        imagePath: "images/staff/document.png",
                                        height: screenHeight * 0.07,
                                        width: screenWidth * 0.2,
                                        // Maincolor: Color(0xffF9FFFF),
                                        Maincolor: Colors.white,
                                      ),
                                    );
                                  },
                                )),
                            GestureDetector(
                              onTap: () {
                                scaleNotifier4.value = 0.94;
                                Future.delayed(Duration(milliseconds: 200), () {
                                  scaleNotifier4.value = 0.99;
                                });
                                if (peopleid == null) {
                                  Utils.toastMessage("No PaySlip has been created yet");
                                  print("Not Ok: $peopleid");
                                } else {
                                  final SelectedId = "$peopleid";
                                  print("Ok: $peopleid");

                                  // Navigator.push(context, MaterialPageRoute(builder: (context)=>PaySlip(userId: SelectedId,)));
                                  // Navigator.push(context, MaterialPageRoute(builder: (context)=>PaySlipNew(userId: SelectedId,)));
                                  // Navigator.push(context, MaterialPageRoute(builder: (context)=>FinalPaySlipNew(userId: SelectedId,)));
                                  Future.delayed(const Duration(milliseconds: 250), () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => FinalPaySlipLast(
                                                  userId: SelectedId,
                                                )));
                                  });
                                  // Utils.toastMessage("Updating Soon. Working on it.");
                                }
                              },
                              child: AnimatedBuilder(
                                animation: scaleNotifier4,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: scaleNotifier4.value,
                                    child: CategoryContainers(
                                      context: context,
                                      text: "Payslips",
                                      imagePath: "images/staff/money.png",
                                      height: screenHeight * 0.07,
                                      width: screenWidth * 0.2,
                                      // Maincolor: Color(0xffFFF9F2),
                                      Maincolor: Colors.white,
                                    ),
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.013),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                scaleNotifier5.value = 0.94;
                                Future.delayed(Duration(milliseconds: 200), () {
                                  scaleNotifier5.value = 0.99;
                                });
                                final SelectedId = "$id";
                                // Navigator.push(context, MaterialPageRoute(builder: (context)=>CalenderView()));
                                Future.delayed(const Duration(milliseconds: 250), () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => AnotherTest(id: SelectedId)));
                                });
                                // Utils.toastMessage("Updating Soon. Working on it.");
                              },
                              child: AnimatedBuilder(
                                animation: scaleNotifier5,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: scaleNotifier5.value,
                                    child: CategoryContainers1(
                                      context: context,
                                      text: "Availability",
                                      imagePath: "images/staff/calendar.png",
                                      height: screenHeight * 0.07,
                                      width: screenWidth * 0.2,
                                      Maincolor: Colors.white,
                                    ),
                                  );
                                },
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                scaleNotifier6.value = 0.94;
                                Future.delayed(Duration(milliseconds: 200), () {
                                  scaleNotifier6.value = 0.99;
                                });
                                Future.delayed(const Duration(milliseconds: 250), () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => StaffProfile()));
                                });
                              },
                              child: AnimatedBuilder(
                                animation: scaleNotifier6,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: scaleNotifier6.value,
                                    child: CategoryContainers(
                                      context: context,
                                      text: "Profile",
                                      imagePath: "images/staff/user.png",
                                      height: screenHeight * 0.07,
                                      width: screenWidth * 0.2,
                                      Maincolor: Colors.white,
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
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04, // 5% of the screen width
                        vertical: screenHeight * 0.03),
                    width: screenWidth,
                    color: Color(0xffe2ebf6),
                    child: Column(
                      // mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Assignments",
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.010),

                        /// Empty Container DO NOt REMOVE IT
                        // Container(height: screenHeight * 0.1,),
                      ],
                    ),
                  ),
                ]),
              );
            }
          }
        },
      ),
    );
  }

  Widget AllClients(
    String dummyImage,
    String name,
    String place,
  ) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return Column(
      children: [
        Container(
          height: screenHeight * 0.09,
          width: screenWidth * 0.25,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(dummyImage),
                fit: BoxFit.cover,
              )),
        ),
        Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        Text(place),
      ],
    );
  }

  Widget CategoryContainers({
    required BuildContext context,
    required String text,
    required String imagePath,
    required Color Maincolor,
    required double height,
    required double width,
  }) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final ValueNotifier<double> scaleNotifier = ValueNotifier(1.0);

    return Container(
      // height: screenHeight * 0.16,
      height: screenHeight * 0.15,
      width: screenWidth * 0.42,

      // padding: EdgeInsets.all(20),
      padding: EdgeInsets.all(screenHeight * 0.02),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8F9FC), Color(0xFFFFFFFF)],
          stops: [0.0, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: screenHeight * 0.07,
            width: screenWidth * 0.18,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                imagePath,
                height: height,
                width: width,
              ),
            ),
          ),
          Text(
            text,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget CategoryContainers1({
    required BuildContext context,
    required String text,
    required String imagePath,
    required Color Maincolor,
    required double height,
    required double width,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Get current date and day
    final DateTime currentDate = DateTime.now();
    final List<String> shortDayNames = ['SUN', 'MON', 'TUES', 'WED', 'THURS', 'FRI', 'SAT'];
    final String currentDay = shortDayNames[currentDate.weekday % 7]; // Get short day name
    final String currentDateString = currentDate.day.toString(); // Get day number

    return Container(
      height: screenHeight * 0.16,
      width: screenWidth * 0.42,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8F9FC), Color(0xFFFFFFFF)],
          stops: [0.0, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: screenHeight * 0.061,
            width: screenWidth * 0.12,
            decoration: BoxDecoration(color: Colors.grey.withOpacity(0.22), borderRadius: BorderRadius.circular(12)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 2,
                ),
                Text(
                  currentDay,
                  style: GoogleFonts.robotoCondensed(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    letterSpacing: 1.2,
                    height: 1.0,
                  ),
                ),
                Text(
                  currentDateString, // Display date number
                  style: GoogleFonts.robotoCondensed(
                      fontSize: 26, // Larger font size for emphasis
                      fontWeight: FontWeight.bold, // Bold weight
                      color: Colors.black87,
                      letterSpacing: 1.5,
                      height: 1.0),
                ),
              ],
            ),
          ),
          AutoSizeText(
            text,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget showSupportServiceModal() {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount;
    if (screenWidth >= 1200) {
      // Desktop
      crossAxisCount = 9;
    } else if (screenWidth >= 800) {
      // Tablet
      crossAxisCount = 6;
    } else {
      // Mobile
      crossAxisCount = 3;
    }
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContextcontext) {
            return AlertDialog(
              insetPadding: EdgeInsets.all(10),
              titlePadding: EdgeInsets.zero,
              contentPadding: EdgeInsets.zero,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              title: Container(
                width: screenWidth,
                decoration: BoxDecoration(color: AppColors.navButtonColor, borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: screenHeight * 0.013,
                    ),
                    Container(
                        width: 55,
                        height: 55,
                        // color: Colors.green,
                        child: Image.asset(
                          "images/staff/support.png",
                          color: Colors.white,
                        )),
                    SizedBox(
                      height: screenHeight * 0.005,
                    ),
                    Text(
                      "C9 Group Ltd.",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, letterSpacing: 1, color: AppColors.whiteColor),
                    ),
                    SizedBox(
                      height: screenHeight * 0.005,
                    ),
                    GestureDetector(
                        onTap: () {
                          _makePhoneCall('+44 20 8152 4574');
                          // await FlutterPhoneDirectCaller.callNumber(number);
                        },
                        child: Text(
                          "+44 20 8152 4574",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: AppColors.whiteColor),
                        )),
                    SizedBox(
                      height: screenHeight * 0.005,
                    ),
                    GestureDetector(
                        onTap: () async {
                          _sendEmail();
                        },
                        child: Text(
                          "support@c9-recruitment.com",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: AppColors.whiteColor),
                        )),
                    SizedBox(
                      height: screenHeight * 0.013,
                    ),
                  ],
                )),
              ),
              content: Container(
                width: screenWidth,
                // height: screenHeight * 0.09,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Text("Agency Support",style: TextStyle(fontSize: 22,fontWeight: FontWeight.w500, color: Colors.black),),
                    Text(
                      "Click Call or Email button for agency support.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                    ),
                    SizedBox(
                      height: screenHeight * 0.005,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _makePhoneCall('+44 20 8152 4574');
                            // await FlutterPhoneDirectCaller.callNumber(number);
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 55,
                                height: 55,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.green, AppColors.navButtonColor],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              Container(
                                width: 49,
                                height: 49,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.call,
                                    color: Colors.green,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: screenWidth * 0.1,
                        ),
                        GestureDetector(
                          onTap: () {
                            _sendEmail();
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 55,
                                height: 55,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.red, AppColors.navButtonColor],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              Container(
                                  width: 49,
                                  height: 49,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      'images/staff/settingsIcon/acountSettings/emailForgot.png',
                                      height: 30,
                                      width: 30,
                                      color: Colors.red,
                                    ),
                                  )),
                            ],
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
            );
          },
        );
      },
      child: Container(
        width: screenWidth,
        // height: screenHeight * 0.12,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          color: Color(0xFFF4F6F8), // Background color (#f4f6f8)
          border: Border(
            top: BorderSide(
              color: Color(0xFFE0E0E0), // Border color (#e0e0e0)
              width: 2.0, // Border width
            ),
          ),
        ),
        padding: EdgeInsets.all(screenWidth * 0.045),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Need help with an assignment?",
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                // Replace with a similar font
                fontSize: 14,
                color: Colors.black, // Set desired text color
              ),
            ),
            SizedBox(
              height: screenHeight * 0.008,
            ),
            Text(
              "Click here for support.",
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                  // Replace with a similar font
                  fontSize: 14,
                  color: Colors.black, // Set desired text color
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: screenHeight * 0.005,
            ),
          ],
        ),
      ),
    );
  }
}
