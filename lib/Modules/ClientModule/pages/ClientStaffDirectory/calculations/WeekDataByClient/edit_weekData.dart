import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:c9_app/Modules/ClientModule/client_screen.dart';
import 'package:c9_app/Modules/ClientModule/model/clientDirectoryModel/calculationModels/WeekDataModel/editweekupdate_model.dart';
import 'package:c9_app/Modules/ClientModule/pages/ClientStaffDirectory/calculations/WeekDataByClient/weekdataclients_new.dart';
import 'package:c9_app/Modules/ClientModule/pages/noInternetConnectionWidget.dart';
import 'package:c9_app/loadingScreen.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/view/widgets/header_widgets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as https;

import '../../../../../../utils/utils.dart';


class EditWeekData extends StatefulWidget {
  final String? slug;
  final String? stTime;
  final String? enTime;
  final List<int> ids;
  final String? email;
  final String? driverSlug;
  final String? companyName;
  final String? images;
  final String? breakTimes;
  final dynamic status;
  final dynamic  hour;
  final dynamic date;
  final String? assignStartDate;
  final String? assignEndDate;
  const EditWeekData({super.key,
    this.slug,
    this.stTime,
    this.enTime,
    required this.ids,
    required this.email,
    required this.driverSlug,
    required this.companyName,
    required this.images,
    required this.breakTimes,
    required this.status,
    required this.hour,
    required this.date,
    required this.assignStartDate,
    required this.assignEndDate,
  });

  @override
  State<EditWeekData> createState() => _EditWeekDataState();
}

class _EditWeekDataState extends State<EditWeekData>with WidgetsBindingObserver{
  bool _isUploading = false;
  List<Datum> _data = [];
  Map<String, String> _validationErrors = {};
  List<TextEditingController> _dateControllers = [];
  List<TextEditingController> _dayHourControllers = [];
  List<TextEditingController> _nightHourControllers = [];
  List<TextEditingController> _expensesControllers = [];
  List<TextEditingController> _totalControllers = [];
  TextEditingController _updateController = TextEditingController();

  late Future<EditWeekDataUpdateModel?> _userEditManual;

  bool _showNoInternetConnectionMessage = false;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;


  String formatValue(String value) {
    double? doubleValue = double.tryParse(value);
    if (doubleValue == null) return value;
    return doubleValue == doubleValue.toInt() ? doubleValue.toInt().toString() : doubleValue.toStringAsFixed(2);
  }
  @override
  void initState() {
    super.initState();
    _refreshData();
    _userEditManual = fetchClientWeekDetails();

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
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _calculateTotalAmount(int index) {
    if (index >= _data.length) return;

    // Getting selected item data and associated controllers
    final selectedDetails = _data[index];
    double dayTime = double.tryParse(_dayHourControllers[index].text) ?? 0;
    double nightTime = double.tryParse(_nightHourControllers[index].text) ?? 0;
    double expenses = double.tryParse(_expensesControllers[index].text) ?? 0;

    double clientDayChargeRate = double.tryParse(selectedDetails.clientDayChargeRate ?? '0') ?? 0;
    double clientNightChargeRate = double.tryParse(selectedDetails.clientNightChargeRate ?? '0') ?? 0;

    // Calculate total amount and update the total controller
    double totalAmount = (dayTime * clientDayChargeRate) + (nightTime * clientNightChargeRate) + expenses;
    _totalControllers[index].text = totalAmount.toStringAsFixed(2);
  }

  Future<EditWeekDataUpdateModel?> fetchClientWeekDetails() async {
    // first check user's network connectivity
    var connectivityResult = await (Connectivity().checkConnectivity());
    bool hasInternet = await _hasInternetConnection();

    if(connectivityResult == ConnectivityResult.none || !hasInternet){
      // show No internet connection
      setState(() {
        _showNoInternetConnectionMessage = true;
      });
      return null;
    }else {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';
    final String apiUrl = '${AppUrl.baseUrl}/api/app/client/weekly-amend';
    print("----$apiUrl");
    print("----${widget.ids}");
    final response = await https.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: jsonEncode({
        'calculation_ids':  widget.ids,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final EditWeekDataUpdateModel profileViewset = EditWeekDataUpdateModel.fromJson(responseData);

      setState(() {
        _data = profileViewset.data ?? [];
        _dateControllers = List.generate(_data.length, (index) => TextEditingController(text: _data[index].date));
        _dayHourControllers = List.generate(_data.length, (index) => TextEditingController(text: formatValue(_data[index].dayShiftTime ?? '')));
        _nightHourControllers = List.generate(_data.length, (index) => TextEditingController(text: formatValue(_data[index].nightShiftTime ?? '')));
        _expensesControllers = List.generate(_data.length, (index) => TextEditingController(text: formatValue(_data[index].expenses ?? '')));
        _totalControllers = List.generate(_data.length, (index) => TextEditingController(text: formatValue(_data[index].totalCharge ?? '')));
        _updateController = TextEditingController(text: profileViewset.cancelReason ?? '');

        // Adding listeners to each controller to update total amount when changed
        for (int i = 0; i < _data.length; i++) {
          _dayHourControllers[i].addListener(() => _calculateTotalAmount(i));
          _nightHourControllers[i].addListener(() => _calculateTotalAmount(i));
          _expensesControllers[i].addListener(() => _calculateTotalAmount(i));
        }

      });

      return profileViewset;
    } else {
      print('Request failed with status: ${response.statusCode}');
      throw Exception('Failed to load data');
    }}
  }

  Future<void> _updateManual(String slug, List<Datum> data) async {
    setState(() {
      _isUploading = true;
    });
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String _token = prefs.getString('token') ?? '';
      final String apiUrl = '${AppUrl.baseUrl}/api/app/client/weekly-amend/store/$slug';
      // print(apiUrl);
      https.MultipartRequest request = https.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers.addAll({
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
      });

      for (int i = 0; i < _data.length; i++) {
        request.fields['m_id[$i]'] = data[i].calId.toString();
        request.fields['assign_slug'] = slug;
        request.fields['id[$i]'] = data[i].id.toString();
        request.fields['date[$i]'] = _dateControllers[i].text;
        request.fields['day_shift_time[$i]'] = _dayHourControllers[i].text;
        request.fields['night_shift_time[$i]'] = _nightHourControllers[i].text;
        request.fields['total_charge[$i]'] = _totalControllers[i].text;
        request.fields['expenses[$i]'] = _expensesControllers[i].text;
        request.fields['cancelReason'] = _updateController.text;

        //
        // print('Posting data for index $i:');
        // print('m_id[$i]: ${data[i].calId.toString()}');
        // print('assign_slug: $slug');
        // print('id[$i]: ${data[i].id}');
        // print('date[$i]: ${_dateControllers[i].text}');
        // print('day_shift_time[$i]: ${_dayHourControllers[i].text}');
        // print('night_shift_time[$i]: ${_nightHourControllers[i].text}');
        // print('total_charge[$i]: ${_totalControllers[i].text}');
        // print('expenses[$i]: ${_expensesControllers[i].text}');
      }

      final response = await request.send();
      if (response.statusCode == 200) {
        print('Update Successful');
        print('Response body: ${await response.stream.bytesToString()}');

        setState(() {
          _isUploading = false;
        });
        Utils.flushBarSuccessMessage('Data Updated Successfully', context);
        Future.delayed(Duration(seconds: 2), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WeekDataClientListNew(
                slug:widget.slug,
                stTime:widget.stTime,
                enTime:widget.enTime,
                driverSlug: widget.driverSlug!,
                email: widget.email!,
                companyName: widget.companyName!,
                images:widget.images!,
                breakTimes:widget.breakTimes!,
                assignStartDate:widget.assignStartDate,
                assignEndDate:widget.assignEndDate,
                    ),
            ),
          );
        });
      } else {
        setState(() {
          _isUploading = false;
        });
        print('Response body: ${await response.stream.bytesToString()}');
        Utils.flushBarErrorMessage('Failed to update data',context);
      }
    } catch (e) {
      print('Error during data submission: $e');
      setState(() {
        _isUploading = false;
      });
      Utils.flushBarErrorMessage('An error occurred during update', context);
    }
  }

  Future<void> _refreshData() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: _showNoInternetConnectionMessage ? Colors.red : AppColors.navColor,
    ));

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          surfaceTintColor: Colors.white,
          toolbarHeight: 80,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: HeaderRow(Icons.arrow_back)),
              Text("Update Timesheet", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ClientCurveNabBar()));
                  },
                  child: HeaderRow(Icons.home_filled)),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child:_showNoInternetConnectionMessage ? NoInternetConnection(): ResPonsiveUi(
            mobile: body(),
            desktop: body(),
            tablet: body(),
          ),
        ),
      ),
    );
  }

  Widget body() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Column(
        children: [
          Center(
            child: FutureBuilder<EditWeekDataUpdateModel?>(
              future: _userEditManual,
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
                  EditWeekDataUpdateModel data = snapshot.data!;
                  if (data.data == null || data.data!.isEmpty) {
                    return  Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.1),
                      height: screenHeight * 0.7,
                      width: screenWidth,
                      color: AppColors.whiteColor,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            Icon(
                              Icons.update_disabled,
                              color: AppColors.navColor,
                              size: screenWidth * 0.12,
                            ),
                            SizedBox(
                              height: screenHeight * 0.02,
                            ),
                            Text(
                              'No updates are available',
                              style: TextStyle(
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.bold,
                                color: AppColors.navColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: screenHeight * 0.01,
                            ),
                            Text(
                              'All data have been either approved or declined.',
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                color: AppColors.navColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
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
                            // Text("Client id: ${data.clientSlug ?? ''}"),

                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: data.data?.length ?? 0,
                              itemBuilder: (context, index) {
                                Datum datum = data.data![index]; // Accessing each datum
                                // Parsing and formatting the date
                                DateTime parsedDate = DateTime.tryParse(datum.date ?? '') ?? DateTime.now();
                                String formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);

                                return Column(
                                  children: [
                                    Center(
                                      child: Container(
                                        width: screenWidth * 0.95,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.2),
                                              offset: Offset(0, 0),
                                              blurRadius: 5,
                                              spreadRadius: 1,
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
                                                    controller: TextEditingController(text: formattedDate),
                                                    // controller: _dateControllers[index],
                                                    keyboardType: TextInputType.name,
                                                    errorMessage: _validationErrors['date'],
                                                  ),
                                                  doubleContainer(
                                                    title: "Total Amount",
                                                    controller: _totalControllers[index],
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
                                                    controller: _expensesControllers[index],
                                                    keyboardType: TextInputType.number,
                                                    errorMessage: _validationErrors['expenses'],
                                                  ),
                                                  singleContainer(
                                                    title: "Day Hour",
                                                    controller: _dayHourControllers[index],
                                                    keyboardType: TextInputType.number,
                                                    errorMessage: _validationErrors['dayHour'],
                                                  ),
                                                  singleContainer(
                                                    title: "Night Hour",
                                                    controller: _nightHourControllers[index],
                                                    keyboardType: TextInputType.number,
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
                                  ],
                                );
                              },
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
                                      onTap: () async {
                                        if (_updateController.text.isNotEmpty) {
                                          final slug = data.assignSlug ?? '';
                                          _updateManual(slug,data.data!);
                                        } else {
                                          Utils.flushBarErrorMessage("Update reason must be required", context);
                                        }
                                      },
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
          ),


        ],
      ),
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

