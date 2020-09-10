import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget{
	@override
	Widget build(BuildContext context){
	return SafeArea(
	child: Container(
		color: Colors.brown[100],
		child: Center(
			child: SpinKitRing(
				color: Colors.red,
				size: 50.0,
			)
		)
	)
	);
	}
}
