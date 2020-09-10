import 'dart:io';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart'; 

import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:jitsi_meet/jitsi_meeting_listener.dart';
import 'package:jitsi_meet/room_name_constraint.dart';
import 'package:jitsi_meet/room_name_constraint_type.dart';
import 'package:jitsi_meet/feature_flag/feature_flag_enum.dart';


class AuthService{
	final FirebaseAuth _auth = FirebaseAuth.instance;
	final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

	User _userFromFirebase(FirebaseUser user){
		return user != null ? User.fromMap(user) : null;
	}

	// auth change stream
	Stream<User> get user{
		return _auth.onAuthStateChanged
			.map(_userFromFirebase);
			//.map((FirebaseUser user) => _userFromFirebase(user));
	}

	Future signOut() async {
		try{
			return await _auth.signOut();
		}catch(err){
			print(err.toString());
			return null;
		}
	}

	Future signInGoogle() async {
		try {
		// 1st sign in w/ Google
		// 2nd sign in w/ that token to Firebase
			GoogleSignInAccount googleUser = await _googleSignIn.signIn();
			GoogleSignInAuthentication googleAuth = await googleUser.authentication;
			AuthCredential credential = GoogleAuthProvider.getCredential(
				accessToken: googleAuth.accessToken,
				idToken: googleAuth.idToken
			);
			FirebaseUser fuser = (await _auth.signInWithCredential(credential)).user;
			User user = _userFromFirebase(fuser);
			await DataService(uid: user.uid).updateUser(user);
			return user;
		} catch(err){
			print(err.toString());
			return null;
		}
	}

	Future permitContacts() async {
		try{
			var status = await Permission.contacts.status;
			if(status.isUndetermined){
				status = await Permission.contacts.request();
			}
			if(status.isGranted){
				return true;
			}
		}catch(err){
			print(err.toString());
		}
		return false;
	}

	Future getContacts() async {

		bool permission = await permitContacts();

		if(permission == false) return [];

		Iterable<Contact> contacts = await ContactsService.getContacts();

		return contacts.toList();
	}
}
// can expose globally
final AuthService authService = AuthService();



class DataService{
	final String uid;
	final Firestore _db = Firestore.instance;
	final CollectionReference usersCollection = Firestore.instance.collection('users');

	DataService({ this.uid });

	Future updateUser(User user) async {
		return await usersCollection.document(uid).setData({
			'displayName': user.displayName,
			'email': user.email,
			'isEmailVerified': user.isEmailVerified,
			'lastSeen': DateTime.now(),
		}, merge: true);
	}

	Future updateOptions(String name) async {
		return await usersCollection.document(uid).setData({
			'name': name,
			'lastSeen': DateTime.now(),
		}, merge: true);
	}

	// #19 using model https://youtu.be/ggYTQn4WVuw?list=PL4cUxeGkcC9j--TKIdkb3ISfRbJeJYQwC&t=481
	List<UserInfo> _stuffListFromSnapshot(QuerySnapshot snapshot){
		return snapshot.documents.map((doc) => UserInfo.fromFirestore(doc)).toList();
	}

	Stream<List<UserInfo>> get stuff{
	//Stream<QuerySnapshot> get stuff{
		return usersCollection.snapshots().map(_stuffListFromSnapshot);
		//return usersCollection.snapshots();
	}

	SomeModel _someModelFromSnap(DocumentSnapshot snapshot){
		return SomeModel(uid: uid, name: snapshot.data['name']);
	}
	
	// someModel doc stream
	Stream<SomeModel> get someModel{
		return usersCollection.document(uid).snapshots().map(_someModelFromSnap);
	}

}

// custom model
class UserInfo{
	final String name;
	final String displayName;
	final String email;
	final bool isEmailVerified;
	UserInfo({ this.name, this.displayName, this.email, this.isEmailVerified });

	factory UserInfo.fromFirestore(DocumentSnapshot doc){

		Map data = doc.data;

		return UserInfo(
			name: data['name'] ?? '',
			displayName: data['displayName'] ?? '',
			email: data['email'] ?? '',
			isEmailVerified: data['isEmailVerified'] ?? false,
		);
	}
}

// user options
class SomeModel{
	final String uid;
	final String name;

	SomeModel({ this.uid, this.name, });
}

class User{
	final String uid;
	final bool isEmailVerified;
	final String email;
	final String providerId;
	final String displayName;
	final String photoUrl;

	User({ this.uid, this.isEmailVerified, this.email, this.providerId, this.displayName, this.photoUrl });

	factory User.fromMap(FirebaseUser data){
		return User(
			uid: data.uid ?? '',
			isEmailVerified: data.isEmailVerified ?? false,
			email: data.email ?? '',
			providerId: data.providerId ?? '',
			displayName: data.displayName ?? '',
			photoUrl: data.photoUrl ?? '',
		);
	}
}

class Meeting extends ChangeNotifier{
	
	bool isAudioOnly = true;
	bool isAudioMuted = true;
	bool isVideoMuted = true;
	String roomName = '';

	Meeting({this.isAudioOnly, this.isAudioMuted, this.isVideoMuted});

	factory Meeting.everyone(){
		var meeting = Meeting(isAudioOnly: true, isAudioMuted: true, isVideoMuted: true);
		meeting.connect();

		return meeting;
	}
	void onAudioOnlyChanged(bool value){
		isAudioOnly = value;
		notifyListeners();
	}
	void onAudioMutedChanged(bool value){
		isAudioMuted = value;
		notifyListeners();
	}
	void onVideoMutedChanged(bool value){
		isVideoMuted = value;
		notifyListeners();
	}
	void connect(){
		JitsiMeet.addListener(
			JitsiMeetingListener(
				onConferenceWillJoin: _onConferenceWillJoin,
				onConferenceJoined: _onConferenceJoined,
				onConferenceTerminated: _onConferenceTerminated,
				onError: _onError
			)
		);
	}
	void join(User user, String roomName) async {

		try {

			// Enable or disable any feature flag here
			// If feature flag are not provided, default values will be used
			// Full list of feature flags (and defaults) available in the README
			Map<FeatureFlagEnum, bool> featureFlags = {
				FeatureFlagEnum.WELCOME_PAGE_ENABLED : false,
			};

			// Here is an example, disabling features for each platform
			if (Platform.isAndroid)
			{
				// Disable ConnectionService usage on Android to avoid issues (see README)
				featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
			}
			else if (Platform.isIOS)
			{
				// Disable PIP on iOS as it looks weird
				featureFlags[FeatureFlagEnum.PIP_ENABLED] = false;
			}

	if(roomName.isEmpty){
		roomName = 'pt-${ DateTime.now().toUtc().toIso8601String() }';
	}
	roomName = roomName.substring(0,30).replaceAll(
		new RegExp(r"[^a-z0-9_-]+", caseSensitive: false, multiLine: false),
		""
	);

	var userDisplayName = '${ user.displayName }';

print('roomName: "${ roomName }" by: ${ userDisplayName }');
			// Define meetings options here
			var options = JitsiMeetingOptions()
				..room = roomName
				..serverURL = null
				..subject = 'special meeting call'
				..userDisplayName = userDisplayName
				..userEmail = user.email
				..iosAppBarRGBAColor = "#0080FF80"
				..audioOnly = isAudioOnly
				..audioMuted = isAudioMuted
				..videoMuted = isVideoMuted
				..featureFlags.addAll(featureFlags);

			print("JitsiMeetingOptions: $options");
			await JitsiMeet.joinMeeting(options,
					listener: JitsiMeetingListener(onConferenceWillJoin: ({message}) {
						print("${options.room} will join with message: $message");
					}, onConferenceJoined: ({message}) {
						print("${options.room} joined with message: $message");
					}, onConferenceTerminated: ({message}) {
						print("${options.room} terminated with message: $message");
					}),
					// by default, plugin default constraints are used
					//roomNameConstraints: new Map(), // to disable all constraints
					//roomNameConstraints: customContraints, // to use your own constraint(s)
			);
		} catch (error) {
			print("error: $error");
		}
	}

	static final Map<RoomNameConstraintType, RoomNameConstraint> customContraints =
	{
		RoomNameConstraintType.MAX_LENGTH : new RoomNameConstraint(
						(value) { return value.trim().length <= 50; },
						"Maximum room name length should be 30."),

		RoomNameConstraintType.FORBIDDEN_CHARS : new RoomNameConstraint(
						(value) { return RegExp(r"[$€£]+", caseSensitive: false, multiLine: false).hasMatch(value) == false; },
						"Currencies characters aren't allowed in room names."),
	};

	void _onConferenceWillJoin({message}) {
		print("_onConferenceWillJoin broadcasted with message: $message");
	}

	void _onConferenceJoined({message}) {
		print("_onConferenceJoined broadcasted with message: $message");
	}

	void _onConferenceTerminated({message}) {
		print("_onConferenceTerminated broadcasted with message: $message");
	}

	_onError(error) {
		print("_onError broadcasted: $error");
	}
	void disconnect(){
		JitsiMeet.removeAllListeners();
	}
}

final meeting = Meeting.everyone();

