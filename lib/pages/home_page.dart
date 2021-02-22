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
  int editedWeight = 0;
  List<dynamic> finalData = [];
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
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

            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(top: widget.screenWidth * 0.28),
                    alignment: Alignment.center,
                    child: Text(
                      'Enter Details Below',
                      style: TextStyle(fontSize: widget.screenWidth * 0.071),
                    ),
                  ),
                  SizedBox(height: 38),
                  Container(
                    width: widget.screenWidth * 0.6,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            style: TextStyle(fontSize: 22),
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
                                // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                //     duration: Duration(seconds: 2),
                                //     content: Text('Saving Data')));

                                var result = await saveDataToDB(weight)
                                    .catchError((Object error) =>
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                duration: Duration(seconds: 2),
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
                                          duration: Duration(seconds: 2),
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
                            style:
                                TextStyle(fontSize: widget.screenWidth * 0.048),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '(Long Press To Delete Entry |',
                            style:
                                TextStyle(fontSize: widget.screenWidth * 0.038),
                          ),
                          Text(
                            'Click To Edit Entry)',
                            style:
                                TextStyle(fontSize: widget.screenWidth * 0.038),
                          ),
                          SizedBox(height: 7),
                          finalData != null
                              ? Card(
                                  elevation: 3,
                                  shadowColor: Colors.black,
                                  child: ListView.builder(
                                    reverse: true,
                                    shrinkWrap: true,
                                    itemCount: finalData.length != 0
                                        ? finalData.length
                                        : 0,
                                    itemBuilder: (context, i) {
                                      return finalData[i] != null
                                          ? ListTile(
                                              dense: true,
                                              onLongPress: () async {
                                                setState(() {
                                                  finalData.removeAt(i);
                                                });
                                                await deleteWeightEntry();
                                              },
                                              onTap: () async {
                                                await showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext _context) {
                                                    return AlertDialog(
                                                      title: Text("Edit Entry"),
                                                      content: TextFormField(
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            editedWeight =
                                                                int.parse(
                                                                    value);
                                                          });
                                                        },
                                                        validator: (value) {
                                                          if (value.isEmpty) {
                                                            return 'Please enter weight';
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                      actions: [
                                                        FlatButton(
                                                          child: Text("Submit"),
                                                          onPressed: () async {
                                                            setState(() {
                                                              finalData[i] = {
                                                                'weight':
                                                                    editedWeight,
                                                                'timestamp':
                                                                    DateTime
                                                                        .now()
                                                              };
                                                            });
                                                            await editWeightEntry();
                                                            Navigator.pop(
                                                                _context);
                                                          },
                                                        ),
                                                        FlatButton(
                                                          child: Text("Cancel"),
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                _context);
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              title: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Text(
                                                    'Weight: ' +
                                                        finalData[i]['weight']
                                                            .toString(),
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  Text('Date: ' +
                                                      finalData[i]['timestamp']
                                                          .toDate()
                                                          .toString()
                                                          .substring(0, 11)),
                                                  SizedBox(height: 10),
                                                ],
                                              ),
                                            )
                                          : Container(
                                              height: 0,
                                              width: 0,
                                            );
                                    },
                                  ),
                                )
                              : Container(
                                  height: 0,
                                  width: 0,
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
      ),
    );
  }

  Future deleteWeightEntry() async {
    await FirebaseFirestore.instance
        .collection('user_weights')
        .doc(widget.user.uid)
        .set(
      {
        'data': finalData,
      },
      SetOptions(merge: true),
    );
  }

  Future editWeightEntry() async {
    await FirebaseFirestore.instance
        .collection('user_weights')
        .doc(widget.user.uid)
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
