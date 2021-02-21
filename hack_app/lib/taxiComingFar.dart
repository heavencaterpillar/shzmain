import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TaxiComingFar extends StatelessWidget {
  const TaxiComingFar({
    Key key,
    this.car,
    this.userPosition,
    this.userMarker,
    this.polylines
  }) : super(key: key);

  final Marker car, userMarker;
  final Map<PolylineId, Polyline> polylines;
  final LatLng userPosition;

  @override
  Widget build(BuildContext context) {
    Set<Marker> markers = {};
    markers.add(userMarker);
    markers.add(car);

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: userPosition,
        zoom: 12.0,
      ),
      zoomControlsEnabled: false,
      markers: markers,
      polylines: Set<Polyline>.of(polylines.values),
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
    );
  }
}
