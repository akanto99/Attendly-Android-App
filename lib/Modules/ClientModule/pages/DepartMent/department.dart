import 'dart:async';
import 'package:c9_app/DarkAndLightTheme/theme_provider.dart';
import 'package:c9_app/Modules/ClientModule/client_screen.dart';
import 'package:c9_app/Modules/ClientModule/model/DepartmentModel/departmentindexModel.dart';
import 'package:c9_app/Modules/ClientModule/pages/DepartMent/addDepartment.dart';
import 'package:c9_app/loadingScreen.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/utils/utils.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as https;

class DepartMent extends StatefulWidget {
  const DepartMent({super.key});

  @override
  State<DepartMent> createState() => _DepartMentState();
}

class _DepartMentState extends State<DepartMent> {
  late Future<DepartmentIndexModel> _showListData;

  @override
  void initState() {
    super.initState();
    _showListData = fetchDepIndex();
    _refreshData();
  }


  Future<DepartmentIndexModel> fetchDepIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';

    final String apiUrl = '${AppUrl.baseUrl}/api/app/department/index';
    final response = await https.get(Uri.parse(apiUrl), headers: {
      'Authorization': 'Bearer $_token',
    });
    if (response.statusCode == 200) {
      return departmentIndexModelFromJson(response.body);
    } else {
      throw Exception('Failed to load day rate index');
    }
  }

  Future<void> deleteDeptIndex(String Slug) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';

    final String apiUrl = '${AppUrl.baseUrl}/api/app/department/delete/$Slug';
    final response = await https.get(Uri.parse(apiUrl), headers: {
      'Authorization': 'Bearer $_token',
    });

    if (response.statusCode == 200) {
      setState(() {
        _showListData = fetchDepIndex();
      });

      print('Staff $Slug deleted successfully');
    } else {
      throw Exception('Failed to delete Dept Index: $Slug');
    }
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
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            // ChangeThemeButtonWidget(),
            // SizedBox(height: screenHeight * 0.013,),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     GestureDetector(
            //       onTap: (){
            //         Navigator.push(context, MaterialPageRoute(builder: (context)=>ClientCurveNabBar()));
            //       },
            //         child: HeaderRow(Icons.arrow_back)),
            //     GestureDetector(
            //         onTap: (){
            //           Navigator.push(context, MaterialPageRoute(builder: (context)=>ClientCurveNabBar()));
            //         },
            //         child: HeaderRow(Icons.home)),
            //   ],
            // ),

            Center(
              child: FutureBuilder<DepartmentIndexModel>(
                future: _showListData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      height: screenHeight *0.72,
                      width: screenWidth,
                      color: AppColors.whiteColor,
                      child: Center(child: LoadingScreen()),
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
                    final deptIndex = snapshot.data?.data?.data;

                    if (deptIndex != null && deptIndex.isNotEmpty) {
                      return Column(
                        children: [
                          // SizedBox(height: screenHeight * 0.013,),
                          // Align(alignment: Alignment.centerLeft,
                          //     child: Text("Create New Department",
                          //       style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),)),
                          // SizedBox(height: screenHeight * 0.013,),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     InkWell(
                          //       onTap: (){
                          //         Navigator.push(context, MaterialPageRoute(builder: (context)=>ADDdepartent()));
                          //       },
                          //       child: Container(
                          //         height: screenHeight * 0.055,
                          //         width: screenWidth * 0.45,
                          //         decoration: BoxDecoration(
                          //             borderRadius: BorderRadius.circular(10),
                          //             border: Border.all(
                          //               width: 0.2,
                          //               color: AppColors.navButtonColor,
                          //               // Color(0xff078C79)
                          //             )
                          //         ),
                          //         child: Center(child: Text("Add Department", style: TextStyle(
                          //             fontSize: 20,
                          //             fontWeight: FontWeight.w500,
                          //             letterSpacing: 1),)),
                          //       ),
                          //     ),
                          //
                          //     InkWell(
                          //       onTap: (){
                          //         Navigator.push(context, MaterialPageRoute(builder: (context)=>DepartMent()));
                          //       },
                          //       child: Container(
                          //         height: screenHeight * 0.055,
                          //         width: screenWidth * 0.45,
                          //         decoration: BoxDecoration(
                          //             color: AppColors.navButtonColor,
                          //             // Color(0xff078C79).withOpacity(0.8),
                          //             borderRadius: BorderRadius.circular(10),
                          //             border: Border.all(
                          //               width: 0.2,
                          //               color:  AppColors.navButtonColor,
                          //             )
                          //         ),
                          //         child: Center(child: Text("Department List", style: TextStyle(
                          //             fontSize: 20,
                          //             fontWeight: FontWeight.bold,
                          //             color: AppColors.whiteColor,
                          //             letterSpacing: 1),)),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // SizedBox(height: screenHeight * 0.013,),


                          Container(
                            width: screenWidth * 0.95,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(5),
                                topRight: Radius.circular(5),
                              ),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: deptIndex.length,
                              itemBuilder: (context, index) {
                                String DepName = deptIndex[index].deptName ??"";
                                String location = deptIndex[index].location?? "";
                                String responsi = deptIndex[index].details?? "";
                                final slug = deptIndex[index].slug;

                                if (responsi.length > 5) {
                                  responsi = '${responsi.substring(0, 5)}...';
                                }

                                if (DepName.length > 15) {
                                  DepName = '${DepName.substring(0, 15)}...';
                                }

                                if (location.length > 18) {
                                  location = '${location.substring(0, 18)}';
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
                                                    Text("Department Name",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                                                    Text("$DepName",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w400),),
                                                  ],
                                                ),

                                                Row(
                                                  children: [
                                                    Icon(Icons.location_on),
                                                    SizedBox(width: screenWidth*0.013,),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text("Location",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                                                        Text("$location",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w400),),
                                                      ],
                                                    ),
                                                  ],
                                                ),

                                              ],
                                            ),
                                            SizedBox(height: screenHeight* 0.013,),

                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                GestureDetector(
                                                  onTapUp:(details){
                                                    String? responsi = deptIndex[index].details;
                                                    if (responsi != null) {
                                                      _showFullNamePopup(context, responsi, details.globalPosition);
                                                    }
                                                  },
                                                  child: Container(
                                                    height: screenHeight*0.07,
                                                    width: screenWidth*0.5,
                                                    child: Row(
                                                      children: [
                                                        Text("Responsibilities",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
                                                        SizedBox(width: screenWidth*0.02,),
                                                        Container(
                                                          height: screenHeight*0.035,
                                                          width: screenWidth*0.002,
                                                          color: Colors.grey,
                                                        ),
                                                        SizedBox(width: screenWidth*0.02,),
                                                        Text(_removeHtmlTags("$responsi"),style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: AppColors.blackOpacity),),
                                                      ],
                                                    ),
                                                  ),
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
                                                     GestureDetector(
                                                      onTap: ()async{
                                                       //  Utils.showDialogLoading(context);
                                                       // await deleteDeptIndex(slug!);
                                                       // Navigator.pop(context);
                                                        showConfirmationDialog(context, () async {
                                                          Utils.showDialogLoading(context);
                                                          await deleteDeptIndex(slug!);
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
                                                        child: Center(child: Text("Delete",style: TextStyle(color: Colors.white),)),
                                                      ),
                                                    )
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
                          ),
                          SizedBox(height: screenHeight * 0.1),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          // SizedBox(height: screenHeight * 0.013,),
                          // Align(alignment: Alignment.centerLeft,
                          //     child: Text("Create New Department",
                          //       style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),)),
                          // SizedBox(height: screenHeight * 0.013,),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     InkWell(
                          //       onTap: (){
                          //         Navigator.push(context, MaterialPageRoute(builder: (context)=>ADDdepartent()));
                          //       },
                          //       child: Container(
                          //         height: screenHeight * 0.055,
                          //         width: screenWidth * 0.45,
                          //         decoration: BoxDecoration(
                          //             borderRadius: BorderRadius.circular(10),
                          //             border: Border.all(
                          //               width: 0.2,
                          //               color: AppColors.navButtonColor,
                          //               // Color(0xff078C79)
                          //             )
                          //         ),
                          //         child: Center(child: Text("Add Department", style: TextStyle(
                          //             fontSize: 20,
                          //             fontWeight: FontWeight.w500,
                          //             letterSpacing: 1),)),
                          //       ),
                          //     ),
                          //
                          //     InkWell(
                          //       onTap: (){
                          //         Navigator.push(context, MaterialPageRoute(builder: (context)=>DepartMent()));
                          //       },
                          //       child: Container(
                          //         height: screenHeight * 0.055,
                          //         width: screenWidth * 0.45,
                          //         decoration: BoxDecoration(
                          //             color: AppColors.navButtonColor,
                          //             // Color(0xff078C79).withOpacity(0.8),
                          //             borderRadius: BorderRadius.circular(10),
                          //             border: Border.all(
                          //               width: 0.2,
                          //               color:  AppColors.navButtonColor,
                          //             )
                          //         ),
                          //         child: Center(child: Text("Department List", style: TextStyle(
                          //             fontSize: 20,
                          //             fontWeight: FontWeight.bold,
                          //             color: AppColors.whiteColor,
                          //             letterSpacing: 1),)),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // SizedBox(height: screenHeight * 0.013,),


                          Container(
                              height: screenHeight *0.7,
                              width: screenWidth,
                              color: AppColors.whiteColor,
                              child: Center(child: Text('Empty Department !!!'))),
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
                Text('Are you sure you want to delete this department?'),
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
            color: AppColors.greyOpacity,
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