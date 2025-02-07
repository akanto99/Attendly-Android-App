import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:c9_app/DarkAndLightTheme/theme_provider.dart';
import 'package:c9_app/Modules/ClientModule/client_screen.dart';
import 'package:c9_app/Modules/ClientModule/pages/ClientStaffDirectory/calculations/WeekDataByClient/weekdataclients_new.dart';
import 'package:c9_app/Modules/ClientModule/pages/noInternetConnectionWidget.dart';
import 'package:c9_app/Modules/StaffModule/MODEL/period_getRates.dart';
import 'package:c9_app/loadingScreen.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/utils/routes/routes_name.dart';
import 'package:c9_app/utils/utils.dart';
import 'package:c9_app/view/widgets/error_logout.dart';
import 'package:c9_app/view_model/services/rolebasedmodel/user_view_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as https;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class PeriodCalculationWeek extends StatefulWidget {
  final String slug;
  final String driverSlug;
  final String startedTime;
  final String endedTime;
  final String PasscompanyName;
  final String Passemail;
  final String images;
  final String breakTimes;
  final String? assignStartDate;
  final String? assignEndDate;

  const PeriodCalculationWeek({
    super.key,
    required this.slug,
    required this.driverSlug,
    required this.startedTime,
    required this.endedTime,
    required this.PasscompanyName,
    required this.Passemail,
    required this.breakTimes,
    required this.images,
    required this.assignStartDate,
    required this.assignEndDate,
  });

  @override
  State<PeriodCalculationWeek> createState() => _PeriodCalculationWeekState();
}

class _PeriodCalculationWeekState extends State<PeriodCalculationWeek>with WidgetsBindingObserver{
  bool isLoading = false;
  late String totalShiftHours;

  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool _showNoInternetConnectionMessage = false;


  TextEditingController _startSDateController = TextEditingController();
  TextEditingController _StartTimePickerController = TextEditingController();
  TextEditingController _EndTimePickerController = TextEditingController();
  TextEditingController  _ExpensesController= TextEditingController();
  TextEditingController  _DayTimeController= TextEditingController();
  TextEditingController  _NightTimeController= TextEditingController();
  TextEditingController  _TotalHourController= TextEditingController();


  Future<void> _NomalCalculationPost() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';
    try {
      String apiUrl = '${AppUrl.baseUrl}/api/app/client/calculation/store/${widget.slug}';
      var request = https.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers.addAll({
        'Authorization': 'Bearer $_token',
      });
      // request.fields['start_date'] = _startSDateController.text.toString();
      if (_startSDateController.text.isNotEmpty) {
        request.fields['start_date'] = DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(_startSDateController.text));
      }
      request.fields['start_time'] = _StartTimePickerController.text.toString();
      request.fields['end_time'] = _EndTimePickerController.text.toString();
      request.fields['expenses'] = _ExpensesController.text.toString();
      request.fields['day_shift'] = _DayTimeController.text.toString();
      request.fields['night_shift'] = _NightTimeController.text.toString();

      // // Check _DayTimeController value
      // double dayShiftValue = double.tryParse(_DayTimeController.text) ?? 0.0;
      // request.fields['day_shift'] =
      // (dayShiftValue == 11.98)
      //     ? (dayShiftValue + 0.02).toStringAsFixed(2)
      //     : dayShiftValue.toStringAsFixed(2);
      //
      //
      // double nightShiftValue =
      //     double.tryParse(_NightTimeController.text) ?? 0.0;
      // request.fields['night_shift'] =
      // (nightShiftValue <= 0.02) ? '00.00' : nightShiftValue.toStringAsFixed(2);
      //

      request.fields['deviceInfo'] = Platform.isAndroid ? 'Android' : 'iOS';
      if (Platform.isAndroid) {
        var androidData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
        androidData.forEach((key, value) {
          request.fields['_readAndroidBuildData[$key]'] = value.toString();});
        print("json formate Data $androidData");
      } else if (Platform.isIOS) {
        var iosData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
        iosData.forEach((key, value) {request.fields['_readIosDeviceInfo[$key]'] = value.toString();});
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        print('Registration Successful');
        Utils.flushBarSuccessMessage("Data submitted successfully", context);
        print(await response.stream.bytesToString());
        _clearFields();
        Future.delayed(Duration(seconds: 2), () {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WeekDataClientListNew(
                slug: widget.slug,
                driverSlug: widget.driverSlug,
                stTime: widget.startedTime,
                enTime: widget.endedTime,
                companyName: widget.PasscompanyName,
                email: widget.Passemail,
                images: widget.images,
                breakTimes: widget.breakTimes,
                assignStartDate:widget.assignStartDate,
                assignEndDate:widget.assignEndDate,
              ),
            ),
          );
        });
      } else if (response.statusCode == 422) {
        setState(() {
          isLoading = false;
        });
        var errorResponse = await response.stream.bytesToString();
        print(errorResponse);
        Map<String, dynamic> errorJson = json.decode(errorResponse);
        if (errorJson.containsKey('message')) {
          String errorMessage = errorJson['message'];
          Utils.flushBarErrorMessage(errorMessage, context);
        } else {
          Utils.flushBarErrorMessage("Failed to register.", context);
        }
      }
      else {
        setState(() {
          isLoading = false;
        });
        Utils.flushBarErrorMessage("Data submittion failed", context);
        print('Failed to register. Status code: ${response.statusCode}');
        print(response.reasonPhrase);

      }
    } catch (e) {
      print('Error during registration: $e');
    }
  }


  late TimeOfDay startTime;
  late TimeOfDay endTime;
  late String a;
  late String b;

  late String d;
  late String e;

  late String differenceText;
  late String daytimeText;
  late String nighttimeText;


  @override
  void initState() {
    initPlatformState();
    super.initState();
    _getCurrentDate();
    _clientgetRatesFuture = getRates();
    WidgetsBinding.instance.addObserver(this);
    _startSDateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    // _startSDateController.text = DateTime.now().toString().substring(0, 10);
    startTime = TimeOfDay.now();
    endTime = TimeOfDay.now();
    a = widget.startedTime;
    b = widget.endedTime;

    d = '';
    e = '';

    differenceText = '';
    daytimeText = '';
    nighttimeText = '';

    _calculateTimeDifference();
    _startSDateController.addListener(() {
      _updateNextDate();
    });
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result)async{
      bool hasInternet = await _hasInternetConnection();
      setState(() {
        _showNoInternetConnectionMessage = (result == ConnectivityResult.none || !hasInternet);
      });
    });
  }

  @override
  void dispose() {
    // Dispose the controllers
    _ExpensesController.dispose();
    _DayTimeController.dispose();
    _NightTimeController.dispose();
    _connectivitySubscription.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
  late String nextDate = "";


  // void _updateNextDate() {
  //   if (startTime != null && endTime != null) {
  //     final now = DateTime.now();
  //     final startDateTime = DateTime(now.year, now.month, now.day, startTime!.hour, startTime!.minute);
  //     final endDateTime = DateTime(now.year, now.month, now.day, endTime!.hour, endTime!.minute);
  //
  //     if (startDateTime.isAfter(endDateTime)) {
  //       DateTime selectedDate = DateTime.parse(_startSDateController.text);
  //       setState(() {
  //         nextDate = DateFormat('dd-MM-yyyy').format(selectedDate.add(Duration(days: 1)));
  //       });
  //     } else {
  //       setState(() {
  //         nextDate = '';
  //       });
  //     }
  //   } else {
  //     setState(() {
  //       nextDate = '';
  //     });
  //   }
  // }


  void _selectStartTime(TimeOfDay newTime) {
    setState(() {
      startTime = newTime;
      d = '${startTime.hour}:${startTime.minute}';});
    _calculateTimeDifference();
    _updateNextDate();
  }

  void _selectEndTime(TimeOfDay newTime) {
    setState(() {
      endTime = newTime;
      e = '${endTime.hour}:${endTime.minute}';});
    _calculateTimeDifference();
    _updateNextDate();
  }

  void _updateNextDate() {
    if (startTime != null && endTime != null) {
      final now = DateTime.now();
      final startDateTime = DateTime(now.year, now.month, now.day, startTime!.hour, startTime!.minute);
      final endDateTime = DateTime(now.year, now.month, now.day, endTime!.hour, endTime!.minute);

      if (startDateTime.isAfter(endDateTime)) {
        DateTime selectedDate = DateFormat('dd/MM/yyyy').parse(_startSDateController.text);
        setState(() {
          nextDate = DateFormat('dd/MM/yyyy').format(selectedDate.add(Duration(days: 1)));
        });
      } else {
        setState(() {
          nextDate = '';
        });
      }
    } else {
      setState(() {
        nextDate = '';
      });
    }
  }


  void _calculateTimeDifference() {


    final int totalStartMinutes = startTime.hour * 60 + startTime.minute;
    final int totalEndMinutes = endTime.hour * 60 + endTime.minute;
    final int dayTimeStartMinutes = _convertTimeToMinutes(a);
    final int dayTimeEndMinutes = _convertTimeToMinutes(b);

    int nightShiftMinutes = 0;
    int dayShiftMinutes = 0;
    int ab=0;
    /** Previous Version DO NOT DELETE THIS
    if (totalStartMinutes > totalEndMinutes) {
      nightShiftMinutes = (1440 - totalStartMinutes) + totalEndMinutes;
      dayShiftMinutes = 0;

      if (totalEndMinutes <= dayTimeStartMinutes) {
        nightShiftMinutes = totalEndMinutes - totalStartMinutes;
        nightShiftMinutes += 1440;
        nightShiftMinutes -= totalStartMinutes;
        dayShiftMinutes = nightShiftMinutes - (nightShiftMinutes - totalStartMinutes);
        print("a = $nightShiftMinutes $dayShiftMinutes");
        //

        if (totalEndMinutes < dayTimeStartMinutes && totalStartMinutes > dayTimeEndMinutes) {
          dayShiftMinutes = 0;
        }
        if ((totalStartMinutes >= totalEndMinutes) && (dayTimeStartMinutes >= totalStartMinutes)) {
          dayShiftMinutes = 720;
          nightShiftMinutes = 720 - (totalStartMinutes - totalEndMinutes);
          print("b = $nightShiftMinutes $dayShiftMinutes");
        } else if (totalStartMinutes >= totalEndMinutes && totalEndMinutes <= dayTimeStartMinutes) {
          dayShiftMinutes = 720;
          nightShiftMinutes = 720 - (totalStartMinutes - totalEndMinutes);
          print("c = $nightShiftMinutes $dayShiftMinutes");
          if (totalEndMinutes < totalStartMinutes) {
            dayShiftMinutes = 0;
            nightShiftMinutes = 1440 - (totalStartMinutes - totalEndMinutes);
            print("d = $nightShiftMinutes $dayShiftMinutes");
          }
          if (totalStartMinutes < dayTimeEndMinutes) {
            dayShiftMinutes = dayTimeEndMinutes - totalStartMinutes;
            nightShiftMinutes = 1440 - (totalStartMinutes - totalEndMinutes) - dayShiftMinutes;
            print("e = $nightShiftMinutes $dayShiftMinutes");
          }
          if (dayTimeStartMinutes < totalStartMinutes && totalStartMinutes <= 720) {
            dayShiftMinutes = (720 - (totalStartMinutes - dayTimeStartMinutes)).toInt();
            nightShiftMinutes = (720 - (dayTimeStartMinutes - totalEndMinutes)).toInt();
            print("f = $nightShiftMinutes $dayShiftMinutes");
          }
        }
      } else if (totalEndMinutes <= dayTimeEndMinutes) {
        int startMinutes = 1440 - totalStartMinutes;
        int endMinutes = 1440 - totalEndMinutes;

        dayShiftMinutes = totalEndMinutes - dayTimeStartMinutes;
        nightShiftMinutes = startMinutes + dayTimeStartMinutes;
        print("g = $nightShiftMinutes $dayShiftMinutes");

        if (nightShiftMinutes >= 12 * 60) {
          int extraShift = nightShiftMinutes - 12 * 60;
          nightShiftMinutes = nightShiftMinutes - extraShift;
          dayShiftMinutes = dayShiftMinutes + extraShift;
          print("h = $nightShiftMinutes $dayShiftMinutes");
        }
      } else {
        nightShiftMinutes = dayTimeStartMinutes - totalStartMinutes;
        dayShiftMinutes = dayTimeEndMinutes - dayTimeStartMinutes;
        ab= totalStartMinutes - totalEndMinutes;
        nightShiftMinutes = (1440) - (dayShiftMinutes + ab) ;
        print(ab);
        print("i = $nightShiftMinutes ");
      }
    }
    **/

    /** Updated Version By Himu Start **/
    if (totalStartMinutes > totalEndMinutes) {
      nightShiftMinutes = (1440 - totalStartMinutes) + totalEndMinutes;
      dayShiftMinutes = 0;

      if (totalEndMinutes <= dayTimeStartMinutes) {
        nightShiftMinutes = totalEndMinutes - totalStartMinutes;
        nightShiftMinutes += 1440;
        nightShiftMinutes -= totalStartMinutes;
        dayShiftMinutes = nightShiftMinutes - (nightShiftMinutes - totalStartMinutes);
        print("a = $nightShiftMinutes $dayShiftMinutes");
        //

        if (totalEndMinutes < dayTimeStartMinutes && totalStartMinutes > dayTimeEndMinutes) {
          dayShiftMinutes = 0;
        }
        if ((totalStartMinutes >= totalEndMinutes) && (dayTimeStartMinutes >= totalStartMinutes)) {
          dayShiftMinutes = 720;
          nightShiftMinutes = 720 - (totalStartMinutes - totalEndMinutes);
          print("b = $nightShiftMinutes $dayShiftMinutes");


          /// UPDATED BY HIMU  Start
          if(totalEndMinutes <= dayTimeStartMinutes && totalStartMinutes >00){
            print('-----Mongly');

            var dayFes = dayTimeEndMinutes - dayTimeStartMinutes;
            var nightFes = dayTimeStartMinutes - totalStartMinutes;
            var nightBas = 1440 - dayTimeEndMinutes + totalEndMinutes + nightFes;


            dayShiftMinutes = dayFes;
            nightShiftMinutes = nightBas;

            print('-----dayFes :$dayFes');
            print('-----nightFes : $nightFes');
            print('-----nightBas  : $nightBas');
            print('-----dayShiftMinutes : $dayShiftMinutes');
            print('-----nightShiftMinutes : $nightShiftMinutes');

          }

        } else if (totalStartMinutes >= totalEndMinutes && totalEndMinutes <= dayTimeStartMinutes) {
          dayShiftMinutes = 720;
          nightShiftMinutes = 720 - (totalStartMinutes - totalEndMinutes);

          /**
              if(totalEndMinutes <= dayTimeStartMinutes && totalStartMinutes >00){
              print('-----Mongly');

              var dayFes = dayTimeEndMinutes - dayTimeStartMinutes;
              var nightFes = dayTimeStartMinutes - totalStartMinutes;
              var nightBas = 1440 - dayTimeEndMinutes + totalEndMinutes + nightFes;


              dayShiftMinutes = dayFes;
              nightShiftMinutes = nightBas;

              print('-----dayFes :$dayFes');
              print('-----nightFes : $nightFes');
              print('-----nightBas  : $nightBas');
              print('-----dayShiftMinutes : $dayShiftMinutes');
              print('-----nightShiftMinutes : $nightShiftMinutes');

              }

           **/
          /// UPDATED BY HIMU  End
          print("c = $nightShiftMinutes $dayShiftMinutes");
          if (totalEndMinutes < totalStartMinutes) {
            dayShiftMinutes = 0;
            nightShiftMinutes = 1440 - (totalStartMinutes - totalEndMinutes);
            print("d = $nightShiftMinutes $dayShiftMinutes");
          }
          if (totalStartMinutes < dayTimeEndMinutes) {
            dayShiftMinutes = dayTimeEndMinutes - totalStartMinutes;
            nightShiftMinutes = 1440 - (totalStartMinutes - totalEndMinutes) - dayShiftMinutes;
            print("e = $nightShiftMinutes $dayShiftMinutes");
          }
          // if (dayTimeStartMinutes < totalStartMinutes && totalStartMinutes <= 720) {
          //   dayShiftMinutes = (720 - (totalStartMinutes - dayTimeStartMinutes)).toInt();
          //   nightShiftMinutes = (720 - (dayTimeStartMinutes - totalEndMinutes)).toInt();
          //   print("f = $nightShiftMinutes $dayShiftMinutes");
          // }
          /// UPdated Code Himu Start

          if (dayTimeStartMinutes < totalStartMinutes && totalStartMinutes <= 720) {
            print('------Issue');
            var dayren = dayTimeEndMinutes - totalStartMinutes;
            dayShiftMinutes = dayTimeEndMinutes - totalStartMinutes;
            nightShiftMinutes = 1440 - (totalStartMinutes - totalEndMinutes) - dayShiftMinutes;
            print("f = $nightShiftMinutes $dayShiftMinutes");
          }


        }
      } else if (totalEndMinutes <= dayTimeEndMinutes) {

        int startMinutes = 1440 - totalStartMinutes;
        int endMinutes = 1440 - totalEndMinutes;

        var us=dayTimeEndMinutes-totalStartMinutes;

        // dayShiftMinutes = totalEndMinutes - dayTimeStartMinutes;
        dayShiftMinutes = totalEndMinutes - dayTimeStartMinutes + us;

        var  a = dayTimeEndMinutes - totalStartMinutes;
        var gro = 1440 - dayTimeEndMinutes;
        var mo=dayTimeStartMinutes;

        // nightShiftMinutes = startMinutes + dayTimeStartMinutes;
        nightShiftMinutes = (gro + mo);
        if(totalEndMinutes > dayTimeStartMinutes && totalStartMinutes > dayTimeEndMinutes){
          print('solved');
          var grous= totalEndMinutes -dayTimeStartMinutes;
          print("grous $grous");
          dayShiftMinutes = grous;
          gro=totalStartMinutes-dayTimeEndMinutes;
          mo=dayTimeStartMinutes;
          // nightShiftMinutes = (start_minit + dayTimeStartMinutes);
          nightShiftMinutes = (gro + mo);
        }
        if(nightShiftMinutes<1.50){
          dayShiftMinutes = dayShiftMinutes+nightShiftMinutes;
          nightShiftMinutes=0;
        }
        print("g = $nightShiftMinutes $dayShiftMinutes");

        if (nightShiftMinutes >= 12 * 60) {

          int extraShift = nightShiftMinutes - 12 * 60;
          var  bro=totalEndMinutes-dayTimeStartMinutes;
          var  daywe=dayTimeEndMinutes-totalStartMinutes;
          gro=1440-dayTimeEndMinutes;
          mo=dayTimeStartMinutes;

          //nightShiftMinutes = nightShiftMinutes - extraShift;
          // dayShiftMinutes = dayShiftMinutes + extraShift;

          nightShiftMinutes = gro+mo;
          dayShiftMinutes = daywe + bro;

          print('d');


          // print("h = $nightShiftMinutes $dayShiftMinutes");
        }
        /// UPdated Code Himu End
      } else {
        nightShiftMinutes = dayTimeStartMinutes - totalStartMinutes;
        dayShiftMinutes = dayTimeEndMinutes - dayTimeStartMinutes;
        ab= totalStartMinutes - totalEndMinutes;
        nightShiftMinutes = (1440) - (dayShiftMinutes + ab) ;
        print(ab);
        print("i = $nightShiftMinutes ");
      }
    }
    /** Updated Version By Himu End **/
    else if (totalStartMinutes < dayTimeStartMinutes) {
      if (totalEndMinutes <= dayTimeStartMinutes) {
        nightShiftMinutes = totalEndMinutes - totalStartMinutes;
        print("j = $nightShiftMinutes $dayShiftMinutes");
      } else if (totalEndMinutes <= dayTimeEndMinutes) {
        nightShiftMinutes = dayTimeStartMinutes - totalStartMinutes;
        dayShiftMinutes = totalEndMinutes - dayTimeStartMinutes;
        print("k = $nightShiftMinutes $dayShiftMinutes");
      } else {
        nightShiftMinutes = dayTimeStartMinutes - totalStartMinutes;
        dayShiftMinutes = dayTimeEndMinutes - dayTimeStartMinutes;
        nightShiftMinutes += totalEndMinutes - dayTimeEndMinutes;
        print("l = $nightShiftMinutes $dayShiftMinutes");
      }
    } else if (totalStartMinutes >= dayTimeStartMinutes && totalStartMinutes <= dayTimeEndMinutes) {
      if (totalEndMinutes <= dayTimeEndMinutes) {
        dayShiftMinutes = totalEndMinutes - totalStartMinutes;
        print("m = $nightShiftMinutes $dayShiftMinutes");
      } else {
        dayShiftMinutes = dayTimeEndMinutes - totalStartMinutes;
        nightShiftMinutes = totalEndMinutes - dayTimeEndMinutes;
        print("n = $nightShiftMinutes $dayShiftMinutes");
      }
    } else {
      nightShiftMinutes = totalEndMinutes - totalStartMinutes;
      print("o = $nightShiftMinutes ");
    }

    double dayShiftHours = dayShiftMinutes / 60;
    double nightShiftHours = nightShiftMinutes / 60;

    if (nightShiftHours >= 24) nightShiftHours -= 24;
    if (dayShiftHours >= 24) dayShiftHours -= 24;

    setState(() {
      differenceText = '${nightShiftHours.toStringAsFixed(2)} + ${dayShiftHours.toStringAsFixed(2)}';
      daytimeText = '${dayShiftHours.toStringAsFixed(2)}';
      nighttimeText = '${nightShiftHours.toStringAsFixed(2)}';


      _DayTimeController.text = daytimeText;
      _NightTimeController.text = nighttimeText;

      double total = nightShiftHours + dayShiftHours;
      totalShiftHours = total.toStringAsFixed(2);
      print("Total Shift Hour $totalShiftHours");
      _TotalHourController.text = totalShiftHours;
      if (totalShiftHours == '0.00') {
        _TotalHourController.text = 'Automatically Calculated';
      } else {
        _TotalHourController.text = totalShiftHours;
      }
    });
  }


  // int _convertTimeToMinutes(String time) {
  //   final parts = time.split(':');
  //   return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  // }
  int _convertTimeToMinutes(String time) {
    time = time.trim().toUpperCase(); // Remove spaces and ensure uppercase

    final RegExp regex = RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)?');
    final match = regex.firstMatch(time);

    if (match == null) {
      throw FormatException("Invalid time format: $time");
    }

    int hours = int.parse(match.group(1)!);
    int minutes = int.parse(match.group(2)!);
    String? period = match.group(3); // AM or PM

    if (period == "PM" && hours != 12) {
      hours += 12;
    } else if (period == "AM" && hours == 12) {
      hours = 0;
    }

    return hours * 60 + minutes;
  }

  String currentDate = "";
  void _getCurrentDate() {
    currentDate = DateFormat('dd MMMM yyyy').format(DateTime.now());
  }

  final List<String> _labels = [ 'Docs', 'Req','Home', 'Map', 'Settings',];
  final List<String> _imagePaths = [

    'images/staff/document.png',
    'images/staff/request.png',
    'images/staff/home.png',
    'images/staff/googlemap.png',
    'images/staff/settings.png',

  ];

  int _tappedIndex = -1;
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
    final screenHeight = MediaQuery.of(context).size.height *1;
    final screenWidth = MediaQuery.of(context).size.width *1;
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
                  width: screenWidth*0.3,
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
                  width: screenWidth*0.3,
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
        ) ?? false;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body:_showNoInternetConnectionMessage ? NoInternetConnection() : ResPonsiveUi(
            mobile: body(),
            desktop: body(),
            tablet: body(),
          ),
        ),
      ),
    );
  }

  Widget body() {
    final screenHeight = MediaQuery.of(context).size.height *1;
    final screenWidth = MediaQuery.of(context).size.width *1;

    double dayShiftHours = double.tryParse(_DayTimeController.text) ?? 0.0;
    double nightShiftHours = double.tryParse(_NightTimeController.text) ?? 0.0;
    double TotalHours = double.tryParse(_TotalHourController.text) ?? 0.0;
    final userPrefernece = Provider.of<UserViewModel>(context);

    final bool isExpanded = (dayShiftHours + nightShiftHours >= 6.0) ||
        (TotalHours >= 6.0);

    return  Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: screenHeight * 0.08,
          decoration: BoxDecoration(
            // color: Color(0xff131A27)
              color: AppColors.navColor),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: screenHeight * 0.055,
                width: screenWidth * 0.12,
                decoration: BoxDecoration(
                  image: DecorationImage(image: AssetImage("images/c9LogoLatest.png"), fit: BoxFit.cover),
                  color: AppColors.whiteColor,
                  // shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10),

                  // color: Colors.red
                ),
              ),
              Text(
                "C9 Recruitment",
                style: GoogleFonts.openSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Replace with AppColors.whiteColor if applicable
                ),
              ),
              Text(
                "$currentDate",
                style: GoogleFonts.openSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white, // Replace with AppColors.whiteColor if applicable
                ),
              ),
            ],
          ),
        ),

        Center(
          child: FutureBuilder<PeriodGetRates?>(
            future: _clientgetRatesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: screenHeight * 0.7,
                  width: screenWidth,
                  color: AppColors.whiteColor,
                  child: LoadingScreen(),
                );
              } else if (snapshot.hasError) {
                return Column(
                  children: [
                    SizedBox(height: screenHeight * 0.013),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ClientCurveNabBar()));
                              },
                              child: HeaderRow(Icons.arrow_back))),
                    ),
                    SizedBox(height: screenHeight * 0.013),
                    ErrorLogOutScreen(
                      screenHeight: screenHeight* 0.65,
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
                // return Text("${snapshot.error}");
              } else {
                final getRates = snapshot.data?.availabilityStatus;
                if ((getRates != null && getRates.isNotEmpty)) {
                  return  Padding(
                    padding: const EdgeInsets.only(left: 15.0,right: 15),
                    child: Container(
                        height: screenHeight * 0.75,
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
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              // Text(getRates),
                              SizedBox(height: screenHeight * 0.013,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AutoSizeText(
                                        'Select Date',
                                        maxLines: 1,
                                        style: GoogleFonts.openSans(
                                          textStyle: TextStyle(fontSize: 15),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(
                                        height: screenHeight * 0.01,
                                      ),
                                      buildDateContainer('Select Date', _startSDateController),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: screenHeight * 0.013,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AutoSizeText(
                                    'Start Time',
                                    maxLines: 1,
                                    style: GoogleFonts.openSans(
                                      textStyle: TextStyle(fontSize: 15),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.01,
                                  ),
                                  Container(
                                    height: screenHeight * 0.055,
                                    width: screenWidth * 0.85,
                                    decoration: BoxDecoration(
                                      color: Color(0xffF2F5F6),
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border.all(
                                        color: Color(0xffEAECED),
                                        width: 1,
                                      ),
                                      // boxShadow: [
                                      //   BoxShadow(
                                      //     color: Color(0xff0ffdfe6e9).withOpacity(0.1), // Inner shadow color
                                      //     offset: Offset(-1, -1), // Inner shadow position
                                      //     blurRadius: 5.0, // Inner shadow blur radius
                                      //     spreadRadius: 1.0, // Inner shadow spread radius
                                      //   ),
                                      // ],
                                    ),
                                    child: TextFormField(
                                      readOnly: true,
                                      controller: _StartTimePickerController,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                                        hintText: "Pick a start time",
                                        hintStyle: GoogleFonts.openSans(
                                          color: Colors.grey, // Text color
                                          fontSize: 15, // Font size
                                          fontWeight: FontWeight.normal, // Font weight
                                        ),
                                        suffixIcon: Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Colors.black87,
                                          size: 20,
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      onTap: () async {
                                        TimeOfDay? newTime = await showTimePicker(
                                          context: context,
                                          initialTime: startTime,
                                          initialEntryMode: TimePickerEntryMode.input,
                                          builder: (BuildContext context, Widget? child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                timePickerTheme: TimePickerThemeData(
                                                  backgroundColor: Colors.white, // Background color
                                                  dayPeriodTextColor: Colors.blue, // Text color for AM/PM
                                                  dayPeriodBorderSide: BorderSide(color: AppColors.navColor), // Border color for AM/PM
                                                  dialHandColor: AppColors.navColor, // Color of the hour hand
                                                  // dialTextColor: Colors.purple, // Text color on the clock dial
                                                  dialBackgroundColor: Colors.white,
                                                ),
                                                colorScheme: const ColorScheme.light(
                                                  onPrimary: Colors.white,

                                                  onBackground: Colors.white,

                                                  onSurface: AppColors.navButtonColor, //TextColor in Calender

                                                  onSurfaceVariant: Colors.white,

                                                  primary: AppColors.navColor, // circle color

                                                  brightness: Brightness.light, //Brightness

                                                  surface: Colors.white,

                                                  secondary: AppColors.navColor,
                                                ),
                                                datePickerTheme: const DatePickerThemeData(
                                                  headerBackgroundColor: AppColors.navColor,

                                                  backgroundColor: Colors.white, //Main Baground

                                                  headerForegroundColor: Colors.white, //Header Text Color
                                                  surfaceTintColor: Colors.white, //Main Background Needed
                                                ),
                                                textButtonTheme: TextButtonThemeData(
                                                  style: TextButton.styleFrom(
                                                    foregroundColor: AppColors.navButtonColor, //Cancel Ok  button text color
                                                  ),
                                                ),
                                              ),
                                              child: child!,
                                            );
                                          },
                                        );
                                        if (newTime != null) {
                                          _selectStartTime(newTime);
                                          String formattedHour = newTime.hour.toString().padLeft(2, '0');
                                          String formattedMinute = newTime.minute.toString().padLeft(2, '0');
                                          String formattedTime = "$formattedHour:$formattedMinute";
                                          setState(() {
                                            _StartTimePickerController.text = formattedTime;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: screenHeight * 0.013,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AutoSizeText(
                                    'End Time',
                                    maxLines: 1,
                                    style: GoogleFonts.openSans(
                                      textStyle: TextStyle(fontSize: 15),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.01,
                                  ),
                                  Container(
                                    height: screenHeight * 0.055,
                                    width: screenWidth * 0.85,
                                    decoration: BoxDecoration(
                                      color: Color(0xffF2F5F6),
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border.all(
                                        color: Color(0xffEAECED),
                                        width: 1,
                                      ),
                                      // boxShadow: [
                                      //   BoxShadow(
                                      //     color: Color(0xff0ffdfe6e9).withOpacity(0.1), // Inner shadow color
                                      //     offset: Offset(-1, -1), // Inner shadow position
                                      //     blurRadius: 5.0, // Inner shadow blur radius
                                      //     spreadRadius: 1.0, // Inner shadow spread radius
                                      //   ),
                                      // ],
                                    ),
                                    child: TextFormField(
                                      readOnly: true,
                                      controller: _EndTimePickerController,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                                        hintText: "Pick an end time",
                                        hintStyle: GoogleFonts.openSans(
                                          color: Colors.grey, // Text color
                                          fontSize: 15, // Font size
                                          fontWeight: FontWeight.normal, // Font weight
                                        ),suffixIcon: Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.black87,
                                        size: 20,
                                      ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      onTap: () async {
                                        TimeOfDay? newTime = await showTimePicker(
                                          context: context,
                                          initialTime: endTime,
                                          initialEntryMode: TimePickerEntryMode.input,
                                          builder: (BuildContext context, Widget? child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                timePickerTheme: TimePickerThemeData(
                                                  backgroundColor: Colors.white, // Background color
                                                  dayPeriodTextColor: Colors.blue, // Text color for AM/PM
                                                  dayPeriodBorderSide: BorderSide(color: AppColors.navColor), // Border color for AM/PM
                                                  dialHandColor: AppColors.navColor, // Color of the hour hand
                                                  // dialTextColor: Colors.purple, // Text color on the clock dial
                                                  dialBackgroundColor: Colors.white,
                                                ),
                                                colorScheme: const ColorScheme.light(
                                                  onPrimary: Colors.white,

                                                  onBackground: Colors.white,

                                                  onSurface: AppColors.navButtonColor, //TextColor in Calender

                                                  onSurfaceVariant: Colors.white,

                                                  primary: AppColors.navColor, // circle color

                                                  brightness: Brightness.light, //Brightness

                                                  surface: Colors.white,

                                                  secondary: AppColors.navColor,
                                                ),
                                                datePickerTheme: const DatePickerThemeData(
                                                  headerBackgroundColor: AppColors.navColor, //Header Background Color

                                                  backgroundColor: Colors.white, //Main Baground

                                                  headerForegroundColor: Colors.white, //Header Text Color
                                                  surfaceTintColor: Colors.white, //Main Background Needed
                                                ),
                                                textButtonTheme: TextButtonThemeData(
                                                  style: TextButton.styleFrom(
                                                    foregroundColor: AppColors.navButtonColor, //Cancel Ok  button text color
                                                  ),
                                                ),
                                              ),
                                              child: child!,
                                            );
                                          },
                                        );
                                        if (newTime != null) {
                                          _selectEndTime(newTime);
                                          String formattedHour = newTime.hour.toString().padLeft(2, '0');
                                          String formattedMinute = newTime.minute.toString().padLeft(2, '0');
                                          String formattedTime = "$formattedHour:$formattedMinute";
                                          setState(() {
                                            _EndTimePickerController.text = formattedTime;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              // Text(_DayTimeController.text),
                              // Text(_NightTimeController.text),
                              // Text(dayShiftHours.toString()),
                              // Text(nightShiftHours.toString()),
                              if ( (dayShiftHours  > 0.0 || nightShiftHours > 0.0) && (getRates=="only_day_available"))...[
                                SizedBox(
                                  height: screenHeight * 0.013,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AutoSizeText(
                                      'Day Time(Hours)',
                                      maxLines: 1,
                                      style: GoogleFonts.openSans(
                                        textStyle: TextStyle(fontSize: 15),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(
                                      height: screenHeight * 0.01,
                                    ),
                                    Container(
                                      height: screenHeight * 0.055,
                                      width: screenWidth * 0.85,
                                      decoration: BoxDecoration(
                                        color: Color(0xffF2F5F6),
                                        borderRadius: BorderRadius.circular(10.0),
                                        border: Border.all(
                                          color: Color(0xffEAECED),
                                          width: 1,
                                        ),
                                        // boxShadow: [
                                        //   BoxShadow(
                                        //     color: Color(0xff0ffdfe6e9).withOpacity(0.1), // Inner shadow color
                                        //     offset: Offset(-1, -1), // Inner shadow position
                                        //     blurRadius: 5.0, // Inner shadow blur radius
                                        //     spreadRadius: 1.0, // Inner shadow spread radius
                                        //   ),
                                        // ],
                                      ),
                                      child: TextFormField(
                                        controller: _TotalHourController,
                                        keyboardType: TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                                        ],
                                        decoration: InputDecoration(
                                          hintText: 'Day Time',
                                          hintStyle: GoogleFonts.openSans(
                                            color: Colors.grey, // Text color
                                            fontSize: 15, // Font size
                                            fontWeight: FontWeight.normal, // Font weight
                                          ), // prefixIcon: Icon(Icons.av_timer_outlined),
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

                              if ((dayShiftHours  > 0.0 || nightShiftHours > 0.0) && (getRates=="only_night_available"))...[
                                Column(
                                  children: [
                                    SizedBox(
                                      height: screenHeight * 0.013,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: screenWidth * 0.425,
                                          // color: Colors.yellowAccent,
                                          child: AutoSizeText(
                                            'Night Time(Hours)',
                                            maxLines: 1,
                                            style: GoogleFonts.openSans(
                                              textStyle: TextStyle(fontSize: 15),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: screenHeight * 0.025,
                                          width: screenWidth * 0.425,
                                          // color: Colors.red,
                                          alignment: Alignment.center,
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              "$nextDate",
                                              style: GoogleFonts.openSans(
                                                textStyle: TextStyle(fontSize: 10),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: screenHeight * 0.01,
                                    ),
                                    Container(
                                      height: screenHeight * 0.055,
                                      width: screenWidth * 0.85,
                                      decoration: BoxDecoration(
                                        color: Color(0xffF2F5F6),
                                        borderRadius: BorderRadius.circular(10.0),
                                        border: Border.all(
                                          color: Color(0xffEAECED),
                                          width: 1,
                                        ),
                                        // boxShadow: [
                                        //   BoxShadow(
                                        //     color: Color(0xff0ffdfe6e9).withOpacity(0.1), // Inner shadow color
                                        //     offset: Offset(-1, -1), // Inner shadow position
                                        //     blurRadius: 5.0, // Inner shadow blur radius
                                        //     spreadRadius: 1.0, // Inner shadow spread radius
                                        //   ),
                                        // ],
                                      ),
                                      child: TextFormField(
                                        controller: _TotalHourController,
                                        keyboardType: TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                                        ],
                                        decoration: InputDecoration(
                                          hintText: 'Night Time',
                                          hintStyle: GoogleFonts.openSans(
                                            color: Colors.grey, // Text color
                                            fontSize: 15, // Font size
                                            fontWeight: FontWeight.normal, // Font weight
                                          ), // prefixIcon: Icon(Icons.av_timer_outlined),
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

                              if (dayShiftHours > 0.0 && nightShiftHours > 0.0 && (getRates=="both_available")) ...[
                                SizedBox(
                                  height: screenHeight * 0.013,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AutoSizeText(
                                      'Day Time(Hours)',
                                      maxLines: 1,
                                      style: GoogleFonts.openSans(
                                        textStyle: TextStyle(fontSize: 15),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(
                                      height: screenHeight * 0.01,
                                    ),
                                    Container(
                                      height: screenHeight * 0.055,
                                      width: screenWidth * 0.85,
                                      decoration: BoxDecoration(
                                        color: Color(0xffF2F5F6),
                                        borderRadius: BorderRadius.circular(10.0),
                                        border: Border.all(
                                          color: Color(0xffEAECED),
                                          width: 1,
                                        ),
                                        // boxShadow: [
                                        //   BoxShadow(
                                        //     color: Color(0xff0ffdfe6e9).withOpacity(0.1), // Inner shadow color
                                        //     offset: Offset(-1, -1), // Inner shadow position
                                        //     blurRadius: 5.0, // Inner shadow blur radius
                                        //     spreadRadius: 1.0, // Inner shadow spread radius
                                        //   ),
                                        // ],
                                      ),
                                      child: TextFormField(
                                        controller: _DayTimeController,
                                        keyboardType: TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                                        ],
                                        decoration: InputDecoration(
                                          hintText: 'Day Time',
                                          hintStyle: GoogleFonts.openSans(
                                            color: Colors.grey, // Text color
                                            fontSize: 15, // Font size
                                            fontWeight: FontWeight.normal, // Font weight
                                          ), // prefixIcon: Icon(Icons.av_timer_outlined),
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
                                  children: [
                                    SizedBox(
                                      height: screenHeight * 0.013,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: screenWidth * 0.425,
                                          // color: Colors.yellowAccent,
                                          child: AutoSizeText(
                                            'Night Time(Hours)',
                                            maxLines: 1,
                                            style: GoogleFonts.openSans(
                                              textStyle: TextStyle(fontSize: 15),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: screenHeight * 0.025,
                                          width: screenWidth * 0.425,
                                          // color: Colors.red,
                                          alignment: Alignment.center,
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              "$nextDate",
                                              style: GoogleFonts.openSans(
                                                textStyle: TextStyle(fontSize: 10),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: screenHeight * 0.01,
                                    ),
                                    Container(
                                      height: screenHeight * 0.055,
                                      width: screenWidth * 0.85,
                                      decoration: BoxDecoration(
                                        color: Color(0xffF2F5F6),
                                        borderRadius: BorderRadius.circular(10.0),
                                        border: Border.all(
                                          color: Color(0xffEAECED),
                                          width: 1,
                                        ),
                                        // boxShadow: [
                                        //   BoxShadow(
                                        //     color: Color(0xff0ffdfe6e9).withOpacity(0.1), // Inner shadow color
                                        //     offset: Offset(-1, -1), // Inner shadow position
                                        //     blurRadius: 5.0, // Inner shadow blur radius
                                        //     spreadRadius: 1.0, // Inner shadow spread radius
                                        //   ),
                                        // ],
                                      ),
                                      child: TextFormField(
                                        controller: _NightTimeController,
                                        keyboardType: TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                                        ],
                                        decoration: InputDecoration(
                                          hintText: 'Night Time',
                                          hintStyle: GoogleFonts.openSans(
                                            color: Colors.grey, // Text color
                                            fontSize: 15, // Font size
                                            fontWeight: FontWeight.normal, // Font weight
                                          ), // prefixIcon: Icon(Icons.av_timer_outlined),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                        readOnly: true,
                                      ),
                                    ),
                                  ],
                                )
                              ]else if (getRates=="both_available")...[
                                SizedBox(
                                  height: screenHeight * 0.013,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AutoSizeText(
                                      'Total Time(Hours)',
                                      maxLines: 1,
                                      style: GoogleFonts.openSans(
                                        textStyle: TextStyle(fontSize: 15),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(
                                      height: screenHeight * 0.013,
                                    ),
                                    Container(
                                      height: screenHeight * 0.055,
                                      width: screenWidth * 0.85,
                                      decoration: BoxDecoration(
                                        color: Color(0xffF2F5F6),
                                        borderRadius: BorderRadius.circular(10.0),
                                        border: Border.all(
                                          color: Color(0xffEAECED),
                                          width: 1,
                                        ),
                                        // boxShadow: [
                                        //   BoxShadow(
                                        //     color: Color(0xff0ffdfe6e9).withOpacity(0.1), // Inner shadow color
                                        //     offset: Offset(-1, -1), // Inner shadow position
                                        //     blurRadius: 5.0, // Inner shadow blur radius
                                        //     spreadRadius: 1.0, // Inner shadow spread radius
                                        //   ),
                                        // ],
                                      ),
                                      child: TextFormField(
                                        controller: _TotalHourController,
                                        style: GoogleFonts.openSans(
                                          textStyle: TextStyle(fontSize: 15),
                                          fontWeight: FontWeight.w500,
                                        ),
                                        keyboardType: TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                                        ],

                                        decoration: InputDecoration(
                                          hintText: 'Total Hour',
                                          hintStyle: GoogleFonts.openSans(
                                            color: Colors.grey, // Text color
                                            fontSize: 15, // Font size
                                            fontWeight: FontWeight.normal, // Font weight
                                          ),// suffixIcon: Icon(Icons.keyboard_arrow_down),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                        readOnly: true,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                              SizedBox(
                                height: screenHeight * 0.013,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AutoSizeText(
                                        'Input Expenses',
                                        maxLines: 1,
                                        style: GoogleFonts.openSans(
                                          textStyle: TextStyle(fontSize: 15),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(
                                        height: screenHeight * 0.01,
                                      ),
                                      Container(
                                        height: screenHeight * 0.055,
                                        width: isExpanded ? screenWidth * 0.4 : screenWidth * 0.85,
                                        decoration: BoxDecoration(
                                          color: Color(0xffF2F5F6),
                                          borderRadius: BorderRadius.circular(10.0),
                                          border: Border.all(
                                            color: Color(0xffEAECED),
                                            width: 1,
                                          ),
                                          // boxShadow: [
                                          //   BoxShadow(
                                          //     color: Color(0xff0ffdfe6e9).withOpacity(0.1), // Inner shadow color
                                          //     offset: Offset(-1, -1), // Inner shadow position
                                          //     blurRadius: 5.0, // Inner shadow blur radius
                                          //     spreadRadius: 1.0, // Inner shadow spread radius
                                          //   ),
                                          // ],
                                        ),
                                        child: TextFormField(
                                          controller: _ExpensesController,
                                          keyboardType: TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                                          ],
                                          // textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                            hintText: 'Expenses',
                                            hintStyle: GoogleFonts.openSans(
                                              color: Colors.grey, // Text color
                                              fontSize: 15, // Font size
                                              fontWeight: FontWeight.normal, // Font weight
                                            ),alignLabelWithHint: true,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (isExpanded)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        AutoSizeText(
                                          'Break Time',
                                          maxLines: 1,
                                          style: GoogleFonts.openSans(
                                            textStyle: TextStyle(fontSize: 15),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(
                                          height: screenHeight * 0.01,
                                        ),
                                        Container(
                                          height: screenHeight * 0.055,
                                          width: screenWidth * 0.4,
                                          decoration: BoxDecoration(
                                            color: Color(0xffF2F5F6),
                                            borderRadius: BorderRadius.circular(10.0),
                                            border: Border.all(
                                              color: Color(0xffEAECED),
                                              width: 1,
                                            ),
                                            // boxShadow: [
                                            //   BoxShadow(
                                            //     color: Color(0xff0ffdfe6e9).withOpacity(0.1), // Inner shadow color
                                            //     offset: Offset(-1, -1), // Inner shadow position
                                            //     blurRadius: 5.0, // Inner shadow blur radius
                                            //     spreadRadius: 1.0, // Inner shadow spread radius
                                            //   ),
                                            // ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 15.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: AutoSizeText(
                                                "${((double.tryParse(widget.breakTimes ?? '0') ?? 0.0) * 60).toStringAsFixed(2)} minutes",
                                                style:GoogleFonts.openSans(
                                                  fontSize: 15, // Font size
                                                  fontWeight: FontWeight.normal, // Font weight
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                ],
                              ),
                              SizedBox(
                                height: screenHeight * 0.02,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  if (_startSDateController.text.isEmpty ||
                                      // _endDateController.text.isEmpty ||
                                      _StartTimePickerController.text.isEmpty ||
                                      _EndTimePickerController.text.isEmpty) {
                                    Utils.flushBarErrorMessage("Fields must not be empty", context);
                                  } else {
                                    await _NomalCalculationPost();
                                  }
                                },
                                child: Container(
                                  height: screenHeight * 0.05,
                                  width: screenWidth * 0.7,
                                  decoration: BoxDecoration(
                                    color: Color(0xff2664EC),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: isLoading
                                        ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        )) // Show loading indicator if isLoading is true
                                        : AutoSizeText(
                                      "SUBMIT",
                                      maxLines: 1,
                                      style: GoogleFonts.openSans(
                                        textStyle: TextStyle(fontSize: 16),
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: screenHeight * 0.01,
                              ),
                              AutoSizeText(
                                "Note: Breaks will be automatically deducted",
                                maxLines: 1,
                                style: GoogleFonts.openSans(
                                  textStyle: TextStyle(fontSize: 10),
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.013,),
                            ],
                          ),
                        )),
                  );
                }else
                {
                  return   Align(
                      alignment: Alignment.center,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                        height: screenHeight * 0.72,
                        width: screenWidth,
                        color: AppColors.whiteColor,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.rate_review_outlined,
                                color: AppColors.navColor,
                                size: screenWidth * 0.12,
                              ),
                              SizedBox(
                                height: screenHeight * 0.02,
                              ),
                              Text(
                                'No Rates Available',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.navColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ));
                }
              }
            },
          ),
        ),

        Container(
          height: screenHeight * 0.07,
          color: AppColors.navColor, // Replace with AppColors.navColor
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_labels.length, (index) {
              return GestureDetector(
                onTap: () async {
                  setState(() {
                    _tappedIndex = index;
                  });

                  // Wait for the animation to complete
                  await Future.delayed(Duration(milliseconds: 300));

                  // Navigate to StaffCurveNabBar and pass the tapped index
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClientCurveNabBar(initialIndex: index),
                    ),
                  );
                  print(index);
                  // Reset the tapped index
                  setState(() {
                    _tappedIndex = -1;
                  });
                },

                child: Container(
                  width: screenWidth * 0.17,
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedScale(
                        scale: _tappedIndex == index ? 1.2 : 1.0,
                        duration: Duration(milliseconds: 200),
                        child: Image.asset(
                          _imagePaths[index],
                          height: 25, // Adjust icon size
                          width: 25,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        _labels[index],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.white, // Replace with desired text color
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );}

  Widget buildDateContainer(String labelText, TextEditingController controller) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;

    return Container(
      height: screenHeight * 0.055,
      width: screenWidth * 0.85,
      decoration: BoxDecoration(
        color: Color(0xffF2F5F6),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: Color(0xffEAECED),
          width: 1,
        ),
        // boxShadow: [
        //   BoxShadow(
        //     color: Color(0xff0ffdfe6e9).withOpacity(0.1), // Inner shadow color
        //     offset: Offset(-1, -1), // Inner shadow position
        //     blurRadius: 5.0, // Inner shadow blur radius
        //     spreadRadius: 1.0, // Inner shadow spread radius
        //   ),
        // ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.datetime,
        readOnly: true,
        style: GoogleFonts.openSans(
          color: Colors.black87, // Text color
          fontSize: 15, // Font size
          fontWeight: FontWeight.w600, // Font weight
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
          hintText: labelText,
          hintStyle: GoogleFonts.openSans(
            color: Colors.grey.withOpacity(0.6),
            fontSize: 12,
          ),
          suffixIcon: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.black87,
            size: 20,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
        ),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            initialEntryMode: DatePickerEntryMode.calendarOnly,
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
            builder: (BuildContext context, Widget? child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    onPrimary: Colors.white,
                    onBackground: Colors.white,
                    onSurface: Colors.black,
                    primary: AppColors.navColor,
                    brightness: Brightness.light,
                    surface: Colors.white,
                  ),
                  datePickerTheme: const DatePickerThemeData(
                    headerBackgroundColor: AppColors.navColor,
                    backgroundColor: Colors.white,
                    headerForegroundColor: Colors.white,
                    surfaceTintColor: Colors.white,
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.navButtonColor,
                    ),
                  ),
                ),
                child: child!,
              );
            },
          );

          if (pickedDate != null) {
            DateTime assignStartDate = widget.assignStartDate != null ? DateTime.parse(widget.assignStartDate!) : DateTime(2000); // Default fallback
            DateTime assignEndDate = widget.assignEndDate != null ? DateTime.parse(widget.assignEndDate!) : DateTime(2101); // Default fallback

            if (pickedDate.isBefore(assignStartDate)) {
              Utils.flushBarErrorMessage("You've selected a date before your assignment's start date.\nPlease contact C9 Recruitment if you believe this to be a mistake.", context);
            } else if (pickedDate.isAfter(assignEndDate)) {
              Utils.flushBarErrorMessage("You've selected a date after your assignment's end date.\nPlease contact C9 Recruitment if you believe this to be a mistake.", context);
            } else {
              // Update the controller with the selected date
              String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
              setState(() {
                controller.text = formattedDate;
              });
            }
          }
        },
      ),
    );
  }

  void _clearFields() {
    setState(() {
      _startSDateController.clear();
      // _endDateController.clear();
      _StartTimePickerController.clear();
      _EndTimePickerController.clear();
      _ExpensesController.clear();
      _DayTimeController.clear();
      _NightTimeController.clear();
      _TotalHourController.clear();

    });}

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
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
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
  Widget HeaderRow(IconData iconData) {
    final themeProvider = Provider.of<ThemeProvider>(context);
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
            color:  AppColors.greyOpacity,
            offset: Offset(0, 2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(iconData,color: AppColors.navColor,),
    );
  }
}
