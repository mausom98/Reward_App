import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './PageCheck2.dart';
import './Login.dart';
import './PageCheck.dart';
import './PageCheck3.dart';

class CheckAuth extends StatefulWidget {
  @override
  _CheckAuthState createState() => new _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth> {
  bool LValue;
  int PValue;
  @override
  void initState() {
    getValuesSF();
    super.initState();
  }

  getValuesSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool LogValue = prefs.getBool('LoginValue');
    int PageValue = prefs.getInt('ScreenValue');
    setState(() {
      LValue = LogValue;
      PValue = PageValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LValue == true
        ? (PValue == 1
            ? PageCheck()
            : (PValue == 2 ? PageCheck2() : PageCheck3()))
        : LoginScreen();
  }
}
