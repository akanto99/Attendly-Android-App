import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:c9_app/DarkAndLightTheme/theme_provider.dart';
import 'package:c9_app/Modules/ClientModule/client_screen.dart';
import 'package:c9_app/Modules/ClientModule/model/clientDirectoryModel/calculationModels/Active_InActive/inActiveClientModel.dart';
import 'package:c9_app/Modules/ClientModule/pages/FullImageView.dart';
import 'package:c9_app/loadingScreen.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as https;

class PreviousStaff extends StatefulWidget {
  const PreviousStaff({super.key});

  @override
  State<PreviousStaff> createState() => _PreviousStaffState();
}

class _PreviousStaffState extends State<PreviousStaff> {
  late Future<InActiveClientModel> _showInactiveList;
  late String selectedDepartmentID;
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;


  @override
  void initState() {
    super.initState();
    _showInactiveList = fetchInactiveClient();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _showInactiveList = fetchInactiveClient();
    });
  }



  Future<InActiveClientModel> fetchInactiveClient() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';

    final String apiUrl = '${AppUrl.baseUrl}/api/app/previous/staff';
    final response = await https.get(Uri.parse(apiUrl), headers: {
      'Authorization': 'Bearer $_token',
    });
    if (response.statusCode == 200) {
      return inActiveClientModelFromJson(response.body);
    } else {
      throw Exception('Failed to load day rate index');
    }
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body:  RefreshIndicator(
          onRefresh: _refreshData,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isSearching = false;
              });
            },
            child: ResPonsiveUi(
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;

    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Center(
        child: Container(
          width: screenWidth,
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight*0.013,),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: [
              //     Container(
              //       height: 1,
              //       width: screenWidth*0.28,
              //       color: Colors.grey,
              //
              //     ),
              //     Padding(
              //       padding: EdgeInsets.symmetric(horizontal: 5.0),
              //       child: Text("Pevious Staffs",style: TextStyle(
              //           fontSize: 18,fontWeight: FontWeight.w500
              //       ),),
              //     ),
              //     Container(
              //       height: 1,
              //       width: screenWidth*0.28,
              //       color: Colors.grey,
              //     ),
              //   ],
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: screenHeight * 0.055,
                    width: screenWidth * 0.15,
                    child: Icon(
                      Icons.home,
                      color: Colors.transparent,
                    ),
                  ),
                  Text("Previous Staff",style: TextStyle(
                      fontSize: 18,fontWeight: FontWeight.w500
                  ),),
                  //Serachbar from this api function AssignClientList
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isSearching = !_isSearching;
                      });
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height: screenHeight * 0.055,
                      width: _isSearching ? screenWidth * 0.5 : screenWidth * 0.15,
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            offset: Offset(0, 2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                        border: Border.all(
                            width: 0.4,
                            color: AppColors.navColor
                        ),
                      ),
                      child: _isSearching
                          ? Align(
                        alignment: Alignment.centerLeft,
                        child: TextFormField(
                          controller: _searchController,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: 'Staff name or email',
                            border: InputBorder.none, ),
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      )
                          : Icon(Icons.search,color:AppColors.navButtonColor,),
                    ),
                  ),
                ],
              ) ,
              SizedBox(height: screenHeight*0.013,),
              Center(
                child: FutureBuilder<InActiveClientModel>(
                  future: _showInactiveList,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        height: screenHeight *0.55,
                        width: screenWidth,
                        color: AppColors.whiteColor,
                        child: LoadingScreen(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text(''));
                      // return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      final InActiveClient = snapshot.data?.data;

                      if (InActiveClient != null && InActiveClient.isNotEmpty) {
                        return  ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: InActiveClient.length,
                          itemBuilder: (context, index) {
                            // final Firstname = InActiveClient[index].drivers?.firstName?? "no";
                            // final Lastname = InActiveClient[index].drivers?.lastName?? "no";
                            final Firstname = InActiveClient[index].drivers?.firstName?.toLowerCase() ?? "";
                            final Lastname = InActiveClient[index].drivers?.lastName?.toLowerCase() ?? "";
                            final email = InActiveClient[index].drivers?.email?? "no info";
                            final phone = InActiveClient[index].drivers?.phone?? "no info";
                            final gender = InActiveClient[index].drivers?.gender?? "no info";
                            final staff = InActiveClient[index].drivers?.driverType?? "no info";
                            final image = InActiveClient[index].drivers?.image?? "";
                            final assignNumber = InActiveClient[index].AssignmentNumber?? "";
                            // final slug = InActiveClient[index].slug;

                            // Get the first name and last name from the search query
                            final searchQuery = _searchController.text.trim().toLowerCase();
                            final List<String> searchParts = searchQuery.split(" ");
                            String searchFirstName = searchParts.isNotEmpty ? searchParts[0] : "";
                            String searchLastName = searchParts.length > 1 ? searchParts.sublist(1).join(" ") : "";

                            // Check if either the first name or the last name contains the search query
                            final firstNameMatches = Firstname.trim().toLowerCase().contains(searchFirstName);
                            final lastNameMatches = Lastname.trim().toLowerCase().contains(searchLastName);

                            final isMatch =  Firstname.contains(_searchController.text.toLowerCase()) ||
                                Lastname.contains(_searchController.text.toLowerCase()) || firstNameMatches && lastNameMatches ||
                                email.contains(_searchController.text.toLowerCase());




                            if (_searchController.text.isEmpty || isMatch) {
                              return Column(
                                children: [
                                  Container(
                                    width: screenWidth*0.90,
                                    decoration: BoxDecoration(
                                      color: AppColors.whiteColor,
                                      borderRadius: BorderRadius.circular(10), // Border radius
                                      boxShadow: [
                                        BoxShadow(
                                          color:  AppColors.greyOpacity,
                                          offset: Offset(0, 2),
                                          blurRadius: 5,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        SizedBox(height: screenHeight*0.007,),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10.0, right: 10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [

                                              Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => FullScreenImage(imageUrl: '${AppUrl.baseUrl}/backend/logo/$image'),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      height: screenHeight * 0.05,
                                                      width: screenWidth * 0.1,
                                                      decoration: BoxDecoration(
                                                        color:  AppColors.navOpacity,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          image: DecorationImage(
                                                            image: NetworkImage(
                                                              '${AppUrl.baseUrl}/backend/logo/$image',
                                                            ),
                                                            fit: BoxFit.cover, // Adjust this to fit your needs
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  SizedBox(width: screenWidth*0.03,),
                                                  Container(
                                                    height: screenHeight * 0.04,
                                                    width: screenWidth * 0.35,
                                                    child: AutoSizeText("$Firstname $Lastname", minFontSize: 5, maxFontSize: 20, style: TextStyle(
                                                      fontSize: 20, fontWeight: FontWeight.w600,
                                                    )),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                height: screenHeight * 0.04,
                                                width: screenWidth * 0.32,
                                                decoration: BoxDecoration(
                                                    color:  AppColors.navOpacity, borderRadius: BorderRadius.circular(8)
                                                ),
                                                child: Center(child: AutoSizeText('$assignNumber',minFontSize: 5, maxFontSize: 16,),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: screenHeight*0.007,),
                                        RowData("Name", '$Firstname $Lastname'),
                                        SizedBox(height: screenHeight*0.013,),
                                        RowData("Email", email),
                                        SizedBox(height: screenHeight*0.013,),
                                        RowData("Phone", phone),
                                        SizedBox(height: screenHeight*0.013,),
                                        RowData("Gender", gender,),
                                        SizedBox(height: screenHeight*0.013,),
                                        RowData("Staff", staff),
                                        SizedBox(height: screenHeight*0.01,),

                                      ],
                                    ), // Replace YourChildWidget with your actual widget
                                  ),
                                  SizedBox(height: screenHeight*0.023,),
                                ],
                              );
                            } else {
                              return Container();
                            }

                          },
                        );
                      } else {
                        return Container(
                          height:screenHeight*0.5,
                          child:Center(child: Text('Empty !!!')
                          ),);
                      }
                    }
                  },
                ),
              ),
              SizedBox(height: screenHeight*0.1,),

            ],
          ),
        ),
      ),
    );
  }

  Widget RowData(String text, String text2){
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return Container(
      width: screenWidth*0.90,
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              height: screenHeight*0.03,
              width: screenWidth*0.25,

              child: Align(
                  alignment: Alignment.centerLeft,
                  child: AutoSizeText(text,style: TextStyle(
                      fontSize: 20,fontWeight: FontWeight.w400
                  ),))),
          SizedBox(width: screenWidth*0.023,),
          Container(
            height: 30,
            width: 1,
            color: Colors.grey,
          ),
          SizedBox(width: screenWidth*0.023,),
          Container(
              height: screenHeight*0.03,

              child: Align(
                  alignment: Alignment.centerLeft,
                  child: AutoSizeText(text2,style: TextStyle(
                      fontSize: 18,color: AppColors.blackColor.withOpacity(0.6)
                  ),))),
        ],
      ),
    );
  }




}