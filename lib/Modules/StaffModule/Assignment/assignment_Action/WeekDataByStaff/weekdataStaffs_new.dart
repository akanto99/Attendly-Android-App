import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:c9_app/Modules/ClientModule/model/clientDirectoryModel/calculationModels/WeekDataModel/weekclient_model.dart';
import 'package:c9_app/Modules/StaffModule/Assignment/assignment_Action/WeekDataByStaff/weekDetailsStaffs.dart';
import 'package:c9_app/Modules/StaffModule/Assignment/manual_and_nomal_Calculation/manual_Calculation_New.dart';
import 'package:c9_app/Modules/StaffModule/Assignment/manual_and_nomal_Calculation/normal_Calculation_New.dart';
import 'package:c9_app/Modules/StaffModule/DashBoard/staff_navigationScreen.dart';
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
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as https;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../../../../ClientModule/pages/noInternetConnectionWidget.dart';

class TimerRecord {
  String date;
  List<String> startDate;
  List<String> startTime;
  List<String> endDate;
  List<String> endTime;
  int total;
  int daytime;
  int nighttime;

  TimerRecord({
    required this.date,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.total,
    required this.daytime,
    required this.nighttime,
  });

  // Convert TimerRecord to JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'startDate': startDate,
      'startTime': startTime,
      'endDate': endDate,
      'endTime': endTime,
      'total': total,
      'daytime': daytime,
      'nighttime': nighttime,
    };
  }

  // Create TimerRecord from JSON
  TimerRecord.fromJson(Map<String, dynamic> json)
      : date = json['date'],
        startDate = List<String>.from(json['startDate']),
        startTime = List<String>.from(json['startTime']),
        endDate = List<String>.from(json['endDate']),
        endTime = List<String>.from(json['endTime']),
        total = json['total'],
        daytime = json['daytime'],
        nighttime = json['nighttime'];
}

class TimerProviderAgain extends ChangeNotifier with WidgetsBindingObserver {
  late String a;
  late String b;
  late Timer _timer;
  late DateTime _startTime;
  late DateTime _stopTime;
  int _elapsedTime = 0;
  bool _running = false;
  List<TimerRecord> _timerRecords = [];
  late FlutterLocalNotificationsPlugin _localNotificationsPlugin;

  Map<String, bool> activeTimers = {};
  void printValues() {
    print('Value of a: $a');
    print('Value of b: $b');
  }

  int _convertAHour(String time) {
    final parts = time.split(':');
    final hours = int.parse(parts[0]);
    return hours;
  }

  int _convertAMinutes(String time) {
    final parts = time.split(':');
    final minutes = int.parse(parts[1]);
    return minutes;
  }

  int _convertBHour(String time) {
    final parts = time.split(':');
    final hours = int.parse(parts[0]);
    return hours;
  }

  int _convertBMinutes(String time) {
    final parts = time.split(':');
    final minutes = int.parse(parts[1]);
    return minutes;
  }

  TimerProviderAgain() {
    _initializeNotifications();
    _timer = Timer.periodic(Duration(milliseconds: 10), _updateTimer);
    WidgetsBinding.instance?.addObserver(this);

    // Load timer records data when the TimerProvider is initialized
    _loadTimerRecords();
  }
  // Check if a client has an active timer
  bool isTimerRunningForClient(String clientId) {
    return activeTimers[clientId] ?? false;
  }

  void _loadTimerRecords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? recordsJson = prefs.getStringList('timerRecords');

    if (recordsJson != null) {
      _timerRecords = recordsJson.map((jsonString) => TimerRecord.fromJson(json.decode(jsonString))).toList();
      notifyListeners();
    }
  }

  void clearTimerRecords() {
    _timerRecords.clear();
    _saveTimerState(); // Save an empty list of timer records
    notifyListeners();
  }

  int get elapsedTime => _elapsedTime;
  bool get isRunning => _running;
  List<TimerRecord> get timerRecords => _timerRecords;

  // Update timer callback
  void _updateTimer(Timer timer) {
    if (_running) {
      _elapsedTime = DateTime.now().difference(_startTime).inMilliseconds;
      _saveTimerState(); // Save state
      notifyListeners();
    }
  }

  // Start the timer for a specific client
  void startTimer(String clientId) {
    if (!isTimerRunningForClient(clientId)) {
      _startTime = DateTime.now().subtract(Duration(milliseconds: _elapsedTime));
      _running = true;

      activeTimers[clientId] = true;
      _saveTimerState(); // Save state
      notifyListeners();
    } else {
      print('Timer already running for client: $clientId');
    }
  }

  // Pause the timer for a specific client
  void pauseTimer(String clientId) {
    if (isTimerRunningForClient(clientId)) {
      _running = false;

      _elapsedTime = DateTime.now().difference(_startTime).inMilliseconds;
      activeTimers[clientId] = false;
      _saveTimerState(); // Save state
      notifyListeners();
    }
  }

  // Stop the timer for a specific client
  void stopTimer(String clientId) {
    if (isTimerRunningForClient(clientId)) {
      pauseTimer(clientId);
      activeTimers[clientId] = false; // Mark the client's timer as stopped
      _saveTimerState(); // Save state
      notifyListeners();
    }
  }

  void resetTimer() {
    _elapsedTime = 0;
    _running = false; // Set running to false
    _saveTimerState(); // Save timer state here
    notifyListeners();
  }

  void submitTimer(BuildContext context) {
    _stopTime = DateTime.now(); // Record stop time
    _updateTimerRecordsTable();
    _printTimerRecords();
    cancelBackgroundTask();
    resetTimer(); // Reset the timer completely
    notifyListeners();
  }

  void _updateTimerRecordsTable() {
    String startDate = formatDate(_startTime);
    String endDate = formatDate(_stopTime);

    // Format start and stop time without milliseconds
    String startTimeFormatted = formatTime(_startTime);
    String endTimeFormatted = formatTime(_stopTime);

    Map<String, dynamic> timeSplits = splitTimeAcrossDates(_startTime, _stopTime);

    for (String date in timeSplits.keys) {
      if (!_timerRecords.any((record) => record.date == date)) {
        _timerRecords.add(TimerRecord(
          date: date,
          startDate: [],
          startTime: [],
          endDate: [],
          endTime: [],
          total: 0,
          daytime: 0,
          nighttime: 0,
        ));
      }

      TimerRecord record = _timerRecords.firstWhere((record) => record.date == date);
      if (date == startDate) {
        record.startDate.add(startDate);
        record.startTime.add(startTimeFormatted);
      }

      if (date == endDate) {
        record.endDate.add(endDate);
        record.endTime.add(endTimeFormatted);
      }

      for (int i = 0; i < timeSplits[date]['starts'].length; i++) {
        DateTime segmentStart = DateTime.parse('$date ${timeSplits[date]['starts'][i]}');
        DateTime segmentEnd = DateTime.parse('$date ${timeSplits[date]['ends'][i]}');
        int AHour = _convertAHour("$a");

        int AMinutes = _convertAMinutes("$a");
        int BHour = _convertBHour("$b");
        int BMinutes = _convertBMinutes("$b");
        print('up $AHour, $BHour');
        Map<String, int> dayNightTimes = calculateDayNightTime(segmentStart, segmentEnd, AHour, AMinutes, BHour, BMinutes);
        record.daytime += dayNightTimes['daytime']!;
        record.nighttime += dayNightTimes['nighttime']!;
        print('xx${record.daytime},${record.nighttime}');
      }
      record.total = record.daytime + record.nighttime;
    }
  }

  Map<String, dynamic> splitTimeAcrossDates(DateTime start, DateTime end) {
    Map<String, dynamic> timeSplits = {};

    DateTime currentDate = start;
    while (currentDate.isBefore(end)) {
      DateTime nextDay = DateTime(currentDate.year, currentDate.month, currentDate.day + 1, 0, 0, 0, 0);
      print('$nextDay');
      String currentDateKey = currentDate.toLocal().toIso8601String().split('T')[0];
      if (!timeSplits.containsKey(currentDateKey)) {
        timeSplits[currentDateKey] = {'total': 0, 'starts': [], 'ends': []};
      }

      // Check if the current date is the start date
      if (currentDate == start) {
        timeSplits[currentDateKey]['starts'].add(start.toLocal().toIso8601String().split('T')[1]);
        timeSplits[currentDateKey]['ends'].add(nextDay.isBefore(end) ? '23:59:59' : end.toLocal().toIso8601String().split('T')[1]);
      } else {
        timeSplits[currentDateKey]['starts'].add('00:00:00');
        timeSplits[currentDateKey]['ends'].add(nextDay.isBefore(end) ? '23:59:59' : end.toLocal().toIso8601String().split('T')[1]);
      }

      int splitTime = ((nextDay.isBefore(end) ? nextDay.millisecondsSinceEpoch : end.millisecondsSinceEpoch) - currentDate.millisecondsSinceEpoch) ~/ (1000 * 60); // Convert milliseconds to minutes
      timeSplits[currentDateKey]['total'] += splitTime;

      currentDate = nextDay;
    }

    return timeSplits;
  }

  Map<String, int> calculateDayNightTime(DateTime start, DateTime end, int AHour, int AMinutes, int BHour, int BMinutes) {
    int daytimeDuration = 0;
    int nighttimeDuration = 0;

    int AHour = _convertAHour("$a");

    int AMinutes = _convertAMinutes("$a");
    int BHour = _convertBHour("$b");
    int BMinutes = _convertBMinutes("$b");
    print('$AHour,$AMinutes ,$BHour,$BMinutes');
    DateTime daytimeStart = DateTime(start.year, start.month, start.day, AHour, AMinutes, 0, 0);
    DateTime daytimeEnd = DateTime(start.year, start.month, start.day, BHour, BMinutes, 0, 0);
    print('$daytimeStart,$daytimeEnd');
    // If start and end are after daytimeEnd, adjust daytimeStart and daytimeEnd to the next day
    if (start.isAfter(daytimeEnd) && end.isAfter(daytimeEnd)) {
      daytimeStart = DateTime(start.year, start.month, start.day + 1, AHour, AMinutes, 0, 0);
      daytimeEnd = DateTime(start.year, start.month, start.day + 1, BHour, BMinutes, 0, 0);
    }

    if (start.isBefore(daytimeStart)) {
      if (end.isBefore(daytimeStart)) {
        nighttimeDuration += end.difference(start).inMilliseconds;
        print('a$nighttimeDuration');
      } else {
        nighttimeDuration += daytimeStart.difference(start).inMilliseconds;
        daytimeDuration += end.difference(daytimeStart).inMilliseconds;
        print('b$nighttimeDuration,$daytimeDuration');
        if (daytimeDuration > 12 * 60 * 60 * 1000) {
          nighttimeDuration += daytimeDuration - 12 * 60 * 60 * 1000;
          daytimeDuration = 12 * 60 * 60 * 1000;
        }
      }
    } else if (start.isBefore(daytimeEnd)) {
      if (end.isBefore(daytimeEnd)) {
        daytimeDuration += end.difference(start).inMilliseconds;
        print('c$nighttimeDuration,$daytimeDuration');
      } else {
        daytimeDuration += daytimeEnd.difference(start).inMilliseconds;
        nighttimeDuration += end.difference(daytimeEnd).inMilliseconds;
        print('d$nighttimeDuration,$daytimeDuration');
      }
    } else {
      nighttimeDuration += end.difference(start).inMilliseconds;
      print('e$nighttimeDuration,$daytimeDuration');
    }

    return {'daytime': daytimeDuration, 'nighttime': nighttimeDuration};
  }

  // Save the state of the timer (adjust this method to save per-client state)
  void _saveTimerState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('elapsedTime', _elapsedTime);
    await prefs.setString('startTime', _startTime.toString());
    await prefs.setBool('running', _running);
    // Save active timers map
    await prefs.setString('activeTimers', jsonEncode(activeTimers));
  }

  void _loadTimerState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? storedElapsedTime = prefs.getInt('elapsedTime');
    String? storedStartTime = prefs.getString('startTime');
    bool? storedRunning = prefs.getBool('running');
    String? storedActiveTimers = prefs.getString('activeTimers');

    if (storedElapsedTime != null && storedStartTime != null && storedRunning != null) {
      _elapsedTime = storedElapsedTime;
      _startTime = DateTime.parse(storedStartTime);
      _running = storedRunning;

      // Restore activeTimers state (per client)
      if (storedActiveTimers != null) {
        activeTimers = Map<String, bool>.from(json.decode(storedActiveTimers));

        // Restore the timer for the client that was running, if any
        activeTimers.forEach((clientId, isActive) {
          if (isActive) {
            startTimer(clientId);
          }
        });
      }
    }
  }

  void saveTimerRecords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('elapsedTime', elapsedTime);
    List<String> recordsJson = _timerRecords.map((record) => json.encode(record.toJson())).toList(); // Add underscore to access class level variables
    prefs.setStringList('timerRecords', recordsJson);
  }

  void _printTimerRecords() {
    for (TimerRecord record in _timerRecords) {
      print('--------------------------------');
      print('Date: ${record.date}');
      print('Start Date: ${record.startDate}');
      print('Start Time: ${record.startTime}');
      print('End Date: ${record.endDate}');
      print('End Time: ${record.endTime}');
      print('Total Time: ${_formatTotalTime(record.total)}');
      print('Daytime: ${_formatTotalTime(record.daytime)}');
      print('Nighttime: ${_formatTotalTime(record.nighttime)}');
      print('--------------------------------');
    }
  }

  String _formatTotalTime(int milliseconds) {
    int totalSeconds = (milliseconds / 1000).floor();
    int hours = (totalSeconds / 3600).floor();
    totalSeconds %= 3600;
    int minutes = (totalSeconds / 60).floor();
    int seconds = totalSeconds % 60;

    return '$hours hrs $minutes min $seconds sec';
  }

  String formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  String formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  void scheduleBackgroundTask() {
    Workmanager().registerOneOffTask(
      '1',
      'simpleTask',
      inputData: <String, dynamic>{'key': 'value'},
    );
  }

  void cancelBackgroundTask() {
    Workmanager().cancelAll();
  }

  Future<void> _initializeNotifications() async {
    _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('mipmap/ic_launcher_latest'); // Check icon name here
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await _localNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your channel id', 'your channel name', importance: Importance.max, priority: Priority.high, showWhen: false);
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await _localNotificationsPlugin.show(0, 'Timer Running', 'The timer is running in the background.', platformChannelSpecifics);
  }
}

class WeekDataStaffNew extends StatefulWidget {
  final String slug;
  final String? clientslug;
  final String StartTime;
  final String EndTime;
  final String? email;
  final String? companyName;
  final String? images;
  final String? breakTimes;
  final String? assignStartDate;
  final String? assignEndDate;
  // final List<String?> methods;
  const WeekDataStaffNew({
    super.key,
    required this.slug,
    required this.StartTime,
    required this.EndTime,
    this.email,
    this.companyName,
    this.images,
    this.breakTimes,
    this.clientslug,
    this.assignStartDate,
    this.assignEndDate,
    // this.methods = const [],
  });

  @override
  State<WeekDataStaffNew> createState() => _WeekDataStaffNewState();
}

class _WeekDataStaffNewState extends State<WeekDataStaffNew> with WidgetsBindingObserver {
  bool showText = false;
  String? user;
  String? startTime;
  String? endTime;
  bool isLoading = false;

  late TimerProviderAgain _timerProvider;
  late String a; // Define 'a' here
  late String b;
  late Future<WeekDataClientModel?> _clientWeekDataFuture;

  bool _showNoInternetConnectionMessage = false;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  /// Updated Function
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _timerProvider = Provider.of<TimerProviderAgain>(context, listen: false);

    a = widget.StartTime;
    b = widget.EndTime;
    _timerProvider.a = a;
    _timerProvider.b = b;
    _timerProvider._loadTimerState();
    _timerProvider.printValues();
    _clientWeekDataFuture = fetchClientWeekList();

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
      bool hasInternet = await _hasInternetConnection(); // Check internet access

      if (result != ConnectivityResult.none && hasInternet && _showNoInternetConnectionMessage) {
        _refreshData().then((_) {
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

  /// Updated Function
  @override
  void dispose() {
    _timerProvider.saveTimerRecords();
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription.cancel();
    super.dispose();
  }

  /// Updated Function
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == _timerProvider.isRunning) {
      _timerProvider._showNotification();
    }
    if (state == AppLifecycleState.resumed) {
      _refreshData();
    }
    super.didChangeAppLifecycleState(state);
  }

  /// Updated Function
  Future<void> _refreshData() async {
    var freshData = await fetchClientWeekList();

    if (freshData != null) {
      setState(() {
        _clientWeekDataFuture = Future.value(freshData);
      });
    } else {
      setState(() {
        _showNoInternetConnectionMessage = true;
      });
    }
  }

  ///Updated Function
  Future<WeekDataClientModel?> fetchClientWeekList() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    bool hasInternet = await _hasInternetConnection();

    if (connectivityResult == ConnectivityResult.none || !hasInternet) {
      // No internet connection
      setState(() {
        _showNoInternetConnectionMessage = true;
      });
      return null;
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String _token = prefs.getString('token') ?? '';

      final String apiUrl = '${AppUrl.baseUrl}/api/app/weekly-data-by-users?client_slug=${widget.clientslug}';
     print(apiUrl);
      final response = await https.get(Uri.parse(apiUrl), headers: {
        'Authorization': 'Bearer $_token',
      });
      if (response.statusCode == 200) {
        return weekDataClientModelFromJson(response.body);
      } else {
        throw Exception('Failed to load');
      }
    }
  }

  Future<void> showConfirmationDialog(BuildContext context, Function() onConfirmed) async {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        double screenWidth = MediaQuery.of(context).size.width * 1;
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'You have attempted to submit less than 15 minutes of time to the client, are you sure you wish to submit your timesheet?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
                onConfirmed();
              },
              child: Container(
                width: screenWidth * 0.2,
                color: AppColors.navButtonColor,
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
                color: AppColors.navOpacity,
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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: _showNoInternetConnectionMessage ? Colors.red : AppColors.navColor));

    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return WillPopScope(
      onWillPop: () async {
        if (Provider.of<TimerProviderAgain>(context, listen: false).isRunning) {
          Provider.of<TimerProviderAgain>(context, listen: false)._showNotification();
        }
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => StaffCurveNabBar()));
        return false;
      },
      child: SafeArea(
        child: GestureDetector(
          onTap: () {
            setState(() {
              showText = false;
            });
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            body: RefreshIndicator(
              onRefresh: _refreshData,
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
      ),
    );
  }

  Widget body() {
    final userPrefernece = Provider.of<UserViewModel>(context);
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    // final methods = widget.methods ?? [];
    List<String> transformedMethods = [];
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: GestureDetector(
        onTap: () {
          setState(() {
            showText = false;
          });
        },
        child: Column(
          children: [
            // Text("${widget.methods}"),
            // Text("${widget.breakTimes}"),

            SizedBox(
              height: screenHeight * 0.005,
            ),
            Center(
              child: FutureBuilder<WeekDataClientModel?>(
                future: _clientWeekDataFuture,
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
                        SizedBox(height: screenHeight * 0.013),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => StaffCurveNabBar()));
                                  },
                                  child: HeaderRow(Icons.arrow_back))),
                        ),
                        SizedBox(height: screenHeight * 0.013),
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
                    // return Text("${snapshot.error}");
                  } else {
                    final List<Datum>? weekList = snapshot.data?.data;
                    final calculationMethodJson = snapshot.data?.method ?? "[]";

                    List<String> calculationMethods = [];
                    try {
                      calculationMethods = List<String>.from(json.decode(calculationMethodJson));
                    } catch (e) {
                      calculationMethods = [];
                    }

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

                    if ((weekList != null && weekList.isNotEmpty) || transformedMethods.contains("One") || transformedMethods.contains("Manu") || transformedMethods.contains("Pero")) {
                      return Container(
                        width: screenWidth * 0.95,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            // SizedBox(height: screenHeight*0.005,),
                            Stack(
                              children: [
                                Column(
                                  children: [
                                    SizedBox(
                                      height: screenHeight * 0.013,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                            onTap: () {
                                              final timerProvider = Provider.of<TimerProviderAgain>(context, listen: false);
                                              if (timerProvider.isRunning) {
                                                timerProvider._showNotification();
                                              }
                                              // Navigator.pop(context);
                                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => StaffCurveNabBar()));
                                            },
                                            child: HeaderRow(Icons.arrow_back)),
                                        Text(
                                          "Timesheets",
                                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                        ),
                                        if (transformedMethods != null && (transformedMethods.contains("Manu") && transformedMethods.contains("Pero")))
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                showText = !showText;
                                              });
                                            },
                                            child: HeaderRow(Icons.edit_note_outlined),
                                          )
                                        else if (transformedMethods != null && transformedMethods.contains("Manu"))
                                          GestureDetector(
                                              onTap: () {
                                                final timerProvider = Provider.of<TimerProviderAgain>(context, listen: false);
                                                if (timerProvider.isRunning) {
                                                  timerProvider._showNotification();
                                                }
                                                final selectedSlug = '${widget.slug}';
                                                final selectedClientSlug = '${widget.clientslug}';
                                                final selectedStartTime = '${widget.StartTime}';
                                                final selectedEndtime = '${widget.EndTime}';
                                                final selectedCompanyName = '${widget.companyName}';
                                                final selectedEmail = '${widget.email}';
                                                final selectedImage = '${widget.images}';
                                                // final selectedMethods = widget.methods;
                                                final selectedBreak = widget.breakTimes;
                                                // print("--------------$selectedMethods");
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => ManualCalculationNew(
                                                        Passimage: selectedImage,
                                                        clientslug: selectedClientSlug,
                                                        PasscompanyName: selectedCompanyName,
                                                        Passemail: selectedEmail,
                                                        slug: selectedSlug,
                                                        StartTime: selectedStartTime,
                                                        EndTime: selectedEndtime,
                                                        // methods:selectedMethods,
                                                        breakTimes: selectedBreak),
                                                  ),
                                                ).then((value) {
                                                  if (value != null) {
                                                    print('Received data from IndividualView: $value');
                                                  }
                                                });
                                                setState(() {
                                                  showText = false;
                                                });
                                              },
                                              child: HeaderRow(
                                                Icons.calculate_outlined,
                                              ))
                                        else if (transformedMethods != null && transformedMethods.contains("Pero"))
                                          GestureDetector(
                                              onTap: () {
                                                final timerProvider = Provider.of<TimerProviderAgain>(context, listen: false);
                                                if (timerProvider.isRunning) {
                                                  timerProvider._showNotification();
                                                }
                                                final selectedSlug = '${widget.slug}';
                                                final selectedClientSlug = '${widget.clientslug}';
                                                final selectedStartTime = '${widget.StartTime}';
                                                final selectedEndtime = '${widget.EndTime}';
                                                final selectedCompanyName = '${widget.companyName}';
                                                final selectedEmail = '${widget.email}';
                                                final selectedImage = '${widget.images}';
                                                final selectedAssignStartDate = '${widget.assignStartDate}';
                                                final selectedAssignEndDate = '${widget.assignEndDate}';
                                                // final selectedMethods = widget.methods;
                                                final selectedBreak = widget.breakTimes;
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => NormalCalculationNew(
                                                      Passimage: selectedImage,
                                                      clientslug: selectedClientSlug,
                                                      PasscompanyName: selectedCompanyName,
                                                      Passemail: selectedEmail,
                                                      slug: selectedSlug,
                                                      startedTime: selectedStartTime,
                                                      endedTime: selectedEndtime,
                                                      // methods:selectedMethods,
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
                                              },
                                              child: HeaderRow(
                                                Icons.more_time_rounded,
                                              ))
                                        else
                                          SizedBox(
                                            height: screenHeight * 0.055,
                                            width: screenWidth * 0.12,
                                          ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: screenHeight * 0.013,
                                    ),
                                    if (transformedMethods.contains("One"))
                                      Consumer<TimerProviderAgain>(builder: (context, timerProvider, child) {
                                        int overallTotalTime = timerProvider.timerRecords.fold<int>(
                                          0,
                                          (previousValue, record) => previousValue + record.total,
                                        );

                                        bool isAnyTimerRunning = timerProvider.activeTimers.values.any((isActive) => isActive);
                                        bool isClientTimerRunning = timerProvider.isTimerRunningForClient(widget.clientslug!);
                                        return Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10.0),
                                              child: Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Text(
                                                    "Timer Set",
                                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                                  )),
                                            ),
                                            SizedBox(
                                              height: screenHeight * 0.005,
                                            ),
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
                                                    height: screenHeight * 0.013,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      Container(
                                                        width: screenWidth * 0.6,
                                                        child: Row(
                                                          children: [
                                                            Consumer<TimerProviderAgain>(
                                                              builder: (context, timerProvider, child) {
                                                                return Container(
                                                                  height: 50,
                                                                  width: screenWidth * 0.6,
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.white,
                                                                    borderRadius: BorderRadius.circular(10),
                                                                    border: Border.all(width: 0.4),
                                                                  ),
                                                                  child: Center(
                                                                    child: Text(
                                                                      formatElapsedTime(timerProvider.elapsedTime, isClientTimerRunning),
                                                                      style: TextStyle(fontSize: 24),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                            // SizedBox(height: screenHeight * 0.013),
                                                          ],
                                                        ),
                                                      ),
                                                      Consumer<TimerProviderAgain>(
                                                        builder: (context, timerProvider, child) {
                                                          return Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                            children: [
                                                              if (!isAnyTimerRunning || !isClientTimerRunning) // Show start button if timer is not running
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    if (isAnyTimerRunning) {
                                                                      showDialog(
                                                                        context: context,
                                                                        builder: (context) => AlertDialog(
                                                                          title: Text("Timer Running"),
                                                                          content: Text("Timer is already running from another client. Please stop it before starting a new one."),
                                                                          actions: [
                                                                            TextButton(
                                                                              onPressed: () {
                                                                                Navigator.of(context).pop();
                                                                              },
                                                                              child: Text("OK"),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      );
                                                                    } else {
                                                                      showDialog(
                                                                        barrierDismissible: false,
                                                                        context: context,
                                                                        builder: (context) {
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
                                                                            content: Text(
                                                                              'Timesheet started, breaks are automatically deducted so please do not stop the timer for breaks.',
                                                                              textAlign: TextAlign.center,
                                                                            ),
                                                                            actions: [
                                                                              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                                                GestureDetector(
                                                                                  onTap: () {
                                                                                    Navigator.of(context).pop();
                                                                                    timerProvider.startTimer(widget.clientslug!);
                                                                                  },
                                                                                  child: Container(
                                                                                    width: screenWidth * 0.2,
                                                                                    // color:  AppColors.navButtonColor,
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
                                                                                          fontSize: 16,
                                                                                          fontWeight: FontWeight.w600,
                                                                                          letterSpacing: 1,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                SizedBox(
                                                                                  width: screenWidth * 0.05,
                                                                                ),
                                                                                GestureDetector(
                                                                                    onTap: () {
                                                                                      Navigator.of(context).pop();
                                                                                    },
                                                                                    child: Container(
                                                                                        width: screenWidth * 0.2,
                                                                                        // color:  AppColors.navOpacity,
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
                                                                                              fontSize: 16,
                                                                                              fontWeight: FontWeight.w600,
                                                                                              letterSpacing: 1,
                                                                                            ),
                                                                                          ),
                                                                                        ))),
                                                                              ])
                                                                            ],
                                                                          );
                                                                        },
                                                                      );
                                                                    }
                                                                  },
                                                                  child: Container(
                                                                    height: 40,
                                                                    width: 40,
                                                                    decoration: BoxDecoration(
                                                                      color: AppColors.navOpacity,
                                                                      shape: BoxShape.circle,
                                                                    ),
                                                                    child: Icon(Icons.not_started_outlined, color: Colors.green, size: 25),
                                                                  ),
                                                                ),
                                                              if (isClientTimerRunning) // Show stop button if timer is running
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    setState(() {
                                                                      timerProvider.stopTimer(widget.clientslug!);
                                                                    });
                                                                    showDialog(
                                                                      barrierDismissible: false,
                                                                      context: context,
                                                                      builder: (context) {
                                                                        // Calculate total time to be shown
                                                                        int totalMilliseconds =
                                                                            timerProvider.elapsedTime + timerProvider.timerRecords.fold(0, (previousValue, element) => previousValue + element.total);
                                                                        int totalHours = totalMilliseconds ~/ (1000 * 60 * 60);
                                                                        int totalMinutes = (totalMilliseconds % (1000 * 60 * 60)) ~/ (1000 * 60);
                                                                        int totalSeconds = (totalMilliseconds % (1000 * 60)) ~/ 1000;
                                                                        String totalTimeText =
                                                                            "Timesheet stopped, do you want to submit timesheet for ${totalHours}h ${totalMinutes}m ${totalSeconds}s?";
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
                                                                          title: Row(
                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              SizedBox.shrink(),
                                                                              GestureDetector(
                                                                                  onTap: () {
                                                                                    timerProvider.resetTimer();
                                                                                    Navigator.of(context).pop();
                                                                                  },
                                                                                  child: Container(
                                                                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                                                      decoration: BoxDecoration(
                                                                                        gradient: LinearGradient(
                                                                                          colors: [Colors.redAccent, Colors.deepOrange],
                                                                                          begin: Alignment.topLeft,
                                                                                          end: Alignment.bottomRight,
                                                                                        ),
                                                                                        borderRadius: BorderRadius.circular(15),
                                                                                        boxShadow: [
                                                                                          BoxShadow(
                                                                                            color: Colors.black.withOpacity(0.2),
                                                                                            spreadRadius: 2,
                                                                                            blurRadius: 2,
                                                                                            offset: Offset(0, 1),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                      child: Text(
                                                                                        "Reset",
                                                                                        style: TextStyle(color: Colors.white, fontSize: 12),
                                                                                      ))
                                                                                  // Icon(
                                                                                  //   Icons.cancel_presentation,
                                                                                  //   color: Colors.red,
                                                                                  // ),
                                                                                  ),
                                                                            ],
                                                                          ),
                                                                          content: Text(totalTimeText, textAlign: TextAlign.center),
                                                                          actions: [
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                GestureDetector(
                                                                                  onTap: () async {
                                                                                    Navigator.of(context).pop(); // Close the dialog
                                                                                    final timerRecords = timerProvider.timerRecords;
                                                                                    final assignSlug = '${widget.slug}';
                                                                                    timerProvider.submitTimer(context);
                                                                                    Utils.showDialogLoading(context);
                                                                                    await postData(timerRecords, assignSlug);
                                                                                    print("--------------$timerRecords");
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
                                                                                SizedBox(
                                                                                  width: screenWidth * 0.05,
                                                                                ),
                                                                                GestureDetector(
                                                                                    onTap: () {
                                                                                      setState(() {
                                                                                        timerProvider.startTimer(widget.clientslug!);
                                                                                      });
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
                                                                                        ))),
                                                                              ],
                                                                            )
                                                                          ],
                                                                        );
                                                                      },
                                                                    );
                                                                  },
                                                                  child: Container(
                                                                    height: 40,
                                                                    width: 40,
                                                                    decoration: BoxDecoration(
                                                                      color: AppColors.navOpacity,
                                                                      shape: BoxShape.circle,
                                                                    ),
                                                                    child: Icon(Icons.stop, color: Colors.red, size: 25),
                                                                  ),
                                                                ),
                                                            ],
                                                          );
                                                        },
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
                                        );
                                      }),
                                    SizedBox(
                                      height: screenHeight * 0.013,
                                    ),
                                    if (weekList != null && weekList.isNotEmpty)
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: weekList.length,
                                        itemBuilder: (context, index) {
                                          final week = weekList[index];
                                          final calculationIds = week.calculationIds?.join(', ') ?? '';
                                          dynamic calculationTypes = week.calculationType ?? "";
                                          if (calculationTypes!.length > 20) {
                                            calculationTypes = '${calculationTypes.substring(0, 20)}...';
                                          }

                                          List<TextSpan> _getTextSpans(String? text) {
                                            if (text == null || text.isEmpty) {
                                              return [
                                                TextSpan(
                                                  text: '',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ];
                                            }

                                            final RegExp numberRegExp = RegExp(r'\d+');
                                            final matches = numberRegExp.allMatches(text);
                                            final List<TextSpan> spans = [];
                                            int lastMatchEnd = 0;

                                            for (final match in matches) {
                                              if (match.start > lastMatchEnd) {
                                                spans.add(
                                                  TextSpan(
                                                    text: text.substring(lastMatchEnd, match.start),
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.white,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                );
                                              }
                                              spans.add(
                                                TextSpan(
                                                  text: match.group(0),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              );
                                              lastMatchEnd = match.end;
                                            }

                                            if (lastMatchEnd < text.length) {
                                              spans.add(
                                                TextSpan(
                                                  text: text.substring(lastMatchEnd),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              );
                                            }

                                            return spans;
                                          }

                                          String replaceUnderscoreWithSpace(String input) {
                                            return input.replaceAll('_', ' ');
                                          }

                                          String truncateText(String text, int maxLength) {
                                            return text.length > maxLength ? '${text.substring(0, maxLength)}...' : text;
                                          }

                                          return Column(
                                            children: [
                                              Container(
                                                width: screenWidth * 0.95,
                                                decoration: BoxDecoration(
                                                  color: AppColors.whiteColor,
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(
                                                    width: 0.2,
                                                    color: AppColors.navButtonColor,
                                                  ), // Border radius
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: AppColors.blackOpacity,
                                                      offset: Offset(4, 4),

                                                      // offset: Offset(0,0,),
                                                      blurRadius: 1,
                                                      spreadRadius: 0,
                                                    ),
                                                    BoxShadow(
                                                      color: Colors.white,
                                                      offset: Offset(-4, -4),
                                                      blurRadius: 5,
                                                      spreadRadius: 1,
                                                    ),
                                                  ],

                                                ),
                                                child: Column(
                                                  children: [
                                                    Container(
                                                        width: screenWidth * 0.95,
                                                        decoration: BoxDecoration(
                                                          color: AppColors.navButtonColor,
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: AppColors.greyOpacity,
                                                              offset: Offset(0, 0,),
                                                              blurRadius: 0.5,
                                                              spreadRadius: 0,
                                                            ),
                                                          ],
                                                          borderRadius: BorderRadius.only(
                                                            topLeft: Radius.circular(10),
                                                            topRight: Radius.circular(10),
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding: EdgeInsets.only(top:5,bottom: 5),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Padding(
                                                                padding: const EdgeInsets.only(left:5.0),
                                                                child: Container(
                                                                  width: screenWidth * 0.24,
                                                                  // color: Colors.red,
                                                                  child: RichText(
                                                                    text: TextSpan(
                                                                      children: _getTextSpans(week.week),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                width: screenWidth * 0.66,
                                                                height: screenHeight * 0.05,
                                                                padding: EdgeInsets.only(
                                                                  top: 1,
                                                                  bottom: 1,
                                                                ),
                                                                decoration: BoxDecoration(
                                                                  // color: Colors.yellowAccent,
                                                                  borderRadius: BorderRadius.circular(5),
                                                                ),
                                                                child: Center(
                                                                  child: AutoSizeText(
                                                                    "${week.weekDatesRange ?? ""}",
                                                                    style: TextStyle(color: AppColors.whiteColor),
                                                                  ),
                                                                ),
                                                              ),

                                                            ],
                                                          ),
                                                        )),
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                "Company Name : ",
                                                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                                              ),
                                                              AutoSizeText(
                                                                MediaQuery.of(context).size.width < 600
                                                                    ? truncateText(replaceUnderscoreWithSpace("${week.companyName ?? ""}"), 23) // Truncate for mobile
                                                                    : replaceUnderscoreWithSpace("${week.companyName ?? ""}"), // Full name for tablet/desktop
                                                                style: TextStyle(
                                                                  fontSize: 15,
                                                                  color: AppColors.blackColor.withOpacity(0.6),
                                                                ),
                                                              ),

                                                            ],
                                                          ),

                                                          Padding(
                                                            padding: const EdgeInsets.only(right: 7),
                                                            child: InkWell(
                                                              onTap: () {
                                                                final timerProvider = Provider.of<TimerProviderAgain>(context, listen: false);
                                                                if (timerProvider.isRunning) {
                                                                  timerProvider._showNotification();
                                                                }
                                                                final passcalculationIds = week.calculationIds ?? [];
                                                                dynamic hour = week.totalWorkingHours;
                                                                dynamic date = week.calculationDate;
                                                                print(passcalculationIds);
                                                                print(hour);
                                                                // dynamic date = week.calculationDate;
                                                                dynamic status = week.status;
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => WeekDataStaffDetails(
                                                                            ids: passcalculationIds,
                                                                            email: widget.email,
                                                                            companyName: widget.companyName,
                                                                            images: widget.images,
                                                                            breakTimes: widget.breakTimes,
                                                                            status: status,
                                                                            hour: hour,
                                                                            date: date)));
                                                                setState(() {
                                                                  showText = false;
                                                                });
                                                              },
                                                              child: Icon(
                                                                Icons.info_outline,
                                                                color: AppColors.blackColor,
                                                              ),
                                                            ),
                                                          )


                                                        ],
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [
                                                        RowData("Assign. ID", week.assignmentId ?? ""),
                                                        RowData("Total Hours", " ${double.tryParse(week.totalWorkingHours.toString())!.toStringAsFixed(2) ?? ""} hour")
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: screenHeight * 0.013,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: screenHeight * 0.02,
                                              ),
                                            ],
                                          );
                                        },
                                      )
                                    else
                                      Align(
                                          alignment: Alignment.center, // Adjust alignment as needed
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                                            height: screenHeight * 0.75,
                                            width: screenWidth,
                                            color: AppColors.whiteColor,
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.timer_off,
                                                    color: AppColors.navColor,
                                                    size: screenWidth * 0.12,
                                                  ),
                                                  SizedBox(
                                                    height: screenHeight * 0.02,
                                                  ),
                                                  Text(
                                                    'No Timesheets Logged',
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
                                                    'To log a timesheet, please tap the top right button to enter a timesheet.',
                                                    style: TextStyle(
                                                      fontSize: screenWidth * 0.035,
                                                      color: AppColors.navColor,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ))
                                  ],
                                ),
                                Positioned(
                                  top: screenHeight * 0.075,
                                  right: screenWidth * 0.045,
                                  child: Visibility(
                                    visible: showText,
                                    child: Container(
                                      // height: 120,
                                      width: screenWidth * 0.45,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        // color: Colors.blueGrey.shade700,
                                        color: AppColors.navButtonColor,
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(0),
                                          topLeft: Radius.circular(5),
                                          bottomLeft: Radius.circular(5),
                                          bottomRight: Radius.circular(5),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          if (transformedMethods != null && transformedMethods.contains("Manu"))
                                            InkWell(
                                              onTap: () {
                                                final timerProvider = Provider.of<TimerProviderAgain>(context, listen: false);
                                                if (timerProvider.isRunning) {
                                                  timerProvider._showNotification();
                                                }
                                                final selectedSlug = '${widget.slug}';
                                                final selectedClientSlug = '${widget.clientslug}';
                                                // final selectedStartTime = '$startTime';
                                                // final selectedEndtime = '$endTime';
                                                final selectedStartTime = '${widget.StartTime}';
                                                final selectedEndtime = '${widget.EndTime}';

                                                final selectedCompanyName = '${widget.companyName}';
                                                final selectedEmail = '${widget.email}';
                                                final selectedImage = '${widget.images}';
                                                // final selectedMethods = widget.methods;
                                                final selectedBreak = widget.breakTimes;
                                                // print("--------------$selectedMethods");

                                                // Navigator.push(context, MaterialPageRoute(builder: (context) => ManualCalculationAssignment(Passimage: selectedImage,PasscompanyName:selectedCompanyName,Passemail:selectedEmail,slug: selectedSlug, StartTime:selectedStartTime, EndTime:selectedEndtime,),),
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => ManualCalculationNew(
                                                        Passimage: selectedImage,
                                                        clientslug: selectedClientSlug,
                                                        PasscompanyName: selectedCompanyName,
                                                        Passemail: selectedEmail,
                                                        slug: selectedSlug,
                                                        StartTime: selectedStartTime,
                                                        EndTime: selectedEndtime,
                                                        // methods:selectedMethods,
                                                        breakTimes: selectedBreak),
                                                  ),
                                                ).then((value) {
                                                  if (value != null) {
                                                    print('Received data from IndividualView: $value');
                                                  }
                                                });
                                                setState(() {
                                                  showText = false;
                                                });
                                              },
                                              child: Container(
                                                  height: screenHeight * 0.05,
                                                  width: screenWidth * 0.45,
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.only(
                                                        topRight: Radius.circular(0),
                                                        topLeft: Radius.circular(5),
                                                      ),
                                                      border: Border.all(color: AppColors.navOpacity)),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      Icon(
                                                        Icons.calculate_outlined,
                                                        color: Colors.white,
                                                      ),
                                                      Text(
                                                        'Manual Timesheet',
                                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                      ),
                                                    ],
                                                  )),
                                            ),
                                          if (transformedMethods != null && transformedMethods.contains("Pero"))
                                            InkWell(
                                              onTap: () {
                                                final timerProvider = Provider.of<TimerProviderAgain>(context, listen: false);
                                                if (timerProvider.isRunning) {
                                                  timerProvider._showNotification();
                                                }
                                                final selectedSlug = '${widget.slug}';
                                                final selectedClientSlug = '${widget.clientslug}';
                                                // final selectedStartTime = '$startTime';
                                                // final selectedEndtime = '$endTime';
                                                final selectedStartTime = '${widget.StartTime}';
                                                final selectedEndtime = '${widget.EndTime}';

                                                final selectedCompanyName = '${widget.companyName}';
                                                final selectedEmail = '${widget.email}';
                                                final selectedImage = '${widget.images}';
                                                // final selectedMethods = widget.methods;
                                                final selectedBreak = widget.breakTimes;
                                                final selectedAssignStartDate = '${widget.assignStartDate}';
                                                final selectedAssignEndDate = '${widget.assignEndDate}';
                                                // print("--------------$selectedMethods");

                                                // Navigator.push(context, MaterialPageRoute(builder: (context) => NormalCalculationAssignment(Passimage: selectedImage,PasscompanyName:selectedCompanyName,Passemail:selectedEmail,slug: selectedSlug, startedTime:selectedStartTime, endedTime:selectedEndtime),),
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => NormalCalculationNew(
                                                      Passimage: selectedImage,
                                                      clientslug: selectedClientSlug,
                                                      PasscompanyName: selectedCompanyName,
                                                      Passemail: selectedEmail,
                                                      slug: selectedSlug,
                                                      startedTime: selectedStartTime,
                                                      endedTime: selectedEndtime,
                                                      // methods:selectedMethods,
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
                                                setState(() {
                                                  showText = false;
                                                });
                                              },
                                              child: Container(
                                                  height: screenHeight * 0.05,
                                                  width: screenWidth * 0.45,
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.only(
                                                        topRight: Radius.circular(0),
                                                        topLeft: Radius.circular(0),
                                                        bottomLeft: Radius.circular(5),
                                                        bottomRight: Radius.circular(5),
                                                      ),
                                                      border: Border.all(color: AppColors.navOpacity)),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      Icon(
                                                        Icons.type_specimen_outlined,
                                                        color: Colors.white,
                                                      ),
                                                      Text(
                                                        'Period Timesheet',
                                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                      ),
                                                    ],
                                                  )),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Column(
                        children: [
                          SizedBox(
                            height: screenHeight * 0.013,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    final timerProvider = Provider.of<TimerProviderAgain>(context, listen: false);
                                    if (timerProvider.isRunning) {
                                      timerProvider._showNotification();
                                    }
                                    // Navigator.pop(context);
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => StaffCurveNabBar()));
                                  },
                                  child: HeaderRow(Icons.arrow_back)),
                              Text(
                                "Timesheets",
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                height: screenHeight * 0.055,
                                width: screenWidth * 0.12,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: screenHeight * 0.013,
                          ),
                          Align(
                              alignment: Alignment.center, // Adjust alignment as needed
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                                height: screenHeight * 0.75,
                                width: screenWidth,
                                color: AppColors.whiteColor,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.timer_off,
                                        color: AppColors.navColor,
                                        size: screenWidth * 0.12,
                                      ),
                                      SizedBox(
                                        height: screenHeight * 0.02,
                                      ),
                                      Text(
                                        'No Timesheets Logged',
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
                                        'To log a timesheet, please tap the top right button to enter a timesheet.',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.035,
                                          color: AppColors.navColor,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ))
                        ],
                      );
                    }
                  }
                },
              ),
            ),
            SizedBox(
              height: screenHeight * 0.013,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> postData(List<TimerRecord> timerRecords, String assignSlug) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';

    try {
      String apiUrl = '${AppUrl.baseUrl}/api/app/staff/timer/store';
      var request = https.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers.addAll({
        'Authorization': 'Bearer $_token',
      });

      // Convert timerRecords to the required format
      List<Map<String, dynamic>> timerRecordsData = timerRecords.map((record) {
        return {
          'date': record.date,
          'totalTime': _formatTotalTime(record.total),
          'daytime': _formatTotalTime(record.daytime),
          'nighttime': _formatTotalTime(record.nighttime),
        };
      }).toList();
      String timerRecordsJson = json.encode({'timerRecords': timerRecordsData, 'assign_slug': assignSlug});
      request.fields['timerRecords'] = json.encode(timerRecordsData);
      request.fields['assign_slug'] = assignSlug;
// print(assignSlug);
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      print('`````````````````');
      print(responseBody);
      print('``````````````````');
      if (response.statusCode == 200) {
        print('Data submitted successfully');
        _timerProvider.clearTimerRecords();
        Utils.flushBarSuccessMessage("Data Submitted Successfully", context);
        var decodedResponse = json.decode(responseBody);
        if (decodedResponse['success'] == true) {
          var serverMessage = decodedResponse['message'];
          print(serverMessage);
        }
        Future.delayed(Duration(seconds: 2), () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => StaffCurveNabBar()),
          );
        });
      } else {
        print('Failed to submit data. Status code: ${response.statusCode}');
        print(response.reasonPhrase);
      }
    } catch (e) {
      print('Error during data submission: $e');
    }
  }

  String formatElapsedTime(int elapsedTime, bool isClientTimerRunning) {
    int totalMilliseconds = elapsedTime;
    int days = totalMilliseconds ~/ (1000 * 60 * 60 * 24);
    int totalSeconds = totalMilliseconds ~/ 1000;
    int milliseconds = totalMilliseconds % 1000;

    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    if (milliseconds == 999) {
      seconds++;
      milliseconds = 0;
    }

    if (hours >= 24) {
      hours = 0;
    }

    // !isClientTimerRunning ? elapsedTime : '00:00:00:00:000';

    if (!isClientTimerRunning) {
      return '00:00:00:00:000';
    }

    return '${days.toString().padLeft(2, '0')}:${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}:${milliseconds.toString().padLeft(3, '0')}';
  }

  String _formatTotalTime(int milliseconds) {
    int totalSeconds = (milliseconds / 1000).floor();
    int days = (totalSeconds / 86400).floor();
    totalSeconds %= 86400;
    int hours = (totalSeconds / 3600).floor();
    totalSeconds %= 3600;
    int minutes = (totalSeconds / 60).floor();
    int seconds = totalSeconds % 60;

    return '${days.toString().padLeft(2, '0')}:'
        '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  Widget RowData(String text, String text2) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * 0.4,
      height: screenHeight * 0.1,
      decoration: BoxDecoration(
        color: AppColors.navOpacity,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyOpacity,
            offset: Offset(2, 2),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AutoSizeText(
            text,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: screenHeight * 0.013,
          ),
          AutoSizeText(
            text2,
            style: TextStyle(fontSize: 15, color: AppColors.blackColor.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}
