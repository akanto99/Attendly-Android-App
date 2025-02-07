import 'dart:async';
import 'dart:convert';
import 'package:c9_app/res/app_url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as https;

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

class TimerProviderNew extends ChangeNotifier with WidgetsBindingObserver {
  late String a;
  late String b;
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
  late Timer _timer;
  late DateTime _startTime;
  late DateTime _stopTime;
  int _elapsedTime = 0;
  bool _running = false;
  List<TimerRecord> _timerRecords = [];
  late FlutterLocalNotificationsPlugin _localNotificationsPlugin; // Add this line


  TimerProviderNew() {
    _initializeNotifications();
    _timer = Timer.periodic(Duration(milliseconds: 10), _updateTimer);
    WidgetsBinding.instance?.addObserver(this);

    // Load timer records data when the TimerProvider is initialized
    _loadTimerRecords();
  }

  void _loadTimerRecords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? recordsJson = prefs.getStringList('timerRecords');

    if (recordsJson != null) {
      _timerRecords = recordsJson.map((jsonString) => TimerRecord.fromJson(json.decode(jsonString))).toList();
      notifyListeners(); // Notify listeners to update UI with loaded data
    }
  }


  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);
  //   if (state == AppLifecycleState.paused && _running) {
  //     _showNotification();
  //   }
  // }

  int get elapsedTime => _elapsedTime;
  bool get isRunning => _running;
  List<TimerRecord> get timerRecords => _timerRecords;

  void _updateTimer(Timer timer) {
    if (_running) {
      _elapsedTime = DateTime.now().difference(_startTime).inMilliseconds;
      _saveTimerState(); // Save timer state here
      notifyListeners();
    }
  }

  void startTimer() {
    if (!_running) {
      _startTime = DateTime.now().subtract(Duration(milliseconds: _elapsedTime));
      _running = true;
      _saveTimerState(); // Save timer state here
      notifyListeners();
    }
  }

  void pauseTimer() {
    if (_running) {
      _running = false;
      _elapsedTime = DateTime.now().difference(_startTime).inMilliseconds;
      _saveTimerState(); // Save timer state here
      notifyListeners();
    }
  }

  void stopTimer() {
    if (_running) {
      pauseTimer();
    }
    _stopTime = DateTime.now(); // Record stop time
    _elapsedTime = 0;
    _saveTimerState();
    _updateTimerRecordsTable();
    _printTimerRecords();
    cancelBackgroundTask();
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
        int AHour=_convertAHour("$a");

        int AMinutes=_convertAMinutes("$a");
        int BHour=_convertBHour("$b");
        int BMinutes=_convertBMinutes("$b");
        print('up $AHour, $BHour');
        Map<String, int> dayNightTimes = calculateDayNightTime(segmentStart, segmentEnd, AHour,AMinutes, BHour,BMinutes);
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

  Map<String, int> calculateDayNightTime(DateTime start, DateTime end,int AHour,int AMinutes,int BHour,int BMinutes) {
    int daytimeDuration = 0;
    int nighttimeDuration = 0;

    int AHour=_convertAHour("$a");

    int AMinutes=_convertAMinutes("$a");
    int BHour=_convertBHour("$b");
    int BMinutes=_convertBMinutes("$b");
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

    return { 'daytime': daytimeDuration, 'nighttime': nighttimeDuration };
  }


  void _saveTimerState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('elapsedTime', _elapsedTime);
    await prefs.setString('startTime', _startTime.toString());
    await prefs.setBool('running', _running);
    List<String> recordsJson = _timerRecords.map((record) => json.encode(record.toJson())).toList();
    prefs.setStringList('timerRecords', recordsJson);
  }

  void _loadTimerState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? storedElapsedTime = prefs.getInt('elapsedTime');
    String? storedStartTime = prefs.getString('startTime');
    bool? storedRunning = prefs.getBool('running');

    if (storedElapsedTime != null && storedStartTime != null && storedRunning != null) {
      _elapsedTime = storedElapsedTime;
      _startTime = DateTime.parse(storedStartTime);
      _running = storedRunning;
      if (_running) {
        startTimer();
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
  //
  // @override
  // void dispose() {
  //   _showNotification();
  //   _timer.cancel();
  //   WidgetsBinding.instance?.removeObserver(this);
  //   super.dispose();
  // }


  Future<void> _initializeNotifications() async {
    _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('mipmap/ic_launcher'); // Check icon name here
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await _localNotificationsPlugin.initialize(initializationSettings);
  }
  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
        'your channel id', 'your channel name',
        importance: Importance.max, priority: Priority.high, showWhen: false);
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await _localNotificationsPlugin.show(
        0, 'Timer Running', 'The timer is running in the background.', platformChannelSpecifics);
  }

}


class TimerScreenNew extends StatefulWidget {

  final String slug;
  final String StartTime;
  final String EndTime;

  const TimerScreenNew({
    required this.slug,
    required this.StartTime,
    required this.EndTime,
    Key? key,
  }) : super(key: key);

  @override
  State<TimerScreenNew> createState() => _TimerScreenNewState();
}

class _TimerScreenNewState extends State<TimerScreenNew> with WidgetsBindingObserver{
  late TimerProviderNew _timerProvider;
  late String a; // Define 'a' here
  late String b;
  @override
  void initState() {
    super.initState();
    _timerProvider = Provider.of<TimerProviderNew>(context, listen: false);
    a = widget.StartTime;
    b = widget.EndTime;
    _timerProvider.a = a;
    _timerProvider.b = b;
    _timerProvider._loadTimerState();
    _timerProvider.printValues();
  }


  @override
  void dispose() {
    final timerProvider = Provider.of<TimerProviderNew>(context, listen: false);
    timerProvider.saveTimerRecords(); // Save timer records before disposing
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused && _timerProvider.isRunning) {
      _timerProvider._showNotification();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final timerProvider = Provider.of<TimerProviderNew>(context, listen: false);
        timerProvider.saveTimerRecords();
        if (timerProvider.isRunning) {
          timerProvider._showNotification();
        }
        return true;
    },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Timer Screen'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(widget.slug),
              Text(widget.StartTime),
              Text(widget.EndTime),
              Consumer<TimerProviderNew>(
                builder: (context, timerProvider, child) {
                  return Text(
                    formatElapsedTime(timerProvider.elapsedTime),
                    style: TextStyle(fontSize: 24),
                  );
                },
              ),
              SizedBox(height: 20),
              Consumer<TimerProviderNew>(
                builder: (context, timerProvider, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: timerProvider.startTimer,
                        child: Text('Start'),
                      ),
                      ElevatedButton(
                        onPressed: timerProvider.pauseTimer,
                        child: Text('Pause'),
                      ),
                      ElevatedButton(
                        onPressed: timerProvider.stopTimer,
                        child: Text('Stop'),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Consumer<TimerProviderNew>(
                  builder: (context, timerProvider, child) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            _rowHeader('Date', 1),
                            _rowHeader('Start Date', 1),
                            _rowHeader('Start Time', 1),
                            _rowHeader('End Date', 1),
                            _rowHeader('End Time', 1),
                            _rowHeader('Total Time', 1),
                            _rowHeader('Daytime', 1),
                            _rowHeader('Nighttime', 1),
                          ],
                        ),
                        Column(
                          children: timerProvider.timerRecords.map((record) {
                            return Row(
                              children: [
                                _rHeader(record.date, 1),
                                _rHeader(record.startDate.join(', '), 1),
                                _rHeader(record.startTime.join(', '), 1),
                                _rHeader(record.endDate.join(', '), 1),
                                _rHeader(record.endTime.join(', '), 1),
                                _rHeader(_formatTotalTime(record.total), 1),
                                _rHeader(_formatTotalTime(record.daytime), 1),
                                _rHeader(_formatTotalTime(record.nighttime), 1),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                ),
              ),


              ElevatedButton(
                onPressed: () async {
                  final timerProvider = Provider.of<TimerProviderNew>(context, listen: false);
                  final timerRecords = timerProvider.timerRecords;
                  final assignSlug = '${widget.slug}';

                  await postData(timerRecords, assignSlug);
                },
                child: Text("Post Display Data"),
              )


            ],
          ),
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

      // Convert the timerRecordsData list to JSON
      String timerRecordsJson = json.encode({'timerRecords': timerRecordsData, 'assign_slug': assignSlug});

      // Add timerRecordsJson to the request body
      request.fields['timerRecords'] = json.encode(timerRecordsData);
      request.fields['assign_slug'] =  json.encode(assignSlug);


      var response = await request.send();
      print(await response.stream.bytesToString());
      if (response.statusCode == 200) {
        print('Data submitted successfully');
        // print(await response.stream.bytesToString());
        // print("---------------$timerRecordsJson");
        // print("....................$timerRecordsJson");
      } else {
        print('Failed to submit data. Status code: ${response.statusCode}');
        print(response.reasonPhrase);
        print("-------------------$timerRecordsJson");
      }
    } catch (e) {
      print('Error during data submission: $e');
    }
  }

  Widget _rowHeader(String text, int flex) {
    return Expanded(
      flex: flex,
      child: Container(
        height: 40,
        padding: EdgeInsets.only(left: 5),
        decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
                color: Colors.black26,
                width: 0.4
            )
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _rHeader(String text, int flex) {
    return Expanded(
      flex: flex,
      child: Container(
        height: 80,
        padding: EdgeInsets.only(left: 5),
        decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
                color: Colors.black26,
                width: 0.4
            )
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Center(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  String formatElapsedTime(int elapsedTime) {
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

    return '${days.toString().padLeft(2, '0')}d:${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}:${milliseconds.toString().padLeft(3, '0')}';
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
        '${seconds.toString().padLeft(2,'0')}';
    }


  //
  // Future<void> postData(List<TimerRecord> timerRecords, String assignSlug) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String _token = prefs.getString('token') ?? '';
  //
  //   try {
  //     String apiUrl = '${AppUrl.baseUrl}/api/app/staff/timer/store';
  //     var request = https.MultipartRequest('POST', Uri.parse(apiUrl));
  //     request.headers.addAll({
  //       'Authorization': 'Bearer $_token',
  //     });
  //
  //     // Convert timerRecords to the required format
  //     List<Map<String, dynamic>> timerRecordsData = timerRecords.map((record) {
  //       return {
  //         'date': record.date,
  //         'totalTime': _formatTotalTime(record.total),
  //         'daytime': _formatTotalTime(record.daytime),
  //         'nighttime': _formatTotalTime(record.nighttime),
  //       };
  //     }).toList();
  //
  //     // Convert the timerRecordsData list to JSON
  //     String timerRecordsJson = json.encode({'timerRecords': timerRecordsData, 'assign_slug': assignSlug});
  //
  //     // Add timerRecordsJson to the request body
  //     request.fields['data'] = timerRecordsJson;
  //
  //     var response = await request.send();
  //     if (response.statusCode == 200) {
  //       print('Data submitted successfully');
  //       print(await response.stream.bytesToString());
  //       print("---------------$timerRecordsJson");
  //     } else {
  //       print('Failed to submit data. Status code: ${response.statusCode}');
  //       print(response.reasonPhrase);
  //       print("-------------------$timerRecordsJson");
  //     }
  //   } catch (e) {
  //     print('Error during data submission: $e');
  //   }
  // }



}