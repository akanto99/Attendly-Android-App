import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:c9_app/Modules/ClientModule/client_screen.dart';
import 'package:c9_app/Modules/ClientModule/model/clientDirectoryModel/calculationModels/BulkActionModel/bulkaction_model.dart';
import 'package:c9_app/Modules/ClientModule/pages/noInternetConnectionWidget.dart';
import 'package:c9_app/loadingScreen.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/view/widgets/header_widgets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as https;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../utils/utils.dart';

class BulkApproveshowlist extends StatefulWidget {
  final String? driversSlug;
  final String? email;
  final String? companyName;
  final String? images;
  final String? status;
  const BulkApproveshowlist({
    super.key,
    required this.driversSlug,
    required this.email,
    required this.companyName,
    required this.images,
    required this.status,
  });
  @override
  State<BulkApproveshowlist> createState() => _BulkApproveshowlistState();
}

class _BulkApproveshowlistState extends State<BulkApproveshowlist> {
  bool _isUploading = false;
  TextEditingController cancelController = TextEditingController();
  Map<String, String> _validationErrors = {};
  late Future<BulkActionModel?> _bulkDetailsFuture;
  final MultiSelectController<Calculation> controller = MultiSelectController<Calculation>();
  List<Calculation> bulkList = [];
  String? selectedDriver;
  String? selectedYear;

  bool get showButtons => controller.selectedItems.isNotEmpty;
  bool selectionMode = false;

  bool _showNoInternetConnectionMessage = false;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  List<String> generateYears() {
    int currentYear = DateTime.now().year;
    return List<String>.generate(6, (index) => (currentYear - index).toString());
  }

  String? selectedMonth;
  final Map<String, int> monthMapping = {
    'January': 1,
    'February': 2,
    'March': 3,
    'April': 4,
    'May': 5,
    'June': 6,
    'July': 7,
    'August': 8,
    'September': 9,
    'October': 10,
    'November': 11,
    'December': 12,
  };
  List<String> generateMonths() {
    return monthMapping.keys.toList();
  }

  bool selectAll = false;

  void _onSelectAllChanged(bool? value) {
    setState(() {
      selectAll = value ?? false;
      if (selectAll) {
        controller.setSelectedItems(bulkList);
      } else {
        controller.clearSelection();
      }
    });
  }

  void _onLongPress(int index) {
    setState(() {
      controller.selectItem(bulkList[index]);
      selectionMode = true;
      selectAll = controller.selectedItems.length == bulkList.length;
    });
  }

  // void _onItemTap(int index) {
  //   if (selectionMode) {
  //     setState(() {
  //       controller.toggleSelection(bulkList[index]);
  //       if (controller.selectedItems.isEmpty) {
  //         selectionMode = false;
  //       }
  //     });
  //   } else {
  //     print("Normal tap action");
  //   }
  // }
//   bool selectAll = false;
//
  void _onItemTap(int index) {
    if (selectionMode) {
      setState(() {
        controller.toggleSelection(bulkList[index]);
        if (controller.selectedItems.isEmpty) {
          selectionMode = false;
        }
        selectAll = controller.selectedItems.length == bulkList.length;
      });
    } else {
      print("Normal tap action");
    }
  }

  void _onCancel(String reason) async {
    List<String> selectedItems = controller.selectedItems.map((item) => item.id.toString()).toList();
    print('Declined items id: $selectedItems');
    List<Map<String, dynamic>> bulkUpdateRequests = selectedItems
        .map((id) => {
              "calculation_ids": [id],
              "status": "Decline",
              "declineReason": reason,
            })
        .toList();
    for (var requestBody in bulkUpdateRequests) {
      await _postBulk(requestBody);
      print(_postBulk(requestBody));
    }
    _clearSelection();
    Navigator.pop(context);
    Navigator.pop(context);
  }

  void _clearSelection() {
    setState(() {
      controller.clearSelection();
      selectionMode = false;
    });
  }

  TextEditingController _dateControllers = TextEditingController();
  TextEditingController _dayTimeControllers = TextEditingController();
  TextEditingController _nightTimeControllers = TextEditingController();
  TextEditingController _expensesControllers = TextEditingController();
  TextEditingController _totalControllers = TextEditingController();
  TextEditingController _updateController = TextEditingController();

  Future<void> _updateManual(String slug, dynamic mID, List<Calculation> data) async {
    Utils.showDialogLoading(context);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String _token = prefs.getString('token') ?? '';
      final String apiUrl = '${AppUrl.baseUrl}/api/app/client/update/calculation/store/$slug';
      https.MultipartRequest request = https.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers.addAll({
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
      });
      print("---------$slug");
      print('assign_slug:------------------ $slug');
      print('reason:----------------- ${_updateController.text}');
      request.fields['assign_slug'] = slug;
      request.fields['cancelReason'] = _updateController.text;

      for (int i = 0; i == 0; i++) {
        request.fields['id[$i]'] = mID.toString();
        request.fields['date[$i]'] = _dateControllers.text;
        request.fields['day_shift_time[$i]'] = _dayTimeControllers.text;
        request.fields['night_shift_time[$i]'] = _nightTimeControllers.text;
        request.fields['total_charge[$i]'] = _totalControllers.text;
        request.fields['expenses[$i]'] = _expensesControllers.text;

        print('id[$i]: $mID');
        print('date[$i]: ${_dateControllers.text}');
        print('day_shift_time[$i]: ${_dayTimeControllers.text}');
        print('night_shift_time[$i]: ${_nightTimeControllers.text}');
        print('total_charge[$i]: ${_totalControllers.text}');
        print('expenses[$i]: ${_expensesControllers.text}');
      }

      final response = await request.send();
      if (response.statusCode == 200) {
        print('Update Successful');
        print('Response body: ${await response.stream.bytesToString()}');
        Utils.flushBarSuccessMessage('Data Updated Successfully', context);

        Future.delayed(Duration(seconds: 2), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BulkApproveshowlist(
                driversSlug: widget.driversSlug,
                email: widget.email,
                companyName: widget.companyName,
                images: widget.images,
                status: widget.status,
              ),
            ),
          );
        });
      } else {
        Navigator.pop(context);
        Utils.flushBarErrorMessage(
            'Failed to update data.'
            // ' Status code: ${response.statusCode}'
            ,
            context);
      }
    } catch (e) {
      print('Error during data submission: $e');
      Navigator.pop(context);
      Utils.flushBarErrorMessage('An error occurred during updating', context);
    }
  }

  void _onApprove() async {
    Utils.showDialogLoading(context);
    List<String> selectedItems = controller.selectedItems.map((item) => item.id.toString()).toList();
    print('Approved items id: $selectedItems');
    List<Map<String, dynamic>> bulkUpdateRequests = selectedItems
        .map((id) => {
              "calculation_ids": [id],
              "status": "Approved",
            })
        .toList();
    for (var requestBody in bulkUpdateRequests) {
      await _postBulk(requestBody); // Ensure this is awaited
      print(_postBulk(requestBody));
    }
    _clearSelection();
    Navigator.pop(context);
  }

  Future<void> _postBulk(Map<String, dynamic> requestBody) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';
    final String apiUrl = '${AppUrl.baseUrl}/api/app/weekly-data-details-merge';

    final response = await https.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: jsonEncode(requestBody),
    );
    if (response.statusCode == 200) {
      print('API Response: ${response.body}');
      setState(() {
        _bulkDetailsFuture = fetchBulkDetails();
        selectAll = false;
      });
    } else {
      print('Request failed with status: ${response.statusCode}');
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    _bulkDetailsFuture = fetchBulkDetails();
    _refreshData();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) async {
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

  Future<void> _refreshData() async {
    setState(() {
      _bulkDetailsFuture = fetchBulkDetails();
    });
  }

  Future<BulkActionModel?> fetchBulkDetails() async {
    // first check user's network connectivity
    var connectivityResult = await (Connectivity().checkConnectivity());
    bool hasInternet = await _hasInternetConnection();

    if (connectivityResult == ConnectivityResult.none || !hasInternet) {
      // show No internet connection
      setState(() {
        _showNoInternetConnectionMessage = true;
      });
      return null;
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String _token = prefs.getString('token') ?? '';
      final String apiUrl = '${AppUrl.baseUrl}/api/app/client-bulk-managment-extension-all-pending-data';

      final requestBody = {
        'driver_slug': widget.driversSlug,
        'year': selectedYear,
        // 'month': selectedMonth,
        'month': selectedMonth != null ? monthMapping[selectedMonth].toString() : null,
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
        print('API Response: ${response.body}');
        print('API Response: ${widget.driversSlug}');
        return bulkActionModelFromJson(response.body);
      } else {
        print('Request failed with status: ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: _showNoInternetConnectionMessage ? Colors.red : AppColors.navColor,
    ));
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ClientCurveNabBar()),
        );
        return false;
      },
      child: SafeArea(
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ClientCurveNabBar()),
                    );
                  },
                  child: HeaderRow(Icons.arrow_back),
                ),
                Text(
                  "Bulk Action",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (showButtons) ...[
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: _onApprove,
                      ),
                      SizedBox(
                        width: screenWidth * 0.02,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.cancel,
                          color: Colors.red,
                        ),
                        onPressed: _showCancelReasonDialog,
                      ),
                    ],
                  )
                ] else ...[
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ClientCurveNabBar()),
                      );
                    },
                    child: HeaderRow(Icons.home),
                  ),
                ],
              ],
            ),
          ),
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
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: FutureBuilder<BulkActionModel?>(
        future: _bulkDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: screenHeight * 0.75,
              width: screenWidth,
              color: AppColors.whiteColor,
              child: LoadingScreen(),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text(""));
            // return Center(child: Text("${snapshot.error}"));
          } else if (snapshot.hasData && snapshot.data != null) {
            // Proceed with displaying the data
            bulkList = snapshot.data!.calculations!;
            List<Staff> staffList = snapshot.data!.staffs!;
            String? responsi = widget.companyName;
            if (responsi!.length > 25) {
              responsi = '${responsi.substring(0, 25)}...';
            }

            BulkActionModel data = snapshot.data!;

            return Column(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: screenHeight * 0.07,
                                width: screenWidth * 0.15,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: NetworkImage(
                                        "${AppUrl.clientUsers}/${widget.images}",
                                      ),
                                      fit: BoxFit.cover),
                                  color: AppColors.navOpacity,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(
                                width: screenWidth * 0.02,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                      onTapUp: (details) {
                                        String? responsi = widget.companyName;
                                        if (responsi != null) {
                                          _showFullNamePopup(context, responsi, details.globalPosition);
                                        }
                                      },
                                      child: Text(
                                        "$responsi",
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                      )),
                                  Text(
                                    "${widget.email}",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.005,
                    ),
                    Container(
                      height: screenHeight * 0.06,
                      width: screenWidth * 0.95,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: AppColors.navButtonColor,
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Checkbox(
                              hoverColor: Colors.white,
                              side: BorderSide(color: Colors.white, width: 2.0),
                              value: selectAll,
                              onChanged: _onSelectAllChanged,
                            ),
                            Container(
                              width: screenWidth * 0.39,
                              height: screenHeight * 0.05,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.white,
                                border: Border.all(width: 0.5, color: AppColors.navButtonColor),
                              ),
                              child: Center(
                                child: DropdownButton<String>(
                                  hint: Text("Year"),
                                  value: selectedYear,
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedYear = newValue;
                                      _refreshData();
                                    });
                                  },
                                  items: generateYears().map((String year) {
                                    return DropdownMenuItem<String>(
                                      value: year,
                                      child: Text(year),
                                    );
                                  }).toList(),
                                  underline: Container(),
                                ),
                              ),
                            ),
                            Container(
                              width: screenWidth * 0.39,
                              height: screenHeight * 0.05,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.white,
                                border: Border.all(width: 0.5, color: AppColors.navButtonColor),
                              ),
                              child: Center(
                                child: DropdownButton<String>(
                                  hint: Text("Month"),
                                  value: selectedMonth,
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedMonth = newValue;
                                      _refreshData();
                                    });
                                  },
                                  items: generateMonths().map((String month) {
                                    return DropdownMenuItem<String>(
                                      value: month,
                                      child: Text(month),
                                    );
                                  }).toList(),
                                  underline: Container(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: screenHeight * 0.013,
                ),
                Container(
                  width: screenWidth * 0.97,
                  child: bulkList.isEmpty
                      ? Container(
                          height: screenHeight * 0.7,
                          width: screenWidth,
                          color: AppColors.whiteColor,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.data_exploration_outlined,
                                      size: 40, color: AppColors.navButtonColor), // Warning icon
                                  SizedBox(height: 10),
                                  Text(
                                    'No Data Available',
                                    style:
                                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navColor),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'It seems there is no data to display at this moment.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                  ),
                                  SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () {
                                      _refreshData(); // Retry fetching data
                                    },
                                    child: Text(
                                      'Try again',
                                      style: TextStyle(color: Colors.black38),
                                    ),
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.navOpacity),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: bulkList.length,
                          itemBuilder: (context, index) {
                            var dayDetails = bulkList[index];
                            String? daysName = dayDetails.daysName ?? "";
                            String shortdaysName = daysName;
                            if (daysName != null && daysName.length > 15) {
                              shortdaysName = '${daysName.substring(0, 15)}...';
                            }
                            String formattedDate = '';
                            String? date = dayDetails.date;
                            if (date != null && date != 'No') {
                              DateTime parsedDate = DateTime.parse(date);
                              formattedDate =
                                  '${parsedDate.day.toString().padLeft(2, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.year}';
                            }
                            String? status = dayDetails.status ?? "";

                            return Column(
                              children: [
                                GestureDetector(
                                  onLongPress: () => _onLongPress(index),
                                  onTap: () => _onItemTap(index),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: controller.isSelected(bulkList[index])
                                          ? AppColors.navButtonColor.withOpacity(0.1)
                                          : AppColors.whiteColor,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: controller.isSelected(dayDetails)
                                            ? AppColors.navButtonColor.withOpacity(0.1)
                                            // :Colors.blue,
                                            : AppColors.greyOpacity,
                                      ),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 0),
                                        title: Padding(
                                          padding: EdgeInsets.zero,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Container(
                                                width: screenWidth * 0.07,
                                                // color: Colors.green,
                                                child: Checkbox(
                                                  value: controller.isSelected(dayDetails),
                                                  hoverColor: Colors.black,
                                                  side: BorderSide(
                                                    color: Colors.indigo,
                                                    width: 2.0,
                                                  ),
                                                  onChanged: (bool? value) {
                                                    if (value != null) {
                                                      setState(() {
                                                        controller.toggleSelection(dayDetails);
                                                        selectAll = controller.selectedItems.length == bulkList.length;
                                                      });
                                                    }
                                                  },
                                                ),
                                              ),

                                              Container(
                                                  width: screenWidth * 0.2,
                                                  height: screenHeight * 0.04,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.greyOpacity,
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
                                                  child: Center(
                                                      child: Text(
                                                    formattedDate,
                                                    style: TextStyle(
                                                        fontSize: 13, color: Colors.black, fontWeight: FontWeight.w400),
                                                  ))),

                                              GestureDetector(
                                                onTapUp: (details) {
                                                  if (daysName != null) {
                                                    _showFullNamePopup(context, daysName, details.globalPosition);
                                                  }
                                                },
                                                child: Container(
                                                  width: screenWidth * 0.3,
                                                  height: screenHeight * 0.04,
                                                  // decoration: BoxDecoration(
                                                  //   color: Color(0xffFAFAFA),
                                                  //   borderRadius: BorderRadius.circular(4),
                                                  // ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.greyOpacity,
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      shortdaysName ?? '',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.black,
                                                          fontWeight: FontWeight.w400),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              Container(
                                                height: screenHeight * 0.04,
                                                width: screenWidth * 0.15,
                                                decoration: BoxDecoration(
                                                  color: AppColors.greyOpacity,
                                                  borderRadius: BorderRadius.circular(5),
                                                ),
                                                child: Center(
                                                  child: AutoSizeText(
                                                    '${(double.parse(dayDetails.hours ?? '0')).toStringAsFixed(2)} H',
                                                    style: TextStyle(
                                                        fontSize: 12, fontWeight: FontWeight.w400, color: Colors.black),
                                                  ),
                                                ),
                                              ),

                                              // Container(
                                              //   height: screenHeight * 0.04,
                                              //   // width: screenWidth * 0.10,
                                              //   // color: Colors.red,
                                              //   child: Center(
                                              //     child: Row(
                                              //       children: [
                                              //         if (status == "Pending") // Check status for Approved
                                              //           Icon(Icons.watch_later_outlined, color: Colors.green, size: 20),
                                              //         SizedBox(width: screenWidth * 0.01),
                                              //         if (status =="Decline") // Check status for Decline
                                              //           Icon(Icons.cancel, color: Colors.red, size: 20),
                                              //       ],
                                              //     ),
                                              //   ),
                                              // ),
                                              GestureDetector(
                                                  onTap: () {
                                                    _showDetailsModalBottomSheet(context, bulkList, dayDetails.id);
                                                  },
                                                  child: Container(
                                                      height: screenHeight * 0.04,
                                                      // width: screenWidth * 0.005,
                                                      // color: Colors.purpleAccent,
                                                      child: Center(
                                                          child: Icon(
                                                        Icons.info_outline,
                                                        size: 20,
                                                        color: Colors.black,
                                                      )))),
                                              SizedBox(width: screenWidth * 0.01),
                                              InkWell(
                                                // onTap:(){
                                                //   final AssignSlug=dayDetails.assignmentSlug;
                                                //   final AssignId=dayDetails.id;
                                                //   print("ID $AssignId");
                                                //   String DriverSllug=widget.driversSlug?? "";
                                                //   print("Test Slug $AssignSlug");
                                                //   Navigator.push(context, MaterialPageRoute(builder: (context)=>UpdateBulk(bulkSlug:AssignSlug,ID:AssignId,driverslug:DriverSllug)));
                                                // },
                                                onTap: () {
                                                  _showAlertBulkUpdate(context, bulkList, dayDetails.id);
                                                },
                                                child: Container(
                                                  height: screenHeight * 0.04,
                                                  // width: screenWidth * 0.10,
                                                  // color: Colors.red,
                                                  child: Center(
                                                    child: Row(
                                                      children: [
                                                        if (status == "Pending" ||
                                                            status == "Updated") // Check status for Approved
                                                          SvgPicture.asset(
                                                            'images/staff/editsvg.svg',
                                                            height: 25,
                                                            width: 25,
                                                            color: status == "Pending"
                                                                ? AppColors.pending
                                                                : status == "Updated"
                                                                    ? Colors.blue
                                                                    : Colors.black,
                                                          ),
                                                        // SizedBox(width: screenWidth * 0.09),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // subtitle: Text(dayDetails.date ?? ''),
                                        // trailing: Text(dayDetails.id.toString()),
                                        selected: controller.isSelected(dayDetails),
                                        onTap: () => _onItemTap(index),
                                        onLongPress: () => _onLongPress(index),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.01),
                              ],
                            );
                          },
                        ),
                ),
                SizedBox(
                  height: screenHeight * 0.2,
                ),
              ],
            );
          } else {
            return Center(child: Text('No data available.'));
          }
        },
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
            width: 200,
            alignment: Alignment.center,
            child: Text(
              fullName,
              style: TextStyle(
                  color: Colors.black,
                  // fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  void _showDetailsModalBottomSheet(BuildContext context, List<Calculation> viewDetails, dynamic selectedId) {
    Calculation selectedDetails = viewDetails.firstWhere((details) => details.id == selectedId);
    String formatDate(String date) {
      try {
        DateTime parsedDate = DateTime.parse(date);
        return DateFormat('dd-MM-yyyy').format(parsedDate);
      } catch (e) {
        return date;
      }
    }

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        final screenHeight = MediaQuery.of(context).size.height * 1;
        final screenWidth = MediaQuery.of(context).size.width * 1;
        final fixedHeight = screenHeight * 0.45;

        Color _getBorderColor(String? status) {
          switch (status) {
            case "Updated":
              return Colors.blue;
            case "Approved":
              return Colors.green;
            case "Pending":
              return AppColors.navButtonColor;
            case "Decline":
              return Colors.red;
            default:
              return Colors.grey;
          }
        }

        return FractionallySizedBox(
          // Use FractionallySizedBox
          widthFactor: screenWidth,
          child: Container(
              width: screenWidth,
              // height: fixedHeight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: screenHeight * 0.07,
                    width: screenWidth,
                    decoration: BoxDecoration(
                      color: AppColors.navButtonColor,
                      // Colors.deepOrangeAccent,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: screenHeight * 0.013,
                        ),
                        Container(
                          height: 5,
                          width: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.grey.shade300,
                            ),
                            color: Colors.grey.shade300,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.007),
                        Text(
                          'Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: screenWidth,
                    color: Colors.white,
                    padding: EdgeInsets.only(left: 5, right: 5),
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.013),
                        singleContainer("Rate Type", "${selectedDetails.daysName ?? ""}"),
                        SizedBox(height: screenHeight * 0.013),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            doubleContainer("Date", formatDate("${selectedDetails.date ?? ""}")),
                            doubleContainer(
                              "Total Submitted Hours",
                              "${((double.tryParse(selectedDetails.dayShiftTime ?? '') ?? 0.00) + (double.tryParse(selectedDetails.nightShiftTime ?? '') ?? 0.00) + (double.tryParse(selectedDetails.breakTime ?? '') ?? 0.00)).toStringAsFixed(2)}",
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.013),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            doubleContainer("Break Deduction",
                                "${(double.tryParse(selectedDetails.breakTime ?? '') ?? 0.0).toStringAsFixed(2)}"),
                            doubleContainer(
                              "Total Net Hours",
                              "${((double.tryParse(selectedDetails.dayShiftTime ?? '') ?? 0.00) + (double.tryParse(selectedDetails.nightShiftTime ?? '') ?? 0.00)).toStringAsFixed(2)}",
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.013),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     doubleContainer("Day Shift Amount",
                        //         "£ ${(double.tryParse(selectedDetails.dayShiftCharge ?? '') ?? 0.0).toStringAsFixed(2)}"),
                        //     doubleContainer("Night Shift Amount",
                        //         "£ ${(double.tryParse(selectedDetails.nightShiftCharge ?? '') ?? 0.0).toStringAsFixed(2)}")
                        //   ],
                        // ),
                        // SizedBox(height: screenHeight * 0.013),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            doubleContainer("Expenses",
                                "£ ${(double.tryParse(selectedDetails.expenses ?? '') ?? 0.0).toStringAsFixed(2)}"),
                            // doubleContainer("Total Amount",
                            //     "£ ${(double.tryParse(selectedDetails.totalCharge ?? '') ?? 0.0).toStringAsFixed(2)}")
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Status",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                                Container(
                                  height: screenHeight * 0.04,
                                  width: screenWidth * 0.475,
                                  decoration: BoxDecoration(
                                    color: _getBorderColor(selectedDetails.status ?? ""),
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: _getBorderColor(selectedDetails.status ?? ""),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "${(selectedDetails.status) ?? ""}",
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.013),
                      ],
                    ),
                  ),
                ],
              )),
        );
      },
    );
  }

  Widget singleContainer(String heading, String text) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              heading,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Container(
            height: screenHeight * 0.04,
            width: screenWidth * 0.98,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(child: AutoSizeText(text))),
      ],
    );
  }

  Widget doubleContainer(String heading, String? text) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;

    // Handle the case where text is null
    final displayText = text ?? "N/A";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Container(
          height: screenHeight * 0.04,
          width: screenWidth * 0.475,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(child: Text(displayText)),
        ),
      ],
    );
  }

  void _showCancelReasonDialog() {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.02,
            vertical: screenHeight * 0.02,
          ),
          // insetPadding: EdgeInsets.symmetric(
          //   horizontal: screenWidth * 0.1,
          //   vertical: screenHeight * 0.2,
          // ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text('Rejection Reason'),
          content: SingleChildScrollView(
            child: ListBody(children: <Widget>[
              Container(
                height: screenHeight * 0.25,
                width: screenWidth * 0.70,
                child: Container(
                  height: screenHeight * 0.22,
                  width: screenWidth * 0.65,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                      border: Border.all(width: 0.4, color: AppColors.navButtonColor)),
                  child: TextField(
                    controller: cancelController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'Enter rejection reason',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    onChanged: (value) {
                      cancelController.text = value;
                    },
                  ),
                ),
              ),
            ]),
          ),
          actions: [
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
                _clearSelection();
                setState(() {
                  selectAll = false;
                });
              },
              child: Container(
                width: screenWidth * 0.22,
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.011,
                ),
                decoration: BoxDecoration(
                  color: AppColors.navButtonColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                if (cancelController.text.trim().isNotEmpty) {
                  Utils.showDialogLoading(context);
                  _onCancel(cancelController.text);
                  cancelController.clear();
                } else {
                  Utils.flushBarErrorMessage("Rejection reason required", context);
                }
              },
              child: Container(
                width: screenWidth * 0.22,
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.011,
                ),
                decoration: BoxDecoration(
                  color: AppColors.navOpacity,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
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

  void _showAlertBulkUpdate(BuildContext context, List<Calculation> viewDetails, dynamic selectedId) {
    Calculation selectedDetails = viewDetails.firstWhere((details) => details.id == selectedId);
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    setState(() {
      _dateControllers.text = "${selectedDetails.date ?? ""}";
      _totalControllers.text = (selectedDetails.totalCharge != null && selectedDetails.totalCharge!.isNotEmpty)
          ? double.tryParse(selectedDetails.totalCharge!)?.toStringAsFixed(2) ?? ""
          : "";

      _expensesControllers.text = (selectedDetails.expenses != null && selectedDetails.expenses!.isNotEmpty)
          ? double.tryParse(selectedDetails.expenses!)?.toStringAsFixed(2) ?? ""
          : "";

      _dayTimeControllers.text = (selectedDetails.dayShiftTime != null && selectedDetails.dayShiftTime!.isNotEmpty)
          ? double.tryParse(selectedDetails.dayShiftTime!)?.toStringAsFixed(2) ?? ""
          : "";

      _nightTimeControllers.text =
          (selectedDetails.nightShiftTime != null && selectedDetails.nightShiftTime!.isNotEmpty)
              ? double.tryParse(selectedDetails.nightShiftTime!)?.toStringAsFixed(2) ?? ""
              : "";

      _updateController.text = "${selectedDetails.cancelReason ?? ""}";

      // Add listeners to the controllers for recalculating total amount
      _dayTimeControllers.addListener(() => _calculateTotalAmount(viewDetails, selectedDetails));
      _nightTimeControllers.addListener(() => _calculateTotalAmount(viewDetails, selectedDetails));
      _expensesControllers.addListener(() => _calculateTotalAmount(viewDetails, selectedDetails));
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime parsedDate = DateTime.tryParse(selectedDetails.date ?? '') ?? DateTime.now();
        String formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(
            'Update Details',
            style: TextStyle(fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: ListBody(children: <Widget>[
              // Text("${selectedDetails.id}"),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: [
              //     Text("${selectedDetails.clientDayChargeRate}"),
              //     Text("${selectedDetails.clientNightChargeRate}"),
              //   ],
              // ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  doubleContainer1(
                    title: "Date",
                    controller: TextEditingController(text: formattedDate),
                    // controller: _dateControllers,
                    keyboardType: TextInputType.name,
                    errorMessage: _validationErrors['date'],
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  doubleContainer1(
                    title: "Total Amount",
                    controller: _totalControllers,
                    keyboardType: TextInputType.number,
                    errorMessage: _validationErrors['totalExpense'],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.002),
              singleContainer2(
                title: "Expense",
                controller: _expensesControllers,
                keyboardType: TextInputType.number,
                errorMessage: _validationErrors['expenses'],
              ),
              SizedBox(height: screenHeight * 0.002),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  singleContainer1(
                    title: "Day Time",
                    controller: _dayTimeControllers,
                    keyboardType: TextInputType.number,
                    errorMessage: _validationErrors['dayHour'],
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  singleContainer1(
                    title: "Night Time",
                    controller: _nightTimeControllers,
                    keyboardType: TextInputType.number,
                    errorMessage: _validationErrors['nightHour'],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.013),
              Text("Update Reason", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: screenHeight * 0.11,
                    width: screenWidth * 0.62,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.navButtonColor, width: 0.8),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: TextFormField(
                      controller: _updateController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      style: TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintStyle: TextStyle(fontSize: 14),
                        contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                        prefixIcon: Icon(Icons.edit, size: 15),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
              // SizedBox(height: screenHeight * 0.1),
            ]),
          ),
          actions: [
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
                _clearSelection();
                setState(() {
                  selectAll = false;
                });
              },
              child: Container(
                width: screenWidth * 0.22,
                // color:  AppColors.navButtonColor,

                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.011,
                  // horizontal: screenWidth * 0.001
                ),
                decoration: BoxDecoration(
                  color: AppColors.navOpacity,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                if (_updateController.text.isNotEmpty) {
                  final slug = selectedDetails.assignmentSlug ?? '';
                  dynamic mID = selectedDetails.id ?? '';
                  await _updateManual(slug, mID, viewDetails);
                } else {
                  Utils.flushBarErrorMessage("Update reason must be required", context);
                }
              },
              child: Container(
                width: screenWidth * 0.22,
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.011,
                ),
                decoration: BoxDecoration(
                  color: AppColors.navButtonColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    "Update",
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _calculateTotalAmount(List<Calculation> viewDetails, Calculation selectedDetails) {
    double dayTime = double.tryParse(_dayTimeControllers.text) ?? 0;
    double nightTime = double.tryParse(_nightTimeControllers.text) ?? 0;
    double expenses = double.tryParse(_expensesControllers.text) ?? 0;

    double clientDayChargeRate = double.tryParse(selectedDetails.clientDayChargeRate ?? '0') ?? 0;
    double clientNightChargeRate = double.tryParse(selectedDetails.clientNightChargeRate ?? '0') ?? 0;

    double totalAmount = (dayTime * clientDayChargeRate) + (nightTime * clientNightChargeRate) + expenses;

    _totalControllers.text = totalAmount.toStringAsFixed(2);
  }

  Widget doubleContainer1({
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
          width: screenWidth * 0.3,
          decoration: BoxDecoration(
            color: AppColors.navOpacity,
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(fontSize: 14),
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

  Widget singleContainer1({
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
          width: screenWidth * 0.3,
          child: Align(
            alignment: Alignment.center,
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              style: TextStyle(fontSize: 14),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.navButtonColor.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.circular(5),
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

  Widget singleContainer2({
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
          width: screenWidth * 0.62,
          child: Align(
            alignment: Alignment.center,
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              style: TextStyle(fontSize: 14),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.navButtonColor.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.circular(5),
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
}

class MultiSelectController<T> {
  final List<T> selectedItems = [];

  void selectItem(T item) {
    if (!selectedItems.contains(item)) {
      selectedItems.add(item);
    }
  }

  void toggleSelection(T item) {
    if (selectedItems.contains(item)) {
      selectedItems.remove(item);
    } else {
      selectedItems.add(item);
    }
  }

  void clearSelection() {
    selectedItems.clear();
  }

  bool isSelected(T item) {
    return selectedItems.contains(item);
  }

  void setSelectedItems(List<T> items) {
    selectedItems.clear();
    selectedItems.addAll(items);
  }
}
