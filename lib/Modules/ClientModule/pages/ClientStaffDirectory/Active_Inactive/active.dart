// import 'dart:async';
// import 'dart:convert';
// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:c9_app/Modules/ClientModule/client_screen.dart';
// import 'package:c9_app/Modules/ClientModule/model/clientDirectoryModel/calculationModels/Active_InActive/ActiveClientModel.dart';
// import 'package:c9_app/Modules/ClientModule/pages/Calendar/calendar.dart';
//  import 'package:c9_app/Modules/ClientModule/pages/ClientStaffDirectory/calculations/BulkAction/bulkapproved_showlist.dart';
//  import 'package:c9_app/Modules/ClientModule/pages/ClientStaffDirectory/calculations/WeekDataByClient/weekdataclients_new.dart';
// import 'package:c9_app/Modules/ClientModule/pages/Client_Document/ViewFolder.dart';
// import 'package:c9_app/Modules/ClientModule/pages/FullImageView.dart';
// import 'package:c9_app/loadingScreen.dart';
// import 'package:c9_app/res/app_url.dart';
// import 'package:c9_app/res/color.dart';
// import 'package:c9_app/responsive/responsive_ui.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:lottie/lottie.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as https;
//
// class ActiveStaff extends StatefulWidget {
//   const ActiveStaff({super.key});
//
//   @override
//   State<ActiveStaff> createState() => _ActiveStaffState();
// }
//
// class _ActiveStaffState extends State<ActiveStaff> {
//   late Future<ActiveClientStaffModel> _showActiveList;
//   String selectedDepartmentName = 'Select';
//   late String selectedDepartmentID;
//   TextEditingController _searchController = TextEditingController();
//   bool _isSearching = false;
//
//
//   @override
//   void initState() {
//     super.initState();
//     _showActiveList = fetchActiveClient();
//     _refreshData();
//   }
//
//   Future<void> _refreshData() async {
//     setState(() {
//       _showActiveList = fetchActiveClient();
//     });
//   }
//   Future<void> AssignDept(String departmentName, String slug) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String _token = prefs.getString('token') ?? '';
//
//     final url = Uri.parse('${AppUrl.baseUrl}/api/app/assign/department/$slug'); // Update URL with the slug
//
//     final response = await https.post(
//       url,
//       headers: {
//         'Authorization': 'Bearer $_token',
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode({
//         'dept_slug': departmentName,
//       }),
//     );
//
//     if (response.statusCode == 200) {
//       setState(() {
//         _showActiveList = fetchActiveClient();
//       });
//       // If the data is submitted successfully
//       print('Data submitted successfully: ${response.body}');
//       print('Slugs-----: $slug');
//       print('Department slug id-----: $selectedDepartmentID');
//       print('Dept Name-----: $selectedDepartmentName');
//       print('Post deps Slug: $departmentName');
//     } else {
//       print('Failed to post Data: ${response.body}');
//       print('Slugs-----: $slug');
//       print('Department slug id-----: $selectedDepartmentID');
//       print('Dept Name-----: $selectedDepartmentName');
//       print('Post deps Slug: $departmentName');
//     }
//   }
//
//   Future<void> PostDropDownData(String slug, List<String> selectedMethods) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String _token = prefs.getString('token') ?? '';
//
//     final url = Uri.parse('${AppUrl.baseUrl}/api/app/calculation/method/$slug');
//
//     final response = await https.post(
//       url,
//       headers: {
//         'Authorization': 'Bearer $_token',
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode({
//         'calculation_method': selectedMethods,
//       }),
//     );
//
//     if (response.statusCode == 200) {
//       setState(() {
//         _showActiveList = fetchActiveClient();
//       });
//     } else {
//       print('Failed to post Data: ${response.body}');
//     }
//   }
//   // fffffffffffff
//
//   Future<ActiveClientStaffModel> fetchActiveClient() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String _token = prefs.getString('token') ?? '';
//
//     final String apiUrl = '${AppUrl.baseUrl}/api/app/index';
//     final response = await https.get(Uri.parse(apiUrl), headers: {
//       'Authorization': 'Bearer $_token',
//     });
//     if (response.statusCode == 200) {
//       return activeClientStaffModelFromJson(response.body);
//     } else {
//       throw Exception('Failed to load day rate index');
//     }
//   }
//
//   List<String> _selectedLicenseTypes = [];
//   final List<String> _licenseTypes = ['Manual_Calculation', 'One_tap_Calculation', 'Period_Calculation',];
//
//   // Map<String, String> methodDisplayNames = {
//   //   'Manual_Calculation': 'Manual Calculation',
//   //   'One_tap_Calculation': 'One Tap Calculation',
//   //   'Period_Calculation': 'Period Calculation',
//   // };
//   String replaceUnderscoreWithSpace(String input) {
//     return input.replaceAll('_', ' ');
//   }
//   @override
//     Widget build(BuildContext context) {
//       return SafeArea(
//         child: Scaffold(
//            backgroundColor: Colors.white, ///Background
//           body:  RefreshIndicator(
//             onRefresh: _refreshData,
//             child: GestureDetector(
//               onTap: () {
//                 setState(() {
//                   _isSearching = false;
//                 });
//               },
//               child: ResPonsiveUi(
//                 mobile: body(),
//                 desktop: body(),
//                 tablet: body(),
//               ),
//             ),
//           ),
//         ),
//       );
//     }
//
//     Widget body() {
//       final screenHeight = MediaQuery.of(context).size.height * 1;
//       final screenWidth = MediaQuery.of(context).size.width * 1;
//
//       return SingleChildScrollView(
//         physics: AlwaysScrollableScrollPhysics(),
//         child: Center(
//           child: Container(
//             width: screenWidth,
//             child: Column(
//               // crossAxisAlignment: CrossAxisAlignment.start,
//               // mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//
//                 SizedBox(height: screenHeight*0.013,),
//
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Container(
//                       height: screenHeight * 0.055,
//                       width: screenWidth * 0.15,
//                       child: Icon(
//                         Icons.home,
//                         color: Colors.transparent,
//                       ),
//                     ),
//                     Text("Active Staff",style: TextStyle(
//                         fontSize: 18,fontWeight: FontWeight.w500
//                     ),),
//                     //Serachbar from this api function AssignClientList
//                     GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           _isSearching = !_isSearching;
//                         });
//                       },
//                       child: AnimatedContainer(
//                         duration: Duration(milliseconds: 300),
//                         curve: Curves.easeInOut,
//                         height: screenHeight * 0.055,
//                         width: _isSearching ? screenWidth * 0.5 : screenWidth * 0.15,
//                         decoration: BoxDecoration(
//                           color: AppColors.whiteColor, //Search background
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.grey.withOpacity(0.1),
//                               offset: Offset(0, 2),
//                               blurRadius: 10,
//                               spreadRadius: 2,
//                             ),
//                           ],
//                           borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(20),
//                             bottomLeft: Radius.circular(20),
//                           ),
//                           border: Border.all(
//                               width: 0.4,
//                               color: AppColors.navColor  // border background
//                           ),
//                         ),
//                         child: _isSearching
//                             ? Align(
//                           alignment: Alignment.centerLeft,
//                           child: TextFormField(
//                             controller: _searchController,
//                             textAlign: TextAlign.center,
//                             decoration: InputDecoration(
//                               hintText: 'Staff name or email',
//                               border: InputBorder.none,
//                             ),
//                             onChanged: (value) {
//                               setState(() {});
//                             },
//                           ),
//                         )
//                             : Icon(Icons.search,color:AppColors.navButtonColor,),
//                       ),
//                     ),
//                   ],
//                 ) ,
//                 SizedBox(height: screenHeight*0.013,),
//                 Center(
//                   child: FutureBuilder<ActiveClientStaffModel>(
//                     future: _showActiveList,
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return Container(
//                           height:screenHeight *0.55,
//                           width: screenWidth,
//                           color: AppColors.whiteColor,
//                           child: LoadingScreen(),
//                         );
//                       } else if (snapshot.hasError) {
//                         return SingleChildScrollView(
//                           child: Container(
//                             height: screenHeight*0.5,
//                             width: screenWidth,
//                             color: AppColors.whiteColor,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 SizedBox(
//                                   height: 200,
//                                   width: 200,
//                                   child: Lottie.asset('images/internet.json'),
//                                 ),
//                                 GestureDetector(
//                                   onTap: (){
//                                     Navigator.push(context, MaterialPageRoute(builder: (context)=>ClientCurveNabBar()));
//                                   } ,
//                                   child: Container(
//                                     height: 40,
//                                     width: 180,
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(25),
//                                       border: Border.all(width: 2,color: Color(0xff2A63A5)),
//                                       color: Colors.white60,
//                                     ),
//                                     child: Center(
//                                       child: Text('Try again'),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                      // return Center(child: Text('Error: ${snapshot.error}'));
//                       } else {
//                         final ActiveClient = snapshot.data?.data;
//                         final DepartMents = snapshot.data?.the0;
//
//                         if (ActiveClient != null && ActiveClient.isNotEmpty) {
//                           return ListView.builder(
//                             shrinkWrap: true,
//                             physics: NeverScrollableScrollPhysics(),
//                             itemCount: ActiveClient.length,
//                             itemBuilder: (context, index) {
//                               final email = ActiveClient[index].drivers?.email ?? "no info";
//                               final slug = ActiveClient[index].slug;
//                               final Driverslug = ActiveClient[index].driverSlug;
//                               final assignId = ActiveClient[index].assignmentNumber ?? "";
//                               final phone = ActiveClient[index].drivers?.phone ?? "no info";
//                               final gender = ActiveClient[index].drivers?.gender ?? "no info";
//                               final dep = ActiveClient[index].deptSlug ?? "no info";
//                               final doc = ActiveClient[index].drivers?.file ?? "no info";
//                               final image = ActiveClient[index].drivers?.image ?? "no info";
//                               final breakTimes = ActiveClient[index].clients?.breakTime ?? "";
//                               final calculationMethodJson = ActiveClient[index].calculationMethod ?? "[]";
//                               final firstName = ActiveClient[index].drivers?.firstName?.toLowerCase() ?? "";
//                               final lastName = ActiveClient[index].drivers?.lastName?.toLowerCase() ?? "";
//
//
//                               final truncatedEmail = email.length > 20 ? email.substring(0, 20) + "..." : email;
//
//                               // Get the first name and last name from the search query
//                               final searchQuery = _searchController.text.trim().toLowerCase();
//                               final List<String> searchParts = searchQuery.split(" ");
//                               String searchFirstName = searchParts.isNotEmpty ? searchParts[0] : "";
//                               String searchLastName = searchParts.length > 1 ? searchParts.sublist(1).join(" ") : "";
//
//                               // Check if either the first name or the last name contains the search query
//                               final firstNameMatches = firstName.trim().toLowerCase().contains(searchFirstName);
//                               final lastNameMatches = lastName.trim().toLowerCase().contains(searchLastName);
//
//                               final isMatch =  firstName.contains(_searchController.text.toLowerCase()) ||
//                                   lastName.contains(_searchController.text.toLowerCase()) || firstNameMatches && lastNameMatches ||
//                                   email.contains(_searchController.text.toLowerCase());
//
//
//                               List<String> calculationMethods = [];
//                               try {
//                                 calculationMethods = List<String>.from(json.decode(calculationMethodJson));
//                               } catch (e) {
//                                 // Handle the error if JSON parsing fails
//                                 calculationMethods = [];
//                               }
//
//
//                               // Only display the item if it matches the search query
//                               if (_searchController.text.isEmpty || isMatch) {
//                                 return Column(
//                                   children: [
//                                     Container(
//                                       width: screenWidth * 0.90,
//                                       decoration: BoxDecoration(
//
//                                         /// Active Staff Color
//                                         color: AppColors.whiteColor,
//                                         borderRadius: BorderRadius.circular(10), // Border radius
//                                         boxShadow: [
//                                           BoxShadow(
//                                             color: AppColors.greyOpacity,
//                                             offset: Offset(0, 2),
//                                             blurRadius: 5,
//                                             spreadRadius: 2,
//                                           ),
//                                         ],
//                                       ),
//                                       child: Column(
//                                         children: [
//                                           SizedBox(height: screenHeight * 0.0013,),
//                                           Padding(
//                                             padding: const EdgeInsets.only(left: 10.0, right: 10, top: 5, bottom: 5),
//                                             child: Row(
//                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                               children: [
//                                                 Row(
//                                                   children: [
//                                                     GestureDetector(
//                                                       onTap: () {
//                                                         Navigator.push(
//                                                           context,
//                                                           MaterialPageRoute(
//                                                             builder: (context) => FullScreenImage(imageUrl: '${AppUrl.clientDrivers}/$image'),
//                                                           ),
//                                                         );
//                                                       },
//                                                       child: Container(
//                                                         height: screenHeight * 0.05,
//                                                         width: screenWidth * 0.1,
//                                                         decoration: BoxDecoration(
//                                                           color: AppColors.navOpacity,
//                                                           shape: BoxShape.circle,
//
//                                                         ),
//                                                         child: Container(
//                                                           decoration: BoxDecoration(
//                                                             shape: BoxShape.circle,
//                                                             image: DecorationImage(
//                                                               image: NetworkImage(
//                                                                 '${AppUrl.clientDrivers}/$image',
//                                                               ),
//                                                               fit: BoxFit.cover, // Adjust this to fit your needs
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     SizedBox(width: screenWidth * 0.03,),
//                                                     Container(
//                                                       height: screenHeight * 0.04,
//                                                       width: screenWidth * 0.35,
//                                                       child: AutoSizeText("$firstName $lastName", minFontSize: 5, maxFontSize: 20, style: TextStyle(
//                                                         fontSize: 20, fontWeight: FontWeight.w600,
//                                                       )),
//                                                     ),
//                                                   ],
//                                                 ),
//                                                 Container(
//                                                   height: screenHeight * 0.04,
//                                                   width: screenWidth * 0.32,
//                                                   decoration: BoxDecoration(
//                                                     // color: AppColors.navOpacity,  // Active user ID background color
//                                                     color: AppColors.navOpacity,  // Active user ID background color
//                                                     borderRadius: BorderRadius.circular(8),
//                                                   ),
//                                                   child: Center(child: AutoSizeText(assignId, minFontSize: 5, maxFontSize: 16,)),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                           Padding(
//                                             padding: const EdgeInsets.only(left: 10.0, right: 10),
//                                             child: Column(
//                                               children: [
//                                                 SizedBox(height: screenHeight * 0.007,),
//                                                 RowData("Email", truncatedEmail),
//                                                 SizedBox(height: screenHeight * 0.013,),
//                                                 RowData("Phone", phone),
//                                                 SizedBox(height: screenHeight * 0.013,),
//                                                 RowData("Gender", gender),
//                                                 SizedBox(height: screenHeight * 0.013,),
//                                                 RowDept("Department", dep, DepartMents!, slug!),
//                                                 SizedBox(height: screenHeight * 0.013,),
//                                                 GestureDetector(
//                                                   onTap: () {
//                                                     List<String> availableMethods = [];
//                                                     List<String> allMethods = ['Manual_Calculation', 'One_tap_Calculation', 'Period_Calculation'];
//
//                                                     // Filter out the already selected methods from all methods
//                                                     availableMethods = allMethods.where((method) => !calculationMethods.contains(method)).toList();
//
//                                                     showDialog(
//                                                       context: context,
//                                                       barrierDismissible: false,
//                                                       builder: (BuildContext context) {
//                                                         return StatefulBuilder(
//                                                           builder: (context, setState) {
//                                                             return AlertDialog( // Dialog Box background color
//                                                               backgroundColor: Colors.white,
//                                                               surfaceTintColor: Colors.white,
//                                                               shape: RoundedRectangleBorder(
//                                                                 borderRadius: BorderRadius.circular(10),
//                                                               ),
//                                                               content: Container(
//                                                                 width: MediaQuery.of(context).size.width,
//                                                                 decoration: BoxDecoration(
//                                                                   borderRadius: BorderRadius.circular(10),
//                                                                   color: Colors.white,
//                                                                   // border: Border.all(
//                                                                   //     width: 0.5,
//                                                                   //     color: AppColors.navButtonColor
//                                                                   // ),
//                                                                 ),
//                                                                 child: SingleChildScrollView(
//                                                                   child: Column(
//                                                                     mainAxisSize: MainAxisSize.min,
//                                                                     children: [
//                                                                       Text('Selected Methods',style: TextStyle(
//                                                                           fontSize: 18,color: AppColors.blackColor
//                                                                       )),
//                                                                       ...calculationMethods.map((method) {
//                                                                         return CheckboxListTile(
//                                                                           title: Text(replaceUnderscoreWithSpace(method),style: TextStyle(color:AppColors.navColor),),
//                                                                           value: true,
//                                                                           activeColor: AppColors.navColor, // Color when checked
//                                                                           checkColor: Colors.white,
//                                                                           onChanged: (bool? value) {
//                                                                             if (value == false) {
//                                                                               setState(() {
//                                                                                 calculationMethods.remove(method);
//                                                                                 availableMethods.add(method);
//                                                                               });
//                                                                             }
//                                                                           },
//                                                                         );
//                                                                       }).toList(),
//                                                                       if (availableMethods.isNotEmpty) Divider(   color: AppColors.navOpacity,),
//                                                                       if (availableMethods.isNotEmpty) Text('Available Methods',style: TextStyle(
//                                                                           fontSize: 18,color: AppColors.blackColor
//                                                                       )),
//                                                                       ...availableMethods.map((method) {
//                                                                         return CheckboxListTile(
//                                                                           title: Text(replaceUnderscoreWithSpace(method),style: TextStyle(color:Colors.green),),
//                                                                           value: _selectedLicenseTypes.contains(method),
//                                                                           onChanged: (bool? value) {
//                                                                             setState(() {
//                                                                               if (value != null) {
//                                                                                 if (value) {
//                                                                                   _selectedLicenseTypes.add(method);
//                                                                                 } else {
//                                                                                   _selectedLicenseTypes.remove(method);
//                                                                                 }
//                                                                               }
//                                                                             });
//                                                                           },
//                                                                         );
//                                                                       }).toList(),
//                                                                     ],
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                               actions: <Widget>[
//                                                                 InkWell(
//                                                                   onTap: (){
//                                                                     setState(() {
//                                                                       _selectedLicenseTypes.clear();
//                                                                     });
//                                                                     Navigator.pop(context);
//                                                                   },
//                                                                   child: Container(
//                                                                     width: screenWidth*0.2,
//                                                                     color:  AppColors.navButtonColor,
//                                                                     child: Padding(
//                                                                       padding: const EdgeInsets.all(5.0),
//                                                                       child: Center(
//                                                                         child: Text(
//                                                                           'Close',
//                                                                           style:TextStyle(
//                                                                             color: Colors.white,
//                                                                             fontSize: 15,
//                                                                             fontWeight: FontWeight.w600,
//                                                                             letterSpacing:1,
//
//                                                                           ),
//                                                                         ),
//                                                                       ),
//                                                                     ),
//                                                                   ),
//                                                                 ),
//                                                                 InkWell(
//                                                                   onTap: (){
//                                                                     setState(() {
//                                                                       calculationMethods.addAll(_selectedLicenseTypes);
//                                                                       availableMethods.removeWhere((method) => _selectedLicenseTypes.contains(method));
//                                                                       PostDropDownData(slug, calculationMethods);
//                                                                       _selectedLicenseTypes.clear();
//                                                                     });
//                                                                     Navigator.pop(context);
//                                                                   },
//                                                                   child: Container(
//                                                                     width: screenWidth*0.3,
//                                                                     color:  AppColors.navOpacity,
//                                                                     child: Padding(
//                                                                       padding: const EdgeInsets.all(5.0),
//                                                                       child: Center(
//                                                                         child: Text(
//                                                                           'Save Changes',
//                                                                           style:TextStyle(
//                                                                             color: Colors.black,
//                                                                             fontSize: 15,
//                                                                             fontWeight: FontWeight.w600,
//                                                                             letterSpacing:1,
//                                                                           ),
//                                                                         ),
//                                                                       ),
//                                                                     ),
//                                                                   ),
//                                                                 ),
//
//                                                               ],
//                                                             );
//                                                           },
//                                                         );
//                                                       },
//                                                     );
//                                                   },
//                                                   child: Container(
//                                                     width: screenWidth * 0.90,
//                                                     child: Row(
//                                                       children: [
//                                                         Container(
//                                                           height: screenHeight * 0.06,
//                                                           width: screenWidth * 0.25,
//                                                           child: Align(
//                                                             alignment: Alignment.centerLeft,
//                                                             child: AutoSizeText(
//                                                               "Default Timesheet",
//                                                               style: TextStyle(
//                                                                 fontSize: 20,
//                                                                 fontWeight: FontWeight.w400,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                         SizedBox(width: screenWidth * 0.023,),
//                                                         Container(
//                                                           height: screenHeight * 0.03,
//                                                           width: 1,
//                                                           color: Colors.grey,
//                                                         ),
//                                                         SizedBox(width: screenWidth * 0.023,),
//                                                         Align(
//                                                           alignment: Alignment.centerLeft,
//                                                           child: calculationMethods.isEmpty
//                                                               ? Container(
//                                                               height: screenHeight*0.03,
//                                                               width: screenWidth*0.5,
//                                                               color: Colors.white,
//                                                               child:Row(
//                                                                 children: [
//                                                                   Align(
//                                                                       alignment: Alignment.centerLeft,
//                                                                       child: AutoSizeText("empty",style: TextStyle(
//                                                                           fontSize: 18,color: AppColors.blackColor.withOpacity(0.6)
//                                                                       ),)),
//                                                                   SizedBox(width: screenWidth * 0.029,),
//                                                                   Icon(Icons.tab_unselected),
//                                                                 ],
//                                                               )
//                                                           ) : Container(
//                                                             // height: screenHeight * (0.03* calculationMethods.length),
//                                                             width: screenWidth*0.5,
//                                                             // color: Colors.green,
//                                                             child: Row(
//                                                               children: [
//                                                                 Column(
//                                                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                                                   mainAxisAlignment: MainAxisAlignment.center,
//                                                                   children: calculationMethods.map((method) => AutoSizeText(
//                                                                     replaceUnderscoreWithSpace(method),
//                                                                     style: TextStyle(
//                                                                       fontSize: 15,
//                                                                       color: AppColors.blackColor.withOpacity(0.6),
//                                                                     ),
//                                                                   )).toList(),
//                                                                 ),
//                                                                 SizedBox(width: screenWidth*0.02,),
//                                                                 Icon(Icons.settings_applications_sharp,color: AppColors.navColor,),
//                                                               ],
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 SizedBox(height: screenHeight * 0.013,),
//                                                 // RowData("Document", doc),
//                                                 GestureDetector(
//                                                   onTap: (){
//                                                     final selectedSlug=ActiveClient[index].driverSlug!;
//                                                     Navigator.push(context, MaterialPageRoute(builder: (context)=>UploadFileClientfNew(slug:selectedSlug)));
//                                                  print("File View Slug -$selectedSlug");
//                                                   },
//                                                   child: Container(
//                                                     width: screenWidth*0.90,
//                                                     decoration: BoxDecoration(
//                                                       border: Border.all(
//                                                         color: Colors.white
//                                                       )
//                                                     ),
//                                                     child: Row(
//                                                       // mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                       children: [
//                                                         Container(
//                                                             height: screenHeight*0.03,
//                                                             width: screenWidth*0.25,
//
//                                                             child: Align(
//                                                                 alignment: Alignment.centerLeft,
//                                                                 child: AutoSizeText("Documents",style: TextStyle(
//                                                                     fontSize: 20,fontWeight: FontWeight.w400
//                                                                 ),))),
//                                                         SizedBox(width: screenWidth*0.023,),
//                                                         Container(
//                                                           height: screenHeight*0.03,
//                                                           width: 1,
//                                                           color: Colors.grey,
//                                                         ),
//                                                         SizedBox(width: screenWidth*0.023,),
//                                                         Container(
//                                                             height: screenHeight*0.03,
//                                                             width: screenWidth*0.35,
//                                                             child:Row(
//                                                               children: [
//                                                                 Align(
//                                                                     alignment: Alignment.centerLeft,
//                                                                     child: AutoSizeText("files",style: TextStyle(
//                                                                         fontSize: 18,color: AppColors.blackColor.withOpacity(0.6)
//                                                                     ),)),
//                                                                 SizedBox(width: screenWidth * 0.029,),
//                                                                 Icon(CupertinoIcons.rectangle_on_rectangle_angled),
//                                                               ],
//                                                             )
//                                                          ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 SizedBox(height: screenHeight * 0.01,),
//                                                 _rateDetails("Actions",  ActiveClient[index]),
//                                                 SizedBox(height: screenHeight * 0.013,),
//                                                 InkWell(
//                                                   onTap: (){
//                                                     final driversSlug=ActiveClient[index].driverSlug;
//                                                     final selectedEmail = ActiveClient[index].clients?.email;
//                                                     final selectedCompany =  ActiveClient[index].clients?.companyName;
//                                                     final selectedImage =  ActiveClient[index].clients?.image;
//                                                     final selectedStatus =  ActiveClient[index].clients?.status;
//                                                     Navigator.push(context, MaterialPageRoute(builder: (context) =>
//                                                         BulkApproveshowlist(
//                                                           driversSlug:driversSlug,
//                                                           email:selectedEmail,
//                                                           companyName:selectedCompany,
//                                                           images:selectedImage,
//                                                            status: selectedStatus
//                                                         ),),);
//                                                   },
//                                                   child: Align(
//                                                     alignment: Alignment.centerLeft,
//                                                     child: Container(
//                                                       height: screenHeight * 0.04,
//                                                       width: screenWidth*0.27,
//                                                       decoration: BoxDecoration(
//                                                         color: AppColors.navButtonColor
//                                                         ,
//                                                         borderRadius: BorderRadius.circular(5),
//                                                       ),
//                                                       child: Center(child: Text("Bulk Actions",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)),
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 SizedBox(height: screenHeight * 0.013,),
//                                               ],
//                                             ),
//                                           )
//                                         ],
//                                       ), // Replace YourChildWidget with your actual widget
//                                     ),
//                                     SizedBox(height: screenHeight * 0.023,),
//                                   ],
//                                 );
//                               } else {
//                                 return Container();
//                               }
//                             },
//                           );
//
//                         } else {
//                           return Container(
//                           height:screenHeight*0.5,
//                             child:Center(child: Text('Empty !!!')
//                           ),);
//                         }
//                       }
//                     },
//                   ),
//                 ),
//                 SizedBox(height: screenHeight*0.1,),
//               ],
//             ),
//           ),
//         ),
//       );
//     }
//
//   String getDepartmentName(String deptSlug, List<The0> departments) {
//     final department = departments.firstWhere((dept) => dept.slug == deptSlug, orElse: () => The0());
//     return department.deptName ?? "Unknown Department";
//   }
//
//
//     Widget RowData(String text, String text2){
//       final screenHeight = MediaQuery.of(context).size.height * 1;
//       final screenWidth = MediaQuery.of(context).size.width * 1;
//     return Container(
//       width: screenWidth*0.90,
//       child: Row(
//         // mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Container(
//               height: screenHeight*0.03,
//               width: screenWidth*0.25,
//
//               child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: AutoSizeText(text,style: TextStyle(
//                     fontSize: 20,fontWeight: FontWeight.w400
//                   ),))),
//           SizedBox(width: screenWidth*0.023,),
//           Container(
//             height: screenHeight*0.03,
//             width: 1,
//             color: Colors.grey,
//           ),
//           SizedBox(width: screenWidth*0.023,),
//           Container(
//               height: screenHeight*0.03,
//               child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: AutoSizeText(text2,style: TextStyle(
//                       fontSize: 18,color: AppColors.blackColor.withOpacity(0.6)
//                   ),))),
//         ],
//       ),
//     );
//     }
//
//   Widget RowDept(String text, String text2, List<The0> departments, String slug) {
//     final screenHeight = MediaQuery.of(context).size.height * 1;
//     final screenWidth = MediaQuery.of(context).size.width * 1;
//     final correspondingName = getDepartmentName(text2, departments);
//     List<String?> departmentNames = departments.map((department) => department.deptName).toList();
//     List <String?> departmentIDs = departments.map((department) => department.slug).toList();
//     departmentNames = departmentNames.toSet().toList();
//     return InkWell(
//       onTap: () {
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return StatefulBuilder(
//               builder: (context, setState) {
//                 return AlertDialog(
//                   backgroundColor: Colors.white,
//                   surfaceTintColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(5),
//                   ),
//                   title: Text('Select Department',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
//                   content: Container(
//                     width: MediaQuery.of(context).size.width,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(5),
//                       color: Colors.white,
//                       border: Border.all(
//                         width: 0.5,
//                         color: AppColors.navButtonColor
//                       ),
//                     ),
//                     child: DropdownButton<String>(
//                       hint: Padding(
//                         padding: const EdgeInsets.only(left: 13.0),
//                         child: Text("Select"),
//                       ),
//                       value: selectedDepartmentName,
//                       onChanged: (newValue) {
//                         setState(() {
//                           selectedDepartmentName = newValue!;
//                           selectedDepartmentID = departmentIDs[departmentNames.indexOf(newValue)]! ;
//                         });
//                       },
//                       items: <DropdownMenuItem<String>>[
//                         DropdownMenuItem<String>(
//                           value: 'Select',
//                           child: Padding(
//                             padding: const EdgeInsets.only(left: 13.0),
//                             child: Text("Select"),
//                           ),
//                         ),
//                         ...departmentNames.map((DeptName) {
//                           return DropdownMenuItem<String>(
//                             value: DeptName!,
//                             child: Padding(
//                               padding: const EdgeInsets.only(left: 13.0),
//                               child: Text(DeptName,),
//                             ),
//                           );
//                         }),
//                       ],
//                       icon: SizedBox(),
//                       underline: Container(),
//                     ),
//                   ),
//                   actions: <Widget>[
//
//                     InkWell(
//                       onTap:(){
//                         Navigator.of(context).pop();
//                       },
//                       child: Container(
//                       width: screenWidth*0.2,
//                         color:  AppColors.navButtonColor,
//                         child:  Padding(
//                           padding: const EdgeInsets.all(5.0),
//                           child: Center(
//                             child: Text('Cancel',
//                               style:TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.w600,
//                                 letterSpacing:1,
//
//                               ),),
//                           ),
//                         ),
//                       ),
//                     ),
//                     InkWell(
//                       onTap:(){
//                         AssignDept(selectedDepartmentID.toString(), slug);
//                         Navigator.of(context).pop();
//                       },
//                       child: Container(
//                         width: screenWidth*0.3,
//                         color:  AppColors.navOpacity,
//                         child:  Padding(
//                           padding: const EdgeInsets.all(5.0),
//                           child: Center(
//                             child: Text('Submit',
//                               style:TextStyle(
//                                 color: Colors.black,
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.w600,
//                                 letterSpacing:1,
//
//                               ),),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             );
//           },
//         );
//       },
//       child: Container(
//         width: screenWidth * 0.90,
//         child: Row(
//           children: [
//             Container(
//               height: screenHeight * 0.03,
//               width: screenWidth * 0.25,
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: AutoSizeText(text, style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w400,
//                 )),
//               ),
//             ),
//             SizedBox(width: screenWidth * 0.023,),
//             Container(
//               height: screenHeight * 0.03,
//               width: 1,
//               color: Colors.grey,
//             ),
//             SizedBox(width: screenWidth * 0.023,),
//             Container(
//               height: screenHeight * 0.03,
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: AutoSizeText(correspondingName, style: TextStyle(
//                   fontSize: 18,color: AppColors.blackColor.withOpacity(0.6)
//                 )),
//               ),
//             ),
//             SizedBox(width: screenWidth * 0.023,),
//             Icon(Icons.assistant_direction,color: Colors.grey,)
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _rateDetails(String text,Datum data) {
//     final screenHeight = MediaQuery.of(context).size.height * 1;
//     final screenWidth = MediaQuery.of(context).size.width * 1;
//     return Container(
//       width: screenWidth*0.90,
//       decoration: BoxDecoration(
//         color: Colors.transparent,
//       ),
//       child: Row(
//         children: [
//           Container(
//               height: screenHeight*0.03,
//               width: screenWidth*0.25,
//
//               child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: AutoSizeText(text,style: TextStyle(
//                       fontSize: 20,fontWeight: FontWeight.w400
//                   ),))),
//           SizedBox(width: screenWidth*0.023,),
//           Container(
//             height: screenHeight * 0.03,
//             width: 1,
//             color: Colors.grey,
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               SizedBox(width: screenWidth*0.023,),
//               // InkWell(
//               //   onTap: () {
//               //
//               //     final selectedSlug = '${data.slug}';
//               //     final selectedStartTime = '${data.startTime}';
//               //     final selectedEndTime = '${data.endTime}';
//               //     final selectedEmail = '${data.clients?.email}';
//               //     final selectedCompany = '${data.clients?.companyName}';
//               //     final selectedImage = '${data.clients?.image}';
//               //
//               //     print('Received data from IndividualView:${data.slug}');
//               //     print('Received data from IndividualView:${data.clients?.companyName}');
//               //     print('Received data from IndividualView: ${data.clients?.email}');
//               //     print('Received data from IndividualView: ${data.clients?.companyName}');
//               //     print('Received data from IndividualView: ${data.clients?.image}');
//               //     print('Received data from IndividualView:${data.slug}');
//               //
//               //
//               //
//               //     Navigator.push(
//               //       context,
//               //       MaterialPageRoute(
//               //         //ALl List View Data
//               //         builder: (context) => ActionListNew(slug: selectedSlug, StartTime: selectedStartTime,EndTime: selectedEndTime,email:selectedEmail,companyName:selectedCompany, images:selectedImage,),
//               //       ),
//               //     ).then((value) {
//               //       if (value != null) {
//               //         print('Received data from IndividualView: $value');
//               //       }
//               //     });
//               //   },
//               //   child: Icon(Icons.file_present,size: 28,color:AppColors.navColor,),
//               // ),
//               // SizedBox(width: screenWidth*0.023,),
//               // InkWell(
//               //   onTap: () {
//               //     final selectedSlug = '${data.slug}';
//               //     final selectedStartTime = '${data.startTime}';
//               //     final selectedEndTime = '${data.endTime}';
//               //     final selectedEmail = '${data.clients?.email}';
//               //     final selectedCompany = '${data.clients?.companyName}';
//               //     final selectedImage = '${data.clients?.image}';
//               //     final selectedBreak = '${data.clients?.breakTime}';
//               //     print('Received data from IndividualView:${data.slug}');
//               //     print('Received data from IndividualView:${data.clients?.companyName}');
//               //     print('Received data from IndividualView: ${data.clients?.email}');
//               //     print('Received data from IndividualView: ${data.clients?.companyName}');
//               //     print('Received data from IndividualView: ${data.clients?.image}');
//               //     print('Received data from IndividualView:${data.slug}');
//               //
//               //
//               //
//               //     Navigator.push(
//               //       context,
//               //       MaterialPageRoute(
//               //         //Just Action View Data
//               //         builder: (context) => AnotherActionListNew(slug: selectedSlug, stTime: selectedStartTime,enTime: selectedEndTime,email:selectedEmail,companyName:selectedCompany, images:selectedImage,breakTimes:selectedBreak),
//               //       ),
//               //     ).then((value) {
//               //       if (value != null) {
//               //         print('Received data from IndividualView: $value');
//               //       }
//               //     });
//               //   },
//               //   child: Icon(Icons.calculate_outlined,size: 28,color: AppColors.blackColor,),
//               // ),
//               // SizedBox(width: screenWidth*0.023,),
//               InkWell(
//                 onTap: () {
//                   final selectedSlug = '${data.slug}';
//                   final selectedStartTime = '${data.startTime}';
//                   final selectedEndTime = '${data.endTime}';
//
//
//
//                   final selecteddriverSlug = '${data.driverSlug}';
//                   final selectedEmail = '${data.clients?.email}';
//                   final selectedCompany = '${data.clients?.companyName}';
//                   final selectedImage = '${data.clients?.image}';
//                   final selectedBreak = '${data.clients?.breakTime}';
//                   print('Slug:$selecteddriverSlug');
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       //Just Action View Data
//                       builder: (context) => WeekDataClientListNew(slug: selectedSlug, stTime: selectedStartTime,enTime: selectedEndTime,driverSlug:selecteddriverSlug,email:selectedEmail,companyName:selectedCompany, images:selectedImage,breakTimes:selectedBreak),
//                     ),
//                   ).then((value) {
//                     if (value != null) {
//                       print('Received data from IndividualView: $value');
//                     }
//                   });
//                 },
//                 child: Icon(Icons.calendar_view_month_sharp,size: 25,),
//               ),
//               SizedBox(width: screenWidth*0.023,),
//               InkWell(
//                 onTap: () {
//                   final selectedID = '${data.drivers?.id}';
//                   print('Received data from IndividualView:${data.id}');
//
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       //Just Action View Data
//                       builder: (context) => ClientCalendar(id: selectedID, ),
//                     ),
//                   ).then((value) {
//                     if (value != null) {
//                       print('Received data from IndividualView: $value');
//                     }
//                   });
//                 },
//                 child: Icon(Icons.calendar_month,size: 25,color: Colors.green,),
//               ),
//
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//
//
// }
//
