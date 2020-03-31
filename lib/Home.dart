import 'package:flutter/material.dart';
import 'package:qrcode_reader/qrcode_reader.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './HistoryList.dart';
import './database_helper.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './firebase_notification_handler.dart';

var greenColor = Color(0xff32a05f);
var darkGreenColor = Color(0xff279152);

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DatabaseHelper helper = DatabaseHelper();
  final db = Firestore.instance;
  Future<String> _barcodeString;
  String uid = '';
  bool verified = false;
  getValuesSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool dValue = prefs.getBool('DocumentBool');
    if (dValue != null) {
      setState(() {
        verified = dValue;
      });
    }
  }

  @override
  void initState() {
    this.uid = '';
    FirebaseAuth.instance.currentUser().then((val) {
      setState(() {
        this.uid = val.phoneNumber;
      });
    }).catchError((e) {
      print(e);
    });
    super.initState();
    new FirebaseNotifications().setUpFirebase();
  }

  _barrequest() async {
    String bar = await _barcodeString;
    var usersRef = db.collection('QR').document(bar);
    int manu = int.parse(bar.substring(bar.length - 2));
    var ref;
    var date = DateFormat.yMMMd().format(DateTime.now());
    HistoryList current = HistoryList(bar, manu.toString(), date);

    usersRef.get().then((docSnapshot) => {
          if (docSnapshot.exists)
            {
              helper.insertHistory(current),
              ref = db.collection('users').document(uid),
              ref.updateData({'reward': FieldValue.increment(manu)}),
              usersRef.delete(),
              showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Congratulation!!'),
                    content: const Text('Reward has been Added'),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('Ok'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              )
            }
          else if (!docSnapshot.exists)
            {
              showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('QR Code is Not Valid'),
                    content: const Text('This QR Code cannot be used '),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('Ok'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              )
            }
        });
  }

  _redeem() async {
    await getValuesSF();
    if (verified == false) {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Documents Not Verified'),
            content:
                Text('Please Verify Your Documents In The Profile Section'),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      var sum = await Firestore.instance
          .collection('users')
          .document(uid)
          .get()
          .then((DocumentSnapshot ds) {
        return ds.data['reward'];
      });
      var id = await Firestore.instance
          .collection('users')
          .document(uid)
          .get()
          .then((DocumentSnapshot ds) {
        return ds.data['fund_account_id'];
      });
      var firstOrNot = await Firestore.instance
          .collection('users')
          .document(uid)
          .get()
          .then((DocumentSnapshot ds) {
        return ds.data['first'];
      });

      var sum1 = sum;
      if ((firstOrNot == true) && (sum1 >= 250)) {
        sum1 = (sum1 + 251) * 100;
      } else {
        sum1 = sum * 100;
      }
      var ac = '';
      String keyId = '';
      String keySecret = '';
      String url = 'https://$keyId:$keySecret@api.razorpay.com/v1/payouts';
      Map<String, String> headers = {"Content-type": "application/json"};
      String curren = 'INR';
      String mode = 'NEFT';
      String purpose = 'cashback';
      String ing =
          '{"account_number":"$ac","fund_account_id":"$id","amount":$sum1,"currency":"$curren","mode":"$mode","purpose":"$purpose"}';

      if (sum == 0 || sum == null) {
        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('No Reward Points'),
              content: Text('Please collect some reward points and try again!'),
              actions: <Widget>[
                FlatButton(
                  child: Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else if (sum < 100 && sum > 0) {
        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Not Enough Reward Points'),
              content: Text('Need Atleast 100 Points To Redeem'),
              actions: <Widget>[
                FlatButton(
                  child: Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        var response = await http.post(url, headers: headers, body: ing);
        var pstate = json.decode(response.body);
        var ppstate = pstate['status'].toString();

        if (ppstate == 'null') {
          showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Transaction Status'),
                content: Text('Please Try Again Later'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Ok'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        } else {
          showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Transaction Status'),
                content: Text('Status : $ppstate'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Ok'),
                    onPressed: () {
                      Firestore.instance
                          .collection('users')
                          .document(uid)
                          .updateData({'reward': 0, 'first': false});
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: greenColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.only(bottomLeft: Radius.circular(108.0)),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 2.0),
                    SizedBox(height: 2.0),
                    Container(
                        width: 300.0, child: Image.asset("assets/CCLogo.png")),
                    Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        FloatingActionButton(
                          onPressed: () {
                            setState(() {
                              _barcodeString = new QRCodeReader()
                                  .setAutoFocusIntervalInMs(200)
                                  .setForceAutoFocus(true)
                                  .setTorchEnabled(true)
                                  .setHandlePermissions(true)
                                  .setExecuteAfterPermissionGranted(true)
                                  .scan();
                            });
                            _barrequest();
                          },
                          backgroundColor: Colors.black,
                          child: Icon(Icons.camera_alt),
                          heroTag: null,
                        ),
                        Container(
                          width: 150.0,
                          child: Image.asset("assets/money.png"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 12.0),
                    Text('Account Info',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          height: 80.0,
                          width: MediaQuery.of(context).size.width / 2 - 15,
                          decoration: BoxDecoration(
                              color: darkGreenColor,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(22.0),
                                  topRight: Radius.circular(22.0))),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  StreamBuilder(
                                    stream: Firestore.instance
                                        .collection('users')
                                        .document(uid)
                                        .snapshots(),
                                    initialData: 0,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.active) {
                                        var userDocument = snapshot.data;
                                        return new Text(
                                            userDocument["reward"].toString(),
                                            style: TextStyle(
                                                color: Colors.yellow,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 40.0));
                                      } else if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Container(
                                            child: Center(
                                                child:
                                                    CircularProgressIndicator()));
                                      } else {
                                        return Container(
                                            child: Center(
                                          child: Text('Error'),
                                        ));
                                      }
                                    },
                                  ),
                                  SizedBox(width: 5.0),
                                  Text(
                                    'Points',
                                    style: TextStyle(color: Colors.white70),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 95.0,
                          width: MediaQuery.of(context).size.width / 2 - 50,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    FloatingActionButton(
                                      onPressed: () {
                                        _redeem();
                                      },
                                      backgroundColor: Colors.blue,
                                      child: Icon(Icons.account_balance_wallet),
                                      heroTag: null,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5.0),
                                Text(
                                  'REDEEM',
                                  style: TextStyle(color: Colors.white),
                                )
                              ]),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
