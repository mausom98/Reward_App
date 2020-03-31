import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import './Info.dart';
import './Info2.dart';
import './Info3.dart';
import 'package:flutter/services.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

final FirebaseAuth _auth = FirebaseAuth.instance;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => new _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _smsController = TextEditingController();

  String _verificationId;
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  String mobile;
  int selectedRadio;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    selectedRadio = 1;
  }

  setSelectedRadio(int val) => {
        setState(() => {selectedRadio = val})
      };

  String validateMobile(String value) {
    String patttern = r'(^[0-9]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Mobile is Required";
    } else if (value.length != 10) {
      return "Mobile number must 10 digits";
    } else if (!regExp.hasMatch(value)) {
      return "Mobile Number must be digits";
    }
    return null;
  }

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
                    height: ScreenUtil.getInstance().setHeight(150),
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
                          EdgeInsets.only(left: 16.0, right: 16.0, top: 0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("User Login",
                              style: TextStyle(
                                  fontSize: ScreenUtil.getInstance().setSp(45),
                                  fontFamily: "Poppins-Bold",
                                  letterSpacing: .6)),
                          SizedBox(
                            height: ScreenUtil.getInstance().setHeight(5),
                          ),
                          Text("Phone",
                              style: TextStyle(
                                  fontFamily: "Poppins-Medium",
                                  fontSize:
                                      ScreenUtil.getInstance().setSp(26))),
                          TextFormField(
                            controller: _phoneNumberController,
                            decoration: InputDecoration(
                              hintText: "Phone",
                              hintStyle:
                                  TextStyle(color: Colors.grey, fontSize: 12.0),
                              prefixText: '\+91   ',
                              prefixIcon: new Icon(Icons.phone),
                            ),
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.phone,
                            enabled: true,
                            validator: validateMobile,
                          ),
                          Text("You are a",
                              style: TextStyle(fontFamily: "Poppins-Bold")),
                          RadioListTile(
                            value: 1,
                            groupValue: selectedRadio,
                            title: Text("Electrician"),
                            onChanged: (val) {
                              setSelectedRadio(val);
                            },
                            activeColor: Colors.blue,
                          ),
                          RadioListTile(
                            value: 2,
                            groupValue: selectedRadio,
                            title: Text("Channel Partner"),
                            onChanged: (val) {
                              setSelectedRadio(val);
                            },
                            activeColor: Colors.blue,
                          ),
                          RadioListTile(
                            value: 3,
                            groupValue: selectedRadio,
                            title: Text("Reseller"),
                            onChanged: (val) {
                              setSelectedRadio(val);
                            },
                            activeColor: Colors.blue,
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
                                  _verifyPhoneNumber();
                                }
                              },
                              child: Center(
                                child: Text("Get OTP ->",
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

  void _verifyPhoneNumber() async {
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      _auth.signInWithCredential(phoneAuthCredential);
      if (selectedRadio == 1) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => InfoScreen(_phoneNumberController.text)));
      } else if (selectedRadio == 2) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    Info2Screen(_phoneNumberController.text)));
      } else if (selectedRadio == 3) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    Info3Screen(_phoneNumberController.text)));
      }
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Phone Verification Failed'),
            content: Text('Error : ${authException.message}'),
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
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      this._verificationId = verificationId;
      smsCodeDialog(context);
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      this._verificationId = verificationId;
    };
    final fnumber = _phoneNumberController.text;
    final pnumber = '+91$fnumber';

    await _auth.verifyPhoneNumber(
        phoneNumber: pnumber,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  Future<bool> smsCodeDialog(BuildContext context) => showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(20.0)),
          title: Text('Enter sms Code'),
          content: TextFormField(
            controller: _smsController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
                hintText: 'Enter OTP', icon: Icon(Icons.perm_phone_msg)),
            maxLength: 6,
            maxLengthEnforced: true,
          ),
          contentPadding: EdgeInsets.all(10.0),
          actions: <Widget>[
            new RaisedButton(
                child: Text('Login'),
                textColor: Colors.white,
                onPressed: () {
                  FirebaseAuth.instance.currentUser().then((user) {
                    if (user != null) {
                      if (selectedRadio == 1) {
                        Navigator.of(context).pop();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    InfoScreen(_phoneNumberController.text)));
                      } else if (selectedRadio == 2) {
                        Navigator.of(context).pop();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Info2Screen(_phoneNumberController.text)));
                      } else if (selectedRadio == 3) {
                        Navigator.of(context).pop();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Info3Screen(_phoneNumberController.text)));
                      }
                    } else {
                      Navigator.of(context).pop();
                      _signInWithPhoneNumber(context);
                    }
                  });
                })
          ],
        );
      });

  void _signInWithPhoneNumber(BuildContext context) async {
    try {
      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: this._verificationId,
        smsCode: _smsController.text,
      );
      final FirebaseUser user =
          (await _auth.signInWithCredential(credential)) as FirebaseUser;
      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);
      if (user != null) {
        if (selectedRadio == 1) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      InfoScreen(_phoneNumberController.text)));
        } else if (selectedRadio == 2) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      Info2Screen(_phoneNumberController.text)));
        } else if (selectedRadio == 3) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      Info3Screen(_phoneNumberController.text)));
        }
      } else {
        Navigator.of(context).pop();
      }
    } catch (e) {
      handleError(e);
    }
  }

  handleError(PlatformException error) {
    print(error);
    switch (error.code) {
      case 'ERROR_INVALID_VERIFICATION_CODE':
        FocusScope.of(context).requestFocus(new FocusNode());
        setState(() {
          errorMessage = 'Invalid Code';
        });
        Navigator.of(context).pop();
        smsCodeDialog(context).then((value) {
          print('sign in');
        });
        break;
      default:
        setState(() {
          errorMessage = error.message;
        });

        break;
    }
  }
}
