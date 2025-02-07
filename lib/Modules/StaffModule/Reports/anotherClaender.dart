import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:c9_app/Modules/StaffModule/DashBoard/staff_navigationScreen.dart';
import 'package:c9_app/Modules/StaffModule/Reports/MODELCalender.dart';
import 'package:c9_app/loadingScreen.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/utils/utils.dart';
import 'package:c9_app/view/widgets/header_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class AnotherTest extends StatefulWidget {
  final String id;
  const AnotherTest({Key? key, required this.id}) : super(key: key);

  @override
  State<AnotherTest> createState() => _AnotherTestState();
}

class _AnotherTestState extends State<AnotherTest> {
  List<Datum>? _events;
  DateTime? _selectedDate;
  TextEditingController _commentController = TextEditingController();
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();
  TextEditingController _rangeCommentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchEvents();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _events = null; // Set events to null to indicate loading state
    });
    await fetchEvents(); // Fetch events from the server
  }


  // Future<void> fetchEvents() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String _token = prefs.getString('token') ?? '';
  //
  //   final String apiUrl =
  //       '${AppUrl.baseUrl}/api/app/calendar/index/${widget.id}';
  //   print("Url: $apiUrl");
  //   final response = await https.get(
  //     Uri.parse(apiUrl),
  //     headers: {
  //       'Authorization': 'Bearer $_token',
  //     },
  //   );
  //
  //   if (response.statusCode == 200) {
  //     final Map<String, dynamic> data = json.decode(response.body);
  //     final CalendarModelClass calendarData = CalendarModelClass.fromJson(data);
  //     setState(() {
  //       _events = calendarData.data;
  //     });
  //   } else {
  //     throw Exception('Failed to load events');
  //   }
  // }
  Future<void> fetchEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';

    final String apiUrl =
        '${AppUrl.baseUrl}/api/app/calendar/index/${widget.id}';
    print("Url: $apiUrl");
    final response = await https.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      print(data); // Add this line to print the JSON response
      final CalendarModelClass calendarData = CalendarModelClass.fromJson(data);
      setState(() {
        _events = calendarData.data;
      });
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<void> deleteEvent(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';

    final String apiUrl = '${AppUrl.baseUrl}/api/app/calendar/delete/$id';
    final response = await https.delete(Uri.parse(apiUrl), headers: {
      'Authorization': 'Bearer $_token',
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final CalendarModelClass calendarData = CalendarModelClass.fromJson(data);
      setState(() {
        _events = calendarData.data;
      });
      print('$id deleted successfully');
    } else {
      throw Exception('Failed to delete Dept Index: $id');
    }
  }

  Future<void> saveComment(String comment) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';

    final String apiUrl = '${AppUrl.baseUrl}/api/app/calendar/store';
    final response = await https.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "start_time": _selectedDate.toString(),
        // "end_time": _selectedDate.toString(),
        "comments": comment,
      }),
    );

    if (response.statusCode == 200) {
      print(response.body);
      print('Comment saved successfully');
      final Map<String, dynamic> data = json.decode(response.body);
      final CalendarModelClass calendarData = CalendarModelClass.fromJson(data);
      setState(() {
        _events = calendarData.data;
      });
    } else {
      print(response.reasonPhrase);
      print('Failed to save comment');
    }
  }

  // Future<void> saveRangeComment(String comment) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String _token = prefs.getString('token') ?? '';
  //
  //   final String apiUrl = '${AppUrl.baseUrl}/api/app/calendar/store';
  //   final response = await https.post(
  //     Uri.parse(apiUrl),
  //     headers: {
  //       'Authorization': 'Bearer $_token',
  //       'Content-Type': 'application/json',
  //     },
  //     body: json.encode({
  //       "start_time": _startDateController.toString(),
  //       "end_time": _endDateController.toString(),
  //       "comments": comment,
  //     }),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     print(response.body);
  //     print('Comment saved successfully');
  //   } else {
  //     print(response.reasonPhrase);
  //     print('Failed to save comment');
  //   }
  // }

  bool isFree = true;
  Future<void> showCommentDialog(BuildContext context, Datum? event) async {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    // Check if any events exist within the selected range
    bool hasEventsInRange = _events?.any((e) {
          DateTime eventStartTime = DateTime.parse(e.startTime!);
          DateTime eventEndTime =
              DateTime.parse(e.endTime!).subtract(Duration(days: 1));
          return _selectedDate!
                  .isAfter(eventStartTime.subtract(Duration(days: 1))) &&
              _selectedDate!.isBefore(eventEndTime.add(Duration(days: 1)));
        }) ??
        false;

    if (hasEventsInRange && event != null) {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Text('Delete'),
            content: Text('Do you want to delete this event?'),
            actions: <Widget>[
              GestureDetector(
                onTap: () async {
                  if (event != null && event.id != null) {
                    Utils.showDialogLoading(context);
                    await deleteEvent(event.id);
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    fetchEvents();
                  } else {
                    print('Event or event ID is null');
                  }
                },
                child: Container(
                  width: screenWidth * 0.2,
                  color: AppColors.navButtonColor,
                  child: Center(
                    child: Text(
                      'Yes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: screenWidth * 0.2,
                  color: AppColors.navOpacity,
                  child: Center(
                    child: Text(
                      'No',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
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
    } else {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: EdgeInsets.all(15),
            // title: Text('Title'),
            content: Row(
              children: [
                InkWell(
                  onTap: () async {
                    String comment = 'Free';
                    Utils.showDialogLoading(context);
                    await saveComment(comment);
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    fetchEvents();
                  },
                  child: Container(
                    width: screenWidth*0.3,

                    // padding: EdgeInsets.all(5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: screenHeight * 0.025,
                          width: screenWidth * 0.04,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(width: 1),
                              shape: BoxShape.circle),
                        ),
                        SizedBox(
                          width: screenWidth * 0.02,
                        ),
                        Text(
                          "Free",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                InkWell(
                  onTap: () async {
                    String comment = 'Busy';
                    Utils.showDialogLoading(context);
                    await saveComment(comment);
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    fetchEvents();
                  },
                  child: Container(
                    width: screenWidth*0.3,
                    // color: AppColors.navOpacity,
                    // padding: EdgeInsets.all(5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: screenHeight * 0.025,
                          width: screenWidth * 0.04,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                  width: 1),
                              shape: BoxShape.circle),
                        ),
                        SizedBox(
                          width: screenWidth * 0.02,
                        ),
                        Text(
                          "Busy",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          surfaceTintColor: Colors.white,
          toolbarHeight: 80,
          title:Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StaffCurveNabBar()));
                },
                child: HeaderRow(Icons.arrow_back),
              ),
              Text(
                "Availability",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Container(
                height: screenHeight * 0.055,
                width: screenWidth * 0.12,
              )
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: ResPonsiveUi(
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
          // SizedBox(height: screenHeight * 0.013),
          // Padding(
          //   padding: const EdgeInsets.only(left: 5, right: 5),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       GestureDetector(
          //         onTap: () {
          //           Navigator.push(
          //               context,
          //               MaterialPageRoute(
          //                   builder: (context) => StaffCurveNabBar()));
          //         },
          //         child: HeaderRow(Icons.arrow_back),
          //       ),
          //       Text(
          //         "Calendar",
          //         style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          //       ),
          //       Container(
          //         height: screenHeight * 0.055,
          //         width: screenWidth * 0.12,
          //       )
          //     ],
          //   ),
          // ),
          // SizedBox(height: screenHeight * 0.013),
          // Container(
          //   // height: screenHeight * 0.25,
          //   decoration: BoxDecoration(color: Colors.white),
          //   child: Padding(
          //     padding: const EdgeInsets.all(8.0),
          //     child: Column(
          //       children: [
          //         Padding(
          //           padding: const EdgeInsets.only(bottom: 5.0),
          //           child: Align(
          //             alignment: Alignment.centerLeft,
          //             child: Text(
          //               'Select Range Date',
          //               style: TextStyle(
          //                   fontSize: 20, fontWeight: FontWeight.w500),
          //             ),
          //           ),
          //         ),
          //         Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //           children: [
          //             buildDateContainerTab("Start Date",'   --:--:--', _startDateController),
          //             SizedBox(width: 16),
          //             buildDateContainerTab("End Date",'   --:--:--', _endDateController),
          //           ],
          //         ),  SizedBox(height: screenHeight * 0.013),
          //
          //         Stack(
          //           children: [
          //             Container(
          //               height: screenHeight * 0.06,
          //               width: screenWidth * 0.96,
          //               decoration: BoxDecoration(
          //                 color: AppColors.navOpacity.withOpacity(0.2),
          //                 border: Border.all(
          //                   color: AppColors.navButtonColor.withOpacity(0.4),
          //                   width: 0.4,
          //                 ),
          //                 borderRadius: BorderRadius.circular(8.0),
          //               ),
          //               child: TextFormField(
          //                 controller: _rangeCommentController,
          //                 keyboardType: TextInputType.multiline,
          //                 maxLines: null,
          //                 decoration: InputDecoration(
          //                   border: InputBorder.none,
          //                   hintText: "Title",
          //                   contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          //                 ),
          //               ),
          //             ),
          //             Positioned(
          //                 bottom: 12,
          //                 right: 2,
          //                 child: GestureDetector(
          //                     onTap: (){
          //                       String comment = _rangeCommentController.text;
          //                       saveRangeComment(comment);
          //                       // Navigator.of(context).pop();
          //                     },
          //                     child: Icon(Icons.send,color:Colors.blueAccent,))
          //             ),
          //           ],
          //         )
          //
          //       ],
          //     ),
          //   ),
          // ),

          _events == null
              ? Container(
                  height: screenHeight * 0.75,
                  width: screenWidth,
                  color: AppColors.whiteColor,
                  child: LoadingScreen(),
                )
              : Container(
                  height: screenHeight * 0.83,
                  // width: screenWidth*0.95,
                  child: SfCalendar(
                    view: CalendarView.month,
                    firstDayOfWeek: 1,
                    dataSource: GoogleDataSource(events: _events!),
                    monthViewSettings: const MonthViewSettings(
                      appointmentDisplayMode:
                          MonthAppointmentDisplayMode.appointment,
                    ),
                    selectionDecoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      border: Border.all(color: Colors.blue),
                    ),
                    viewHeaderStyle: ViewHeaderStyle(
                      backgroundColor: Colors.white,
                      dayTextStyle: TextStyle(
                        color: Colors.deepPurple,
                      ),
                    ),
                    onTap: (CalendarTapDetails details) {
                      if (details.targetElement ==
                          CalendarElement.calendarCell) {
                        setState(() {
                          _selectedDate = details.date;
                        });
                        if (_selectedDate != null) {
                          Datum? selectedEvent = _events?.firstWhere(
                            (e) =>
                                DateTime.parse(e.startTime!).year ==
                                    _selectedDate!.year &&
                                DateTime.parse(e.startTime!).month ==
                                    _selectedDate!.month &&
                                DateTime.parse(e.startTime!).day ==
                                    _selectedDate!.day,
                            orElse: () =>
                                Datum(/* Provide default values here */),
                          );
                          showCommentDialog(context,
                              selectedEvent); // Pass selectedEvent here
                        }
                      }
                    },
                    appointmentBuilder: (BuildContext context,
                        CalendarAppointmentDetails details) {
                      Color backgroundColor;
                      Color textColor;

                      // Iterate over each appointment and check its subject
                      for (final appointment in details.appointments) {
                        final String comment = appointment.subject;

                        if (comment == 'Free') {
                          backgroundColor = Colors.green;
                          textColor = Colors.white;
                        } else if (comment == 'Busy') {
                          backgroundColor = AppColors.navColor;
                          textColor = Colors.white;
                        } else {
                          backgroundColor = Colors.grey;
                          textColor = Colors.black;
                        }
                        return Container(
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(1.0),
                          ),
                          child: Center(
                            child: Text(
                              comment,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }
                      // Return an empty container if no appointments are found
                      return Container();
                    },
                  )),
        ],
      ),
    );
  }



  Widget buildDateContainerTab(
      String title, String labelText, TextEditingController controller) {
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
          contentPadding: EdgeInsets.symmetric(horizontal: 5),
          hintText: labelText,
          hintStyle: TextStyle(
              color: AppColors.blackColor.withOpacity(0.5), fontSize: 15),
          prefixIcon: Container(
            height: screenHeight * 0.065,
            width: screenWidth * 0.20,
            decoration: BoxDecoration(
              color: AppColors.navOpacity,
              border: Border.all(
                color: AppColors.navOpacity,
                width: 0.4,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Center(
                child: AutoSizeText(
              title,
              style: TextStyle(fontSize: 14, color: AppColors.blackColor),
            )),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
        ),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2024),
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
}

class GoogleDataSource extends CalendarDataSource {
  GoogleDataSource({required List<Datum> events}) {
    appointments = events
        .map((event) => Appointment(
              startTime: DateTime.parse(event.startTime!),
              endTime:
                  DateTime.parse(event.endTime!).subtract(Duration(days: 1)),
              subject: event.comments ?? 'No Title',
            ))
        .toList();
  }
}
