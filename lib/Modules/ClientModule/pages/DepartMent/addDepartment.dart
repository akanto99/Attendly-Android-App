// import 'dart:async';
// import 'dart:convert';
//
// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:c9_app/DarkAndLightTheme/theme_provider.dart';
// import 'package:c9_app/Modules/ClientModule/client_screen.dart';
// import 'package:c9_app/Modules/ClientModule/pages/DepartMent/department.dart';
// import 'package:c9_app/netConnectivityScreen.dart';
// import 'package:c9_app/res/app_url.dart';
// import 'package:c9_app/res/color.dart';
// import 'package:c9_app/responsive/responsive_ui.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as https;
// import '../../../../utils/utils.dart';
//
//
// class ADDdepartent extends StatefulWidget {
//   const ADDdepartent({super.key});
//
//   @override
//   State<ADDdepartent> createState() => _ADDdepartentState();
// }
//
// class _ADDdepartentState extends State<ADDdepartent> {
//
//   TextEditingController _depName = TextEditingController();
//   TextEditingController _location = TextEditingController();
//   TextEditingController _details = TextEditingController();
//   Map<String, String> _validationErrors = {};
//   String _responsibilitiesValidationError = '';
//   String _deptNameValidationError = '';
//   String _LocationValidationError = '';
//
//   Future<void> _PostDept() async {
//     setState(() {
//       isLoading = true; // Set loading state to true
//     });
//      _deptNameValidationError = '';
//      _LocationValidationError = '';
//      _responsibilitiesValidationError = '';
//
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String _token = prefs.getString('token') ?? '';
//
//     try {
//       String apiUrl = '${AppUrl.baseUrl}/api/app/department/store';
//       var request = https.MultipartRequest('POST', Uri.parse(apiUrl));
//       request.headers.addAll({
//         'Authorization': 'Bearer $_token',
//         'Accept': 'application/json',
//       });
//
//
//       request.fields['dept_name'] = _depName.text.toString();
//       request.fields['location'] = _location.text.toString();
//       request.fields['details'] = _details.text.toString();
//
//       var response = await request.send();
//
//       if (response.statusCode == 200) {
//         print('Registration Successful');
//         setState(() {
//           isLoading = false; // Set loading state to false after successful request
//         });
//         _depName.clear();
//         _location.clear();
//         _details.clear();
//         Utils.flushBarSuccessMessage("Data Submit Successfully", context);
//       } else if (response.statusCode == 422) {
//         // Parse and handle validation error response
//         final Map<String, dynamic> responseData = jsonDecode(await response.stream.bytesToString());
//         if (responseData.containsKey('errors')) {
//           final Map<String, dynamic> errors = responseData['errors'];
//           errors.forEach((field, messages) {
//             final String errorMessage = messages.isNotEmpty ? messages.first : 'Unknown error';
//             switch (field) {
//               case 'dept_name':
//                 _deptNameValidationError = errorMessage;
//                 break;
//               case 'location':
//                 _LocationValidationError = errorMessage;
//                 break;
//               case 'details':
//                 _responsibilitiesValidationError = errorMessage;
//                 break;
//             }
//           });
//
//           // Show error messages to the user
//           setState(() {
//             _validationErrors = {
//               'dept_name': _deptNameValidationError,
//               'location': _LocationValidationError,
//               'details': _responsibilitiesValidationError,
//             };
//             isLoading = false;
//           });
//           Utils.flushBarErrorMessage('Please fill all the rquired field', context);
//         } else {
//           Utils.flushBarErrorMessage('Please fill all the rquired field', context);
//           setState(() {
//             isLoading = false;
//           });
//         }
//       }else {
//         setState(() {
//           isLoading = false;
//         });
//         print('Failed to register. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       print('Error during registration: $e');
//     }
//   }
//
//   bool isLoading = false;
//
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: ResPonsiveUi(
//           mobile: body(),
//           desktop: body(),
//           tablet: body(),
//         ),
//       ),
//     );
//   }
//
//   Widget body() {
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     final screenWidth = MediaQuery.of(context).size.width * 1;
//     final screenHeight = MediaQuery.of(context).size.height * 1;
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(15.0),
//         child: Column(
//           children: [
//             Align(alignment: Alignment.centerLeft,
//                 child: Text("Create New Department",
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),)),
//             SizedBox(height: screenHeight * 0.013,),
//
//         SingleHeader(context: context,  text: 'Depart. Name',HintText:"enter department name", controllers: _depName, keyboard: TextInputType.text, iconData: Icons.account_balance_wallet_outlined,),
//             if ( _deptNameValidationError.isNotEmpty)
//               Align(
//                 alignment: Alignment.topLeft,
//                 child: Text( _deptNameValidationError,
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.red,
//                   ),),
//               ),
//
//             SizedBox(height: screenHeight * 0.013,),
//             SingleHeader(text: 'Location',HintText:"enter location", context: context, controllers: _location, keyboard: TextInputType.text, iconData: Icons.location_on,),
//             if ( _LocationValidationError.isNotEmpty)
//               Align(
//                 alignment: Alignment.topLeft,
//                 child: Text( _LocationValidationError,
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.red,
//                   ),),
//               ),
//
//             SizedBox(height: screenHeight * 0.013,),
//
//             Row(
//               children: [
//                 Align(alignment:Alignment.centerLeft,child: Text("Responsibility", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),)),
//                 Text(
//                   ' *',
//                   style:
//                   TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
//                 ),
//               ],
//             ),
//             SizedBox(height: screenHeight * 0.013,),
//             Container(
//               height: screenHeight * 0.15,
//               width: screenWidth * 0.95,
//               decoration: BoxDecoration(
//                 border: Border.all(color:  AppColors.navButtonColor,width: 0.4),
//                 borderRadius: BorderRadius.circular(5),
//               ),
//               child: TextFormField(
//                 controller: _details,
//                 keyboardType: TextInputType.multiline,
//                 maxLines: null,
//                 decoration: InputDecoration(
//                   contentPadding: EdgeInsets.symmetric(horizontal: 16,vertical: 10),
//                   prefixIcon: Icon(Icons.edit,size: 20,),
//                   border: InputBorder.none,
//                   hintText: "enter responsibilities",
//                   hintStyle: TextStyle(fontSize: 14),
//                   enabledBorder: InputBorder.none,
//                   focusedBorder: InputBorder.none,
//                 ),
//               ),
//             ),
//             if ( _responsibilitiesValidationError.isNotEmpty)
//               Align(
//                 alignment: Alignment.topLeft,
//                 child: Text( _responsibilitiesValidationError,
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.red,
//                   ),),
//               ),
//             SizedBox(height: screenHeight * 0.013,),
//
//             InkWell(
//               onTap: () async {
//                 await _PostDept();
//               },
//               child: Container(
//                 height: screenHeight * 0.055,
//                 width: screenWidth * 0.3,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10),
//                   color:  AppColors.navButtonColor,
//                   // Colors.black,
//                   // Color(0xff078C79),
//                   border: Border.all(
//                     width: 0.2,
//                     color:   AppColors.greyOpacity,
//                     // Color(0xff078C79),
//                   ),
//                 ),
//                 child: Center(
//                   child: isLoading
//                       ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white,)) // Show loading indicator if isLoading is true
//                       : Text("Submit", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1,),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: screenHeight * 0.1),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget SingleHeader({
//     String? text,
//     required BuildContext context,
//     required TextEditingController controllers,
//     required TextInputType keyboard,
//     IconData? iconData,
//     String ? HintText,
//   }) {
//     final screenWidth = MediaQuery.of(context).size.width * 1;
//     final screenHeight = MediaQuery.of(context).size.height * 1;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//        Row(
//          children: [
//            if (text != null) // Only add the Text widget if text is provided
//              AutoSizeText(
//                text,
//                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
//              ),
//            Text(
//              ' *',
//              style:
//              TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
//            ),
//          ],
//        ),
//         SizedBox(height: screenHeight * 0.013,),
//         Container(
//           // height: screenHeight * 0.065,
//           width: screenWidth * 0.95,
//           decoration: BoxDecoration(
//             border: Border.all(color:  AppColors.navButtonColor,width: 0.4),
//             borderRadius: BorderRadius.circular(5),
//           ),
//           child: TextFormField(
//             controller: controllers,
//             keyboardType: keyboard,
//             // textAlign: TextAlign.left,
//               decoration: InputDecoration(
//               prefixIcon: Icon(iconData,size: 20,),
//               border: InputBorder.none,
//               hintText: HintText,
//               hintStyle: TextStyle(fontSize: 14),
//               contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
//               enabledBorder: InputBorder.none,
//               focusedBorder: InputBorder.none,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//
//
//   Widget HeaderRow(IconData iconData) {
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     final screenWidth = MediaQuery.of(context).size.width * 1;
//     final screenHeight = MediaQuery.of(context).size.height * 1;
//     return Container(
//       height: screenHeight * 0.055,
//       width: screenWidth * 0.12,
//       decoration: BoxDecoration(
//         color:  AppColors.whiteColor,
//        shape: BoxShape.circle,
//         boxShadow: [
//           BoxShadow(
//             color: themeProvider.isDarkMode ? AppColors.blackOpacity: AppColors.greyOpacity,
//             offset: Offset(0, 2),
//             blurRadius: 10,
//             spreadRadius: 2,
//           ),
//         ],
//       ),
//       child: Icon(iconData,color:  AppColors.navColor,),
//     );
//   }
// }
