import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'mapController.dart';

class PathCheck extends StatelessWidget {
  const PathCheck({
    Key key,
    this.start,
    this.end,
    this.markers,
    this.polylines
  }) : super(key: key);

  final LatLng start;
  final LatLng end;
  final Set<Marker> markers;
  final Map<PolylineId, Polyline> polylines;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng((start.latitude + end.latitude)/2, (start.longitude + end.longitude)/2),
        zoom: 13.0,
      ),
      zoomControlsEnabled: false,
      markers: markers,
      polylines: Set<Polyline>.of(polylines.values),
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
    );  //mapController();
  }
}