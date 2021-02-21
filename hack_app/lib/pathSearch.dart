import 'package:flutter/material.dart';

class PathSearch extends StatelessWidget {
  const PathSearch({
    Key key,
  }) : super(key: key);

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
                suffixIcon: Icon(Icons.mic_rounded),
              ),
            ),
            TextField(
              decoration: InputDecoration(
                hintText: 'Оберіть кінцеву точку',
                labelText: 'Куди їдемо?',
                suffixIcon: Icon(Icons.mic_rounded),
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}
