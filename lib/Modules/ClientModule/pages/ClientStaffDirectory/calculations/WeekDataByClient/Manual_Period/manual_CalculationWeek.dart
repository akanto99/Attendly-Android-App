import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:c9_app/Modules/ClientModule/client_screen.dart';
import 'package:c9_app/Modules/ClientModule/pages/ClientStaffDirectory/calculations/WeekDataByClient/weekdataclients_new.dart';
import 'package:c9_app/Modules/StaffModule/MODEL/period_getRates.dart';
import 'package:c9_app/loadingScreen.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/utils/routes/routes_name.dart';
import 'package:c9_app/view/widgets/error_logout.dart';
import 'package:c9_app/view/widgets/header_widgets.dart';
import 'package:c9_app/view_model/services/rolebasedmodel/user_view_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as https;
import 'package:c9_app/res/app_url.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../../utils/utils.dart';

class ManualCalculationWeek extends StatefulWidget {
  final String slug;
  final String driverSlug;
  final String stTime;
  final String enTime;
  final String PasscompanyName;
  final String Passemail;
  final String images;
  final String breakTimes;
  final String? assignStartDate;
  final String? assignEndDate;
  const ManualCalculationWeek({
    super.key,
    required this.slug,
    required this.driverSlug,
    required this.stTime,
    required this.enTime,
    required this.PasscompanyName,
    required this.Passemail,
    required this.images,
    required this.breakTimes,
    required this.assignStartDate,
    required this.assignEndDate,
  });

  @override
  State<ManualCalculationWeek> createState() => _ManualCalculationWeekState();
}

class _ManualCalculationWeekState extends State<ManualCalculationWeek> {
  /**All Controllers except selected dates**/
  List<TextEditingController> dayControllers = [];
  List<TextEditingController> nightControllers = [];
  List<TextEditingController> expenseControllers = [];
  late List<String> _dayTimes = [];
  late List<String> _nightTimes = [];
  late List<String> _expenseId = [];
  TextEditingController TotalExpenses = TextEditingController();
  TextEditingController TotalDayNightControllers = TextEditingController();

  /** Multidate and showDate Start **/
  bool isLoading = false;
  DateTime _selectedStartDate = DateTime.now();
  DateTime? _selectedEndDate;
  int? _selectedIndex;
  List<String> _formattedDates = [];

  late List<DropdownMenuItem<int>> _dropdownItems;
  late List<Map<String, DateTime>> _weekDates;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _clientgetRatesFuture = getRates();
    _weekDates = [];
    _dropdownItems = _buildDropdownItems();
    if (_dropdownItems.isNotEmpty) {
      _selectedIndex = _dropdownItems.first.value;
      _updateSelectedDates(_selectedIndex!);
    }
  }

  List<DropdownMenuItem<int>> _buildDropdownItems() {
    List<DropdownMenuItem<int>> items = [];

    DateTime currentDate = DateTime.now();
    DateTime firstDayOfMonth = DateTime(currentDate.year, currentDate.month, 1);
    DateTime lastDayOfMonth = DateTime(currentDate.year, currentDate.month + 1, 0);
    DateTime startDate = firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday - 1));
    DateTime endDate = startDate.add(Duration(days: 6));
    while (startDate.isBefore(lastDayOfMonth.add(Duration(days: 1)))) {
      if (endDate.isBefore(lastDayOfMonth) || endDate.month == currentDate.month) {
        items.add(
          DropdownMenuItem<int>(
            value: items.length,
            child: Text(_getDateString(startDate, endDate)),
          ),
        );
        _weekDates.add({
          'startDate': startDate,
          'endDate': endDate,
        });
      }
      startDate = startDate.add(Duration(days: 7));
      endDate = startDate.add(Duration(days: 6));
    }
    return items;
  }

  void _updateSelectedDates(int index) {
    if (index >= 0 && index < _weekDates.length) {
      final week = _weekDates[index];
      final startDate = week['startDate']!;
      final endDate = week['endDate']!;

      List<String> formattedDates = [];
      DateTime currentDate = startDate;

      while (currentDate.isBefore(endDate.add(Duration(days: 1)))) {
        formattedDates.add(_formatDate(currentDate));
        currentDate = currentDate.add(Duration(days: 1));
      }

      setState(() {
        _selectedStartDate = startDate;
        _selectedEndDate = endDate;
        _formattedDates = formattedDates;
        // Update controllers list to match the number of formatted dates
        if (_formattedDates.length > dayControllers.length) {
          int difference = _formattedDates.length - dayControllers.length;
          for (int i = 0; i < difference; i++) {
            dayControllers.add(TextEditingController());
            nightControllers.add(TextEditingController());
            expenseControllers.add(TextEditingController());
          }
        } else if (_formattedDates.length < dayControllers.length) {
          dayControllers.removeRange(_formattedDates.length, dayControllers.length);
          nightControllers.removeRange(_formattedDates.length, nightControllers.length);
          expenseControllers.removeRange(_formattedDates.length, expenseControllers.length);
        }
      });
    }
  }

  Future<void> postData() async {
    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final DateFormat inputDateFormat = DateFormat('dd-MM-yyyy');

    try {
      String apiUrl = '${AppUrl.baseUrl}/api/app/client/manual/calculation/client/${widget.slug}';
      print('API URL: $apiUrl');

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      };

      Map<String, String> dates = {};
      Map<String, String> dayHours = {};
      Map<String, String> nightHours = {};
      Map<String, String> expenses = {};

      for (int i = 0; i < dayControllers.length; i++) {
        try {
          DateTime date = inputDateFormat.parse(_formattedDates[i]);
          String formattedDate = formatter.format(date);
          dates[i.toString()] = formattedDate;
          dayHours[i.toString()] = dayControllers[i].text.isEmpty ? "0" : dayControllers[i].text;
          nightHours[i.toString()] = nightControllers[i].text.isEmpty ? "0" : nightControllers[i].text;
          expenses[i.toString()] = expenseControllers[i].text.isEmpty ? "0" : expenseControllers[i].text;
        } catch (e) {
          print('Date parsing error for ${_formattedDates[i]}: $e');
        }
      }

      final Map<String, dynamic> data = {
        "date": dates,
        "day_hour": dayHours,
        "total": TotalDayNightControllers.text.isEmpty ? "0" : TotalDayNightControllers.text,
        "night_hour": nightHours,
        "expenses": expenses,
        "totalExpenses": TotalExpenses.text.isEmpty ? "0" : TotalExpenses.text,
        "_readAndroidBuildData": _deviceData,
        'deviceInfo': Platform.isAndroid ? 'Android' : 'iOS',
      };

      if (Platform.isAndroid) {
        var androidData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
        androidData.forEach((key, value) {
          data['_readAndroidBuildData[$key]'] = value.toString();
        });
        print("Android data: $androidData");
      } else if (Platform.isIOS) {
        var iosData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
        iosData.forEach((key, value) {
          data['_readIosDeviceInfo[$key]'] = value.toString();
        });
      }

      print("Data to be posted: $data");

      var response = await https.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(data),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Successful response
        setState(() {
          isLoading = false;
        });
        _clearFields();
        Future.delayed(Duration(seconds: 2), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WeekDataClientListNew(
                slug: widget.slug,
                stTime: widget.stTime,
                enTime: widget.enTime,
                driverSlug: widget.driverSlug,
                companyName: widget.PasscompanyName,
                email: widget.Passemail,
                images: widget.images,
                breakTimes: widget.breakTimes,
                assignStartDate: widget.assignStartDate,
                assignEndDate: widget.assignEndDate,
              ),
            ),
          );
        });

        Utils.flushBarSuccessMessage("Data submitted successfully", context);
      } else if (response.statusCode == 422) {
        // Validation error
        setState(() {
          isLoading = false;
        });
        print('Validation Error Response Body: ${response.body}');
        Map<String, dynamic> errorJson = json.decode(response.body);
        if (errorJson.containsKey('message')) {
          String errorMessage = errorJson['message'];
          Utils.flushBarErrorMessage(errorMessage, context);
        } else {
          Utils.flushBarErrorMessage("Validation failed.", context);
        }
      } else if (response.statusCode == 500) {
        // Server error (status 500), check if data was still submitted
        setState(() {
          isLoading = false;
        });
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        // Optionally, check for a success message in the response body
        if (response.body.contains('Success')) {
          Utils.flushBarSuccessMessage("Data submitted successfully (but received status code 500)", context);
        } else {
          Utils.flushBarErrorMessage("Please check with support.", context);
        }
      } else {
        // Other unsuccessful responses
        setState(() {
          isLoading = false;
        });
        print('Unsuccessful Response: ${response.statusCode}');
        print('Response Body: ${response.body}');
        Utils.flushBarErrorMessage("Failed to submit data.", context);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error during data submission: $e');
      print('Total Day-Night Controllers: ${TotalDayNightControllers.text}');
      print('Total Expenses: ${TotalExpenses.text}');
      Utils.flushBarErrorMessage("An error occurred while submitting the data.", context);
    }
  }

  void _clearFields() {
    setState(() {
      _dayTimes.clear();
      _nightTimes.clear();
      _expenseId.clear();
      TotalDayNightControllers.clear();
      TotalExpenses.clear();
      dayControllers.forEach((controller) => controller.clear());
      nightControllers.forEach((controller) => controller.clear());
      expenseControllers.forEach((controller) => controller.clear());
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  String _getDateString(DateTime startDate, DateTime endDate) {
    String formatDate(DateTime date) {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }

    return '${formatDate(startDate)} - ${formatDate(endDate)}';
  }
  /** Multidate and showDate End **/

  /** DaysName List **/
  final DaysNameIndex = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];

  /** UI Validation **/
  bool _hasDataInLists() {
    return _dayTimes.any((element) => element.isNotEmpty) ||
        _nightTimes.any((element) => element.isNotEmpty) ||
        _expenseId.any((element) => element.isNotEmpty);
  }


  late Future<PeriodGetRates?> _clientgetRatesFuture;
  Future<PeriodGetRates?> getRates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';

    final String apiUrl = '${AppUrl.baseUrl}/api/app/get-staff-assigned-rates/${widget.driverSlug}';
    print(apiUrl);
    final response = await https.get(Uri.parse(apiUrl), headers: {
      'Authorization': 'Bearer $_token',
    });
    if (response.statusCode == 200) {
      return periodGetRatesFromJson(response.body);
    } else {
      throw Exception('Failed to load');
    }
  }



  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;

    return WillPopScope(
      onWillPop: () async {
        return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: Text(
                  "Are you sure you want to leave without submitting?",
                  style: TextStyle(fontSize: 16),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                actions: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context, true);
                      Navigator.pop(context, true);
                    },
                    child: Container(
                      width: screenWidth * 0.3,
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.015,
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
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context, false);
                    },
                    child: Container(
                      width: screenWidth * 0.3,
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.015,
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
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ) ??
            false;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: ResPonsiveUi(
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
    final userPrefernece = Provider.of<UserViewModel>(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: screenHeight * 0.013,),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
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
                          content: SizedBox(
                            width: screenWidth * 0.6,
                            child: Text(
                              "Are you sure you want to leave without submitting?",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          actionsAlignment: MainAxisAlignment.center,
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    width: screenWidth * 0.3,
                                    padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.015,
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
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.05),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    width: screenWidth * 0.3,
                                    padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.015,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.navOpacity,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    // color:  AppColors.navOpacity,
                                    child: Center(
                                      child: Text(
                                        'No',
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
                              ],
                            )
                          ],
                        );
                      },
                    );
                  },
                  child: HeaderRow(Icons.arrow_back),
                ),
                Text(
                  "Manual Timesheet",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
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
                          content: SizedBox(
                            width: screenWidth * 0.6,
                            child: Text(
                              "Are you sure you want to leave without submitting?",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          actionsAlignment: MainAxisAlignment.center,
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context, MaterialPageRoute(builder: (context) => ClientCurveNabBar()));
                                  },
                                  child: Container(
                                    width: screenWidth * 0.3,
                                    padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.015,
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
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.05),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    width: screenWidth * 0.3,
                                    padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.015,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.navOpacity,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    // color:  AppColors.navOpacity,
                                    child: Center(
                                      child: Text(
                                        'No',
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
                              ],
                            )
                          ],
                        );
                      },
                    );
                  },
                  child: HeaderRow(Icons.home),
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.023,),


          // Center(
          //   child: FutureBuilder<PeriodGetRates?>(
          //     future: _clientgetRatesFuture,
          //     builder: (context, snapshot) {
          //       if (snapshot.connectionState == ConnectionState.waiting) {
          //         return Container(
          //           height: screenHeight * 0.7,
          //           width: screenWidth,
          //           color: AppColors.whiteColor,
          //           child: LoadingScreen(),
          //         );
          //       } else if (snapshot.hasError) {
          //         return Column(
          //           children: [
          //             SizedBox(height: screenHeight * 0.013),
          //             Padding(
          //               padding: const EdgeInsets.only(left: 10.0),
          //               child: Align(
          //                   alignment: Alignment.centerLeft,
          //                   child: GestureDetector(
          //                       onTap: () {
          //                         Navigator.push(context, MaterialPageRoute(builder: (context) => ClientCurveNabBar()));
          //                       },
          //                       child: HeaderRow(Icons.arrow_back))),
          //             ),
          //             SizedBox(height: screenHeight * 0.013),
          //             ErrorLogOutScreen(
          //               screenHeight: screenHeight* 0.65,
          //               screenWidth: screenWidth,
          //               errorMessage: 'Oops! Something went wrong.',
          //               subMessage: 'Try logging out and back in.',
          //               icon: CupertinoIcons.exclamationmark_circle,
          //               buttonText: 'Logout',
          //               onButtonPressed: () {
          //                 userPrefernece.remove().then((value) {
          //                   Navigator.pushNamed(context, RoutesName.login);
          //                 });
          //               },
          //             ),
          //           ],
          //         );
          //         // return Text("${snapshot.error}");
          //       } else {
          //         final getRates = snapshot.data?.availabilityStatus;
          //         if ((getRates != null && getRates.isNotEmpty)) {
          //           return Column(
          //             children: [
          //
          //             ],
          //           );
          //         }else
          //         {
          //           return   Align(
          //               alignment: Alignment.center,
          //               child: Container(
          //                 padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
          //                 height: screenHeight * 0.72,
          //                 width: screenWidth,
          //                 color: AppColors.whiteColor,
          //                 child: Center(
          //                   child: Column(
          //                     mainAxisAlignment: MainAxisAlignment.center,
          //                     children: [
          //                       Icon(
          //                         Icons.rate_review_outlined,
          //                         color: AppColors.navColor,
          //                         size: screenWidth * 0.12,
          //                       ),
          //                       SizedBox(
          //                         height: screenHeight * 0.02,
          //                       ),
          //                       Text(
          //                         'No Rates Available',
          //                         style: TextStyle(
          //                           fontSize: screenWidth * 0.045,
          //                           fontWeight: FontWeight.bold,
          //                           color: AppColors.navColor,
          //                         ),
          //                         textAlign: TextAlign.center,
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          //               ));
          //         }
          //       }
          //     },
          //   ),
          // ),
          // Text(getRates),
          _buildDateDropdown(
            _selectedStartDate,
                (DateTime date) {
              setState(() {
                _selectedStartDate = date;
              });
            },
          ),
          SizedBox(
            height: screenHeight * 0.013,
          ),
          Center(
            child: Container(
              width: screenWidth * 0.95,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white, boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  offset: Offset(0, 2),
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ]),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.013),
                  if (_selectedEndDate != null) ...[
                    ..._formattedDates.asMap().entries.map((entry) {
                      int index = entry.key;
                      String date = entry.value;

                      // Ensure index is valid before using it
                      if (index < dayControllers.length &&
                          index < nightControllers.length &&
                          index < expenseControllers.length) {
                        return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    width: screenWidth * 0.23,
                                    child: Center(
                                      child: Text(
                                        "${DaysNameIndex[index]}",
                                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.013),
                                  Text(
                                    date,
                                    style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.5)),
                                  ),
                                ],
                              ),
                              Container(
                                // height: screenHeight*0.065,
                                width: screenWidth * 0.67,

                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  // color: Color(0xffFFF3E5),
                                  color: AppColors.navOpacity,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 7.5,bottom: 7.5),
                                  child: Column(
                                    children: [
                                      // SizedBox(height: screenHeight* 0.013,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          // if (getRates=="only_day_available")...[
                                          //   Container(
                                          //     height: screenHeight * 0.06,
                                          //     // width:screenWidth*0.315,
                                          //     width: getRates == "only_day_available" ? screenWidth * 0.64 : screenWidth * 0.315,
                                          //     decoration: BoxDecoration(
                                          //         color: Colors.white,
                                          //         borderRadius: BorderRadius.circular(8)
                                          //     ),
                                          //     child: TextFormField(
                                          //       controller: dayControllers[index],
                                          //       keyboardType: TextInputType.numberWithOptions(decimal: true),
                                          //       inputFormatters: <TextInputFormatter>[
                                          //         FilteringTextInputFormatter.allow(RegExp(r'^\d{0,5}(\.\d{0,5})?$')),
                                          //       ],
                                          //       decoration: InputDecoration(
                                          //         hintText: 'Day Time 00:00',
                                          //         hintStyle: TextStyle(
                                          //           fontSize: 14.0,
                                          //           fontWeight: FontWeight.normal,
                                          //           color: Colors.grey, // Change the color if needed
                                          //         ),
                                          //         alignLabelWithHint: true,
                                          //         isDense: true,
                                          //         border: OutlineInputBorder(
                                          //           borderSide: BorderSide.none,
                                          //         ),
                                          //       ),
                                          //       onChanged: (_) {
                                          //         if (_.isNotEmpty) {
                                          //           double hours = double.parse(_);
                                          //           if (hours > 24) {
                                          //             dayControllers[index].text = '24';
                                          //           }
                                          //         }
                                          //         _updateTotalDayNightControllers();
                                          //       },
                                          //     ),
                                          //   ),
                                          // ] else if (getRates=="only_night_available")...[
                                          //   Container(
                                          //     height: screenHeight * 0.06,
                                          //     width: getRates == "only_day_available" ? screenWidth * 0.64 : screenWidth * 0.315,
                                          //     decoration: BoxDecoration(
                                          //         color: Colors.white,
                                          //         borderRadius: BorderRadius.circular(8)
                                          //     ),
                                          //     child: Align(
                                          //       alignment: Alignment.center,// Center widget added here
                                          //       child: TextFormField(
                                          //         controller: nightControllers[index],
                                          //         keyboardType: TextInputType.numberWithOptions(decimal: true),
                                          //         inputFormatters: <TextInputFormatter>[
                                          //           FilteringTextInputFormatter.allow(RegExp(r'^\d{0,5}(\.\d{0,5})?$')),
                                          //         ],
                                          //         decoration: InputDecoration(
                                          //           hintText: 'Night Time 00:00',
                                          //           hintStyle: TextStyle(
                                          //             fontSize: 14.0,
                                          //             fontWeight: FontWeight.normal,
                                          //             color: Colors.grey, // Change the color if needed
                                          //           ),
                                          //           alignLabelWithHint: true,
                                          //           isDense: true,
                                          //           border: OutlineInputBorder(
                                          //             borderSide: BorderSide.none,
                                          //           ),
                                          //         ),
                                          //         onChanged: (_) {
                                          //           if (_.isNotEmpty) {
                                          //             double hours = double.parse(_);
                                          //             if (hours > 24) {
                                          //               nightControllers[index].text = '24';
                                          //             }
                                          //           }
                                          //           _updateTotalDayNightControllers();
                                          //         },
                                          //       ),
                                          //     ),
                                          //   ),
                                          // ]else...[
                                          Container(
                                            height: screenHeight * 0.06,
                                            // width:screenWidth*0.315,
                                            width:  screenWidth * 0.315,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(8)
                                            ),
                                            child: Align(
                                              alignment: Alignment.center,// Center widget added here
                                              child: TextFormField(
                                                controller: dayControllers[index],
                                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                inputFormatters: <TextInputFormatter>[
                                                  FilteringTextInputFormatter.allow(RegExp(r'^\d{0,5}(\.\d{0,5})?$')),
                                                ],
                                                decoration: InputDecoration(
                                                  hintText: 'Day Time 00:00',
                                                  hintStyle: TextStyle(
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.normal,
                                                    color: Colors.grey, // Change the color if needed
                                                  ),
                                                  alignLabelWithHint: true,
                                                  isDense: true,
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide.none,
                                                  ),
                                                ),
                                                onChanged: (_) {
                                                  if (_.isNotEmpty) {
                                                    double hours = double.parse(_);
                                                    if (hours > 24) {
                                                      dayControllers[index].text = '24';
                                                    }
                                                  }
                                                  _updateTotalDayNightControllers();
                                                },
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 5,),
                                          Container(
                                            height: screenHeight * 0.06,
                                            width: screenWidth * 0.315,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(8)
                                            ),
                                            child: Align(
                                              alignment: Alignment.center,// Center widget added here
                                              child: TextFormField(
                                                controller: nightControllers[index],
                                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                                inputFormatters: <TextInputFormatter>[
                                                  FilteringTextInputFormatter.allow(RegExp(r'^\d{0,5}(\.\d{0,5})?$')),
                                                ],
                                                decoration: InputDecoration(
                                                  hintText: 'Night Time 00:00',
                                                  hintStyle: TextStyle(
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.normal,
                                                    color: Colors.grey, // Change the color if needed
                                                  ),
                                                  alignLabelWithHint: true,
                                                  isDense: true,
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide.none,
                                                  ),
                                                ),
                                                onChanged: (_) {
                                                  if (_.isNotEmpty) {
                                                    double hours = double.parse(_);
                                                    if (hours > 24) {
                                                      nightControllers[index].text = '24';
                                                    }
                                                  }
                                                  _updateTotalDayNightControllers();
                                                },
                                              ),
                                            ),
                                          ),
                                          // ]

                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top:7.5),
                                        child: Container(
                                          height: screenHeight * 0.06,
                                          width: screenWidth*0.64,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(8)
                                          ),
                                          child: Align(
                                            alignment: Alignment.center,// Center widget added here
                                            child: TextFormField(
                                              controller: expenseControllers[index],
                                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                                              inputFormatters: <TextInputFormatter>[
                                                FilteringTextInputFormatter.allow(RegExp(r'^\d{0,5}(\.\d{0,5})?$')),
                                              ],
                                              decoration: InputDecoration(
                                                hintText: 'Expense 00.00',
                                                hintStyle: TextStyle(
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.grey, // Change the color if needed
                                                ),
                                                alignLabelWithHint: true,
                                                isDense: true,
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide.none,
                                                ),
                                              ),
                                              onChanged: (_) {
                                                _updateTotalExpenses();
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    }).toList()
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    'Total Hour',
                    maxLines: 1,
                    style: GoogleFonts.roboto(
                      textStyle: TextStyle(fontSize: 18),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.005,
                  ),
                  Container(
                    height: screenHeight * 0.06,
                    width: screenWidth * 0.45,
                    decoration: BoxDecoration(
                      // color: AppColors.navColor,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(width: 0.1, color: AppColors.navColor)),
                    child: TextFormField(
                      controller: TotalDayNightControllers,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                      ],
                      decoration: InputDecoration(
                        hintText: '00.00',
                        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6), fontSize: 14),
                        alignLabelWithHint: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                      readOnly: true,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    'Total Expenses',
                    maxLines: 1,
                    style: GoogleFonts.roboto(
                      textStyle: TextStyle(fontSize: 18),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.005,
                  ),
                  Container(
                    height: screenHeight * 0.06,
                    width: screenWidth * 0.45,
                    decoration: BoxDecoration(
                      // color: AppColors.navColor,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(width: 0.1, color: AppColors.navColor)),
                    child: TextFormField(
                      controller: TotalExpenses,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                      ],
                      decoration: InputDecoration(
                        hintText: '00.00',
                        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6), fontSize: 14),
                        alignLabelWithHint: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                      readOnly: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: screenHeight * 0.013,
          ),
          GestureDetector(
            onTap: () async {
              if (_hasDataInLists()) {
                await postData();
              } else {
                Utils.flushBarErrorMessage("Input fields are empty", context);
              }
            },
            child: Container(
              height: screenHeight * 0.05,
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
          SizedBox(
            height: screenHeight * 0.1,
          ),
        ],
      ),
    );
  }

  Widget _buildDateDropdown(DateTime selectedDate, ValueChanged<DateTime> onChanged) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: screenHeight * 0.07,
          width: screenWidth * 0.95,
          decoration: BoxDecoration(
            // color: Color(0xffFFF3E5),
            color: AppColors.navOpacity,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5.0, left: 5, bottom: 5),
                child: Container(
                  height: screenHeight * 0.07,
                  width: screenWidth * 0.28,
                  decoration: BoxDecoration(
                    color: AppColors.navColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'Select Date',
                      maxLines: 1,
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(fontSize: 17, color: Colors.white),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: screenHeight * 0.06,
                width: screenWidth * 0.6,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: DropdownButton<int>(
                    value: _selectedIndex,
                    items: _dropdownItems,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedIndex = value;
                          _updateSelectedDates(value);
                        });
                      }
                    },
                    iconEnabledColor: AppColors.navColor,
                    underline: Container(),
                    style: TextStyle(fontSize: 15, letterSpacing: 1, color: AppColors.blackColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _updateTotalDayNightControllers() {
    _dayTimes.clear();
    _nightTimes.clear();

    for (TextEditingController controller in dayControllers) {
      if (controller.text.isNotEmpty) {
        _dayTimes.add(controller.text);
      }
    }

    for (TextEditingController controller in nightControllers) {
      if (controller.text.isNotEmpty) {
        _nightTimes.add(controller.text);
      }
    }

    TotalDayNightControllers.text = _calculateTotal(_dayTimes, _nightTimes);
  }

  void _updateTotalExpenses() {
    _expenseId.clear();

    for (TextEditingController controller in expenseControllers) {
      if (controller.text.isNotEmpty) {
        _expenseId.add(controller.text);
      }
    }

    TotalExpenses.text = _calculateTotalExpenses(_expenseId);
  }

  String _calculateTotal(List<String> dayTimes, List<String> nightTimes) {
    double sum = 0.0;
    for (String dayTime in dayTimes) {
      sum += double.parse(dayTime);
    }
    for (String nightTime in nightTimes) {
      sum += double.parse(nightTime);
    }
    return sum.toString();
  }

  String _calculateTotalExpenses(List<String> expenses) {
    double sum = 0.0;
    for (String expense in expenses) {
      sum += double.parse(expense);
    }
    return sum.toString();
  }

  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};

    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{'Error:': 'Failed to get platform version.'};
    }
    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'brand': build.brand,
      'device': build.device,
      'model': build.model,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'brand': data.name,
      'device': data.systemName,
      'model': data.model,
    };
  }
}
