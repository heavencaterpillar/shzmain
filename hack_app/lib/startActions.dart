import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'mapController.dart';

class StartActions extends StatelessWidget {
  const StartActions({
    Key key,
    this.cars,
    this.onButtonClick,
  }) : super(key: key);

  final Function onButtonClick;
  final Set<Marker> cars;

  final LatLng _center = const LatLng(50.48, 30.5);

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 11.0,
        ),
        zoomControlsEnabled: false,
        markers: cars,
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
      ),
      new Positioned(
        left: 20.0,
        right: 20.0,
        bottom: 20.0,
        child: FlatButton(
          color: Colors.green,
          onPressed: onButtonClick,
          child: Text('Замовити машину'),
        ),
      ),
    ]);
  }
}
