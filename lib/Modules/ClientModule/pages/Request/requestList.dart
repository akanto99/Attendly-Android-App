import 'dart:async';
import 'package:c9_app/DarkAndLightTheme/theme_provider.dart';
import 'package:c9_app/Modules/ClientModule/client_screen.dart';
import 'package:c9_app/Modules/ClientModule/model/RequestIndexModel/requestIndexModel.dart';
import 'package:c9_app/Modules/ClientModule/pages/Request/Addrequest.dart';
import 'package:c9_app/loadingScreen.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as https;

class RequestStaff extends StatefulWidget {
  const RequestStaff({super.key});

  @override
  State<RequestStaff> createState() => _RequestStaffState();
}

class _RequestStaffState extends State<RequestStaff> {
  late Future<RequestIndexModel> _showListData;


  @override
  void initState() {
    super.initState();
    _showListData = fetchDepIndex();
  }


  Future<RequestIndexModel> fetchDepIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';
    final String apiUrl = '${AppUrl.baseUrl}/api/app/request/index';
    final response = await https.get(Uri.parse(apiUrl), headers: {
      'Authorization': 'Bearer $_token',
    });
    if (response.statusCode == 200) {
      return requestIndexModelFromJson(response.body);
    } else {
      throw Exception('Failed to load day rate index');
    }
  }

  Future<void> deleteDeptIndex(int id) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';

    final String apiUrl = '${AppUrl.baseUrl}/api/app/request/cancel/$id';
    final response = await https.get(Uri.parse(apiUrl), headers: {
      'Authorization': 'Bearer $_token',
    });

    if (response.statusCode == 200) {
      setState(() {
        _showListData = fetchDepIndex();
      });

      print('Staff $id deleted successfully');
    } else {
      throw Exception('Failed to delete Dept Index: $id');
    }
  }
  Future<void> showConfirmationDialog(BuildContext context, Function() onConfirmed) async {
    double screenWidth = MediaQuery.of(context).size.width * 1;
    return showDialog<void>(
      context: context,
      // barrierDismissible: false, // Dialog cannot be dismissed by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to cancel this request?'),
              ],
            ),
          ),
          actions: <Widget>[
            InkWell(
              onTap: ()async{
                Navigator.of(context).pop();
                onConfirmed();
              },
              child: Container(
                width: screenWidth*0.2,
                color:  AppColors.navButtonColor,
                child: Center(
                  child: Text(
                    'Yes',
                    style:TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing:1,

                    ),
                  ),
                ),
              ),
            ),

            InkWell(
              onTap: (){
                Navigator.of(context).pop();
              },
              child: Container(
                width: screenWidth*0.2,
                color:  AppColors.navOpacity,
                child: Center(
                  child: Text(
                    'No',
                    style:TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing:1,

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
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
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

  Future<void> _refreshData() async {
    setState(() {
      _showListData = fetchDepIndex();
      print("Pull");
    });
  }


  Widget body() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            // SizedBox(height: screenHeight * 0.013),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     GestureDetector(
            //         onTap: (){
            //           Navigator.push(context, MaterialPageRoute(builder: (context)=>ClientCurveNabBar()));
            //         },
            //         child: HeaderRow(Icons.arrow_back)),
            //     GestureDetector(
            //         onTap: (){
            //           Navigator.push(context, MaterialPageRoute(builder: (context)=>ClientCurveNabBar()));
            //         },
            //         child: HeaderRow(Icons.home)),
            //   ],
            // ),
      
      
            Center(
              child: FutureBuilder<RequestIndexModel>(
                future: _showListData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      height: screenHeight *0.72,
                      width: screenWidth,
                      color: AppColors.whiteColor,
                      child: LoadingScreen(),
                    );
                  } else if (snapshot.hasError) {
                    return SingleChildScrollView(
                      child: Container(
                        height: screenHeight*0.6,
                        width: screenWidth,
                        color: AppColors.whiteColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 200,
                              width: 200,
                              child: Lottie.asset('images/internet.json'),
                            ),
                            GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>ClientCurveNabBar()));
                              } ,
                              child: Container(
                                height: 40,
                                width: 180,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(width: 2,color: Color(0xff2A63A5)),
                                  color: Colors.white60,
                                ),
                                child: Center(
                                  child: Text('Try again'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    final reqIndex = snapshot.data?.data?.data;
      
                    if (reqIndex != null && reqIndex.isNotEmpty) {
                      return Column(
                        children: [
                          // SizedBox(height: screenHeight * 0.013),
                          // Align(
                          //   alignment: Alignment.centerLeft,
                          //   child: Text(
                          //     "Create New Request",
                          //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                          //   ),
                          // ),
                          // SizedBox(height: screenHeight * 0.013),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     InkWell(
                          //       onTap: () {
                          //         Navigator.push(
                          //           context,
                          //           MaterialPageRoute(builder: (context) => AddRequest()),
                          //         );
                          //       },
                          //       child: Container(
                          //         height: screenHeight * 0.055,
                          //         width: screenWidth * 0.45,
                          //         decoration: BoxDecoration(
                          //           borderRadius: BorderRadius.circular(10),
                          //           border: Border.all(width: 0.2, color: AppColors.navButtonColor,),
                          //         ),
                          //         child: Center(
                          //           child: Text(
                          //             "Add Request",
                          //             style: TextStyle(
                          //               fontSize: 20,
                          //               fontWeight: FontWeight.w500,
                          //               letterSpacing: 1,
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //     InkWell(
                          //       onTap: () {
                          //         Navigator.push(
                          //           context,
                          //           MaterialPageRoute(builder: (context) => RequestStaff()),
                          //         );
                          //       },
                          //       child: Container(
                          //         height: screenHeight * 0.055,
                          //         width: screenWidth * 0.45,
                          //         decoration: BoxDecoration(
                          //           color: AppColors.navButtonColor,
                          //
                          //           borderRadius: BorderRadius.circular(10),
                          //           border: Border.all(width: 0.2,
                          //             color: AppColors.navButtonColor,
                          //           ),
                          //         ),
                          //         child: Center(
                          //           child: Text(
                          //             "Request List",
                          //             style: TextStyle(
                          //               fontSize: 20,
                          //               fontWeight: FontWeight.bold,
                          //               color:AppColors.whiteColor,
                          //               letterSpacing: 1,
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // SizedBox(height: screenHeight * 0.013),
                          Container(
                            width: screenWidth * 0.95,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Column(
                              children: [
      
      
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: reqIndex.length,
                                  itemBuilder: (context, index) {
                                    final number = reqIndex[index].numberOfStaff ?? "";
                                    String type = reqIndex[index].typesOfStaff ?? "";
                                    final status = reqIndex[index].status ?? "";
                                    int id = reqIndex[index].id;
                                    Widget statusWidget;
      
                                    if (type.length > 15) {
                                      type = '${type.substring(0, 15)}...';
                                    }
      
      
                                    if (status == "Cancel") {
                                      statusWidget = Text("Cancelled",style: TextStyle(color:Colors.red),);
                                    } else if (status == "Pending") {
                                      statusWidget = GestureDetector(
                                        onTap: ()async{
                                         //  Utils.showDialogLoading(context);
                                         // await deleteDeptIndex(id);
                                         //  Navigator.pop(context);
                                          showConfirmationDialog(context, () async {
                                            Utils.showDialogLoading(context);
                                            await deleteDeptIndex(id);
                                            Navigator.pop(context);
                                          });
                                        },
                                        child: Container(
                                          height: screenHeight*0.04,
                                          width: screenWidth*0.2,
                                          decoration: BoxDecoration(
                                              color: AppColors.navButtonColor,
                                              borderRadius: BorderRadius.circular(5)
                                          ),
                                          child: Center(child:Text("Cancel",style: TextStyle(color: Colors.white),)),
                                        ),
                                      );
                                    } else if (status == "Approve") {
                                      statusWidget = Text("Approved",style: TextStyle(color:Colors.green));
                                    } else {
                                      statusWidget = Text("Unknown Status");
                                    }
                                    return Column(
                                      children: [
                                        SizedBox(height: screenHeight * 0.013,),
                                        Container(
                                          width: screenWidth * 0.95,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color: Color(0xffFAFAFA),
                                          ),
      
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text("Type of Staff",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                                                        GestureDetector(
                                                            onTapUp:(details){
                                                              String? responsi = reqIndex[index].typesOfStaff;
                                                              if (responsi != null) {
                                                                _showFullNamePopup(context, responsi, details.globalPosition);
                                                              }
                                                            },
                                                            child: Text("$type",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w400),)),
                                                      ],
                                                    ),
      
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text("Number of Staff",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                                                        Text("$number",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w400),),
                                                      ],
                                                    ),
      
                                                  ],
                                                ),
                                                SizedBox(height: screenHeight* 0.013,),
      
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text("Status",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
                                                      SizedBox(width: screenWidth*0.02,),
                                                      Container(
                                                        height: screenHeight*0.035,
                                                        width: screenWidth*0.002,
                                                        color: Colors.grey,
                                                      ),
                                                      SizedBox(width: screenWidth*0.02,),
                                                      Text("$status",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: AppColors.blackOpacity),),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text("Action",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
                                                      SizedBox(width: screenWidth*0.02,),
                                                      Container(
                                                        height: screenHeight*0.035,
                                                        width: screenWidth*0.002,
                                                        color: Colors.grey,
                                                      ),
                                                      SizedBox(width: screenWidth*0.02,),
                                                     statusWidget,
                                                    ],
                                                  ),
                                                ],
                                              )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.2),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          // SizedBox(height: screenHeight * 0.013),
                          // Align(
                          //   alignment: Alignment.centerLeft,
                          //   child: Text(
                          //     "Create New Request",
                          //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                          //   ),
                          // ),
                          // SizedBox(height: screenHeight * 0.013),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     InkWell(
                          //       onTap: () {
                          //         Navigator.push(
                          //           context,
                          //           MaterialPageRoute(builder: (context) => AddRequest()),
                          //         );
                          //       },
                          //       child: Container(
                          //         height: screenHeight * 0.055,
                          //         width: screenWidth * 0.45,
                          //         decoration: BoxDecoration(
                          //           borderRadius: BorderRadius.circular(10),
                          //           border: Border.all(width: 0.2, color: AppColors.navButtonColor,),
                          //         ),
                          //         child: Center(
                          //           child: Text(
                          //             "Add Request",
                          //             style: TextStyle(
                          //               fontSize: 20,
                          //               fontWeight: FontWeight.w500,
                          //               letterSpacing: 1,
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //     InkWell(
                          //       onTap: () {
                          //         Navigator.push(
                          //           context,
                          //           MaterialPageRoute(builder: (context) => RequestStaff()),
                          //         );
                          //       },
                          //       child: Container(
                          //         height: screenHeight * 0.055,
                          //         width: screenWidth * 0.45,
                          //         decoration: BoxDecoration(
                          //           color: AppColors.navButtonColor,
                          //
                          //           borderRadius: BorderRadius.circular(10),
                          //           border: Border.all(width: 0.2,
                          //             color: AppColors.navButtonColor,
                          //           ),
                          //         ),
                          //         child: Center(
                          //           child: Text(
                          //             "Request List",
                          //             style: TextStyle(
                          //               fontSize: 20,
                          //               fontWeight: FontWeight.bold,
                          //               color:AppColors.whiteColor,
                          //               letterSpacing: 1,
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // SizedBox(height: screenHeight * 0.013),
                          Container(
                              height: screenHeight*0.7,
                              width: screenWidth,
                              color: AppColors.whiteColor,
                              child: Center(child: Text('Empty Request !!!'))),
                        ],
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _removeHtmlTags(String htmlString) {
    final document = parse(htmlString);
    return parse(document.body!.text).documentElement!.text;
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
      child: Icon(iconData,color:  AppColors.navColor,),
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
            // width: ,
            // height: 40,
            alignment: Alignment.center,
            child: Text(
              _removeHtmlTags( fullName),
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
