import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

addBoolToSF() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('LoginValue', true);
}

addIntToSF() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt('ScreenValue', 2);
}

class BankInfo2Screen extends StatefulWidget {
  final String id;
  BankInfo2Screen(this.id) : super();
  @override
  _BankInfo2ScreenState createState() => new _BankInfo2ScreenState();
}

class _BankInfo2ScreenState extends State<BankInfo2Screen> {
  String uid = '';
  final db = Firestore.instance;
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  bool loading = false;
  String upi;
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
  }

  final TextEditingController _UPIController = TextEditingController();
  final TextEditingController _GSTController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  gstVerify() async {
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
        '{"gstin":"${_GSTController.text.toString()}","consent":"Y","consent_text":"I consent to use my data"}';
    var response = await http.post(prodUrl, headers: headers, body: body);
    var respo = json.decode(response.body);
    if (response.statusCode == 200) {
      var stat =
          (respo['data'] as List).map((p) => new GST.fromJson(p)).toList();
      for (final items in stat) {
        if (items.response_code == "101") {
          _makerequest();
        } else if (items.response_code == "102") {
          setState(() {
            loading = false;
          });
          showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Invalid GSTIN'),
                content: const Text('Please try with valid GSTIN'),
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
    } else {
      setState(() {
        loading = false;
      });
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Invalid GSTIN'),
            content: const Text('Please try with valid GSTIN'),
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

  _makerequest() async {
    String keyId = '';
    String keySecret = '';
    String address = '{"address":"${_UPIController.text}"}';
    String url = 'https://$keyId:$keySecret@api.razorpay.com/v1/fund_accounts';

    Map<String, String> headers = {"Content-type": "application/json"};
    String ing =
        '{"account_type": "vpa","contact_id":"${widget.id}","vpa":$address}';
    print(ing);

    var response = await http.post(url, headers: headers, body: ing);
    var respo = json.decode(response.body);
    var id = respo['id'].toString();

    if (response.statusCode == 200) {
      final snapShot = await db.collection('retailers').document(uid).get();
      if (snapShot == null || !snapShot.exists) {
        await db.collection('retailers').document(uid).setData({
          'fund_account_id': '$id',
          'reward': 0,
          'upiId': '${_UPIController.text}',
          'name': '${_nameController.text}',
          'GSTIN': '${_GSTController.text}',
          'account_no': null,
          'ifsc': null,
          'bank_name': null,
          'pan_card': null,
          'voter_id': null,
          'state': null,
          'district': null,
          'locality': null,
          'first': true
        });
        setState(() {
          loading = false;
        });
      } else {
        await db.collection('retailers').document(uid).updateData({
          'first': false,
          'name': '${_nameController.text}',
          'GSTIN': '${_GSTController.text}',
          'upiId': '${_UPIController.text}',
          'fund_account_id': '$id',
        });
        setState(() {
          loading = false;
        });
      }

      addIntToSF();
      addBoolToSF();
      Navigator.of(context).pushReplacementNamed('/pageCheck2');
    }
  }

  String validateUPI(String value) {
    String pattern = r'^\w+@\w+$';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      setState(() {
        loading = false;
      });
      return "UPI ID is Required";
    } else if (!regExp.hasMatch(value)) {
      setState(() {
        loading = false;
      });
      return "Invalid UPI";
    } else {
      return null;
    }
  }

  String validateEmail(String value) {
    if (value.length == 0) {
      setState(() {
        loading = false;
      });
      return "GSTIN ID is Required";
    } else {
      return null;
    }
  }

  String validateName(String value) {
    if (value.length == 0) {
      setState(() {
        loading = false;
      });
      return "Name is Required";
    } else {
      return null;
    }
  }

  Widget radioButton(bool isSelected) => Container(
        width: 16.0,
        height: 16.0,
        padding: EdgeInsets.all(2.0),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(width: 2.0, color: Colors.black)),
        child: isSelected
            ? Container(
                width: double.infinity,
                height: double.infinity,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.black),
              )
            : Container(),
      );

  Widget horizontalLine() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          width: ScreenUtil.getInstance().setWidth(120),
          height: 1.0,
          color: Colors.black26.withOpacity(.2),
        ),
      );

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);
    ScreenUtil.instance =
        ScreenUtil(width: 750, height: 1334, allowFontScaling: true);
    return new Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomPadding: true,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
                child: Image.asset("assets/CCLogo.png"),
              ),
              Expanded(
                child: Container(),
              ),
              Image.asset("assets/image_02.png")
            ],
          ),
          SingleChildScrollView(
              child: new Form(
            key: _key,
            autovalidate: _validate,
            child: Padding(
              padding: EdgeInsets.only(left: 28.0, right: 28.0, top: 150.0),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: ScreenUtil.getInstance().setHeight(180),
                  ),
                  Container(
                    width: double.infinity,
                    height: ScreenUtil.getInstance().setHeight(600),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0.0, 15.0),
                              blurRadius: 15.0),
                          BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0.0, -10.0),
                              blurRadius: 10.0),
                        ]),
                    child: Padding(
                      padding:
                          EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("UPI Info",
                              style: TextStyle(
                                  fontSize: ScreenUtil.getInstance().setSp(45),
                                  fontFamily: "Poppins-Bold",
                                  letterSpacing: .6)),
                          Text("User Name",
                              style: TextStyle(
                                  fontFamily: "Poppins-Medium",
                                  fontSize:
                                      ScreenUtil.getInstance().setSp(26))),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                                hintText: "User Name",
                                hintStyle: TextStyle(
                                    color: Colors.grey, fontSize: 12.0),
                                icon: Icon(Icons.account_circle)),
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.text,
                            enabled: true,
                            validator: validateName,
                          ),
                          SizedBox(
                            height: ScreenUtil.getInstance().setHeight(5),
                          ),
                          Text("UPI ID",
                              style: TextStyle(
                                  fontFamily: "Poppins-Medium",
                                  fontSize:
                                      ScreenUtil.getInstance().setSp(26))),
                          TextFormField(
                            controller: _UPIController,
                            decoration: InputDecoration(
                                hintText: "UPI ID",
                                hintStyle: TextStyle(
                                    color: Colors.grey, fontSize: 12.0),
                                icon: Icon(Icons.account_balance)),
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.text,
                            enabled: true,
                            validator: validateUPI,
                          ),
                          SizedBox(
                            height: ScreenUtil.getInstance().setHeight(30),
                          ),
                          Text("Official Data",
                              style: TextStyle(
                                  fontSize: ScreenUtil.getInstance().setSp(40),
                                  fontFamily: "Poppins-Bold",
                                  letterSpacing: .6)),
                          SizedBox(
                            height: ScreenUtil.getInstance().setHeight(2),
                          ),
                          Text("GSTIN",
                              style: TextStyle(
                                  fontFamily: "Poppins-Medium",
                                  fontSize:
                                      ScreenUtil.getInstance().setSp(26))),
                          TextFormField(
                            controller: _GSTController,
                            decoration: InputDecoration(
                                hintText: "GSTIN",
                                hintStyle: TextStyle(
                                    color: Colors.grey, fontSize: 12.0),
                                icon: Icon(Icons.account_balance)),
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.text,
                            enabled: true,
                            validator: validateEmail,
                          ),
                          SizedBox(
                            height: ScreenUtil.getInstance().setHeight(2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: ScreenUtil.getInstance().setHeight(40)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      InkWell(
                        child: Container(
                          width: ScreenUtil.getInstance().setWidth(330),
                          height: ScreenUtil.getInstance().setHeight(100),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Color(0xFF17ead9),
                                Color(0xFF6078ea)
                              ]),
                              borderRadius: BorderRadius.circular(20.0),
                              boxShadow: [
                                BoxShadow(
                                    color: Color(0xFF6078ea).withOpacity(.3),
                                    offset: Offset(0.0, 8.0),
                                    blurRadius: 8.0)
                              ]),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (_key.currentState.validate()) {
                                  setState(() {
                                    loading = true;
                                  });
                                  gstVerify();
                                }
                              },
                              child: Center(
                                child: loading
                                    ? Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              new AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : Text("Proceed",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "Poppins-Bold",
                                            fontSize: 18,
                                            letterSpacing: 1.0)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ))
        ],
      ),
    );
  }
}

class GST {
  final String id,
      env,
      request_timestamp,
      response_timestamp,
      transaction_status,
      result,
      response_msg,
      response_code;
  GST(
      {this.id,
      this.env,
      this.request_timestamp,
      this.response_timestamp,
      this.transaction_status,
      this.result,
      this.response_msg,
      this.response_code});
  factory GST.fromJson(Map<String, dynamic> json) {
    return new GST(
        id: json['id'].toString(),
        env: json['env'].toString(),
        request_timestamp: json['request_timestamp'].toString(),
        response_timestamp: json['response_timestamp'].toString(),
        transaction_status: json['transaction_status'].toString(),
        result: json['result'].toString(),
        response_msg: json['response_msg'].toString(),
        response_code: json['response_code'].toString());
  }
}
