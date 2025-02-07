import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:c9_app/Modules/ClientModule/client_screen.dart';
import 'package:c9_app/Modules/ClientModule/model/clientDirectoryModel/calculationModels/WeekDataModel/weekdetails_model.dart';
import 'package:c9_app/Modules/ClientModule/pages/ClientStaffDirectory/calculations/WeekDataByClient/weekdataclients_new.dart';
import 'package:c9_app/Modules/ClientModule/pages/noInternetConnectionWidget.dart';
import 'package:c9_app/loadingScreen.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/responsive/responsive_ui.dart';
import 'package:c9_app/view/widgets/header_widgets.dart';
import 'package:c9_app/view/widgets/icon_container.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as https;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../utils/utils.dart';


class WeekDataClientDetails extends StatefulWidget {
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
  final dynamic hour;
  final dynamic date;
  final String? assignStartDate;
  final String? assignEndDate;
  const WeekDataClientDetails({
    Key? key,
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
  }) : super(key: key);

  @override
  State<WeekDataClientDetails> createState() => _WeekDataClientDetailsState();
}

class _WeekDataClientDetailsState extends State<WeekDataClientDetails> with WidgetsBindingObserver  {
  late Future<WeekDataClientDetailsModel?> _clientWeekDataDetailsFuture;
  bool _showNoInternetConnectionMessage = false;
  late StreamSubscription<ConnectivityResult>
  _connectivitySubscription;

  WeekDataClientDetailsModel? _cachedData;


  TextEditingController _dateControllers = TextEditingController();
  TextEditingController _dayTimeControllers = TextEditingController();
  TextEditingController _nightTimeControllers = TextEditingController();
  TextEditingController _expensesControllers = TextEditingController();
  TextEditingController _totalControllers = TextEditingController();
  TextEditingController _updateController = TextEditingController();
  Map<String, String> _validationErrors = {};

  // final String apiUrl = '${AppUrl.baseUrl}/api/app/client/weekly-amend/store/$slug';

  Future<void> _updateManual(String slug, dynamic mID, List<Datum> data) async {
    Utils.showDialogLoading(context);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String _token = prefs.getString('token') ?? '';
      final String apiUrl =
          '${AppUrl.baseUrl}/api/app/client/update/calculation/store/$slug';
      https.MultipartRequest request =
      https.MultipartRequest('POST', Uri.parse(apiUrl));
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
              builder: (context) => WeekDataClientDetails(
                slug:widget.slug,
                stTime:widget.stTime,
                enTime:widget.enTime,
                ids: widget.ids,
                email: widget.email,
                driverSlug: widget.driverSlug,
                companyName: widget.companyName,
                images: widget.images,
                breakTimes: widget.breakTimes,
                status: widget.status,
                hour: widget.hour,
                date: widget.date,
                assignStartDate: widget.assignStartDate,
                assignEndDate: widget.assignEndDate,

              ),
            ),
          );
        });
      } else {
        Navigator.pop(context);
        print(response);
        print("${response.statusCode}");
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _clientWeekDataDetailsFuture = fetchClientWeekDetails();
     // _refreshData();
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen(
            (ConnectivityResult result) async {
          bool hasInternet =
          await _hasInternetConnection(); // Check internet access

          if (result != ConnectivityResult.none && hasInternet &&  _showNoInternetConnectionMessage) {
            _refreshData()
                .then((_) {
              setState(() {});
            });
          }

          setState(() {
            _showNoInternetConnectionMessage =  (result == ConnectivityResult.none || !hasInternet);
          });
        });
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup(
          'google.com');
      return result.isNotEmpty &&
          result[0].rawAddress.isNotEmpty;
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
  void didChangeAppLifecycleState(
      AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshData();
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> _refreshData() async {

    var freshData = await fetchClientWeekDetails();
    if (freshData != null) {
      setState(() {
        _clientWeekDataDetailsFuture =
            Future.value(freshData);
       });

    } else {
      setState(() {
        _showNoInternetConnectionMessage = true;
      });
    }
  }

  Future<WeekDataClientDetailsModel?> fetchClientWeekDetails() async {
    var connectivityResult = await (Connectivity()
        .checkConnectivity());
    bool hasInternet =
    await _hasInternetConnection();

    if (connectivityResult == ConnectivityResult.none || !hasInternet) {
      // No internet connection
      setState(() {
        _showNoInternetConnectionMessage = true;
      });
      return null;
    } else {

        SharedPreferences prefs = await SharedPreferences.getInstance();
        String _token = prefs.getString('token') ?? '';
        final String apiUrl = '${AppUrl.baseUrl}/api/app/weekly-data-details-by-users';
        final response = await https.post( Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
          },
          body: jsonEncode({
            'calculation_ids': widget.ids,
          }),
        );

        if (response.statusCode == 200) {

          return weekDataClientDetailsModelFromJson(
              response.body);
        } else {
          print(
              'Request failed with status: ${response.statusCode}');
          throw Exception('Failed to load data');
        }

    }
  }

  final MultiSelectController<Datum> controller = MultiSelectController<Datum>();
  TextEditingController cancelController = TextEditingController();
  List<Datum> tapWeekList = [];
  bool get showButtons => controller.selectedItems.isNotEmpty;
  bool selectionMode = false;

  // bool selectAll = false;
  // void _onLongPress(int index) {
  //   setState(() {
  //     controller.selectItem(tapWeekList[index]);
  //     selectionMode = true;
  //   });
  // }
  //
  // void _onItemTap(int index) {
  //   if (selectionMode) {
  //     setState(() {
  //       controller.toggleSelection(tapWeekList[index]);
  //       if (controller.selectedItems.isEmpty) {
  //         selectionMode = false;
  //       }
  //     });
  //   } else {
  //     print("Normal tap action");
  //   }
  // }
  bool selectAll = false;

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

  void _onLongPress(int index) {
    setState(() {
      controller.selectItem(tapWeekList[index]);
      selectionMode = true;
      selectAll = controller.selectedItems.length == tapWeekList.length;
    });
  }
  void _onItemTap(int index) {
    if (selectionMode) {
      setState(() {
        controller.toggleSelection(tapWeekList[index]);
        if (controller.selectedItems.isEmpty) {
          selectionMode = false;
        }
        selectAll = controller.selectedItems.length == tapWeekList.length;
      });
    } else {
      print("Normal tap action");
    }
  }
  void _clearSelection() {
    setState(() {
      controller.clearSelection();
      selectionMode = false;
    });
  }

  void _onCancel(String reason) async {
    List<dynamic> selectedItems =
    controller.selectedItems.map((item) => item.id.toString()).toList();
    print('Declined items id: $selectedItems');
    Map<String, dynamic> requestBody = {
      "calculation_ids": selectedItems,
      "status": "Decline",
      "cancelReason": reason,
    };
    try {
      await _postBulk(requestBody);
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
    List<dynamic> selectedItems =
    controller.selectedItems.map((item) => item.id.toString()).toList();

    print('Approved items id: $selectedItems');
    Map<String, dynamic> requestBody = {
      "calculation_ids": selectedItems,
      "status": "Approved",
    };

    try {
      await _postBulk(requestBody);
      _clearSelection();
      Navigator.pop(context);
    } catch (e) {
      print('Error occurred: $e');
      // Handle the error if needed
    }
  }

  // void _onSelectAllChanged(bool? value) {
  //   setState(() {
  //     selectAll = value ?? false;
  //     if (selectAll) {
  //       controller.setSelectedItems(tapWeekList);
  //     } else {
  //       controller.clearSelection();
  //     }
  //   });
  // }

  Future<void> _postBulk(Map<String, dynamic> requestBody) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';
    final String apiUrl =
        '${AppUrl.baseUrl}/api/app/weekly-data-details-merge-api';

    print('Sending request to API: $apiUrl');
    print('Request body: $requestBody');

    try {
      final response = await https.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final successMessage = responseData['success'] ?? '';

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          Utils.flushBarSuccessMessage(successMessage, context);


          Future.delayed(Duration(seconds: 2), () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WeekDataClientDetails(
                  slug:widget.slug,
                  stTime:widget.stTime,
                  enTime:widget.enTime,
                  ids: widget.ids,
                  email: widget.email,
                  driverSlug: widget.driverSlug,
                  companyName: widget.companyName,
                  images: widget.images,
                  breakTimes: widget.breakTimes,
                  status: widget.status,
                  hour: widget.hour,
                  date: widget.date,
                  assignStartDate: widget.assignStartDate,
                  assignEndDate: widget.assignEndDate,
                ),
              ),
            );
          });
        });
      } else if (response.statusCode == 404) {
        final responseData = jsonDecode(response.body);
        final successMessage = responseData['error'] ?? '';
print(responseData);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Utils.flushBarErrorMessage(successMessage, context);
        });
      }  else if (response.statusCode == 403) {
        final responseData = jsonDecode(response.body);
        final successMessage = responseData['error'] ?? '';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Utils.flushBarErrorMessage(successMessage, context);
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Utils.flushBarErrorMessage("Failed to update the status", context);
        });
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Utils.flushBarErrorMessage("An error occurred", context);
      });
      print('Error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: _showNoInternetConnectionMessage ? Colors.red : AppColors.navColor,
    ));

    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return WillPopScope(
      onWillPop: () async {
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
              images: widget.images!,
              breakTimes: widget.breakTimes!,
              assignStartDate: widget.assignStartDate,
              assignEndDate: widget.assignEndDate,
            ),
          ),
        );
        // Navigator.pop(context);
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
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => WeekDataClientListNew(
                          slug:widget.slug,
                          stTime:widget.stTime,
                          enTime:widget.enTime,
                          driverSlug: widget.driverSlug!,
                          email: widget.email!,
                          companyName: widget.companyName!,
                          images: widget.images!,
                          breakTimes: widget.breakTimes!,
                          assignStartDate: widget.assignStartDate,
                          assignEndDate: widget.assignEndDate,
                        ),
                      ),
                    );
                    // Navigator.pop(context);
                  },
                  child: HeaderRow(Icons.arrow_back),
                ),
                Text(
                  "Details",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (showButtons) ...[
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: _onApprove,
                      ),
                      SizedBox(width: screenWidth*0.02,),
                      IconButton(
                        icon: Icon(Icons.cancel,color:Colors.red,),
                        onPressed: _showCancelReasonDialog,
                      ),
                    ],
                  )
                ] else ...[
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ClientCurveNabBar()),);
                    },
                    child: HeaderRow(Icons.home),
                  ),
                ],
              ],
            ),
          ),
          body: RefreshIndicator(
            onRefresh:_refreshData,
            child: _showNoInternetConnectionMessage ? NoInternetConnection() : ResPonsiveUi(
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

    String? responsi = widget.companyName;
    if (responsi!.length > 15) {
      responsi = '${responsi.substring(0, 15)}...';
    }
    String formattedDate = '';
    if (widget.date != 'No') {
      DateTime parsedDate = DateTime.parse(widget.date.toString());
      formattedDate =
      '${parsedDate.day.toString().padLeft(2, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.year}';
    }

    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Text("${widget.ids}"),
          // Text("${widget.hour}"),

          Center(
            child: FutureBuilder<WeekDataClientDetailsModel?>(
              future: _clientWeekDataDetailsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: screenHeight * 0.8,
                    width: screenWidth,
                    color: AppColors.whiteColor,
                    child: LoadingScreen(),
                  );
                } else if (snapshot.hasError) {
                  // return Center(child: Text("${snapshot.error}"));
                  return Center(child: Text(""));
                } else if (snapshot.hasData && snapshot.data!.data != null) {
                  tapWeekList = snapshot.data!.data!;

                  // var weekList = snapshot.data!.data!;
                  return Column(
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 10.0, left: 10, right: 10),
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
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                            onTapUp: (details) {
                                              String? responsi =
                                                  widget.companyName;
                                              if (responsi != null) {
                                                _showFullNamePopup(
                                                    context,
                                                    responsi,
                                                    details.globalPosition);
                                              }
                                            },
                                            child: Text(
                                              "$responsi",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500),
                                            )),
                                        Container(
                                          width:screenWidth*0.45,
                                          child: AutoSizeText(
                                            "${widget.email}",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                    height: screenHeight * 0.04,
                                    width: screenWidth * 0.3,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(7),
                                        border: Border.all(
                                            width: 1,
                                            color:
                                            Colors.grey.withOpacity(0.5))),
                                    child:
                                    Center(child: Text("$formattedDate"))),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.013,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Total Hour",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(
                                      width: screenWidth * 0.02,
                                    ),
                                    Container(
                                      height: screenHeight * 0.035,
                                      width: screenWidth * 0.002,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(
                                      width: screenWidth * 0.02,
                                    ),
                                    Text(
                                      "${(double.parse(widget.hour.toString())).toStringAsFixed(2)}",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),

                                // Row(
                                //   children: [
                                //     Container(
                                //         height: screenHeight*0.04,
                                //         width: screenWidth*0.2,
                                //         child: Center(child: Text("Status",style: TextStyle(fontSize: 17,fontWeight: FontWeight.w500),))),
                                //
                                //
                                //     Container(
                                //       height: screenHeight*0.035,
                                //       width: screenWidth*0.002,
                                //       color: Colors.grey,
                                //     ),
                                //
                                //     Container(
                                //         height: screenHeight*0.04,
                                //         width: screenWidth*0.2,
                                //         child: Center(child: Text(widget.status,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black.withOpacity(0.5)),))),
                                //   ],
                                // ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.013,
                          ),
                          Container(
                            height: screenHeight * 0.05,
                            width: screenWidth * 0.80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColors.navButtonColor,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Checkbox(
                                  hoverColor: Colors.white,
                                  // activeColor: AppColors.navButtonColor,
                                  side: BorderSide(
                                      color: Colors.white, width: 2.0),
                                  value: selectAll,
                                  onChanged: _onSelectAllChanged,
                                ),
                                Text(
                                  "Details",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.013,),
                      Container(
                        width: screenWidth * 0.97,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: tapWeekList.length,
                          itemBuilder: (context, index) {
                            var dayDetails = tapWeekList[index];
                            String? daysName = dayDetails.daysName ?? "";

                            //Previous COde
                            // String shortdaysName = '';
                            // if (daysName != null && daysName.length > 15) {
                            //   shortdaysName = '${daysName.substring(0, 15)}...';
                            // }

                            String formattedDate = '';
                            String? date = dayDetails.date;
                            if (date != null && date != 'No') {
                              DateTime parsedDate = DateTime.parse(date);
                              formattedDate =
                              '${parsedDate.day.toString().padLeft(2, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.year}';
                            }
                            // Function to get the day name based on the date
                            String getDayName(String? date) {
                              if (date == null || date.isEmpty) return '';
                              try {
                                DateTime parsedDate = DateTime.parse(date);
                                return DateFormat('EEEE').format(parsedDate);
                              } catch (e) {
                                return ''; // Return empty string if parsing fails
                              }
                            }

                            return Column(
                              children: [
                                GestureDetector(
                                  onLongPress: () => _onLongPress(index),
                                  onTap: () => _onItemTap(index),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: controller.isSelected(tapWeekList[index])
                                          ?   AppColors.navButtonColor.withOpacity(0.1)
                                          : AppColors.whiteColor,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: controller.isSelected(dayDetails)
                                            ?   AppColors.navButtonColor.withOpacity(0.1)
                                        // :Colors.blue,
                                            : AppColors.greyOpacity,
                                      ),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 0),
                                        title: Padding(
                                          padding: EdgeInsets.all(0),
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
                                                        selectAll = controller.selectedItems.length == tapWeekList.length;
                                                      });
                                                    }
                                                  },
                                                ),
                                              ),
                                              Container(
                                                width: screenWidth * 0.2,
                                                height:screenHeight * 0.04,
                                                decoration: BoxDecoration(
                                                  color: AppColors.navOpacity,
                                                  borderRadius:
                                                  BorderRadius.circular(4),
                                                ),
                                                child: Center(
                                                  child: AutoSizeText(
                                                    formattedDate,
                                                    style: TextStyle(fontSize: 13),
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTapUp: (details) {
                                                  if (daysName != null) {
                                                    // _showFullNamePopup(
                                                    //     context,
                                                    //     daysName,
                                                    //     details.globalPosition);
                                                  }
                                                },
                                                child: Container(
                                                  width: screenWidth * 0.3,
                                                  height:screenHeight * 0.04,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.navOpacity,
                                                    borderRadius:
                                                    BorderRadius.circular(4),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      // shortdaysName ?? '',
                                                      getDayName(date),
                                                      style:
                                                      TextStyle(fontSize: 12),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                height: screenHeight * 0.04,
                                                width: screenWidth * 0.13,
                                                decoration: BoxDecoration(
                                                  color: AppColors.navOpacity,
                                                  borderRadius:
                                                  BorderRadius.circular(5),
                                                ),
                                                child: Center(
                                                  child: AutoSizeText(
                                                    '${(double.parse(dayDetails.hours ?? '0')).toStringAsFixed(2)} H',
                                                    style: TextStyle(fontSize: 12),
                                                  ),
                                                ),
                                              ),
                                              // Container(
                                              //   height: MediaQuery.of(context).size.height * 0.04,
                                              //   child: Center(
                                              //     child: AutoSizeText(
                                              //       getStatusString(dayDetails.status),
                                              //       style: TextStyle(fontSize: 13),
                                              //     ),
                                              //   ),
                                              // ),
                                              Container(
                                                height: screenHeight * 0.04,
                                                child: Center(
                                                  child: Row(
                                                    children: [
                                                      if (dayDetails.status == Status.APPROVED) // Check status for Approved
                                                        StatusIconContainer(color: Colors.green,),
                                                      if (dayDetails.status == Status.PENDING) // Check status for Decline
                                                        StatusIconContainer(color: AppColors.pending,),
                                                      if (dayDetails.status == Status.DECLINE) // Check status for Decline
                                                        StatusIconContainer(color: Colors.red,),
                                                      if (dayDetails.status == Status.UPDATED) // Check status for Decline
                                                        StatusIconContainer(color: Colors.blue,)
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  _showDetailsModalBottomSheet(
                                                      context,
                                                      tapWeekList,
                                                      dayDetails.id);
                                                },
                                                child: Container(
                                                  width: screenWidth *
                                                      0.1,
                                                  child: Icon(Icons.info_outline,
                                                      size: 20),
                                                ),
                                              ),
                                              // InkWell(
                                              //   onTap: () {
                                              //     _showAlertBulkUpdate(context,
                                              //         tapWeekList, dayDetails.id);
                                              //   },
                                              //   child: Container(
                                              //     height: screenHeight * 0.04,
                                              //     // width: screenWidth * 0.10,
                                              //     // color: Colors.red,
                                              //     child: Center(
                                              //       child: Row(
                                              //         children: [
                                              //           if (dayDetails.status == Status.PENDING || dayDetails.status == Status.UPDATED) // Check status for Approved
                                              //             SvgPicture.asset(
                                              //               'images/staff/editsvg.svg', height: 25, width: 25,
                                              //               color: dayDetails.status == Status.PENDING
                                              //                   ? AppColors.navColor
                                              //                   : dayDetails.status == Status.UPDATED
                                              //                   ? Colors.blue
                                              //                   : Colors.black,
                                              //             ),
                                              //         ],
                                              //       ),
                                              //     ),
                                              //   ),
                                              // ),
                                              if (dayDetails.status == Status.PENDING)
                                                InkWell(
                                                  onTap:(){
                                                    _showAlertBulkUpdate(context, tapWeekList, dayDetails.id);
                                                  },
                                                  child: Container(
                                                    height: screenHeight * 0.04,
                                                    // width: screenWidth * 0.10,
                                                    // color: Colors.red,
                                                    child: Center(
                                                      child: SvgPicture.asset(
                                                        'images/staff/editsvg.svg',height: 25,width: 25,
                                                        color: dayDetails.status == Status.PENDING
                                                            ?  AppColors.pending
                                                            : dayDetails.status == Status.UPDATED
                                                            ?Colors.blue
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              else
                                                SvgPicture.asset(
                                                    'images/staff/editsvg.svg',height: 25,width: 25,
                                                    color: Colors.transparent
                                                )
                                            ],
                                          ),
                                        ),
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
                    ],
                  );
                } else {
                  return Center(child: Text('No data available.'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFullNamePopup(
      BuildContext context, String fullName, Offset position) {
    final RenderBox overlay =
    Overlay.of(context)!.context.findRenderObject() as RenderBox;
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
            // height: 40,
            alignment: Alignment.center,
            child: Text(
              fullName,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  void _showDetailsModalBottomSheet(
      BuildContext context, List<Datum> viewDetails, dynamic selectedId) {
    Datum selectedDetails =
    viewDetails.firstWhere((details) => details.id == selectedId);

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

        String getStatusString(Status? status) {
          switch (status) {
            case Status.APPROVED:
              return "Approved";
            case Status.PENDING:
              return "Pending";
            case Status.DECLINE:
              return "Declined";
            case Status.UPDATED:
              return "Approved (Updated)";
            default:
              return "Unknown";
          }
        }

        Color _getBorderColor(String? status) {
          switch (status) {
            case "Approved (Updated)":
              return Colors.blue;
            case "Approved":
              return Colors.green;
            case "Pending":
              return AppColors.navButtonColor;
            case "Declined":
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
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0)),
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
                            fontSize: 18,
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
                        singleContainer(
                            "Rate Type", "${selectedDetails.daysName ?? ""}"),
                        SizedBox(height: screenHeight * 0.013),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            doubleContainer("Date",
                                formatDate("${selectedDetails.date ?? ""}")),
                            doubleContainer(
                              "Total Submitted Hours",
                              "${((double.tryParse(selectedDetails.dayShiftTime ?? '') ?? 0.00) + (double.tryParse(selectedDetails.nightShiftTime ?? '') ?? 0.00) + (double.tryParse(selectedDetails.breakTime ?? '') ?? 0.00)).toStringAsFixed(2)}",
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.013),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     doubleContainer("Day Shift Time",
                        //         "${(double.tryParse(selectedDetails.dayShiftTime ?? '') ?? 0.0).toStringAsFixed(2)}"),
                        //     doubleContainer("Night Shift Time",
                        //         "${(double.tryParse(selectedDetails.nightShiftTime ?? '') ?? 0.0).toStringAsFixed(2)}")
                        //   ],
                        // ),
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

                        // SizedBox(height: screenHeight * 0.013),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     doubleContainer("Day Shift Amount",
                        //         "£ ${(double.tryParse(selectedDetails.dayShiftCharge ?? '') ?? 0.0).toStringAsFixed(2)}"),
                        //     doubleContainer("Night Shift Amount",
                        //         "£ ${(double.tryParse(selectedDetails.nightShiftCharge ?? '') ?? 0.0).toStringAsFixed(2)}")
                        //   ],
                        // ),
                        SizedBox(height: screenHeight * 0.013),
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
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                Container(
                                  height: screenHeight * 0.04,
                                  width: screenWidth * 0.475,
                                  decoration: BoxDecoration(
                                    color: _getBorderColor(getStatusString(
                                        selectedDetails.status)),
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: _getBorderColor(getStatusString(
                                          selectedDetails.status)),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "${getStatusString(selectedDetails.status)}",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
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
        Text(
          heading,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
  void _calculateTotalAmount(List<Datum> viewDetails, Datum selectedDetails) {
    double dayTime = double.tryParse(_dayTimeControllers.text) ?? 0;
    double nightTime = double.tryParse(_nightTimeControllers.text) ?? 0;
    double expenses = double.tryParse(_expensesControllers.text) ?? 0;

    double clientDayChargeRate = double.tryParse(selectedDetails.clientDayChargeRate ?? '0') ?? 0;
    double clientNightChargeRate = double.tryParse(selectedDetails.clientNightChargeRate ?? '0') ?? 0;

    double totalAmount = (dayTime * clientDayChargeRate) + (nightTime * clientNightChargeRate) + expenses;


    _totalControllers.text = totalAmount.toStringAsFixed(2);
  }

  void _showAlertBulkUpdate(
      BuildContext context, List<Datum> viewDetails, dynamic selectedId) {
    Datum selectedDetails =
    viewDetails.firstWhere((details) => details.id == selectedId);
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    setState(() {
      _dateControllers.text = "${selectedDetails.date ?? ""}";
      _totalControllers.text = "${(double.tryParse(selectedDetails.totalCharge ?? '') ?? 0.0).toStringAsFixed(2)}";
      _expensesControllers.text = "${(double.tryParse(selectedDetails.expenses ?? '') ?? 0.0).toStringAsFixed(2)}";
      _dayTimeControllers.text ="${(double.tryParse(selectedDetails.dayShiftTime ?? '') ?? 0.0).toStringAsFixed(2)}";
      _nightTimeControllers.text ="${(double.tryParse(selectedDetails.nightShiftTime ?? '') ?? 0.0).toStringAsFixed(2)}";
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  doubleContainer1(
                    title: "Date",
                    controller: TextEditingController(text: formattedDate),
                    keyboardType: TextInputType.name,
                    errorMessage: _validationErrors['date'],
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  doubleContainer1(
                    title: "Total Amount",
                    controller: _totalControllers,
                    keyboardType: TextInputType.name,
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
              Text("Update Reason",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: screenHeight * 0.11,
                    width: screenWidth * 0.62,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColors.navButtonColor, width: 0.8),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: TextFormField(
                      controller: _updateController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      style: TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintStyle: TextStyle(fontSize: 14),
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 5, vertical: 10),
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
              },
              child: Container(
                width: screenWidth * 0.22,
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.011,
                ),
                decoration:  BoxDecoration(
                  color: AppColors.navButtonColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.white,
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
                  Utils.flushBarErrorMessage(
                      "Update reason must be required", context);
                }
              },
              child: Container(
                width: screenWidth * 0.22,
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
                    "Update",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
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
        Text(title,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
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
                borderSide: BorderSide(
                    color: AppColors.navButtonColor.withOpacity(0.4)),
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
        Text(title,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
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
                contentPadding:
                EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: AppColors.navButtonColor.withOpacity(0.4)),
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
        Text(title,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
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
                contentPadding:
                EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: AppColors.navButtonColor.withOpacity(0.4)),
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
                      border: Border.all(
                          width: 0.4, color: AppColors.navButtonColor)),
                  child: TextField(
                    controller: cancelController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'Enter rejection reason',
                      border: InputBorder.none,
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                decoration:  BoxDecoration(
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
                  print("Rejection Reason: ${cancelController.text}");

                  Utils.showDialogLoading(context);
                  _onCancel(cancelController.text);
                  cancelController.clear();
                } else {
                  Utils.flushBarErrorMessage(
                      "Rejection reason required", context);
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