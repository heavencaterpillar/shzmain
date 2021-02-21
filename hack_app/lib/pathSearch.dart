import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PathSearch extends StatefulWidget {
  const PathSearch({
    Key key,
    this.next
  }) : super(key: key);

  final Function next;

  @override
  _PathSearchState createState() => _PathSearchState(next);
}

class _PathSearchState extends State<PathSearch> {
  _PathSearchState(Function next){
    this.next = next;
  }
  Function next;

  int stage = 1;
  String startPointAddress = "";
  String destPointAddress = "";
  List<Address> searchRess = List<Address>();
  List<Widget> searchRessTiles = List<Widget>();
  LatLng startPoint;
  final sourceAddressController = TextEditingController();
  LatLng destPoint;
  final destAddressController = TextEditingController();

  void chooseSourceByID(int id) {
    setState(() {
      stage = 2;
      startPointAddress = searchRess[id].addressLine;
      startPoint = LatLng(searchRess[id].coordinates.latitude,
          searchRess[id].coordinates.longitude);

      sourceAddressController.text = startPointAddress;
      searchRess = List<Address>();
      searchRessTiles = List<Widget>();
    });
  }

  void chooseDestByID(int id) {
    setState(() {
      destPointAddress = searchRess[id].addressLine;
      destPoint = LatLng(searchRess[id].coordinates.latitude,
          searchRess[id].coordinates.longitude);

      destAddressController.text = destPointAddress;
      searchRess = List<Address>();
      searchRessTiles = List<Widget>();
    });

    next(startPoint, destPoint);
  }

  void _getDestAddressFunction() async {
    _getDestAddress().then((item) =>
    {
      setState(() {
        for (int i = 0; i < searchRess.length; i++)
          searchRessTiles.add(
            GestureDetector(
              child: Card(
                child: ListTile(
                  title: Text(searchRess[i].addressLine),
                ),
              ),
              onTap: () => chooseDestByID(i),
            ),
          );
      })
    });
  }

  void _getAddressFunction() async {
    _getSourceAddress().then((item) =>
    {
      setState(() {
        for (int i = 0; i < searchRess.length; i++)
          searchRessTiles.add(
            GestureDetector(
              child: Card(
                child: ListTile(
                  title: Text(searchRess[i].addressLine),
                ),
              ),
              onTap: () => chooseSourceByID(i),
            ),
          );
      })
    });
  }

  Future<void> _getSourceAddress() async {
    try {
      List<Address> p;
      // Places are retrieved using the coordinates
      await Geocoder.google("AIzaSyDKjIoArzjQjTAOmf5PRN-XoqkHxqsf6-A")
          .findAddressesFromQuery(startPointAddress)
          .then((val) =>
      {
        p = val,
      });

      setState(() {
        searchRess = p;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _getDestAddress() async {
    try {
      List<Address> p;
      // Places are retrieved using the coordinates
      await Geocoder.google("AIzaSyDKjIoArzjQjTAOmf5PRN-XoqkHxqsf6-A")
          .findAddressesFromQuery(destPointAddress)
          .then((val) =>
      {
        p = val,
      });

      setState(() {
        searchRess = p;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        color: Colors.white,
        padding:
        EdgeInsets.only(left: 20.0, right: 20.0, top: 0.0, bottom: 20.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Оберіть початкову точку',
                labelText: 'Звідки їдемо?',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _getAddressFunction,
                  color: Colors.green,
                ),
              ),
              controller: sourceAddressController,
              onChanged: (value) {
                startPointAddress = value;
              },
            ),
            stage > 1
                ? TextField(
              decoration: InputDecoration(
                hintText: 'Оберіть кінцеву точку',
                labelText: 'Куди їдемо?',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _getDestAddressFunction,
                  color: Colors.green,
                ),
              ),
              controller: destAddressController,
              onChanged: (value) {
                destPointAddress = value;
              },
            )
                : Container(),
          ],
        ),
      ),
      Container(
        color: Colors.grey[50],
        child: searchRessTiles.length > 0
            ? Column(
          children: [
            SizedBox(height: 10),
            Text("Результати пошуку"),
            ...searchRessTiles
          ],
        )
            : stage == 1
            ? Column(children: [
          SizedBox(height: 10),
          Text("Ввeдіть, будь ласка, назву початкового пункту"),
        ])
            : Column(children: [
          SizedBox(height: 10),
          Text("Ввeдіть, будь ласка, назву кінцевого пункту"),
        ]),
      )
    ]);
  }
}
