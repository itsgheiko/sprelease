import 'package:flutter/material.dart';

class AppBarButton extends StatelessWidget {
  Function function;
  String title;

  AppBarButton({@required this.function, @required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 10, 10, 10),
      padding: EdgeInsets.only(left: 5, right: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).accentColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextButton(
        onPressed: () => function(),
        child: Text(
          title,
          style: TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
