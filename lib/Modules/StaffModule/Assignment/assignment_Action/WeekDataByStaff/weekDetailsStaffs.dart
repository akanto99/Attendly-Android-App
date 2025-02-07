import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:c9_app/Modules/ClientModule/model/clientDirectoryModel/calculationModels/WeekDataModel/weekdetails_model.dart';
import 'package:c9_app/Modules/ClientModule/pages/noInternetConnectionWidget.dart';
import 'package:c9_app/Modules/StaffModule/DashBoard/staff_navigationScreen.dart';
import 'package:c9_app/loadingScreen.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/view/widgets/header_widgets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as https;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../view/widgets/icon_container.dart';

class WeekDataStaffDetails extends StatefulWidget {
  final List<int> ids;
  final String? email;
  final String ?companyName;
  final String ?images;
  final String? breakTimes;
  final dynamic status;
  final dynamic  hour;
  final dynamic date;
  const WeekDataStaffDetails({Key? key,
    required this.ids,
    required this.email,
    required this.companyName,
    required this.images,
    required this.breakTimes,
    required this.status,
    required this.hour,
    required this.date,
  }) : super(key: key);

  @override
  State<WeekDataStaffDetails> createState() => _WeekDataStaffDetailsState();
}

class _WeekDataStaffDetailsState extends State<WeekDataStaffDetails> with WidgetsBindingObserver{
  late Future<WeekDataClientDetailsModel?> _clientWeekDataDetailsFuture;

  bool _showNoInternetConnectionMessage = false;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;



  /// UPdated By himu
  @override
  void initState() {
    super.initState();
     WidgetsBinding.instance.addObserver(this);
    _clientWeekDataDetailsFuture = fetchClientWeekDetails();

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result)async{
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
   _connectivitySubscription.cancel(); // Cancel subscription

    super.dispose();
  }
  /// UPdated By himu
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshData( );
    }
    super.didChangeAppLifecycleState(state);
  }

  ///Updated Function By Himu
  Future<void> _refreshData( ) async {

    var freshData = await fetchClientWeekDetails();

    if(freshData != null){
      setState(() {
        _clientWeekDataDetailsFuture = Future.value(freshData);
      });

    }else{
      setState(() {
        _showNoInternetConnectionMessage = true;
      });
    }



  }

  ///Updated BY Himu
  Future<WeekDataClientDetailsModel?> fetchClientWeekDetails() async {

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
        final String apiUrl = '${AppUrl.baseUrl}/api/app/weekly-data-details-by-users';
        final response = await https.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
          },
          body: jsonEncode({
            'calculation_ids': widget.ids,
          }),
        );
        print(widget.ids);
        if (response.statusCode == 200) {
          print('API Response: ${response.body}');


          return weekDataClientDetailsModelFromJson(response.body);
        } else {
          print('Request failed with status: ${response.statusCode}');
          throw Exception('Failed to load data');
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
        appBar: AppBar(
          automaticallyImplyLeading: false,
          surfaceTintColor: Colors.white,
          toolbarHeight: 70,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: HeaderRow(Icons.arrow_back),
              ),
              Text("Week Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>StaffCurveNabBar()));
                },
                child: HeaderRow(Icons.home),
              ),
            ],
          ),
        ),
        body:  RefreshIndicator(
          onRefresh:()=>_refreshData(),
          child:_showNoInternetConnectionMessage ? NoInternetConnection(): ResPonsiveUi(
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

    String ? responsi=widget.companyName ??"";
    if (responsi!.length > 15) {
      responsi = '${responsi.substring(0, 15)}...';
    }
    String formattedDate = '';
    if (widget.date != 'No') {
      DateTime parsedDate =
      DateTime.parse(widget.date.toString());
      formattedDate =
      '${parsedDate.day.toString().padLeft(2, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.year}';
    }

    return  SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Text("${widget.ids}"),
              // Text("${widget.hour}"),

              Center(
                child: FutureBuilder<WeekDataClientDetailsModel?>(
                  future: _clientWeekDataDetailsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        height: screenHeight * 0.8,
                        width: screenWidth,
                        color: AppColors.whiteColor,
                        child: LoadingScreen(),
                      );
                    } else if (snapshot.hasError) {
                      print("${snapshot.error}");
                      return Center(child: Text(""));
                      return Text("${snapshot.error}");
                    } else if (snapshot.hasData && snapshot.data!.data != null) {
                      var weekList = snapshot.data!.data!;
                      return Column(
                        children: [
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0,left: 10,right: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          height: screenHeight * 0.07,
                                          width: screenWidth * 0.15,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: NetworkImage("${AppUrl.clientUsers}/${widget.images}",),fit: BoxFit.cover
                                            ),
                                            color: AppColors.navOpacity,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        SizedBox(width: screenWidth*0.02,),

                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [

                                            GestureDetector(
                                                onTapUp:(details){
                                                  String? responsi = widget.companyName;
                                                  if (responsi != null) {
                                                    _showFullNamePopup(context, responsi, details.globalPosition);
                                                  }
                                                },
                                                child: Text("$responsi",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500),)),
                                            Container(
                                                width:screenWidth*0.45,
                                                child: AutoSizeText("${widget.email}",style: TextStyle(fontSize: 12),)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                        height: screenHeight*0.04,
                                        width: screenWidth*0.3,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(7),
                                            border: Border.all(
                                                width: 1,
                                                color:Colors.grey.withOpacity(0.5)
                                            )
                                        ),

                                        child: Center(child: Text("$formattedDate"))),
                                  ],
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.013,),
                              Padding(
                                padding: const EdgeInsets.only(left: 10,right: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text("Total Hour",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),

                                        SizedBox(width: screenWidth*0.02,),
                                        Container(
                                          height: screenHeight*0.035,
                                          width: screenWidth*0.002,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(width: screenWidth*0.02,),
                                        Text(
                                          "${(double.parse(widget.hour.toString())).toStringAsFixed(2)}",
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),

                                    // Row(
                                    //   children: [
                                    //     Container(
                                    //         height: screenHeight*0.04,
                                    //         width: screenWidth*0.2,
                                    //         child: Center(child: Text("Status",style: TextStyle(fontSize: 17,fontWeight: FontWeight.w500),))),
                                    //
                                    //
                                    //     Container(
                                    //       height: screenHeight*0.035,
                                    //       width: screenWidth*0.002,
                                    //       color: Colors.grey,
                                    //     ),
                                    //
                                    //     Container(
                                    //         height: screenHeight*0.04,
                                    //         width: screenWidth*0.2,
                                    //         child: Center(child: Text(widget.status,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black.withOpacity(0.5)),))),
                                    //   ],
                                    // ),
                                  ],
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.013,),
                              Container(
                                height: screenHeight*0.05,
                                width: screenWidth *0.80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color:AppColors.navButtonColor,
                                ),


                                child: Center(
                                  child: Text("Details",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.005,),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: weekList.length,
                            itemBuilder: (context, index) {
                              var dayDetails = weekList[index];
                              String? daysName = dayDetails.daysName ?? "";


                              //previous code
                              // String shortdaysName = '';
                              // if (daysName != null && daysName.length > 15) {
                              //   shortdaysName = '${daysName.substring(0, 15)}...';
                              // }
                              //

                              String formattedDate = '';
                              String? date = dayDetails.date;
                              if (date != null && date != 'No') {
                                DateTime parsedDate = DateTime.parse(date);
                                formattedDate = '${parsedDate.day.toString().padLeft(2, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.year}';
                              }


                              // Function to get the day name based on the date
                              String getDayName(String? date) {
                                if (date == null || date.isEmpty) return '';
                                try {
                                  DateTime parsedDate = DateTime.parse(date);
                                  return DateFormat('EEEE').format(parsedDate);
                                } catch (e) {
                                  return ''; // Return empty string if parsing fails
                                }
                              }


                              return Padding(
                                padding: const EdgeInsets.all(3),
                                child: Column(
                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.95,
                                      height: MediaQuery.of(context).size.height * 0.065,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Color(0xffFAFAFA),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: screenWidth * 0.3,
                                              height: screenHeight * 0.04,
                                              decoration: BoxDecoration(
                                                color: AppColors.navOpacity,
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                              child: Center(
                                                child: AutoSizeText(
                                                  formattedDate,
                                                  style: TextStyle(fontSize: 13),
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTapUp: (details) {
                                                if (daysName != null) {
                                                 // _showFullNamePopup(context, daysName, details.globalPosition);
                                                }
                                              },
                                              child: Container(
                                                width: screenWidth * 0.3,
                                                height: screenHeight * 0.04,
                                                decoration: BoxDecoration(
                                                  color: AppColors.navOpacity,
                                                  borderRadius: BorderRadius.circular(5),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    // shortdaysName ?? '',
                                                     getDayName(date),
                                                      style: TextStyle(fontSize: 12),),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              height: screenHeight * 0.04,
                                              width: screenWidth * 0.13,
                                              decoration: BoxDecoration(
                                                color: AppColors.navOpacity,
                                                 borderRadius: BorderRadius.circular(5),
                                              ),
                                              child: Center(
                                                child: AutoSizeText(
                                                  '${(double.parse(dayDetails.hours ?? '0')).toStringAsFixed(2)} H',
                                                    style: TextStyle(fontSize: 12),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              height: screenHeight * 0.04,

                                              child: Center(
                                                child: Row(
                                                  children: [
                                                    if (dayDetails.status == Status.APPROVED) // Check status for Approved
                                                      StatusIconContainer(color: Colors.green,),
                                                    if (dayDetails.status == Status.PENDING) // Check status for Decline
                                                      StatusIconContainer(color: AppColors.pending,),
                                                    if (dayDetails.status == Status.DECLINE) // Check status for Decline
                                                      StatusIconContainer(color: Colors.red,),
                                                    if (dayDetails.status == Status.UPDATED) // Check status for Decline
                                                      StatusIconContainer(color: Colors.blueAccent,)


                                                  ],
                                                ),
                                              ),
                                            ),

                                            GestureDetector(
                                              onTap: () {
                                                _showDetailsModalBottomSheet(context, weekList, dayDetails.id);
                                              },
                                              child: Container(
                                                width: MediaQuery.of(context).size.width * 0.1,
                                                child: Icon(Icons.info_outline,size: 22,),
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
                          ),

                        ],
                      );
                    } else {
                      return Center(child: Text('No data available.'));
                    }
                  },
                ),
              ),
            ],
          ),
        );
  }

  void _showFullNamePopup(
      BuildContext context, String fullName, Offset position) {
    final RenderBox overlay =
    Overlay.of(context)!.context.findRenderObject() as RenderBox;
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
            width: 200,
            // height: 40,
            alignment: Alignment.center,
            child: Text(
              fullName,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }


  void _showDetailsModalBottomSheet(
      BuildContext context, List<Datum> viewDetails, dynamic selectedId) {
    Datum selectedDetails =
    viewDetails.firstWhere((details) => details.id == selectedId);

    String formatDate(String date) {
      try {
        DateTime parsedDate = DateTime.parse(date);
        return DateFormat('dd-MM-yyyy').format(parsedDate);
      } catch (e) {
        return date;
      }
    }
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        final screenHeight = MediaQuery.of(context).size.height * 1;
        final screenWidth = MediaQuery.of(context).size.width * 1;
        final fixedHeight = screenHeight * 0.45;

        String getStatusString(Status? status) {
          switch (status) {
            case Status.APPROVED:
              return "Approved";
            case Status.PENDING:
              return "Pending";
            case Status.DECLINE:
              return "Declined";
            case Status.UPDATED:
              return "Approved (Updated)";
            default:
              return "Unknown";
          }
        }

        Color _getBorderColor(String status) {
          switch (status) {
            case "Approved (Updated)":
              return Colors.blueAccent;
            case "Approved":
              return Colors.green;
            case "Pending":
              return AppColors.pending;
            case "Declined":
              return Colors.red;
            default:
              return Colors.grey;
          }
        }
        return FractionallySizedBox(
          widthFactor: screenWidth,
          child: Container(
              width: screenWidth,
              // height: fixedHeight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: screenHeight * 0.07,
                    width: screenWidth,
                    decoration: BoxDecoration(
                      color: AppColors.navButtonColor,
                      // Colors.deepOrangeAccent,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0)),
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
                        Container(
                          height: 5,
                          width: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.grey.shade300,
                            ),
                            color: Colors.grey.shade300,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.007),
                        Text(
                          'Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: screenWidth,
                    color: Colors.white,
                    padding: EdgeInsets.only(left: 5, right: 5),
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.013),
                        singleContainer(
                            "Rate Type",
                            "${selectedDetails.daysName ?? ""}"),
                        SizedBox(height: screenHeight * 0.013),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // doubleContainer(
                            //     "Date", "${selectedDetails.date ?? ""}"),
                            doubleContainer("Date",
                                formatDate("${selectedDetails.date ?? ""}")),
                            doubleContainer(
                              "Total Submitted Hours",
                              "${((double.tryParse(selectedDetails.dayShiftTime ?? '') ?? 0.00) + (double.tryParse(selectedDetails.nightShiftTime ?? '') ?? 0.00)+(double.tryParse(selectedDetails.breakTime ?? '') ?? 0.00)).toStringAsFixed(2)}",                             ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.013),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            doubleContainer("Break Deduction",
                                "${(double.tryParse(selectedDetails.breakTime ?? '') ?? 0.0).toStringAsFixed(2)}"),
                            doubleContainer(
                              "Total Net Hours",
                              "${((double.tryParse(selectedDetails.dayShiftTime ?? '') ?? 0.00) + (double.tryParse(selectedDetails.nightShiftTime ?? '') ?? 0.00)).toStringAsFixed(2)}",
                              ),
                          ],
                        ),

                        SizedBox(height: screenHeight * 0.013),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            doubleContainer("Expenses",
                                "£ ${(double.tryParse(selectedDetails.expenses ?? '') ?? 0.0).toStringAsFixed(2)}"),
                            // doubleContainer("Total Amount",
                            //     "£ ${(double.tryParse(selectedDetails.totalCharge ?? '') ?? 0.0).toStringAsFixed(2)}")
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Status",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                                Container(
                                  height: screenHeight * 0.04,
                                  width: screenWidth * 0.475,
                                  decoration: BoxDecoration(
                                    color: _getBorderColor("${getStatusString(selectedDetails.status)}"),
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: _getBorderColor("${getStatusString(selectedDetails.status)}",),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "${getStatusString(selectedDetails.status)}",
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.013),
                      ],
                    ),
                  ),
                ],
              )),
        );
      },
    );
  }


  Widget singleContainer(String heading, String text) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(heading,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
           ],
        ),
        Container(
            height: screenHeight*0.04,
            width: screenWidth * 0.98,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(child: AutoSizeText(text))
        ),
      ],
    );
  }
  Widget doubleContainer(String heading, String? text) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;

    // Handle the case where text is null
    final displayText = text ?? "N/A";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(heading,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
        Container(
          height: screenHeight * 0.04,
          width: screenWidth * 0.475,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(child: Text(displayText)),
        ),
      ],
    );
  }
}
