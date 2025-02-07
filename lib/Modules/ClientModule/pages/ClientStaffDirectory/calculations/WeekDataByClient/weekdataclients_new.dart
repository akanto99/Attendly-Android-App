import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:c9_app/Modules/ClientModule/client_screen.dart';
import 'package:c9_app/Modules/ClientModule/model/clientDirectoryModel/calculationModels/WeekDataModel/weekclient_model.dart';
import 'package:c9_app/Modules/ClientModule/pages/ClientStaffDirectory/calculations/WeekDataByClient/Manual_Period/manual_CalculationWeek.dart';
import 'package:c9_app/Modules/ClientModule/pages/ClientStaffDirectory/calculations/WeekDataByClient/Manual_Period/period_CalculationWeek.dart';
import 'package:c9_app/Modules/ClientModule/pages/ClientStaffDirectory/calculations/WeekDataByClient/edit_weekData.dart';
import 'package:c9_app/Modules/ClientModule/pages/ClientStaffDirectory/calculations/WeekDataByClient/weekDetailsScreen.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../utils/utils.dart';

class WeekDataClientListNew extends StatefulWidget {
  final String? slug;
  final String? stTime;
  final String? enTime;
  final String driverSlug;
  final String email;
  final String companyName;
  final String images;
  final String breakTimes;
  final String? assignStartDate;
  final String? assignEndDate;
  const WeekDataClientListNew({
    super.key,
    this.slug,
    this.stTime,
    this.enTime,
    required this.driverSlug,
    required this.email,
    required this.companyName,
    required this.images,
    required this.breakTimes,
    required this.assignStartDate,
    required this.assignEndDate,
  });

  @override
  State<WeekDataClientListNew> createState() => _WeekDataClientListNewState();
}

class _WeekDataClientListNewState extends State<WeekDataClientListNew> with WidgetsBindingObserver {
  late Future<WeekDataClientModel?> _clientWeekDataFuture;

  bool _showNoInternetConnectionMessage = false;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  bool showText = false;
  String? selectedYear;
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

  String replaceUnderscoreWithSpace(String input) {
    return input.replaceAll('_', ' ');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _clientWeekDataFuture = fetchClientWeekList();
    // _clientWeekDataFuture = fetchClientWeekList();

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

  ///New
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription.cancel(); // Cancel subscription
    APICacheManager().deleteCache('WeekData List - ${widget.driverSlug}');

    super.dispose();
  }

  ///NEw Added
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshData().then((_) {
        setState(() {});
      });
      // _refreshData(forceRefresh: true);
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> _refreshData() async {
    var freshData = await fetchClientWeekList();
    // var freshData = await fetchClientWeekList();
    if (freshData != null) {
      setState(() {
        _clientWeekDataFuture = Future.value(freshData);
      });
    } else {
      setState(() {
        _showNoInternetConnectionMessage = true;
      });
    }
  }

  Future<WeekDataClientModel?> fetchClientWeekList() async {
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

      final String apiUrl = '${AppUrl.baseUrl}/api/app/weekly-data-by-users?driver_slug=${widget.driverSlug}';
      print(apiUrl);
      final response = await https.get(Uri.parse(apiUrl), headers: {
        'Authorization': 'Bearer $_token',
      });
      if (response.statusCode == 200) {
        return weekDataClientModelFromJson(response.body);
      } else {
        throw Exception('Failed to load');
      }
    }
  }

  final MultiSelectController<Datum> controller = MultiSelectController<Datum>();
  TextEditingController cancelController = TextEditingController();
  List<Datum> tapWeekList = [];
  bool get showButtons => controller.selectedItems.isNotEmpty;
  bool selectionMode = false;
  bool selectAll = false;

  void _onLongPress(int index) {
    setState(() {
      controller.selectItem(tapWeekList[index]);
      selectionMode = true;
    });
  }

  void _onItemTap(int index) {
    if (selectionMode) {
      setState(() {
        controller.toggleSelection(tapWeekList[index]);
        if (controller.selectedItems.isEmpty) {
          selectionMode = false;
        }
      });
    } else {
      print("Normal tap action");
    }
  }

  void _clearSelection() {
    setState(() {
      controller.clearSelection();
      selectAll = false;
      selectionMode = false;
    });
  }

  void _onCancel(String reason) async {
    List<dynamic> selectedItems = controller.selectedItems.map((item) => item.calculationIds ?? []).expand((i) => i).toList();
    print('Declined items id: $selectedItems');
    Map<String, dynamic> requestBody = {
      "calculation_ids": selectedItems,
      "status": "Decline",
      "declineReason": reason,
    };
    try {
      await _postBulk(requestBody);
      print(requestBody);
      _clearSelection();
      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      print('Error occurred: $e');
      // Handle the error if needed
    }
  }

  void _onApprove() async {
    Utils.showDialogLoading(context);
    List<dynamic> selectedItems = controller.selectedItems.map((item) => item.calculationIds ?? []).expand((i) => i).toList();

    print('Approved items id: $selectedItems');
    Map<String, dynamic> requestBody = {
      "calculation_ids": selectedItems,
      "status": "Approved",
    };

    try {
      await _postBulk(requestBody);
      _clearSelection();
      Navigator.pop(context);
      print(requestBody);
    } catch (e) {
      print('Error occurred: $e');
      // Handle the error if needed
    }
  }

  void _onSelectAllChanged(bool? value) {
    setState(() {
      selectAll = value ?? false;
      if (selectAll) {
        controller.setSelectedItems(tapWeekList);
      } else {
        controller.clearSelection();
      }
    });
  }

  Future<void> _postBulk(Map<String, dynamic> requestBody) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';
    final String apiUrl = '${AppUrl.baseUrl}/api/app/weekly-data-details-merge-api';

    try {
      final response = await https.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final successMessage = responseData['success'] ?? '';

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          Utils.flushBarSuccessMessage(successMessage, context);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WeekDataClientListNew(
                slug: widget.slug,
                stTime: widget.stTime,
                enTime: widget.enTime,
                driverSlug: widget.driverSlug,
                email: widget.email,
                companyName: widget.companyName,
                images: widget.images,
                breakTimes: widget.breakTimes,
                assignStartDate: widget.assignStartDate,
                assignEndDate: widget.assignEndDate,
              ),
            ),
          );

          // Future.delayed(Duration(seconds: 2), () {
          //
          //   Navigator.pushReplacement(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => WeekDataClientListNew(
          //         slug:widget.slug,
          //         stTime:widget.stTime,
          //         enTime:widget.enTime,
          //         driverSlug: widget.driverSlug,
          //         email: widget.email,
          //         companyName: widget.companyName,
          //         images: widget.images,
          //         breakTimes: widget.breakTimes,
          //       ),
          //     ),
          //   ) ;
          // });
        });

        print("--0--");
      } else if (response.statusCode == 404) {
        final responseData = jsonDecode(response.body);
        final successMessage = responseData['error'] ?? '';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Utils.flushBarErrorMessage(successMessage, context);
        });
        print("--1--");
      } else if (response.statusCode == 403) {
        final responseData = jsonDecode(response.body);
        final successMessage = responseData['error'] ?? '';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Utils.flushBarErrorMessage(successMessage, context);
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Utils.flushBarErrorMessage("Failed to update the status", context);
        });
        print("--2--");
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Utils.flushBarErrorMessage("An error occurred", context);
      });
      print("--3--");
      print('Error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: _showNoInternetConnectionMessage ? Colors.red : AppColors.navColor,
    ));
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          setState(() {
            showText = false;
          });
        },
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
            appBar: AppBar(
              automaticallyImplyLeading: false,
              surfaceTintColor: Colors.white,
              toolbarHeight: 70,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ClientCurveNabBar()));
                        },
                        child: HeaderRow(Icons.arrow_back),
                      ),
                      Checkbox(
                        hoverColor: Colors.white,
                        activeColor: AppColors.navButtonColor,
                        side: BorderSide(color: Colors.black, width: 2.0),
                        value: selectAll,
                        onChanged: _onSelectAllChanged,
                      ),
                    ],
                  ),
                  Text(
                    "Weekly Timesheet",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (showButtons)
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.check,
                            color: Colors.green,
                          ),
                          onPressed: _onApprove,
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
                  else
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            showText = !showText;
                          });
                          // _showTimesheetDialog();
                        },
                        child: HeaderRow(Icons.edit_note_outlined)),
                ],
              ),
            ),
            body: _showNoInternetConnectionMessage
                ? NoInternetConnection()
                : RefreshIndicator(
                    onRefresh: _refreshData,
                    child: ResPonsiveUi(
                      mobile: body(),
                      desktop: body(),
                      tablet: body(),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget body() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        setState(() {
          showText = false;
        });
      },
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                Center(
                  child: FutureBuilder<WeekDataClientModel?>(
                    future: _clientWeekDataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          height: screenHeight * 0.8,
                          width: screenWidth,
                          color: AppColors.whiteColor,
                          child: LoadingScreen(),
                        );
                      } else if (snapshot.hasError) {
                        return Text("");
                        // return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        // final List<Datum>? weekList = snapshot.data?.data;
                        tapWeekList = snapshot.data!.data!;

                        if (tapWeekList != null && tapWeekList.isNotEmpty) {
                          return Container(
                            width: screenWidth * 0.95,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: tapWeekList.length,
                                  itemBuilder: (context, index) {
                                    var dayDetails = tapWeekList[index];
                                    final calculationIds = dayDetails.calculationIds?.join(', ') ?? '';
                                    dynamic calculationTypes = dayDetails.calculationType ?? "";
                                    if (calculationTypes!.length > 20) {
                                      calculationTypes = '${calculationTypes.substring(0, 20)}...';
                                    }

                                    String driverName = dayDetails.driverName ?? "";
                                    String truncatedDriverName = driverName.length > 20 ? '${driverName.substring(0, 20)}..' : driverName;

                                    List<TextSpan> _getTextSpans(String? text) {
                                      if (text == null || text.isEmpty) {
                                        return [
                                          TextSpan(
                                            text: '',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ];
                                      }

                                      final RegExp numberRegExp = RegExp(r'\d+');
                                      final matches = numberRegExp.allMatches(text);
                                      final List<TextSpan> spans = [];
                                      int lastMatchEnd = 0;

                                      for (final match in matches) {
                                        if (match.start > lastMatchEnd) {
                                          spans.add(
                                            TextSpan(
                                              text: text.substring(lastMatchEnd, match.start),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                                fontSize: 15,
                                              ),
                                            ),
                                          );
                                        }
                                        spans.add(
                                          TextSpan(
                                            text: match.group(0),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 15,
                                            ),
                                          ),
                                        );
                                        lastMatchEnd = match.end;
                                      }

                                      if (lastMatchEnd < text.length) {
                                        spans.add(
                                          TextSpan(
                                            text: text.substring(lastMatchEnd),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                              fontSize: 15,
                                            ),
                                          ),
                                        );
                                      }

                                      return spans;
                                    }

                                    return Column(
                                      children: [
                                        GestureDetector(
                                          onLongPress: () => _onLongPress(index),
                                          onTap: () {
                                            _onItemTap(index);
                                            setState(() {
                                              showText = false;
                                            });
                                          },
                                          child: ListTile(
                                            contentPadding: EdgeInsets.symmetric(
                                              horizontal: 5.0,
                                            ),
                                            title: Container(
                                              decoration: BoxDecoration(
                                                color: controller.isSelected(tapWeekList[index]) ? AppColors.navOpacity : AppColors.whiteColor,
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(
                                                  width: 0.2,
                                                  color: AppColors.navButtonColor,
                                                ), // Border radius
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppColors.blackOpacity,
                                                    offset: Offset(4, 4),
                                                    blurRadius: 1,
                                                    spreadRadius: 0,
                                                  ),
                                                  BoxShadow(
                                                    color: Colors.white,
                                                    offset: Offset(-4, -4),
                                                    blurRadius: 5,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    width: screenWidth * 0.95,
                                                    decoration: BoxDecoration(
                                                      color: AppColors.navButtonColor,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: AppColors.blackOpacity,
                                                          offset: Offset(0, 0),
                                                          blurRadius: 0.5,
                                                          spreadRadius: 0,
                                                        ),
                                                      ],
                                                      borderRadius: BorderRadius.only(
                                                        topLeft: Radius.circular(10),
                                                        topRight: Radius.circular(10),
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(top: 5.0,bottom: 5),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [

                                                          Padding(
                                                            padding: const EdgeInsets.only(left:5.0),
                                                            child: Container(
                                                              width: screenWidth * 0.24,
                                                              // color: Colors.red,
                                                              child: RichText(
                                                                text: TextSpan(
                                                                  children: _getTextSpans(dayDetails.week),
                                                                ),
                                                              ),
                                                            ),
                                                          ),

                                                          Container(
                                                            width: screenWidth * 0.66,
                                                            height: screenHeight * 0.05,
                                                            padding: EdgeInsets.only(
                                                              top: 1,
                                                              bottom: 1,
                                                            ),
                                                            decoration: BoxDecoration(
                                                              // color: Colors.yellowAccent,
                                                              borderRadius: BorderRadius.circular(5),
                                                            ),
                                                            child: Center(
                                                              child: AutoSizeText(
                                                                "${dayDetails.weekDatesRange ?? ""}",
                                                                style: TextStyle(color: AppColors.whiteColor,),
                                                              ),
                                                            ),
                                                          ),

                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              "Driver Name : ",
                                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                                            ),
                                                            GestureDetector(
                                                              onTapDown: (details) {
                                                                _showFullNamePopup(context, driverName, details.globalPosition);
                                                              },
                                                              child: Text(
                                                                replaceUnderscoreWithSpace(truncatedDriverName),
                                                                style: TextStyle(
                                                                  fontSize: 13,
                                                                  color: AppColors.blackColor.withOpacity(0.6),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            InkWell(
                                                              onTap: () {
                                                                final passcalculationIds = dayDetails.calculationIds ?? [];
                                                                dynamic hour = dayDetails.totalWorkingHours;
                                                                dynamic date = dayDetails.calculationDate;
                                                                print(passcalculationIds);
                                                                dynamic status = dayDetails.status;
                                                                final selectedAssignStartDate = '${widget.assignStartDate}';
                                                                final selectedAssignEndDate = '${widget.assignEndDate}';
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) => WeekDataClientDetails(
                                                                      slug: widget.slug,
                                                                      stTime: widget.stTime,
                                                                      enTime: widget.enTime,
                                                                      ids: passcalculationIds,
                                                                      email: widget.email,
                                                                      driverSlug: widget.driverSlug,
                                                                      companyName: widget.companyName,
                                                                      images: widget.images,
                                                                      breakTimes: widget.breakTimes,
                                                                      status: status,
                                                                      hour: hour,
                                                                      date: date,
                                                                      assignStartDate: selectedAssignStartDate,
                                                                      assignEndDate: selectedAssignEndDate,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              child: Icon(
                                                                Icons.info_outline,
                                                                color: AppColors.blackColor,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                final passcalculationIds = dayDetails.calculationIds ?? [];
                                                                dynamic hour = dayDetails.totalWorkingHours;
                                                                dynamic date = dayDetails.calculationDate;
                                                                print(hour);
                                                                dynamic status = dayDetails.status;
                                                                final selectedAssignStartDate = '${widget.assignStartDate}';
                                                                final selectedAssignEndDate = '${widget.assignEndDate}';
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) => EditWeekData(
                                                                      slug: widget.slug,
                                                                      stTime: widget.stTime,
                                                                      enTime: widget.enTime,
                                                                      ids: passcalculationIds,
                                                                      email: widget.email,
                                                                      driverSlug: widget.driverSlug,
                                                                      companyName: widget.companyName,
                                                                      images: widget.images,
                                                                      breakTimes: widget.breakTimes,
                                                                      status: status,
                                                                      hour: hour,
                                                                      date: date,
                                                                      assignStartDate: selectedAssignStartDate,
                                                                      assignEndDate: selectedAssignEndDate,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              child: Container(
                                                                  height: screenHeight * 0.035,
                                                                  // color:Colors.red,
                                                                  child: Align(
                                                                    alignment: Alignment.centerRight,
                                                                    child: SvgPicture.asset('images/staff/editsvg.svg', color: AppColors.navColor),
                                                                  )),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      RowData("Assign. ID", dayDetails.assignmentId ?? ""),
                                                      RowData(
                                                        "Total Hours",
                                                        "${double.tryParse(dayDetails.totalWorkingHours.toString())?.toStringAsFixed(2) ?? ""} hour",
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: screenHeight * 0.013),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                            height: screenHeight * 0.7,
                            width: screenWidth,
                            color: AppColors.whiteColor,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.timer_off,
                                    color: AppColors.navColor,
                                    size: screenWidth * 0.12,
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.02,
                                  ),
                                  Text(
                                    'No Timesheets Logged',
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
                                    'To log a timesheet, please tap the top right button to enter a timesheet.',
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
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            // top: screenHeight * 0.075,
            right: screenWidth * 0.085,
            child: Visibility(
              visible: showText,
              child: Container(
                // height: 120,
                width: screenWidth * 0.45,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.navButtonColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(0),
                    topLeft: Radius.circular(5),
                    bottomLeft: Radius.circular(5),
                    bottomRight: Radius.circular(5),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        final selectedSlug = '${widget.slug}';
                        final selectedStartTime = '${widget.stTime}';
                        final selectedEndtime = '${widget.enTime}';
                        final selectedDriverSlug = '${widget.driverSlug}';
                        final selectedCompanyName = '${widget.companyName}';
                        final selectedEmail = '${widget.email}';
                        final selectedImages = '${widget.images}';
                        final selectedBreak = '${widget.breakTimes}';
                        final selectedAssignStartDate = '${widget.assignStartDate}';
                        final selectedAssignEndDate = '${widget.assignEndDate}';
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => ManualCalculationScreenClient(images:selectedImages,PasscompanyName:selectedCompanyName,Passemail:selectedEmail,slug: selectedSlug, stTime:selectedStartTime, enTime:selectedEndtime),),
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManualCalculationWeek(
                              driverSlug: selectedDriverSlug,
                              images: selectedImages,
                              PasscompanyName: selectedCompanyName,
                              Passemail: selectedEmail,
                              slug: selectedSlug,
                              stTime: selectedStartTime,
                              enTime: selectedEndtime,
                              breakTimes: selectedBreak,
                              assignStartDate: selectedAssignStartDate,
                              assignEndDate: selectedAssignEndDate,
                            ),
                          ),
                        ).then((value) {
                          if (value != null) {
                            print('Received data from IndividualView: $value');
                          }
                        });
                        setState(() {
                          showText = false;
                        });
                      },
                      child: Container(
                          height: screenHeight * 0.05,
                          width: screenWidth * 0.45,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(0),
                                topLeft: Radius.circular(5),
                              ),
                              border: Border.all(color: Colors.white, width: 0.5)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(
                                Icons.calculate_outlined,
                                color: Colors.white,
                              ),
                              Text(
                                'Manual Timesheet',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          )),
                    ),
                    InkWell(
                      onTap: () {
                        final selectedSlug = '${widget.slug}';
                        final selectedStartTime = '${widget.stTime}';
                        final selectedEndtime = '${widget.enTime}';
                        final selectedDriverSlug = '${widget.driverSlug}';
                        final selectedCompanyName = '${widget.companyName}';
                        final selectedEmail = '${widget.email}';
                        final selectedImages = '${widget.images}';
                        final selectedBreak = '${widget.breakTimes}';
                        final selectedAssignStartDate = '${widget.assignStartDate}';
                        final selectedAssignEndDate = '${widget.assignEndDate}';
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => NormalCalculationClient(images:selectedImages,PasscompanyName:selectedCompanyName,Passemail:selectedEmail,slug: selectedSlug, startedTime:selectedStartTime, endedTime:selectedEndtime),),
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PeriodCalculationWeek(
                              driverSlug: selectedDriverSlug,
                              images: selectedImages,
                              PasscompanyName: selectedCompanyName,
                              Passemail: selectedEmail,
                              slug: selectedSlug,
                              startedTime: selectedStartTime,
                              endedTime: selectedEndtime,
                              breakTimes: selectedBreak,
                              assignStartDate: selectedAssignStartDate,
                              assignEndDate: selectedAssignEndDate,
                            ),
                          ),
                        ).then((value) {
                          if (value != null) {
                            print('Received data from IndividualView: $value');
                          }
                        });
                        setState(() {
                          showText = false;
                        });
                      },
                      child: Container(
                          height: screenHeight * 0.05,
                          width: screenWidth * 0.45,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white,
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(5),
                              bottomRight: Radius.circular(5),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(
                                Icons.type_specimen_outlined,
                                color: Colors.white,
                              ),
                              Text(
                                'Period Timesheet',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget RowData(String text, String text2) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * 0.4,
      height: screenHeight * 0.1,
      decoration: BoxDecoration(
        color: AppColors.navOpacity,
        // color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(10), // Border radius
        boxShadow: [
          BoxShadow(
            color: AppColors.greyOpacity,
            offset: Offset(2, 2),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AutoSizeText(
            text,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: screenHeight * 0.013,
          ),
          AutoSizeText(
            text2,
            style: TextStyle(fontSize: 13, color: AppColors.blackColor.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }

  void _showCancelReasonDialog() {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // backgroundColor: Colors.white,
          // surfaceTintColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.02,
            vertical: screenHeight * 0.02,
          ),

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
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.white, border: Border.all(width: 0.4, color: AppColors.navButtonColor)),
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
                // color:  AppColors.navButtonColor,
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
                // color:  AppColors.navOpacity,
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
            alignment: Alignment.center,
            child: Text(
              fullName,
              style: TextStyle(color: Colors.black, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  // git commit -m"Week Data Driver name small changes"
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
