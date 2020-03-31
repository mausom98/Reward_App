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
  prefs.setInt('ScreenValue', 3);
}

class BankDetails3Screen extends StatefulWidget {
  final String id;
  BankDetails3Screen(this.id) : super();
  @override
  _BankDetails3ScreenState createState() => new _BankDetails3ScreenState();
}

class _BankDetails3ScreenState extends State<BankDetails3Screen> {
  bool verifyB = false;
  bool loading = false;
  String beneName = '';
  String uid = '';
  final db = Firestore.instance;
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _GSTController = TextEditingController();

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
      if (respo['response_code'] == "101") {
        bankVerify();
      } else if (respo['response_code'] == "102") {
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

  bankVerify() async {
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
        '{"Account":"${_accountController.text}","IFSC":"${_ifscController.text}"}';
    var response = await http.post(prodUrl, headers: headers, body: body);
    Map<String, dynamic> respo = json.decode(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> respo1 = respo['data'];
      if (respo1['Status'] == "VERIFIED") {
        setState(() {
          beneName = respo1['BeneName'];
        });
        makerequest();
      } else if (_nameController.text.toUpperCase() != respo1['BeneName']) {
        setState(() {
          loading = false;
        });
        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Name Match Failure'),
              content:
                  const Text('Provided Name Doesnot Match With Bank Details'),
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
        setState(() {
          loading = false;
        });
        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Verification Error'),
              content: const Text('Invalid Bank Account'),
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
    } else {
      setState(() {
        loading = false;
      });
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Server Problem'),
            content: const Text('Please try again after sometime'),
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

  makerequest() async {
    String keyId = '';
    String keySecret = '';
    String address =
        '{"name":"${_nameController.text}","ifsc":"${_ifscController.text}","account_number":"${_accountController.text}"}';
    String url = 'https://$keyId:$keySecret@api.razorpay.com/v1/fund_accounts';

    Map<String, String> headers = {"Content-type": "application/json"};
    String ing =
        '{"contact_id":"${widget.id}","account_type": "bank_account","bank_account":$address}';
    print(ing);

    var response = await http.post(url, headers: headers, body: ing);
    var respo = json.decode(response.body);
    var id = respo['id'].toString();

    if (response == null) {
      Center(
        child: new CircularProgressIndicator(),
      );
    }
    if (response.statusCode == 200) {
      final snapShot = await db.collection('dealers').document(uid).get();
      if (snapShot == null || !snapShot.exists) {
        await db.collection('dealers').document(uid).setData({
          'fund_account_id': '$id',
          'reward': 0,
          'account_no': '${_accountController.text}',
          'ifsc': '${_ifscController.text}',
          'name': '${_nameController.text}',
          'GSTIN': '${_GSTController.text}',
          'bank_name': beneName,
          'upiID': null,
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
        await db.collection('dealers').document(uid).updateData({
          'first': false,
          'account_no': '${_accountController.text}',
          'ifsc': '${_ifscController.text}',
          'name': '${_nameController.text}',
          'GSTIN': '${_GSTController.text}',
          'bank_name': beneName,
          'fund_account_id': '$id',
        });
        setState(() {
          loading = false;
        });
      }
      addIntToSF();
      addBoolToSF();
      Navigator.of(context).pushReplacementNamed('/pageCheck3');
    }
    if (respo['error']['code'] == "GATEWAY_ERROR") {
      setState(() {
        loading = false;
      });
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Gateway Error'),
            content: const Text('Please try again later'),
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
    if (respo['error']['code'] == "BAD_REQUEST_ERROR") {
      setState(() {
        loading = false;
      });
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Bad Request'),
            content: const Text('Please check the details provided by you'),
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
    if (respo['error']['code'] == "SERVER_ERROR") {
      setState(() {
        loading = false;
      });
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Server Error'),
            content: const Text('Please try again later'),
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

  String validateEmail(String value) {
    if (value.length == 0) {
      return "Input is Required";
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
              padding: EdgeInsets.only(left: 28.0, right: 28.0, top: 10.0),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: ScreenUtil.getInstance().setHeight(180),
                  ),
                  Container(
                    width: double.infinity,
                    height: ScreenUtil.getInstance().setHeight(907),
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
                          Text("Bank Info",
                              style: TextStyle(
                                  fontSize: ScreenUtil.getInstance().setSp(45),
                                  fontFamily: "Poppins-Bold",
                                  letterSpacing: .6)),
                          SizedBox(
                            height: ScreenUtil.getInstance().setHeight(5),
                          ),
                          Text("Full Name",
                              style: TextStyle(
                                  fontFamily: "Poppins-Medium",
                                  fontSize:
                                      ScreenUtil.getInstance().setSp(26))),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                                hintText: "Full Name",
                                hintStyle: TextStyle(
                                    color: Colors.grey, fontSize: 12.0),
                                icon: Icon(Icons.account_circle)),
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.text,
                            enabled: true,
                            validator: validateEmail,
                          ),
                          Text("IFSC",
                              style: TextStyle(
                                  fontFamily: "Poppins-Medium",
                                  fontSize:
                                      ScreenUtil.getInstance().setSp(26))),
                          TextFormField(
                            controller: _ifscController,
                            decoration: InputDecoration(
                                hintText: "IFSC",
                                hintStyle: TextStyle(
                                    color: Colors.grey, fontSize: 12.0),
                                icon: Icon(Icons.info_outline)),
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.characters,
                            enabled: true,
                            validator: validateEmail,
                          ),
                          SizedBox(
                            height: ScreenUtil.getInstance().setHeight(30),
                          ),
                          Text("Account Number",
                              style: TextStyle(
                                  fontFamily: "Poppins-Medium",
                                  fontSize:
                                      ScreenUtil.getInstance().setSp(26))),
                          TextFormField(
                            controller: _accountController,
                            decoration: InputDecoration(
                                hintText: "AccountNumber",
                                hintStyle: TextStyle(
                                    color: Colors.grey, fontSize: 12.0),
                                icon: Icon(Icons.account_balance)),
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.text,
                            enabled: true,
                            validator: validateEmail,
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
                                icon: Icon(Icons.attachment)),
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
                                    : Text("Proceed ->",
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
