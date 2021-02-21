// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'dart:async';
//
// class mapController extends StatefulWidget {
//   @override
//   _mapControllerPageState createState() => _mapControllerPageState();
// }
//
// class _mapControllerPageState extends State<mapController> {
//   GoogleMapController mapController;
//
//   final LatLng _center = const LatLng(50.48, 30.5);
//   LatLng pinPosition = LatLng(50.48776, 30.51);
//
//   Set<Marker> _markers = {};
//
//   void _onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//
//     setState(() {
//       _markers.add(Marker(
//           markerId: MarkerId('1'),
//           position: pinPosition,
//           icon: pinLocationIcon));
//     });
//
//     sleep1().then((value) => func()).catchError((e) => print(e));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GoogleMap(
//       onMapCreated: _onMapCreated,
//       initialCameraPosition: CameraPosition(
//         target: _center,
//         zoom: 11.0,
//       ),
//       zoomControlsEnabled: false,
//       markers: _markers,
//       myLocationEnabled: true,
//       myLocationButtonEnabled: false,
//     );
//   }
// }
