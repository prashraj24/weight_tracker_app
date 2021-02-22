import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:weight_tracker_app/pages/sign_in_page.dart';

class HomePage extends StatefulWidget {
  @required
  final User user;
  final double screenWidth;

  HomePage({this.user, this.screenWidth});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    print('Passed UID:' + widget.user.toString());
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  int weight = 0;
  var finalData;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('user_weights')
            .doc(widget.user.uid)
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot> weightsSnapshot) {
          if (weightsSnapshot.hasError) {
            return Text('Something went wrong');
          }

          if (weightsSnapshot.hasData) {
            finalData = weightsSnapshot.data.data()['data'];
          }

          print('Stream DATA:  ' + finalData.toString());

          return Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: widget.screenWidth * 0.28),
                alignment: Alignment.center,
                child: Text(
                  'Enter Details Below',
                  style: TextStyle(fontSize: widget.screenWidth * 0.071),
                ),
              ),
              SizedBox(height: 45),
              Container(
                width: widget.screenWidth * 0.5,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            weight = int.parse(value);
                          });
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter weight';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                duration: Duration(seconds: 2),
                                content: Text('Saving Data')));

                            var result = await saveDataToDB(weight).catchError(
                                (Object error) => ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                        duration: Duration(seconds: 3),
                                        content: Row(
                                          children: [
                                            Text('Error Saving Data'),
                                            SizedBox(width: 7),
                                            Icon(
                                              Icons.cancel,
                                              color: Colors.red,
                                            ),
                                          ],
                                        ))));

                            if (result == null) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                      duration: Duration(seconds: 3),
                                      content: Row(
                                        children: [
                                          Text('Data Saved'),
                                          SizedBox(width: 7),
                                          Icon(
                                            Icons.done,
                                            color: Colors.green,
                                          ),
                                        ],
                                      )));
                            }
                          }
                        },
                        child: Text('Submit Details'),
                      ),
                      SizedBox(height: 50),
                      Text(
                        'Weights List',
                        style: TextStyle(fontSize: widget.screenWidth * 0.04),
                      ),
                      SizedBox(height: 7),
                      finalData != null
                          ? Card(
                              elevation: 3,
                              shadowColor: Colors.black,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: finalData.length != 0
                                    ? finalData.length
                                    : 0,
                                itemBuilder: (context, i) {
                                  return finalData[i] != null
                                      ? ListTile(
                                          title: Text(finalData[i]['weight']
                                              .toString()),
                                        )
                                      : Container(
                                          height: 0,
                                          width: 0,
                                        );
                                },
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await signOut();
        },
        tooltip: 'Sign Out',
        child: Icon(Icons.logout),
      ),
    );
  }

  Future deleteWeightEntry(weight) async {
    await FirebaseFirestore.instance
        .collection('user_weights')
        .doc(widget.user.uid)
        .set(
      {
        'data': FieldValue.arrayUnion([
          {
            'weight': weight,
            'timestamp': DateTime.now(),
          }
        ]),
        'uid': widget.user.uid,
      },
      SetOptions(merge: true),
    );
  }

  Future saveDataToDB(weight) async {
    await FirebaseFirestore.instance
        .collection('user_weights')
        .doc(widget.user.uid)
        .set(
      {
        'data': FieldValue.arrayUnion([
          {
            'weight': weight,
            'timestamp': DateTime.now(),
          }
        ]),
        'uid': widget.user.uid,
      },
      SetOptions(merge: true),
    );
  }

  Future signOut() async {
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
