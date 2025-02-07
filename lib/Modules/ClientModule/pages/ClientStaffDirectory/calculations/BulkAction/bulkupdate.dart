import 'dart:convert';

import 'package:c9_app/Modules/ClientModule/model/clientDirectoryModel/calculationModels/BulkActionModel/bulkaction_model.dart';
import 'package:c9_app/loadingScreen.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as https;

class UpdateBulk extends StatefulWidget {
  final String bulkSlug;
  final dynamic ID;
  final String driverslug;
  const UpdateBulk({super.key,required this.bulkSlug,required this.ID,required this.driverslug});

  @override
  State<UpdateBulk> createState() => _UpdateBulkState();
}

class _UpdateBulkState extends State<UpdateBulk> {

   bool _isUploading = false;
   List<Calculation> bulkList = [];
   dynamic selectedId;

   Map<String, String> _validationErrors = {};
   TextEditingController _dateControllers =TextEditingController();
   TextEditingController _dayTimeControllers = TextEditingController();
   TextEditingController  _nightTimeControllers = TextEditingController();
   TextEditingController  _expensesControllers = TextEditingController();
   TextEditingController  _totalControllers = TextEditingController();
   TextEditingController _updateController = TextEditingController();

  late Future<BulkActionModel> _userBulkEdit;


   Future<BulkActionModel> getData() async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
     String _token = prefs.getString('token') ?? '';
     final String apiUrl = '${AppUrl.baseUrl}/api/app/client-bulk-managment-extension-all-pending-data';

     final requestBody = {
       'driver_slug': widget.driverslug,
     };

     print('Request Body: ${jsonEncode(requestBody)}'); // Print the request body

     final response = await https.post(
       Uri.parse(apiUrl),
       headers: {
         'Content-Type': 'application/json',
         'Authorization': 'Bearer $_token',
       },
       body: jsonEncode(requestBody),
     );
     if (response.statusCode == 200) {
       final Map<String, dynamic> responseData = json.decode(response.body);
       final BulkActionModel bulkView = BulkActionModel.fromJson(responseData);

       setState(() {
         bulkList = bulkView.calculations ?? [];
         Calculation? selectedDetails = bulkList.firstWhere((details) => widget.ID == details.id);
         if (selectedDetails != null) {
           _dateControllers.text = "${selectedDetails.date ?? ""}";
           _totalControllers.text = "${selectedDetails.totalCharge ?? ""}";
           _expensesControllers.text = "${selectedDetails.expenses ?? ""}";
           _dayTimeControllers.text = "${selectedDetails.dayShiftTime ?? ""}";
           _nightTimeControllers.text = "${selectedDetails.nightShiftTime ?? ""}";
           _updateController.text = "${selectedDetails.cancelReason ?? ""}";
         }
       });
       return bulkView;
     } else {
       print('Request failed with status: ${response.statusCode}');
       throw Exception('Failed to load data');
     }
   }
   @override
   void initState() {
     super.initState();
     _userBulkEdit = getData();
   }
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
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
              Text(
                "Update Details",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: HeaderRow(Icons.home),
              ),
            ],
          ),
        ),
        body: ResPonsiveUi(
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
          // Text("Assign id: ${widget.ID ?? ''}"),
          FutureBuilder<BulkActionModel>(
            future: _userBulkEdit,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: screenHeight * 0.8,
                  width: screenWidth,
                  color: AppColors.whiteColor,
                  child: LoadingScreen(),
                );
              } else if (snapshot.hasError) {
                // return Center(child: Text('Error: ${snapshot.error}'));
                return Center(child: Text(''));
              } else if (snapshot.hasData) {
                BulkActionModel data = snapshot.data!;

                return Column(
                  children: [
                    Container(
                      width: screenWidth * 0.95,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [

                          // Text("Assign Slug: ${data.assignSlug ?? ''}"),
                          // Text("Assign id: ${data.mCalculationId ?? ''}"),

                          Center(
                            child: Container(
                              width: screenWidth * 0.95,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    offset: Offset(0, 3),
                                    blurRadius: 5,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        doubleContainer(
                                          title: "Date",
                                          controller: _dateControllers,
                                          keyboardType: TextInputType.name,
                                          errorMessage: _validationErrors['date'],
                                        ),
                                        doubleContainer(
                                          title: "Total Amount",
                                          controller: _totalControllers,
                                          keyboardType: TextInputType.name,
                                          errorMessage: _validationErrors['totalExpense'],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenHeight * 0.002),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        singleContainer(
                                          title: "Expense",
                                          controller: _expensesControllers,
                                          keyboardType: TextInputType.name,
                                          errorMessage: _validationErrors['expenses'],
                                        ),
                                        singleContainer(
                                          title: "Day Hour",
                                          controller: _dayTimeControllers,
                                          keyboardType: TextInputType.name,
                                          errorMessage: _validationErrors['dayHour'],
                                        ),
                                        singleContainer(
                                          title: "Night Hour",
                                          controller: _nightTimeControllers,
                                          keyboardType: TextInputType.name,
                                          errorMessage: _validationErrors['nightHour'],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.013),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                height: screenHeight * 0.11,
                                width: screenWidth * 0.60,
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.navButtonColor, width: 0.8),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: TextFormField(
                                  controller: _updateController,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(fontSize: 14),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    prefixIcon: Icon(Icons.edit, size: 20),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  Text("Update Reason", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                  SizedBox(height: screenHeight * 0.015),
                                  InkWell(
                                    // onTap: () async {
                                    //   if (_updateController.text.isNotEmpty) {
                                    //     final slug = data.assignSlug ?? '';
                                    //     final mID = data.mCalculationId ?? '';
                                    //     _updateManual(slug, mID, data.data!);
                                    //   } else {
                                    //     Utils.flushBarErrorMessage("Update reason must be required", context);
                                    //   }
                                    // },
                                    child: Container(
                                      height: screenHeight * 0.04,
                                      width: screenWidth * 0.25,
                                      decoration: BoxDecoration(
                                        color: AppColors.navButtonColor,
                                        borderRadius: BorderRadius.circular(5),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.2),
                                            offset: Offset(0, 2),
                                            blurRadius: 5,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: _isUploading
                                            ? SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                            ))
                                            : Text(
                                          "Update",
                                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.1),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return Center(child: Text('No data available'));
              }
            },
          ),


        ],
      ),
    );}

  Widget HeaderRow(IconData iconData) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
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
      child: Icon(iconData, color: AppColors.navColor),
    );
  }

  Widget singleContainer({
    required TextEditingController controller,
    required TextInputType keyboardType,
    String? errorMessage,
    required String title,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        Container(
          height: screenHeight * 0.05,
          width: screenWidth * 0.29,
          child: Align(
            alignment: Alignment.center,
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.navButtonColor.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
        if (errorMessage != null && errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                errorMessage,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget doubleContainer({
    required TextEditingController controller,
    required TextInputType keyboardType,
    String? errorMessage,
    required String title,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        Container(
          height: screenHeight * 0.05,
          width: screenWidth * 0.44,
          decoration: BoxDecoration(
            color: AppColors.navOpacity,
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: AppColors.navButtonColor.withOpacity(0.4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            readOnly: true,
          ),
        ),
        if (errorMessage != null && errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                errorMessage,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
