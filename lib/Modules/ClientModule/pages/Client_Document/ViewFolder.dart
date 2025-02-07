import 'dart:async';
import 'dart:io';
import 'package:c9_app/Modules/ClientModule/client_screen.dart';
import 'package:c9_app/Modules/ClientModule/pages/Client_Document/documentFolder.dart';
import 'package:c9_app/Modules/ClientModule/pages/Client_Document/imgaeFolder.dart';
import 'package:c9_app/Modules/ClientModule/pages/Profile_&_Setting/client_Profile.dart';
import 'package:c9_app/Modules/ClientModule/pages/noInternetConnectionWidget.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:c9_app/view/widgets/header_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

class UploadFileClientfNew extends StatefulWidget {
  final String slug;
  const UploadFileClientfNew({super.key, required this.slug});

  @override
  State<UploadFileClientfNew> createState() => _UploadFileClientfNewState();
}

class _UploadFileClientfNewState extends State<UploadFileClientfNew> {

  bool _showNoInternetConnectionMessage = false;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;


  @override
  void initState() {
    super.initState();
    _requestPermissions();

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result)async{
      bool hasInternet = await _hasInternetConnection();
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
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    PermissionStatus status = await Permission.storage.request();
    if (!status.isGranted) {
      throw Exception('Permission denied for storage');
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
        body: _showNoInternetConnectionMessage?NoInternetConnection() : ResPonsiveUi(
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

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: screenHeight * 0.013,),
          Padding(
            padding: const EdgeInsets.only(left: 15,right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>ClientCurveNabBar()));
                      // Navigator.pop(context);
                    },
                    child: HeaderRow(Icons.arrow_back)),
                Text("Files",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>ClientCurveNabBar()));
                    },
                    child: HeaderRow(Icons.home)),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.013,),
          Column(
            children: [
              Container(
                width: screenWidth*0.95,
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
                    ]
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10,bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          "Documents",style: GoogleFonts.roboto(
                          textStyle: TextStyle(fontSize: 18),
                          fontWeight: FontWeight.bold,
                        ),),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 10.0,bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap:(){
                                final selectedSlug=widget.slug;
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>ClientImageFolder(slug:selectedSlug)));
                              },
                              child: Container(
                                height: screenHeight * 0.07,
                                width: screenWidth * 0.40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 2,
                                      blurRadius: 3,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(child: Text("Images",style: TextStyle(
                                    fontSize: 16,fontWeight: FontWeight.w400
                                ),)),
                              ),
                            ),
                            GestureDetector(
                              onTap:(){
                                final selectedSlug=widget.slug;
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>ClientDocFolder(slug:selectedSlug)));
                              },
                              child: Container(
                                height: screenHeight * 0.07,
                                width: screenWidth * 0.40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 2,
                                      blurRadius: 3,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(child: Text("Doc files",style: TextStyle(
                                    fontSize: 16,fontWeight: FontWeight.w400
                                ),)),
                              ),
                            ),

                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),

            ],
          ),
        ],),
    );
  }
}
