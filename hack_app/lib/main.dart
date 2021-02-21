import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import 'dart:math';

import 'startActions.dart';
import 'pathSearch.dart';
import 'waitAccept.dart';

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

  final LatLng _center = const LatLng(50.48, 30.5);
  var rnd = new Random();
  int iter = 0;

  void initState() {
    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5),
            'assets/car_from_top_tiny_white-free.png')
        .then((onValue) {
      carLocationIcon = onValue;

      for (int i = 0; i < 5; i++) {
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
    for (int i = 0; i < 5; i++) {
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

    sleep().then((value) => func()).catchError((e) => print(e));
  }

  Future sleep() {
    return new Future.delayed(
        const Duration(seconds: 1), () => print("All right"));
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
              ? PathSearch()
              : stage == "wait_accept"
                  ? WaitAcceptation()
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
      floatingActionButton: stage == "path_search"
          ? FloatingActionButton(
              onPressed: () => setState(() => stage = "wait_accept"),
              tooltip: 'next',
              backgroundColor: Colors.green,
              child: const Icon(Icons.navigate_next),
            )
          : null,
    );
  }
}
