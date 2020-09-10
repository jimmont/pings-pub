import 'package:flutter/material.dart';
import 'package:pings/data.dart';
import 'package:provider/provider.dart';
//import 'dart:developer' as dev;

class Home extends StatelessWidget{
	final AuthService _auth = AuthService();

	@override
	Widget build(BuildContext context){

		final user = Provider.of<User>(context);

		final meeting = Provider.of<Meeting>(context);

		final userList= Provider.of<List<UserInfo>>(context);

		print('userList.length is ${ userList != null ? userList.length : -1 }');


/*
	_onAudioOnlyChanged(bool value) {
		setState(() {
			isAudioOnly = value;
		});
	}

	_onAudioMutedChanged(bool value) {
		setState(() {
			isAudioMuted = value;
		});
	}

	_onVideoMutedChanged(bool value) {
		setState(() {
			isVideoMuted = value;
		});
	}
*/
		void _showSettingsPanel(){
			showModalBottomSheet(context: context, builder: (context){
				return Container(
					padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
					//child: Text('bottom sheet'),
					child: ListView(
						children: <Widget>[
							RaisedButton(
								color: Colors.brown[900],
								child: Row(
									mainAxisAlignment: MainAxisAlignment.start,
									crossAxisAlignment: CrossAxisAlignment.center,
									children: <Widget>[
										Icon(Icons.lock, color: Colors.white),
										Text('sign out',
											style:TextStyle(
												color:Colors.white,
												fontSize: 20,
												fontWeight: FontWeight.w700,
											)
										),
									],
								),
								onPressed: () async {
									Navigator.of(context).pop();
									await _auth.signOut();
								}
							),
							SettingsForm(),
						]
					),
				);
			});
		}

		List contacts;

		return StreamProvider<List<UserInfo>>.value(
			value: DataService().stuff,
			child: Scaffold(
				appBar: AppBar(
					title: Text('${ user.displayName }'),
					elevation: 0.0,
					actionsIconTheme: IconThemeData(
						size: 30.0,
						color: Colors.white,
						opacity: 10.0,
					),
					actions: <Widget>[
						FlatButton.icon(
							icon: Icon(Icons.contacts, color: Colors.white),
							label: Text(''),
							onPressed: () async {
								contacts = await _auth.getContacts();

								print('contacts: ${ contacts.length }');
							}
						)
					],
					leading: GestureDetector(
						onTap: () => _showSettingsPanel(),
						child: Icon(
							Icons.person,
						//	color: Theme.of(context).appBarTheme.actionsIconTheme.color,
						),
					),
				),
				body: Column(
						children: <Widget>[
/////
							SizedBox(
								height: 16.0,
							),
							CheckboxListTile(
								title: Text("Audio Only"),
								value: meeting.isAudioOnly,
								onChanged: meeting.onAudioOnlyChanged,
							),
							CheckboxListTile(
								title: Text("Audio Muted"),
								value: meeting.isAudioMuted,
								onChanged: meeting.onAudioMutedChanged,
							),
							CheckboxListTile(
								title: Text("Video Muted"),
								value: meeting.isVideoMuted,
								onChanged: meeting.onVideoMutedChanged,
							),
							SizedBox(
								height: 64.0,
								width: double.maxFinite,
								child: RaisedButton(
									onPressed: () {
									// TODO pass roomName !!!
										meeting.join(user, '-pt-${ DateTime.now() }');
									},
									child: Text(
										"Join Meeting",
										style: TextStyle(color: Colors.white),
									),
									color: Colors.blue,
								),
							),


/////
						/*
							Padding(
								padding: EdgeInsets.only(top: 8.0),
								child: Container(
								margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
								child: RaisedButton(
									padding: EdgeInsets.all(20.0),
									color: Colors.brown[900],
									child: Row(
										mainAxisAlignment: MainAxisAlignment.start,
										crossAxisAlignment: CrossAxisAlignment.center,
										children: <Widget>[
											Icon(Icons.contacts, color: Colors.white),
											Text('show contacts',
												style:TextStyle(
													color:Colors.white,
													fontSize: 20,
													fontWeight: FontWeight.w700,
												)
											),
										],
									),
									onPressed: () async {
										contacts = await _auth.getContacts();
										print('contacts: ${ contacts.length }');
									}
								),
								),
							),
*/
							//Text('${ user.displayName } ${ user.email } ${ user.isEmailVerified ? "👀🍔🍟❤️👍🏿☀️🌻":"🤖👾💩😷🤐" }'),
							Padding(
								padding: EdgeInsets.only(top: 8.0),
								child: Card(
									margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
									child: ListTile(
										leading: CircleAvatar(
											radius: 25.0,
					//						backgroundColor: Colors.brown[contact.isEmailVerified ? 100 : 400],
											// backgroundImage: AssetImage('path....'),
										),
										title: Text(user.displayName),
										subtitle: Text(
											'${user.email} ${user.isEmailVerified ? "👀🍔🍟❤️👍🏿☀️🌻🤖👾💩😷🤐":"🤖👾💩😷🤐" }',
											style: TextStyle(color: Colors.black.withOpacity(1.0)),
										),
									),
								),
							),
							ListView.builder(
								shrinkWrap: true,
								itemCount: contacts != null ? contacts.length : 0,
								itemBuilder: (context, index){
									return ContactTile(contact: contacts[index]);
								},
							),
							Flexible( flex: 1, child: Container( child: StuffList() ), ),
						]
				)
			)
		);
	}
}

class LocalList extends StatefulWidget{
	@override
	_LocalListState createState() => _LocalListState();
}

class _LocalListState extends State<LocalList>{
	@override
	Widget build(BuildContext context){

		//final stuff = Provider.of<QuerySnapshot>(context) ?? [];
		// fallback while loading to avoid errors
		final stuff = Provider.of<List<UserInfo>>(context) ?? [];

		if(stuff == null){
			return Text('...');
		}

		print('stuff.length is ${stuff?.length}');
		stuff.forEach((contact){
			print('~name: ${contact.name}, email ${contact.email}, verified ${contact.isEmailVerified}');
		});

		return ListView.builder(
			shrinkWrap: true,
			//physics: NeverScrollableScrollPhysics(),
			itemCount: stuff.length,
			itemBuilder: (context, index){
				return ContactTile(contact: stuff[index]);
			},
		);
	}
}


class StuffList extends StatefulWidget{
	@override
	_StuffListState createState() => _StuffListState();
}

class _StuffListState extends State<StuffList>{
	@override
	Widget build(BuildContext context){

		//final stuff = Provider.of<QuerySnapshot>(context) ?? [];
		// fallback while loading to avoid errors
		final stuff = Provider.of<List<UserInfo>>(context) ?? [];

		if(stuff == null){
			return Text('...');
		}

		print('stuff.length is ${stuff?.length}');
		stuff.forEach((contact){
			print('~name: ${contact.name}, email ${contact.email}, verified ${contact.isEmailVerified}');
		});

		return ListView.builder(
			shrinkWrap: true,
			//physics: NeverScrollableScrollPhysics(),
			itemCount: stuff.length,
			itemBuilder: (context, index){
				return ContactTile(contact: stuff[index]);
			},
		);
	}
}

class ContactTile extends StatelessWidget{
	final UserInfo contact;
	
	ContactTile({ this.contact});

	@override
	Widget build(BuildContext context){
		return Padding(
			padding: EdgeInsets.only(top: 8.0),
			child: Card(
				margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
				child: ListTile(
					leading: CircleAvatar(
						radius: 25.0,
//						backgroundColor: Colors.brown[contact.isEmailVerified ? 100 : 400],
						// backgroundImage: AssetImage('path....'),
					),
					title: Text(contact.name),
					subtitle: Text(
						'${contact.name} ${contact.email} ${contact.isEmailVerified ? "👾👍🏿":"👾"}',
						style: TextStyle(color: Colors.black.withOpacity(1.0)),
					),
				),
			),
		);
	}
}

class SettingsForm extends StatefulWidget{
	@override
	_SettingsFormState createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm>{
	final _formKey = GlobalKey<FormState>();
	final List<String> count = ['0','1','2'];

	// form values
	String _currentName;
	String _contact;
	int _currentN;

	// ui info
	String info = '';
	bool loading = false;

	final AuthService _auth = AuthService();

	@override
	Widget build(BuildContext context){

		final user = Provider.of<User>(context);

		return user == null ? Text('NO USER') : StreamBuilder<SomeModel>(
			stream: DataService(uid: user.uid).someModel,
			builder: (context, streamsnapshot){
				// wait till have some data
				if(!streamsnapshot.hasData){
					return Text('loading...');
				}

				SomeModel firestore = streamsnapshot.data;

				return Form(
					key: _formKey,
					child: Column(
						children: <Widget>[
							SizedBox(height: 20.0),
							Text('update settings',
								style: TextStyle(fontSize: 18.0),
							),
							SizedBox(height: 20.0),
							TextFormField(
								initialValue: firestore.name,
								decoration: InputDecoration(
									hintText: 'display name',
									fillColor: Colors.white,
									filled: true,
									focusedBorder: OutlineInputBorder(
										borderSide: BorderSide(color: Colors.blue, width: 2.0)
									),
									enabledBorder: OutlineInputBorder(
										borderSide: BorderSide(color: Colors.white, width: 2.0)
									)
								),
								validator: (val){
									if(val.trim().isEmpty){
										return 'please enter a name of some kind';
									}
									return null;
								},
								obscureText: false,
								onChanged: (val){
									print('changed: $val');
									setState((){
										_currentName = val;
									});
								}

							),
							/*
							SizedBox(height: 20.0),
							// dropdown
							DropdownButtonFormField(
								// can use loaded model for default
								//value: _contact ?? firestore.somekey,
								value: _contact ?? '0',
								items: count.map((n){
									return DropdownMenuItem(value: n, child: Text('$n contact'));
								}).toList(),
								onChanged: (val){
									print('changed contact $val');
									setState((){
										_contact = val;
									});
								}
							),
							// slider
							Slider(
								value: (_currentN ?? 100).toDouble(),
								min: 100,
								max: 900,
								activeColor: Colors.red,
								inactiveColor: Colors.brown,
								divisions: 8,
								onChanged: (val){
									print('slide to ${val.round()}');
									setState(()=>_currentN = val.round());
								},
							),
							*/
							RaisedButton(
								color: Colors.brown[900],
								child: Text('update', style:TextStyle(color:Colors.white)),
								onPressed: () async {
									if(loading) return;

									if(_formKey.currentState.validate()){
										print('validated()');
										// chaged, so save
										var name = (_currentName ?? '').trim();
										if(name.isNotEmpty && name != firestore.name){
											info = ('name changed from ${ firestore.name } to $name');
											print(info);

											setState((){
												loading = true;
											});

											dynamic res = await DataService(uid: user.uid).updateOptions(name);

											setState((){
												loading = false;
											});

											Navigator.pop(context);

										}else{
											info = ('name unchanged');
											Navigator.pop(context);
										}
									}else{
										info = 'please provide valid info';
									}
								}
							),
							SizedBox(height: 10.0),
						//	Text(_currentName, style: TextStyle(color:Colors.blue, fontSize: 14.0))
						]
					),
				);
			},
		);
	}
}

class MeetingForm extends StatefulWidget{
	@override
	_MeetingFormState createState() => _MeetingFormState();
}

class _MeetingFormState extends State<MeetingForm>{
	final _formKey = GlobalKey<FormState>();

	// ui info
	String info = '';
	bool loading = false;

	final meeting = Provider.of<Meeting>(context);

	@override
	Widget build(BuildContext context){


		return user == null ? Text('NO USER') : StreamBuilder<SomeModel>(
			stream: DataService(uid: user.uid).someModel,
			builder: (context, streamsnapshot){
				// wait till have some data
				if(!streamsnapshot.hasData){
					return Text('loading...');
				}

				SomeModel firestore = streamsnapshot.data;

				return Form(
					key: _formKey,
					child: Column(
						children: <Widget>[
						]
					),
				);
			},
		);
	}
}
