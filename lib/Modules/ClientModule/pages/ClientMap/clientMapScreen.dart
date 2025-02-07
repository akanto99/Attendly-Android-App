import 'dart:async';
import 'dart:io';
import 'package:c9_app/Modules/ClientModule/client_screen.dart';
import 'package:c9_app/Modules/ClientModule/model/MapModelClient/MapModelClients.dart';
import 'package:c9_app/loadingScreen.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/utils/routes/routes_name.dart';
import 'package:c9_app/view/widgets/error_logout.dart';
import 'package:c9_app/view_model/services/rolebasedmodel/user_view_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:c9_app/res/app_url.dart';

import '../noInternetConnectionWidget.dart';

class GoogleMapsAllListClient extends StatefulWidget {
  const GoogleMapsAllListClient({Key? key}) : super(key: key);

  @override
  State<GoogleMapsAllListClient> createState() => _GoogleMapsAllListClientState();
}

class _GoogleMapsAllListClientState extends State<GoogleMapsAllListClient> with WidgetsBindingObserver {
  late Future<ClientAllMapMarkerModel?> _mapApiFuture;
  final Completer<GoogleMapController> _controller = Completer();
  List<Marker> _markers = [];
  late Timer _timer;

  bool _showNoInternetConnectionMessage = false;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _mapApiFuture = _fetchMapData();
    _startTimer();

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
    WidgetsBinding.instance.removeObserver(this);
    _timer.cancel(); // Cancel the timer to prevent memory leaks
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(minutes: 5), (timer) {
      setState(() {
        _mapApiFuture = _fetchMapData(); // Refresh the map data
      });
    });
  }

  Future<ClientAllMapMarkerModel?> _fetchMapData() async {
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

      final String apiUrl = '${AppUrl.baseUrl}/api/app/staff/location';
      final response = await http.get(Uri.parse(apiUrl), headers: {
        'Authorization': 'Bearer $_token',
      });

      if (response.statusCode == 200) {
        return clientAllMapMarkerModelFromJson(response.body);
      } else {
        throw Exception('Failed to load location data');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userPrefernece = Provider.of<UserViewModel>(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: _showNoInternetConnectionMessage ? Colors.red : AppColors.navColor,
    ));
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return Scaffold(
      body: _showNoInternetConnectionMessage
          ? NoInternetConnection()
          : FutureBuilder<ClientAllMapMarkerModel?>(
              future: _mapApiFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: screenHeight,
                    width: screenWidth,
                    color: AppColors.whiteColor,
                    child: LoadingScreen(),
                  );
                } else if (snapshot.hasError) {
                  return  Text("");
                  //   Column(
                  //   children: [
                  //     SizedBox(height: screenHeight*0.2,),
                  //     Expanded(
                  //       child: ErrorLogOutScreen(
                  //         screenHeight: screenHeight,
                  //         screenWidth: screenWidth,
                  //         errorMessage: 'Oops! Something went wrong.',
                  //         subMessage: 'Try logging out and back in.',
                  //         icon: CupertinoIcons.exclamationmark_circle,
                  //
                  //         buttonText: 'Logout',
                  //         onButtonPressed: () {
                  //           userPrefernece.remove().then((value){
                  //             Navigator.pushNamed(context, RoutesName.login);
                  //           });
                  //         },
                  //       ),
                  //     ),
                  //   ],
                  // );
                } else {
                  final List<Datum>? dataList = snapshot.data?.data;
                  if (dataList != null && dataList.isNotEmpty) {
                    // _markers = dataList.map((datum) {
                    //   double latitude = double.tryParse(datum.latitude ?? "0") ?? 0.0;
                    //   double longitude = double.tryParse(datum.longitude ?? "0") ?? 0.0;
                    //   return Marker(
                    //     markerId: MarkerId(datum.slug ?? ""),
                    //     position: LatLng(latitude, longitude),
                    //     infoWindow: InfoWindow(
                    //       // Display firstName in the marker name
                    //       title: '${datum.firstName ?? ""} ${datum.lastName ?? ""}',
                    //     ),
                    //   );
                    // }).toList();

                    _markers = dataList.where((datum) {
                      double? latitude = double.tryParse(datum.latitude ?? "");
                      double? longitude = double.tryParse(datum.longitude ?? "");
                      return latitude != null && longitude != null && latitude != 0 && longitude != 0;
                    }).map((datum) {
                      return Marker(
                        markerId: MarkerId(datum.slug ?? ""),
                        position: LatLng(
                          double.parse(datum.latitude!),
                          double.parse(datum.longitude!),
                        ),
                        infoWindow: InfoWindow(
                          title: '${datum.firstName ?? ""} ${datum.lastName ?? ""}',
                        ),
                      );
                    }).toList();

                  }

                  return _buildMapWithMarkers(snapshot);
                }
              },
            ),
    );
  }

  // Widget _buildMapWithMarkers(AsyncSnapshot<ClientAllMapMarkerModel?> snapshot) {
  //   return GoogleMap(
  //     mapType: MapType.normal,
  //     initialCameraPosition: CameraPosition(
  //       target: _markers.isNotEmpty ? _markers.first.position : LatLng(0, 0),
  //       zoom: 10,
  //     ),
  //     markers: Set<Marker>.of(_markers),
  //     onMapCreated: (GoogleMapController controller) {
  //       _controller.complete(controller);
  //     },
  //   );
  // }

  Widget _buildMapWithMarkers(AsyncSnapshot<ClientAllMapMarkerModel?> snapshot) {
    final LatLng defaultPosition = LatLng(0, 0);
    final double defaultZoom = 0.0;

    LatLng initialPosition;
    double initialZoom;

    if (_markers.isNotEmpty) {
      initialPosition = _markers.first.position;
      initialZoom = 10.0;
    } else {
      initialPosition = defaultPosition;
      initialZoom = defaultZoom;
    }

    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: initialZoom,
      ),
      markers: Set<Marker>.of(_markers),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
    );
  }

}
