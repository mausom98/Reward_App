import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

addDocumentBool() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('DocumentBool', true);
}

class Profile3 extends StatefulWidget {
  Profile3({Key key}) : super(key: key);

  _Profile3State createState() => _Profile3State();
}

class _Profile3State extends State<Profile3> {
  getColor() {
    if (verified == false) {
      return Colors.red;
    } else {
      return Colors.green;
    }
  }

  getIcon() {
    if (verified == false) {
      return Icons.cancel;
    } else {
      return Icons.assignment_turned_in;
    }
  }

  getValuesSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool dValue = prefs.getBool('DocumentBool');
    if (dValue != null) {
      setState(() {
        verified = dValue;
      });
    }
  }

  final TextEditingController _panController = TextEditingController();
  final TextEditingController _voterController = TextEditingController();
  String sta = 'status';
  String uid = '';

  bool verified = false;
  final db = Firestore.instance;
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
    getValuesSF();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Profile Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 10.0,
            ),
            Center(
              child: Container(
                  width: 100.0, child: Image.asset("assets/user.png")),
            ),
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(
                    Icons.call,
                    color: Colors.white,
                  ),
                ),
                title: Text("Phone Number : $uid"),
              ),
            ),
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: getColor(),
                  child: Icon(
                    getIcon(),
                    color: Colors.white,
                  ),
                ),
                title: Text('Document Verification Status'),
              ),
            ),
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(
                    Icons.assignment_turned_in,
                    color: Colors.white,
                  ),
                ),
                title: Text('Bank Account Verification'),
              ),
            ),
            Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(
                        Icons.assignment,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      'Get Documents Verified',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                  ButtonTheme.bar(
                    child: ButtonBar(
                      children: <Widget>[
                        RaisedButton(
                          child: const Text(
                            'PAN CARD',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: verified == true
                              ? null
                              : () {
                                  showDialog<void>(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      20.0)),
                                          title: Text('Pan Number'),
                                          content: TextField(
                                            textCapitalization:
                                                TextCapitalization.characters,
                                            textInputAction:
                                                TextInputAction.done,
                                            autofocus: true,
                                            autocorrect: false,
                                            controller: _panController,
                                            maxLength: 10,
                                            maxLengthEnforced: true,
                                            decoration: InputDecoration(
                                                hintText: "Pan Number",
                                                icon: Icon(Icons.pages)),
                                          ),
                                          actions: <Widget>[
                                            new RaisedButton(
                                              child: Text(
                                                'Submit',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                panVerify();
                                              },
                                            )
                                          ],
                                        );
                                      });
                                },
                        ),
                        Text('OR'),
                        RaisedButton(
                          child: const Text(
                            'VOTER ID',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: verified == true
                              ? null
                              : () {
                                  showDialog<void>(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      25.0)),
                                          title: Text('Voter ID'),
                                          content: TextField(
                                            textCapitalization:
                                                TextCapitalization.characters,
                                            autofocus: true,
                                            autocorrect: false,
                                            textInputAction:
                                                TextInputAction.done,
                                            decoration: InputDecoration(
                                                hintText: "Voter ID",
                                                icon: Icon(Icons.pages)),
                                          ),
                                          actions: <Widget>[
                                            new RaisedButton(
                                              child: Text(
                                                'Submit',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                voterVerify();
                                              },
                                            )
                                          ],
                                        );
                                      });
                                },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 17.0),
            Text(
              'Helpline Number',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.call),
        onPressed: () async {
          launch('tel:6360828876');
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  panVerify() async {
    Position position;
    List<Placemark> placemark;
    try {
      position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print(position);
    } catch (e) {
      print(e);
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Verification Failed'),
            content: const Text('Please Turn On Your GPS'),
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
      return;
    }

    try {
      placemark = await Geolocator()
          .placemarkFromCoordinates(position.latitude, position.longitude)
          .timeout(new Duration(seconds: 3));
    } catch (e) {
      print(e);
    }
    var locality = placemark.first.locality;
    String preProdUrl = '';
    String prodUrl = '';
    String agencyID = '';
    String preProdKey = '';
    String prodKey = '';

    Map<String, String> headers = {
      'qt_api_key': '$prodKey',
      'qt_agency_id': '$agencyID',
      'Content-Type': 'application/json'
    };
    String body = '{"pan":"${_panController.text}"}';
    var response = await http.post(prodUrl, headers: headers, body: body);
    var respo = await json.decode(response.body);
    if (response.statusCode == 200) {
      var stat =
          (respo['data'] as List).map((p) => new Pan.fromJson(p)).toList();
      for (final items in stat) {
        if (items.pan_status == "VALID") {
          await db
              .collection('dealers')
              .document(uid)
              .updateData({'pan_card': items.pan_number, 'locality': locality});
          showDialog<void>(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Success'),
                content: const Text('Pan Card Details Have Been Uploaded'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Ok'),
                    onPressed: () {
                      setState(() {
                        verified = true;
                      });
                      addDocumentBool();
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
                title: Text('Failed'),
                content: const Text('Pan Card Details Are Not Valid'),
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
        }
      }
    } else if (response.statusCode == 422) {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Failed'),
            content: const Text('Invalid Pan Number'),
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
    } else if (respo['response_code'] == 3) {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Transaction Failure'),
            content: const Text('Please Try Again Later'),
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
    }
  }

  voterVerify() async {
    Position position;
    List<Placemark> placemark;
    try {
      position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print(position);
    } catch (e) {
      print(e);
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Verification Failed'),
            content: const Text('Please Turn On Your GPS'),
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
      return;
    }

    try {
      placemark = await Geolocator()
          .placemarkFromCoordinates(position.latitude, position.longitude)
          .timeout(new Duration(seconds: 3));
    } catch (e) {
      print(e);
    }
    var locality = placemark.first.locality;

    String preProdUrl = '';
    String prodUrl = '';
    String agencyID = '';
    String preProdKey = '';
    String prodKey = '';
    Map<String, String> headers = {
      'qt_api_key': '$prodKey',
      'qt_agency_id': '$agencyID',
      'Content-Type': 'application/json'
    };
    String body =
        '{"epic_no":"${_voterController.text}","consent":"Y","consent_text":"Yes I consent to give my voter Id details"}';
    var response = await http.post(prodUrl, headers: headers, body: body);
    var respo = json.decode(response.body);
    if (response.statusCode == 200) {
      if (respo['response_code'] == "101") {
        var stat =
            (respo['result'] as List).map((p) => new Vote.fromJson(p)).toList();
        for (final items in stat) {
          await db.collection('dealers').document(uid).updateData({
            'voter_id': items.epic_no,
            'state': items.state,
            'district': items.district,
            'locality': locality
          });
          showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Success'),
                content: const Text('Voter ID Details Have Been Uploaded'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Ok'),
                    onPressed: () {
                      setState(() {
                        verified = true;
                      });
                      addDocumentBool();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      } else if (respo['response_code'] == "103") {
        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Failed'),
              content: const Text('No Records Found'),
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
      }
    } else if (respo['response_code'] == "102") {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Failure'),
            content: const Text('Please Try Again Later'),
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
    } else if (response.statusCode == 422) {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Failure'),
            content: const Text('Please Provide A Valid Voter ID'),
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
    }
  }
}

class Pan {
  final String pan_number,
      pan_status,
      last_name,
      first_name,
      pan_holder_title,
      pan_last_updated;
  Pan(
      {this.pan_number,
      this.pan_status,
      this.last_name,
      this.first_name,
      this.pan_holder_title,
      this.pan_last_updated});

  factory Pan.fromJson(Map<String, dynamic> json) {
    return new Pan(
      pan_number: json['pan_number'].toString(),
      pan_status: json['pan_status'].toString(),
      last_name: json['last_name'].toString(),
      first_name: json['first_name'].toString(),
      pan_holder_title: json['pan_holder_title'].toString(),
      pan_last_updated: json['pan_last_updated'].toString(),
    );
  }
}

class Vote {
  final String ps_lat_long,
      rln_name_v1,
      rln_name_v2,
      rln_name_v3,
      part_no,
      rln_type,
      section_no,
      id,
      epic_no,
      rln_name,
      district,
      last_update,
      state,
      ac_no,
      house_no,
      ps_name,
      pc_name,
      slno_inpart,
      name,
      part_name,
      dob,
      gender,
      age,
      ac_name,
      name_v1,
      st_code,
      name_v3,
      name_v2;
  Vote(
      {this.ps_lat_long,
      this.rln_name_v1,
      this.rln_name_v2,
      this.rln_name_v3,
      this.part_no,
      this.rln_type,
      this.section_no,
      this.id,
      this.epic_no,
      this.rln_name,
      this.district,
      this.last_update,
      this.state,
      this.ac_no,
      this.house_no,
      this.ps_name,
      this.pc_name,
      this.slno_inpart,
      this.name,
      this.part_name,
      this.dob,
      this.gender,
      this.age,
      this.ac_name,
      this.name_v1,
      this.st_code,
      this.name_v3,
      this.name_v2});
  factory Vote.fromJson(Map<String, dynamic> json) {
    return new Vote(
        ps_lat_long: json['ps_lat_long'].toString(),
        rln_name_v1: json['rln_name_v1'].toString(),
        rln_name_v2: json['rln_name_v2'].toString(),
        rln_name_v3: json['rln_name_v3'].toString(),
        part_no: json['panrt_no'].toString(),
        rln_type: json['rln_type'].toString(),
        section_no: json['section_no'].toString(),
        id: json['id'].toString(),
        epic_no: json['epic_no'].toString(),
        rln_name: json['rln_name'].toString(),
        district: json['district'].toString(),
        last_update: json['last_update'].toString(),
        state: json['state'].toString(),
        ac_no: json['ac_no'].toString(),
        house_no: json['house_no'].toString(),
        ps_name: json['ps_name'].toString(),
        pc_name: json['pc_name'].toString(),
        slno_inpart: json['slno_inpart'].toString(),
        name: json['name'].toString(),
        part_name: json['part_name'].toString(),
        dob: json['dob'].toString(),
        gender: json['gender'].toString(),
        age: json['age'].toString(),
        ac_name: json['ac_name'].toString(),
        name_v1: json['name_v1'].toString(),
        st_code: json['st_code'].toString(),
        name_v3: json['name_v3'].toString(),
        name_v2: json['name_v2'].toString());
  }
}
