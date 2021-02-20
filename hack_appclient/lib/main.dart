import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'mapController.dart';

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
  List<LatLng> cars = [new LatLng(45.521563, -122.677453)];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: mapController(),
      drawer: Drawer(
         child: ListView(
           padding: EdgeInsets.zero,
           children: <Widget>[
             DrawerHeader(
               margin: const EdgeInsets.only(
                 top: 8,
                 bottom: 8,
               ),
               child: Text('Меню', textScaleFactor: 2,),
               decoration: BoxDecoration(
                 color: Colors.green,
               ),
             ),
             ListTile(
               title: Text('Я - ВОДІЙ'),
               onTap: () {

                  Navigator.pop(context);
               },
             ),
             ListTile(
               title: Text('Налаштування'),
               onTap: () {

                  Navigator.pop(context);
               },
             ),
           ],
         )
       ),
    );
  }
}
