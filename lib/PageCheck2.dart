import 'package:flutter/material.dart';
import './Home2.dart';
import './History.dart';
import './Profile2.dart';

class PageCheck2 extends StatefulWidget {
  PageCheck2({Key key}) : super(key: key);

  _PageCheck2State createState() => _PageCheck2State();
}

class _PageCheck2State extends State<PageCheck2> {
  int _selectedPage = 0;
  var darkGreenColor = Color(0xff279152);

  final _pageOptions = [HomePage2(), History(), Profile2()];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: darkGreenColor),
      home: Scaffold(
        body: _pageOptions[_selectedPage],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedPage,
          onTap: (int index) {
            setState(() {
              _selectedPage = index;
            });
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home, color: Colors.black),
                title: Text('Home', style: TextStyle(color: Colors.black))),
            BottomNavigationBarItem(
                icon: Icon(Icons.history, color: Colors.black),
                title: Text('History', style: TextStyle(color: Colors.black))),
            BottomNavigationBarItem(
                icon: Icon(Icons.person, color: Colors.black),
                title: Text('Profile', style: TextStyle(color: Colors.black))),
          ],
        ),
      ),
    );
  }
}
