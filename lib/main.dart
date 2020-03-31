import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './authCheck.dart';
import './Home.dart';
import './Login.dart';
import './Home2.dart';
import './Home3.dart';
import './PageCheck.dart';
import './PageCheck2.dart';
import './PageCheck3.dart';

void main() => SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]).then((_) {
      runApp(MaterialApp(
        title: 'Cobra Cables',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: CheckAuth(),
        routes: <String, WidgetBuilder>{
          // Set routes for using the Navigator.
          '/home': (BuildContext context) => new HomePage(),
          '/login': (BuildContext context) => new LoginScreen(),
          '/home2': (BuildContext context) => new HomePage2(),
          '/home3': (BuildContext context) => new HomePage3(),
          '/pageCheck': (BuildContext context) => new PageCheck(),
          '/pageCheck2': (BuildContext context) => new PageCheck2(),
          '/pageCheck3': (BuildContext context) => new PageCheck3()
        },
      ));
    });
