import 'dart:convert';
import 'package:c9_app/Modules/ClientModule/client_screen.dart';
import 'package:c9_app/Modules/StaffModule/Reports/MODELCalender.dart';
import 'package:c9_app/loadingScreen.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/view/widgets/header_widgets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class ClientCalendar extends StatefulWidget {
  final String id;
  const ClientCalendar({Key? key,required this.id}) : super(key: key);

  @override
  State<ClientCalendar> createState() => _ClientCalendarState();
}

class _ClientCalendarState extends State<ClientCalendar> {
  List<Datum>? _events;

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';

    final String apiUrl = '${AppUrl.baseUrl}/api/app/calendar/index/${widget.id}';
    final response = await https.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final CalendarModelClass calendarData = CalendarModelClass.fromJson(data);
      setState(() {
        _events = calendarData.data;
      });
    } else {
      throw Exception('Failed to load events');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ResPonsiveUi(
          mobile: body(),
          desktop: body(),
          tablet: body(),
        ),
      ),
    );
  }

  Widget body() {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;

    return  SingleChildScrollView(
      child: Column(
        children: [
            SizedBox(height: screenHeight * 0.013),
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => ClientCurveNabBar()));
                    },
                    child: HeaderRow(Icons.arrow_back),
                  ),
                  Text(
                    "Availability",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  Container(
                    height: screenHeight * 0.055,
                    width: screenWidth * 0.12,)

                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.013),
            _events == null
                ? Container(
              height: screenHeight * 0.75,
              width: screenWidth,
              color: AppColors.whiteColor,
              child: LoadingScreen(),
            )
                : Container(
              height: screenHeight*0.83,
                  child: SfCalendar(
                                view: CalendarView.month,
                                dataSource: GoogleDataSource(events: _events!),
                                monthViewSettings: const MonthViewSettings(
                  appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                                ),
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
                              ),
                ),
          ],
        ),
      );
  }
}

class GoogleDataSource extends CalendarDataSource {
  GoogleDataSource({required List<Datum> events}) {
    appointments = events.map((event) => Appointment(
      startTime: DateTime.parse(event.startTime!),
      endTime:  DateTime.parse(event.endTime!).subtract(Duration(days: 1)),
      subject: event.comments ?? 'No Title',
      // color: event.comments == 'Free' ? Colors.green : AppColors.navColor,
    )).toList();
  }
}
