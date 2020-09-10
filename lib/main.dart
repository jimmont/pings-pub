import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pings/home.dart';
import 'package:pings/login.dart';
import 'package:pings/data.dart';
import 'package:provider/provider.dart';
//import 'package:pings/translations.dart';


void main(){
	runApp(
		MyApp()
	);
}



class MyApp extends StatelessWidget{
	@override
	Widget build(BuildContext context){
		return MultiProvider(
			providers: [
				StreamProvider<User>.value(value: AuthService().user),
				StreamProvider<List<UserInfo>>.value(value: DataService().stuff),
				ChangeNotifierProvider<Meeting>.value(value: meeting),
			],

			child: MaterialApp(
				title: 'ping thing',
				home: Wrapper(),
				debugShowCheckedModeBanner: false,
				theme: ThemeData(
					brightness: Brightness.light,
					primaryColor: Colors.brown[800],
					accentColor: Colors.brown[900],
					/* TODO decipher theming and use it
					textTheme: TextTheme(
						headline1: 
					),
					*/
				),
			),
		);
	}

}

class Wrapper extends StatelessWidget{
	@override
	Widget build(BuildContext context){
		final user = Provider.of<User>(context);
		//return user != null ? Home() : Login();
		return user != null ? Home() : Login();
	}
}

