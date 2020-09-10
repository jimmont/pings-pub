import 'package:flutter/material.dart';

class Contacts extends StatefulWidget{
  @override
  _ContactsState createState() => _ContactsState();
}

class _ContactsState extends State<Contacts>{
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(children: <Widget>[Text('contacts')])
      )
    );
  }
}
