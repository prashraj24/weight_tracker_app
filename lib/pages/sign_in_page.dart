import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:weight_tracker_app/models/database_functions.dart';
import 'package:weight_tracker_app/pages/home_page.dart';

class SingInPage extends StatefulWidget {
  @override
  _SingInPageState createState() => _SingInPageState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;

class _SingInPageState extends State<SingInPage> {
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Sign In Page"),
      // ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: screenWidth * 0.5),
            Text(
              'Sign In Page',
              style: TextStyle(fontSize: 21, color: Colors.black),
            ),
            SizedBox(width: 25),
            Container(
              padding: const EdgeInsets.only(top: 16.0),
              alignment: Alignment.center,
              child: RaisedButton(
                color: Colors.blue[800],
                onPressed: () async {
                  signInAnonymously();
                },
                child: Text(
                  "Sign in Anonymously",
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

//Anonymous Sign In function
  void signInAnonymously() {
    _auth.signInAnonymously().then((result) async {
      setState(() {
        final User user = result.user;
        print('User Signed In Data: ' + user.toString());
      });
      if (_auth.currentUser != null) {
        await DatabaseService(uid: _auth.currentUser.uid).createUserDoc();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
                user: _auth.currentUser,
                screenWidth: MediaQuery.of(context).size.width),
          ),
        );
      }
    });
  }

}
