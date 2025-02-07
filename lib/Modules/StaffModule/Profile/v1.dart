import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:c9_app/Modules/ClientModule/pages/noInternetConnectionWidget.dart';
import 'package:c9_app/Modules/StaffModule/DashBoard/staff_navigationScreen.dart';
import 'package:c9_app/Modules/StaffModule/Profile/fileUpload_new.dart';
import 'package:c9_app/Modules/StaffModule/Profile/updateProfile.dart';
import 'package:c9_app/Modules/StaffModule/Profile/updateProfileV2.dart';
import 'package:c9_app/Modules/StaffModule/Profile/update_profile/personalInformation_update.dart';
import 'package:c9_app/loadingScreen.dart';
import 'package:c9_app/model/profileModel/profileapi_model.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/utils/routes/routes_name.dart';
import 'package:c9_app/view/widgets/error_logout.dart';
import 'package:c9_app/view/widgets/header_widgets.dart';
import 'package:c9_app/view_model/services/rolebasedmodel/user_view_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as https;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/utils.dart';
import '../fullViewImageStaff.dart';

class V1 extends StatefulWidget {
  const V1({super.key});

  @override
  State<V1> createState() => _V1State();
}

class _V1State extends State<V1> with WidgetsBindingObserver {
  late Future<ProfileApiModel?> _userProfileFuture;

  bool _showNoInternetConnectionMessage = false;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  String? _selectStaffRole;

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
        print("Pull profile");
      });
    }
  }

  Future<ProfileApiModel?> fetchData() async {
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
        return ProfileApiModel.fromJson(responseData);
      } else {
        throw Exception('Failed to fetch user data. Status code: ${response.statusCode}');
      }
    }
  }

  bool showText = false;
  UniqueKey item1Key = UniqueKey();
  UniqueKey item2Key = UniqueKey();
  UniqueKey item3Key = UniqueKey();
  UniqueKey item4Key = UniqueKey();
  UniqueKey item5Key = UniqueKey();
  bool _isExpanded = false;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: _showNoInternetConnectionMessage ? Colors.red : AppColors.navColor,
    ));

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StaffCurveNabBar()),
        );
        // Prevent default back navigation
        return false;
      },
      child: SafeArea(
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
      child: FutureBuilder<ProfileApiModel?>(
        future: _userProfileFuture,
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
            // return Text("${snapshot.error}");
            // return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No user data found.'));
          } else {
            final ProfileApiModel profileData = snapshot.data!;
            final Data profile = profileData.data;
            final String? profilePick = profileData.data.image;

            String address = profileData.data.addressLine2 ?? "no info";
            String addressF = profileData.data.addressLine1 ?? "no info";
            String townCity = profileData.data.city ?? "no info";

            String licenceNumber = profileData.data.licenceNumber ?? "no info";
            String licenceExpiry = profileData.data.licenceExpiry?.toString() ?? "no info";

            String licenceEndorsements = profileData.data.licenceEndorsement ?? "no info";
            String CpcNumber = profileData.data.cpcNumber ?? "no info";
            String CpcExpiry = profileData.data.cpcExpiry?.toString() ?? "no info";
            String TachoCard = profileData.data.tachoNumber ?? "no info";
            String TachoExpiry = profileData.data.tachoExpiry ?? "no info";
            dynamic peopleId = profileData.data.peopleId;

            String yesNoMapper(dynamic value) {
              return value.toString() == "1" ? "Yes" : "No";
            }

            String rightToWorkUK = yesNoMapper(profileData.data.rightToWorkUk?.toString() ?? "");
            String dbsCheck = yesNoMapper(profileData.data.dbsCheck?.toString() ?? "");
            String optOutOfPension = yesNoMapper(profileData.data.optOutOfPension?.toString() ?? "");

            // String medicalConditions = profileData.data.medicalCondition ?? "None";

            if (address.length > 25) {
              address = '${address.substring(0, 25)}...';
            }

            if (addressF.length > 25) {
              addressF = '${addressF.substring(0, 25)}...';
            }

            String areYouCitizenOfUK = yesNoMapper(profileData.data.isUkCitizen?.toString() ?? "");
            String authorizedToWorkInUK = yesNoMapper(profileData.data.isAuthorizedToWorkInUk?.toString() ?? "");
            String hasUnspentCriminalConvictions = yesNoMapper(profileData.data.hasUnspentCriminalConvictions?.toString() ?? "");
            String ukDrivingExperience = yesNoMapper(profileData.data.ukDrivingExperience?.toString() ?? "");
            String validUkDrivingLicense = yesNoMapper(profileData.data.validUkDrivingLicense?.toString() ?? "");
            String penaltyPoints = yesNoMapper(profileData.data.penaltyPoints?.toString() ?? "");
            String physicalIncapabilities = yesNoMapper(profileData.data.physicalIncapabilities?.toString() ?? "");
            String ongoingMedicalConditions = yesNoMapper(profileData.data.ongoingMedicalConditions?.toString() ?? "");
            String takingMedication = yesNoMapper(profileData.data.takingMedication?.toString() ?? "");
            String drugOrAlcoholIssues = yesNoMapper(profileData.data.drugOrAlcoholIssues?.toString() ?? "");
            String wearsGlasses = yesNoMapper(profileData.data.wearsGlasses?.toString() ?? "");
            String dismissedForMedicalReasons = yesNoMapper(profileData.data.dismissedForMedicalReasons?.toString() ?? "");
            String dismissedFromDrivingRoles = yesNoMapper(profileData.data.dismissedFromDrivingRoles?.toString() ?? "");

            String formattedDate = '';
            if (profile.dob != null && profile.dob != 'No') {
              try {
                DateTime parsedDate = DateTime.parse(profile.dob.toString());
                formattedDate = '${parsedDate.day.toString().padLeft(2, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.year}';
              } catch (e) {
                formattedDate = 'Invalid date';
              }
            } else {
              formattedDate = 'No info';
            }
            String drivingLicenseIssueDate = '';
            if (profile.drivingLicenseIssueDate != null && profile.drivingLicenseIssueDate != 'No') {
              try {
                DateTime parsedDate = DateTime.parse(profile.drivingLicenseIssueDate.toString());
                drivingLicenseIssueDate = '${parsedDate.day.toString().padLeft(2, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.year}';
              } catch (e) {
                drivingLicenseIssueDate = 'Invalid date';
              }
            } else {
              drivingLicenseIssueDate = 'No info';
            }

            String lastEyeTest = '';
            if (profile.lastEyeTest != null && profile.lastEyeTest != 'No') {
              try {
                DateTime parsedDate = DateTime.parse(profile.lastEyeTest.toString());
                lastEyeTest = '${parsedDate.day.toString().padLeft(2, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.year}';
              } catch (e) {
                lastEyeTest = 'Invalid date';
              }
            } else {
              lastEyeTest = 'No info';
            }

            String formattedLicDate = '';
            if (profile.licenceExpiry != null && profile.licenceExpiry != 'No') {
              try {
                DateTime parsedDate = DateTime.parse(profile.licenceExpiry.toString());
                formattedLicDate = '${parsedDate.day.toString().padLeft(2, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.year}';
              } catch (e) {
                formattedLicDate = 'Invalid date';
              }
            } else {
              formattedLicDate = 'No info';
            }

            String formattedCpcDate = '';
            if (profile.cpcExpiry != null && profile.cpcExpiry != 'No') {
              try {
                DateTime parsedDate = DateTime.parse(profile.cpcExpiry.toString());
                formattedCpcDate = '${parsedDate.day.toString().padLeft(2, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.year}';
              } catch (e) {
                formattedCpcDate = 'Invalid date';
              }
            } else {
              formattedCpcDate = 'No info';
            }

            String formattedTachoExpDate = '';
            if (profile.tachoExpiry != null && profile.tachoExpiry != 'No') {
              try {
                DateTime parsedDate = DateTime.parse(profile.tachoExpiry.toString());
                formattedTachoExpDate = '${parsedDate.day.toString().padLeft(2, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.year}';
              } catch (e) {
                formattedTachoExpDate = 'Invalid date';
              }
            } else {
              formattedTachoExpDate = 'No info';
            }

            String formattedDBSExpiry = '';
            if (profile.dbsExpiry != null && profile.dbsExpiry != 'No') {
              try {
                DateTime parsedDate = DateTime.parse(profile.dbsExpiry.toString());
                formattedDBSExpiry = '${parsedDate.day.toString().padLeft(2, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.year}';
              } catch (e) {
                formattedDBSExpiry = 'Invalid date';
              }
            } else {
              formattedDBSExpiry = 'No info';
            }

            String camelCaseToWords(String text) {
              if (text == null || text.isEmpty) return '';
              final buffer = StringBuffer();
              buffer.write(text[0].toUpperCase()); // Capitalize the first letter
              for (int i = 1; i < text.length; i++) {
                if (text[i].toUpperCase() == text[i]) {
                  buffer.write(' ');
                }
                buffer.write(text[i]);
              }
              return buffer.toString();
            }

            Widget displayLicenceType(dynamic licenceType) {
              if (licenceType == null) {
                return Text(
                  'No licence types available',
                  style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 14, color: AppColors.blackOpacity.withOpacity(0.5)), fontWeight: FontWeight.w500),
                );
              } else if (licenceType is List<String>) {
                String licenceText = licenceType.map((type) => camelCaseToWords(type)).join(', ');
                String truncatedText = licenceText.length > 25 ? '${licenceText.substring(0, 25)}...' : licenceText;
                return GestureDetector(
                  onTapDown: (TapDownDetails details) {
                    _showFullLicensePopup(context, licenceText, details.globalPosition);
                  },
                  child: Text(
                    truncatedText,
                    style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 14, color: AppColors.blackOpacity.withOpacity(0.5)), fontWeight: FontWeight.w500),
                  ),
                );
              } else if (licenceType is String) {
                String licenceText = camelCaseToWords(licenceType);
                String truncatedText = licenceText.length > 25 ? '${licenceText.substring(0, 25)}...' : licenceText;
                return GestureDetector(
                  onTapDown: (TapDownDetails details) {
                    _showFullLicensePopup(context, licenceText, details.globalPosition);
                  },
                  child: Text(
                    truncatedText,
                    style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 14, color: AppColors.blackOpacity.withOpacity(0.5)), fontWeight: FontWeight.w500),
                  ),
                );
              } else {
                return Text(
                  '',
                  style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 14, color: AppColors.blackOpacity.withOpacity(0.5)), fontWeight: FontWeight.w500),
                );
              }
            }

            // Function to check if the selected role contains 'driver'
            bool isDriverRole() {
              return profile.roleType != null && profile.roleType!.toLowerCase().contains('driver');
            }

            return Column(
              children: [
                Container(
                  width: screenWidth,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.03,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2c3e50), Color(0xFF1a252f)], // Gradient colors
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    // borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30),
                    //   bottomRight: Radius.circular(30),
                    // ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StaffCurveNabBar(),
                                ),
                              );
                            },
                            child: Icon(
                              Icons.arrow_back,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Profile",
                            style: GoogleFonts.roboto(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              if (peopleId != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UpdateProfileV2(),
                                  ),
                                );
                              } else {
                                Utils.toastMessage("You are not registered in My Digital. Please contact Admin.");
                              }
                            },
                            child: Icon(
                              Icons.edit,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      GestureDetector(
                        onTap: () {
                          if (profilePick != null && profilePick.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenImageStaff(
                                  imageUrl: '${AppUrl.staffDriver}/$profilePick',
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          height: screenHeight * 0.15,
                          width: screenWidth * 0.3,
                          decoration: BoxDecoration(
                            color: Colors.grey[800], // Dark grey circle
                            shape: BoxShape.circle,
                            image: profilePick != null && profilePick.isNotEmpty
                                ? DecorationImage(
                              image: NetworkImage('${AppUrl.staffDriver}/$profilePick'),
                              fit: BoxFit.cover,
                            )
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: profilePick == null || profilePick.isEmpty
                              ? Icon(
                            Icons.person,
                            color: Colors.blueAccent,
                            size: screenHeight * 0.08,
                          )
                              : null,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        "${profile.firstName ?? ""} ${profile.lastName ?? ""}",
                        style: GoogleFonts.roboto(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        "${profile.email}",
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[400],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.02,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically in the center
                              children: [
                                // Profile Information Text
                                Text(
                                  "Account Overview",
                                  style: GoogleFonts.roboto(
                                    textStyle: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white, // Added for better contrast
                                    ),
                                  ),
                                ),

                                // Upload File Button
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FileUploadStaff(),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(8), // Rounded corners for the tap area
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent.withOpacity(0.1), // Subtle background color
                                      borderRadius: BorderRadius.circular(8), // Rounded corners
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.upload_file,
                                          color: Colors.blueAccent,
                                          size: 20, // Adjusted icon size
                                        ),
                                        SizedBox(width: 8), // Reduced spacing
                                        Text(
                                          "Upload File",
                                          style: GoogleFonts.roboto(
                                            textStyle: TextStyle(
                                              fontSize: 14, // Slightly smaller font size
                                              fontWeight: FontWeight.w600, // Bold for emphasis
                                              color: Colors.blueAccent,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Divider(color: Colors.grey[300]), // Add a divider for visual separation
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF2C3E50), Color(0xFF1A252F)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        ),
                        child: ExpansionTile(
                          key: item1Key,
                          onExpansionChanged: (expanded) {
                            setState(() {
                              _isExpanded = expanded;
                              print(_isExpanded);
                              if (expanded) {
                                item2Key = UniqueKey();
                                item3Key = UniqueKey();
                                item4Key = UniqueKey();
                                item5Key = UniqueKey();
                              }
                            });
                          },
                          iconColor: AppColors.navColor,
                          collapsedIconColor: Colors.white,
                          backgroundColor: Colors.white,
                          textColor: AppColors.navButtonColor,
                          collapsedTextColor: Colors.white,
                          tilePadding: EdgeInsets.only(left: 10),
                          minTileHeight: screenHeight * 0.06,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                          ),
                          collapsedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.12),
                          ),
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.person_outline),
                              SizedBox(width: screenWidth * 0.03),
                              Text(
                                "Personal Information",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.042,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              // Expanded(
                              //   child: Align(
                              //     alignment: Alignment.centerRight,
                              //     child: _isExpanded
                              //         ? InkWell(
                              //             onTap: () {
                              //              Navigator.push(context, MaterialPageRoute(builder: (context)=>PersonalInformationUpdate()));
                              //             },
                              //             child: Icon(
                              //               Icons.edit,
                              //               size: 20,
                              //               color: AppColors.navColor,
                              //             ),
                              //           )
                              //         : SizedBox.shrink(),
                              //   ),
                              // ),
                            ],
                          ),
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.02),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(screenWidth * 0.04),
                                child: Column(
                                  children: [
                                    _buildInfoRow("Email", "${profile.email ?? "No info"}"),
                                    Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                    _buildInfoRow("Phone", "${profile.phone ?? "No info"}"),
                                    Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                    _buildInfoRow("Town/City", "$townCity"),
                                    Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                    _buildInfoRow("Post Code", "${profile.postCode ?? "No info"}"),
                                    Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                    _buildInfoRowWithPopup("Address 1", "$addressF", profileData.data.addressLine1),
                                    Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                    _buildInfoRowWithPopup("Address 2", "$address", profileData.data.addressLine2),
                                    Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                    _buildInfoRow("Marital Status", "${profile.maritalStatus ?? "N/A"}"),
                                    Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                    _buildInfoRow("User Name", "${profile.userName ?? "No info"}"),
                                    Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                    _buildInfoRow("Gender", "${profile.gender ?? "No info"}"),
                                    Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                    _buildInfoRow("Ni Number", "${profile.niNumber ?? "No info"}"),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.grey[300],
                        thickness: 0.2,
                        height: screenHeight * 0.002,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF2C3E50), Color(0xFF1A252F)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        ),
                        child: ExpansionTile(
                          key: item2Key,
                          onExpansionChanged: (expanded) {
                            if (expanded == true) {
                              setState(() {
                                item1Key = UniqueKey();
                                item3Key = UniqueKey();
                                item4Key = UniqueKey();
                                item5Key = UniqueKey();
                              });
                            }
                          },
                          tilePadding: EdgeInsets.only(left: 10),
                          iconColor: AppColors.navButtonColor,
                          collapsedIconColor: Colors.white,
                          backgroundColor: Colors.white,
                          textColor: AppColors.navButtonColor,
                          collapsedTextColor: Colors.white,
                          minTileHeight: screenHeight * 0.06,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                          ),
                          collapsedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.12),
                          ),
                          // title: Padding(
                          //   padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                          //   child: ,
                          // ),
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.work_outline,
                              ),
                              SizedBox(width: screenWidth * 0.03),
                              Text("Employment & Eligibility",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.042,
                                    fontWeight: FontWeight.w500,
                                  )),
                              // Expanded(
                              //     child: Container(
                              //         child: Align(
                              //             alignment: Alignment.centerRight,
                              //             child: Icon(
                              //               Icons.edit,
                              //               size: 20,
                              //             )))),
                            ],
                          ),
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.02),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(screenWidth * 0.04),
                                child: Column(
                                  children: [
                                    _buildInfoRow(
                                      "Agency Consultant",
                                      "${profile.consultant ?? "N/A"}",
                                    ),
                                    Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                    _buildInfoRow(
                                      "Are you a citizen of the UK?",
                                      areYouCitizenOfUK,
                                    ),
                                    Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                    _buildInfoRow(
                                      "Do you have a Right to Work in the UK?",
                                      authorizedToWorkInUK,
                                    ),
                                    Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                    _buildInfoRow(
                                      "Do you have any unspent criminal convictions?",
                                      hasUnspentCriminalConvictions,
                                    ),
                                    Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                    _buildInfoRow(
                                      "Role",
                                      "${profile.roleType ?? "No info"}",
                                    ),
                                    Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                    _buildQuestionRow(
                                      "Do you have a DBS or EDBS (if applicable for your role)?",
                                      dbsCheck,
                                      screenWidth,
                                    ),
                                    Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                    _buildQuestionRow(
                                      "Do you want to opt out of the Pension Scheme?",
                                      optOutOfPension,
                                      screenWidth,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isDriverRole()) ...[
                        Divider(
                          color: Colors.grey[300],
                          thickness: 0.2,
                          height: screenHeight * 0.002,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF2C3E50), Color(0xFF1A252F)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                          ),
                          child: ExpansionTile(
                            key: item3Key,
                            onExpansionChanged: (expanded) {
                              if (expanded == true) {
                                setState(() {
                                  item1Key = UniqueKey();
                                  item2Key = UniqueKey();
                                  item4Key = UniqueKey();
                                  item5Key = UniqueKey();
                                });
                              }
                            },
                            iconColor: AppColors.navButtonColor,
                            collapsedIconColor: Colors.white,
                            backgroundColor: Colors.white,
                            textColor: AppColors.navButtonColor,
                            collapsedTextColor: Colors.white,
                            tilePadding: EdgeInsets.only(left: 10),
                            minTileHeight: screenHeight * 0.06,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(screenWidth * 0.03),
                            ),
                            collapsedShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(screenWidth * 0.12),
                            ),
                            // title: Padding(
                            //   padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                            //   child:,
                            // ),
                            title: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.directions_car),
                                SizedBox(width: screenWidth * 0.03),
                                Text(
                                  "Driving Qualifications",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.042,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                // Expanded(
                                //     child: Container(
                                //         child: Align(
                                //             alignment: Alignment.centerRight,
                                //             child: Icon(
                                //               Icons.edit,
                                //               size: 20,
                                //             )))),
                              ],
                            ),
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.02),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(screenWidth * 0.04),
                                  child: Column(
                                    children: [
                                      SizedBox(height: 5),
                                      _buildInfoRow(
                                        "Do you have UK driving experience?",
                                        "$ukDrivingExperience",
                                      ),

                                      Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
                                      if (ukDrivingExperience == 'Yes') ...[
                                        _buildInfoRow(
                                          "Do you hold a valid UK driving licence?",
                                          "$validUkDrivingLicense",
                                        ),
                                      ],
                                      Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
                                      _buildInfoRow(
                                        "licence Number",
                                        licenceNumber,
                                      ),
                                      Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider

                                      _buildInfoRow(
                                        "Date of issue of the driving licence.",
                                        "${drivingLicenseIssueDate}",
                                      ),
                                      Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
                                      _buildInfoRow(
                                        "Driving licence category",
                                        "${profile.drivingLicenseCategory ?? "No info"}",
                                      ),
                                      Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
                                      _buildInfoRow("licence Expiry", "$formattedLicDate"),
                                      Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
                                      _buildInfoRow(
                                        "Check code for driving licence.",
                                        "${profile.drivingLicenseCheckCode ?? "No info"}",
                                      ),
                                      Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider

                                      if (validUkDrivingLicense == 'Yes') ...[
                                        _buildInfoRow(
                                          "Do you have penalty points on your licence?",
                                          "$penaltyPoints",
                                        ),
                                        Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
                                      ],
                                      // _buildInfoRow(
                                      //   "Licence Types",
                                      //   displayLicenceType(
                                      //       profileData.data.licenceType),
                                      // ),
                                      middleContainer(
                                        "Licence Types",
                                        displayLicenceType(profileData.data.licenceType),
                                      ),

                                      Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
                                      _buildInfoRow(
                                        "licence Endorsements",
                                        licenceEndorsements,
                                      ),
                                      Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
                                      _buildInfoRow(
                                        "Tacho Number",
                                        TachoCard,
                                      ),
                                      Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
                                      _buildInfoRow(
                                        "Tacho Expiry",
                                        "$formattedTachoExpDate",
                                      ),

                                      Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
                                      _buildInfoRow(
                                        "CPC Number",
                                        CpcNumber,
                                      ),
                                      Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
                                      _buildInfoRow(
                                        "CPC Expiry",
                                        "$formattedCpcDate",
                                      ),

                                      Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
                                      _buildInfoRow(
                                        "DBS Expiry",
                                        "$formattedDBSExpiry",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      Divider(
                        color: Colors.grey[300],
                        thickness: 0.2,
                        height: screenHeight * 0.002,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF2C3E50), Color(0xFF1A252F)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        ),
                        child: ExpansionTile(
                          key: item4Key,
                          onExpansionChanged: (expanded) {
                            if (expanded == true) {
                              setState(() {
                                item1Key = UniqueKey();
                                item2Key = UniqueKey();
                                item3Key = UniqueKey();
                                item5Key = UniqueKey();
                              });
                            }
                          },
                          iconColor: AppColors.navButtonColor,
                          collapsedIconColor: Colors.white,
                          backgroundColor: Colors.white,
                          textColor: AppColors.navButtonColor,
                          collapsedTextColor: Colors.white,
                          tilePadding: EdgeInsets.zero,
                          minTileHeight: screenHeight * 0.06,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                          ),
                          collapsedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.12),
                          ),
                          title: Padding(
                            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.medical_information_outlined,
                                ),
                                SizedBox(width: screenWidth * 0.03),
                                Text("Medical & Fitness",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.042,
                                      fontWeight: FontWeight.w500,
                                    )),
                              ],
                            ),
                          ),
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.02),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(screenWidth * 0.04),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildQuestionRow("Do you have any ongoing medical conditions?", "${ongoingMedicalConditions}", screenWidth),
                                    Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                    _buildQuestionRow("Do you have any physical incapabilities?", physicalIncapabilities, screenWidth),
                                    Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                    _buildQuestionRow("Are you currently taking any medication?", "${takingMedication}", screenWidth),
                                    Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                    _buildQuestionRow("Do you have ongoing issues with drugs or alcohol?", "${drugOrAlcoholIssues}", screenWidth),
                                    Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Color(0xFF2C3E50), Color(0xFF1A252F)],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                                      ),
                                      child: ExpansionTile(
                                        iconColor: AppColors.navButtonColor,
                                        collapsedIconColor: Colors.white,
                                        backgroundColor: Colors.white,
                                        textColor: AppColors.navButtonColor,
                                        collapsedTextColor: Colors.white,
                                        tilePadding: EdgeInsets.zero,
                                        minTileHeight: screenHeight * 0.03,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(screenWidth * 0.03),
                                        ),
                                        collapsedShape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(screenWidth * 0.12),
                                        ),
                                        title: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                                          child: Row(children: [
                                            Icon(
                                              Icons.visibility_outlined,
                                            ), // Cleaner icon
                                            SizedBox(width: 12),
                                            Text(
                                              "Vision Requirements",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            )
                                          ]),
                                        ),
                                        children: [
                                          Divider(thickness: 1, color: Colors.grey[300]),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                                            child: Column(
                                              children: [
                                                _buildInfoRow(
                                                  "Do you currently wear glasses?",
                                                  "${wearsGlasses}",
                                                ),
                                                Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
                                                _buildInfoRow(
                                                  "When was your last eye test?",
                                                  "${lastEyeTest}",
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                    _buildQuestionRow("Have you ever been dismissed for medical reasons?", "${dismissedForMedicalReasons}", screenWidth),
                                    Divider(height: screenHeight * 0.02, thickness: 1, color: Colors.grey[200]),
                                    _buildQuestionRow("Have you been dismissed from previous driving roles in the last 3 years?", "${dismissedFromDrivingRoles}", screenWidth),
                                    SizedBox(height: 5),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.grey[300],
                        thickness: 0.2,
                        height: screenHeight * 0.002,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF2C3E50), Color(0xFF1A252F)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        ),
                        child: ExpansionTile(
                          key: item5Key,
                          onExpansionChanged: (expanded) {
                            if (expanded == true) {
                              setState(() {
                                item1Key = UniqueKey();
                                item2Key = UniqueKey();
                                item3Key = UniqueKey();
                                item4Key = UniqueKey();
                              });
                            }
                          },
                          iconColor: AppColors.navButtonColor,
                          collapsedIconColor: Colors.white,
                          backgroundColor: Colors.white,
                          textColor: AppColors.navButtonColor,
                          collapsedTextColor: Colors.white,
                          tilePadding: EdgeInsets.zero,
                          minTileHeight: screenHeight * 0.06,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                          ),
                          collapsedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.12),
                          ),
                          title: Padding(
                            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.account_balance_outlined,
                                ),
                                SizedBox(width: screenWidth * 0.03),
                                Text("Banking Information",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.042,
                                      fontWeight: FontWeight.w500,
                                    )),
                              ],
                            ),
                          ),
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.02),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(screenWidth * 0.04),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ..._buildBankDetailsWidgets(profile),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.013,
                      ),
                      SizedBox(height: 5),
                      SizedBox(height: screenHeight * 0.023),
                      Container(
                        height: screenHeight * 0.05,
                        width: screenWidth * 0.4,
                        decoration: BoxDecoration(
                          // color: AppColors.navButtonColor,
                            color: AppColors.navOpacity,
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
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.navOpacity,
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
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  List<Widget> _buildBankDetailsWidgets(Data profile) {
    if (profile.bankDetail == null) {
      return []; // Return an empty list if bankDetail is null
    }

    List<Widget> bankDetailsWidgets = [];

    // Account Type
    bankDetailsWidgets.add(_buildInfoRow("Account Type", profile.bankDetail!.accountType ?? "No info"));
    bankDetailsWidgets.add(
      Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
    );

    // Bank Name
    bankDetailsWidgets.add(_buildInfoRow("Bank Name", profile.bankDetail!.bankName ?? "No info"));
    bankDetailsWidgets.add(
      Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
    );

    // Account Name
    bankDetailsWidgets.add(_buildInfoRow("Account Name", profile.bankDetail!.accountName ?? "No info"));

    // Conditional display based on account type
    if (profile.bankDetail!.accountType == 'BANK_ACCOUNT' || profile.bankDetail!.accountType == 'BUILDING_SOCIETY') {
      bankDetailsWidgets.add(
        Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
      );
      // Account Number
      bankDetailsWidgets.add(_buildInfoRow("Account Number", profile.bankDetail!.accountNumber?.toString() ?? "No info"));
      bankDetailsWidgets.add(
        Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
      );

      // Bank Code
      bankDetailsWidgets.add(_buildInfoRow("Bank Code", profile.bankDetail!.bankCode ?? "No info"));

      // Building Society (only for BUILDING_SOCIETY account type)
      if (profile.bankDetail!.accountType == 'BUILDING_SOCIETY') {
        bankDetailsWidgets.add(
          Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
        );
        bankDetailsWidgets.add(_buildInfoRow("Building Society", profile.bankDetail!.buildingSocietyRollNumber ?? "No info"));
      }
    } else if (profile.bankDetail!.accountType == 'INTERNATIONAL_BANK_ACCOUNT') {
      bankDetailsWidgets.add(
        Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
      );
      // Recipient Address 1
      bankDetailsWidgets.add(_buildInfoRow("Recipient Address 1", profile.bankDetail!.recipientAddress1 ?? "No info"));
      bankDetailsWidgets.add(
        Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
      );

      // Recipient Address 2
      bankDetailsWidgets.add(_buildInfoRow("Recipient Address 2", profile.bankDetail!.recipientAddress2 ?? "No info"));
      bankDetailsWidgets.add(
        Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
      );

      // Recipient Address 3
      bankDetailsWidgets.add(_buildInfoRow("Recipient Address 3", profile.bankDetail!.recipientAddress3 ?? "No info"));
      bankDetailsWidgets.add(
        Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
      );

      // IBAN
      bankDetailsWidgets.add(_buildInfoRow("IBAN", profile.bankDetail!.iban ?? "No info"));
      bankDetailsWidgets.add(
        Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
      );

      // BIC/Swift
      bankDetailsWidgets.add(_buildInfoRow("BIC/Swift", profile.bankDetail!.bicSwiftCode ?? "No info"));
      bankDetailsWidgets.add(
        Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
      );

      // Payment ISO Country Code
      bankDetailsWidgets.add(_buildInfoRow("Payment ISO Country Code", profile.bankDetail!.paymentIsoCode ?? "No info"));
      bankDetailsWidgets.add(
        Divider(thickness: 1, color: Colors.grey[300]), // Subtle divider
      );

      // Credit ISO Currency Code
      bankDetailsWidgets.add(_buildInfoRow("Credit ISO Currency Code", profile.bankDetail!.creditIsoCode ?? "No info"));
    }

    return bankDetailsWidgets;
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
              style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 14, color: AppColors.blackOpacity.withOpacity(0.5)), fontWeight: FontWeight.w500),
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
              style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 14, color: AppColors.blackOpacity.withOpacity(0.5)), fontWeight: FontWeight.w500),
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
              style: GoogleFonts.roboto(textStyle: TextStyle(fontSize: 14, color: AppColors.blackOpacity.withOpacity(0.5)), fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }

  Widget Questions({
    required String title,
    required String ans,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        SizedBox(height: screenHeight * 0.013),
        Container(
            width: screenWidth * 0.3,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              border: Border.all(
                color: Colors.grey.withOpacity(0.4),
                width: 0.4,
              ),
              borderRadius: BorderRadius.circular(2.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Center(child: Text(ans)),
            )),
      ],
    );
  }

  Widget Questions2({
    required String title,
    required String ans,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        SizedBox(height: screenHeight * 0.013),
        Container(
          width: screenWidth * 0.3,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            border: Border.all(
              color: Colors.grey.withOpacity(0.4),
              width: 0.4,
            ),
            borderRadius: BorderRadius.circular(2.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              ans,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
              softWrap: true, // Allows wrapping to the next line
              overflow: TextOverflow.visible, // Ensures visibility of all text
            ),
          ),
        ),
      ],
    );
  }

  Widget middleContainer(String title, Widget titleData) {
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
        // padding: const EdgeInsets.only(left: 10, right: 10),
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),

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
                  // style: GoogleFonts.roboto(
                  //     textStyle: TextStyle(
                  //       fontSize: 15,
                  //     ),
                  //     fontWeight: FontWeight.bold),
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[700],
                  ),
                )
              ],
            ),
            titleData, // Display the title data widget
          ],
        ),
      ),
    );
  }

  void _showFullLicensePopup(BuildContext context, String fullLicenseTypes, Offset position) {
    final screenWidth = MediaQuery.of(context).size.width * 1;
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
            width: screenWidth * 0.95,
            child: Center(
              child: Text(
                fullLicenseTypes,
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to build a question row
  Widget _buildQuestionRow(String title, String ans, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: screenWidth * 0.038,
              fontWeight: FontWeight.w400,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: screenWidth * 0.01),
          Text(
            ans,
            style: TextStyle(
              fontSize: screenWidth * 0.038,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      String label,
      String value,
      ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w400,
                color: Colors.grey[700],
              ),
            ),
          ),
          Flexible(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: screenWidth * 0.034,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowWithPopup(String label, String value, String? popupValue) {
    return GestureDetector(
      onTapUp: (details) {
        if (popupValue != null) {
          _showFullNamePopup(context, popupValue, details.globalPosition);
        }
      },
      child: _buildInfoRow(label, value),
    );
  }
}

