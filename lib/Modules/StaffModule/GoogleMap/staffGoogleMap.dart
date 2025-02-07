import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

class StaffGoogleMaps extends StatefulWidget {
  const StaffGoogleMaps({super.key});

  @override
  State<StaffGoogleMaps> createState() => _StaffGoogleMapsState();
}

class _StaffGoogleMapsState extends State<StaffGoogleMaps> {
  late String lat;
  late String long;
  final Completer<GoogleMapController> _controller = Completer();
  static const CameraPosition _kGooglePlex =  CameraPosition(
    target: LatLng(24.887525, 90.3878622),
    zoom: 14,
  );
  List<Marker> _markers =[];
  List<Marker> _list =const [
    Marker(
        markerId: MarkerId('SomeId'),
        position: LatLng(24.887525, 90.3878622),
        infoWindow: InfoWindow(
            title: 'My Location'
        )
    )
  ];
  double? latitude; // Variable to store latitude
  double? longitude;
  String locationMessage ="Current Location Of the User";
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _markers.addAll(_list);
    _timer = Timer.periodic(Duration(minutes: 1), (Timer t) => _updateLocation());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateLocation() {
    _getCurrentLocation().then((value) {
      setState(() {
        lat ='${value.latitude}';
        long ='${value.longitude}';
        locationMessage='Latitude: $lat, Latitude: $long';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height * 1;
    final screenWidth = MediaQuery.of(context).size.width * 1;
    return Column(
      children: [
        Container(
            height: screenHeight*0.4,
            width:screenWidth*0.95 ,
            child: GoogleMap(
              initialCameraPosition: _kGooglePlex,
              mapType: MapType.normal,
              markers: Set<Marker>.of(_markers),
              onMapCreated: (GoogleMapController controller){
                _controller.complete(controller);
              },
            )
        ),
        Text(locationMessage, textAlign: TextAlign.center,),
        ElevatedButton(
          onPressed: () async {
            _getCurrentLocation().then((value) {
              lat ='${value.latitude}';
              long ='${value.longitude}';
              setState(() {
                locationMessage='Latitude: $lat, Latitude: $long';
              });
              _liveLocation();
            });
          },
          child: Text("Get Current location"),
        ),
        ElevatedButton(
          onPressed: () async {
            _openmap(lat, long);
          },
          child: Text("Open Google map"),
        ),
      ],
    );
  }

  Future<void> _openmap(String lat, String long) async {
    String googleURL ="https://www.google.com/maps/search/?api=1&query=$lat,$long";
    await canLaunchUrlString(googleURL)?
    await launchUrlString(googleURL):throw "Could not launch$googleURL";
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled= await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled){
      return Future.error("Location services are disabled");
    }
    LocationPermission permission =await Geolocator.checkPermission();
    if(permission == LocationPermission.denied){
      permission=await Geolocator.requestPermission();
      if(permission== LocationPermission.denied){
        return Future.error("Location Permission are denied");
      }
    }

    if(permission==LocationPermission.deniedForever){
      return Future.error("Location Permission are permanently denied, We cannot request");
    }
    return await Geolocator.getCurrentPosition();
  }

  void _liveLocation(){
    LocationSettings locationSettings =const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    Geolocator.getPositionStream(
        locationSettings: locationSettings
    ).listen((Position position) {
      lat= position.latitude.toString();
      long= position.longitude.toString();
      setState(() {
        locationMessage='Latitude: $lat, Latitude: $long';
      });
    });
  }
}
