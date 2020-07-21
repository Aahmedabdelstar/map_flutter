import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import './location.dart';


import 'dart:ui' as ui;

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class theMapClass extends StatefulWidget {

  @override
  _theMapClassState createState() => _theMapClassState();
}



class _theMapClassState extends State<theMapClass> {

  static double deviceLongitude;
  static double deviceLatitude;
  double onMoveLatitude;
  double onMoveLongitude;
  double onTapLatitude;
  double onTapLongitude;
  Widget pinMark;
  static final double _zoom = 15.3;
  Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = Set();


  /// to get phone location
  void getLocation() async {
    Location location = Location();
    await location.getCurrentLocation();
    print(location.longtude);
    print(location.latitude);
    setState(() {
      deviceLongitude=location.longtude;
      deviceLatitude=location.latitude;
      print('my phone location lat is ${deviceLatitude.toString()}');
      print('my phone location long  is ${deviceLongitude.toString()}');
    });
  }

  /// to open google maps in determined Location
  static Future<void> openGoogleMapApp({double latitude, double longitude}) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
      print('opnenig');
    } else {
      throw 'Could not open the map.';
    }}

  /// do any thing when camera moving
  whenMapCameraMoving(result){
    setState(() {
      onMoveLatitude = result.target.latitude;
      onMoveLongitude = result.target.longitude;
      print('lat  on moving map  is ${onMoveLatitude.toString()}');
      print('long  on moving map is ${onMoveLongitude.toString()}');


    });
  }

  /// do any thing when camera Stop moving
  whenMapCameraStopMoving(result){
    setState(() {
      onMoveLatitude = result.target.latitude;
      onMoveLongitude = result.target.longitude;
      print('lat  on moving map  is ${onMoveLatitude.toString()}');
      print('long  on moving map is ${onMoveLongitude.toString()}');

    });
  }

  /// to make map camera move  to phone location
  Future<void> _goToMyLocation() async {
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(deviceLatitude, deviceLongitude), _zoom));
    setState(() {
      _markers.add(
        Marker(
            markerId: MarkerId('phoneLocation'),
            position: LatLng(deviceLatitude, deviceLongitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              30.0,
            ),
            alpha: 0.0,
            infoWindow: InfoWindow(
              title: 'My location',
            )),
      );
    });
  }

  /// this function do map camera move  when tap on map
  Future<void> _goToTapLocation(LatLng latLng) async {
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(
            target: latLng,
            zoom: 15.3
        )));
  }

  /// to convert img  to mack pin mark
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();


  }

  /// to move map camera to determined Location and put Marker
  Future<void> movingMapCameraAndPutMark({double latitude,double longitude}) async {
    final Uint8List markerIcon = await getBytesFromAsset('assets/mar.png', 90);
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('mark'),
          position: LatLng(latitude, longitude),
          alpha: 0.9,
          icon: BitmapDescriptor.fromBytes(markerIcon),

        ),
      );
    });
  }


  @override
  void initState() {
    /// to get phone location
    getLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: <Widget>[
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition:  CameraPosition (
                target: LatLng (
                  deviceLatitude,
                  deviceLongitude,
                ),
                zoom: _zoom,
              ),
              markers: _markers,
              padding: EdgeInsets.all(60.0),
              myLocationButtonEnabled: false,
              myLocationEnabled: true,

              onMapCreated: (GoogleMapController controller) async{
                _controller.complete(controller);
              },

              onCameraMove: (result) async{
                whenMapCameraMoving(result);
              },
              onCameraIdle:(){

                /// when map camera stop moving
                // do any thing here
                movingMapCameraAndPutMark(latitude: onTapLatitude,longitude: onTapLongitude);
              },
              onTap: (latLng) {
                /// when tap location on map
                _goToTapLocation(latLng);
                onTapLatitude=latLng.latitude;
                onTapLongitude=latLng.longitude;
                debugPrint('on tap latitude is =${onTapLatitude.toString()}  on tap longitude is = ${onTapLongitude.toString()}, ');
              },


            ),
            /// my location button
            Positioned(
              bottom: 0.0,
              height: 50.0,
              width: 50.0,
              right: 22.0,
              child: FloatingActionButton.extended(
                onPressed: () {
                  setState(() {
                    _goToMyLocation();
                  });
                },
                label: Icon(
                  Icons.near_me,
                  size: 25.0,
                ),
                elevation: 0.5,
              ),
            ),
            // to go coustomer Location
            Positioned(
              bottom: 0.0,
              height: 50.0,
              width: 50.0,
              left: 22.0,
              child: FloatingActionButton.extended(
                onPressed: () {
                  setState(() {
                    openGoogleMapApp(latitude: onMoveLatitude,longitude: onMoveLongitude);
                  });
                },
                label: Icon(
                  Icons.near_me,
                  size: 25.0,
                ),
                elevation: 0.5,
              ),
            ),
            /// pin mark loading
            Center(
              child: Icon(
                Icons.near_me,
                size: 25.0,
              ),
            )
          ],
        ),
      ),
    );
  }

}