import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class WaitAcceptation extends StatelessWidget {
  const WaitAcceptation({
    Key key,
  }) : super(key: key);

  static const spinkit = SpinKitFoldingCube(
    color: Colors.green,
    size: 50.0,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        spinkit,
        SizedBox(
          height: 20,
        ),
        // Column(
        //   children: [
        //     spinkit,
        //     Text("Очікування приймання замовлення"),
        //   ],
        // ),
        Text("Очікування приймання замовлення водієм", textScaleFactor: 1.5, textAlign: TextAlign.center,),
      ],
    );
  }
}
