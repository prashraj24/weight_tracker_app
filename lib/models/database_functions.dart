import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:weight_tracker_app/pages/sign_in_page.dart';

class DatabaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String uid;

  DatabaseService({this.uid});

  Future createUserDoc() async {
    var userDoc = FirebaseFirestore.instance
        .collection('user_weights')
        .doc(_auth.currentUser.uid)
        .snapshots();
    print('USER DOC RESULT: ' + userDoc.toString());

    await FirebaseFirestore.instance
        .collection('user_weights')
        .doc(_auth.currentUser.uid)
        .set(
      {
        'data': FieldValue.arrayUnion([]),
        'uid': _auth.currentUser.uid,
      },
      SetOptions(merge: true),
    );
  }

  Future deleteWeightEntry(finalData) async {
    await FirebaseFirestore.instance
        .collection('user_weights')
        .doc(_auth.currentUser.uid)
        .set(
      {
        'data': finalData,
      },
      SetOptions(merge: true),
    );
  }

  Future editWeightEntry(finalData) async {
    await FirebaseFirestore.instance
        .collection('user_weights')
        .doc(_auth.currentUser.uid)
        .set(
      {
        'data': finalData,
      },
      SetOptions(merge: true),
    );
  }

  Future saveDataToDB(weight) async {
    await FirebaseFirestore.instance
        .collection('user_weights')
        .doc(_auth.currentUser.uid)
        .set(
      {
        'data': FieldValue.arrayUnion([
          {
            'weight': weight,
            'timestamp': DateTime.now(),
          }
        ]),
        'uid': _auth.currentUser.uid,
      },
      SetOptions(merge: true),
    );
  }

  Future signOut(BuildContext context) async {
    await _auth.signOut();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SingInPage(),
      ),
    );
    print('Authentication Status: ' + _auth.currentUser.toString());
  }
}
