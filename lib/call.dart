import 'package:flutter/material.dart';

class Call extends StatefulWidget{
  @override
  _CallState createState() => _CallState();
}

class _CallState extends State<Call>{
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(children: <Widget>[Text('call')])
      )
    );
  }
}

