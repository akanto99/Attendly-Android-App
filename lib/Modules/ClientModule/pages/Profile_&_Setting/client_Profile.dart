import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:c9_app/Modules/ClientModule/model/ProfileModel/clientProfileApiModel.dart';
import 'package:c9_app/Modules/ClientModule/pages/FullImageView.dart';
import 'package:c9_app/Modules/ClientModule/pages/Profile_&_Setting/UpdateProfileClient.dart';
import 'package:c9_app/Modules/ClientModule/pages/noInternetConnectionWidget.dart';
import 'package:c9_app/loadingScreen.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/utils/routes/routes_name.dart';
import 'package:c9_app/view/widgets/error_logout.dart';
import 'package:c9_app/view_model/services/rolebasedmodel/user_view_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as https;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../client_screen.dart';

class ClientProfile extends StatefulWidget {
  const ClientProfile({super.key});

  @override
  State<ClientProfile> createState() => _ClientProfileState();
}

class _ClientProfileState extends State<ClientProfile> with WidgetsBindingObserver {
  late Future<ClientProfileApiModel?> _userProfileFuture;

  bool _showNoInternetConnectionMessage = false;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _userProfileFuture = fetchData();

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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription.cancel(); // Cancel subscription
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _refreshData();
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> _refreshData() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    bool hasInternet = await _hasInternetConnection();

    if (connectivityResult == ConnectivityResult.none || !hasInternet) {
      setState(() {
        _showNoInternetConnectionMessage = true;
      });
    } else {
      setState(() {
        _userProfileFuture = fetchData();
        print("Pull");
      });
    }
  }

  Future<ClientProfileApiModel?> fetchData() async {
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

      final String apiUrl = '${AppUrl.baseUrl}/api/app/profile';
      // final String apiUrl = '${AppUrl.baseUrl}/api/app/staff/profile';
      final response = await https.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData == null) {
          throw Exception('Response data is null');
        }

        return ClientProfileApiModel.fromJson(responseData);
      } else {
        throw Exception('Failed to fetch user data. Status code: ${response.statusCode}');
      }
    }
  }

  bool showText = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: _showNoInternetConnectionMessage ? Colors.red : AppColors.navColor,
    ));
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ClientCurveNabBar()),
          );
          return false;
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
    );
  }

  Widget body() {
    final userPrefernece = Provider.of<UserViewModel>(context);
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return SingleChildScrollView(
      child: FutureBuilder<ClientProfileApiModel?>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: screenHeight,
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
                  screenHeight: screenHeight * 0.8,
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
            // return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No user data found.'));
          } else {
            final ClientProfileApiModel profileData = snapshot.data!;
            final Data? profile = profileData.data;
            final String? profilePick = profileData.data?.image;
            final contacts = profile?.xeroContacts ?? [];

            String address1 = profileData.data?.addressLine1 ?? "no info";
            String address2 = profileData.data?.addressLine2 ?? "no info";

            if (address1.length > 25) {
              address1 = '${address1.substring(0, 25)}...';
            }

            if (address2.length > 25) {
              address2 = '${address2.substring(0, 25)}...';
            }

            return Column(
              children: [
                Container(
                  // height: 280,
                  width: screenWidth,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.center,
                      end: Alignment(1.76, -0.23),
                      colors: [
                        // const Color(0x44232f47),
                        // const Color(0x44232f47),
                        AppColors.navOpacity,
                        AppColors.navOpacity,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        offset: Offset(0, 2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ClientCurveNabBar()));
                                },
                                child: Icon(
                                  Icons.arrow_back,
                                  size: 28,
                                  color: AppColors.navColor,
                                )),
                            Text(
                              "Profile",
                              style: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context, MaterialPageRoute(builder: (context) => UpdateProfileClient()));
                                },
                                child: Icon(
                                  Icons.edit,
                                  size: 28,
                                  color: AppColors.navColor,
                                )),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (profilePick != null && profilePick.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenImage(
                                  imageUrl: '${AppUrl.clientUsers}/$profilePick',
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          height: screenHeight * 0.12,
                          width: screenWidth * 0.26,
                          decoration: BoxDecoration(
                            color: profilePick != null && profilePick.isNotEmpty ? Colors.white : Colors.white,
                            shape: BoxShape.circle,
                            image: profilePick != null && profilePick.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage('${AppUrl.clientUsers}/$profilePick'),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: profilePick == null || profilePick.isEmpty
                              ? Icon(Icons.person,
                                  color: Colors.red, size: screenHeight * 0.06) // optional icon for better UX
                              : null,
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.004,
                      ),
                      Text(
                        "${profile?.name ?? "no info"} ",
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: AppColors.navButtonColor),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "${profile?.email}",
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1),
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.013,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Personal Information",
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.023,
                ),
                HeaderContainer("Email", "${profile?.email ?? "no info"}"),
                SizedBox(height: 5),
                MiddleContainer("Phone", "${profile?.phone ?? "no info"}"),
                SizedBox(height: 5),
                MiddleContainer("Town/City", "${profile?.city ?? "no info"}"),
                SizedBox(height: 5),
                MiddleContainer("Post Code", "${profile?.postCode ?? "no info"}"),
                SizedBox(height: 5),
                GestureDetector(
                  onTapUp: (details) {
                    String address1 = profileData.data?.addressLine1 ?? "Address Line 1 empty!";
                    if (address1 != null) {
                      _showFullNamePopup(context, address1, details.globalPosition);
                    }
                  },
                  child: MiddleContainer(
                    "Address 1",
                    "$address1",
                  ),
                ),
                SizedBox(height: 5),
                GestureDetector(
                  onTapUp: (details) {
                    String address2 = profileData.data?.addressLine2 ?? "Address Line 2 empty!";
                    if (address2 != null) {
                      _showFullNamePopup(context, address2, details.globalPosition);
                    }
                  },
                  child: LastContainer("Address 2", "$address2"),
                ),
                SizedBox(height: 5),
                MiddleContainer(
                  "Account Owner",
                  "${profile?.consultant ?? "N/A"}",
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text("Business Information",
                        style: GoogleFonts.roboto(
                          textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                        )),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                HeaderContainer("Business Name", "${profile?.companyName ?? "No info"}"),
                SizedBox(height: 5),
                MiddleContainer(
                  "Break Deduction",
                  "${((double.tryParse(profile?.breakTime ?? "0.0") ?? 0.0) * 60).toInt()} minutes",
                ),
                SizedBox(height: 5),
                MiddleContainer(
                  "Day Start Time",
                  "${profile?.dayStartTime ?? "No info"}",
                ),
                SizedBox(height: 5),
                LastContainer(
                  "Day End Time",
                  "${profile?.dayEndTime ?? "No info"}",
                ),
                if (contacts.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text("Billing Contacts",
                          style: GoogleFonts.roboto(
                            textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                          )),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  ...contacts.map((contact) {
                    return Column(
                      children: [
                        SizedBox(
                          height: 5,
                        ),
                        ContactContainer("Name", contact.name ?? "No info", "Email", contact.emailAddress ?? "No info"),
                      ],
                    );
                  }).toList(),
                ],
                // if (contacts.isNotEmpty) ...[
                //   Padding(
                //     padding:
                //         const EdgeInsets.only(left: 20, right: 20, top: 20),
                //     child: Align(
                //       alignment: Alignment.topLeft,
                //       child: Text("Contact Information 2",
                //           style: GoogleFonts.roboto(
                //             textStyle: TextStyle(
                //                 fontSize: 18, fontWeight: FontWeight.w600),
                //           )),
                //     ),
                //   ),
                //   SizedBox(
                //     height: 15,
                //   ),
                //   Column(
                //     children: contacts.map((contact) {
                //       return Column(
                //         children: [
                //           SizedBox(height: 5),
                //           ContactContainer2("Name", contact.name ?? "No info",
                //               "Email", contact.emailAddress ?? "No info"),
                //         ],
                //       );
                //     }).toList(),
                //   )
                // ],
                SizedBox(height: 20),
                Container(
                  height: screenHeight * 0.05,
                  width: screenWidth * 0.4,
                  decoration: BoxDecoration(
                      color: AppColors.navButtonColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          offset: Offset(0, 2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ]),
                  child: ElevatedButton(
                    onPressed: () {
                      userPrefernece.remove().then((value) {
                        Navigator.pushNamed(context, RoutesName.login);
                      });
                    },
                    child: AutoSizeText(
                      'Logout',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navColor,
                      foregroundColor: Colors.white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.2),
              ],
            );
          }
        },
      ),
    );
  }

  Widget HeaderRow(IconData iconData) {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return Container(
      height: screenHeight * 0.055,
      width: screenWidth * 0.12,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            offset: Offset(0, 2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        iconData,
        color: AppColors.navButtonColor,
      ),
    );
  }

  void _showFullNamePopup(BuildContext context, String fullName, Offset position) {
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
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
              fullName,
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget HeaderContainer(
    String title,
    String TitleData,
  ) {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return Container(
      height: screenHeight * 0.06,
      width: screenWidth * 0.95,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            offset: Offset(0, -2),
            blurRadius: 5,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            offset: Offset(-2, 0),
            blurRadius: 5,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            offset: Offset(2, 0),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // Icon(Icons.account_box),
                // SizedBox(
                //   width: 5,
                // ),
                Text(
                  title,
                  style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                        fontSize: 15,
                      ),
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
            Text(
              TitleData,
              style: GoogleFonts.roboto(
                  textStyle: TextStyle(fontSize: 14, color: AppColors.blackOpacity.withOpacity(0.5)),
                  fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }

  MiddleContainer(
    String title,
    String TitleData,
    // final IconData icon
  ) {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return Container(
      height: screenHeight * 0.06,
      width: screenWidth * 0.95,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            offset: Offset(-2, 0),
            blurRadius: 5,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            offset: Offset(2, 0),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // Icon(Icons.date_range_sharp),
                // SizedBox(
                //   width: 5,
                // ),
                Text(
                  title,
                  style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                        fontSize: 15,
                      ),
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
            Text(
              TitleData,
              style: GoogleFonts.roboto(
                  textStyle: TextStyle(fontSize: 14, color: AppColors.blackOpacity.withOpacity(0.5)),
                  fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }

  Widget LastContainer(
    String title,
    String TitleData,
    // final IconData icon
  ) {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return Container(
      height: screenHeight * 0.06,
      width: screenWidth * 0.95,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            offset: Offset(2, 0),
            blurRadius: 5,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            offset: Offset(-2, 0),
            blurRadius: 5,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            offset: Offset(2, 0),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // Icon(icon),
                // SizedBox(
                //   width: 5,
                // ),
                Text(
                  title,
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
            Text(
              TitleData,
              style: GoogleFonts.roboto(
                  textStyle: TextStyle(fontSize: 14, color: AppColors.blackOpacity.withOpacity(0.5)),
                  fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }

  Widget ContactContainer(
    String title1,
    String TitleData1,
    String title2,
    String TitleData2,
  ) {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return Container(
      // height: screenHeight * 0.06,
      width: screenWidth * 0.95,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            offset: Offset(0, 2),
            blurRadius: 5,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      title1,
                      style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                            fontSize: 15,
                          ),
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                Text(
                  TitleData1,
                  style: GoogleFonts.roboto(
                      textStyle: TextStyle(fontSize: 14, color: AppColors.blackOpacity.withOpacity(0.5)),
                      fontWeight: FontWeight.w500),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      title2,
                      style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                            fontSize: 15,
                          ),
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                Text(
                  TitleData2,
                  style: GoogleFonts.roboto(
                      textStyle: TextStyle(fontSize: 14, color: AppColors.blackOpacity.withOpacity(0.5)),
                      fontWeight: FontWeight.w500),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget ContactContainer2(
    String title1,
    String TitleData1,
    String title2,
    String TitleData2,
  ) {
    final screenWidth = MediaQuery.of(context).size.width * 1;
    final screenHeight = MediaQuery.of(context).size.height * 1;
    return Container(
      width: screenWidth * 0.9,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        border: Border.all(
          color: Colors.grey.withOpacity(0.4),
          width: 0.4,
        ),
        borderRadius: BorderRadius.circular(2.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      title1,
                      style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                            fontSize: 15,
                          ),
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                Text(
                  TitleData1,
                  style: GoogleFonts.roboto(
                      textStyle: TextStyle(fontSize: 14, color: AppColors.blackOpacity.withOpacity(0.5)),
                      fontWeight: FontWeight.w500),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      title2,
                      style: GoogleFonts.roboto(
                          textStyle: TextStyle(
                            fontSize: 15,
                          ),
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                Text(
                  TitleData2,
                  style: GoogleFonts.roboto(
                      textStyle: TextStyle(fontSize: 14, color: AppColors.blackOpacity.withOpacity(0.5)),
                      fontWeight: FontWeight.w500),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
