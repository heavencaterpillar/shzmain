import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

Future<Uint8List> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
}

class mapController extends StatefulWidget {
  @override
  _mapControllerPageState createState() => _mapControllerPageState();
}

class _mapControllerPageState extends State<mapController> {
  GoogleMapController mapController;
  BitmapDescriptor pinLocationIcon;

  final LatLng _center = const LatLng(45.521563, -122.677433);
  LatLng pinPosition = LatLng(45.521564, -122.677431);

  Set<Marker> _markers = {};
  void initState() {
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/car_from_top_tiny_white-free.png').then((onValue) {
      pinLocationIcon = onValue;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    setState(() {
      _markers.add(
          Marker(
              markerId: MarkerId('1'),
              position: pinPosition,
              icon: pinLocationIcon
          )
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 11.0,
        ),
      zoomControlsEnabled: false,
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
    );
  }
}