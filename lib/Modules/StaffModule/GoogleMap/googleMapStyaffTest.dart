import 'dart:async';
import 'dart:io';

import 'package:c9_app/Modules/ClientModule/pages/noInternetConnectionWidget.dart';
import 'package:c9_app/Modules/StaffModule/DashBoard/staff_navigationScreen.dart';
import 'package:c9_app/Modules/StaffModule/MODEL/MapApiModel/mapApi.dart';
import 'package:c9_app/loadingScreen.dart';
import 'package:c9_app/res/app_url.dart';
import 'package:c9_app/res/color.dart';
import 'package:c9_app/utils/routes/routes_name.dart';
import 'package:c9_app/view/widgets/error_logout.dart';
import 'package:c9_app/view_model/services/rolebasedmodel/user_view_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as https;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

class LocationProvider with ChangeNotifier {

  double _latitude = 0.0;
  double _longitude = 0.0;

  double get latitude => _latitude;
  double get longitude => _longitude;

  late Timer _timer;
  late String lat;
  late String long;
  String locationMessage = "Current Location Of the User";

  LocationProvider() {
    _updateLocation();
    _timer = Timer.periodic(Duration(minutes: 5), (Timer t) => _updateLocation());
    // _timer = Timer.periodic(Duration(minutes: 5), (Timer t) => _updateLocation());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _updateLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
          // If permission is denied, request permission again
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        // Permission still denied, handle accordingly
        print('Permission denied by user.');
        return;
      }


      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _latitude = position.latitude;
      _longitude = position.longitude;
      await postCurrentLocation(_latitude.toString(), _longitude.toString());
      notifyListeners();
      getCurrentLocation();
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  Future<void> postCurrentLocation(String latitude, String longitude) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';

    try {
      String apiUrl = '${AppUrl.baseUrl}/api/app/update-location';
      var request = https.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers.addAll({
        'Authorization': 'Bearer $_token',
      });
      request.fields['latitude'] = latitude;
      request.fields['longitude'] = longitude;
      var response = await request.send();
      if (response.statusCode == 200) {
        print('Data submitted successfully');
        print('Individual latitude: $latitude');
        print('Individual longitude: $longitude');
      } else {
        print('Failed to submit data. Status code: ${response.statusCode}');
        print('Individual latitude: $latitude');
        print('Individual longitude: $longitude');
      }
    } catch (e) {
      print('Error during data submission: $e');
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        // desiredAccuracy: LocationAccuracy.high,
      );
      lat = position.latitude.toString();
      long = position.longitude.toString();
      locationMessage = 'Latitude: $lat, Longitude: $long';
      notifyListeners();
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  void startLocationUpdate() {
    _timer = Timer.periodic(Duration(minutes: 5), (Timer t) => getCurrentLocation());
  }

  void stopLocationUpdate() {
    _timer.cancel();
  }

  void openMap() async {
    String googleURL = "https://www.google.com/maps/search/?api=1&query=$_latitude,$_longitude";
    await canLaunchUrlString(googleURL) ? await launchUrlString(googleURL) : throw "Could not launch $googleURL";
  }

  void updateCameraPosition(GoogleMapController controller, double latitude, double longitude) {
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 20, // You can adjust the zoom level as needed
        ),
      ),
    );
  }
}

class GoogleMapsStaffTest extends StatefulWidget {
  @override
  State<GoogleMapsStaffTest> createState() => _GoogleMapsStaffTestState();
}

class _GoogleMapsStaffTestState extends State<GoogleMapsStaffTest>with WidgetsBindingObserver{
  late Future<MapApiget?> _mapApiFuture;
  final Completer<GoogleMapController> _controller = Completer();
  List<Marker> _markers = [];
  late Timer _timer;
  late MapApiget _mapData; // Define a variable to store snapshot data


  bool _showNoInternetConnectionMessage = false;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _mapApiFuture = _fetchMapData();
    _startTimer();
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
    _timer.cancel();
    _connectivitySubscription.cancel();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        _mapApiFuture = _fetchMapData();
      });
    }
    super.didChangeDependencies();
  }


  void _startTimer() {
    _timer = Timer.periodic(Duration(minutes: 5), (timer) {
      setState(() {
        _mapApiFuture = _fetchMapData(); // Refresh the map data
      });
    });
  }


  Future<MapApiget?> _fetchMapData() async {
    // First check user's network connectivity
    var connectivityResult = await (Connectivity().checkConnectivity());
    bool hasInternet = await _hasInternetConnection();

    if (connectivityResult == ConnectivityResult.none || !hasInternet) {
      setState(() {
        _showNoInternetConnectionMessage = true;
      });
      return null;
    } else {
      // Fetch device's current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double deviceLatitude = position.latitude;
      double deviceLongitude = position.longitude;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String _token = prefs.getString('token') ?? '';

      final String apiUrl = '${AppUrl.baseUrl}/api/app/location';
      final response = await https.get(Uri.parse(apiUrl), headers: {
        'Authorization': 'Bearer $_token',
      });

      if (response.statusCode == 200) {
        MapApiget mapData = mapApigetFromJson(response.body);

        // Update the map's initial location to device location
        setState(() {
          _mapData = mapData;
          _mapData.location.latitude = deviceLatitude.toString();
          _mapData.location.longitude = deviceLongitude.toString();
        });

        return _mapData;
      } else {
        throw Exception('Failed to load location data');
      }
    }
  }
  // Future<MapApiget?> _fetchMapData() async {
  //   // first check user's network connectivity
  //   var connectivityResult = await (Connectivity().checkConnectivity());
  //   bool hasInternet = await _hasInternetConnection();
  //
  //   if(connectivityResult == ConnectivityResult.none || !hasInternet){
  //     // show No internet connection
  //     setState(() {
  //       _showNoInternetConnectionMessage = true;
  //     });
  //      return null;
  //   }else{
  //
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     String _token = prefs.getString('token') ?? '';
  //
  //     final String apiUrl = '${AppUrl.baseUrl}/api/app/location';
  //     final response = await https.get(Uri.parse(apiUrl), headers: {
  //       'Authorization': 'Bearer $_token',
  //     });
  //
  //     if (response.statusCode == 200) {
  //       return mapApigetFromJson(response.body);
  //     } else {
  //       throw Exception('Failed to load location data');
  //     }
  //   }
  //
  // }

  @override
  Widget build(BuildContext context) {
    final userPrefernece = Provider.of<UserViewModel>(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: _showNoInternetConnectionMessage ? Colors.red : AppColors.navColor,
    ));
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return Scaffold(
      body:_showNoInternetConnectionMessage ? NoInternetConnection(): SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: screenHeight * 0.8,
              width: screenWidth,
              child: FutureBuilder<MapApiget?>(
                future: _mapApiFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      height: screenHeight*0.8,
                      width: screenWidth,
                      color: AppColors.whiteColor,
                      child: LoadingScreen(),
                    );
                  } else if (snapshot.hasError) {
                    return Text("");
                  } else {
                    _mapData = snapshot.data!;
                    Location location = _mapData.location;
                    double latitude = double.tryParse(location.latitude ?? "0") ?? 0.0;
                    double longitude = double.tryParse(location.longitude ?? "0") ?? 0.0;
                    Marker marker = Marker(
                      markerId: MarkerId(location.slug ?? ""),
                      position: LatLng(latitude, longitude),
                      infoWindow: InfoWindow(
                        title: '${location.firstName ?? ""} ${location.lastName ?? ""}',
                      ),
                    );
                    Set<Marker> markers = {marker};
                    return _buildMapWithMarkers(markers);
                  }
                },
              ),
            ),
            SizedBox(height: screenHeight * 0.013,),
            Consumer<LocationProvider>(
              builder: (context, locationProvider, child) {
                return Column(
                  children: [
                    Container(
                      width: screenWidth * 0.95,
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        border: Border.all(
                          color: AppColors.navButtonColor.withOpacity(0.4),
                          width: 0.4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            offset: Offset(0, 2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: screenHeight * 0.013,),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                      locationProvider.getCurrentLocation();
                                      final googleMapController = await _controller.future;
                                      double latitude = double.tryParse(_mapData.location.latitude ?? "0") ?? 0.0;
                                      double longitude = double.tryParse(_mapData.location.longitude ?? "0") ?? 0.0;
                                      locationProvider.updateCameraPosition(googleMapController, latitude, longitude);
                                       } ,
                                      child: Container(
                                        height: screenHeight * 0.05,
                                        width: screenWidth * 0.12,
                                        decoration: BoxDecoration(
                                          color: AppColors.navButtonColor,
                                          border: Border.all(
                                            color: AppColors.navButtonColor.withOpacity(0.4),
                                            width: 0.4,
                                          ),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: Icon(Icons.location_on_outlined, color: AppColors.whiteColor,),
                                      ),
                                    ),
                                    SizedBox(width: screenWidth * 0.007,),
                                    GestureDetector(
                                      onTap: () async {
                                        final googleMapController = await _controller.future;
                                        double latitude = double.tryParse(_mapData.location.latitude ?? "0") ?? 0.0;
                                        double longitude = double.tryParse(_mapData.location.longitude ?? "0") ?? 0.0;
                                        locationProvider.updateCameraPosition(googleMapController, latitude, longitude);
                                      },
                                      child: Container(
                                        height: screenHeight * 0.05,
                                        width: screenWidth * 0.30,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "Get Location",
                                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navButtonColor, fontSize: 15),
                                          ),
                                        ),
                                      ),
                                    )

                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(height: screenHeight * 0.05, width: screenWidth * 0.30, child: Align(
                                        alignment: Alignment.centerRight, child: Text("Open Map", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.blueColor, fontSize: 15),)),
                                    ),
                                    SizedBox(width: screenWidth * 0.007,),
                                    GestureDetector(
                                      onTap: () => locationProvider.openMap(),
                                      child: Container(
                                        height: screenHeight * 0.05,
                                        width: screenWidth * 0.12,
                                        decoration: BoxDecoration(
                                          color: AppColors.whiteColor,
                                          border: Border.all(
                                            color: AppColors.navButtonColor.withOpacity(0.4),
                                            width: 0.4,
                                          ),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: Icon(Icons.map, color: AppColors.blueColor,),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.013,),
                          GestureDetector(
                            onTap: () => locationProvider.openMap(),
                            child: Container(
                                height: screenHeight * 0.045,
                                width: screenWidth * 0.90,
                                decoration: BoxDecoration(
                                  color: AppColors.navOpacity.withOpacity(0.2),
                                  border: Border.all(
                                    color: AppColors.navButtonColor.withOpacity(0.4),
                                    width: 0.4,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Center(child: Text(locationProvider.locationMessage, textAlign: TextAlign.center),)
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.013,),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.1,),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  void _updateMapCamera(GoogleMapController controller, double latitude, double longitude) {
    controller.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(latitude, longitude),
      ),
    );
  }

  Widget _buildMapWithMarkers(Set<Marker> markers) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: markers.isNotEmpty ? markers.first.position : LatLng(0, 0),
        zoom: 10,
      ),
      markers: markers,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
         if(_mapData != null){
          _updateMapCamera(controller, double.parse(_mapData.location.latitude!), double.parse(_mapData.location.longitude!));
        }
      },
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
        ),
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      compassEnabled: true,
      zoomControlsEnabled: true,

    );
  }
}

