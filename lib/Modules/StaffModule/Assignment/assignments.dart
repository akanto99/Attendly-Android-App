import 'dart:async';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:c9_app/Modules/ClientModule/pages/noInternetConnectionWidget.dart';
import 'package:c9_app/Modules/StaffModule/DashBoard/staff_navigationScreen.dart';
import 'package:c9_app/Modules/StaffModule/MODEL/assignmentModel/assignmentDetailsModel/assignmentsModel.dart';
import 'package:c9_app/loadingScreen.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/view/widgets/header_widgets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as https;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Assignments extends StatefulWidget {
  final String? slug;
  final String? email;
  final String ?companyName;
  final String ?images;
  const Assignments({super.key,
    required this.slug,
    required this.email,
    required this.companyName,
    required this.images,
  });

  @override
  State<Assignments> createState() => _AssignmentsState();
}

class _AssignmentsState extends State<Assignments> with WidgetsBindingObserver{
  late Future<AssignmentsDetails?> _showAssignDetails;
  bool _showNoInternetConnectionMessage = false;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  final _cacheManager = DefaultCacheManager();



  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // _showAssignDetails = AssignDetailsView();
    _showAssignDetails = _getCachedOrFetchData();

    _connectivitySubscription = Connectivity().onConnectivityChanged
        .listen((ConnectivityResult result) async {

      bool hasInternet = await _hasInternetConnection();
      if(result != ConnectivityResult.none && _showNoInternetConnectionMessage && hasInternet){
        _refreshData().then((_){
          setState(() {});
        });
      }
      setState(() {
        _showNoInternetConnectionMessage = (result == ConnectivityResult.none || !hasInternet);
      });
    });
  }

  Future<bool>_hasInternetConnection() async{
    try{
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  @override
  void dispose(){
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
    if(state == AppLifecycleState.resumed){
      // _refreshData().then((_){
      //   setState(() {});
      // });
      _refreshData();

    }
    super.didChangeAppLifecycleState(state);
  }


  Future<AssignmentsDetails?> _getCachedOrFetchData() async {
    final cacheKey = 'assignment_${widget.slug}';
    FileInfo? cachedFile = await _cacheManager.getFileFromCache(cacheKey);

    if (cachedFile != null) {
      // Load from cache
      final cachedData = await cachedFile.file.readAsString();
      return assignmentsDetailsFromJson(cachedData);
    } else {
      // Fetch from API
      return AssignDetailsView(cacheKey);
    }
  }

  Future<AssignmentsDetails?> AssignDetailsView(String cacheKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';
    final String apiUrl = '${AppUrl.baseUrl}/api/app/assignment/details/${widget.slug}';
    print(widget.slug);
    final response = await https.get(Uri.parse(apiUrl), headers: {
      'Authorization': 'Bearer $_token',
    });

    if (response.statusCode == 200) {
       await _cacheManager.putFile(
        cacheKey,
        response.bodyBytes,
        fileExtension: 'json',
      );
      return assignmentsDetailsFromJson(response.body);
    } else {
      throw Exception('Failed to load assignment details');
    }
  }

  Future<void> _refreshData( ) async {
    var freshData = await AssignDetailsView('assignment_${widget.slug}');
    setState(() {
      _showAssignDetails = Future.value(freshData);
    });

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
              Text("Assignment Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>StaffCurveNabBar()));
                },
                child: HeaderRow(Icons.home),
              ),
            ],
          ),
        ),
        body: _showNoInternetConnectionMessage ? NoInternetConnection() : RefreshIndicator(
          onRefresh:()=>_refreshData(),
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
      child: Center(
        child: FutureBuilder<AssignmentsDetails?>(
          future: _showAssignDetails,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: screenHeight * 0.9,
                width: screenWidth,
                color: AppColors.whiteColor,
                child: LoadingScreen(),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text(""));
              // return Text("Error: ${snapshot.error}");
            } else if (snapshot.hasData && snapshot.data != null) {
              var assignmentDetails = snapshot.data?.data;
              var offDays = assignmentDetails?.offDays ?? [];
              var categories = snapshot.data?.category ?? [];
              var clientAddress = assignmentDetails?.clients?.addressLine1 ??"";
              var clientPhone = assignmentDetails?.clients?.phone ??"";
              var clientReg = assignmentDetails?.clients?.regNumber ??"";
              var clientCity = assignmentDetails?.clients?.city ??"";
              var clientPostCode = assignmentDetails?.clients?.postCode ??"";

              String? getCategoryDaysName(dynamic offdaysName) {
                String offDaysStr = offdaysName.toString();

                for (var category in categories) {
                  String categoryIdStr = category.id.toString();
                  if (categoryIdStr == offDaysStr) {
                    return category.daysName;
                  }
                }
                return null;
              }
              // Get current date
              DateTime currentDate = DateTime.now();
              bool isPastEndDate = assignmentDetails?.assignEndDate != null && currentDate.isAfter(assignmentDetails!.assignEndDate!);
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [

                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: screenHeight * 0.07,
                                  width: screenWidth * 0.15,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: widget.images != null && widget.images!.isNotEmpty
                                          ? NetworkImage("${AppUrl.clientUsers}/${widget.images}") as ImageProvider
                                          : AssetImage('images/company-image.png'),
                                      fit: BoxFit.cover,
                                    ),
                                    color: AppColors.navOpacity,
                                    shape: BoxShape.circle,
                                  ),
                                ),

                                SizedBox(width: screenWidth*0.02,),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(getDisplayedCompanyName(widget.companyName, context), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)
                                    ),
                                    Container(
                                      width:screenWidth*0.45,child: AutoSizeText("${widget.email} ",style: TextStyle(fontSize: 12),)),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Container(
                                  width: screenWidth * 0.3,
                                  height: screenHeight * 0.04,
                                  decoration: BoxDecoration(
                                    color: AppColors.navOpacity,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Center(
                                    child: Text("${assignmentDetails?.dataAssignmentNumber??""}",
                                      style: TextStyle(fontSize: 12),),
                                  ),
                                ),
                                Container(
                                    height: screenHeight*0.04,
                                    width: screenWidth*0.3,
                                    child: Center(child: Text("${assignmentDetails?.status??""}",style: TextStyle(color: assignmentDetails?.status == 'inactive' ? Colors.red : Colors.green,
                                    ),))),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.013,),

                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.navOpacity.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [

                              Row(
                                children: [
                                  Align(
                                      alignment:Alignment.centerLeft,
                                      child: Text("Phone: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
                                  Text("$clientPhone", style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              SizedBox(height: screenHeight*0.008),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Address: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                  Expanded(
                                    child: Container(
                                        child: Text("$clientAddress, $clientCity, $clientPostCode", style: TextStyle(fontSize: 16))),
                                  ),
                                ],
                              ),
                              // SizedBox(height: screenHeight*0.008),
                              // Row(
                              //   children: [
                              //     Align(
                              //         alignment:Alignment.centerLeft,
                              //         child: Text("Registration Number: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
                              //     Text("$clientReg", style: TextStyle(fontSize: 16)),
                              //   ],
                              // ),
                              // SizedBox(height: screenHeight*0.008),
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //   children: [
                              //     Text("Day Start Time", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              //     Row(
                              //       children: [
                              //         Icon(Icons.access_time, size: 18, color: Colors.grey),
                              //         SizedBox(width: screenWidth*0.02,),
                              //         Text("${assignmentDetails?.startTime??""}", style: TextStyle(fontSize: 16)),
                              //       ],
                              //     ),
                              //   ],
                              // ),
                              // Divider(thickness: 1, color: Colors.grey.shade300),
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //   children: [
                              //     Text("Day End Time", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              //     Row(
                              //       children: [
                              //         Icon(Icons.access_time, size: 18, color: Colors.grey),
                              //         SizedBox(width: screenWidth*0.02,),
                              //         Text("${assignmentDetails?.endTime??""}", style: TextStyle(fontSize: 16)),
                              //       ],
                              //     ),
                              //   ],
                              // ),
                              // Divider(thickness: 1, color: Colors.grey.shade300),
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //   children: [
                              //     Text("End Date", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              //     Text(assignmentDetails?.assignEndDate != null ? DateFormat('dd-MM-yyyy').format(assignmentDetails!.assignEndDate!) : "",
                              //       style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isPastEndDate ? Colors.red : Colors.green,
                              //       ),),
                              //
                              //   ],
                              // ),
                            ],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.013,),
                        Container(
                          height: screenHeight*0.05,
                          width: screenWidth *0.7,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color:AppColors.navButtonColor,
                          ),
                          child: Center(
                            child: Text("Rate Details",
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
                    SizedBox(height: screenHeight * 0.013,),
                    Container(
                      width: screenWidth,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200.withOpacity(0.4),
                            blurRadius: 10,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Column(
                        children: offDays.map((offDay) {
                          String? categoryDaysName = getCategoryDaysName(offDay.daysName);
                          return Padding(
                            padding:  EdgeInsets.symmetric(vertical: screenWidth*0.01,),
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade200,
                                    blurRadius: 6,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today, size: 18, color: Colors.blue.shade300),
                                          SizedBox(width: screenWidth*0.02,),
                                          Text(
                                            "Date: ${offDay.date != null ? DateFormat('dd-MM-yyyy').format(DateTime.parse(offDay.date!)) : ""}",
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),

                                      Row(
                                        children: [
                                          Text("Amount: ", style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                                          Text(" £ ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                          Text("${offDay.payHourSalary ?? ""}", style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: screenHeight*0.005,),
                                  Text("Days Name: ${categoryDaysName ?? ""}",
                                      style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  ],
                ),
              );
            } else {
              return Text("No assignment details found.");
            }
          },
        ),
      ),
    );
  }

  String getDisplayedCompanyName(String? companyName, BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double mobileThreshold = 600; if (companyName == null || companyName.isEmpty) {
      return 'Unknown Company';
    }
    if (screenWidth < mobileThreshold) {
      return companyName.length > 17 ? '${companyName.substring(0, 17)}...' : companyName;
    } else {
      return companyName;
    }
  }

}
