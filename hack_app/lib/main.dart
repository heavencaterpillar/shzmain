import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import 'dart:math';

import 'startActions.dart';
import 'pathSearch.dart';
import 'pathCheck.dart';
import 'waitAccept.dart';
import 'taxiComingFar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoRigator',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'AutoRiGATOR'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Set<Marker> _cars = {};
  List<LatLng> _carsPoss = [];
  List<bool> _carsMoving = [];
  List<List<LatLng>> _carsMovingPaths = [];
  List<int> _carsLastPointsNum = [];
  String stage = "start_actions";
  BitmapDescriptor carLocationIcon;
  PolylinePoints polylinePoints = PolylinePoints();
  LatLng startPoint, destPoint;

  final LatLng _center = const LatLng(50.48, 30.5);
  var rnd = new Random();
  int iter = 0;

  void initState() {
    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5),
            'assets/car_from_top_tiny_white-free.png')
        .then((onValue) {
      carLocationIcon = onValue;

      for (int i = 0; i < 15; i++) {
        setState(() {
          _carsPoss.add(new LatLng(
              _center.latitude + rnd.nextInt(1500) / 10000 - 0.075,
              _center.longitude + rnd.nextInt(1500) / 10000 - 0.075));
          _cars.add(
            Marker(
              markerId: MarkerId(i.toString()),
              position: _carsPoss[i],
              icon: carLocationIcon,
              rotation: rnd.nextInt(360).toDouble(),
            ),
          );
        });

        _carsMoving.add(true); //rnd.nextBool());
        _carsLastPointsNum.add(0);
        if (_carsMoving[i]) {
          _carsMovingPaths.add(new List<LatLng>());
          findPath(i);
        } else {
          _carsMovingPaths.add(null);
        }
      }
    });

    sleep().then((value) => func()).catchError((e) => print(e));
  }

  double len(LatLng p1, LatLng p2) {
    return pow(
        pow(p1.latitude - p2.latitude, 2) + pow(p1.longitude - p2.longitude, 2),
        0.5);
  }

  void func() {
    iter++;
    for (int i = 0; i < 15; i++) {
      if (_carsMoving[i] &&
          _carsLastPointsNum[i] < _carsMovingPaths[i].length - 1) {
        double dlat = _carsMovingPaths[i][_carsLastPointsNum[i]].latitude -
            _carsPoss[i].latitude;
        double dlong = _carsMovingPaths[i][_carsLastPointsNum[i]].longitude -
            _carsPoss[i].longitude;
        double angle = atan(dlat / dlong);
        double importantAngle =
            dlong > 0 ? 180 - angle * 180 / pi : -angle * 180 / pi;
        double importantLen =
            len(_carsPoss[i], _carsMovingPaths[i][_carsLastPointsNum[i]]);
        if (importantLen <= 0.0003) {
          _carsPoss[i] = LatLng(
              _carsMovingPaths[i][_carsLastPointsNum[i]].latitude,
              _carsMovingPaths[i][_carsLastPointsNum[i]].longitude);
          _carsLastPointsNum[i]++;
        } else {
          _carsPoss[i] = LatLng(
              _carsPoss[i].latitude + 0.0003 * dlat / importantLen,
              _carsPoss[i].longitude + 0.0003 * dlong / importantLen);
        }

        setState(() {
          _cars.removeWhere((m) => m.markerId.value == i.toString());

          _cars.add(
            Marker(
              markerId: MarkerId(i.toString()),
              position: _carsPoss[i],
              icon: carLocationIcon,
              rotation: importantAngle,
            ),
          );
        });
      }
    }

    if (carSelected > -1) {
      if (len(_carsPoss[carSelected], startPoint) < 0.002) {
        setState(() {
          stage = "taxi_coming_near";
        });
      }
    }

    sleep().then((value) => func()).catchError((e) => print(e));
  }

  Future sleep() {
    return new Future.delayed(
        const Duration(seconds: 1), () => print("All right"));
  }

  Future sleepAcceptance() {
    return new Future.delayed(
        const Duration(seconds: 3), () => stage = "taxi_coming_far");
  }

  Future<bool> findPath(i) async {
    LatLng dest = new LatLng(
        _center.latitude + rnd.nextInt(3000) / 10000 - 0.15,
        _center.longitude + rnd.nextInt(3000) / 10000 - 0.15);

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyDKjIoArzjQjTAOmf5PRN-XoqkHxqsf6-A",
      PointLatLng(_carsPoss[i].latitude, _carsPoss[i].longitude),
      PointLatLng(dest.latitude, dest.longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        _carsMovingPaths[i].add(LatLng(point.latitude, point.longitude));
      });
    } else
      _carsMoving[i] = false;
  }

  void fromSearchToCheck(LatLng start, LatLng end) async {
    setState(() {
      startPoint = start;
      destPoint = end;
      stage = "path_check";
    });
    Marker startMarker = Marker(
      markerId: MarkerId('start'),
      position: startPoint,
      infoWindow: InfoWindow(
        title: 'Start',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId('dest'),
      position: destPoint,
      infoWindow: InfoWindow(
        title: 'Destination',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    setState(() {
      markersStartAndEnd = {};
      markersStartAndEnd.add(startMarker);
      markersStartAndEnd.add(destinationMarker);
    });

    PolylinePoints polylinePoints = PolylinePoints();
    polylineCoordinates = [];
    polylines = {};

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyDKjIoArzjQjTAOmf5PRN-XoqkHxqsf6-A",
      PointLatLng(startPoint.latitude, startPoint.longitude),
      PointLatLng(destPoint.latitude, destPoint.longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    PolylineId id = PolylineId('poly');

    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.green,
      points: polylineCoordinates,
      width: 3,
    );
    setState(() {
      polylines[id] = polyline;
    });
  }

  Set<Marker> markersStartAndEnd = {};
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  int carSelected = -1;

  void findCar() async {
    double minlen = -1, templen;
    int minCar = -1;
    for (int i = 0; i < _carsPoss.length; i++) {
      templen = len(_carsPoss[i], startPoint);
      if (minCar < 0 || minlen > templen) {
        minCar = i;
        minlen = templen;
      }
    }
    carSelected = minCar;
    _carsMoving[carSelected] = true;
    _carsLastPointsNum[carSelected] = 0;
    _carsMoving[carSelected] = true;

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyDKjIoArzjQjTAOmf5PRN-XoqkHxqsf6-A",
      PointLatLng(
          _carsPoss[carSelected].latitude, _carsPoss[carSelected].longitude),
      PointLatLng(startPoint.latitude, startPoint.longitude),
      travelMode: TravelMode.driving,
    );

    _carsMovingPaths[carSelected] = List<LatLng>();

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        _carsMovingPaths[carSelected]
            .add(LatLng(point.latitude, point.longitude));
      });
    }

    PolylineId id = PolylineId('poly2');

    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.yellowAccent,
      points: _carsMovingPaths[carSelected],
      width: 3,
    );
    setState(() {
      polylines[id] = polyline;
    });
  }

  int stateNumTaxiNear = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: stage == "start_actions"
          ? StartActions(
              onButtonClick: () => {
                setState(() {
                  stage = "path_search";
                })
              },
              cars: _cars,
            )
          : stage == "path_search"
              ? PathSearch(next: fromSearchToCheck)
              : stage == "wait_accept"
                  ? WaitAcceptation()
                  : stage == "path_check"
                      ? PathCheck(
                          start: startPoint,
                          end: destPoint,
                          markers: markersStartAndEnd,
                          polylines: polylines,
                        )
                      : (stage == "taxi_coming_far" ||
                              stage == "taxi_coming_near") &&
                                  stateNumTaxiNear == 0
                          ? TaxiComingFar(
                              car: _cars.elementAt(carSelected),
                              polylines: polylines,
                              userMarker: markersStartAndEnd.elementAt(0),
                              userPosition: startPoint,
                            )
                          : stateNumTaxiNear == 1
                              ? Container(
                                  child: Text(
                                      "AR WILL BE HERE. _carsPoss[carSelected] - позиція необхідного нам таксі"))
                              : Container(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text(
                'Меню',
                textScaleFactor: 2,
              ),
              decoration: BoxDecoration(
                color: Colors.green,
              ),
            ),
            ListTile(
              title: Text('Налаштування'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: stage == "path_check"
          ? FloatingActionButton(
              onPressed: () => setState(
                  () => {stage = "wait_accept", findCar(), sleepAcceptance()}),
              tooltip: 'next',
              backgroundColor: Colors.green,
              child: const Icon(Icons.navigate_next),
            )
          : stage == "taxi_coming_near" || stage == "taxi_coming_far"
              ? (stateNumTaxiNear == 0
                  ? FloatingActionButton(
                      onPressed: () => setState(() {stateNumTaxiNear = 1;}),
                      tooltip: 'To AR',
                      backgroundColor: Colors.green,
                      child: const Icon(Icons.remove_red_eye),
                    )
                  : FloatingActionButton(
                      onPressed: () => setState(() {stateNumTaxiNear = 0;}),
                      tooltip: 'To map',
                      backgroundColor: Colors.green,
                      child: const Icon(Icons.map)))
              : null,
    );
  }
}
