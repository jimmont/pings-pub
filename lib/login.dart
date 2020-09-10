import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pings/data.dart';
import 'package:pings/loading.dart';

class Login extends StatefulWidget{
	@override
	_LoginState createState() => _LoginState();
}

class _LoginState extends State<Login>{

	final AuthService _auth = AuthService();

	String info = 'please sign in';
	bool loading = false;

	@override
	Widget build(BuildContext context){
		return loading ? Loading() : Scaffold(
			backgroundColor: Colors.brown[700],
			appBar: AppBar(
				backgroundColor: Colors.brown[900],
				elevation: 0.0,
				title: Text('sign in'),
				leading: Icon(Icons.person)
			)
			, body: Container(
				padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
				child: Column(
					children: <Widget>[
						Text('$info',
							style:TextStyle( color:Colors.white, ),

						),
						SizedBox(height: 20.0),
						RaisedButton(
							color: Colors.white,
							child: Row(
								mainAxisAlignment: MainAxisAlignment.start,
								crossAxisAlignment: CrossAxisAlignment.center,
								children: <Widget>[
								SvgPicture.asset(
									'lib/art.svg',
									width: 50,
									height: 50,
									fit: BoxFit.fill,
									allowDrawingOutsideViewBox: true,
									matchTextDirection: true,
								),
								Text('Google sign in',
									style:TextStyle(
										color:Colors.black,
										fontSize: 20,
										fontWeight: FontWeight.w700,
									)
								),
								],
							),
							onPressed: () async {
								setState(()=> loading = true);
								dynamic res = await _auth.signInGoogle();
								if(res == null){
									setState((){
										info = 'sign in failed, please try again';
										loading = false;
									});
								}
							}
						),
					] // children
				),
			), // column
		);
	}
}
